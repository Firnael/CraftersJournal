local _, ES = ...

-- Calculadora de beneficio de una receta, como una hoja de cálculo: materiales en
-- crudo (lo intermedio que sabes fabricar, como el Bolt of Silk Cloth, se desglosa en
-- su tela), el precio de cada uno, la venta y la comisión de la AH (el depósito se
-- enseña aparte: se devuelve si se vende).
-- Los precios salen solos (lo más barato entre la AH del último escaneo y el vendedor,
-- con el descuento de la capital donde tienes más reputación) y cada uno se puede
-- escribir a mano: se guarda en ese cálculo y no cambia nada más del addon.
-- Los cálculos se guardan (varios, de recetas distintas) hasta que los borras.
--
-- CraftersJournalDB.calcs = { list = { calc, ... }, nextID, selected }
--   calc = { id, prof, recipe (hechizo), qty (fabricaciones), prices = { [itemID] = cobre },
--            sale (cobre por unidad, a mano), hours (duración de la subasta), time }

local Calc = {}
ES.Calc = Calc

local MAX_DEPTH = 3 -- intermedios dentro de intermedios, como mucho

-- Capitales de cada bando: los vendedores hacen descuento según tu reputación con la
-- ciudad (los materiales básicos, hilo, tintes, viales, sal..., se venden en todas)
local CITIES = { Alliance = { 72, 47, 69, 54 }, Horde = { 76, 81, 68, 530 } }
local REP_DISCOUNT = { [5] = 0.05, [6] = 0.10, [7] = 0.15, [8] = 0.20 } -- amistoso .. exaltado

---------------------------------------------------------------------------
-- Cálculos guardados
---------------------------------------------------------------------------
local function Store()
  ES.db.calcs = ES.db.calcs or { list = {}, nextID = 1 }
  return ES.db.calcs
end

function Calc:List() return Store().list end

function Calc:Find(id)
  for i, c in ipairs(Store().list) do if c.id == id then return c, i end end
end

function Calc:Selected()
  local s = Store()
  return s.selected and self:Find(s.selected) or s.list[1]
end

function Calc:Select(id) Store().selected = id end

-- Añade un cálculo (arriba de la lista) y lo deja elegido
function Calc:Add(prof, spellID)
  local s = Store()
  local c = { id = s.nextID, prof = prof, recipe = spellID, qty = 1, prices = {}, time = time() }
  s.nextID = s.nextID + 1
  table.insert(s.list, 1, c)
  s.selected = c.id
  return c
end

-- Duración de la subasta del cálculo (2, 8 o 24 h; por defecto 24): cambia el depósito
Calc.DURATIONS = { 2, 8, 24 }
function Calc.Hours(c)
  for _, h in ipairs(Calc.DURATIONS) do if c.hours == h then return h end end
  return 24
end

-- Por dónde se vende: "ah" (comisión y depósito) o "trade" (chat de comercio, cara a
-- cara: sin comisión ni depósito). Por defecto, la AH
Calc.CHANNELS = { "ah", "trade" }
function Calc.Channel(c)
  return c.channel == "trade" and "trade" or "ah"
end

-- Depósito mínimo por subasta en Forever: 1s, aunque el porcentaje dé menos (Wowhead,
-- noviembre de 2026; por montón en lo que se apila). Blizzard ha dicho que volverá a la
-- fórmula de Classic: entonces bastará con cambiar este valor
Calc.MIN_DEPOSIT = 100

-- Unidades por montón de un objeto (1 si no se apila o el juego aún no lo tiene)
function Calc.StackSize(itemID)
  local get = (C_Item and C_Item.GetItemInfo) or GetItemInfo
  local stack = get and select(8, get(itemID))
  return (type(stack) == "number" and stack > 1) and stack or 1
end

-- Depósito de vender `units` unidades: una subasta por montón lleno y otra con lo que
-- sobre, cada una con el mínimo. Devuelve depósito y número de subastas
function Calc.Deposit(perUnit, units, stack)
  if units <= 0 then return 0, 0 end
  local full = math.floor(units / stack)
  local rest = units - full * stack
  local deposit = full * math.max(Calc.MIN_DEPOSIT, perUnit * stack)
  if rest > 0.001 then deposit = deposit + math.max(Calc.MIN_DEPOSIT, perUnit * rest) end
  return deposit, full + (rest > 0.001 and 1 or 0)
end

-- Depósito de una duración en % del precio de vendedor (5/20/60; más en la AH neutral)
function Calc.DepositPct(hours)
  return math.floor(ES.Planner.AuctionCosts(100, { hours = hours, neutral = ES:IsNeutralAH() }) + 0.5)
end

function Calc:Remove(id)
  local s = Store()
  local _, i = self:Find(id)
  if i then table.remove(s.list, i) end
  if s.selected == id then s.selected = s.list[1] and s.list[1].id end
end

---------------------------------------------------------------------------
-- Precios
---------------------------------------------------------------------------
-- Mayor descuento de vendedor por reputación con una capital de tu bando, y cuál
function Calc.CityDiscount()
  local best, bestID = 0, nil
  for _, id in ipairs(CITIES[UnitFactionGroup and UnitFactionGroup("player") or ""] or {}) do
    local d = REP_DISCOUNT[(ES:Standing(id))] or 0
    if d > best then best, bestID = d, id end
  end
  return best, bestID and ES:FactionName(bestID)
end

-- Precio automático de un material: lo más barato entre el vendedor (con el descuento
-- de ciudad) y la subasta más barata del último escaneo. Devuelve precio y fuente
-- ("vendor" o "ah"), o nil si no hay ninguno
function Calc.AutoPrice(itemID, scan, discount)
  local vendor = ES.Data.VendorPrices and ES.Data.VendorPrices[itemID]
  if vendor then vendor = math.floor(vendor * (1 - (discount or 0)) + 0.5) end
  local entry = scan and scan.items and scan.items[itemID]
  local ah = entry and entry.minUnit
  if vendor and (not ah or vendor <= ah) then return vendor, "vendor" end
  if ah then return ah, "ah" end
  return nil
end

-- "2,7" o "2.7" = 2s 70c (en plata, como en una hoja de cálculo); también "1g 20s 5c"
-- (o "1o 20p 5c"). Devuelve cobre, o nil si está vacío o no se entiende
function Calc.ParseMoney(text)
  text = ((text or ""):lower():gsub(",", "."):gsub("^%s+", ""):gsub("%s+$", ""))
  if text == "" then return nil end
  if text:find("[gospc]") then
    local total, any = 0, false
    for num, unit in text:gmatch("([%d%.]+)%s*([gospc])") do
      local n = tonumber(num)
      if not n then return nil end
      local mult = (unit == "g" or unit == "o") and 10000 or (unit == "s" or unit == "p") and 100 or 1
      total, any = total + n * mult, true
    end
    return any and math.floor(total + 0.5) or nil
  end
  local n = tonumber(text)
  return n and n >= 0 and math.floor(n * 100 + 0.5) or nil
end

-- Cobre en texto para escribirlo en una casilla: "1g 2s 70c"
function Calc.FormatMoney(copper)
  if not copper then return "" end
  copper = math.floor(copper + 0.5)
  local g, s, c = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
  local parts = {}
  if g > 0 then parts[#parts + 1] = g .. "g" end
  if s > 0 then parts[#parts + 1] = s .. "s" end
  if c > 0 or #parts == 0 then parts[#parts + 1] = c .. "c" end
  return table.concat(parts, " ")
end

---------------------------------------------------------------------------
-- Cálculo
---------------------------------------------------------------------------
-- Receta de la profesión que fabrica un objeto y sabes (para desglosarlo en crudo)
local function Producer(data, itemID)
  for spellID, r in pairs(data.recipes) do
    if r.out and r.out[1] == itemID and not r.conversion and ES:IsRecipeKnown(spellID) then return r end
  end
end

-- Suma a `need` los materiales en crudo de `crafts` fabricaciones; `made` apunta lo
-- intermedio que se fabrica por el camino (para enseñarlo)
local function Expand(data, recipe, crafts, need, order, made, depth)
  for _, rq in ipairs(recipe.r or {}) do
    local id, n = rq[1], rq[2] * crafts
    local sub = depth < MAX_DEPTH and Producer(data, id)
    if sub then
      made[#made + 1] = { itemID = id, qty = n }
      Expand(data, sub, n / ((sub.out and sub.out[2]) or 1), need, order, made, depth + 1)
    else
      if not need[id] then need[id] = 0 order[#order + 1] = id end
      need[id] = need[id] + n
    end
  end
end

-- Todo el cálculo de una receta guardada:
-- { recipe, rows = { { itemID, qty, price, source ("manual"/"vendor"/"ah"), total } },
--   made, cost, missing, outID, outN, sale, saleSource, revenue, cut, cutRate, deposit,
--   profit, discount, city }; nil si la receta ya no existe en los datos
function Calc:Compute(c)
  local data = ES.Data[c.prof]
  local recipe = data and data.recipes and data.recipes[c.recipe]
  if not recipe then return nil end
  local scan = ES.db.scans and ES.db.scans[ES:RealmKey()]
  local discount, city = Calc.CityDiscount()
  local need, order, made = {}, {}, {}
  Expand(data, recipe, c.qty or 1, need, order, made, 0)

  local res = { recipe = recipe, rows = {}, made = made, cost = 0, missing = false, discount = discount, city = city }
  for _, id in ipairs(order) do
    local price, source = c.prices[id], "manual"
    if not price then price, source = Calc.AutoPrice(id, scan, discount) end
    local row = { itemID = id, qty = need[id], price = price, source = price and source or nil }
    if price then
      row.total = need[id] * price
      res.cost = res.cost + row.total
    else
      res.missing = true
    end
    res.rows[#res.rows + 1] = row
  end

  -- Venta: a mano, o la subasta más barata menos 1c; sin subastas, al vendedor
  res.outID = recipe.out and recipe.out[1]
  res.outN = res.outID and (recipe.out[2] or 1) * (c.qty or 1) or 0
  if res.outID then
    if c.sale then
      res.sale, res.saleSource = c.sale, "manual"
    else
      local entry = scan and scan.items and scan.items[res.outID]
      if entry and entry.minUnit then
        res.sale, res.saleSource = ES.Market.ListPrice(ES.Market:FairPrice(res.outID, entry.minUnit)), "ah"
      else
        res.sale, res.saleSource = ES:VendorSellPrice(res.outID), "vendor"
      end
    end
  end
  res.revenue = (res.sale or 0) * res.outN
  res.cut, res.cutRate, res.deposit = 0, 0, 0
  res.hours = Calc.Hours(c)
  res.depositPct = Calc.DepositPct(res.hours)
  res.channel = Calc.Channel(c)
  -- Se puede elegir AH o chat de comercio salvo si se vende al vendedor
  res.canChoose = res.outID ~= nil and res.saleSource ~= "vendor"
  local ahCut = 0
  if res.canChoose then
    -- En la AH: comisión sobre la venta y depósito según la duración (2/8/24 h: 5/20/60%
    -- del precio de vendedor, la fórmula de Classic). El depósito se devuelve si se
    -- vende: no resta del beneficio, solo se arriesga
    local perUnit, cut = ES.Planner.AuctionCosts(ES:VendorSellPrice(res.outID) or 0, { hours = res.hours, neutral = ES:IsNeutralAH() })
    res.cutRate, ahCut = cut, res.revenue * cut
    if res.channel == "ah" then
      res.cut = ahCut
      res.deposit, res.listings = Calc.Deposit(perUnit, res.outN, Calc.StackSize(res.outID))
    end
  end
  -- Los dos beneficios, para comparar: en la AH y por el chat de comercio (sin comisión)
  res.profitAH = res.revenue - ahCut - res.cost
  res.profitTrade = res.revenue - res.cost
  res.profit = res.revenue - res.cut - res.cost
  return res
end

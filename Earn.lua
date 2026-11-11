local _, ES = ...
local L = ES.L

-- Ganar dinero con tus profesiones, día a día: de las recetas que SABES, cuáles
-- dan beneficio con los precios del último escaneo y cuántas fabricar.
--
-- No se estiman ventas. "Cuántas" solo evita inundar el mercado:
--   alerta "bien":            hasta el AH_SHARE de las unidades a la venta (tope MAX_BATCH)
--   "ojo" / "pocos datos":    unas pocas para probar (TEST_BATCH)
--   "evitar":                 no se recomienda (se lista aparte con el motivo)
--   se vende al vendedor:     venta segura, VENDOR_BATCH
-- (El buzón no se lee: el addon no guarda nada de tu correo.)

local Earn = {}
ES.Earn = Earn

local MIN_PROFIT = 5         -- cobre por fabricación como mínimo
local MIN_MARGIN = 0.10      -- y al menos un 10% sobre el coste
local AH_SHARE = 0.3         -- no anunciar más del 30% de lo que ya hay a la venta
local MAX_BATCH = 10
local TEST_BATCH = 3
local VENDOR_BATCH = 20
local BATCH_SIZE = 8         -- recetas en el lote de hoy
local WATCH_WEIGHT = 0.5     -- "ojo" puntúa la mitad
local OLD_SCAN = 12 * 3600   -- más viejo que esto: avisar

Earn.OLD_SCAN = OLD_SCAN

-- Beneficio mínimo de una línea (lo que dejan todas sus fabricaciones juntas, no
-- cada una): por debajo no compensa el viaje a la AH. Lo elige el jugador en la
-- cabecera (ES.db.earnMinProfit); por defecto, 10 platas
Earn.MIN_LINE_STEPS = { 0, 1000, 5000, 10000, 50000, 200000 } -- 0, 10s, 50s, 1g, 5g, 20g
Earn.DEFAULT_MIN_LINE = 1000
function Earn.MinLineProfit()
  local v = ES.db and ES.db.earnMinProfit
  return type(v) == "number" and v >= 0 and v or Earn.DEFAULT_MIN_LINE
end

-- Siguiente (o anterior, dir = -1) escalón del mínimo
function Earn.StepMinLineProfit(dir)
  local steps, cur = Earn.MIN_LINE_STEPS, Earn.MinLineProfit()
  local i = 1
  for k, v in ipairs(steps) do if v <= cur then i = k end end
  i = ((i - 1 + (dir or 1)) % #steps) + 1
  ES.db.earnMinProfit = steps[i]
  Earn:Clear()
  return steps[i]
end

-- Profesiones del personaje con datos
function Earn.MyProfessions()
  local list = {}
  for _, p in ipairs(ES.PROFESSIONS) do
    local data = ES.Data[p.key]
    if data and ES:GetProfessionSkill(data.skillLine) then list[#list + 1] = p.key end
  end
  return list
end

-- Cuántas fabricar y por qué
local function Batch(idea, e)
  if idea.sellWhere == "vendor" then
    return VENDOR_BATCH, L["Se vende al vendedor: venta segura."]
  end
  local onSale = math.floor((e.quantity or 0) / math.max(1, e.qty))
  local share = onSale > 0 and math.max(1, math.floor(onSale * AH_SHARE)) or TEST_BATCH
  local n, why
  if idea.verdict == "good" then
    n = math.min(MAX_BATCH, share)
    why = onSale > 0 and string.format(L["Hasta el %d%% de lo que hay a la venta (%d)."], AH_SHARE * 100, onSale)
      or L["No hay ninguno a la venta: unos pocos para probar."]
  else
    n = math.min(TEST_BATCH, share)
    why = L["Alertas de mercado dudosas: unos pocos para probar."]
  end
  return math.max(1, n), why
end

-- Coste de una idea para las fabricaciones que quiere (idea.wanted), descontando
-- lo que ya llevas fabricado. El coste de 1 es el de las subastas más baratas;
-- para N hay que subir por la escalera: si a N ya no compensa, se reduce a la mitad.
function Earn.CostIdea(idea)
  local e = idea.e
  idea.have = ES:ItemCount(e.itemID)
  local haveCrafts = math.floor(idea.have / math.max(1, e.qty))
  local n = math.max(0, idea.wanted - haveCrafts)
  idea.why2 = haveCrafts > 0 and string.format(L["Ya tienes %d: se fabrican solo las que faltan."], idea.have) or nil
  if n == 0 then
    idea.crafts, idea.invest, idea.profit, idea.reagents, idea.extra = 0, 0, 0, {}, {}
    return
  end
  local cost, reagents, extra, actions = ES.Planner.RecipeCost(idea.ctx, e.recipe, n, {})
  local start = n
  while n > 1 and (not cost or idea.sale * n - cost < math.max(MIN_PROFIT, MIN_MARGIN * cost) * n) do
    n = math.max(1, math.floor(n / 2))
    cost, reagents, extra, actions = ES.Planner.RecipeCost(idea.ctx, e.recipe, n, {})
  end
  idea.fewer = n < start
  idea.crafts = n
  idea.invest = cost or e.cost * n
  idea.profit = idea.sale * n - idea.invest
  idea.reagents, idea.extra = reagents or e.reagents, extra or {}
  -- Lo que de verdad se compra: también los materiales de lo que fabricas tú por el
  -- camino (Bolt of Mageweave -> su Mageweave Cloth), no solo los de la receta
  idea.actions = actions
end

-- Lo que deja una línea del lote: el beneficio de sus fabricaciones; si ya las
-- tienes hechas (no hay que fabricar), lo que dejan las que llevas
function Earn.LineValue(idea)
  if idea.crafts and idea.crafts > 0 then return idea.profit or 0 end
  return (idea.e.profit or 0) * math.floor((idea.have or 0) / math.max(1, idea.e.qty))
end

-- Todas las ideas, ordenadas por puntuación. Caché por escaneo, reputación,
-- ventas propias y día (las recetas conocidas cambian poco; se vacía en RefreshAllViews).
local cache
function Earn:Clear() cache = nil end
-- Lo que llevas cambia cuántas hay que fabricar
do
  local f = CreateFrame("Frame")
  ES.SafeRegister(f, "BAG_UPDATE_DELAYED")
  f:SetScript("OnEvent", function() cache = nil end)
end

function Earn:Ideas()
  local scan = ES.db.scans and ES.db.scans[ES:RealmKey()]
  local minLine = Earn.MinLineProfit()
  local stamp = table.concat({ scan and scan.time or 0, ES:RealmKey(), ES.repStamp or "", minLine }, ":")
  if cache and cache.stamp == stamp then return cache end
  local res = { stamp = stamp, ideas = {}, avoided = {}, scanTime = scan and scan.time, profs = Earn.MyProfessions(), known = 0,
    minLine = minLine, hidden = 0 }
  for _, profKey in ipairs(res.profs) do
    local data = ES.Data[profKey]
    local entries, ctx = ES.Planner:RecipeMarket(data, {
      hours = 24, neutral = ES:IsNeutralAH(),
      sourcedScrolls = ES.Waypoints.SOURCED_PROFESSIONS[profKey] or nil,
    })
    for _, e in ipairs(entries) do
      if e.learnSource == "known" then
        res.known = res.known + 1
        if e.cost and e.profit and e.profit >= math.max(MIN_PROFIT, e.cost * MIN_MARGIN) then
          local idea = { e = e, profKey = profKey, itemID = e.itemID, sellWhere = e.sellWhere, unitCost = e.cost }
          if idea.sellWhere == "ah" then
            idea.signals = ES.Market:Signals(e.itemID)
            idea.verdict = idea.signals.verdict
            idea.price = ES.Market.ListPrice(e.fair) or 1
          end
          if idea.verdict == "avoid" then
            -- (sin costear: con lo más que se fabricaría, ¿llegaría al mínimo?)
            if e.profit * MAX_BATCH >= minLine then
              res.avoided[#res.avoided + 1] = idea
            else
              res.hidden = res.hidden + 1
            end
          else
            idea.ctx = ctx
            idea.wanted, idea.why = Batch(idea, e)
            idea.sale = (idea.sellWhere == "ah" and e.ahNet or e.vendor) * e.qty -- por fabricación
            Earn.CostIdea(idea)
            if Earn.LineValue(idea) >= minLine then
              idea.score = idea.profit * ((idea.verdict == "watch" or idea.verdict == "unknown") and WATCH_WEIGHT or 1)
              res.ideas[#res.ideas + 1] = idea
            else
              res.hidden = res.hidden + 1
            end
          end
        end
      end
    end
  end
  table.sort(res.ideas, function(a, b) return a.score > b.score end)
  table.sort(res.avoided, function(a, b) return a.e.profit > b.e.profit end)

  -- Lote de hoy: de mejor a peor, cada receta se vuelve a costear contando lo que
  -- ya compran las anteriores (si dos usan el mismo material, la segunda paga las
  -- subastas siguientes, más caras).
  res.batch, res.invest, res.profit = {}, 0, 0
  local ctxs = {}
  for _, idea in ipairs(res.ideas) do ctxs[idea.ctx] = true end
  for ctx in pairs(ctxs) do ctx.used = {} end
  local need = {}
  for _, idea in ipairs(res.ideas) do
    if #res.batch >= BATCH_SIZE then break end
    Earn.CostIdea(idea)
    -- (con los materiales que ya compran las anteriores puede quedarse por debajo del mínimo)
    if (idea.crafts == 0 or idea.profit > 0) and Earn.LineValue(idea) >= minLine then
      res.batch[#res.batch + 1] = idea
      idea.inBatch = true
      res.invest = res.invest + idea.invest
      res.profit = res.profit + idea.profit
      -- Lo que compra esta receta ya no está para las siguientes (en todas las profesiones)
      for key, q in pairs(idea.extra or {}) do
        if type(key) == "number" and key > 0 then
          for ctx in pairs(ctxs) do ctx.used[key] = (ctx.used[key] or 0) + q end
        end
      end
    end
  end
  local function Need(itemID, source, qty, cost)
    local n = need[itemID]
    if not n then
      n = { itemID = itemID, quantity = 0, total = 0, source = source }
      need[itemID] = n
    end
    n.quantity = n.quantity + qty
    n.total = n.total + cost
  end
  for _, idea in ipairs(res.batch) do
    if idea.actions then
      -- Las compras (AH y vendedor) de todas sus fabricaciones, también las de los
      -- materiales que fabricas tú (un Bolt of Mageweave se compra como Mageweave Cloth)
      for _, a in ipairs(idea.actions) do
        if a.kind == "ah" or a.kind == "vendor" then Need(a.item, a.kind, a.qty, a.cost or 0) end
      end
    else
      -- idea.reagents ya va para todas sus fabricaciones
      for _, rg in ipairs(idea.reagents or {}) do
        Need(rg.item, rg.kinds.ah and "ah" or rg.kinds.vendor and "vendor" or "craft", rg.qty, rg.cost)
      end
    end
  end
  res.shopping = {}
  for _, n in pairs(need) do
    n.unit = n.total / math.max(1, n.quantity)
    res.shopping[#res.shopping + 1] = n
  end
  table.sort(res.shopping, function(a, b) return a.total > b.total end)
  cache = res
  return res
end

-- Recetas con enfriamiento (transmutaciones, tela lunar...) que sabes y están listas
local COOLDOWN_NAMES = { "^Transmute", "Mooncloth" }
function Earn:Cooldowns()
  local list = {}
  if not GetSpellCooldown then return list end
  for _, profKey in ipairs(Earn.MyProfessions()) do
    local data = ES.Data[profKey]
    ES.Planner.Annotate(data)
    for id, r in pairs(data.recipes) do
      local isCd = false
      for _, pat in ipairs(COOLDOWN_NAMES) do if (r.name or ""):find(pat) then isCd = true end end
      if isCd and ES:IsRecipeKnown(id) then
        local start, duration = GetSpellCooldown(id)
        local left = (start and start > 0 and duration) and (start + duration - GetTime()) or 0
        -- Beneficio de hacerlo, si está entre las ideas (o las descartadas por el mercado)
        local profit
        for _, idea in ipairs(cache and cache.ideas or {}) do if idea.e.id == id then profit = idea.e.profit end end
        for _, idea in ipairs(cache and cache.avoided or {}) do if idea.e.id == id then profit = idea.e.profit end end
        list[#list + 1] = { recipe = r, id = id, profKey = profKey, ready = left <= 0, left = math.max(0, left), profit = profit }
      end
    end
  end
  table.sort(list, function(a, b) return a.left < b.left end)
  return list
end

-- Materiales de profesiones en tus bolsas que no usa ninguna receta que sabes:
-- candidatos a vender (precio de la AH y del vendedor)
local function BagItems()
  local items = {}
  local numSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
  local itemID = (C_Container and C_Container.GetContainerItemID) or GetContainerItemID
  if not numSlots or not itemID then return items end
  for bag = 0, 4 do
    for slot = 1, numSlots(bag) or 0 do
      local id = itemID(bag, slot)
      if id then items[id] = true end
    end
  end
  return items
end

function Earn:Leftovers()
  local used = {}
  for _, profKey in ipairs(Earn.MyProfessions()) do
    local data = ES.Data[profKey]
    ES.Planner.Annotate(data)
    for id, r in pairs(data.recipes) do
      if ES:IsRecipeKnown(id) then
        for _, rq in ipairs(r.r) do used[rq[1]] = true end
      end
    end
  end
  local scan = ES.db.scans and ES.db.scans[ES:RealmKey()]
  local list, hidden = {}, 0
  local minLine = Earn.MinLineProfit()
  for id in pairs(BagItems()) do
    if not used[id] and ES.History:IsTracked(id) then
      local count = ES:ItemCount(id)
      local ah = scan and scan.items[id]
      local vendor = ES:VendorSellPrice(id) or 0
      -- En la AH, al precio realista (si el mínimo está inflado, el de los últimos días)
      local fair = ah and ES.Market:FairPrice(id, ah.minUnit)
      local ahPrice = fair and ES.Market.ListPrice(fair)
      local best = math.max(vendor, ahPrice and ahPrice * 0.95 or 0) -- 5% de comisión
      if best > 0 and best * count >= minLine then
        list[#list + 1] = { itemID = id, count = count, ahPrice = ahPrice, fair = fair, vendor = vendor, value = best * count }
      elseif best > 0 then
        hidden = hidden + 1
      end
    end
  end
  table.sort(list, function(a, b) return a.value > b.value end)
  return list, hidden
end

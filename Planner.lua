local _, ES = ...

-- Planificador de subida de profesión.
-- Para cada punto de habilidad elige la receta con menor coste esperado:
-- (materiales para 1/probabilidad fabricaciones) - (lo que recuperas vendiendo).
--
-- Materiales, por orden: lo que tienes en bolsas, lo que recolectas tú, lo
-- fabricado en pasos anteriores (si sale más barato que venderlo y comprar),
-- vendedor, AH o fabricarlo. En la AH se recorren las subastas de más barata a
-- más cara descontando lo ya comprado; con ignoreSupply (lo que usa la UI), lo
-- que exceda de lo anunciado se paga a la mediana en vez de parar el plan.

local Planner = {}
ES.Planner = Planner

-- Comisión y depósito de la AH (Classic / WoW Forever, subastas de 2, 8 o 24 h).
-- Depósito = precio de vendedor x unidades x tasa por cada 2 h: 5% en la AH de
-- tu facción (2 h = 5%, 8 h = 20%, 24 h = 60%) y 5 veces más en la neutral.
-- Se pierde si la subasta no se vende; aquí se cuenta como coste de vender en la AH.
local AH_CUT, AH_CUT_NEUTRAL = 0.05, 0.15
local DEPOSIT_RATE, DEPOSIT_RATE_NEUTRAL = 0.05, 0.25
Planner.DURATIONS = { 2, 8, 24 }

-- Depósito por unidad y comisión según la AH y la duración elegidas
function Planner.AuctionCosts(vendorPrice, opts)
  local hours = opts.hours or 24
  local rate = opts.neutral and DEPOSIT_RATE_NEUTRAL or DEPOSIT_RATE
  return (vendorPrice or 0) * rate * hours / 2, opts.neutral and AH_CUT_NEUTRAL or AH_CUT
end
local APPRENTICE_CAP = 75
local BASIC_MAX_YELLOW = 50 -- recetas sin instructor ni pergamino por debajo de esto: básicas
-- Coste simbólico por fabricación y cuánto más puede costar la ruta que lo tiene
-- en cuenta frente a la más barata (ver Planner:Plan)
local CRAFT_COST = 5          -- cobre por fabricación, solo para elegir
local PROFIT_FULL_CRAFTS = 5  -- hasta estas fabricaciones por punto, el beneficio de vender cuenta entero
-- Lo que tiene que ahorrar cada fabricación de un material intermedio (Light Leather
-- de Ruined Leather Scraps, barras...) frente a comprarlo para fabricarlo (ver Acquire)
local INTERMEDIATE_CRAFT_COST = 5
local VIA_ROUNDS = 2          -- vueltas de cambiar fabricar ↔ comprar (ver Planner:Plan)
local MAX_EXTRA_PCT = 0.03    -- hasta un 3% de los materiales más
local MAX_EXTRA_MIN = 100     -- o 1 plata, lo que sea mayor
-- Recetas de pago usadas menos puntos de los supuestos al elegirlas (ver Planner:Plan)
local FEE_PASSES = 4          -- pasadas como mucho
local FEE_SLACK = 0.75        -- se repite si se usó menos del 75% de lo supuesto
-- Sin zigzag (ver Planner.Smooth)
local SMOOTH_MIN = 3          -- pasos de menos puntos que esto son "cortos"
local SMOOTH_TOLERANCE = 100  -- cobre que puede costar de más hacer el tramo con una sola receta
local SMOOTH_PCT = 0.005      -- o el 0,5% de los materiales, lo que sea mayor
local SMOOTH_PASSES = 4       -- tramos que se arreglan como mucho
-- Recetas de pergamino que se prueba a quitar al acabar la ruta (ver Planner:Plan)
local MAX_SEARCH = 3
local SEARCH_MIN_SAVING = 10  -- cobre: por debajo no merece cambiar la ruta
local SEARCH_SOURCES = { vendor = true, ah = true, scroll = true, quest = true }
-- Con lo que llevas (ver Planner.BagsAlternative)
local BAGS_MIN_POINTS = 5   -- puntos que te tienen que dar tus materiales
local BAGS_MIN_SAVING = 50  -- cobre de oro ahorrado: por debajo no se considera
local BAGS_MIN_WORTH = 50   -- cobre que tiene que ganar a vender lo tuyo para meterla en la ruta
local BAGS_PASSES = 3       -- recetas con lo tuyo que se meten como mucho
-- Empate: si usar lo tuyo sale casi igual que venderlo (la diferencia es menos del
-- BAGS_TIE_PCT de lo que vale lo tuyo), se usa lo tuyo: no hay que vender 68 telas
-- en la AH (depósito, sin garantía de venderlas) ni comprar los materiales de la ruta
local BAGS_TIE_PCT = 0.15
Planner.BAGS_MIN_WORTH = BAGS_MIN_WORTH

-- ¿Usar lo tuyo (alt: ver BagsAlternative) compensa o empata con venderlo?
function Planner.BagsWorth(alt)
  return alt.saving - alt.value > -BAGS_TIE_PCT * (alt.value or 0)
end

-- Tramos de pasos cortos (menos de SMOOTH_MIN puntos cada uno, al menos dos
-- seguidos): se rehace la ruta con cada receta del tramo para todo él (ruta fijada,
-- una pasada) y se queda la más barata de las que no cuestan más de SMOOTH_TOLERANCE
-- (o SMOOTH_PCT de los materiales) que la original y llegan igual de lejos.
function Planner.Smooth(data, opts, plan)
  local skip = {} -- tramos (por su nivel de inicio) que no se pudieron arreglar
  for _ = 1, SMOOTH_PASSES do
    local steps, window = plan.steps, nil
    local i = 1
    while i <= #steps and not window do
      local j = i
      while j <= #steps and steps[j].to - steps[j].from < SMOOTH_MIN do j = j + 1 end
      if j - i >= 2 and not skip[steps[i].from] then window = { i, j - 1 } else i = math.max(i + 1, j) end
    end
    if not window then return plan end
    local from, to = steps[window[1]].from, steps[window[2]].to
    local allowed = plan.net + math.max(SMOOTH_TOLERANCE, SMOOTH_PCT * (plan.reagentCost or 0))
    local best, tried = nil, {}
    for k = window[1], window[2] do
      local id = steps[k].id
      if not tried[id] then
        tried[id] = true
        local o = {}
        for key, v in pairs(opts) do o[key] = v end
        o.forced = {}
        for s, c in pairs(plan.choice) do o.forced[s] = c end
        for s = from, to - 1 do o.forced[s] = id end
        local p = Planner:Plan(data, o)
        if p.reached >= plan.reached and p.net <= allowed and (not best or p.net < best.net) then best = p end
      end
    end
    if best then
      best.cheapest, best.craftCostUsed = plan.cheapest, plan.craftCostUsed
      plan = best
    else
      skip[from] = true -- ninguna sirve: se deja como estaba
    end
  end
  return plan
end

-- Unidades de cada material que pide la ruta desde el nivel `level` hasta el final
function Planner.NeedFrom(plan, level)
  local need = {}
  for s, items in pairs(plan.pointNeed or {}) do
    if s >= level then
      for itemID, q in pairs(items) do need[itemID] = (need[itemID] or 0) + q end
    end
  end
  return need
end

---------------------------------------------------------------------------
-- Comprar por tramos: en vez de toda la ruta de golpe, lo del tramo en el que
-- estás, con un colchón donde la suerte cuenta (amarillo y verde). Al acabar el
-- tramo, el siguiente. La lista es viva: lo que falta = lo del tramo - lo que llevas
---------------------------------------------------------------------------
Planner.PHASE_Z = 1 -- colchón: 1 desviación (te llega ~8 de cada 10 veces); 0 = lo esperado

-- Materiales que pide un nivel (las claves de pointNeed)
local function PointItems(plan, s)
  local set = {}
  for itemID in pairs(plan.pointNeed and plan.pointNeed[s] or {}) do set[itemID] = true end
  return set
end

-- Tramo en el que estás: { from, to, steps = { pasos } } o nil (ruta acabada). Es el
-- paso de tu nivel; los siguientes se juntan si no piden ningún material nuevo
-- (Copper Bracers y luego Copper Chain Pants: una sola visita a la AH)
function Planner.Phase(plan, level)
  local steps = plan and plan.steps or {}
  local first
  for i, st in ipairs(steps) do
    if level < st.to then first = i break end
  end
  if not first then return nil end
  local phase = { from = math.max(level, steps[first].from), to = steps[first].to, steps = { steps[first] } }
  local items = {}
  for s = steps[first].from, steps[first].to - 1 do
    for itemID in pairs(PointItems(plan, s)) do items[itemID] = true end
  end
  for i = first + 1, #steps do
    local st, new = steps[i], false
    for s = st.from, st.to - 1 do
      for itemID in pairs(PointItems(plan, s)) do if not items[itemID] then new = true end end
    end
    if new or st.from ~= phase.to then break end
    phase.to = st.to
    phase.steps[#phase.steps + 1] = st
  end
  return phase
end

-- Lo que pide el tramo desde tu nivel: { [itemID] = { expected, target } }. target
-- lleva el colchón: en un punto con probabilidad p, las fabricaciones son aleatorias
-- (media 1/p, varianza (1-p)/p²); un material que pide q de media en ese punto
-- varía q²(1-p). Naranja (p = 1): lo justo
function Planner.PhaseNeed(plan, level, z)
  local phase = Planner.Phase(plan, level)
  if not phase then return {}, nil end
  z = z or Planner.PHASE_Z
  local acc = {}
  for s = phase.from, phase.to - 1 do
    local p = plan.pointChance and plan.pointChance[s] or 1
    for itemID, q in pairs(plan.pointNeed and plan.pointNeed[s] or {}) do
      local a = acc[itemID] or { expected = 0, var = 0 }
      acc[itemID] = a
      a.expected = a.expected + q
      a.var = a.var + q * q * (1 - p)
    end
  end
  local out = {}
  for itemID, a in pairs(acc) do
    local target = math.ceil(a.expected + z * math.sqrt(a.var) - 0.001)
    if target > 0 then out[itemID] = { expected = a.expected, target = target } end
  end
  return out, phase
end

-- Cómo vas en el tramo con lo que llevas (have(itemID) = unidades):
-- { phase, short = { [itemID] = cuántas faltan para lo esperado }, extra = { [itemID]
--   = cuántas faltan hasta el colchón }, ok (llega a lo esperado) }
function Planner.PhaseOutlook(plan, level, have)
  local need, phase = Planner.PhaseNeed(plan, level)
  if not phase then return nil end
  local res = { phase = phase, short = {}, extra = {}, ok = true }
  for itemID, n in pairs(need) do
    local h = have(itemID) or 0
    local exp = math.ceil(n.expected - 0.001)
    if h < exp then res.short[itemID], res.ok = exp - h, false end
    if h < n.target then res.extra[itemID] = n.target - h end
  end
  return res
end

-- Fabricaciones totales de un plan
function Planner.TotalCrafts(plan)
  local n = 0
  for _, st in ipairs(plan.steps or {}) do n = n + st.crafts end
  return n
end
local MAX_CRAFT_DEPTH = 3
local EPS = 1e-6

-- Probabilidad clásica de subir punto
function Planner.Chance(t, skill)
  local yellow, grey = t[2], t[4]
  if skill < yellow then return 1 end
  if skill >= grey then return 0 end
  return (grey - skill) / (grey - yellow)
end

-- Donde la ruta se para (no hay materiales para un punto entero: Rough Grinding
-- Stone al 62% pide 1,6 fabricaciones y llevas piedra para 1), lo que puedes
-- intentar con lo que llevas: la receta que sabes con más probabilidad de subir
-- a skill + 1. owned = { [itemID] = unidades }; isKnown(id) dice si la sabes.
-- Devuelve { id, recipe, crafts, chance, prob } o nil
function Planner.Attempt(data, skill, owned, isKnown)
  local best
  for id, r in pairs(data.recipes) do
    local chance = not r.intermediate and not r.conversion and Planner.Chance(r.t, skill) or 0
    local tool = r.tool and ES.Data.Tools and ES.Data.Tools[r.tool]
    if chance > 0 and (r.t[1] or 1) <= skill and (not tool or (owned[tool.item] or 0) > 0) and isKnown(id) then
      -- Fabricaciones que caben: lo que vende un vendedor no limita
      local fit
      for _, rq in ipairs(r.r) do
        if not ES.Data.VendorPrices[rq[1]] then
          local n = math.floor((owned[rq[1]] or 0) / rq[2])
          fit = fit and math.min(fit, n) or n
        end
      end
      local crafts = math.min(fit or 0, math.ceil(1 / chance - 0.001))
      if crafts >= 1 then
        local prob = 1 - (1 - chance) ^ crafts
        if not best or prob > best.prob + EPS or (math.abs(prob - best.prob) <= EPS and crafts < best.crafts) then
          best = { id = id, recipe = r, crafts = crafts, chance = chance, prob = prob }
        end
      end
    end
  end
  return best
end

-- Precio del instructor y nivel al que enseña la receta: lo visto en el juego
-- (Ledger:ReadTrainer, CraftersJournalDB.trainerFees) manda sobre los datos
function Planner.Fee(recipe)
  local seen = recipe.id and ES.db and ES.db.trainerFees and ES.db.trainerFees[recipe.id]
  if seen then return seen.cost, seen.skill or recipe.train end
  return recipe.fee, recipe.train
end
local Fee = Planner.Fee

-- Recetas de pergamino buscadas por sus fuentes reales (misión, vendedor, AH;
-- ver Waypoints.RecipeSource): solo si la profesión está en la prueba piloto
local function Sourced(recipe, opts)
  return opts.sourcedScrolls and recipe.scroll and not Fee(recipe)
end

local function ScanPrices()
  local scan = ES.db and ES.db.scans and ES.db.scans[ES:RealmKey()]
  return scan and scan.items or {}
end

-- ¿Ya la sabe el personaje? (necesita recipe.id; ver Annotate)
local function Known(recipe)
  return recipe.id and ES.IsRecipeKnown and ES:IsRecipeKnown(recipe.id)
end

-- Cada receta guarda su id (el hechizo) para poder preguntar si ya se sabe
local function Annotate(data)
  if data._annotated then return end
  for id, r in pairs(data.recipes) do r.id = id end
  data._annotated = true
end
Planner.Annotate = Annotate

-- Nivel mínimo para aprender la receta, o nil si no la consideramos disponible
function Planner.LearnSkill(recipe, opts)
  local fee, train = Fee(recipe)
  if Known(recipe) then return train or 1 end -- ya la sabes: siempre disponible
  if recipe.rep and not ES:RepMet(recipe.rep) then return nil end -- te falta reputación
  -- Merchant's Favor: se compra con fichas y reputación del campamento, no con oro.
  -- Solo con su icono activado (opts.useFavor; por defecto no): entonces cuesta 0 oro
  if recipe.favor then return opts.useFavor and (recipe.train or 1) or nil end
  if Sourced(recipe, opts) then
    local src = ES.Waypoints.RecipeSource(recipe, opts.prices or ScanPrices(), opts.noQuests)
    return src and src.best and (recipe.train or 1) or nil
  end
  if fee or recipe.intermediate then return train end
  if recipe.basic then return 1 end -- se aprende sola al coger la profesión (dato del cliente)
  -- De instructor sin precio conocido (nueva de Forever): al ponerse amarilla
  if recipe.trainer then return train or recipe.t[2] end
  -- Datos antiguos sin "basic": las de amarilla baja eran básicas
  if not recipe.scroll and recipe.basic == nil and recipe.trainer == nil and recipe.t[2] <= BASIC_MAX_YELLOW then return 1 end
  if not opts.includeScrolls then return nil end
  if recipe.scroll then return recipe.train end
  -- Sin instructor ni pergamino conocido (misión, reputación...): estimación
  return math.max(1, recipe.t[2] - 10)
end

-- Cuánto cuesta aprender la receta y de dónde: "known" (ya la sabes), "trainer",
-- "vendor", "scroll", "owned" (pergamino en tus bolsas), "quest", "ah", "favor"
-- (Merchant's Favor: fichas, no oro) o "unknown"
function Planner.LearnCost(ctx, recipe)
  if Known(recipe) then return 0, "known" end
  if recipe.rep and not ES:RepMet(recipe.rep) then return 0, "rep" end -- solo para la vista Recetas
  local fee = Fee(recipe)
  if fee then return fee, "trainer" end
  if recipe.trainer then return 0, "trainer" end -- de instructor, precio desconocido (se pinta "?")
  if recipe.basic then return 0, nil end
  if recipe.favor then return 0, "favor" end
  if Sourced(recipe, ctx.opts) then
    local src = ES.Waypoints.RecipeSource(recipe, ctx.prices, ctx.opts.noQuests)
    if src and src.best then return src.best.cost, src.best.kind end
    return 0, "unknown"
  end
  if recipe.intermediate then return 0, nil end -- precio del instructor desconocido
  if recipe.scroll then
    local ah = ctx.prices[recipe.scroll]
    if ah and ah.minUnit then return ah.minUnit, "scroll" end
    return 0, "unknown"
  end
  if recipe.t[2] <= BASIC_MAX_YELLOW then return 0, nil end
  return 0, "unknown"
end

---------------------------------------------------------------------------
-- Existencias y precios
---------------------------------------------------------------------------
-- Escalera { p1, q1, p2, q2, ... }; los escaneos antiguos solo tienen el mínimo
local function Ladder(entry)
  if not entry then return nil end
  if entry.ladder and #entry.ladder > 0 then return entry.ladder end
  if entry.minUnit then return { entry.minUnit, entry.quantity or 1 } end
  return nil
end

local function LadderSupply(ladder)
  local total = 0
  for i = 2, #ladder, 2 do total = total + ladder[i] end
  return total
end

-- Precio por unidad de la unidad mediana anunciada (no le afectan ni una
-- subasta suelta muy barata ni una absurdamente cara)
local function MedianPrice(ladder)
  local half = LadderSupply(ladder) / 2
  local acc = 0
  for i = 1, #ladder, 2 do
    acc = acc + ladder[i + 1]
    if acc >= half then return ladder[i] end
  end
  return ladder[#ladder - 1]
end
Planner.MedianPrice = MedianPrice

-- Coste de comprar `qty` unidades después de las `used` ya compradas; nil si no hay bastantes
local function LadderCost(ladder, used, qty)
  local cost, skip, need = 0, used, qty
  for i = 1, #ladder, 2 do
    local price, q = ladder[i], ladder[i + 1]
    if skip >= q then
      skip = skip - q
    else
      local take = math.min(q - skip, need)
      skip = 0
      cost = cost + take * price
      need = need - take
      if need <= EPS then return cost end
    end
  end
  return nil
end

local function NewContext(data, opts)
  Annotate(data)
  local scan = ES.db.scans[ES:RealmKey()]
  local ctx = {
    data = data,
    opts = opts,
    -- opts.prices: los de la ruta fijada (guardados al empezarla); si no, el último escaneo
    prices = opts.prices or (scan and scan.items) or {},
    scanTime = opts.prices and opts.pricesTime or (scan and scan.time),
    ladders = {},
    supply = {},     -- unidades a la venta de cada objeto (suma de su escalera)
    medians = {},    -- mediana de lo anunciado (con todos los precios; ver Scanner.BuildLadder)
    used = {},       -- unidades de cada objeto ya compradas en la AH por el plan
    stock = {},      -- inventario del plan: lo fabricado en pasos anteriores, por lotes de valor
    owned = {},      -- lo que llevas en bolsas/banco y queda por usar
    -- [itemID] = "craft" | "buy": lo que se decidió la primera vez para un material que
    -- se puede fabricar; se mantiene en todo el plan (no restos Y cuero comprado a la
    -- vez). opts.via lo fija de antemano (ver Plan y la ruta fijada)
    via = {},
    visiting = {},
    producers = {},
  }
  -- opts.shared (PlanGPS): escaleras y quién fabrica qué, ya preparadas en este
  -- mismo cálculo (mismos precios y mismo objetivo); no se modifican, se comparten
  local shared = opts.shared
  if shared and shared.prices == ctx.prices and shared.to == opts.to then
    ctx.ladders, ctx.supply, ctx.medians, ctx.producers = shared.ladders, shared.supply, shared.medians, shared.producers
  else
    shared = nil
    for itemID, entry in pairs(ctx.prices) do
      local ladder = Ladder(entry)
      ctx.ladders[itemID] = ladder
      ctx.supply[itemID] = ladder and LadderSupply(ladder)
      ctx.medians[itemID] = entry.median
    end
  end
  for itemID, count in pairs(opts.owned or {}) do
    if count > 0 then ctx.owned[itemID] = count end
  end
  for itemID, way in pairs(opts.via or {}) do ctx.via[itemID] = way end
  -- Herramientas por familia (bastones rúnicos, martillo, piedra filosofal):
  -- dentro de una familia la mejor que ya tienes cubre las inferiores
  ctx.toolMask = {}
  for _, tool in pairs(ES.Data.Tools or {}) do
    local fam = tool.family or "rod"
    if (opts.owned or {})[tool.item] and tool.mask > (ctx.toolMask[fam] or 0) then ctx.toolMask[fam] = tool.mask end
  end
  if not shared then
    for id, r in pairs(data.recipes) do
      local learn = r.out and Planner.LearnSkill(r, opts)
      if learn and learn <= opts.to then
        local list = ctx.producers[r.out[1]] or {}
        list[#list + 1] = id
        ctx.producers[r.out[1]] = list
      end
    end
  end
  return ctx
end

local function Copy(t)
  local c = {}
  for k, v in pairs(t) do c[k] = v end
  return c
end

-- Lotes del inventario del plan: { valor1, cantidad1, ... } de menor a mayor valor
local function AddLot(lots, value, qty)
  if qty <= EPS then return end
  value = math.floor(value + 0.5)
  for i = 1, #lots, 2 do
    if lots[i] == value then lots[i + 1] = lots[i + 1] + qty return end
    if lots[i] > value then
      table.insert(lots, i, qty)
      table.insert(lots, i, value)
      return
    end
  end
  lots[#lots + 1] = value
  lots[#lots + 1] = qty
end

-- Saca `qty` del inventario empezando por lo de menor valor
local function ConsumeLots(lots, qty)
  while qty > EPS and #lots > 0 do
    local take = math.min(lots[2], qty)
    lots[2] = lots[2] - take
    qty = qty - take
    if lots[2] <= EPS then
      table.remove(lots, 1)
      table.remove(lots, 1)
    end
  end
end

-- Consigue `qty` unidades de un objeto por la vía más barata disponible.
-- Primero lo que ya has fabricado en pasos anteriores (inventario del plan:
-- cuesta lo que dejas de ganar al no venderlo); el resto del vendedor, la AH
-- (según existencias) o fabricándolo. Devuelve el coste o nil, y anota en
-- `extra` lo gastado (AH con clave itemID, inventario con clave -itemID) y en
-- `actions` lo que hay que hacer. `why` recoge el motivo cuando no se puede:
-- "price" (sin precio) o "supply" (no hay bastantes).
local function Acquire(ctx, itemID, qty, depth, extra, actions, why, skip)
  -- 1. Lo que ya llevas en bolsas/banco: gratis
  local have = skip == nil and ctx.owned[itemID]
  if have then
    local ownKey = "o" .. itemID
    local usedNow = extra[ownKey] or 0
    local avail = have - usedNow
    if avail > EPS then
      local take = math.min(avail, qty)
      -- (el GPS le pone precio: lo que te darían vendiéndolo; ver PlanGPS)
      local own = take * (ctx.ownedPrice and ctx.ownedPrice[itemID] or 0)
      extra[ownKey] = usedNow + take
      actions[#actions + 1] = { kind = "owned", item = itemID, qty = take, cost = own }
      if qty - take <= EPS then return own end
      local rest = Acquire(ctx, itemID, qty - take, depth, extra, actions, why, "owned")
      return rest and rest + own
    end
  end

  -- 2. Lo fabricado en pasos anteriores del plan
  local lots = skip ~= "all" and ctx.opts.reuseCrafted and ctx.stock[itemID]
  if lots then
    local usedNow = extra[-itemID] or 0
    local avail = LadderSupply(lots) - usedNow
    if avail > EPS then
      -- Opción A: lo que tienes (hasta donde llegue) y el resto por otra vía
      local take = math.min(avail, qty)
      local exA, acA = Copy(extra), {}
      local costA = LadderCost(lots, usedNow, take)
      exA[-itemID] = usedNow + take
      acA[1] = { kind = "stock", item = itemID, qty = take, cost = costA }
      if qty - take > EPS then
        local rest = Acquire(ctx, itemID, qty - take, depth, exA, acA, why, "all")
        costA = rest and costA + rest or nil
      end
      -- Opción B: no tocar el inventario (se vende) y conseguirlo por otra vía
      local exB, acB = Copy(extra), {}
      local costB = Acquire(ctx, itemID, qty, depth, exB, acB, why, "all")

      local useA = costA and (not costB or costA <= costB)
      local cost, ex, ac = costB, exB, acB
      if useA then cost, ex, ac = costA, exA, acA end
      if not cost then return nil end
      for k, v in pairs(ex) do extra[k] = v end
      for _, a in ipairs(ac) do actions[#actions + 1] = a end
      return cost
    end
  end

  local best, kind, craft
  local vendor = ES.Data.VendorPrices[itemID]
  if vendor then best, kind = vendor * qty, "vendor" end

  local ladder = ctx.ladders[itemID]
  if ladder then
    local cost
    local used = (ctx.used[itemID] or 0) + (extra[itemID] or 0)
    if ctx.opts.ignoreSupply then
      -- Lo anunciado se compra de más barata a más cara, descontando lo que el
      -- plan ya ha comprado (lo que pagarías de verdad). Si hace falta más de lo
      -- que hay a la venta, el resto al precio de referencia (mediana): el plan
      -- no se para por existencias.
      local fromAH = math.min(qty, math.max(0, ctx.supply[itemID] - used))
      local median = ctx.medians[itemID] or MedianPrice(ladder)
      cost = (fromAH > EPS and (LadderCost(ladder, used, fromAH) or fromAH * median) or 0) + (qty - fromAH) * median
    else
      cost = LadderCost(ladder, used, qty)
    end
    if cost then
      if not best or cost < best then best, kind = cost, "ah" end
    elseif not vendor then
      why[itemID] = why[itemID] or "supply"
    end
  end

  -- Decidido antes comprarlo (y se puede): no se mira fabricarlo
  local via = ctx.via[itemID]
  local canCraft = depth < MAX_CRAFT_DEPTH and ctx.producers[itemID] and not ctx.visiting[itemID]
  if via == "buy" and best then canCraft = false end
  local blockBuy -- (ver abajo: lo que la ruta fabrica y aún da puntos no se compra entretanto)
  if canCraft then
    ctx.visiting[itemID] = true
    for _, rid in ipairs(ctx.producers[itemID]) do
      local r = ctx.data.recipes[rid]
      local crafts = qty / r.out[2]
      local subExtra, subActions, total = Copy(extra), {}, 0
      -- Una receta que aún da puntos a tu nivel (Rough Blasting Powder a 1) no se
      -- fabrica a escondidas como preparación: la ruta diría "fabrica 133 a nivel 1" y
      -- esas fabricaciones subirían la profesión sin contar. Tiene que ser un paso de la
      -- ruta (lo fabricado se guarda para el siguiente). Sí: lo intermedio que no da
      -- puntos (Cured Thick Hide, conversiones) y lo que ya está en gris
      if ctx.skill and not r.intermediate and not r.conversion and Planner.Chance(r.t, ctx.skill) > 0 then
        total = nil
        -- Y si la ruta lo fabrica (via "craft"), tampoco se compra mientras tanto: si
        -- no, "compra hasta 40 y fabrica desde 40" (la dinamita pedía pólvora antes de
        -- que la ruta dijera de dónde sale). Tiene que venir de un paso de la ruta
        if via == "craft" then blockBuy = true end
      end
      for _, rq in ipairs(total and r.r or {}) do
        local cost = Acquire(ctx, rq[1], rq[2] * crafts, depth + 1, subExtra, subActions, why)
        if not cost then total = nil break end
        total = total + cost
      end
      -- Fabricarlo tiene que ahorrar al menos INTERMEDIATE_CRAFT_COST por fabricación:
      -- si no, se compra (521 Ruined Leather Scraps y 174 fabricaciones de Light
      -- Leather por 1 cobre menos cada uno no compensan). Solo si se puede comprar:
      -- si no hay otra vía, se fabrica igual
      -- Decidido antes fabricarlo: se fabrica aunque ahora comprarlo saliera algo
      -- mejor. Entre dos recetas que lo fabrican, la más barata
      local better = total and (not best
        or (kind == "craft" and total < best)
        or (kind ~= "craft" and (via == "craft" or total + crafts * INTERMEDIATE_CRAFT_COST < best)))
      if better then
        best, kind = total, "craft"
        craft = { extra = subExtra, actions = subActions, recipe = rid }
      end
    end
    ctx.visiting[itemID] = nil
  end
  if blockBuy and kind ~= "craft" then best, kind = nil, nil end

  if not best then
    if not ladder and not vendor then why[itemID] = why[itemID] or "price" end
    return nil
  end

  if kind == "craft" then
    for k, v in pairs(craft.extra) do extra[k] = v end
    for _, a in ipairs(craft.actions) do actions[#actions + 1] = a end
    actions[#actions + 1] = { kind = "craft", item = itemID, qty = qty, cost = best, recipe = craft.recipe }
  else
    if kind == "ah" then extra[itemID] = (extra[itemID] or 0) + qty end
    actions[#actions + 1] = { kind = kind, item = itemID, qty = qty, cost = best }
  end
  return best
end

-- Cuánto costaría fabricar tú 1 unidad de un objeto (la receta más barata que
-- lo produce), sin usar inventario ni bolsas. nil si no se fabrica o falta precio.
-- Sirve para explicar en la lista de la compra por qué se compra en vez de fabricar.
function Planner.CraftUnitCost(ctx, itemID)
  local best, bestRecipe
  for _, rid in ipairs(ctx.producers[itemID] or {}) do
    local r = ctx.data.recipes[rid]
    local total = 0
    for _, rq in ipairs(r.r) do
      local c = Acquire(ctx, rq[1], rq[2], 1, {}, {}, {}, "all")
      if not c then total = nil break end
      total = total + c
    end
    if total then
      total = total / r.out[2]
      if not best or total < best then best, bestRecipe = total, r end
    end
  end
  return best, bestRecipe
end

-- Coste de los materiales de `crafts` fabricaciones; devuelve también el
-- desglose por material, lo comprado en la AH y las acciones
local function RecipeCost(ctx, recipe, crafts, why)
  local extra, actions, total, reagents = {}, {}, 0, {}
  for _, rq in ipairs(recipe.r) do
    local first = #actions + 1
    local cost = Acquire(ctx, rq[1], rq[2] * crafts, 0, extra, actions, why)
    if not cost then return nil end
    total = total + cost
    -- De dónde sale este material (puede ser una mezcla: inventario + AH...)
    local kinds = {}
    for i = first, #actions do
      if actions[i].item == rq[1] then kinds[actions[i].kind] = true end
    end
    reagents[#reagents + 1] = { item = rq[1], qty = rq[2] * crafts, cost = cost, kinds = kinds }
  end
  return total, reagents, extra, actions
end

Planner.RecipeCost = RecipeCost -- coste de N fabricaciones subiendo por la escalera (Earn.lua)

-- Cómo se puede vender lo que fabrica una receta (precios por unidad).
-- No se puede saber cuánto se vende en la AH (el juego no lo dice), así que el
-- plan valora lo fabricado a precio de vendedor, que es seguro. La AH queda
-- como opción: lo que te quedaría igualando a la más barata (menos comisión y
-- depósito), con las alertas de mercado para juzgar si se venderá.
function Planner.SaleInfo(ctx, recipe)
  if not recipe.out then return nil end
  local itemID = recipe.out[1]
  local vendor = ES:VendorSellPrice(itemID)
  -- El juego aún no ha cargado el objeto (precio de los datos, quizá antiguo): al
  -- llegar se recalcula la ruta con el precio de ahora
  -- (cuáles: la página recalcula solo cuando llega uno de estos, no con cualquier objeto)
  if not vendor or (ES.SellPriceIsLive and not ES:SellPriceIsLive(itemID)) then
    ctx.pendingInfo = true
    ctx.pendingItems = ctx.pendingItems or {}
    ctx.pendingItems[itemID] = true
  end
  local sale = { itemID = itemID, qty = recipe.out[2], vendor = vendor or 0 }
  local ah = ctx.prices[itemID]
  sale.ahMin = ah and ah.minUnit
  sale.risk = ES:PriceRisk(itemID, ah)
  sale.deposit, sale.cut = Planner.AuctionCosts(sale.vendor, ctx.opts)
  sale.duration = ctx.opts.hours or 24 -- duración de la subasta (h)
  -- Precio realista (si el mínimo de ahora está inflado frente al histórico, el de referencia)
  -- Lo que se liga al recogerlo no se puede vender en la AH: solo al vendedor
  sale.fair = not recipe.bop and ES.Market:FairPrice(itemID, sale.ahMin) or nil
  if sale.fair then
    sale.ahPrice = sale.fair.price
    local net = sale.ahPrice * (1 - sale.cut) - sale.deposit
    if net > sale.vendor then sale.ahNet = net end
  end
  return sale
end

-- Qué hacer con lo que sobra de un objeto fabricado (d = plan.destinations[i]).
-- Solo merece la pena la AH si deja bastante más que el vendedor; cuánto anunciar
-- depende de las alertas de mercado:
--   good    -> anúncialos todos
--   watch / unknown -> unos pocos (AH_FEW) y el resto al vendedor
--   avoid   -> al vendedor
-- Devuelve { kind = "keep" | "vendor" | "ah" | "none", ah = n, vendor = n, price, verdict }
local AH_MIN_GAIN, AH_MIN_GAIN_PCT, AH_FEW = 5, 0.15, 5
function Planner.SaleAdvice(d)
  local sale = d.sale
  local a = { ah = 0, vendor = 0, unsold = 0 }
  if d.sell <= 0 then a.kind = "keep" return a end
  local worth = sale.ahNet and sale.ahNet - sale.vendor >= math.max(AH_MIN_GAIN, sale.vendor * AH_MIN_GAIN_PCT)
  if worth then
    local s = ES.Market:Signals(sale.itemID)
    a.verdict = s.verdict
    if s.verdict == "good" then
      a.ah = d.sell
    elseif s.verdict ~= "avoid" then
      a.ah = math.min(d.sell, AH_FEW)
    end
    -- Precio: 1 cobre por debajo de la más barata, o el realista si está inflada
    a.price = ES.Market.ListPrice(sale.fair) or 1
    a.inflated = sale.fair and sale.fair.inflated
  end
  a.vendor = sale.vendor > 0 and d.sell - a.ah or 0
  a.unsold = d.sell - a.ah - a.vendor -- ni AH ni vendedor
  if a.ah > 0 then
    a.kind = "ah"
  elseif sale.vendor > 0 then
    a.kind = "vendor"
  else
    a.kind = "none" -- ni la AH compensa ni lo compra el vendedor
  end
  return a
end

-- Valor de fabricar `crafts` veces: a precio de vendedor (ver SaleInfo)
local function SaleValue(sale, crafts)
  if not sale then return 0 end
  return crafts * sale.qty * sale.vendor
end

---------------------------------------------------------------------------
-- GPS: la ruta más corta de nivel en nivel (Planner.PlanGPS)
---------------------------------------------------------------------------
-- Subir una profesión es como buscar el camino más corto: los niveles son las
-- ciudades y cada receta, una carretera que cuesta en cada punto sus fabricaciones
-- esperadas (materiales menos lo que sacas vendiéndolo). Empezar a usar una receta
-- paga su instructor o pergamino y GPS_STEP_COST (pocos pasos; volver a una ya
-- usada lo paga otra vez: sin zigzag). Programación dinámica: para cada nivel y
-- receta, la ruta más barata que llega ahí usándola. Mira la ruta entera.
-- El camino se calcula con precios por unidad; la escalera de la AH, lo fabricado
-- que se reutiliza y tus bolsas solo se ven al recorrer la ruta de verdad (la
-- pasada forzada de Plan, rápida). Así que PlanGPS propone caminos, los recorre,
-- y repite con los precios que pagaría la mejor (linealizar), quitando cada una de
-- sus recetas y cambiando fabricar ↔ comprar. Gana la de menor Planner.RouteScore.
Planner.USE_GPS = true         -- el planificador del addon (false: el antiguo, solo para tools/route_qa.py)
local GPS_STEP_COST = 100      -- cobre por cada receta nueva en la ruta (pocos pasos)
local GPS_ROUNDS = 4           -- vueltas con los precios de la mejor ruta hasta ahora
local GPS_VIA_ROUNDS = 2       -- vueltas de fabricar ↔ comprar sobre cada ruta recorrida
local GPS_BAGS_ALTS = 4        -- recetas con lo tuyo que se prueban en su tramo
local GPS_TUNE_MOVES = 40      -- ajustes finos de fronteras que se aceptan como mucho
local GPS_TUNE_WALKS = 500     -- recorridos del ajuste fino como mucho
local GPS_SEGMENT_ROUNDS = 3   -- vueltas repensando cada tramo con el GPS
local GPS_SUB_ROUNDS = 8       -- cambios de receta de un paso que se aceptan como mucho
local GPS_SUB_CANDIDATES = 5   -- recetas que se prueban en lugar de cada paso
local GPS_TOP = 4              -- mejores rutas vistas que se repasan al final
local GPS_NEAR_PCT = 0.05      -- fabricar ↔ comprar solo en rutas a menos de un 5%
local GPS_NEAR_MIN = 500       -- (o 5s) de la mejor

-- Puntuación de una ruta entera, la vara con la que se comparan (PlanGPS y
-- tools/route_qa.py): lo que cuesta, más CRAFT_COST por fabricación (pasos e
-- intermedios: no 2000 materiales por unas monedas) y GPS_STEP_COST por paso. Lo
-- que ganas vendiendo un paso que da dinero cuenta como si hicieras una
-- fabricación por punto: si no, gana una receta casi gris solo por fabricar mucho
-- para el vendedor (96 Phoenix Bindings con un patrón de 75g). Lo que usas de tus
-- bolsas cuenta por lo que te darían vendiéndolo, con un margen de BAGS_TIE_PCT a
-- favor de usarlo (como Planner.BagsWorth): no se gastan 34 Medium Hide de 15g
-- para ahorrar 1g
-- Peso de cada fabricación: CRAFT_COST, o el de opts.craftWeight (icono "Menos
-- fabricaciones": la ruta paga más a cambio de fabricar menos veces)
Planner.FEWER_CRAFTS_WEIGHT = 100 -- 1s por fabricación con el icono activado
local function CraftWeight(opts)
  return opts and opts.craftWeight or CRAFT_COST
end
Planner.CraftWeight = CraftWeight

function Planner.RouteScore(plan)
  local CW = CraftWeight(plan.ctx and plan.ctx.opts)
  local score, crafts = plan.fees + (plan.toolsCost or 0), 0
  for _, st in ipairs(plan.steps) do
    local gain = st.crafts * (st.unitValue - st.unitCost)
    -- (entero hasta PROFIT_FULL_CRAFTS fabricaciones por punto; más allá, rebajado: casi gris)
    local per = st.crafts / math.max(1, st.to - st.from)
    if gain > 0 and per > PROFIT_FULL_CRAFTS then gain = gain * PROFIT_FULL_CRAFTS / per end
    score = score - gain
    crafts = crafts + st.crafts
  end
  for _, c in ipairs(plan.crafted or {}) do crafts = crafts + c.quantity end
  score = score + CW * crafts + GPS_STEP_COST * math.max(0, #plan.steps - 1)
  local have = plan.ctx and plan.ctx.opts.owned
  if have and plan.owned then
    for _, o in ipairs(plan.owned) do
      score = score + (1 - BAGS_TIE_PCT) * Planner.OwnedCost(plan.ctx, o.itemID, have[o.itemID] or o.quantity, o.quantity)
    end
  end
  return score
end

-- Devuelve { [nivel] = receta } con la ruta más barata, o nil. weight: coste
-- simbólico por fabricación; skip: recetas que no se pueden usar; fixed:
-- { [nivel] = receta } que van sí o sí (una receta con lo tuyo en su tramo)
-- Lo que cuesta un punto de una receta en un nivel (sin el peso por fabricación):
-- { neto, fabricaciones } o false. Se guarda en el contexto: las variantes del
-- camino (sin tal receta, con tal tramo fijo) reutilizan los mismos costes
-- Puntos que dan de media los materiales que se fabrican para un punto (Rough
-- Blasting Powder para la Rough Dynamite, Light Leather de chatarras...): son recetas
-- normales y, si aún no están en gris, suben la profesión (Discord: 63 de dinamita
-- pedían 63 de pólvora, que ya llevaban a 51). Las marcadas "intermediate" (Cured
-- Thick Hide) y las conversiones no dan puntos
local function CraftBonus(ctx, actions, s)
  local g = 0
  for _, a in ipairs(actions or {}) do
    local ir = a.kind == "craft" and a.recipe and ctx.data.recipes[a.recipe]
    if ir and not ir.intermediate and not ir.conversion and ir.t and (ir.t[1] or 1) <= s then
      g = g + a.qty / ((ir.out and ir.out[2]) or 1) * Planner.Chance(ir.t, s)
    end
  end
  return g
end
Planner.CraftBonus = CraftBonus

local function PointCost(ctx, rc, s)
  local row = ctx.gpsCost[rc.id]
  if not row then row = {} ctx.gpsCost[rc.id] = row end
  local v = row[s]
  if v == nil then
    v = false
    local chance = Planner.Chance(rc.r.t, s)
    if chance > 0 then
      local crafts = 1 / chance
      ctx.skill = s -- (como en Plan: lo que da puntos a este nivel no se fabrica como preparación)
      local cost, _, _, actions = RecipeCost(ctx, rc.r, crafts, {})
      ctx.skill = nil
      if cost then
        -- Puntos de los materiales que se fabrican por el camino: con ellos, cada
        -- punto de la ruta cuesta 1/(1 + g) de lo que costaría sin ellos
        local g = CraftBonus(ctx, actions, s)
        -- Lo fabricado que la ruta necesita después (Light Leather, Handful of
        -- Copper Bolts) vale lo que costaría conseguirlo, no lo del vendedor
        -- (ctx.needValue, ver PlanGPS). Como al elegir punto a punto (ver Plan):
        -- el beneficio no crece con las fabricaciones de una receta casi gris
        local value = SaleValue(rc.sale, crafts)
        local need = rc.sale and ctx.needValue and ctx.needValue[rc.sale.itemID]
        if need then value = math.max(value, crafts * rc.sale.qty * need) end
        local net = cost - value
        if net < 0 and crafts > PROFIT_FULL_CRAFTS then
          net = net * PROFIT_FULL_CRAFTS / crafts + CRAFT_COST * (crafts - PROFIT_FULL_CRAFTS)
        end
        v = { net / (1 + g), crafts / (1 + g) }
      end
    end
    row[s] = v
  end
  return v
end

-- Recetas candidatas del GPS con este contexto (las mismas para todas sus variantes)
local function GPSRecipes(data, opts, ctx)
  if not ctx.gpsRecipes then
    local list = {}
    for id, r in pairs(data.recipes) do
      local learn = Planner.LearnSkill(r, opts)
      if learn and learn < opts.to and r.t[4] > opts.from and not (opts.excluded and opts.excluded[id]) then
        -- Empezarla paga el instructor y, si pide una herramienta que no tienes
        -- (Arclight Spanner para Crude Scope), la herramienta. Sin precio: no vale
        local fee = Planner.LearnCost(ctx, r)
        local tool = r.tool and ES.Data.Tools and ES.Data.Tools[r.tool]
        if tool and (ctx.toolMask[tool.family or "rod"] or 0) < tool.mask then
          local cost = Acquire(ctx, tool.item, 1, 0, {}, {}, {})
          fee = cost and fee + cost or nil
        end
        if fee then
          list[#list + 1] = { id = id, r = r, learn = learn, fee = fee, sale = Planner.SaleInfo(ctx, r) }
        end
      end
    end
    table.sort(list, function(a, b) return a.id < b.id end) -- mismo orden siempre: misma ruta
    ctx.gpsRecipes, ctx.gpsCost = list, {}
  end
  return ctx.gpsRecipes
end

local function ShortestRoute(data, opts, ctx, weight, skip, fixed, paid)
  local recipes = GPSRecipes(data, opts, ctx)
  local INF = math.huge
  local prev = {}
  for i = 1, #recipes do prev[i] = INF end
  local bestAll, bestIdx = 0, nil -- al empezar: nada pagado, ninguna receta
  local back, last = {}, nil
  for s = opts.from, opts.to - 1 do
    local cur, b = {}, {}
    local newBest, newIdx = INF, nil
    for i, rc in ipairs(recipes) do
      ES.Yield()
      local c = INF
      local allowed = not skip[rc.id] and (not (fixed and fixed[s]) or fixed[s] == rc.id)
      if allowed and rc.learn <= s and (prev[i] < INF or bestIdx or s == opts.from) then
        local pc = PointCost(ctx, rc, s)
        if pc then
          local point = pc[1] + weight * pc[2]
          -- (paid: recetas que la ruta ya aprende en otro tramo: no se pagan otra vez)
          local switch = bestAll + (paid and paid[rc.id] and 0 or rc.fee) + GPS_STEP_COST
          if prev[i] <= switch then
            c, b[i] = prev[i] + point, i
          else
            c, b[i] = switch + point, bestIdx
          end
        end
      end
      cur[i] = c
      if c < newBest then newBest, newIdx = c, i end
    end
    if not newIdx then break end -- ninguna receta sigue: la ruta llega hasta aquí
    back[s], last = b, s
    prev, bestAll, bestIdx = cur, newBest, newIdx
  end
  if not last then return nil end
  local choice, i = {}, bestIdx
  for s = last, opts.from, -1 do
    if not i then break end
    choice[s] = recipes[i].id
    i = back[s][i]
  end
  return choice
end
Planner.ShortestRoute, Planner.NewContext = ShortestRoute, NewContext -- (para pruebas)

-- Clave de una ruta (para no recorrer dos veces la misma)
local function ChoiceKey(opts, choice, via)
  local keys = {}
  for s = opts.from, opts.to - 1 do keys[#keys + 1] = tostring(choice[s]) end
  local v = {}
  for itemID, way in pairs(via or {}) do v[#v + 1] = itemID .. way end
  table.sort(v)
  return table.concat(keys, ",") .. "|" .. table.concat(v, ",")
end

-- Lo que el GPS decidió fabricar o comprar al calcular un camino (cada material,
-- lo más barato en ese momento): para recorrerlo igual. Si no, se recorre con lo
-- que decida la pasada forzada y una ruta buena puede parecer mala (Deadly
-- Blunderbuss comprando los Handful of Copper Bolts en vez de fabricarlos)
local function RouteVia(data, opts, ctx, choice)
  -- Fabricaciones de cada receta en todo el camino: con poca cantidad comprar
  -- suele salir más barato, y lo que cuenta es lo que pide el tramo entero
  local crafts, order = {}, {}
  for s = opts.from, opts.to - 1 do
    local id = choice[s]
    local chance = id and Planner.Chance(data.recipes[id].t, s) or 0
    if chance > 0 then
      if not crafts[id] then order[#order + 1] = id end
      crafts[id] = (crafts[id] or 0) + 1 / chance
    end
  end
  local via = {}
  for _, id in ipairs(order) do
    local _, _, _, actions = RecipeCost(ctx, data.recipes[id], crafts[id], {})
    for _, a in ipairs(actions or {}) do
      if ctx.producers[a.item] and not via[a.item] then
        if a.kind == "craft" then via[a.item] = "craft"
        elseif a.kind == "ah" or a.kind == "vendor" then via[a.item] = "buy" end
      end
    end
  end
  for itemID, way in pairs(ctx.opts.via or {}) do via[itemID] = way end
  return via
end

-- Lo que vale fabricar al subir un material que la ruta `best` necesita (lo compra
-- o lo fabrica aparte): lo que costaría conseguirlo, lo más barato de comprarlo o
-- fabricarlo. Para el GPS (ver PointCost): subir con Light Leather no "regala" el
-- cuero al vendedor, ahorra comprarlo para los pasos de después
local function NeedValue(ctx, best)
  local v = {}
  local function Add(itemID, paid)
    if not ctx.producers[itemID] or v[itemID] then return end
    local ladder = ctx.ladders[itemID]
    local buy = paid or ES.Data.VendorPrices[itemID] or (ladder and ladder[1])
    local craft = Planner.CraftUnitCost(ctx, itemID)
    v[itemID] = (buy and craft) and math.min(buy, craft) or buy or craft
  end
  for _, it in ipairs(best.shopping or {}) do Add(it.itemID, it.unit) end
  for _, c in ipairs(best.crafted or {}) do Add(c.itemID) end
  return v
end

-- Precios con tus bolsas para el GPS: lo tuyo, al precio de la puntuación (lo que
-- te darían vendiéndolo, con el margen a favor de usarlo): ni gratis ni infinito
local function OwnedContext(data, opts, via)
  local w = Copy(opts)
  w.via = via
  local ctx = NewContext(data, w)
  ctx.ownedPrice = {}
  for itemID, q in pairs(ctx.owned) do
    ctx.ownedPrice[itemID] = (1 - BAGS_TIE_PCT) * Planner.OwnedValue(ctx, itemID, q) / q
  end
  return ctx
end

function Planner.PlanGPS(data, opts)
  -- Lo que no cambia en todo el cálculo (escaleras de precios, quién fabrica qué),
  -- preparado una vez para los cientos de recorridos (ver NewContext)
  opts = Copy(opts)
  local CW = CraftWeight(opts)
  local tpl = NewContext(data, opts)
  opts.shared = { prices = tpl.prices, to = opts.to, ladders = tpl.ladders, supply = tpl.supply,
    medians = tpl.medians, producers = tpl.producers }
  local Score = Planner.RouteScore
  local best, seen, pool = nil, {}, {}
  local function Better(p)
    return not best or p.reached > best.reached or (p.reached == best.reached and Score(p) < Score(best) - EPS)
  end
  -- Recorre una ruta de verdad (pasada forzada, rápida). via: fabricar o comprar
  -- fijado (lo del jugador siempre manda)
  local function Walk(choice, via)
    local v = Copy(via or {})
    for itemID, way in pairs(opts.via or {}) do v[itemID] = way end
    local key = ChoiceKey(opts, choice, v)
    if seen[key] then return nil end
    seen[key] = true
    local t = Copy(opts)
    t.forced, t.via = choice, v
    local p = Planner:Plan(data, t)
    -- Las mejores rutas vistas (la mejor recorrida de cada una), para repasarlas al final
    local rk = ChoiceKey(opts, p.choice)
    local q = pool[rk]
    if not q or p.reached > q.reached or (p.reached == q.reached and Score(p) < Score(q)) then pool[rk] = p end
    return p
  end
  -- Cambiar cada material (fabricar ↔ comprar) mientras mejore
  local function ViaPolish(p)
    for _ = 1, GPS_VIA_ROUNDS do
      local improved = false
      local items = {}
      for itemID in pairs(p.ctx and p.ctx.via or {}) do
        if not (opts.via and opts.via[itemID]) then items[#items + 1] = itemID end
      end
      table.sort(items)
      for _, itemID in ipairs(items) do
        local v = Copy(p.ctx.via)
        v[itemID] = v[itemID] == "craft" and "buy" or "craft"
        local q = Walk(p.choice, v)
        if q and (q.reached > p.reached or (q.reached == p.reached and Score(q) < Score(p) - EPS)) then
          p, improved = q, true
        end
      end
      if not improved then break end
    end
    return p
  end
  -- Recorrida y, si está cerca de la mejor, con fabricar ↔ comprar (en una ruta que
  -- sale mucho más cara no la salva, y es lo que más recorridos cuesta)
  local function Try(choice, via)
    local p = Walk(choice, via)
    if not p then return false end
    local near = not best or p.reached > best.reached
      or Score(p) <= Score(best) + GPS_NEAR_PCT * math.abs(Score(best)) + GPS_NEAR_MIN
    if near then p = ViaPolish(p) end
    if Better(p) then best = p return true end
    return false
  end
  -- Un camino del GPS: recorrido con lo que el GPS decidió fabricar o comprar, con
  -- lo de su contexto y (extra) con otro; gana el mejor
  local function TryDP(choice, ctx, extra)
    local a = Try(choice, RouteVia(data, opts, ctx, choice))
    local b = Try(choice, ctx.opts.via)
    local c = extra and Try(choice, extra)
    return a or b or c or false
  end
  -- Puntos de partida: la ruta voraz de una sola pasada (sin restricciones) y,
  -- con bolsas, la voraz del mercado (sin ellas) recorrida con lo tuyo
  Try({}, nil)
  -- La ruta que ya tenías (opts.hint, la última calculada de esta profesión): si
  -- cambian tus bolsas (conviertes chatarras en cuero), sigue siendo la misma salvo
  -- que de verdad haya otra mejor. Sin esto la ruta podía saltar a otra solo porque
  -- la búsqueda tomó otro camino
  if opts.hint and opts.hint.choice then Try(opts.hint.choice, opts.hint.via) end
  do -- (y la voraz con peso por fabricación: de ella sale a menudo la de siempre)
    local t = Copy(opts)
    t.forced, t.craftCost = {}, CW
    Try(Planner:Plan(data, t).choice, nil)
  end
  local owned = opts.owned and next(opts.owned)
  local marketGreedy
  if owned then
    local t = Copy(opts)
    t.owned, t.forced = nil, {}
    marketGreedy = Planner:Plan(data, t)
    Try(marketGreedy.choice, nil)
  end
  for round = 1, GPS_ROUNDS do
    local improved = false
    -- Contextos de precios: los del mercado (primera unidad) la primera vez; luego
    -- los que pagaría la mejor ruta (la mitad de lo que compra ya "comprada") y con
    -- lo que ella decidió fabricar o comprar. Con tus bolsas, también contándolas
    local ctxs = {}
    local m = Copy(opts)
    m.owned = nil
    if best and round > 1 then m.via = Copy(best.ctx.via) end
    ctxs[1] = NewContext(data, m)
    if owned then
      -- Lo tuyo, al precio de la puntuación (ver OwnedContext). A partir de la
      -- segunda vuelta, menos la mitad de lo que ya usa la mejor ruta
      local ctx = OwnedContext(data, opts, m.via)
      if best and round > 1 then
        for _, o in ipairs(best.owned or {}) do
          if ctx.owned[o.itemID] then ctx.owned[o.itemID] = math.max(0, ctx.owned[o.itemID] - o.quantity / 2) end
        end
      end
      ctxs[2] = ctx
    end
    if best and round > 1 then
      -- Lo fabricado que la ruta necesita, valorado a lo que costaría (NeedValue)
      -- y también sin eso, al precio del vendedor: cada vara ve bien unas rutas
      -- (subir con Light Leather o con Light Armor Kit) y mal otras
      local plain = NewContext(data, m)
      for _, ctx in ipairs(ctxs) do ctx.needValue = NeedValue(ctx, best) end
      ctxs[#ctxs + 1] = plain
      for _, ctx in ipairs(ctxs) do
        for itemID, q in pairs(best.ctx.used or {}) do ctx.used[itemID] = q / 2 end
      end
    end
    -- Caminos: el más corto, y sin cada receta de la mejor ruta hasta ahora
    local skips = { {} }
    for _, st in ipairs(best and best.steps or {}) do skips[#skips + 1] = { [st.id] = true } end
    for _, ctx in ipairs(ctxs) do
      for i, skip in ipairs(skips) do
        for _, weight in ipairs(i == 1 and { CW, 0 } or { CW }) do
          local choice = ShortestRoute(data, opts, ctx, weight, skip)
          if choice and TryDP(choice, ctx) then improved = true end
        end
      end
    end
    -- Y fabricando lo que la mejor ruta compra si su receta sube puntos (la pólvora de
    -- la dinamita): entonces el camino lleva esa receta como paso propio (lo que da
    -- puntos no se fabrica como preparación, ver Acquire). Sin esto el GPS no veía
    -- "Rough Blasting Powder 1-33 y luego dinamita", que el planificador antiguo sí
    if best then
      local flip = Copy(best.ctx.via or {})
      local any = false
      for itemID, way in pairs(best.ctx.via or {}) do
        if way == "buy" then
          for _, rid in ipairs(tpl.producers[itemID] or {}) do
            local r = data.recipes[rid]
            if r and not r.intermediate and not r.conversion then flip[itemID], any = "craft", true end
          end
        end
      end
      if any then
        local f = Copy(m)
        f.via = flip
        -- (sin tus bolsas y, si las usas, con ellas: la pólvora de tus Rough Stone)
        local fctxs = { NewContext(data, f) }
        if owned then fctxs[2] = OwnedContext(data, opts, flip) end
        for _, ctx in ipairs(fctxs) do
          for _, weight in ipairs({ CW, 0 }) do
            local choice = ShortestRoute(data, opts, ctx, weight, {})
            if choice and TryDP(choice, ctx, flip) then improved = true end
          end
        end
      end
    end
    if not improved and round > 1 then break end
  end
  if not best then return Planner:Plan(data, (function() local t = Copy(opts) t.forced = {} return t end)()) end

  -- Fases de pulido sobre la mejor ruta
  local function Polish()
    -- Recetas que puedes hacer con lo tuyo (como el aviso "Con lo que llevas"): el
    -- camino que la usa en su tramo. El GPS solo no las ve si lo que fabricas se
    -- reutiliza luego (Cured Medium Hide con tus Medium Hide, para Hillman's Shoulders)
    if owned then
      local m = Copy(opts)
      m.owned = nil
      local ctxs = { NewContext(data, m), OwnedContext(data, opts), OwnedContext(data, opts) }
      -- (y lo tuyo descontando la mitad de lo que ya gasta la mejor ruta: con 50
      -- Light Leather, Light Leather Pants parece gratis hasta que se acaba)
      for _, o in ipairs(best.owned or {}) do
        local have = ctxs[3].owned[o.itemID]
        if have then ctxs[3].owned[o.itemID] = math.max(0, have - o.quantity / 2) end
      end
      for itemID, q in pairs(best.ctx.used or {}) do ctxs[3].used[itemID] = q / 2 end
      -- Frente a la mejor ruta (con lo que ella no gasta) y frente a la del mercado
      -- (con todo lo tuyo): sin repetir receta
      local alts, tried = {}, {}
      for _, base in ipairs({ best, marketGreedy }) do
        local ex = Copy(opts.excluded or {})
        for _ = 1, GPS_BAGS_ALTS do
          local alt = Planner.BagsAlternative(data, base, opts.owned, opts.from, ex, false)
          if not alt then break end
          ex[alt.id] = true
          if not tried[alt.id .. ":" .. alt.to] then
            tried[alt.id .. ":" .. alt.to] = true
            alts[#alts + 1] = alt
          end
        end
      end
      for _, alt in ipairs(alts) do
        -- Su tramo, y hasta donde se podría usar (lo tuyo da para más si la ruta
        -- no lo gasta en otra cosa)
        local spans, last = {}, math.max(alt.to, math.min(opts.to, alt.recipe.t[3]))
      for _, f in ipairs({ 0.5, 0.75, 1 }) do spans[#spans + 1] = math.max(alt.from + 1, math.floor(alt.from + f * (alt.to - alt.from) + 0.5)) end
      if last > alt.to then spans[#spans + 1] = last end
      for _, span in ipairs(spans) do
          local fixed = {}
          for s = alt.from, span - 1 do fixed[s] = alt.id end
          for _, ctx in ipairs(ctxs) do
            local choice = ShortestRoute(data, opts, ctx, CW, {}, fixed)
            if choice then TryDP(choice, ctx) end
          end
        end
      end
    end

    -- Repensar cada tramo (un paso, o dos seguidos) con el GPS dejando el resto de la
    -- ruta como está, con los precios que paga la mejor ruta: mete una receta en
    -- medio de un paso largo (Deadly Blunderbuss dentro de Flying Tiger Goggles)
    for _ = 1, GPS_SEGMENT_ROUNDS do
      local improved = false
      local m = Copy(opts)
      m.owned, m.via = nil, Copy(best.ctx.via)
      local ctxs = { NewContext(data, m) }
      if owned then ctxs[2] = OwnedContext(data, opts, m.via) end
      for _, ctx in ipairs(ctxs) do
        for itemID, q in pairs(best.ctx.used or {}) do ctx.used[itemID] = q / 2 end
        ctx.needValue = NeedValue(ctx, best)
      end
      local steps, windows = best.steps, {}
      for i, st in ipairs(steps) do
        windows[#windows + 1] = { st.from, st.to }
        if steps[i + 1] then windows[#windows + 1] = { st.from, steps[i + 1].to } end
        -- Y el principio o el final de un paso largo (cuando la receta ya sube peor:
        -- Bronze Framework en los últimos niveles de Flying Tiger Goggles)
        for _, k in ipairs({ 5, 10 }) do
          if st.to - st.from > k then
            windows[#windows + 1] = { st.to - k, st.to }
            windows[#windows + 1] = { st.from, st.from + k }
          end
        end
      end
      for _, w in ipairs(windows) do
        local fixed, paid = {}, {}
        for s = opts.from, opts.to - 1 do
          if (s < w[1] or s >= w[2]) and best.choice[s] then
            fixed[s] = best.choice[s]
            paid[best.choice[s]] = true
          end
        end
        for _, ctx in ipairs(ctxs) do
          local choice = ShortestRoute(data, opts, ctx, CW, {}, fixed, paid)
          if choice and TryDP(choice, ctx, best.ctx.via) then improved = true end
        end
      end
      if not improved then break end
    end

    -- Cambiar la receta de un paso por otra en el mismo tramo (Raptor Hide Harness por
    -- Raptor Hide Belt, Rough Weightstone por Rough Sharpening Stone): las
    -- GPS_SUB_CANDIDATES que mejor lo cubren según el GPS, recorridas de verdad
    for _ = 1, GPS_SUB_ROUNDS do
      local improved = false
      local m = Copy(opts)
      m.owned, m.via = nil, Copy(best.ctx.via)
      local ctxs = { NewContext(data, m), NewContext(data, m) }
      ctxs[1].needValue = NeedValue(ctxs[1], best)
      for _, ctx in ipairs(ctxs) do
        for itemID, q in pairs(best.ctx.used or {}) do ctx.used[itemID] = q / 2 end
      end
      local paid = {}
      for _, st in ipairs(best.steps) do paid[st.id] = true end
      for _, st in ipairs(best.steps) do
        local tried = {}
        for _, ctx in ipairs(ctxs) do
          local cands = {}
          for _, rc in ipairs(GPSRecipes(data, opts, ctx)) do
            -- (desde que se aprende, si es a mitad del paso)
            local from = math.max(st.from, rc.learn)
            if rc.id ~= st.id and not tried[rc.id] and from < st.to then
              local sum = paid[rc.id] and 0 or rc.fee
              for s = from, st.to - 1 do
                local pc = PointCost(ctx, rc, s)
                if not pc then sum = nil break end
                sum = sum + pc[1] + CW * pc[2]
              end
              -- (por punto: los tramos cortos no salen baratos solo por ser cortos)
              if sum then cands[#cands + 1] = { id = rc.id, from = from, cost = sum / (st.to - from) } end
            end
          end
          table.sort(cands, function(a, b) return a.cost < b.cost or (a.cost == b.cost and a.id < b.id) end)
          for k = 1, math.min(GPS_SUB_CANDIDATES, #cands) do
            tried[cands[k].id] = true
            local choice = Copy(best.choice)
            for s = cands[k].from, st.to - 1 do choice[s] = cands[k].id end
            local p = Walk(choice, best.ctx.via)
            if p and Better(p) then best, improved = p, true break end
          end
          if improved then break end
        end
        if improved then break end
      end
      if not improved then break end
    end

    -- Ajuste fino, recorriendo de verdad: mover cada frontera entre pasos unos
    -- niveles, o quitar un paso dándoselo a la receta de antes o a la de después
    local tuneWalks = 0
    for _ = 1, GPS_TUNE_MOVES do
      local improved = false
      local steps = best.steps
      for i = 1, #steps do
        local st, prevSt, nextSt = steps[i], steps[i - 1], steps[i + 1]
        local moves = {}
        if nextSt then
          for _, d in ipairs({ -3, -1, 1, 3 }) do
            local cut = nextSt.from + d
            if cut > st.from and cut < nextSt.to then moves[#moves + 1] = { cut = cut, a = st, b = nextSt } end
          end
        end
        if prevSt then moves[#moves + 1] = { whole = st, to = prevSt.id } end
        if nextSt then moves[#moves + 1] = { whole = st, to = nextSt.id } end
        -- Los últimos niveles del paso, con una receta ya aprendida antes (no se
        -- vuelve a pagar: Flying Tiger Goggles al final de Deadly Blunderbuss)
        local earlier = {}
        for j = math.max(1, i - 3), i - 1 do
          if not earlier[steps[j].id] and steps[j].id ~= st.id then
            earlier[steps[j].id] = true
            for _, k in ipairs({ 2, 4, 8 }) do
              if st.to - st.from > k then moves[#moves + 1] = { tail = st, k = k, to = steps[j].id } end
            end
          end
        end
        for _, mv in ipairs(moves) do
          local choice = Copy(best.choice)
          if mv.whole then
            for s = mv.whole.from, mv.whole.to - 1 do choice[s] = mv.to end
          elseif mv.tail then
            for s = mv.tail.to - mv.k, mv.tail.to - 1 do choice[s] = mv.to end
          elseif mv.cut < mv.b.from then
            for s = mv.cut, mv.b.from - 1 do choice[s] = mv.b.id end
          else
            for s = mv.b.from, mv.cut - 1 do choice[s] = mv.a.id end
          end
          local p = Walk(choice, best.ctx.via)
          if p then tuneWalks = tuneWalks + 1 end
          if p and Better(p) then
            best, improved = p, true
            break
          end
          if tuneWalks >= GPS_TUNE_WALKS then break end
        end
        if improved or tuneWalks >= GPS_TUNE_WALKS then break end
      end
      if not improved then break end
    end
  end
  Polish()

  -- Al final, las mejores rutas vistas, con fabricar ↔ comprar sin poda: una ruta
  -- buena recorrida con una mala decisión pudo quedar por detrás de otra peor
  local top = {}
  for _, p in pairs(pool) do top[#top + 1] = p end
  -- (primero las que llegan más lejos: una que se para antes sale barata por subir menos)
  table.sort(top, function(a, b) return a.reached > b.reached or (a.reached == b.reached and Score(a) < Score(b)) end)
  local again = false
  for k = 1, math.min(GPS_TOP, #top) do
    local p = ViaPolish(top[k])
    if Better(p) then best, again = p, true end
  end
  if again then Polish() end

  -- Hacer tú un ingrediente que un paso compra, como paso propio al empezar ese paso,
  -- si su receta aún da puntos: la pólvora de la Rough Dynamite con tus Rough Stone
  -- (pólvora 3-25 y luego dinamita, 19s más barata). Los caminos del GPS no la veían:
  -- se prueba directamente, cortando donde la receta cambia de color
  local function IngredientFirst()
    local found = false
    for _, st in ipairs(best.steps) do
      local tried = {}
      for _, rg in ipairs(st.reagents or {}) do
        if rg.kinds and (rg.kinds.ah or rg.kinds.vendor) then
          for _, rid in ipairs(tpl.producers[rg.item] or {}) do
            local r = data.recipes[rid]
            local learn = r and Planner.LearnSkill(r, opts)
            if r and not tried[rid] and not r.intermediate and not r.conversion and learn and learn <= st.from
              and Planner.Chance(r.t, st.from) > 0 then
              tried[rid] = true
              local cuts = {}
              for _, c in ipairs({ r.t[2], r.t[3], math.floor((r.t[3] + r.t[4]) / 2), r.t[4] }) do
                local to = math.min(c, st.to)
                if to > st.from and not cuts[to] then
                  cuts[to] = true
                  local choice = Copy(best.choice)
                  for s = st.from, to - 1 do choice[s] = rid end
                  if Try(choice, best.ctx.via) then found = true end
                end
              end
            end
          end
        end
      end
    end
    return found
  end
  if IngredientFirst() then Polish() end

  -- La elegida, recorrida una vez con toda la información (las recetas que no se
  -- pudieron usar por falta de precio, para el tooltip de cada paso): mismo resultado
  local final = Copy(opts)
  final.forced, final.via, final.fullInfo = best.choice, best.ctx.via, true
  best = Planner:Plan(data, final)

  return best
end

---------------------------------------------------------------------------
-- Plan
---------------------------------------------------------------------------
-- opts = { from, to, includeScrolls, hours (duración subasta), neutral, reuseCrafted, ignoreSupply, cap,
--          owned = { [itemID] = cantidad en bolsas/banco }, via = { [itemID] = "craft" | "buy" } }
Planner.passes = 0 -- veces que se recorre una ruta (para la barra de progreso, ES:PlanProgress)
function Planner:Plan(data, opts)
  Planner.passes = Planner.passes + 1
  -- El planificador es el GPS (ver arriba). Lo de aquí abajo son las pasadas forzadas
  -- (ruta fijada, las que recorre el GPS) y el planificador antiguo, que solo se usa
  -- para compararlo en tools/route_qa.py (Planner.USE_GPS = false)
  if Planner.USE_GPS and not opts.forced then return Planner.PlanGPS(data, opts) end

  -- Materiales que se pueden fabricar (Light Leather de Ruined Leather Scraps): o se
  -- fabrican todos o se compran todos, nunca las dos cosas (ver Acquire). La primera
  -- vez decide con poca cantidad, así que se prueba la otra opción para todo el plan
  -- y se queda la más barata, contando INTERMEDIATE_CRAFT_COST por cada fabricación
  if not opts.forced and not opts.viaSearched then
    local o = Copy(opts)
    o.viaSearched = true
    local function Score(p)
      local n = 0
      for _, c in ipairs(p.crafted or {}) do n = n + c.quantity end
      return p.net + INTERMEDIATE_CRAFT_COST * n
    end
    local function Better(p, best)
      return p.reached > best.reached or (p.reached == best.reached and Score(p) < Score(best) - EPS)
    end
    local best = Planner:Plan(data, o)
    -- Cambiar un material cada vez (fabricar ↔ comprar), otra vuelta si alguno mejora.
    -- No solo los de la ruta actual: también los que salieron en otras rutas probadas
    -- (la ruta con Cured Medium Hide no usa Cured Light Hide, pero comprarlo hecho
    -- abre la de Black Whelp Cloak)
    local seen, tried = {}, {}
    local function See(p)
      for itemID in pairs(p.ctx and p.ctx.via or {}) do seen[itemID] = true end
    end
    See(best)
    -- Lo decidido sobre la marcha, fijado desde el principio: la ruta se elige ya
    -- sabiendo que Light Leather se fabrica. Con chatarras en las bolsas, la primera
    -- pasada lo decidía tarde, se quedaba con una ruta pensada para comprarlo y la
    -- ruta saltaba al ir convirtiéndolas (tener más cosas daba una ruta peor)
    if best.ctx and next(best.ctx.via) then
      local t = Copy(o)
      t.via = Copy(best.ctx.via)
      local p = Planner:Plan(data, t)
      if Better(p, best) then best = p end
      See(p)
    end
    for _ = 1, VIA_ROUNDS do
      local improved = false
      local items = {}
      for itemID in pairs(seen) do items[#items + 1] = itemID end
      table.sort(items) -- orden fijo: la misma ruta cada vez
      for _, itemID in ipairs(items) do
        local cur = best.ctx and best.ctx.via or {}
        -- Lo que el jugador fijó (✕ en "Fabrica 30× Light Leather": comprarlo) no se toca
        if not (opts.via and opts.via[itemID]) then
          for _, way in ipairs({ "craft", "buy" }) do
            local key = itemID .. way .. tostring(best)
            if cur[itemID] ~= way and not tried[key] then
              tried[key] = true
              local t = Copy(o)
              t.via = Copy(cur)
              t.via[itemID] = way
              local p = Planner:Plan(data, t)
              if Better(p, best) then best, improved = p, true end
              See(p)
              if improved then break end
            end
          end
        end
      end
      if not improved then break end
    end
    return best
  end

  -- Sin zigzag: donde la ruta alterna recetas en pasos de 1-2 puntos (Light Leather
  -- y Light Armor Kit, punto sí punto no), se prueba a hacer todo el tramo con una
  -- sola y se queda si apenas cuesta más (ver Smooth)
  if not opts.forced and not opts.smoothed then
    local o = {}
    for k, v in pairs(opts) do o[k] = v end
    o.smoothed = true
    return Planner.Smooth(data, o, Planner:Plan(data, o))
  end

  -- Con "usar bolsas y banco": la ruta se elige sin contar lo tuyo (ver abajo), así
  -- que una receta de pergamino puede ganar aunque la alternativa use materiales que
  -- ya llevas y salga más barata de verdad (Deviate Scale Cloak frente a Embossed
  -- Leather Gloves con cuero en las bolsas). Al acabar se prueba a quitar las
  -- recetas que hay que ir a buscar o comprar, de la más cara a la más barata, y se
  -- queda la ruta si sale más barata con su coste real (bolsas incluidas) y llega
  -- igual de lejos: se comparan rutas enteras, sin el zigzag de elegir punto a punto.
  -- Sin bolsas no se hace: la ruta ya es la del mercado y calcularla cuesta el doble.
  if not opts.forced and not opts.searched and opts.owned and next(opts.owned) then
    local o = {}
    for k, v in pairs(opts) do o[k] = v end
    o.searched = true
    local best = Planner:Plan(data, o)
    local candidates = {}
    for _, st in ipairs(best.steps) do
      if st.fee > 0 and SEARCH_SOURCES[st.learnSource] then candidates[#candidates + 1] = st end
    end
    table.sort(candidates, function(a, b) return a.fee > b.fee end)
    for i = 1, math.min(#candidates, MAX_SEARCH) do
      local t = {}
      for k, v in pairs(o) do t[k] = v end
      t.excluded = {}
      for id in pairs(o.excluded or {}) do t.excluded[id] = true end
      t.excluded[candidates[i].id] = true
      t.craftCost = best.craftCostUsed -- sin repetir la doble ruta (más barata / menos fabricaciones)
      local plan = Planner:Plan(data, t)
      if plan.reached >= best.reached and plan.net < best.net - SEARCH_MIN_SAVING then
        best, o = plan, t
      end
    end
    -- Receta que puedes hacer con lo tuyo y que te compensa más que vender lo tuyo
    -- y seguir la ruta (ver BagsAlternative): se mete en su tramo. Si no compensa,
    -- la ruta no la usa y la UI explica por qué. Varias pasadas: con lo que te
    -- queda puede salir otra
    for _ = 1, BAGS_PASSES do
      local alt = Planner.BagsAlternative(data, best, opts.owned, opts.from, o.excluded, true)
      if not alt or not Planner.BagsWorth(alt) then break end
      local t = {}
      for k, v in pairs(o) do t[k] = v end
      t.forced = {}
      for s, id in pairs(best.choice) do t.forced[s] = id end
      for s = alt.from, alt.to - 1 do t.forced[s] = alt.id end
      local plan = Planner:Plan(data, t)
      if plan.reached < best.reached then break end
      plan.cheapest, plan.craftCostUsed = best.cheapest, best.craftCostUsed
      best = plan
    end
    return best
  end

  -- Con lo de tus bolsas: la ruta se elige como si no lo tuvieras y luego se
  -- recorre usándolo. Si no, como lo tuyo sale gratis, el plan se desvía para
  -- gastarlo cuanto antes (2 fabricaciones de una receta y vuelta a la otra), y
  -- no ahorra nada: esos materiales se iban a usar igual más adelante.
  if opts.owned and next(opts.owned) and not opts.forced then
    local base, withBags = {}, {}
    for k, v in pairs(opts) do base[k], withBags[k] = v, v end
    base.owned = nil
    local route = Planner:Plan(data, base)
    withBags.forced = route.choice
    -- Y con lo mismo fabricado o comprado: la ruta se eligió comprando Light Leather;
    -- si al recorrerla con tus chatarras pasara a fabricarlo, el coste sería de otra
    -- ruta y la búsqueda de arriba (fabricar ↔ comprar) compararía cosas distintas
    withBags.via = Copy(route.ctx and route.ctx.via or {})
    for itemID, way in pairs(opts.via or {}) do withBags.via[itemID] = way end
    local plan = Planner:Plan(data, withBags)
    plan.cheapest, plan.craftCostUsed = route.cheapest, route.craftCostUsed
    return plan
  end

  -- Coste simbólico por fabricación: se buscan dos rutas, la más barata pura y
  -- otra en la que cada fabricación "cuesta" CRAFT_COST (no se cobra: solo pesa
  -- al elegir). La segunda solo se usa si apenas cuesta más (MAX_EXTRA_PCT de los
  -- materiales, mínimo MAX_EXTRA_MIN) y llega igual de lejos: el addon sigue
  -- dando la ruta más barata, pero sin cientos de fabricaciones por un ahorro mínimo.
  if not opts.forced and opts.craftCost == nil then
    local cheapOpts, balancedOpts = {}, {}
    for k, v in pairs(opts) do cheapOpts[k], balancedOpts[k] = v, v end
    cheapOpts.craftCost, balancedOpts.craftCost = 0, CRAFT_COST
    local cheap = Planner:Plan(data, cheapOpts)
    local balanced = Planner:Plan(data, balancedOpts)
    local allowed = math.max(MAX_EXTRA_MIN, MAX_EXTRA_PCT * cheap.reagentCost)
    local cheapCrafts, balancedCrafts = Planner.TotalCrafts(cheap), Planner.TotalCrafts(balanced)
    if balanced.reached >= cheap.reached and balanced.net <= cheap.net + allowed and balancedCrafts < cheapCrafts then
      balanced.cheapest = { net = cheap.net, crafts = cheapCrafts }
      balanced.craftCostUsed = CRAFT_COST
      return balanced
    end
    cheap.craftCostUsed = 0
    return cheap
  end

  -- Recetas de pago (pergamino, instructor): al elegirlas, su precio se reparte
  -- entre los puntos que quedan hasta que se ponen grises. Si luego la ruta solo
  -- la usa unos pocos (otra receta pasa a ser mejor), el reparto era demasiado
  -- optimista (Deviate Scale Cloak: pergamino de 70s para 3 fabricaciones). Se
  -- repite el plan repartiendo el precio solo entre los puntos que de verdad la
  -- usa; se queda el plan que llega más lejos y, a igualdad, el más barato.
  if not opts.forced and not opts.feeSpan then
    local o = {}
    for k, v in pairs(opts) do o[k] = v end
    o.feeSpan = {}
    local best
    for _ = 1, FEE_PASSES do
      local plan = Planner:Plan(data, o)
      if not best or plan.reached > best.reached or (plan.reached == best.reached and plan.net < best.net - EPS) then
        best = plan
      end
      local changed = false
      for id, use in pairs(plan.feeUse or {}) do
        if use.points < use.assumed * FEE_SLACK and (not o.feeSpan[id] or use.points < o.feeSpan[id]) then
          o.feeSpan[id] = use.points
          changed = true
        end
      end
      if not changed then break end
    end
    return best
  end

  local ctx = NewContext(data, opts)
  local plan = {
    choice = {}, -- [nivel] = receta elegida para ese punto
    from = opts.from, to = opts.to, scanTime = ctx.scanTime,
    steps = {}, ranks = {}, shopping = {}, crafted = {}, kept = {}, keptByItem = {},
    reagentCost = 0, resale = 0, fees = 0,
    stockValue = 0, -- valor de lo que se usa del inventario (venta a la que renuncias)
    owned = {},
    tools = {}, toolsCost = 0, -- herramientas (bastones rúnicos) que hay que conseguir
    missingPrice = {}, shortSupply = {},
  }

  -- Recetas candidatas y lo que no depende del nivel. Con la ruta entera forzada
  -- (la fijada, las que recorre el GPS) solo hacen falta las suyas: el resultado es
  -- el mismo y prepararlas todas era lo que más tardaba
  local only
  -- (opts.fullInfo: la ruta que se enseña, con las recetas bloqueadas de cada paso)
  if opts.forced and not opts.fullInfo then
    only = {}
    for s = opts.from, opts.to - 1 do
      local id = opts.forced[s]
      if not id then only = nil break end
      only[id] = true
    end
  end
  local info = {}
  for id, r in pairs(data.recipes) do
    local learn = (not only or only[id]) and Planner.LearnSkill(r, opts)
    -- opts.excluded: recetas que el jugador ha quitado de la ruta (p. ej. el pergamino está lejos)
    if learn and learn < opts.to and r.t[4] > opts.from and not (opts.excluded and opts.excluded[id]) then
      local learnCost, learnSource = Planner.LearnCost(ctx, r)
      info[id] = { learn = learn, sale = Planner.SaleInfo(ctx, r), learnCost = learnCost, learnSource = learnSource }
    end
  end

  -- Voraz: el mejor por cada punto, gastando existencias de la AH
  local learned = {}
  local bought = {} -- [itemID] = { ahQty, ahCost, vendorQty, vendorCost }
  local craftedQty = {}
  local keptQty = {}  -- [itemID] = unidades fabricadas en el plan que se usan después
  local keptFor = {}  -- [itemID] = { [recetaQueLoUsa] = unidades }
  local ownedQty = {} -- [itemID] = unidades que se usan de tus bolsas/banco
  local perPoint = {}
  local lastWhy
  -- Puntos de media que ya han dado los materiales fabricados por el camino (ver
  -- CraftBonus): al llegar a uno entero, ese nivel no pide fabricar nada
  local carry, lastBest = 0, nil

  for s = opts.from, opts.to - 1 do
    if carry >= 1 - EPS and lastBest then
      -- Punto ya ganado con lo intermedio: sin fabricaciones ni materiales, en el
      -- paso de la receta anterior
      carry = carry - 1
      perPoint[#perPoint + 1] = { id = lastBest.id, crafts = 0, chance = lastBest.chance, cost = 0, value = 0,
        reagents = {}, need = {}, blocked = {}, skill = s, free = true }
      plan.choice[s] = lastBest.id
    else
    local best
    local why = {}
    ctx.skill = s -- (lo que aún da puntos a este nivel no se fabrica como preparación, ver Acquire)
    local blocked = {} -- recetas que se podrían usar pero les falta el precio de algún material
    -- Ruta fijada (ver arriba): en ese punto solo vale la receta ya elegida; donde
    -- la ruta sin bolsas se paraba, lo tuyo puede permitir seguir con cualquiera
    local forced = opts.forced and opts.forced[s]
    for id, inf in pairs(info) do
      ES.Yield() -- calculado como trabajo (Jobs.lua): sigue en el siguiente fotograma
      if inf.learn <= s and (not forced or forced == id) then
        local r = data.recipes[id]
        local chance = Planner.Chance(r.t, s)
        if chance > 0 then
          local crafts = 1 / chance
          local whyR = {}
          local cost, reagents, extra, actions = RecipeCost(ctx, r, crafts, whyR)
          -- Herramienta que pide (se consigue una sola vez, la primera vez que hace falta)
          local toolCost, tool
          if cost and r.tool then
            tool = ES.Data.Tools[r.tool]
            if tool and (ctx.toolMask[tool.family or "rod"] or 0) < tool.mask then
              -- (una herramienta se fabrica una vez y no se compra: vale aunque dé puntos)
              local skill = ctx.skill
              ctx.skill = nil
              toolCost = Acquire(ctx, tool.item, 1, 0, extra, actions, whyR)
              ctx.skill = skill
              if not toolCost then cost = nil end
            else
              tool = nil
            end
          end
          for itemID, reason in pairs(whyR) do why[itemID] = why[itemID] or reason end
          if not cost then
            blocked[#blocked + 1] = { id = id, chance = chance, missing = whyR }
          else
            local value = SaleValue(inf.sale, crafts)
            -- Si fabricarla da dinero (lo que sacas al vendedor supera los materiales),
            -- ese beneficio no puede crecer con las fabricaciones que pide una receta
            -- casi gris: Lesser Magic Wand al 8% (13 por punto) "ganaba" a Greater
            -- Magic Wand al 95% solo por vender más varitas. Para elegir, el beneficio
            -- cuenta entero hasta PROFIT_FULL_CRAFTS fabricaciones por punto y, más allá,
            -- rebajado (el coste real de la ruta no cambia). Antes se rebajaba siempre
            -- (como una sola fabricación) y se comía el beneficio de pasos normales: la
            -- Rough Dynamite con pólvora de tus piedras ganaba 45s y contaban 12s
            -- Y cada fabricación de más allá pesa CRAFT_COST: si no, una receta con
            -- beneficio ganaba a cualquiera que costase algo aunque estuviera casi gris
            local net = cost - value
            if net < 0 and crafts > PROFIT_FULL_CRAFTS then
              net = net * PROFIT_FULL_CRAFTS / crafts + CRAFT_COST * (crafts - PROFIT_FULL_CRAFTS)
            end
            -- Coste simbólico de cada fabricación (solo al elegir; ver Plan)
            local score = net + (opts.craftCost or 0) * crafts
            local span = math.max(1, math.min(r.t[4], opts.to) - s)
            local feeSpan
            if inf.learnCost > 0 and not learned[id] then
              -- Entre los puntos que la usó la pasada anterior, si fueron menos (ver arriba)
              feeSpan = math.max(1, math.min(span, opts.feeSpan and opts.feeSpan[id] or span))
              score = score + inf.learnCost / feeSpan
            end
            if toolCost then score = score + toolCost / span end
            -- Lo fabricado por el camino también sube puntos: el punto sale más barato
            local bonus = CraftBonus(ctx, actions, s)
            score = score / (1 + bonus)
            if not best or score < best.score then
              best = {
                id = id, score = score, crafts = crafts, chance = chance, cost = cost, value = value,
                reagents = reagents, extra = extra, actions = actions,
                tool = tool, toolCost = toolCost or 0, feeSpan = feeSpan, bonus = bonus,
              }
            end
          end
        end
      end
    end

    if not best then
      plan.stoppedAt = s
      lastWhy = why
      break
    end

    -- Herramienta conseguida: ya cubre esta categoría y las inferiores
    if best.tool then
      local fam = best.tool.family or "rod"
      ctx.toolMask[fam] = math.max(ctx.toolMask[fam] or 0, best.tool.mask)
      plan.tools[#plan.tools + 1] = { item = best.tool.item, cost = best.toolCost, skill = s }
      plan.toolsCost = plan.toolsCost + best.toolCost
    end

    -- Recetas con más probabilidad que la elegida que no se pueden usar por falta de precio
    best.blocked = {}
    for _, b in ipairs(blocked) do
      if b.chance > best.chance then best.blocked[#best.blocked + 1] = b end
    end

    -- Confirmar: gastar existencias de la AH y del inventario, y anotar compras
    learned[best.id] = true
    for key, q in pairs(best.extra) do
      if type(key) == "string" then
        local itemID = tonumber(key:sub(2))
        ctx.owned[itemID] = ctx.owned[itemID] - q
      elseif key > 0 then
        ctx.used[key] = (ctx.used[key] or 0) + q
      else
        ConsumeLots(ctx.stock[-key], q)
      end
    end
    for _, a in ipairs(best.actions) do
      -- Material que se puede fabricar: lo decidido ahora (fabricar o comprar) se
      -- mantiene en el resto del plan (ver Acquire)
      if ctx.producers[a.item] and not ctx.via[a.item] then
        if a.kind == "craft" then ctx.via[a.item] = "craft"
        elseif a.kind == "ah" or a.kind == "vendor" then ctx.via[a.item] = "buy" end
      end
      if a.kind == "craft" then
        -- (from: el nivel en que se empieza a fabricar; antes, si daba puntos, no se podía)
        craftedQty[a.item] = craftedQty[a.item] or { qty = 0, recipe = a.recipe, from = s }
        craftedQty[a.item].qty = craftedQty[a.item].qty + a.qty
      elseif a.kind == "stock" then
        keptQty[a.item] = (keptQty[a.item] or 0) + a.qty
        plan.stockValue = plan.stockValue + a.cost
        -- Para qué receta se guarda
        keptFor[a.item] = keptFor[a.item] or {}
        keptFor[a.item][best.id] = (keptFor[a.item][best.id] or 0) + a.qty
      elseif a.kind == "owned" then
        ownedQty[a.item] = (ownedQty[a.item] or 0) + a.qty
      else
        local b = bought[a.item] or { ahQty = 0, ahCost = 0, vendorQty = 0, vendorCost = 0 }
        bought[a.item] = b
        if a.kind == "ah" then
          b.ahQty, b.ahCost = b.ahQty + a.qty, b.ahCost + a.cost
        else
          b.vendorQty, b.vendorCost = b.vendorQty + a.qty, b.vendorCost + a.cost
        end
      end
    end
    -- Materiales que pide este punto (comprados o de tus bolsas): con la ruta
    -- fijada, la lista de la compra cuenta lo que falta desde tu nivel actual
    best.need = {}
    for _, a in ipairs(best.actions) do
      if a.kind == "ah" or a.kind == "vendor" or a.kind == "owned" then
        best.need[a.item] = (best.need[a.item] or 0) + a.qty
      end
    end
    -- Lo fabricado entra al inventario del plan, valorado como se ha contado su venta
    local sale = info[best.id].sale
    if sale then
      ctx.stock[sale.itemID] = ctx.stock[sale.itemID] or {}
      AddLot(ctx.stock[sale.itemID], sale.vendor, best.crafts * sale.qty)
    end
    perPoint[#perPoint + 1] = best
    best.skill = s
    plan.choice[s] = best.id
    lastBest, carry = best, carry + (best.bonus or 0)
    end
  end

  ctx.skill = nil -- (fuera del recorrido punto a punto: sin nivel)

  -- [nivel] = { [itemID] = unidades } que pide ese punto (ver arriba)
  plan.pointNeed, plan.pointChance = {}, {}
  plan.freePoints = 0 -- puntos que dan los materiales fabricados por el camino (ver CraftBonus)
  for _, p in ipairs(perPoint) do
    plan.pointNeed[p.skill], plan.pointChance[p.skill] = p.need, p.chance
    if p.free then plan.freePoints = plan.freePoints + 1 end
  end

  -- Recetas de pago: entre cuántos puntos se repartió su precio y cuántos se usaron
  plan.feeUse = {}
  for _, p in ipairs(perPoint) do
    local use = plan.feeUse[p.id]
    if use then
      use.points = use.points + 1
    elseif p.feeSpan then
      plan.feeUse[p.id] = { assumed = p.feeSpan, points = 1 }
    end
  end

  -- Por qué se paró: materiales sin precio o sin existencias suficientes
  if lastWhy then
    for itemID, reason in pairs(lastWhy) do
      if reason == "supply" then plan.shortSupply[itemID] = true else plan.missingPrice[itemID] = true end
    end
  end

  -- Rangos del instructor (Oficial, Experto, Artesano...) que el plan necesita
  local reached = plan.stoppedAt or opts.to
  local caps = { APPRENTICE_CAP }
  for _, rank in ipairs(data.ranks) do caps[#caps + 1] = rank[1] end
  -- Tope actual: el real del juego si se conoce (p. ej. 75 con Aprendiz); si
  -- no, se supone entrenado el rango que cubre el nivel de partida
  local currentCap = opts.cap
  if not currentCap then
    for _, c in ipairs(caps) do
      if c > opts.from then currentCap = c break end
    end
  end
  for i, rank in ipairs(data.ranks) do
    local prevCap = caps[i]
    if rank[1] > (currentCap or 0) and prevCap < reached then
      plan.ranks[#plan.ranks + 1] = { cap = rank[1], fee = rank[2], skill = math.max(opts.from, rank[3]), level = rank[4] }
      plan.fees = plan.fees + rank[2]
    end
  end

  -- Agrupar puntos consecutivos con la misma receta
  local step
  for _, p in ipairs(perPoint) do
    if not (step and step.id == p.id) then
      step = {
        id = p.id, from = p.skill, expected = 0, costSum = 0, valueSum = 0,
        reagents = {}, firstChance = p.chance, blocked = {},
      }
      plan.steps[#plan.steps + 1] = step
    end
    step.to = p.skill + 1
    step.lastChance = p.chance
    for _, b in ipairs(p.blocked) do
      local missing = step.blocked[b.id]
      if not missing then
        missing = {}
        step.blocked[b.id] = missing
        step.blocked[#step.blocked + 1] = b.id
      end
      for itemID in pairs(b.missing) do missing[itemID] = true end
    end
    step.expected = step.expected + p.crafts
    step.costSum = step.costSum + p.cost
    step.valueSum = step.valueSum + p.value
    for _, rg in ipairs(p.reagents) do
      local agg = step.reagents[rg.item]
      if not agg then
        agg = { item = rg.item, qty = 0, cost = 0, kinds = {} }
        step.reagents[rg.item] = agg
        step.reagents[#step.reagents + 1] = agg
      end
      agg.qty = agg.qty + rg.qty
      agg.cost = agg.cost + rg.cost
      for kind in pairs(rg.kinds) do agg.kinds[kind] = true end
    end
  end

  local feePaid = {}
  for _, st in ipairs(plan.steps) do
    local inf = info[st.id]
    st.recipe = data.recipes[st.id]
    st.crafts = math.ceil(st.expected - 0.001)
    st.unitCost = st.costSum / st.expected
    st.unitValue = st.valueSum / st.expected
    st.sale = inf.sale
    local firstUse = not feePaid[st.id]
    st.fee = firstUse and inf.learnCost or 0
    st.learnSource = firstUse and inf.learnSource or nil
    feePaid[st.id] = true
    st.total = st.crafts * (st.unitCost - st.unitValue) + st.fee

    plan.reagentCost = plan.reagentCost + st.crafts * st.unitCost
    plan.resale = plan.resale + st.crafts * st.unitValue
    plan.fees = plan.fees + st.fee
  end

  -- Lista de la compra (separando AH y vendedor) y lo que conviene fabricar antes
  for itemID, b in pairs(bought) do
    local supply = ctx.ladders[itemID] and LadderSupply(ctx.ladders[itemID])
    if b.ahQty > EPS then
      plan.shopping[#plan.shopping + 1] = {
        itemID = itemID, quantity = math.ceil(b.ahQty - 0.001), source = "ah",
        unit = b.ahCost / b.ahQty, total = b.ahCost, supply = supply,
      }
    end
    if b.vendorQty > EPS then
      plan.shopping[#plan.shopping + 1] = {
        itemID = itemID, quantity = math.ceil(b.vendorQty - 0.001), source = "vendor",
        unit = b.vendorCost / b.vendorQty, total = b.vendorCost,
      }
    end
  end
  table.sort(plan.shopping, function(a, b) return a.total > b.total end)

  for itemID, c in pairs(craftedQty) do
    plan.crafted[#plan.crafted + 1] = { itemID = itemID, quantity = math.ceil(c.qty - 0.001), recipe = data.recipes[c.recipe], from = c.from }
  end

  -- Lo que sale de tus bolsas
  plan.owned = {}
  for itemID, q in pairs(ownedQty) do plan.owned[#plan.owned + 1] = { itemID = itemID, quantity = math.ceil(q - 0.001) } end
  table.sort(plan.owned, function(a, b) return a.quantity > b.quantity end)

  -- Lo que hay que guardar de tus fabricaciones para pasos posteriores
  plan.kept, plan.keptByItem = {}, {}
  for itemID, q in pairs(keptQty) do
    local qty = math.ceil(q - 0.001)
    plan.kept[#plan.kept + 1] = { itemID = itemID, quantity = qty }
    plan.keptByItem[itemID] = qty
  end

  -- Qué hacer con cada cosa que fabricas: guardar (para qué paso) o vender. El
  -- coste del plan cuenta la venta al vendedor; si en la AH te quedaría más,
  -- se indica como opción (ahExtra), sin sumarlo: no se sabe si se venderá.
  plan.destinations = {}
  local destByItem = {}
  for _, st in ipairs(plan.steps) do
    local sale = st.sale
    if sale then
      local d = destByItem[sale.itemID]
      if not d then
        d = { itemID = sale.itemID, produced = 0, sale = sale, firstStep = st }
        destByItem[sale.itemID] = d
        plan.destinations[#plan.destinations + 1] = d
      end
      d.produced = d.produced + st.crafts * sale.qty
    end
  end
  for itemID, d in pairs(destByItem) do
    d.produced = math.floor(d.produced + 0.5)
    d.keep = math.min(d.produced, plan.keptByItem[itemID] or 0)
    d.sell = d.produced - d.keep
    d.ahExtra = d.sale.ahNet and d.sell * (d.sale.ahNet - d.sale.vendor) or nil
    -- Para qué pasos se guarda
    d.usedIn = {}
    for recipeID, q in pairs(keptFor[itemID] or {}) do
      local where
      for _, st in ipairs(plan.steps) do
        if st.id == recipeID then where = st break end
      end
      d.usedIn[#d.usedIn + 1] = { recipe = data.recipes[recipeID], qty = math.ceil(q - 0.001), step = where }
    end
    table.sort(d.usedIn, function(a, b) return (a.step and a.step.from or 0) < (b.step and b.step.from or 0) end)
    d.income = d.sell * d.sale.vendor
  end

  plan.pendingInfo = ctx.pendingInfo
  plan.pendingItems = ctx.pendingItems -- [itemID] = true: objetos cuyo precio de vendedor aún no da el juego
  plan.ctx = ctx
  plan.net = plan.reagentCost - plan.resale + plan.fees + plan.toolsCost
  plan.reached = reached
  return plan
end

---------------------------------------------------------------------------
-- Con lo que llevas: una receta que no está en la ruta y que podrías hacer
-- durante unos cuantos puntos solo con tus materiales (y lo del vendedor). La
-- ruta no la elige porque valora lo tuyo a precio de compra (ver Plan); aquí se
-- cuenta aparte: el oro que ahorrarías y lo que te darían por lo tuyo si lo
-- vendieras. Si compensa, Plan la mete en la ruta; si no, la UI explica por qué no.
---------------------------------------------------------------------------

-- Lo que te darían de verdad por `qty` unidades tuyas, con las mismas reglas que lo
-- fabricado en la vista Profit (SaleAdvice): en la AH al precio realista (el de
-- referencia si el mínimo está inflado) menos comisión y depósito, todas si el
-- mercado va bien, unas pocas si es dudoso y ninguna si va mal; el resto, al
-- vendedor. Y nunca más en la AH de las que hay ahora a la venta: un mercado de 15
-- Medium Hide no absorbe 34 más a ese precio. Con el último escaneo, no con los
-- precios de la ruta fijada (esos solo guardan lo que usa la ruta)
local OWNED_AH_FEW = 5
local function OwnedSaleTotal(ctx, itemID, qty)
  local vendor = ES:VendorSellPrice(itemID) or (ES.Data.SellPrices and ES.Data.SellPrices[itemID]) or 0
  local entry = ScanPrices()[itemID] or ctx.prices[itemID]
  local fair = entry and entry.minUnit and ES.Market:FairPrice(itemID, entry.minUnit)
  if not fair then return vendor * qty end
  local deposit, cut = Planner.AuctionCosts(vendor, ctx.opts)
  local net = fair.price * (1 - cut) - deposit
  if net <= vendor then return vendor * qty end
  local verdict = ES.Market:Signals(itemID).verdict
  local onAH = verdict == "good" and qty or verdict == "avoid" and 0 or math.min(qty, OWNED_AH_FEW)
  onAH = math.min(onAH, entry.quantity or onAH)
  return onAH * net + (qty - onAH) * vendor
end
Planner.OwnedValue = OwnedSaleTotal

-- Lo que dejas de ganar al usar `qty` de tus `have`: lo que vale todo lo tuyo
-- vendido menos lo que vale lo que te queda. No lo que valdrían esos `qty`
-- vendidos: usando 10 de tus 34 Medium Hide sigues vendiendo en la AH las pocas
-- que absorbe a buen precio; lo que pierdes son 10 al precio del vendedor
local function OwnedCost(ctx, itemID, have, qty)
  qty = math.min(qty, have)
  if qty <= 0 then return 0 end
  return OwnedSaleTotal(ctx, itemID, have) - OwnedSaleTotal(ctx, itemID, have - qty)
end
Planner.OwnedCost = OwnedCost -- (para Planner.RouteScore)

-- plan: la ruta que se enseña; owned: { [itemID] = cantidad } en bolsas/banco;
-- from: tu nivel; excluded: recetas quitadas con la ✕ (la ruta fijada no las
-- guarda). Devuelve la mejor alternativa o nil: la que da más puntos o, con
-- onlyWorth, la que más gana a vender lo tuyo de entre las que compensan (para
-- meterla en la ruta: la de más puntos puede no compensar y otra sí):
-- { id, recipe, from, to, crafts, fee, feeUnknown, spend (oro que pagas), gold (spend
--   menos lo que sacas vendiendo lo fabricado), value (lo tuyo, vendido), routeCost,
--   saving (routeCost - gold), use = { { itemID, qty, value } } (de más a menos valor) }
function Planner.BagsAlternative(data, plan, owned, from, excluded, onlyWorth)
  local ctx = plan and plan.ctx
  if not ctx or not owned or not next(owned) then return nil end
  from = math.max(from or plan.from, plan.from)
  local to = plan.reached or plan.to
  if from >= to then return nil end
  local inRoute = {}
  for _, st in ipairs(plan.steps) do inRoute[st.id] = true end
  -- Lo tuyo que ya gasta la ruta no se puede usar dos veces
  local left = {}
  for itemID, n in pairs(owned) do left[itemID] = n end
  for _, it in ipairs(plan.owned or {}) do
    if left[it.itemID] then left[it.itemID] = left[it.itemID] - it.quantity end
  end
  excluded = excluded or ctx.opts.excluded or {}
  local best
  for id, r in pairs(data.recipes) do
    local learn = r.out and not inRoute[id] and not excluded[id] and not r.conversion and not r.intermediate
      and Planner.LearnSkill(r, ctx.opts)
    if learn and learn < to and r.t[4] > from then
      -- Fabricaciones que te dan tus materiales (lo del vendedor se compra)
      local crafts, mine = math.huge, false
      for _, rq in ipairs(r.r) do
        if not ES.Data.VendorPrices[rq[1]] then
          mine = true
          crafts = math.min(crafts, math.floor((left[rq[1]] or 0) / rq[2]))
        end
      end
      local start = math.max(from, learn)
      if mine and crafts >= 1 then
        -- Puntos que dan (como el plan: 1/probabilidad fabricaciones por punto)
        local s, used = start, 0
        while s < to do
          local chance = Planner.Chance(r.t, s)
          if chance <= 0 or used + 1 / chance > crafts + EPS then break end
          used = used + 1 / chance
          s = s + 1
        end
        if s - start >= BAGS_MIN_POINTS then
          local n = math.ceil(used - 0.001)
          local fee, source = Planner.LearnCost(ctx, r)
          local gold, value, use = fee, 0, {}
          for _, rq in ipairs(r.r) do
            local vendor = ES.Data.VendorPrices[rq[1]]
            if vendor then
              gold = gold + vendor * rq[2] * n
            else
              local v = OwnedCost(ctx, rq[1], left[rq[1]] or 0, rq[2] * n)
              value = value + v
              use[#use + 1] = { itemID = rq[1], qty = rq[2] * n, value = v }
            end
          end
          local spend = gold -- oro que sale de tu bolsillo (instructor y vendedor)
          gold = gold - SaleValue(Planner.SaleInfo(ctx, r), n)
          table.sort(use, function(a, b) return a.value > b.value end)
          -- Lo que cuesta la ruta en ese tramo; el precio de aprender una receta
          -- de la ruta solo se ahorra si ya no hace falta en ningún otro punto
          local outside = {}
          for _, st in ipairs(plan.steps) do
            if st.from < start or st.to > s then outside[st.id] = true end
          end
          local routeCost = 0
          for _, st in ipairs(plan.steps) do
            local a, b = math.max(st.from, start), math.min(st.to, s)
            if b > a then
              routeCost = routeCost + (st.total - st.fee) * (b - a) / (st.to - st.from)
              if not outside[st.id] then routeCost = routeCost + st.fee end
            end
          end
          local saving = routeCost - gold
          local alt = {
            id = id, recipe = r, from = start, to = s, crafts = n,
            fee = fee, feeUnknown = source == "trainer" and r.trainer and not Fee(r) or nil,
            gold = gold, spend = spend, value = value, routeCost = routeCost, saving = saving, use = use,
          }
          local diff = saving - value
          local better
          if onlyWorth then
            better = Planner.BagsWorth(alt) and (not best or diff > best.saving - best.value)
          else
            better = not best or alt.to - alt.from > best.to - best.from
              or (alt.to - alt.from == best.to - best.from and diff > best.saving - best.value)
          end
          if saving >= BAGS_MIN_SAVING and better then best = alt end
        end
      end
    end
  end
  return best
end

---------------------------------------------------------------------------
-- Recetas y AH: cada receta que puedes conseguir ahora (instructor, vendedor,
-- básica o pergamino anunciado en la AH) con lo que cuesta fabricar 1 y a
-- cuánto se anuncia lo fabricado. Sin estimar ventas: se compara con el mínimo
-- anunciado, que es lo que tendrías que igualar para vender.
---------------------------------------------------------------------------
-- opts.all: todas las recetas (también las que no puedes conseguir ahora y las
-- que no fabrican objeto, como los encantamientos), para la Colección
function Planner:RecipeMarket(data, opts)
  local o = { from = 1, to = 300, includeScrolls = false, ignoreSupply = true,
    hours = opts.hours, neutral = opts.neutral, sourcedScrolls = opts.sourcedScrolls, noQuests = opts.noQuests }
  local ctx = NewContext(data, o)
  Annotate(data)
  local list = {}
  -- "rep": se lista para que veas qué te daría subir la reputación, pero la ruta no la usa
  local OBTAINABLE = { trainer = true, vendor = true, scroll = true, quest = true, ah = true, owned = true, known = true, rep = true }
  for id, r in pairs(data.recipes) do
    if (r.out or opts.all) and not r.conversion and not r.intermediate then
      local learnCost, learnSource = Planner.LearnCost(ctx, r)
      local basic = learnSource == nil and Planner.LearnSkill(r, o) ~= nil
      -- opts.anySource: también las de fuente desconocida (vista Recetas: que el buscador las encuentre)
      if OBTAINABLE[learnSource] or basic or opts.all or opts.anySource then
        local cost, reagents = RecipeCost(ctx, r, 1, {})
        local itemID, qty = r.out and r.out[1], r.out and r.out[2] or 1
        local ah = itemID and ctx.prices[itemID]
        local vendor = itemID and ES:VendorSellPrice(itemID)
        if itemID and not vendor then ctx.pendingInfo = true end
        local deposit, cut = Planner.AuctionCosts(vendor or 0, o)
        local e = {
          id = id, recipe = r, itemID = itemID, qty = qty, cost = cost, reagents = reagents,
          learn = basic and 1 or select(2, Fee(r)) or 1, learnCost = learnCost or 0, learnSource = learnSource or (basic and "basic" or "unknown"),
          vendor = vendor or 0, deposit = deposit, cut = cut,
          ahMin = ah and ah.minUnit, ahMedian = ah and (ah.median or ah.minUnit),
          listings = ah and ah.listings or 0, quantity = ah and ah.quantity or 0,
        }
        -- Lo que te queda por unidad en la AH al precio realista (el mínimo, o la
        -- referencia del histórico si el mínimo está inflado): - comisión - depósito
        e.fair = itemID and not r.bop and ES.Market:FairPrice(itemID, e.ahMin) or nil -- ligado: sin AH
        if e.fair then
          e.ahPrice = e.fair.price
          e.ahNet = e.ahPrice * (1 - cut) - deposit
        end
        if cost and itemID then
          local best = e.vendor
          e.sellWhere = "vendor"
          if e.ahNet and e.ahNet > best then best, e.sellWhere = e.ahNet, "ah" end
          e.profit = best * qty - cost
          e.margin = cost > 0 and e.profit / cost or nil
          -- Solo al vendedor (venta segura): para la opción de la Colección
          e.profitVendor = e.vendor * qty - cost
        end
        list[#list + 1] = e
      end
    end
  end
  return list, ctx
end

---------------------------------------------------------------------------
-- Nivel actual del jugador en una profesión
---------------------------------------------------------------------------
local LOCAL_NAMES = {
  [165] = { "Leatherworking", "Peletería", "Peleteria" },
  [333] = { "Enchanting", "Encantamiento" },
  [197] = { "Tailoring", "Sastrería", "Sastreria" },
  [164] = { "Blacksmithing", "Herrería", "Herreria" },
  [171] = { "Alchemy", "Alquimia" },
  [202] = { "Engineering", "Ingeniería", "Ingenieria" },
  [185] = { "Cooking", "Cocina" },
  [129] = { "First Aid", "Primeros auxilios" },
}

function ES:GetProfessionSkill(skillLine)
  if GetProfessions and GetProfessionInfo then
    -- GetProfessions devuelve huecos con nil (p. ej. sin segunda profesión):
    -- recorrer por posición, no con ipairs, que se pararía en el primer nil
    local slots = { GetProfessions() }
    for i = 1, select("#", GetProfessions()) do
      local index = slots[i]
      if index then
        local _, _, rank, maxRank, _, _, line = GetProfessionInfo(index)
        if line == skillLine then return rank, maxRank end
      end
    end
  end
  if GetNumSkillLines and GetSkillLineInfo then
    local names = LOCAL_NAMES[skillLine] or {}
    for i = 1, GetNumSkillLines() do
      local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
      if not isHeader then
        for _, n in ipairs(names) do
          if name == n then return rank, maxRank end
        end
      end
    end
  end
  return nil
end


---------------------------------------------------------------------------
-- Alternativas de un paso: por qué la ruta usa esta receta y no otra
---------------------------------------------------------------------------
-- La misma ruta, pero con otra receta en el tramo del paso (lo demás igual): la
-- diferencia de coste neto ya cuenta materiales, venta, aprender y lo que se reutiliza
-- después. Cada una es una pasada forzada (~2 ms)

-- Recetas que podrían hacer el tramo de `st`: se pueden aprender a ese nivel y aún dan
-- puntos al empezarlo (ni conversiones, ni materiales intermedios, ni las quitadas)
function Planner.AlternativeCandidates(data, plan, st)
  local opts = plan.ctx and plan.ctx.opts
  if not opts or not plan.choice then return {} end
  local out = {}
  for id, r in pairs(data.recipes) do
    if id ~= st.id and not r.conversion and not r.intermediate and r.t[4] > st.from
      and not (opts.excluded and opts.excluded[id]) then
      local learn = Planner.LearnSkill(r, opts)
      if learn and learn <= st.from then out[#out + 1] = id end
    end
  end
  table.sort(out)
  return out
end

-- La ruta con `id` en el tramo de `st`. Devuelve { id, delta (coste neto de más de toda
-- la ruta), step (su paso en ese tramo), ahGain (lo que ganaría vendiendo lo fabricado
-- en la AH en vez de al vendedor) }, o nil si así no se llega igual de lejos
function Planner.EvaluateAlternative(data, plan, st, id)
  local o = Copy(plan.ctx.opts)
  o.forced = {}
  for s, c in pairs(plan.choice) do o.forced[s] = c end
  for s = st.from, st.to - 1 do o.forced[s] = id end
  local ok, p = pcall(Planner.Plan, Planner, data, o)
  if not ok or not p or (p.reached or 0) < (plan.reached or 0) then return nil end
  local step
  for _, s in ipairs(p.steps or {}) do
    if s.id == id and s.from <= st.from and s.to > st.from then step = s break end
  end
  if not step then return nil end
  local sale, ahGain = step.sale, 0
  if sale and sale.ahNet and sale.vendor and sale.ahNet > sale.vendor then
    ahGain = step.crafts * (sale.qty or 1) * (sale.ahNet - sale.vendor)
  end
  return { id = id, delta = p.net - plan.net, step = step, ahGain = ahGain }
end

-- Motivo principal por el que `alt` sale peor que el paso `st` de la ruta:
-- "materials" (materiales más caros), "sale" (se recupera menos vendiéndolo), "fee"
-- (hay que aprenderla), "crafts" (hacen falta más fabricaciones) o "route" (afecta a
-- otros pasos: lo que se reutiliza después)
function Planner.AlternativeReason(st, alt)
  local a = alt.step
  local parts = {
    materials = (a.costSum or 0) - (st.costSum or 0),
    sale = (st.valueSum or 0) - (a.valueSum or 0),
    fee = (a.fee or 0) - (st.fee or 0),
  }
  local best, bestV = nil, 0
  for k, v in pairs(parts) do if v > bestV then best, bestV = k, v end end
  if not best then
    -- Nada de este paso sale peor: más fabricaciones o el resto de la ruta
    return (a.expected or 0) > (st.expected or 0) + 0.5 and "crafts" or "route"
  end
  return best
end
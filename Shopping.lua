local _, ES = ...

-- Lista de la compra: lo que TÚ añades desde una ruta, Ganar dinero o la calculadora
-- (botón "Añadir a la lista de compra"). La enseña la pestaña Lista de compra
-- (ShoppingUI.lua), desde donde se compra con la AH abierta.
--
-- Cada lista guarda sus materiales tal cual al añadirla: no cambia con los precios.
-- Lo que tienes se cuenta con tus bolsas: lo que llevas de cada material llena
-- primero la lista del tramo (si la hay) y luego las guardadas, de la más antigua a
-- la más nueva.
--
-- Por personaje: ES.charData.shopping[i] =
--   { t, kind ("route" | "money" | "calc"), key, title, items = { { itemID, need, unit, source } } }

local Shopping = {}
ES.Shopping = Shopping
local L = ES.L

local MAX_LISTS = 20

function Shopping.Lists()
  local c = ES.charData
  if not c then return {} end
  if type(c.shopping) ~= "table" then c.shopping = {} end
  return c.shopping
end

-- Añade una lista. items = { { itemID, quantity, unit, source } } (se juntan los
-- repetidos; source "craft" no se compra y no entra). opts:
--   key:       si ya hay una lista de ese tipo con esa clave (la ruta de una profesión,
--              el mismo cálculo), se sustituye en vez de duplicarla
--   minusBags: descontar lo que ya llevas (la ruta ya lo descuenta; el lote no)
-- Devuelve la lista, o nil si no hay nada que comprar.
function Shopping.Add(kind, title, items, opts)
  opts = opts or {}
  local merged, order = {}, {}
  for _, it in ipairs(items or {}) do
    if it.itemID and it.source ~= "craft" and (it.quantity or 0) > 0 then
      local m = merged[it.itemID]
      if not m then
        m = { itemID = it.itemID, quantity = 0, cost = 0, source = it.source or "ah" }
        merged[it.itemID] = m
        order[#order + 1] = m
      end
      m.quantity = m.quantity + it.quantity
      m.cost = m.cost + (it.unit or 0) * it.quantity
    end
  end
  local list = { t = time(), kind = kind, key = opts.key, title = title, items = {} }
  for _, m in ipairs(order) do
    -- (lo que llevas no se resta aquí: se cuenta al enseñarla, ver Status)
    local need = math.ceil(m.quantity - 0.001)
    if need > 0 then
      list.items[#list.items + 1] = { itemID = m.itemID, need = need, unit = m.cost / m.quantity, source = m.source }
    end
  end
  if #list.items == 0 then return nil end
  local lists = Shopping.Lists()
  if opts.key then
    for i = #lists, 1, -1 do
      if lists[i].kind == kind and lists[i].key == opts.key then table.remove(lists, i) end
    end
  end
  lists[#lists + 1] = list
  while #lists > MAX_LISTS do table.remove(lists, 1) end
  return list
end

function Shopping.Remove(list)
  local lists = Shopping.Lists()
  for i = #lists, 1, -1 do
    if lists[i] == list then table.remove(lists, i) return true end
  end
  return false
end

-- Quita un material de una lista (si se queda vacía, se quita la lista)
function Shopping.RemoveItem(list, itemID)
  for i = #list.items, 1, -1 do
    if list.items[i].itemID == itemID then table.remove(list.items, i) end
  end
  if #list.items == 0 then Shopping.Remove(list) end
end

---------------------------------------------------------------------------
-- Lista de una ruta empezada, calculada al vuelo (no se añade a mano): por tramos
-- (por defecto, Planner.Phase) lo del tramo en el que estás con su colchón; con
-- "Ruta entera", todo lo que pide la ruta desde tu nivel. Lo que llevas se cuenta
-- al enseñarla (Status)
---------------------------------------------------------------------------
function Shopping.ByPhase(profKey)
  local s = ES.db and ES.db.prof and ES.db.prof[profKey]
  return not (s and s.byPhase == false)
end

-- Fuente y precio de un material según la ruta (AH antes que vendedor)
local function SourceOf(plan, itemID)
  local found
  for _, e in ipairs(plan.shopping or {}) do
    if e.itemID == itemID and (not found or e.source == "ah") then found = e end
  end
  if found then return found.source, found.unit end
  return (ES.Data.VendorPrices and ES.Data.VendorPrices[itemID]) and "vendor" or "ah", 0
end

-- Lista de la ruta empezada de una profesión (del tramo o de la ruta entera), o nil
function Shopping.PhaseList(profKey)
  local lock = ES.RouteLock and ES:RouteLock(profKey)
  if not lock or lock.completed then return nil end
  local plan = ES:LockedPlan(profKey)
  local data = ES.Data[profKey]
  if not (plan and data) then return nil end
  local level = math.max(plan.from, ES:GetProfessionSkill(data.skillLine) or plan.from)
  local list = { t = 0, kind = "phase", key = profKey, live = true, items = {} }
  local wanted = {} -- [itemID] = { need, expected }
  if Shopping.ByPhase(profKey) then
    local need, phase = ES.Planner.PhaseNeed(plan, level)
    if not phase then return nil end
    list.phase = phase
    list.title = string.format(L["%s: tramo %d-%d"], ES:ProfLabel(profKey), phase.from, phase.to)
    for itemID, n in pairs(need) do wanted[itemID] = { need = n.target, expected = n.expected } end
  else
    list.whole = true
    list.title = string.format(L["%s: ruta %d-%d"], ES:ProfLabel(profKey), level, lock.to)
    for itemID, q in pairs(ES.Planner.NeedFrom(plan, level)) do
      local n = math.ceil(q - 0.001)
      if n > 0 then wanted[itemID] = { need = n, expected = q } end
    end
  end
  for itemID, w in pairs(wanted) do
    local source, unit = SourceOf(plan, itemID)
    list.items[#list.items + 1] = { itemID = itemID, need = w.need, expected = w.expected, unit = unit, source = source }
  end
  table.sort(list.items, function(a, b) return a.need * (a.unit or 0) > b.need * (b.unit or 0)
    or (a.need * (a.unit or 0) == b.need * (b.unit or 0) and a.itemID < b.itemID) end)
  return #list.items > 0 and list or nil
end

-- Las listas de todas las rutas empezadas
function Shopping.PhaseLists()
  local out = {}
  for _, p in ipairs(ES.PROFESSIONS or {}) do
    local list = ES.Data[p.key] and Shopping.PhaseList(p.key)
    if list then out[#out + 1] = list end
  end
  return out
end

-- Estado de toda la lista:
--   { lists = { { list, items = { { it, bought (lo que llevas para ella), left } }, done, total, cost } },
--     done, total (materiales), cost (lo que falta, a los precios de cuando se añadió) }
function Shopping.Status()
  local res = { lists = {}, done = 0, total = 0, cost = 0 }
  -- Lo que llevas de cada material, que se va repartiendo entre las listas
  local left = {}
  local function Take(itemID, need)
    if left[itemID] == nil then left[itemID] = ES:ItemCount(itemID) or 0 end
    local n = math.min(left[itemID], need)
    left[itemID] = left[itemID] - n
    return n
  end
  local function AddList(list)
    local s = { list = list, items = {}, done = 0, total = 0, cost = 0 }
    for _, it in ipairs(list.items) do
      local have = Take(it.itemID, it.need)
      local missing = it.need - have
      s.items[#s.items + 1] = { it = it, bought = have, left = missing }
      s.total = s.total + 1
      if missing == 0 then s.done = s.done + 1 else s.cost = s.cost + missing * (it.unit or 0) end
    end
    res.lists[#res.lists + 1] = s
    res.done, res.total, res.cost = res.done + s.done, res.total + s.total, res.cost + s.cost
  end
  -- Rutas por tramos: su lista viva va primero y la guardada de la ruta entera no sale
  local phased = {}
  for _, list in ipairs(Shopping.PhaseLists()) do
    phased[list.key] = true
    AddList(list)
  end
  -- Las guardadas, de la más antigua a la más nueva. La de una ruta ya acabada (la
  -- profesión llegó a su objetivo) se quita sola: no queda nada que comprar para ella
  local lists = Shopping.Lists()
  for i = #lists, 1, -1 do
    if lists[i].kind == "route" and Shopping.RouteDone(lists[i].key) then table.remove(lists, i) end
  end
  for _, list in ipairs(lists) do
    if not (list.kind == "route" and phased[list.key]) then AddList(list) end
  end
  return res
end

-- ¿Ha terminado la ruta de esta profesión? (ruta empezada y completada, o tu nivel ya
-- llega al objetivo)
function Shopping.RouteDone(profKey)
  local data = profKey and ES.Data[profKey]
  if not data then return false end
  local lock = ES.RouteLock and ES:RouteLock(profKey)
  if lock and lock.completed then return true end
  local rank = data.skillLine and ES:GetProfessionSkill(data.skillLine)
  local target = lock and lock.to or (ES.ProfessionTarget and ES:ProfessionTarget(profKey))
  return rank ~= nil and target ~= nil and rank >= target
end

-- Lo siguiente que comprar en la AH: el material `current` si aún falta (la compra se
-- recorta a las baratas: se vuelve a pulsar para el resto); si no, el primero que
-- falte después de él, y si no, el primero. Devuelve itemID, cuántos, precio por unidad.
function Shopping.NextToBuy(status, current)
  local list = {}
  for _, s in ipairs(status.lists) do
    for _, e in ipairs(s.items) do
      if e.it.source == "ah" and e.left > 0 then list[#list + 1] = e end
    end
  end
  if #list == 0 then return nil end
  local pick, start = nil, 1
  for i, e in ipairs(list) do
    if e.it.itemID == current then pick = pick or e start = i + 1 end
  end
  pick = pick or list[start] or list[1]
  -- (si el mismo material está en dos listas, se compra lo de todas juntas)
  local left = 0
  for _, e in ipairs(list) do if e.it.itemID == pick.it.itemID then left = left + e.left end end
  return pick.it.itemID, left, pick.it.unit
end

-- Cuántos materiales de la AH faltan (para el botón de la AH)
function Shopping.PendingAH()
  local n = 0
  for _, s in ipairs(Shopping.Status().lists) do
    for _, e in ipairs(s.items) do
      if e.it.source == "ah" and e.left > 0 then n = n + 1 end
    end
  end
  return n
end

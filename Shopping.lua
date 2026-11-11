local _, ES = ...

-- Lista de la compra: lo que TÚ añades desde una ruta, Ganar dinero o la calculadora
-- (botón "Añadir a la lista de compra"). La enseña la pestaña Lista de compra
-- (ShoppingUI.lua), desde donde se compra con la AH abierta.
--
-- Cada lista guarda sus materiales tal cual al añadirla: no cambia con los precios ni
-- con las bolsas. Lo comprado se descuenta con la contabilidad (Books.lua): compras en
-- la AH, al vendedor o en trades de ese material desde que añadiste la lista. Así
-- fabricar (que gasta materiales) no te los vuelve a pedir, y comprar en varios días
-- también cuenta. Si dos listas piden el mismo material, las compras llenan primero
-- la más antigua.
--
-- Por personaje: ES.charData.shopping[i] =
--   { t, kind ("route" | "money" | "calc"), key, title, items = { { itemID, need, unit, source } } }

local Shopping = {}
ES.Shopping = Shopping

local MAX_LISTS = 20
local BUY = { ahBuy = true, vendorBuy = true, buy = true }

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
    local need = math.ceil(m.quantity - 0.001)
    if opts.minusBags then need = need - ES:ItemCount(m.itemID) end
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

-- Compras de cada material según la contabilidad: { [itemID] = { { t, q }, ... } }
local function Purchases()
  local out = {}
  local books = ES.Books and ES.Books.Data()
  for _, m in ipairs(books and books.moves or {}) do
    if BUY[m.k] then
      if m.i then
        out[m.i] = out[m.i] or {}
        table.insert(out[m.i], { t = m.t, q = m.q or 1 }) -- (una subasta de objeto suelto: 1)
      else
        for _, g in ipairs(m.g or {}) do
          if g.i then
            out[g.i] = out[g.i] or {}
            table.insert(out[g.i], { t = m.t, q = g.q or 1 })
          end
        end
      end
    end
  end
  return out
end

-- Estado de toda la lista:
--   { lists = { { list, items = { { it, bought, left } }, done, total, cost } },
--     done, total (materiales), cost (lo que falta, a los precios de cuando se añadió) }
function Shopping.Status()
  local lists = Shopping.Lists()
  local buys = Purchases()
  local res = { lists = {}, done = 0, total = 0, cost = 0 }
  -- De la más antigua a la más nueva: cada compra llena la primera lista que la cubre
  for _, list in ipairs(lists) do
    local s = { list = list, items = {}, done = 0, total = 0, cost = 0 }
    for _, it in ipairs(list.items) do
      local bought = 0
      for _, p in ipairs(buys[it.itemID] or {}) do
        if p.t >= list.t and p.q > 0 and bought < it.need then
          local take = math.min(p.q, it.need - bought)
          bought, p.q = bought + take, p.q - take
        end
      end
      local left = it.need - bought
      s.items[#s.items + 1] = { it = it, bought = bought, left = left }
      s.total = s.total + 1
      if left == 0 then s.done = s.done + 1 else s.cost = s.cost + left * (it.unit or 0) end
    end
    res.lists[#res.lists + 1] = s
    res.done, res.total, res.cost = res.done + s.done, res.total + s.total, res.cost + s.cost
  end
  return res
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

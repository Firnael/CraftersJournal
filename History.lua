local _, ES = ...
local L = ES.L

-- Historial de escaneos de la AH.
--
-- No intenta deducir ventas: cuando una subasta desaparece entre dos escaneos
-- no se puede saber si se vendió, caducó o la retiraron (el cliente no da el
-- identificador de la subasta ni el vendedor). Solo guarda lo que es seguro:
--   snap:  foto de precio de los objetos de profesiones
--          ";itemID:mínimo:subastas:mediana:unidades;..."
--   stuck: de las subastas más baratas de cada objeto, cuántas siguen en el
--          escaneo siguiente (las que siguen no se han vendido, seguro)
--          ";itemID:siguen:baratas;..."
-- Lo usan las alertas de mercado (Market.lua) y la tendencia de precio.
--
-- ES.db.history[reino]: lista de { time, elapsed (s desde el escaneo anterior;
--   0 si no se pudo comparar), snap, stuck }
-- ES.db.track[reino]: { time, sigs } subastas del último escaneo por firma

local History = {}
ES.History = History

local HOUR = 3600
local MAX_GAP = 24 * HOUR     -- con más separación todas pudieron caducar: comparar no dice nada
local STUCK_BAND = 1.10       -- "las más baratas": hasta un 10% por encima del mínimo
-- Lo que usan las alertas y la tendencia son 7 días: guardar más solo hace
-- crecer los datos guardados (~18 KB por escaneo) y alarga la carga del juego
local HISTORY_MAX_AGE = 7 * 86400
local HISTORY_MAX = 200

-- Franjas para la tendencia de precio
History.WINDOWS = ES.Localize({
  { key = "24h", label = "24 h",   seconds = 86400 },
  { key = "3d",  label = "3 días", seconds = 3 * 86400 },
  { key = "7d",  label = "7 días", seconds = 7 * 86400 },
}, "label")

-- Solo seguimos los objetos de profesiones (materiales, fabricados, pergaminos)
-- para que los datos guardados no crezcan demasiado
local tracked

function History:IsTracked(itemID)
  if not tracked then
    tracked = {}
    for _, data in pairs(ES.Data) do
      if type(data) == "table" and data.recipes then
        for _, r in pairs(data.recipes) do
          for _, rq in ipairs(r.r) do tracked[rq[1]] = true end
          if r.out then tracked[r.out[1]] = true end
          if r.scroll then tracked[r.scroll] = true end
        end
      end
    end
  end
  return tracked[itemID]
end

-- Firma de una subasta: objeto, cantidad, precio de compra y vendedor ("?" si no se sabe)
function History.Signature(itemID, count, buyout, owner)
  return itemID .. ":" .. count .. ":" .. (buyout or 0) .. ":" .. (owner or "?")
end

-- Por cada firma guardamos cuántas subastas hay en cada categoría de tiempo
-- restante (1 corto .. 4 muy largo), empaquetado en un número: c1 + c2*1e3 + c3*1e6 + c4*1e9
local BASE = { 1, 1e3, 1e6, 1e9 }
local MAX_PER_BUCKET = 999 -- más desbordaría a la categoría siguiente

function History.AddAuction(sigs, sig, timeLeft)
  local bucket = (timeLeft >= 1 and timeLeft <= 4) and timeLeft or 1 -- desconocido: lo tratamos como corto
  local packed = sigs[sig] or 0
  local inBucket = math.floor(packed / BASE[bucket]) % 1000
  if inBucket < MAX_PER_BUCKET then
    sigs[sig] = packed + BASE[bucket]
  end
end

function History.Unpack(packed)
  local counts, total = {}, 0
  for b = 4, 1, -1 do
    counts[b] = math.floor(packed / BASE[b])
    packed = packed - counts[b] * BASE[b]
    total = total + counts[b]
  end
  return counts, total
end

-- Entradas del historial de un reino (de la más antigua a la más nueva)
function History:Entries(key)
  key = key or ES:RealmKey()
  ES.db.history = ES.db.history or {}
  local history = ES.db.history[key]
  if not history then
    history = {}
    ES.db.history[key] = history
  end
  if not ES.db.historyCleaned then
    -- Versiones anteriores estimaban ventas: se borran esos datos (no eran fiables)
    for _, h in pairs(ES.db.history) do
      for _, e in ipairs(h) do e.sold, e.cancelled, e.expired, e.bulk, e.v = nil, nil, nil, nil, nil end
    end
    ES.db.sales = nil
    ES.db.historyCleaned = true
  end
  return history
end

local function Prune(history, now)
  while #history > 0 and (now - history[1].time > HISTORY_MAX_AGE or #history > HISTORY_MAX) do
    table.remove(history, 1)
  end
end

-- Guarda un escaneo. sigs: [firma] = subastas por categoría de tiempo restante
-- (ver AddAuction); snap: foto de precios. Devuelve los segundos desde el
-- escaneo anterior si se pudo comparar, o nil.
function History:Record(key, sigs, snap, now)
  ES.db.track = ES.db.track or {}
  local history = self:Entries(key)
  local prev = ES.db.track[key]
  ES.db.track[key] = { time = now, sigs = sigs, v = 2 }
  if prev and prev.v ~= 2 then prev = nil end -- formato antiguo: no comparable

  local entry = { time = now, elapsed = 0, snap = snap }
  local elapsed = prev and (now - prev.time) or 0
  if prev and elapsed > 0 and elapsed <= MAX_GAP then
    -- Precio por unidad más barato de cada objeto en el escaneo anterior
    local minUnit = {}
    for sig in pairs(prev.sigs) do
      local item, count, buyout = sig:match("^(%d+):(%d+):(%d+):")
      count, buyout = tonumber(count), tonumber(buyout)
      if buyout > 0 and count > 0 and (not minUnit[item] or buyout / count < minUnit[item]) then
        minUnit[item] = buyout / count
      end
    end
    -- De las más baratas, cuántas siguen. Las que siguen no se han vendido; las
    -- que faltan pudieron venderse, caducar o retirarse (no se cuentan como nada)
    local rem, tot = {}, {}
    for sig, packed in pairs(prev.sigs) do
      local item, count, buyout = sig:match("^(%d+):(%d+):(%d+):")
      count, buyout = tonumber(count), tonumber(buyout)
      if buyout > 0 and count > 0 and buyout / count <= minUnit[item] * STUCK_BAND then
        local prevCounts, prevTotal = History.Unpack(packed)
        local remaining = 0
        if sigs[sig] then
          -- Descontar las nuevas con la misma firma: sobran en total o en "muy
          -- largo" (el tiempo restante nunca sube)
          local nowCounts, nowTotal = History.Unpack(sigs[sig])
          local new = math.max(0, nowTotal - prevTotal, nowCounts[4] - prevCounts[4])
          remaining = math.min(prevTotal, nowTotal - new)
        end
        tot[item] = (tot[item] or 0) + prevTotal
        rem[item] = (rem[item] or 0) + remaining
      end
    end
    local parts = {}
    for item, n in pairs(tot) do parts[#parts + 1] = item .. ":" .. rem[item] .. ":" .. n end
    entry.stuck = ";" .. table.concat(parts, ";")
    entry.elapsed = elapsed
  end

  history[#history + 1] = entry
  Prune(history, now)
  return entry.elapsed > 0 and elapsed or nil
end

-- Escaneos guardados, comparaciones hechas y hora del primero
function History:Summary()
  local history = self:Entries()
  local comparisons = 0
  for _, entry in ipairs(history) do
    if entry.elapsed and entry.elapsed > 0 then comparisons = comparisons + 1 end
  end
  return #history, comparisons, history[1] and history[1].time
end

-- Precio de referencia (mediana; el mínimo en fotos antiguas sin mediana) y
-- subastas de un objeto en el escaneo más antiguo de la ventana
function History:OldestSnapshot(itemID, window)
  local now = time()
  local needle = ";" .. itemID .. ":(%d+):(%d+):?(%d*)" -- id:mín:subastas[:mediana[:unidades]]
  for _, entry in ipairs(self:Entries()) do
    if entry.snap and now - entry.time < window then
      local m, l, med = entry.snap:match(needle)
      if m then return tonumber(med) or tonumber(m), tonumber(l), entry.time end
    end
  end
  return nil
end

-- Evolución de un objeto: { {time, median, listings, quantity}, ... }
-- (las fotos antiguas no tienen mediana: se usa el mínimo; ni unidades: nil)
function History:PriceHistory(itemID, window)
  local now = time()
  local needle = ";" .. itemID .. ":(%d+):(%d+):?(%d*):?(%d*)"
  local points = {}
  for _, entry in ipairs(self:Entries()) do
    if entry.snap and now - entry.time < (window or HISTORY_MAX_AGE) then
      local m, l, med, q = entry.snap:match(needle)
      if m then
        points[#points + 1] = { time = entry.time, median = tonumber(med) or tonumber(m),
          listings = tonumber(l), quantity = tonumber(q) }
      end
    end
  end
  return points
end

---------------------------------------------------------------------------
-- Señales de riesgo de un precio (sin necesidad de historial)
---------------------------------------------------------------------------
local GetItemInfoCompat = (C_Item and C_Item.GetItemInfo) or GetItemInfo

-- Lo que paga el vendedor: lo visto al vender en el juego (Ledger.lua); si no, lo que
-- dice el juego ahora (siempre al día: Forever cambia precios, Bronze Dory pasó de
-- 32s 53c a 4s 88c); si el juego aún no ha cargado el objeto, se le pide y mientras
-- vale el de los datos (puede ser de una versión anterior de Forever)
function ES:VendorSellPrice(itemID)
  local seen = ES.db and ES.db.sellSeen and ES.db.sellSeen[itemID]
  if seen then return seen.price end
  local live = select(11, GetItemInfoCompat(itemID))
  if live then return live end
  if C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, itemID) end
  return ES.Data.SellPrices[itemID]
end

-- ¿El precio de venta es el de ahora (visto al vender o dado por el juego)? Si no, es
-- el de los datos y la ruta se recalcula cuando el juego cargue el objeto
function ES:SellPriceIsLive(itemID)
  if ES.db and ES.db.sellSeen and ES.db.sellSeen[itemID] then return true end
  return select(11, GetItemInfoCompat(itemID)) ~= nil
end

-- Devuelve un texto con los motivos si el precio de la AH parece poco fiable
function ES:PriceRisk(itemID, entry)
  if not entry or not entry.minUnit then return nil end
  local reasons = {}
  if (entry.listings or 0) >= 5 and entry.topShare and entry.topShare >= 0.6 then
    reasons[#reasons + 1] = string.format(L["un vendedor tiene el %d%% de las subastas"], math.floor(entry.topShare * 100 + 0.5))
  end
  local vendor = self:VendorSellPrice(itemID)
  if vendor and vendor > 0 and entry.minUnit > 5 * vendor then
    reasons[#reasons + 1] = string.format(L["se pide %dx su precio de vendedor"], math.floor(entry.minUnit / vendor))
  end
  if #reasons == 0 then return nil end
  return table.concat(reasons, "; ")
end

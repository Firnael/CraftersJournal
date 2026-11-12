local _, ES = ...
local L = ES.L

-- Escaneo completo de la AH. Soporta dos APIs:
--  * Clásica: QueryAuctionItems(getAll) + AUCTION_ITEM_LIST_UPDATE
--  * Moderna: C_AuctionHouse.ReplicateItems + REPLICATE_ITEM_LIST_UPDATE
-- Ambas devuelven los mismos campos en el mismo orden por subasta.

local Scanner = { state = "idle" }
ES.Scanner = Scanner

local BATCH_SIZE = 300   -- sin debugprofilestop: subastas por fotograma
local FRAME_BUDGET = 12  -- ms por fotograma procesando (~60 fps se mantiene jugable)
-- s esperando al servidor; si no responde, se abandona. Con 60 s, en los días de
-- lanzamiento (reinos llenos) se abandonaban escaneos que el servidor sí iba a mandar
local TIMEOUT = 120
-- s que el número de subastas debe quedarse quieto para darlas por recibidas: el
-- servidor las manda por tandas (un escaneo se quedó en 1024 justas con 2 s)
local STABLE_SECONDS = 4
local SERVER_LIMIT = 15 * 60

-- Límite del servidor: el de Forever no responde a un escaneo completo si el
-- anterior fue hace menos de 15 min, aunque el cliente diga que se puede. Así que
-- se cuentan 15 min desde cada petición y el botón muestra la cuenta atrás: mejor
-- esperar viendo el tiempo que pulsar y que no pase nada.
-- El límite es de la CUENTA, no del personaje: un escaneo con un personaje (o el de
-- otro addon, como el automático de ForeverForge_Auction) gasta el de todos.
-- CraftersJournalDB.lastFullScan[personaje u "otro addon"] = hora de la última petición;
-- cuenta la más reciente de todas.
local OTHER_ADDON = "otro addon"
local function LastFullScan()
  if type(ES.db.lastFullScan) ~= "table" then ES.db.lastFullScan = {} end
  return ES.db.lastFullScan
end

local function LastRequest()
  local last
  for _, t in pairs(LastFullScan()) do
    if type(t) == "number" and (not last or t > last) then last = t end
  end
  return last
end

function Scanner:SecondsUntilNextScan()
  if not ES.db then return 0 end
  local last = LastRequest()
  return last and math.max(0, SERVER_LIMIT - (time() - last)) or 0
end

local frame = CreateFrame("Frame")

local function UseLegacyAPI()
  return QueryAuctionItems ~= nil
end

local function SetStatus(text)
  if text ~= Scanner.statusText and not text:find("%d+ / %d+") and not text:find("%d+ s") then
    ES:ScanLog("estado: " .. text) -- sin el contador de cada segundo
  end
  Scanner.statusText = text
end

function Scanner:IsBusy()
  return self.state ~= "idle"
end

-- Progreso del escaneo (0-1) para el botón de la cabecera: al pedir los datos,
-- WAIT_PROGRESS; al procesarlos, de ahí al 100% según las subastas leídas
local WAIT_PROGRESS = 0.05
local function SetProgress(p)
  Scanner.progress = p
  if ES.OnScanProgress then ES:OnScanProgress(p) end
end

-- Silencia a otros frames (la UI de Blizzard, otros addons) mientras llega el
-- getAll: intentar pintar decenas de miles de subastas congela el juego.
function Scanner:MuteOthers(event)
  self.muted = { GetFramesRegisteredForEvent(event) }
  self.mutedEvent = event
  for _, f in ipairs(self.muted) do
    if f ~= frame then f:UnregisterEvent(event) end
  end
end

function Scanner:UnmuteOthers()
  if not self.muted then return end
  for _, f in ipairs(self.muted) do
    if f ~= frame then f:RegisterEvent(self.mutedEvent) end
  end
  self.muted, self.mutedEvent = nil, nil
end

function Scanner:Start()
  if self:IsBusy() then
    ES:Print(L["Ya hay un escaneo en curso."])
    return
  end
  if not ES:IsAuctionHouseOpen() then
    ES:Print(L["Abre la Casa de Subastas para analizarla."])
    return
  end

  -- No pedir lo que el servidor no va a contestar
  local wait = self:SecondsUntilNextScan()
  if wait > 0 then
    local msg = string.format(L["El servidor solo permite un escaneo completo cada 15 min: podrás volver a escanear en %s."], ES.Countdown(wait))
    ES:Print(msg)
    SetStatus(msg)
    return
  end

  local api
  if UseLegacyAPI() then
    local _, canGetAll = CanSendAuctionQuery()
    if not canGetAll then
      local msg = L["El servidor aún no permite un escaneo completo (quizá otro addon escaneó hace poco). Inténtalo más tarde."]
      ES:Print(msg)
      SetStatus(msg)
      return
    end
    api = "legacy"
  elseif C_AuctionHouse and C_AuctionHouse.ReplicateItems then
    api = "modern"
  else
    ES:Print(L["No se encontró ninguna API de subastas compatible en este cliente."])
    return
  end
  self:Begin(api, false)
end

-- Empieza a esperar los datos. Con `piggyback`, la petición la hizo otro addon: no se
-- vuelve a pedir (el servidor no contestaría) y se leen los mismos datos que le llegan
function Scanner:Begin(api, piggyback)
  self.api = api
  self.event = api == "legacy" and "AUCTION_ITEM_LIST_UPDATE" or "REPLICATE_ITEM_LIST_UPDATE"
  self.piggyback = piggyback

  ES:ScanLog((piggyback and "aprovechando el escaneo de otro addon" or "pedido") .. ", API " .. self.api)
  self.state = "waiting"
  self.scanID = (self.scanID or 0) + 1
  self.key = ES:RealmKey() -- AH en la que empezó el escaneo
  self.requestTime = time()
  self.waited = 0
  self.gotEvent = false
  -- La barrera cuenta desde la petición: el servidor la cuenta aunque no responda
  LastFullScan()[piggyback and OTHER_ADDON or ES:CharKey()] = self.requestTime

  -- Al aprovechar el de otro addon no se le silencia: necesita sus eventos
  if not piggyback then self:MuteOthers(self.event) end
  ES.SafeRegister(frame, self.event) -- si no existe, el sondeo de cada segundo detecta los datos igual
  ES:RefreshScanButtons()
  SetProgress(WAIT_PROGRESS)

  local before = self:CountResults()

  if not piggyback then
    self.ownRequest = true -- para que el gancho no lo tome por otro addon
    if self.api == "legacy" then
      -- Evita un error conocido de la UI clásica con calidad -1
      if ITEM_QUALITY_COLORS and not ITEM_QUALITY_COLORS[-1] then
        ITEM_QUALITY_COLORS[-1] = { r = 0, g = 0, b = 0 }
      end
      pcall(QueryAuctionItems, "", nil, nil, 0, nil, nil, true, false, nil)
    else
      pcall(C_AuctionHouse.ReplicateItems)
    end
    self.ownRequest = false
  end

  -- Contador visible + sondeo por si el evento no llega
  local id = self.scanID
  local started = GetTime()
  local apiName = self.api == "legacy" and L["clásica"] or L["moderna"]
  local lastCount, stableTicks, changed = before, 0, false

  local function Tick()
    if self.scanID ~= id or self.state ~= "waiting" then return end
    local elapsed = math.floor(GetTime() - started)

    local count = self:CountResults()
    -- Llegan datos: cambió el número, o llegó el evento (con la API clásica el número
    -- puede ser el mismo que el del escaneo anterior)
    -- (una vez cambiado, sigue contando aunque vuelva al número de antes: el nuevo
    -- escaneo puede acabar con las mismas subastas que el anterior)
    changed = changed or count ~= before
    local arriving = count > 0 and (changed or self.gotEvent)
    if elapsed >= TIMEOUT and not arriving then
      if self.piggyback then
        -- El servidor no contestó al otro addon: no es un fallo nuestro
        self:Abort(nil, true)
        return
      end
      -- Sin respuesta (p. ej. otro addon escaneó hace poco): se abandona y la
      -- cuenta atrás de 15 min ya corre desde esta petición
      self:Abort(string.format(L["El servidor no respondió: solo permite un escaneo completo cada 15 min. Podrás volver a escanear en %s."],
        ES.Countdown(self:SecondsUntilNextScan())))
      return
    end
    self.waited = elapsed
    SetProgress(WAIT_PROGRESS) -- el botón muestra los segundos de espera

    -- Si el número de resultados cambió y se mantiene estable STABLE_SECONDS, procesamos
    -- (el evento no basta: llega con la primera tanda, y en Forever a veces ni llega)
    if arriving then
      if count == lastCount then
        stableTicks = stableTicks + 1
        if stableTicks >= STABLE_SECONDS then
          self:Process()
          return
        end
      else
        ES:ScanLog(string.format("llegando: %d subastas", count))
        stableTicks = 0
      end
    end
    lastCount = count

    SetStatus(string.format(self.piggyback
      and L["Leyendo el escaneo que pidió otro addon... %d s (API %s, /es cancel para cancelar)"]
      or L["Pidiendo los datos de la AH al servidor... %d s (API %s, /es cancel para cancelar)"], elapsed, apiName))
    C_Timer.After(1, Tick)
  end
  Tick()
end

function Scanner:CountResults()
  if self.api == "legacy" then
    return (GetNumAuctionItems("list")) or 0
  end
  return C_AuctionHouse.GetNumReplicateItems() or 0
end

-- `quiet`: sin aviso ni marca de fallo (el escaneo de otro addon que no llegó)
function Scanner:Abort(reason, quiet)
  if not self:IsBusy() then return end
  frame:UnregisterAllEvents()
  self:UnmuteOthers()
  self.state = "idle"
  self.scanID = (self.scanID or 0) + 1 -- invalida lotes pendientes
  if quiet then
    ES:ScanLog("el escaneo de otro addon no llegó")
    SetStatus(L["El servidor no respondió al escaneo de otro addon."])
    ES:RefreshScanButtons()
    return
  end
  -- Para avisar junto a "Último escaneo" de que el último intento no acabó
  -- (si no, "hace 2 días" parece un fallo al guardar)
  if type(ES.db.lastScanFail) ~= "table" then ES.db.lastScanFail = {} end
  ES.db.lastScanFail[self.key or ES:RealmKey()] = { time = time(), reason = reason }
  if reason then
    ES:Print(reason)
    SetStatus(reason)
  end
  ES:RefreshScanButtons()
end

function Scanner:ReadAuction(index)
  if self.api == "legacy" then
    return GetAuctionItemInfo("list", index)
  end
  return C_AuctionHouse.GetReplicateItemInfo(index)
end

-- Categoría de tiempo restante normalizada a 1 (corto) .. 4 (muy largo)
function Scanner:ReadTimeLeft(index)
  if self.api == "legacy" then
    return GetAuctionItemTimeLeft and GetAuctionItemTimeLeft("list", index) or 0
  end
  if C_AuctionHouse.GetReplicateItemTimeLeft then
    local tl = C_AuctionHouse.GetReplicateItemTimeLeft(index)
    return tl and tl + 1 or 0
  end
  return 0
end

function Scanner:Process()
  frame:UnregisterEvent(self.event)
  self.state = "processing"

  local total, first
  if self.api == "legacy" then
    total = GetNumAuctionItems("list")
    first = 1
  else
    total = C_AuctionHouse.GetNumReplicateItems()
    first = 0
  end
  local last = first + total - 1
  ES:ScanLog(string.format("procesando %d subastas (%s)", total, self.gotEvent and "con evento" or "sin evento"))

  local items = {}
  local sigs = {}
  local id = self.scanID
  local index = first

  local function Step()
    if self.scanID ~= id then return end

    -- Por tiempo y no por número: procesa todo lo que quepa en FRAME_BUDGET ms
    -- por fotograma (en un PC rápido son miles de subastas, no 300)
    local started = debugprofilestop and debugprofilestop()
    local stop = last
    if not started then stop = math.min(index + BATCH_SIZE - 1, last) end
    local i = index
    while i <= stop do
      if started and (i - index) % 100 == 99 and debugprofilestop() - started > FRAME_BUDGET then
        stop = i
      end
      -- name, texture, count, quality, canUse, level, levelType, minBid,
      -- minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName,
      -- owner, ownerFullName, saleStatus, itemID, hasAllInfo
      local _, _, count, _, _, _, _, _, _, buyout, _, _, _, owner, _, _, itemID = self:ReadAuction(i)
      if itemID and itemID > 0 and count and count > 0 then
        local entry = items[itemID]
        if not entry then
          entry = { listings = 0, quantity = 0, buyoutQty = 0, buyoutTotal = 0, owners = {} }
          items[itemID] = entry
        end
        entry.listings = entry.listings + 1
        entry.quantity = entry.quantity + count
        local ownerKey = (owner and owner ~= "") and owner or "?"
        if ownerKey ~= "?" then
          entry.owners[ownerKey] = (entry.owners[ownerKey] or 0) + 1
          entry.knownOwners = (entry.knownOwners or 0) + 1
        end

        if ES.History:IsTracked(itemID) then
          local sig = ES.History.Signature(itemID, count, buyout, ownerKey)
          ES.History.AddAuction(sigs, sig, self:ReadTimeLeft(i))
          -- Escalera de precios: cuántas unidades hay a cada precio por unidad
          if buyout and buyout > 0 then
            entry.ladder = entry.ladder or {}
            local unit = math.floor(buyout / count + 0.5)
            entry.ladder[unit] = (entry.ladder[unit] or 0) + count
          end
        end
        if buyout and buyout > 0 then
          local unit = buyout / count
          if not entry.minUnit or unit < entry.minUnit then entry.minUnit = unit end
          entry.buyoutQty = entry.buyoutQty + count
          entry.buyoutTotal = entry.buyoutTotal + buyout
        end
      end
      i = i + 1
    end

    index = stop + 1
    SetStatus(string.format(L["Procesando subastas... %d / %d"], index - first, total))
    SetProgress(WAIT_PROGRESS + (1 - WAIT_PROGRESS) * (index - first) / math.max(1, total))

    if index > last then
      -- Si mientras se procesaba llegó otra tanda, se lee también
      local now = self:CountResults()
      if now > total then
        ES:ScanLog(string.format("llegaron más al procesar: %d -> %d", total, now))
        total = now
        last = first + total - 1
      end
    end
    if index <= last then
      C_Timer.After(0, Step)
    else
      self:Finish(items, sigs, total)
    end
  end

  Step()
end

-- { [precio] = cantidad } -> { p1, q1, p2, q2, ... } ordenado de más barato a más
-- caro, y la mediana calculada con todos los precios. Para no guardar demasiado se
-- conservan MAX_LADDER_LEVELS niveles: lo que sobra se junta en el último a su
-- precio medio, así no se pierden existencias (antes se descartaba y la mediana
-- y las unidades a la venta salían por debajo de las reales).
local MAX_LADDER_LEVELS = 40
local function BuildLadder(levels)
  if not levels then return nil end
  local prices, total = {}, 0
  for price, qty in pairs(levels) do
    prices[#prices + 1] = price
    total = total + qty
  end
  table.sort(prices)
  local median, acc = nil, 0
  for _, price in ipairs(prices) do
    acc = acc + levels[price]
    if acc >= total / 2 then median = price break end
  end
  local flat = {}
  for i = 1, math.min(#prices, MAX_LADDER_LEVELS - 1) do
    flat[#flat + 1] = prices[i]
    flat[#flat + 1] = levels[prices[i]]
  end
  if #prices >= MAX_LADDER_LEVELS then
    local qty, value = 0, 0
    for i = MAX_LADDER_LEVELS, #prices do
      qty = qty + levels[prices[i]]
      value = value + levels[prices[i]] * prices[i]
    end
    flat[#flat + 1] = math.floor(value / qty + 0.5)
    flat[#flat + 1] = qty
  end
  return flat, median
end

function Scanner:Finish(items, sigs, total)
  self:UnmuteOthers()
  self.state = "idle"

  -- Un escaneo vacío es un fallo del servidor: guardarlo borraría los precios
  -- buenos y haría creer que todo se ha vendido
  if total == 0 then
    local msg = L["El servidor devolvió 0 subastas; no se guarda este escaneo. Inténtalo más tarde."]
    ES:Print(msg)
    SetStatus(msg)
    ES:RefreshScanButtons()
    return
  end

  local saved = {}
  local unique = 0
  for itemID, e in pairs(items) do
    unique = unique + 1
    local sellers, top = 0, 0
    for _, n in pairs(e.owners) do
      sellers = sellers + 1
      if n > top then top = n end
    end
    local ladder, median = BuildLadder(e.ladder)
    saved[itemID] = {
      listings = e.listings,
      quantity = e.quantity,
      minUnit = e.minUnit and math.floor(e.minUnit + 0.5) or nil,
      avgUnit = e.buyoutQty > 0 and math.floor(e.buyoutTotal / e.buyoutQty + 0.5) or nil,
      sellers = sellers > 0 and sellers or nil,
      -- Solo fiable si conocemos el vendedor de al menos la mitad de las subastas
      topShare = (e.knownOwners or 0) * 2 >= e.listings
        and math.floor(top / e.knownOwners * 100 + 0.5) / 100 or nil,
      ladder = ladder,
      median = median,
    }
  end

  local now = time()
  local key = self.key or ES:RealmKey()
  local knownOwners = 0
  for _, e in pairs(items) do knownOwners = knownOwners + (e.knownOwners or 0) end
  local scan = { time = now, total = total, unique = unique, items = saved,
    ownerPct = total > 0 and math.floor(knownOwners / total * 100 + 0.5) or 0 }
  ES.db.scans[key] = scan

  -- Foto compacta de los objetos de profesiones para el historial:
  -- itemID:mínimo:subastas:mediana:unidades a la venta
  local snap = {}
  for itemID, e in pairs(saved) do
    if e.minUnit and ES.History:IsTracked(itemID) then
      snap[#snap + 1] = itemID .. ":" .. e.minUnit .. ":" .. e.listings .. ":" .. (e.median or e.minUnit) .. ":" .. e.quantity
    end
  end
  ES.History:Record(key, sigs, ";" .. table.concat(snap, ";"), now)
  local scans = ES.History:Summary()

  local msg = string.format(L["Escaneo completado: %d subastas, %d objetos distintos."], total, unique)
  if scans < 3 then
    msg = msg .. L[" Las alertas de mercado necesitan unos días de escaneos: con 1-2 al día basta."]
  end
  ES:Print(msg)
  SetStatus(msg)
  ES:RefreshScanButtons()
  ES:OnScanComplete(scan)
end

-- Otro addon (ForeverForge_Auction escanea solo al abrir la AH, Auctionator, TSM...)
-- pide un escaneo completo: gasta los 15 min de la cuenta. Se anota la barrera y, con
-- la AH abierta, se leen esos mismos datos en vez de pedirlos y esperar 2 min en vano.
function Scanner:OnForeignScan(api)
  if self.ownRequest or not ES.db then return end
  LastFullScan()[OTHER_ADDON] = time()
  ES:ScanLog("otro addon pidió un escaneo completo (API " .. api .. ")")
  if self:IsBusy() or not ES:IsAuctionHouseOpen() then
    ES:RefreshScanButtons()
    return
  end
  self:Begin(api, true)
end

-- Ganchos sobre las dos APIs (se rehacen si algo cambia la función por otra)
function Scanner:InstallHooks()
  if not hooksecurefunc then return end
  if C_AuctionHouse and C_AuctionHouse.ReplicateItems and C_AuctionHouse.ReplicateItems ~= self.hookedReplicate then
    hooksecurefunc(C_AuctionHouse, "ReplicateItems", function() Scanner:OnForeignScan("modern") end)
    self.hookedReplicate = C_AuctionHouse.ReplicateItems
  end
  if QueryAuctionItems and QueryAuctionItems ~= self.hookedQuery then
    hooksecurefunc("QueryAuctionItems", function(_, _, _, _, _, _, getAll)
      if getAll then Scanner:OnForeignScan("legacy") end
    end)
    self.hookedQuery = QueryAuctionItems
  end
end
pcall(Scanner.InstallHooks, Scanner)

frame:SetScript("OnEvent", function(_, event)
  -- Solo se anota: procesar aquí cogía solo la primera tanda; el sondeo de cada
  -- segundo procesa cuando el número de subastas deja de crecer
  if event == Scanner.event and Scanner.state == "waiting" and not Scanner.gotEvent then
    Scanner.gotEvent = true
    ES:ScanLog(string.format("evento %s: %d subastas", event, Scanner:CountResults()))
  end
end)

local ADDON_NAME, ES = ...
local L = ES.L
_G.CraftersJournal = ES

ES.ICON = "Interface\\Icons\\Trade_BlackSmithing" -- martillo y yunque: profesiones (minimapa y lista de addons)
ES.ahOpen = false

-- Modo desarrollo: lo que aún no está listo para los jugadores (pestañas Ganar
-- dinero y Subastas, la Pesca y el buscador de la cabecera).
--   ES.DEV_BUILD: copia de desarrollo (el repositorio). El empaquetador de CurseForge
--     comenta el bloque @debug@ al publicar: en la versión descargada es false.
--   ES.DEV: si se ve lo de desarrollo. En la copia de desarrollo hay un interruptor
--     en la cabecera ("Vista de jugador") para ver el addon como lo verán los demás.
ES.DEV_BUILD = false
--@debug@
ES.DEV_BUILD = true
--@end-debug@
ES.DEV = ES.DEV_BUILD

-- Pasar de modo desarrollo a vista de jugador (y vuelta); solo en la copia de desarrollo
function ES:SetUserPreview(on)
  if not self.DEV_BUILD then return end
  self.db.userPreview = on or nil
  self.DEV = not on
  if self.ClearHomeCache then self:ClearHomeCache() end
  if self.RebuildMainFrame then self:RebuildMainFrame() end
end

-- AH abierta: por el evento o porque su ventana está a la vista (si el evento se
-- pierde, el botón de escanear no debe quedarse en gris con la AH delante)
-- El cliente puede tener las dos ventanas (moderna y clásica): vale cualquiera
local function AHFrameShown()
  for _, f in ipairs({ AuctionHouseFrame or false, AuctionFrame or false }) do
    if f and f.IsShown and f:IsShown() then return true end
  end
  return false
end

function ES:IsAuctionHouseOpen()
  if self.ahOpen then return true end
  if AHFrameShown() then
    self.ahOpen = true
    return true
  end
  return false
end

-- Recetas que solo puede aprender el otro bando (p. ej. el estandarte de facción):
-- fuera de los datos, así no salen en la colección, las rutas ni los contadores
function ES:DropOtherFactionRecipes()
  local mine = UnitFactionGroup and UnitFactionGroup("player")
  if mine ~= "Alliance" and mine ~= "Horde" then return end
  for _, prof in ipairs(self.PROFESSIONS) do
    local data = self.Data[prof.key]
    for id, r in pairs(data and data.recipes or {}) do
      if r.faction and r.faction ~= mine then data.recipes[id] = nil end
    end
  end
end

-- Icono de misión ("!" amarillo): el atlas en alta resolución del cliente si lo
-- tiene; si no, la textura clásica (pixelada a tamaño grande)
local QUEST_ATLAS, QUEST_TEXTURE = "QuestNormal", "Interface\\GossipFrame\\AvailableQuestIcon"
local function HasAtlas(name)
  return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name) ~= nil
end
-- Para el texto: |A...|a o |T...|t
function ES.QuestIconMarkup(size)
  if HasAtlas(QUEST_ATLAS) then return string.format("|A:%s:%d:%d|a", QUEST_ATLAS, size, size) end
  return string.format("|T%s:%d|t", QUEST_TEXTURE, size)
end
-- Para una textura
function ES.SetQuestIcon(tex)
  if HasAtlas(QUEST_ATLAS) and tex.SetAtlas then tex:SetAtlas(QUEST_ATLAS) else tex:SetTexture(QUEST_TEXTURE) end
end
-- Las filas aceptan icon = ES.QUEST_ICON y lo pintan con ES.SetQuestIcon
ES.QUEST_ICON = "quest"

-- Diario del escaneo en CraftersJournalDB.scanLog (últimas 40 entradas): qué eventos
-- de la AH llegaron y cómo acabó cada escaneo. Para diagnosticar fallos en el juego.
function ES:ScanLog(text)
  if not self.db then return end
  if type(self.db.scanLog) ~= "table" then self.db.scanLog = {} end
  local log = self.db.scanLog
  log[#log + 1] = (date and date("%H:%M:%S") or tostring(time())) .. " " .. text
  while #log > 40 do table.remove(log, 1) end
end

-- Nivel máximo de las profesiones (Artesano): los planes llegan hasta aquí
ES.MAX_SKILL = 300

-- Profesiones de fabricación (tarjetas de la portada). `key` es el nombre de su
-- tabla en ES.Data; `icon`, su imagen en el juego.
-- El orden de esta lista es el orden interno de las tarjetas (la portada y
-- Patterns, ver ES.SortProfessionCards): las principales y, al final, las
-- secundarias (Cocina, Primeros auxilios, Pesca)
local ICONS = "Interface\\Icons\\"
ES.PROFESSIONS = {
  { key = "Alchemy",        label = "Alquimia",      icon = ICONS .. "Trade_Alchemy" },
  { key = "Blacksmithing",  label = "Herrería",      icon = ICONS .. "Trade_BlackSmithing" },
  { key = "Enchanting",     label = "Encantam.",     icon = ICONS .. "Trade_Engraving", name = "Encantamiento" },
  { key = "Engineering",    label = "Ingeniería",    icon = ICONS .. "Trade_Engineering" },
  { key = "Leatherworking", label = "Peletería",     icon = ICONS .. "INV_Misc_ArmorKit_17" },
  { key = "Tailoring",      label = "Sastrería",     icon = ICONS .. "Trade_Tailoring" },
  -- Secundarias
  { key = "Cooking",        label = "Cocina",        icon = ICONS .. "INV_Misc_Food_15" },
  { key = "FirstAid",       label = "Primeros aux.", icon = ICONS .. "Spell_Holy_SealOfSacrifice", name = "Primeros auxilios" },
  { key = "Fishing",        label = "Pesca",         icon = ICONS .. "Trade_Fishing", dev = true }, -- solo en desarrollo
}

-- Orden de las tarjetas de profesión (la portada y Patterns): primero las que
-- tiene el personaje y luego las demás; dentro de cada sección, el orden de
-- ES.PROFESSIONS. entries = { { learned, order } } (order: su posición en la lista)
function ES.SortProfessionCards(entries)
  table.sort(entries, function(a, b)
    if a.learned ~= b.learned then return a.learned end
    return a.order < b.order
  end)
end

-- ¿Se ve esta profesión? (las marcadas dev = true, solo en modo desarrollo)
function ES:ProfessionVisible(prof)
  return not prof.dev or self.DEV
end

function ES:ProfLabel(key)
  for _, p in ipairs(self.PROFESSIONS) do
    if p.key == key then return L[p.name or p.label] end
  end
  return key
end

local DEFAULTS = {
  minimap = { angle = 225, hide = false },
  scans = {},
}

-- Números para mostrar en español: coma decimal ("2,5"), sin decimales a
-- partir de 10 ("15", no "14.7", que en español parece catorce mil)
function ES.Num(x)
  if not x then return "—" end
  if math.abs(x) >= 10 then return tostring(math.floor(x + 0.5)) end
  local s = string.format("%.1f", x):gsub("%.0$", "")
  if ES.lang == "es" then s = s:gsub("%.", ",") end -- en inglés, punto decimal
  return s
end

function ES:Print(msg)
  print("|cff33ccffCrafter's Journal|r: " .. tostring(msg))
end

-- Clave por reino + casa de subastas: la de tu facción y la neutral (goblins de
-- Bahía del Botín, Gadgetzan, Vista Eterna) tienen subastas distintas.
local function FactionKey()
  return (GetRealmName() or "?") .. "-" .. (UnitFactionGroup("player") or "?")
end

-- La última AH que abrió este personaje (la de su facción si nunca abrió la neutral)
function ES:RealmKey()
  local saved = self.db and self.db.activeAH and self.db.activeAH[self:CharKey()]
  return saved or FactionKey()
end

-- Al abrir la AH: el subastador neutral no es de ninguna de las dos facciones
local function DetectAuctionHouse()
  local npcFaction = UnitFactionGroup("npc")
  local neutral = UnitExists("npc") and npcFaction ~= "Alliance" and npcFaction ~= "Horde"
  local key = neutral and ((GetRealmName() or "?") .. "-Neutral") or FactionKey()
  if type(ES.db.activeAH) ~= "table" then ES.db.activeAH = {} end
  local char = ES:CharKey()
  if ES:RealmKey() ~= key then
    ES:Print(neutral and L["Casa de Subastas neutral: sus datos se guardan aparte de los de tu facción."]
      or L["Casa de Subastas de tu facción."])
  end
  ES.db.activeAH[char] = key
end

-- Personaje actual ("Nombre-Reino"): buzón, recetas sabidas, AH activa
function ES:CharKey()
  return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
end

local function ApplyDefaults(db, defaults)
  for k, v in pairs(defaults) do
    if type(v) == "table" then
      if type(db[k]) ~= "table" then db[k] = {} end
      ApplyDefaults(db[k], v)
    elseif db[k] == nil then
      db[k] = v
    end
  end
end

-- Helpers de objetos compatibles con API antigua y moderna
local GetItemInfoCompat = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local GetItemInfoInstantCompat = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant

-- Nombre de un objeto en el idioma del addon según los datos propios: español
-- (Data/Names_esES.lua) o inglés (ES.Data.ItemNames); nil si no lo tenemos
function ES:DataItemName(itemID)
  if self.lang == "es" then
    local es = ES.Data.NamesES and ES.Data.NamesES.items[itemID]
    if es then return es end
  end
  return ES.Data.ItemNames and ES.Data.ItemNames[itemID] -- en español, si no cambia, es igual que en inglés
end

-- Datos de un objeto. El nombre que da el juego va en el idioma del cliente: si el
-- addon está en otro idioma, se usa el de los datos propios (si lo tenemos)
function ES:GetItemData(itemID)
  local name, _, quality, _, _, _, _, _, _, texture = GetItemInfoCompat(itemID)
  if not texture and GetItemInfoInstantCompat then
    texture = select(5, GetItemInfoInstantCompat(itemID))
  end
  if name and self.lang ~= ES.DefaultLanguage() then name = self:DataItemName(itemID) or name end
  return name, quality, texture
end

-- Recetas con el nombre en el idioma del addon: en español, el de Data/Names_esES.lua;
-- en inglés, el original (guardado en nameEN, que también usa el buscador)
function ES:LocalizeRecipeNames()
  local names = ES.Data.NamesES and ES.Data.NamesES.spells or {}
  for _, prof in ipairs(self.PROFESSIONS) do
    for id, r in pairs(ES.Data[prof.key] and ES.Data[prof.key].recipes or {}) do
      if self.lang == "es" and names[id] then
        r.nameEN = r.nameEN or r.name
        r.name = names[id]
      elseif r.nameEN then
        r.name = r.nameEN
      end
    end
  end
end

-- Cuántas unidades tienes de cada material de una profesión. Solo las bolsas: el
-- banco (y el correo) no se cuentan, lo que no llevas encima no se puede usar ya
-- y solo daba malentendidos ("tienes 88" con las chatarras ya convertidas)
-- Unidades de un objeto en las bolsas
function ES:ItemCount(itemID)
  local get = (C_Item and C_Item.GetItemCount) or GetItemCount
  return get and (get(itemID, false) or 0) or 0
end

-- ¿El personaje ya sabe esta receta? (las recetas son hechizos del libro de hechizos)
function ES:IsRecipeKnown(spellID)
  if not spellID or spellID <= 0 then return false end
  if C_SpellBook and C_SpellBook.IsSpellKnown then
    local ok, known = pcall(C_SpellBook.IsSpellKnown, spellID)
    if ok and known then return true end
  end
  if IsPlayerSpell then
    local ok, known = pcall(IsPlayerSpell, spellID)
    if ok and known then return true end
  end
  return false
end

---------------------------------------------------------------------------
-- Reputación (recetas que piden un nivel con una facción: rep = { facción, nivel })
---------------------------------------------------------------------------
-- Nombres por si el juego aún no conoce la facción (no la has descubierto)
local FACTION_NAMES = ES.Localize({
  [59] = "Hermandad del Torio", [270] = "Tribu Zandalar", [529] = "El Alba Argenta",
  [576] = "Bastión Fauces de Madera", [609] = "Círculo Cenarion", [749] = "Srs. del Agua de Hydraxis",
})

-- Nivel actual con la facción (1 odiado ... 4 neutral ... 8 exaltado); neutral si no la conoces
function ES:Standing(factionID)
  if C_Reputation and C_Reputation.GetFactionDataByID then
    local ok, data = pcall(C_Reputation.GetFactionDataByID, factionID)
    if ok and data and data.reaction then return data.reaction, data.name end
  end
  if GetFactionInfoByID then
    local ok, name, _, standing = pcall(GetFactionInfoByID, factionID)
    if ok and standing then return standing, name end
  end
  return 4, nil
end

function ES:FactionName(factionID)
  local _, name = self:Standing(factionID)
  return name or FACTION_NAMES[factionID] or (L["facción "] .. factionID)
end

function ES.StandingName(standing)
  return _G["FACTION_STANDING_LABEL" .. standing] or (L["nivel "] .. standing)
end

-- ¿Tienes la reputación que pide? (sin requisito, sí)
function ES:RepMet(rep)
  return not rep or (self:Standing(rep[1])) >= rep[2]
end

-- Firma de tus niveles con las facciones que piden recetas: cambia solo al subir
-- de nivel (UPDATE_FACTION salta con cada punto de reputación)
function ES:RepStamp()
  if not self.repFactions then
    self.repFactions = {}
    local seen = {}
    for _, data in pairs(ES.Data) do
      if type(data) == "table" and data.recipes then
        for _, r in pairs(data.recipes) do
          if r.rep and not seen[r.rep[1]] then
            seen[r.rep[1]] = true
            self.repFactions[#self.repFactions + 1] = r.rep[1]
          end
        end
      end
    end
    table.sort(self.repFactions)
  end
  local parts = {}
  for i, f in ipairs(self.repFactions) do parts[i] = (self:Standing(f)) end
  return table.concat(parts, ",")
end

function ES:GetOwnedReagents(data)
  local owned, seen = {}, {}
  for _, r in pairs(data.recipes) do
    for _, rq in ipairs(r.r) do
      local itemID = rq[1]
      if not seen[itemID] then
        seen[itemID] = true
        local count = ES:ItemCount(itemID)
        if count and count > 0 then owned[itemID] = count end
      end
    end
  end
  -- Herramientas (bastones rúnicos)
  for _, tool in pairs(ES.Data.Tools or {}) do
    local count = ES:ItemCount(tool.item)
    if count and count > 0 then owned[tool.item] = count end
  end
  return owned
end

---------------------------------------------------------------------------
-- Botón del minimapa
---------------------------------------------------------------------------
local function UpdateMinimapPosition(button)
  local angle = math.rad(ES.db.minimap.angle)
  local radius = (Minimap:GetWidth() / 2) + 5
  button:ClearAllPoints()
  button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function CreateMinimapButton()
  local b = CreateFrame("Button", "CraftersJournalMinimapButton", Minimap)
  b:SetSize(31, 31)
  b:SetFrameStrata("MEDIUM")
  b:SetFrameLevel(8)
  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  b:RegisterForDrag("LeftButton")
  b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  local bg = b:CreateTexture(nil, "BACKGROUND")
  bg:SetSize(20, 20)
  bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  bg:SetPoint("TOPLEFT", 7, -5)

  local icon = b:CreateTexture(nil, "ARTWORK")
  icon:SetSize(17, 17)
  icon:SetTexture(ES.ICON)
  icon:SetPoint("TOPLEFT", 7, -6)

  local border = b:CreateTexture(nil, "OVERLAY")
  border:SetSize(53, 53)
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetPoint("TOPLEFT")

  b:SetScript("OnClick", function() ES:ToggleMainFrame() end)

  b:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
      local mx, my = Minimap:GetCenter()
      local px, py = GetCursorPosition()
      local scale = Minimap:GetEffectiveScale()
      px, py = px / scale, py / scale
      ES.db.minimap.angle = math.deg(math.atan2(py - my, px - mx))
      UpdateMinimapPosition(self)
    end)
  end)
  b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

  b:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Crafter's Journal")
    GameTooltip:AddLine(L["Clic: abrir/cerrar panel"], 1, 1, 1)
    GameTooltip:AddLine(L["Arrastrar: mover botón"], 1, 1, 1)
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function() GameTooltip:Hide() end)

  UpdateMinimapPosition(b)
  if ES.db.minimap.hide then b:Hide() end
  ES.minimapButton = b
end

-- Recalcula todos los apartados que dependen de los datos de la AH activa (tras
-- un escaneo o al cambiar de AH). Lo que no está a la vista se recalcula al mostrarse.
function ES:RefreshAllViews()
  if self.RenderResults then self:RenderResults() end          -- Subastas
  if self.ClearHomeCache then self:ClearHomeCache() end        -- precios nuevos: planes de las tarjetas
  if self.RenderHome then self:RenderHome() end                -- portada (tarjetas)
  if self.RefreshProfessionPages then self:RefreshProfessionPages() end -- planes de cada profesión
  if self.Earn then self.Earn:Clear() end                       -- Ganar dinero
  if self.RenderEarn then self:RenderEarn() end
  if self.RenderInventory then self:RenderInventory() end      -- Inventario
  if self.RenderFlipping then self:RenderFlipping() end        -- Flipping
  if self.RefreshPatternPages then self:RefreshPatternPages() end -- Colección de recetas
  if self.RenderCalculator then self:RenderCalculator() end    -- Calculadora (sus precios salen del escaneo)
  if self.RenderShopping then self:RenderShopping() end        -- Lista de compra
end

-- Menú de addons del minimapa (compartment)
function CraftersJournal_OnAddonCompartmentClick()
  ES:ToggleMainFrame()
end

---------------------------------------------------------------------------
-- Eventos
---------------------------------------------------------------------------
local events = CreateFrame("Frame")
-- Registro protegido: si un evento no existe en este cliente, no rompe la carga del addon
function ES.SafeRegister(frame, event)
  local ok = pcall(frame.RegisterEvent, frame, event)
  return ok
end
-- Lo de cada personaje: las rutas empezadas, los ajustes de cada profesión (objetivo,
-- opciones, recetas quitadas) y la última profesión vista. Se guarda en
-- ES.db.characters[GUID del personaje]; mientras juegas, ES.db.prof y ES.db.lastProf
-- son los suyos. Así otro personaje no ve tu ruta, y al volver con este la recuperas.
-- Por GUID y no por "nombre-reino": en Forever varios personajes de la cuenta
-- pueden llamarse igual en el mismo reino (Ventura...) y compartían rutas.
local PENDING = "pending" -- el juego aún no da el GUID (se corrige al entrar al mundo)
local function CharDataKey()
  local guid = UnitGUID and UnitGUID("player")
  return (type(guid) == "string" and guid ~= "") and guid or PENDING
end

local function LoadCharacterData()
  local db = ES.db
  local key = CharDataKey()
  -- Lo guardado por nombre (ES.db.chars) o para toda la cuenta no se sabe de qué
  -- personaje es: no se reparte (cada uno empieza de cero una vez)
  db.chars, db.charsMigrated = nil, nil
  db.characters = db.characters or {}
  local c = db.characters[key] or {}
  db.characters[key] = c
  c.prof = c.prof or {}
  -- El máximo pasó de 225 a 300: el objetivo guardado en 225 era el máximo de
  -- antes, no uno elegido; pasa al nuevo (una vez; una ruta empezada no se toca)
  if not c.max300 then
    for _, settings in pairs(c.prof) do
      if type(settings) == "table" and settings.target == 225 and not settings.lock then settings.target = nil end
    end
    c.max300 = true
  end
  db.prof, db.lastProf = c.prof, c.lastProf
  ES.charData, ES.charDataKey = c, key
end

-- Al entrar al mundo el GUID ya es seguro: si al cargar el addon el juego aún no lo
-- daba, lo de esta sesión (guardado como pendiente) pasa a ser de este personaje
local function CheckCharacterData()
  local key = CharDataKey()
  if not ES.charDataKey or ES.charDataKey == key or key == PENDING then return end
  local db = ES.db
  local old = db.characters[ES.charDataKey]
  db.characters[ES.charDataKey] = nil
  if ES.charDataKey == PENDING and not db.characters[key] then db.characters[key] = old end
  LoadCharacterData()
end

-- Al salir: lo del personaje queda solo en ES.db.characters (sin copias sueltas en ES.db)
local function SaveCharacterData()
  if not (ES.db and ES.charData) then return end
  ES.charData.lastProf = ES.db.lastProf
  ES.db.prof, ES.db.lastProf = nil, nil
end

ES.LoadCharacterData, ES.SaveCharacterData = LoadCharacterData, SaveCharacterData -- para pruebas

---------------------------------------------------------------------------
-- Registro de errores: los errores de Lua de este addon y las acciones que el
-- juego le bloquea se apuntan en CraftersJournalDB.errorLog (los mismos juntos,
-- con cuántas veces), para revisarlos después (/cj errores, o el archivo de
-- SavedVariables). Siguen saliendo como siempre (ventana de errores, BugSack...).
---------------------------------------------------------------------------
local MAX_ERRORS = 50

local function AddonVersion()
  local get = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
  return get and get(ADDON_NAME, "Version") or "?"
end

function ES:RecordError(kind, msg, stack)
  if not self.db then return end
  msg = tostring(msg or "?"):sub(1, 300)
  self.db.errorLog = self.db.errorLog or {}
  local log, now = self.db.errorLog, time()
  for _, e in ipairs(log) do
    if e.kind == kind and e.msg == msg then
      e.count, e.last = e.count + 1, now
      return
    end
  end
  log[#log + 1] = { kind = kind, msg = msg, stack = stack and tostring(stack):sub(1, 1500) or nil, count = 1,
    first = now, last = now, version = AddonVersion() }
  while #log > MAX_ERRORS do table.remove(log, 1) end
end

do
  -- Errores de Lua: solo los que pasan por los archivos de este addon. Se apunta
  -- y se pasa al manejador que hubiera (el del juego, BugGrabber...). Si otro addon
  -- de errores se carga después y pone el suyo, al entrar al mundo se vuelve a
  -- enganchar delante (busy: por si los dos se llaman entre sí)
  local previous, busy
  local function Handler(msg, ...)
    if busy then return end -- (el otro manejador nos ha vuelto a llamar: se corta aquí)
    busy = true
    local stack = debugstack and debugstack(2) or ""
    if tostring(msg):find(ADDON_NAME, 1, true) or stack:find(ADDON_NAME, 1, true) then
      pcall(ES.RecordError, ES, "lua", msg, stack)
    end
    if previous then pcall(previous, msg, ...) end
    busy = false
  end
  local function Install()
    if not (geterrorhandler and seterrorhandler) then return end
    local current = geterrorhandler()
    if current ~= Handler then
      previous = current
      seterrorhandler(Handler)
    end
  end
  Install()
  -- Acciones bloqueadas por el juego (funciones protegidas)
  local f = CreateFrame("Frame")
  ES.SafeRegister(f, "ADDON_ACTION_BLOCKED")
  ES.SafeRegister(f, "ADDON_ACTION_FORBIDDEN")
  ES.SafeRegister(f, "PLAYER_ENTERING_WORLD")
  f:SetScript("OnEvent", function(_, event, addon, func)
    if event == "PLAYER_ENTERING_WORLD" then Install() return end
    if addon == ADDON_NAME then
      ES:RecordError(event == "ADDON_ACTION_FORBIDDEN" and "prohibida" or "bloqueada", tostring(func),
        debugstack and debugstack(2) or nil)
    end
  end)
end

ES.SafeRegister(events, "ADDON_LOADED")
ES.SafeRegister(events, "PLAYER_LOGIN")
ES.SafeRegister(events, "PLAYER_LOGOUT")
ES.SafeRegister(events, "AUCTION_HOUSE_SHOW")
ES.SafeRegister(events, "AUCTION_HOUSE_CLOSED")
ES.SafeRegister(events, "UPDATE_FACTION")

events:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
    CraftersJournalDB = CraftersJournalDB or {}
    ApplyDefaults(CraftersJournalDB, DEFAULTS)
    ES.db = CraftersJournalDB
    LoadCharacterData()
    ES.lang = ES.db.lang or ES.DefaultLanguage()
    ES.DEV = ES.DEV_BUILD and not ES.db.userPreview -- vista de jugador guardada (copia de desarrollo)
    ES.db.lastGetAll, ES.db.serverLimit = nil, nil -- claves de versiones anteriores (ver Scanner.lua)
    ES.db.useGPS = nil -- (/cj gps de las pruebas: el GPS ya es el planificador de todos)
    ES.db.mail = nil   -- (lo que se leía del buzón en versiones anteriores: ya no se guarda nada del correo)
    ES.db.earnBudget = nil -- (presupuesto de Ganar dinero: ya no existe)
    ES.ApplyLocalization()
    ES:LocalizeRecipeNames()
  elseif event == "PLAYER_LOGOUT" then
    SaveCharacterData()
  elseif event == "PLAYER_LOGIN" then
    CheckCharacterData()
    ES:DropOtherFactionRecipes()
    CreateMinimapButton()
    ES.repStamp = ES:RepStamp()
  elseif event == "UPDATE_FACTION" then
    -- Al subir de nivel con una facción, las recetas que pedía pasan a estar disponibles
    local stamp = ES:RepStamp()
    if ES.repStamp and stamp ~= ES.repStamp then
      ES.repStamp = stamp
      if ES.ClearHomeCache then ES:ClearHomeCache() end
      if ES.RenderHome then ES:RenderHome() end
      if ES.RefreshProfessionPages then ES:RefreshProfessionPages() end
      if ES.RefreshPatternPages then ES:RefreshPatternPages() end
    end
    ES.repStamp = stamp
  elseif event == "AUCTION_HOUSE_SHOW" then
    ES:ScanLog("AUCTION_HOUSE_SHOW")
    ES.ahSession = (ES.ahSession or 0) + 1
    ES.ahOpen = true
    ES:RefreshScanButtons() -- lo primero: si algo de abajo falla, el botón ya está activo
    -- Antes que los addons que escanean solos al abrir (ForeverForge, a los 3 s)
    pcall(ES.Scanner.InstallHooks, ES.Scanner)
    DetectAuctionHouse()
    ES:OnAuctionHouseShow()
    ES:RefreshAllViews()
  elseif event == "AUCTION_HOUSE_CLOSED" then
    -- Puede llegar con la ventana aún abierta (p. ej. tras un escaneo completo):
    -- solo cuenta como cerrada si la ventana de la AH ya no se ve
    ES:ScanLog("AUCTION_HOUSE_CLOSED, ventana visible: " .. tostring(AHFrameShown()))
    local session = ES.ahSession
    C_Timer.After(0.2, function()
      if session ~= ES.ahSession or AHFrameShown() then return end -- ya se reabrió, o sigue abierta
      ES.ahOpen = false
      -- El servidor ya contó la petición: hay que esperar sus 15 min igualmente
      ES.Scanner:Abort(string.format(L["Has cerrado la Casa de Subastas; escaneo cancelado. Déjala abierta hasta que termine. Podrás volver a escanear en %s."],
        ES.Countdown(ES.Scanner:SecondsUntilNextScan())))
      ES:RefreshScanButtons()
    end)
  end
end)

-- /es icono: escribe las texturas del marco bajo el ratón y de sus padres
function ES:PrintIconUnderMouse()
  local frames = (GetMouseFoci and GetMouseFoci()) or { GetMouseFocus and GetMouseFocus() }
  local found, seen = {}, {}
  local function Add(tex)
    if not tex or not tex.GetObjectType or tex:GetObjectType() ~= "Texture" then return end
    local id = (tex.GetTextureFileID and tex:GetTextureFileID()) or (tex.GetTexture and tex:GetTexture())
    if id and not seen[id] then
      seen[id] = true
      found[#found + 1] = tostring(id)
    end
  end
  for _, frame in ipairs(frames) do
    local f, depth = frame, 0
    while f and depth < 3 and f ~= UIParent and f ~= WorldFrame do
      if f.GetNormalTexture then Add(f:GetNormalTexture()) end
      if f.icon then Add(f.icon) end
      if f.Icon then Add(f.Icon) end
      if f.GetRegions then for _, region in ipairs({ f:GetRegions() }) do Add(region) end end
      f, depth = f.GetParent and f:GetParent(), depth + 1
    end
  end
  ES:Print(#found > 0 and string.format(L["Icono bajo el ratón: %s"], table.concat(found, ", "))
    or L["No hay ningún icono bajo el ratón. Escribe /es icono y pon el ratón encima antes de 3 segundos."])
end

-- /es pestaña: guarda en CraftersJournalDB.debugFrame cómo está hecho el botón bajo el
-- ratón (tamaño, texturas con su capa, tamaño y anclaje, y la posición de sus
-- hermanos para ver la separación). Sirve para copiar al detalle un marco de Blizzard.
function ES:DumpFrameUnderMouse()
  local frames = (GetMouseFoci and GetMouseFoci()) or { GetMouseFocus and GetMouseFocus() }
  local f = frames[1]
  if not f or f == WorldFrame or f == UIParent then
    ES:Print(L["No hay ningún icono bajo el ratón. Escribe /es icono y pon el ratón encima antes de 3 segundos."])
    return
  end
  local function Name(x) return x and x.GetName and x:GetName() or tostring(x) end
  local function Points(x)
    local out = {}
    for i = 1, (x.GetNumPoints and x:GetNumPoints() or 0) do
      local p, rel, rp, dx, dy = x:GetPoint(i)
      out[#out + 1] = string.format("%s %s %s %.1f %.1f", tostring(p), Name(rel), tostring(rp), dx or 0, dy or 0)
    end
    return table.concat(out, " | ")
  end
  local function Describe(x)
    local d = { name = Name(x), type = x:GetObjectType(), w = x:GetWidth(), h = x:GetHeight(), points = Points(x),
      scale = x.GetScale and x:GetScale(), regions = {} }
    for _, r in ipairs({ x:GetRegions() }) do
      if r:GetObjectType() == "Texture" then
        local layer, sub = r:GetDrawLayer()
        d.regions[#d.regions + 1] = {
          tex = (r.GetTextureFileID and r:GetTextureFileID()) or r:GetTexture(), atlas = r.GetAtlas and r:GetAtlas(),
          layer = layer, sub = sub, w = r:GetWidth(), h = r:GetHeight(), points = Points(r),
          blend = r:GetBlendMode(), shown = r:IsShown(), coords = { r:GetTexCoord() },
        }
      end
    end
    -- Barras de progreso: la textura del relleno
    local bar = x.GetStatusBarTexture and x:GetStatusBarTexture()
    if bar then
      d.bar = { tex = (bar.GetTextureFileID and bar:GetTextureFileID()) or bar:GetTexture(), atlas = bar.GetAtlas and bar:GetAtlas(),
        coords = { bar:GetTexCoord() } }
    end
    return d
  end
  -- Hijos de un marco (una barra suele tener fondo, relleno y borde como hijos)
  local function Children(x)
    local out = {}
    for i, c in ipairs({ x.GetChildren and x:GetChildren() }) do
      if i > 12 then break end
      out[#out + 1] = Describe(c)
    end
    return out
  end
  local dump = { button = Describe(f), parent = f:GetParent() and Describe(f:GetParent()) or nil, siblings = {},
    children = Children(f), parentChildren = f:GetParent() and Children(f:GetParent()) or nil }
  -- Hermanos del mismo tamaño (las otras pestañas): su posición para la separación
  local parent = f:GetParent()
  if parent and parent.GetChildren then
    for _, c in ipairs({ parent:GetChildren() }) do
      if math.abs(c:GetWidth() - f:GetWidth()) < 1 and math.abs(c:GetHeight() - f:GetHeight()) < 1 then
        dump.siblings[#dump.siblings + 1] = { name = Name(c), top = c:GetTop(), left = c:GetLeft(), points = Points(c) }
      end
    end
  end
  ES.db.debugFrame = dump
  ES:Print(string.format(L["Guardado: %s (%dx%d). Haz /reload para que se escriba en el archivo."], dump.button.name,
    dump.button.w, dump.button.h))
end

---------------------------------------------------------------------------
-- Comandos
---------------------------------------------------------------------------
SLASH_CRAFTERSJOURNAL1 = "/craftersjournal"
SLASH_CRAFTERSJOURNAL2 = "/cj"
SLASH_CRAFTERSJOURNAL3 = "/es" -- el de antes (cuando se llamaba EasySkills)
SlashCmdList.CRAFTERSJOURNAL = function(msg)
  msg = strtrim(msg or ""):lower()
  if msg == "scan" then
    ES:ShowMainFrame()
    ES.Scanner:Start()
  elseif msg == "cancel" then
    if ES.Scanner:IsBusy() then
      ES.Scanner:Abort(L["Escaneo cancelado."])
    else
      ES:Print(L["No hay ningún escaneo en curso."])
    end
  elseif msg == "minimap" then
    ES.db.minimap.hide = not ES.db.minimap.hide
    ES.minimapButton:SetShown(not ES.db.minimap.hide)
  elseif msg == "icono" or msg == "icon" then
    -- Texturas del marco bajo el ratón (p. ej. una pestaña del libro de profesiones).
    -- Se mira a los 3 s: al escribir el comando el ratón no suele estar encima
    ES:Print(L["Pon el ratón sobre el icono: en 3 segundos lo leo."])
    C_Timer.After(3, function() ES:PrintIconUnderMouse() end)
  elseif msg == "errores" or msg == "errors" or msg == "errores borrar" or msg == "errors clear" then
    -- Lo apuntado por ES:RecordError (ver arriba)
    if msg:find(" ") then
      ES.db.errorLog = nil
      ES:Print(L["Registro de errores vaciado."])
      return
    end
    local log = ES.db.errorLog or {}
    if #log == 0 then
      ES:Print(L["Ningún error registrado."])
      return
    end
    ES:Print(string.format(L["%d errores distintos registrados (el más reciente al final):"], #log))
    for _, e in ipairs(log) do
      print(string.format("|cffff6060[%s]|r x%d %s %s%s", e.kind, e.count, date and date("%d/%m %H:%M", e.last) or "",
        e.msg, ""))
    end
    ES:Print(L["Detalle completo en CraftersJournalDB.errorLog (SavedVariables, tras /reload). /cj errores borrar para vaciarlo."])
  elseif msg == "instructor" or msg == "trainer" then
    -- Precios vistos en el instructor que no coinciden con los datos: filas para
    -- tools/forever/trainer_fees.csv (también en el archivo de SavedVariables tras /reload)
    local rows = ES.Ledger:TrainerDiffs()
    ES.db.trainerFeesCSV = rows
    -- Lo comprobado de cada profesión: para tenerlo todo, abre un instructor de cada una
    for _, c in ipairs(ES.Ledger:TrainerCoverage()) do
      ES:Print(string.format(L["%s: %d de %d recetas de instructor vistas en el juego, %d distintas de los datos."],
        ES:ProfLabel(c.prof), c.seen, c.total, c.diff))
    end
    -- Recetas que enseñan los instructores y el addon no conoce (nuevas de Forever)
    for prof, list in pairs(ES.db.trainerUnknown or {}) do
      for name, s in pairs(list) do
        ES:Print(string.format(L["%s: el instructor enseña %s (%s, nivel %s) y el addon no la tiene."],
          ES:ProfLabel(prof), s.link or name, ES.Money(s.cost or 0), tostring(s.skill or "?")))
      end
    end
    if #rows == 0 then
      ES:Print(L["Lo visto en los instructores coincide con los datos del addon."])
    else
      ES:Print(string.format(L["%d precios de instructor distintos de los datos (spell,name,cost,reqskill,source):"], #rows))
      for _, line in ipairs(rows) do print(line) end
      ES:Print(L["Haz /reload y cópialos de CraftersJournalDB.trainerFeesCSV en SavedVariables."])
    end
  elseif msg == "cuentas" or msg == "books" or msg == "cuentas log" or msg == "books log" then
    -- Contabilidad (Books.lua): hoy y la sesión por categoría, o los últimos movimientos
    ES.Books.Report(msg:find(" log$") and "log" or nil)
  elseif msg == "pestaña" or msg == "pestana" or msg == "tab" then
    ES:Print(L["Pon el ratón sobre el icono: en 3 segundos lo leo."])
    C_Timer.After(3, function() ES:DumpFrameUnderMouse() end)
  else
    ES:ToggleMainFrame()
  end
end

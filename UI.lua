local _, ES = ...
local L = ES.L

local GOLD_ICON   = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
local SILVER_ICON = "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t"
local COPPER_ICON = "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"

local CoinString = (C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString) or GetCoinTextureString
  or function(copper)
    local g = math.floor(copper / 10000)
    local s = math.floor(copper / 100) % 100
    local c = copper % 100
    local parts = {}
    if g > 0 then parts[#parts + 1] = g .. GOLD_ICON end
    if s > 0 then parts[#parts + 1] = s .. SILVER_ICON end
    if c > 0 or #parts == 0 then parts[#parts + 1] = c .. COPPER_ICON end
    return table.concat(parts, " ")
  end

local function Money(copper)
  if not copper then return "|cff888888—|r" end
  return CoinString(math.floor(copper + 0.5))
end
ES.Money = Money

-- Dinero dentro de un texto de letra más pequeña (las citas de la ruta): los
-- iconos del juego quedan altos, así que se bajan `offsetY` píxeles
function ES.MoneyInline(copper, offsetY)
  copper = math.floor((copper or 0) + 0.5)
  local function Icon(name) return string.format("|TInterface\\MoneyFrame\\UI-%sIcon:0:0:2:%d|t", name, offsetY or 0) end
  local g, s, c = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
  local parts = {}
  if g > 0 then parts[#parts + 1] = g .. Icon("Gold") end
  if s > 0 then parts[#parts + 1] = s .. Icon("Silver") end
  if c > 0 or #parts == 0 then parts[#parts + 1] = c .. Icon("Copper") end
  return table.concat(parts, " ")
end

local function TimeAgo(t)
  local d = time() - t
  if d < 60 then return L["hace unos segundos"] end
  if d < 3600 then return string.format(L["hace %d min"], math.floor(d / 60)) end
  if d < 86400 then return string.format(L["hace %d h"], math.floor(d / 3600)) end
  return string.format(L["hace %d días"], math.floor(d / 86400))
end

---------------------------------------------------------------------------
-- Panel principal
---------------------------------------------------------------------------
local main
local PAGE_MARGIN = 14 -- margen negro de las páginas a los lados y abajo

local function CreateMainFrame()
  local f = CreateFrame("Frame", "CraftersJournalMainFrame", UIParent, "BackdropTemplate")
  f:SetSize(840, 612)
  -- Marco de roca oscura con borde de diálogo del juego
  f:SetBackdrop({
    bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 24,
    insets = { left = 6, right = 6, top = 6, bottom = 6 },
  })
  f:SetBackdropColor(0.045, 0.042, 0.037, 0.99)
  f:SetPoint("CENTER")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:SetClampedToScreen(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  f:SetFrameStrata("HIGH")
  f:Hide()
  tinsert(UISpecialFrames, "CraftersJournalMainFrame") -- cerrar con Escape

  -- Cabecera: Informar, título e idioma (HeaderUI.lua)
  ES:CreateHeader(f)

  -- Escalar arrastrando la esquina inferior derecha: toda la ventana se amplía o
  -- reduce a la vez (mismo factor en ancho y alto). La esquina superior izquierda
  -- se queda donde está. La escala se recuerda.
  local BASE_W, BASE_H = f:GetWidth(), f:GetHeight()
  local MIN_SCALE, MAX_SCALE = 0.6, 1.8
  local savedScale = tonumber(ES.db.frameScale)
  if savedScale then f:SetScale(math.min(MAX_SCALE, math.max(MIN_SCALE, savedScale))) end

  f.resize = CreateFrame("Button", nil, f)
  f.resize:SetSize(16, 16)
  f.resize:SetPoint("BOTTOMRIGHT", -8, 8)
  f.resize:SetFrameLevel(f:GetFrameLevel() + 20)
  f.resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  f.resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  f.resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

  -- Escala para que la esquina inferior derecha quede bajo el ratón
  local function ScaleToCursor(left, top)
    local ui = UIParent:GetEffectiveScale()
    local x, y = GetCursorPosition()
    x, y = x / ui, y / ui
    local scale = math.max((x - left) / BASE_W, (top - y) / BASE_H)
    scale = math.min(MAX_SCALE, math.max(MIN_SCALE, scale))
    f:SetScale(scale)
    -- Los desplazamientos van en la escala del propio marco
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left / scale, top / scale)
  end

  f.resize:SetScript("OnMouseDown", function(self, button)
    if button ~= "LeftButton" then return end
    -- Esquina superior izquierda en coordenadas de la pantalla (UIParent)
    local scale = f:GetScale()
    local left, top = f:GetLeft() * scale, f:GetTop() * scale
    self:SetScript("OnUpdate", function() ScaleToCursor(left, top) end)
  end)
  f.resize:SetScript("OnMouseUp", function(self)
    self:SetScript("OnUpdate", nil)
    ES.db.frameScale = math.floor(f:GetScale() * 100 + 0.5) / 100
  end)
  f.resize:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Arrastra para ampliar o reducir la ventana"])
    GameTooltip:AddLine(L["Doble clic: tamaño normal"], 0.8, 0.8, 0.8)
    GameTooltip:Show()
  end)
  f.resize:SetScript("OnLeave", function() GameTooltip:Hide() end)
  f.resize:SetScript("OnDoubleClick", function()
    local s = f:GetScale()
    local left, top = f:GetLeft() * s, f:GetTop() * s
    f:SetScale(1)
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
    ES.db.frameScale = 1
  end)

  -- Navegación: la portada (tarjetas) y una página por tarjeta. Encima de la
  -- página, el título y "Volver" a la portada
  -- Flechas a los lados, como "Mazmorras" en el diario: la profesión anterior y la
  -- siguiente (en Subir profesiones y en la colección de recetas)
  local function Arrow(dir)
    local b = CreateFrame("Button", nil, f)
    b:SetSize(26, 26)
    local base = "Interface\\Buttons\\UI-SpellbookIcon-" .. (dir < 0 and "Prev" or "Next") .. "Page-"
    b:SetNormalTexture(base .. "Up")
    b:SetPushedTexture(base .. "Down")
    b:SetDisabledTexture(base .. "Disabled")
    b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    b:SetScript("OnClick", function() ES:SelectSiblingPage(dir) end)
    b:SetScript("OnEnter", function(self)
      local key = ES:SiblingPage(dir)
      if not key then return end
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:AddLine(dir < 0 and L["Profesión anterior"] or L["Profesión siguiente"])
      GameTooltip:AddLine(f.pageTitles[key] or key, 1, 1, 1)
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return b
  end
  f.prevPage = Arrow(-1)
  f.prevPage:SetPoint("TOPLEFT", 14, -57) -- con aire encima (cabecera) y debajo (la página)
  f.back = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  f.back:SetSize(130, 24)
  f.back:SetPoint("LEFT", f.prevPage, "RIGHT", 2, 0)
  f.back:SetText(L["Profesiones"])
  f.back:SetScript("OnClick", function() ES:SelectPage(f.backTarget or "home") end)
  f.nextPage = Arrow(1)
  f.nextPage:SetPoint("LEFT", f.back, "RIGHT", 2, 0)

  f.navTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
  f.navTitle:SetJustifyH("LEFT")

  f.pages, f.pageTitles = {}, {}
  local function AddPage(key, title)
    -- Márgenes negros a los lados y abajo, como el diario de mazmorras
    local page = CreateFrame("Frame", nil, f)
    page:SetPoint("TOPLEFT", PAGE_MARGIN, -94)
    page:SetPoint("BOTTOMRIGHT", -PAGE_MARGIN, PAGE_MARGIN)
    page:Hide()
    f.pages[key], f.pageTitles[key] = page, title
    return page
  end
  f.AddPage = AddPage

  ES:CreateHomePage(AddPage("home", L["Subir profesiones"]))
  ES:CreateEarnPage(AddPage("money", ""))
  ES:CreateInventoryPage(AddPage("inventory", ""))
  ES:CreateCalculatorPage(AddPage("calc", ""))
  ES:CreateShoppingPage(AddPage("shopping", ""))
  ES:CreatePatternsPage(AddPage("patterns", L["Colección de recetas"]))
  for _, prof in ipairs(ES.PROFESSIONS) do
    if ES.Data[prof.key] then ES:CreatePatternPage(AddPage("pattern:" .. prof.key, ES:ProfLabel(prof.key)), prof.key) end
  end

  -- Al abrir el panel se vuelve a donde estabas en esta sesión (la última página; en
  -- una profesión, también su vista), salvo que se pida otra. Solo en la sesión: con
  -- otro personaje (o al volver a entrar) se empieza en la portada
  -- El botón de la estrella sobre una fila (Waypoints.lua) no se queda flotando
  f:HookScript("OnHide", function() ES.Waypoints.ReleaseHover() end)
  f:SetScript("OnShow", function(self)
    ES.Jobs.Resume() -- rutas pendientes de cuando estaba cerrada (Jobs.lua)
    ES:RefreshScanButtons()
    ES:SelectPage(self.openPage or ES.sessionPage or "home")
    self.openPage = nil
  end)

  main = f
  -- Profesiones con datos: su página lleva el nombre en su propia cabecera
  for _, prof in ipairs(ES.PROFESSIONS) do
    if ES.Data[prof.key] then
      ES:CreateProfessionPage(AddPage(prof.key, ""), prof.key)
    end
  end
  ES:CreateSideTabs(f)
  return f
end

---------------------------------------------------------------------------
-- Pestañas laterales (a la derecha, como las del libro de hechizos)
---------------------------------------------------------------------------
-- Icono de "Subir profesiones": el del libro de profesiones de Forever (pico y
-- martillo). Es un icono propio de Forever, sin nombre de archivo: su número
ES.SKILLS_ICON = 8197101
local TABS = ES.Localize({
  { key = "home",     label = "Subir profesiones",    icon = "skills",
    desc = "Cómo subir cada profesión: la ruta más barata paso a paso." },
  -- (justo debajo de Subir profesiones: es lo que se usa al seguir una ruta)
  { key = "shopping", label = "Lista de compra",      icon = "Interface\\Icons\\INV_Misc_Note_01",
    desc = "Lo que pide tu ruta empezada (sale sola) y lo que añades desde Ganar dinero o la calculadora; con la AH abierta, se compra desde aquí." },
  { key = "money",    label = "Ganar dinero",         icon = "Interface\\Icons\\INV_Misc_Coin_02",
    desc = "Qué fabricar hoy con tus recetas porque da beneficio." },
  { key = "inventory", label = "Inventario",          icon = "Interface\\Icons\\INV_Misc_Bag_08",
    desc = "Qué vender de tus bolsas, dónde y cuánto sacas; y lo que ha subido de precio." },
  { key = "calc",     label = "Calculadora",          icon = "Interface\\Icons\\INV_Misc_Note_02",
    desc = "Cuánto ganas con una receta, como en una hoja de cálculo: guarda varios cálculos y escribe tus precios." },
  { key = "patterns", label = "Colección de recetas", icon = "Interface\\Icons\\INV_Scroll_03",
    desc = "Todas las recetas de cada profesión: cuántas tienes y dónde conseguir las demás." },
}, "label")
ES.Localize(TABS, "desc")

-- Pestaña a la que pertenece cada página, y adónde vuelve "Volver"
local function TabOf(key)
  if key:match("^pattern:") then return "patterns", "patterns" end
  if ES.Data[key] then return "home", "home" end -- página de una profesión
  return key, nil
end

-- Pestaña idéntica a las del libro de profesiones de Forever (medidas leídas del
-- juego sobre ProfessionsFrame): botón de 55x55; marco
-- "common-sidetab" de 55x60 centrado; icono de 50x50 desplazado -4 px y recortado
-- 1/32 por borde; seleccionada = "common-sidetab-selected" dos veces (normal y
-- sumado); ratón encima = "common-sidetab-hover". La primera, 60 px bajo la esquina
-- superior derecha; las demás, 2 px por debajo de la anterior.
local TAB_SIZE, TAB_GAP, TAB_TOP = 55, 2, -60

local function Atlas(tex, name, w, h)
  local ok = tex.SetAtlas and tex:SetAtlas(name)
  tex:SetSize(w, h)
  return ok
end

local function CreateTab(parent, icon)
  local tab = CreateFrame("Button", nil, parent)
  tab:SetSize(TAB_SIZE, TAB_SIZE)
  local bg = tab:CreateTexture(nil, "BACKGROUND")
  bg:SetPoint("CENTER")
  local hasAtlas = Atlas(bg, "common-sidetab", 55, 60)
  tab.icon = tab:CreateTexture(nil, "ARTWORK")
  tab.icon:SetSize(50, 50)
  tab.icon:SetPoint("CENTER", -4, 0)
  tab.icon:SetTexture(icon)
  tab.icon:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875)
  tab.selected = {}
  for _, blend in ipairs({ "BLEND", "ADD" }) do
    local sel = tab:CreateTexture(nil, "OVERLAY")
    sel:SetPoint("CENTER")
    Atlas(sel, "common-sidetab-selected", 55, 60)
    sel:SetBlendMode(blend)
    sel:Hide()
    tab.selected[#tab.selected + 1] = sel
  end
  local hover = tab:CreateTexture(nil, "HIGHLIGHT")
  hover:SetPoint("CENTER")
  Atlas(hover, "common-sidetab-hover", 55, 60)
  -- Cliente sin esos atlas: marco y brillos clásicos del libro de hechizos
  if not hasAtlas then
    bg:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
    bg:SetSize(64, 64)
    bg:ClearAllPoints()
    bg:SetPoint("TOPLEFT", -3, 11)
    for _, sel in ipairs(tab.selected) do sel:SetTexture("Interface\\Buttons\\CheckButtonHilight") sel:SetBlendMode("ADD") end
    hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    hover:SetBlendMode("ADD")
  end
  function tab:SetChecked(on)
    for _, sel in ipairs(self.selected) do sel:SetShown(on and true or false) end
  end
  return tab
end

-- Avisa de que algo nuevo ha llegado a una pestaña (la Lista de compra al añadir un
-- tramo): la pestaña brilla unos segundos y, si sound, suena el de las monedas
function ES:FlashTab(key, sound)
  if sound and PlaySound then
    pcall(PlaySound, SOUNDKIT and SOUNDKIT.IG_BACKPACK_COIN_OK or 891)
  end
  if not main or not main.tabs then return end
  for _, tab in ipairs(main.tabs) do
    if tab.key == key then
      if not tab.flash then
        tab.flash = tab:CreateTexture(nil, "OVERLAY")
        tab.flash:SetAllPoints(tab.icon)
        tab.flash:SetColorTexture(1, 0.82, 0.25, 1)
        tab.flash:SetBlendMode("ADD")
        tab.flash:SetAlpha(0)
        local ag = tab.flash:CreateAnimationGroup()
        local up = ag:CreateAnimation("Alpha")
        up:SetFromAlpha(0) up:SetToAlpha(0.55) up:SetDuration(0.35) up:SetOrder(1)
        local down = ag:CreateAnimation("Alpha")
        down:SetFromAlpha(0.55) down:SetToAlpha(0) down:SetDuration(0.35) down:SetOrder(2)
        ag:SetLoopType("REPEAT")
        tab.flashAnim = ag
      end
      tab.flashAnim:Stop()
      tab.flashAnim:Play()
      tab.flashing = true -- (para pruebas)
      C_Timer.After(2.8, function() if tab.flashAnim then tab.flashAnim:Stop() tab.flash:SetAlpha(0) end tab.flashing = nil end)
    end
  end
end

function ES:CreateSideTabs(f)
  f.tabs = {}
  for _, t in ipairs(TABS) do
    local tab = CreateTab(f, t.icon == "skills" and ES.SKILLS_ICON or t.icon)
    if #f.tabs == 0 then
      tab:SetPoint("TOPLEFT", f, "TOPRIGHT", 0, TAB_TOP)
    else
      tab:SetPoint("TOPLEFT", f.tabs[#f.tabs], "BOTTOMLEFT", 0, -TAB_GAP)
    end
    tab.key = t.key
    -- Vuelve a donde estabas en esa pestaña (la profesión que mirabas), no a su portada;
    -- a la portada se va con el botón "Profesiones" / "Colección"
    tab:SetScript("OnClick", function() ES:SelectPage(ES.tabLastPage[t.key] or t.key) end)
    tab:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:AddLine(t.label)
      GameTooltip:AddLine(t.desc, 0.8, 0.8, 0.8, true)
      GameTooltip:Show()
    end)
    tab:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f.tabs[#f.tabs + 1] = tab
  end
end

ES.tabLastPage = {} -- [pestaña] = última página vista en ella (solo esta sesión)
function ES:SelectPage(key)
  if key == "lw" or key == "profit" then key = "Leatherworking" end -- nombres de versiones anteriores
  if not main or not main.pages[key] then key = "home" end -- (también pestañas que ya no existen)
  self.db.lastPage = key
  self.sessionPage = key -- lo que recuerda la ventana al volver a abrirla (solo esta sesión)
  for k, page in pairs(main.pages) do page:SetShown(k == key) end
  local tab, back = TabOf(key)
  self.tabLastPage[tab] = key -- (la pestaña vuelve aquí al pulsarla otra vez)
  for _, t in ipairs(main.tabs or {}) do t:SetChecked(t.key == tab) end
  -- "Volver" solo dentro de una pestaña (una profesión, la colección de una profesión)
  local inner = key ~= tab
  main.back:SetShown(inner)
  main.backTarget = back
  main.back:SetText(back == "patterns" and L["Colección"] or L["Profesiones"])
  -- Flechas: solo dentro de una profesión, y si hay otra a la que pasar
  local siblings = inner and #self:SiblingPages(key) > 1
  main.prevPage:SetShown(siblings)
  main.nextPage:SetShown(siblings)
  main.navTitle:ClearAllPoints()
  if inner then
    main.navTitle:SetPoint("LEFT", siblings and main.nextPage or main.back, "RIGHT", 12, 0)
  else
    main.navTitle:SetPoint("TOPLEFT", 22, -62)
  end
  main.navTitle:SetText(main.pageTitles[key] or "")
  if key == "home" then self:RenderHome() end
end

-- Páginas hermanas de una página interior, en el orden de la portada: primero las
-- profesiones que tienes y luego el resto (las profesiones, o sus colecciones)
function ES:SiblingPages(key)
  local prefix = key:match("^pattern:") and "pattern:" or ""
  local mine, others = {}, {}
  for _, p in ipairs(self.PROFESSIONS or {}) do
    local k = prefix .. p.key
    if main and main.pages[k] then
      local data = self.Data[p.key]
      local has = data and data.skillLine and self:GetProfessionSkill(data.skillLine)
      table.insert(has and mine or others, k)
    end
  end
  for _, k in ipairs(others) do mine[#mine + 1] = k end
  return mine
end

-- La anterior (dir = -1) o la siguiente (1) de la página actual, dando la vuelta
function ES:SiblingPage(dir)
  local key = self.db and self.db.lastPage
  if not key then return nil end
  local list = self:SiblingPages(key)
  for i, k in ipairs(list) do
    if k == key then return list[(i - 1 + dir) % #list + 1] end
  end
end

function ES:SelectSiblingPage(dir)
  local key = self:SiblingPage(dir)
  if key then self:SelectPage(key) end
end

function ES:GetMainFrame()
  return main or CreateMainFrame()
end

-- Vuelve a crear la ventana (al cambiar de idioma: todos sus textos se ponen al
-- crearla). La vieja se esconde y se suelta; si estaba abierta, se abre la nueva
-- en la misma página.
function ES:RebuildMainFrame()
  if not main then return end
  local wasShown, page = main:IsShown(), self.db.lastPage
  main:Hide()
  main:SetScript("OnShow", nil)
  main = nil
  self.professionPages, self.patternPages = nil, nil
  self.homePage, self.earnPage, self.patternsPage = nil, nil, nil
  self.shoppingPage = nil
  if wasShown then self:ShowMainFrame(page) end
end

-- Abre el panel; `page` elige la página (por defecto, la última que viste en esta sesión)
function ES:ShowMainFrame(page)
  local f = self:GetMainFrame()
  if f:IsShown() then
    if page then self:SelectPage(page) end
  else
    f.openPage = page
    f:Show()
  end
end

-- Esconde la ventana si está abierta (sin crearla si aún no existe)
function ES:HideMainFrame()
  if main and main:IsShown() then main:Hide() end
end

function ES:ToggleMainFrame()
  local f = self:GetMainFrame()
  f:SetShown(not f:IsShown())
end

function ES:OnScanComplete(scan)
  self:ShowMainFrame()
  self:RefreshAllViews() -- precios nuevos: todos los apartados
  self.Collection:AlertScan(scan) -- pergaminos de botín que te faltan, en la AH
end

---------------------------------------------------------------------------
-- Botones de escaneo (panel + ventana de la AH)
---------------------------------------------------------------------------
local ahButton

-- Estado de los botones de escanear (cabecera y ventana de la AH), como en
-- Auctionator: sin límite propio; se escanea cuando el cliente lo permite.
--   escaneando -> el % de progreso, en gris
--   si no      -> "Escanear", pulsable solo con la AH abierta
-- Junto al botón de la cabecera, en pequeño: "Último escaneo: hace 3 min".
-- "14:21": lo que falta para poder pedir otro escaneo completo al servidor
local function Countdown(seconds)
  return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end
ES.Countdown = Countdown

function ES:RefreshScanButtons()
  local busy = self.Scanner:IsBusy()
  -- Límite de 15 min del servidor (ver Scanner): cuenta atrás en gris
  local wait = busy and 0 or self.Scanner:SecondsUntilNextScan()
  local enabled = self:IsAuctionHouseOpen() and not busy and wait == 0
  local progress
  if busy then
    progress = string.format("%d%%", math.floor((self.Scanner.progress or 0) * 100))
    if self.Scanner.state == "waiting" and (self.Scanner.waited or 0) > 0 then
      progress = progress .. string.format(" · %ds", self.Scanner.waited) -- esperando al servidor
    end
  elseif wait > 0 then
    progress = Countdown(wait)
  end

  -- Al diario solo los cambios de estado (no cada segundo de la cuenta atrás)
  local state = string.format("%s ah=%s busy=%s espera=%s", tostring(enabled), tostring(self.ahOpen), tostring(busy), tostring(wait > 0))
  if state ~= self.lastButtonState and not busy then
    self.lastButtonState = state
    self:ScanLog("botón " .. state)
  end
  if main then
    main.scanButton:SetEnabled(enabled)
    main.scanButton:SetText(progress or L["Escanear"])
    self:UpdateLastScan()
  end
  if ahButton then
    ahButton:SetEnabled(enabled)
    ahButton:SetText(progress and ("Crafter's Journal: " .. progress) or L["Crafter's Journal: Escanear"])
  end
  -- Mientras dure el límite, la cuenta atrás avanza cada segundo
  if wait > 0 and not self.countdownTicking then
    self.countdownTicking = true
    local function Tick()
      if ES.Scanner:IsBusy() or ES.Scanner:SecondsUntilNextScan() == 0 then
        ES.countdownTicking = false
        ES:RefreshScanButtons()
        return
      end
      ES:RefreshScanButtons()
      C_Timer.After(1, Tick)
    end
    C_Timer.After(1, Tick)
  end
end

function ES:OnScanProgress()
  self:RefreshScanButtons()
end

-- "Último escaneo: hace 3 min" junto al botón (de la AH activa)
function ES:UpdateLastScan()
  if not main or not main.lastScan then return end
  local key = self:RealmKey()
  local scan = self.db.scans and self.db.scans[key]
  local fail = self:LastScanFail()
  if fail then
    -- El último intento no acabó: que "hace 2 días" no parezca un escaneo perdido
    main.lastScan:SetText("|cffff9933" .. L["Cancelado · último: "] .. (scan and TimeAgo(scan.time) or L["nunca"]) .. "|r")
  else
    main.lastScan:SetText(scan and (L["Último escaneo: "] .. TimeAgo(scan.time)) or L["Sin escanear"])
  end
end

-- El último intento de escaneo, si falló después del último escaneo guardado
function ES:LastScanFail()
  local key = self:RealmKey()
  local fail = type(self.db.lastScanFail) == "table" and self.db.lastScanFail[key]
  local scan = self.db.scans and self.db.scans[key]
  if fail and (not scan or fail.time > scan.time) then return fail end
end

function ES:OnAuctionHouseShow()
  -- La ventana de la AH se carga bajo demanda: creamos el botón al abrirla
  local ahFrame = AuctionHouseFrame or AuctionFrame
  if not ahFrame then
    C_Timer.After(0.1, function() if ES.ahOpen then ES:OnAuctionHouseShow() end end)
    return
  end
  if not ahButton then
    ahButton = CreateFrame("Button", "CraftersJournalAHButton", ahFrame, "UIPanelButtonTemplate")
    ahButton:SetSize(180, 24)
    ahButton:SetPoint("BOTTOMRIGHT", ahFrame, "TOPRIGHT", 0, 2)
    ahButton:SetScript("OnClick", function()
      ES:ShowMainFrame()
      ES.Scanner:Start()
    end)
    ahButton:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:AddLine("Crafter's Journal")
      GameTooltip:AddLine(L["Descarga todas las subastas y muestra el análisis."], 1, 1, 1, true)
      GameTooltip:Show()
    end)
    ahButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end
  self.Scanner.statusText = nil
  self:RefreshScanButtons()
  if self.SetupAuctionPanel then self:SetupAuctionPanel(ahFrame) end
end

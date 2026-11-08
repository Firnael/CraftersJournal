local _, ES = ...
local L = ES.L

local MAX_ROWS = 100
local ROW_HEIGHT = 22

-- Mercado de los objetos de profesiones (materiales y fabricados) en la AH
local COLUMNS = ES.Localize({
  { key = "name",     title = "Objeto",        width = 210, justify = "LEFT" },
  { key = "price",    title = "Precio típico", width = 90,  justify = "RIGHT" },
  { key = "min",      title = "Más barata",    width = 90,  justify = "RIGHT" },
  { key = "listings", title = "Subastas",      width = 58,  justify = "RIGHT" },
  { key = "quantity", title = "Uds",           width = 50,  justify = "RIGHT" },
  { key = "trend",    title = "Tendencia",     width = 62,  justify = "RIGHT" },
  { key = "market",   title = "Mercado",       width = 92,  justify = "RIGHT" },
}, "title")

-- Columna de la tabla -> campo por el que se ordena
local SORT_FIELDS = {
  name = "sortName", price = "nowPrice", min = "minUnit", listings = "listings",
  quantity = "quantity", trend = "trend", market = "marketRank",
}
local VERDICT_RANK = { good = 3, unknown = 2, watch = 1, avoid = 0 }

-- Orden de la lista: { key = columna, asc = true/false }
function ES:GetTopSort()
  local s = self.db.topSortBy
  if type(s) ~= "table" or not SORT_FIELDS[s.key] then
    s = { key = "listings", asc = false } -- columnas de versiones anteriores: ya no existen
    self.db.topSortBy = s
  end
  return s
end

-- Pulsar una columna: ordenar por ella; otra vez, al revés. Los números empiezan
-- de mayor a menor y el nombre de la A a la Z.
function ES:SetTopSort(key)
  local s = self:GetTopSort()
  if s.key == key then
    s.asc = not s.asc
  else
    s.key, s.asc = key, (key == "name")
  end
  self:RenderResults()
end

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

local function CreateRow(parent, i)
  local row = CreateFrame("Button", nil, parent)
  row:SetSize(700, ROW_HEIGHT)
  row:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)

  if i % 2 == 0 then
    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0.04)
  end
  local hl = row:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints()
  hl:SetColorTexture(0.2, 0.6, 1, 0.15)

  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(18, 18)
  row.icon:SetPoint("LEFT", 4, 0)

  row.cells = {}
  local x = 26
  for c, col in ipairs(COLUMNS) do
    local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    local w = (c == 1) and (col.width - 26) or col.width
    fs:SetSize(w, ROW_HEIGHT)
    fs:SetPoint("LEFT", x, 0)
    fs:SetJustifyH(col.justify)
    fs:SetWordWrap(false)
    row.cells[col.key] = fs
    x = x + w + 4
  end

  row:SetScript("OnEnter", function(self)
    if not self.itemID then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. self.itemID)
    local d = self.data
    if d then
      local W = { 0.8, 0.8, 0.8, 1, 1, 1 }
      local e = d.current
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine("Crafter's Journal", 0.2, 0.8, 1)
      GameTooltip:AddDoubleLine(L["Ahora en la AH"], string.format(L["%d subastas, %d uds"], e.listings, e.quantity), unpack(W))
      GameTooltip:AddDoubleLine(L["Precio típico (mediana de lo anunciado)"], Money(e.median or e.minUnit), unpack(W))
      GameTooltip:AddDoubleLine(L["La más barata"], Money(e.minUnit), unpack(W))
      if d.oldMin then
        GameTooltip:AddDoubleLine(L["Precio hace "] .. d.windowLabel, Money(d.oldMin) .. " (" .. TimeAgo(d.oldTime) .. ")", unpack(W))
      end
      -- Lo que dice el histórico de escaneos
      local ph = ES.History:PriceHistory(self.itemID)
      if #ph >= 2 then
        local lo, hi = math.huge, 0
        for _, p in ipairs(ph) do lo, hi = math.min(lo, p.median), math.max(hi, p.median) end
        GameTooltip:AddDoubleLine(string.format(L["Precio en %d escaneos (desde %s)"], #ph, TimeAgo(ph[1].time)),
          Money(lo) .. " a " .. Money(hi), unpack(W))
      end
      local vendor = ES:VendorSellPrice(self.itemID)
      if vendor then GameTooltip:AddDoubleLine(L["Precio de vendedor"], Money(vendor), unpack(W)) end
      local risk = ES:PriceRisk(self.itemID, e)
      if risk then GameTooltip:AddLine(L["Precio poco fiable: "] .. risk .. ".", 1, 0.5, 0, true) end
      ES.Market.AddToTooltip(self.itemID)
      GameTooltip:AddLine(L["El juego no dice qué se vende: las alertas avisan de lo que probablemente no."], 0.5, 0.5, 0.5, true)
    end
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function() GameTooltip:Hide() end)

  return row
end

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

  -- Cabecera: buscador, título e idioma (HeaderUI.lua)
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
  f.back = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  f.back:SetSize(130, 24)
  f.back:SetPoint("TOPLEFT", 16, -58) -- con aire encima (cabecera) y debajo (la página)
  f.back:SetText(L["Profesiones"])
  f.back:SetScript("OnClick", function() ES:SelectPage(f.backTarget or "home") end)

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
  ES:CreateFlippingPage(AddPage("flipping", ""))
  ES:CreatePatternsPage(AddPage("patterns", L["Colección de recetas"]))
  for _, prof in ipairs(ES.PROFESSIONS) do
    if ES.Data[prof.key] then ES:CreatePatternPage(AddPage("pattern:" .. prof.key, ES:ProfLabel(prof.key)), prof.key) end
  end

  local page = AddPage("ah", L["Subastas"])

  -- Cabecera de la sección (el botón de escanear está en la cabecera del panel)
  local header = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  header:SetPoint("TOPLEFT", 16, -6)
  header:SetText(L["Mercado de profesiones en la AH"])

  -- Buscador de la lista: filtra mientras se escribe
  f.search = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
  f.search:SetSize(160, 20)
  f.search:SetPoint("TOPRIGHT", -16, -4)
  f.search:SetAutoFocus(false)
  f.search:SetMaxLetters(40)
  f.search:SetScript("OnTextChanged", function() ES:RenderResults() end)
  f.search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  f.search:SetScript("OnEscapePressed", function(self)
    self:SetText("") -- Escape borra la búsqueda
    self:ClearFocus()
  end)
  local searchLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  searchLabel:SetPoint("RIGHT", f.search, "LEFT", -8, 0)
  searchLabel:SetText(L["Buscar:"])

  f.status = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  f.status:SetPoint("TOPLEFT", 16, -32)
  f.status:SetPoint("RIGHT", -16, 0)
  f.status:SetJustifyH("LEFT")

  f.summary = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  f.summary:SetPoint("TOPLEFT", 16, -50)
  f.summary:SetPoint("RIGHT", -16, 0)
  f.summary:SetJustifyH("LEFT")

  -- Franja de tiempo y orden
  local function SmallButton(text, width, onClick)
    local b = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    b:SetSize(width, 20)
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    return b
  end

  local windowLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  windowLabel:SetPoint("TOPLEFT", 16, -92)
  windowLabel:SetText(L["Tendencia de precio en:"])
  f.windowButtons = {}
  local prev = windowLabel
  for _, w in ipairs(ES.History.WINDOWS) do
    local b = SmallButton(w.label, 62, function()
      ES.db.topWindow = w.key
      ES:RenderResults()
    end)
    b:SetPoint("LEFT", prev, "RIGHT", 6, 0)
    b.key = w.key
    f.windowButtons[#f.windowButtons + 1] = b
    prev = b
  end

  local sortHint = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  sortHint:SetPoint("TOPRIGHT", -16, -94)
  sortHint:SetText(L["Pulsa una columna para ordenar (otra vez: al revés)"])

  -- Títulos de columna: pulsables para ordenar; la flecha marca columna y sentido
  local x = 16 + 26
  f.headers = {}
  for c, col in ipairs(COLUMNS) do
    local w = (c == 1) and (col.width - 26) or col.width
    local b = CreateFrame("Button", nil, page)
    b:SetSize(w, 16)
    b:SetPoint("TOPLEFT", x, -118)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.text:SetAllPoints()
    b.text:SetJustifyH(col.justify)
    b.text:SetText(col.title)
    b.arrow = b:CreateTexture(nil, "OVERLAY")
    b.arrow:SetTexture("Interface\\Buttons\\UI-SortArrow")
    b.arrow:SetSize(9, 8)
    if col.justify == "RIGHT" then
      b.arrow:SetPoint("RIGHT", b.text, "RIGHT", 2 - b.text:GetStringWidth() - 4, 0)
    else
      b.arrow:SetPoint("LEFT", b.text, "LEFT", b.text:GetStringWidth() + 4, 0)
    end
    b.arrow:Hide()
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.08)
    b:SetScript("OnClick", function() ES:SetTopSort(col.key) end)
    b.key = col.key
    f.headers[#f.headers + 1] = b
    x = x + w + 4
  end

  -- Lista con scroll
  local scroll = ES.UI.WheelScroll(page)
  scroll:SetPoint("TOPLEFT", 12, -136)
  scroll:SetPoint("BOTTOMRIGHT", -12, 12)

  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(700, 1)
  scroll:SetScrollChild(content)
  f.content = content
  f.rows = {}

  f.empty = content:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  f.empty:SetPoint("TOP", 0, -40)
  f.empty:SetWidth(600)
  f.empty:SetText(L["Todavía no hay datos.\nAbre la Casa de Subastas y pulsa \"Escanear\" arriba."])

  -- Refresca nombres/iconos cuando el servidor nos envía la info de un objeto
  ES.SafeRegister(f, "GET_ITEM_INFO_RECEIVED")
  f:SetScript("OnEvent", function(self)
    if self.pendingItems and not self.refreshQueued then
      self.refreshQueued = true
      C_Timer.After(0.3, function()
        self.refreshQueued = false
        if self:IsShown() then ES:RenderResults() end
      end)
    end
  end)

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
-- (leído con /es icono sobre esa pestaña)
ES.SKILLS_ICON = 8197101
local TABS = ES.Localize({
  { key = "home",     label = "Subir profesiones",    icon = "skills",
    desc = "Cómo subir cada profesión: la ruta más barata paso a paso." },
  { key = "money",    label = "Ganar dinero",         icon = "Interface\\Icons\\INV_Misc_Coin_02",
    desc = "Qué fabricar hoy con tus recetas porque da beneficio." },
  { key = "inventory", label = "Inventario",          icon = "Interface\\Icons\\INV_Misc_Bag_08",
    desc = "Qué vender de tus bolsas, dónde y cuánto sacas; y lo que ha subido de precio." },
  { key = "calc",     label = "Calculadora",          icon = "Interface\\Icons\\INV_Misc_Note_02",
    desc = "Cuánto ganas con una receta, como en una hoja de cálculo: guarda varios cálculos y escribe tus precios." },
  { key = "flipping", label = "Flipping",             icon = "flip", dev = true,
    desc = "Objetos de la AH que han bajado de precio: cómpralos barato y revéndelos." },
  { key = "patterns", label = "Colección de recetas", icon = "Interface\\Icons\\INV_Scroll_03",
    desc = "Todas las recetas de cada profesión: cuántas tienes y dónde conseguir las demás." },
  { key = "ah",       label = "Subastas",             icon = "Interface\\Icons\\INV_Misc_Bag_10", dev = true,
    desc = "Precios, oferta y alertas de mercado de los objetos de profesiones." },
}, "label")
ES.Localize(TABS, "desc")
-- dev = true: solo en modo desarrollo (ES.DEV, Core.lua); en la 1.0 no se ven

-- Pestaña a la que pertenece cada página, y adónde vuelve "Volver"
local function TabOf(key)
  if key:match("^pattern:") then return "patterns", "patterns" end
  if ES.Data[key] then return "home", "home" end -- página de una profesión
  return key, nil
end

-- Pestaña idéntica a las del libro de profesiones de Forever (medidas leídas del
-- juego con /es pestaña sobre ProfessionsFrame): botón de 55x55; marco
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

function ES:CreateSideTabs(f)
  f.tabs = {}
  for _, t in ipairs(TABS) do
    if not t.dev or ES.DEV then
      local tab = CreateTab(f, t.icon == "skills" and ES.SKILLS_ICON or t.icon ~= "flip" and t.icon or nil)
      if t.icon == "flip" then ES.UI.FlipIcon(tab.icon) end -- dos flechas (FlippingUI.lua)
      if #f.tabs == 0 then
        tab:SetPoint("TOPLEFT", f, "TOPRIGHT", 0, TAB_TOP)
      else
        tab:SetPoint("TOPLEFT", f.tabs[#f.tabs], "BOTTOMLEFT", 0, -TAB_GAP)
      end
      tab.key = t.key
      tab:SetScript("OnClick", function() ES:SelectPage(t.key) end)
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
end

function ES:SelectPage(key)
  if key == "lw" or key == "profit" then key = "Leatherworking" end -- nombres de versiones anteriores
  if not main or not main.pages[key] then key = "home" end
  if not ES.DEV and (key == "ah" or key == "flipping") then key = "home" end -- pestañas solo de desarrollo
  if not ES.DEV then -- profesiones solo de desarrollo (Pesca) y su colección
    for _, p in ipairs(ES.PROFESSIONS) do
      if p.dev and (key == p.key or key == "pattern:" .. p.key) then key = "home" end
    end
  end
  self.db.lastPage = key
  self.sessionPage = key -- lo que recuerda la ventana al volver a abrirla (solo esta sesión)
  for k, page in pairs(main.pages) do page:SetShown(k == key) end
  local tab, back = TabOf(key)
  for _, t in ipairs(main.tabs or {}) do t:SetChecked(t.key == tab) end
  -- "Volver" solo dentro de una pestaña (una profesión, la colección de una profesión)
  local inner = key ~= tab
  main.back:SetShown(inner)
  main.backTarget = back
  main.back:SetText(back == "patterns" and L["Colección"] or L["Profesiones"])
  main.navTitle:ClearAllPoints()
  if inner then
    main.navTitle:SetPoint("LEFT", main.back, "RIGHT", 12, 0)
  else
    main.navTitle:SetPoint("TOPLEFT", 22, -62)
  end
  main.navTitle:SetText(main.pageTitles[key] or "")
  if key == "home" then self:RenderHome() elseif key == "ah" then self:RenderResults() end
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
  self.homePage, self.earnPage, self.patternsPage, self.fishingPage = nil, nil, nil, nil
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

function ES:ToggleMainFrame()
  local f = self:GetMainFrame()
  f:SetShown(not f:IsShown())
end

---------------------------------------------------------------------------
-- Resultados
---------------------------------------------------------------------------
local function HideRows()
  for _, row in ipairs(main.rows) do row:Hide() end
  main.content:SetHeight(1)
end

function ES:RenderResults()
  if not main then return end
  local scan = self.db.scans[self:RealmKey()]

  -- Botones de franja y orden
  local windowKey = self.db.topWindow or "24h"
  local window = self.History.WINDOWS[1]
  for _, w in ipairs(self.History.WINDOWS) do
    if w.key == windowKey then window = w end
  end
  for _, b in ipairs(main.windowButtons) do
    if b.key == window.key then b:LockHighlight() else b:UnlockHighlight() end
  end
  -- Columna y sentido de orden; flecha en la cabecera activa
  local sort = self:GetTopSort()
  for _, h in ipairs(main.headers) do
    if h.key == sort.key then
      h.arrow:Show()
      if sort.asc then h.arrow:SetTexCoord(0, 0.5625, 1, 0) else h.arrow:SetTexCoord(0, 0.5625, 0, 1) end
      h.text:SetTextColor(1, 1, 1)
    else
      h.arrow:Hide()
      h.text:SetTextColor(1, 0.82, 0)
    end
  end

  local scans, _, firstTime = self.History:Summary()
  if not scan then
    main.summary:SetText("")
    main.empty:SetText(L["Todavía no hay datos.\nAbre la Casa de Subastas y pulsa \"Escanear\" arriba."])
    main.empty:Show()
    HideRows()
    return
  end

  local ahLabel = self:RealmKey():match("%-Neutral$") and L["AH neutral"] or L["AH de tu facción"]
  main.summary:SetText(string.format(
    L["%s · último escaneo %s (%d subastas) · %d escaneos guardados%s · alertas de mercado con 1-2 escaneos al día"],
    ahLabel, TimeAgo(scan.time), scan.total, scans, firstTime and (L[", el primero "] .. TimeAgo(firstTime)) or ""))

  -- Buscador: filtra por nombre (o número de objeto) mientras se escribe
  local query = strtrim(main.search:GetText() or ""):lower()
  local list, hidden, namesPending = {}, 0, false
  for itemID, current in pairs(scan.items) do
    if current.minUnit and self.History:IsTracked(itemID) then
      local name = self:GetItemData(itemID)
      if not name then namesPending = true end
      local matches = query == "" or (name and name:lower():find(query, 1, true))
        or tostring(itemID):find(query, 1, true)
      if not matches then
        hidden = hidden + 1
      else
        local oldMin, _, oldTime = self.History:OldestSnapshot(itemID, window.seconds)
        -- Precio típico: mediana de lo anunciado (no le mueve una subasta suelta)
        local nowPrice = current.median or current.minUnit
        local signals = self.Market:Signals(itemID)
        list[#list + 1] = {
          itemID = itemID, current = current, nowPrice = nowPrice, minUnit = current.minUnit,
          listings = current.listings, quantity = current.quantity,
          trend = (oldMin and oldMin > 0 and oldTime < scan.time) and (nowPrice - oldMin) / oldMin * 100 or nil,
          signals = signals, marketRank = VERDICT_RANK[signals.verdict] * 10 - signals.flags,
          sortName = name and name:lower() or nil, -- sin nombre cargado aún: al final
          oldMin = oldMin, oldTime = oldTime, windowLabel = window.label,
        }
      end
    end
  end
  main.pendingItems = namesPending

  if #list == 0 then
    main.empty:SetText(query ~= "" and (L["Nada en la AH coincide con \""] .. query .. "\".")
      or L["No hay objetos de profesiones en el último escaneo."])
    main.empty:Show()
    HideRows()
    return
  end
  main.empty:Hide()

  -- Ordenar por la columna elegida; los que no tienen ese dato van siempre al final
  local field = SORT_FIELDS[sort.key] or "listings"
  table.sort(list, function(a, b)
    local va, vb = a[field], b[field]
    if va == nil or vb == nil then
      if va ~= nil or vb ~= nil then return va ~= nil end
    elseif va ~= vb then
      if sort.asc then return va < vb else return va > vb end
    end
    return a.itemID < b.itemID
  end)
  if query ~= "" then
    main.summary:SetText(main.summary:GetText() .. string.format(L[" · búsqueda \"%s\": %d de %d objetos"], query, #list, #list + hidden))
  end

  local shown = math.min(MAX_ROWS, #list)
  if #list > MAX_ROWS then
    main.summary:SetText(main.summary:GetText() .. string.format(
      L["\n|cffff9933Se muestran los %d primeros de %d según el orden elegido: usa el buscador para ver uno concreto.|r"], MAX_ROWS, #list))
  end
  for i = 1, shown do
    local row = main.rows[i] or CreateRow(main.content, i)
    main.rows[i] = row
    local entry = list[i]
    local name, quality, texture = self:GetItemData(entry.itemID)

    row.itemID = entry.itemID
    row.icon:SetTexture(texture or 134400) -- interrogación
    if name then
      local color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality or 1]
      row.cells.name:SetText(name)
      if color then row.cells.name:SetTextColor(color.r, color.g, color.b) end
    else
      main.pendingItems = true
      row.cells.name:SetText(L["Cargando... ("] .. entry.itemID .. ")")
      row.cells.name:SetTextColor(0.6, 0.6, 0.6)
    end
    row.data = entry
    local risk = ES:PriceRisk(entry.itemID, entry.current)
    row.cells.price:SetText((risk and "|cffff8000! |r" or "") .. Money(entry.nowPrice))
    row.cells.min:SetText(Money(entry.minUnit))
    row.cells.listings:SetText(entry.listings)
    row.cells.quantity:SetText(entry.quantity)
    if entry.trend then
      local change = entry.trend
      local color = change > 2 and "|cff40ff40" or change < -2 and "|cffff6060" or "|cffcccccc"
      row.cells.trend:SetText(string.format("%s%+d%%|r", color, math.floor(change + 0.5)))
    else
      row.cells.trend:SetText("|cff888888—|r")
    end
    local s = entry.signals
    row.cells.market:SetText(ES.Market.LABELS[s.verdict] .. (s.flags > 0 and string.format(" |cff888888%d/%d|r", s.flags, ES.Market.SIGNALS) or ""))
    row:Show()
  end
  for i = shown + 1, #main.rows do main.rows[i]:Hide() end

  main.content:SetHeight(math.max(1, shown * ROW_HEIGHT))
end

function ES:OnScanStatus(text)
  if main then main.status:SetText(text or "") end
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
    if not self.ahOpen and not busy then
      main.status:SetText(L["Abre la Casa de Subastas para poder analizarla."])
    elseif self.ahOpen and not busy and not self.Scanner.statusText then
      main.status:SetText(L["Casa de Subastas abierta: listo para analizar."])
    end
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

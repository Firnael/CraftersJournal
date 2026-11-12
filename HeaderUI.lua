local _, ES = ...
local L = ES.L

-- Cabecera del panel: Informar a la izquierda, título en el centro, selector de
-- idioma a la derecha y botón de cerrar.

local GOLD = { 0.96, 0.79, 0.25 }

local function SetBackdrop(frame, edgeSize, inset)
  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = edgeSize,
    insets = { left = inset, right = inset, top = inset, bottom = inset },
  })
end

---------------------------------------------------------------------------
-- Idioma
---------------------------------------------------------------------------
local function CreateLanguage(f)
  -- Idiomas en ES.LANGS (Locale.lua); cada uno con su nombre en su idioma
  local current = ES.lang
  local function Label(code)
    for _, l in ipairs(ES.LANGS) do if l.key == code then return l.name end end
    return ES.LANGS[1].name
  end

  local button = CreateFrame("Button", nil, f, "BackdropTemplate")
  f.languageButton = button
  button:SetSize(110, 24)
  button:SetPoint("TOPRIGHT", -49, -15)
  SetBackdrop(button, 12, 4)
  button:SetBackdropColor(0.12, 0.115, 0.105, 0.98)
  button:SetBackdropBorderColor(0.48, 0.40, 0.27, 1)
  button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

  local caret = button:CreateTexture(nil, "OVERLAY")
  caret:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
  caret:SetSize(12, 12)
  caret:SetPoint("RIGHT", -7, -3)

  local text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  text:SetPoint("LEFT", 8, 0)
  text:SetPoint("RIGHT", -20, 0)
  text:SetJustifyH("CENTER")
  text:SetTextColor(1, 0.82, 0.27)
  text:SetText(Label(current))

  local menu = CreateFrame("Frame", nil, f, "BackdropTemplate")
  f.languageMenu = menu
  menu:SetSize(140, #ES.LANGS * 22 + 10)
  menu:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", 4, -4)
  menu:SetFrameStrata("TOOLTIP")
  SetBackdrop(menu, 12, 4)
  menu:SetBackdropColor(0.055, 0.05, 0.043, 0.99)
  menu:SetBackdropBorderColor(0.57, 0.43, 0.20, 1)
  menu:Hide()

  for i, lang in ipairs(ES.LANGS) do
    local option = CreateFrame("Button", nil, menu)
    option:SetPoint("TOPLEFT", 6, -5 - (i - 1) * 22)
    option:SetPoint("TOPRIGHT", -6, -5 - (i - 1) * 22)
    option:SetHeight(21)
    option:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    local label = option:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("LEFT", 10, 0)
    label:SetText(lang.name)
    label:SetTextColor(0.95, 0.83, 0.53)
    option:SetScript("OnClick", function()
      menu:Hide()
      if lang.key ~= ES.lang then
        text:SetText(lang.name)
        ES:SetLanguage(lang.key) -- se aplica al momento: la ventana se vuelve a crear
      end
    end)
  end

  button:SetScript("OnClick", function() menu:SetShown(not menu:IsShown()) end)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine(L["Idioma del addon"])
    GameTooltip:AddLine(L["Textos, recetas y objetos cambian al momento."], 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

---------------------------------------------------------------------------
-- Informar de un error: el juego no abre enlaces, así que se muestra el del
-- Discord seleccionado para copiarlo con Ctrl+C
---------------------------------------------------------------------------
ES.DISCORD_URL = "https://discord.gg/DjT4HatsF"
local BUG_ICON = "Interface\\HelpFrame\\HelpIcon-Bug"

local reportDialog
local function ReportDialog()
  if reportDialog then return reportDialog end
  local d = CreateFrame("Frame", "CraftersJournalReportDialog", UIParent, "BackdropTemplate")
  reportDialog = d
  d:SetSize(440, 200)
  d:SetPoint("CENTER", 0, 120)
  d:SetFrameStrata("DIALOG")
  d:EnableMouse(true)
  d:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  })
  tinsert(UISpecialFrames, "CraftersJournalReportDialog") -- Escape lo cierra
  d:Hide()

  d.title = d:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  d.title:SetPoint("TOP", 0, -22)
  d.text = d:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  d.text:SetPoint("TOP", d.title, "BOTTOM", 0, -12)
  d.text:SetWidth(390)
  d.label = d:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  d.label:SetPoint("TOP", d.text, "BOTTOM", 0, -14)

  local box = CreateFrame("EditBox", nil, d, "InputBoxTemplate")
  d.box = box
  box:SetSize(330, 22)
  box:SetPoint("TOP", d.label, "BOTTOM", 0, -6)
  box:SetAutoFocus(false)
  box:SetJustifyH("CENTER")
  -- Solo para copiar: si se escribe algo, vuelve el enlace
  box:SetScript("OnTextChanged", function(self, user)
    if user then self:SetText(ES.DISCORD_URL) self:HighlightText() end
  end)
  box:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
  box:SetScript("OnMouseUp", function(self) self:HighlightText() end)
  box:SetScript("OnEscapePressed", function() d:Hide() end)
  box:SetScript("OnEnterPressed", function() d:Hide() end)

  local ok = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
  d.ok = ok
  ok:SetSize(110, 24)
  ok:SetPoint("BOTTOM", 0, 20)
  ok:SetText(OKAY or "Ok")
  ok:SetScript("OnClick", function() d:Hide() end)

  d:SetScript("OnShow", function()
    -- Textos al mostrarse: el idioma puede haber cambiado
    d.title:SetText(L["Informar de un error"])
    d.text:SetText(L["¿Has visto información incorrecta, un error o algo nuevo que falte? Cuéntalo en el Discord con una captura de pantalla."])
    d.label:SetText(L["Discord (Ctrl+C para copiar):"])
    box:SetText(ES.DISCORD_URL)
    box:SetFocus()
    box:HighlightText()
  end)
  return d
end

function ES:ShowReportDialog()
  ReportDialog():Show()
end

local function CreateReport(f)
  local b = CreateFrame("Button", nil, f, "BackdropTemplate")
  f.reportButton = b
  b:SetSize(92, 24)
  b:SetPoint("TOPLEFT", 18, -15) -- a la izquierda del todo: a la derecha tapaba "Último escaneo"
  SetBackdrop(b, 12, 4)
  b:SetBackdropColor(0.12, 0.115, 0.105, 0.98)
  b:SetBackdropBorderColor(0.48, 0.40, 0.27, 1)
  b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  b.icon = b:CreateTexture(nil, "OVERLAY")
  b.icon:SetTexture(BUG_ICON)
  b.icon:SetSize(18, 18)
  b.icon:SetPoint("LEFT", 6, 0)
  b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  b.text:SetPoint("LEFT", b.icon, "RIGHT", 4, 0)
  b.text:SetPoint("RIGHT", -6, 0)
  b.text:SetTextColor(1, 0.82, 0.27)
  b.text:SetText(L["Informar"])
  b:SetScript("OnClick", function() ES:ShowReportDialog() end)
  b:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine(L["Informar de un error"])
    GameTooltip:AddLine(L["Errores, datos incorrectos o sugerencias: en nuestro Discord."], 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

---------------------------------------------------------------------------
-- Cabecera completa
---------------------------------------------------------------------------
function ES:CreateHeader(f)
  -- Banda marrón con líneas doradas arriba y abajo
  local band = f:CreateTexture(nil, "BACKGROUND", nil, 1)
  band:SetPoint("TOPLEFT", 12, -10)
  band:SetPoint("TOPRIGHT", -12, -10)
  band:SetHeight(34)
  band:SetColorTexture(0.14, 0.10, 0.055, 0.96)
  for _, edge in ipairs({ { "TOPLEFT", "TOPRIGHT", 0.65 }, { "BOTTOMLEFT", "BOTTOMRIGHT", 0.45 } }) do
    local line = f:CreateTexture(nil, "ARTWORK")
    line:SetPoint(edge[1], band, edge[1], 0, 0)
    line:SetPoint(edge[2], band, edge[2], 0, 0)
    line:SetHeight(1)
    line:SetColorTexture(0.68, 0.52, 0.20, edge[3])
  end

  -- Título, centrado en la cabecera
  local SCAN_W = 120
  f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  f.title:SetText("Crafter's Journal")
  f.title:SetTextColor(unpack(GOLD))
  f.title:SetPoint("TOP", f, "TOP", 0, -19)

  -- Escanear la AH: desde cualquier pestaña; en gris si la AH está cerrada. Debajo
  -- de la cabecera, a la derecha (bajo el idioma), en la franja del título de la
  -- página, que en todas las pantallas tiene libre ese lado.
  -- Mientras escanea, el botón muestra el % de progreso (ver RefreshScanButtons)
  local scan = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  scan:SetSize(SCAN_W, 22)
  scan:SetPoint("TOPRIGHT", f, "TOPRIGHT", -49, -59)
  scan:SetText(L["Escanear"])
  scan:SetMotionScriptsWhileDisabled(true) -- el tooltip explica por qué está gris
  scan:SetScript("OnClick", function() ES.Scanner:Start() end)
  scan:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine(L["Escanear la Casa de Subastas"])
    local wait = ES.Scanner:SecondsUntilNextScan()
    if ES.Scanner:IsBusy() then
      GameTooltip:AddLine(L["Escaneo en curso."], 0.8, 0.8, 0.8, true)
    elseif wait > 0 then
      GameTooltip:AddLine(string.format(L["El servidor solo permite un escaneo completo cada 15 min: podrás volver a escanear en %s."],
        ES.Countdown(wait)), 1, 0.6, 0.2, true)
    elseif not ES:IsAuctionHouseOpen() then
      GameTooltip:AddLine(L["Abre la Casa de Subastas para poder escanearla."], 1, 0.6, 0.2, true)
    else
      GameTooltip:AddLine(L["Descarga todas las subastas y actualiza precios, rutas y alertas."], 0.8, 0.8, 0.8, true)
    end
    local fail = ES:LastScanFail()
    if fail and fail.reason then
      GameTooltip:AddLine(string.format(L["Último intento (%s): %s"], date("%H:%M", fail.time), fail.reason), 1, 0.6, 0.2, true)
    end
    GameTooltip:Show()
  end)
  scan:SetScript("OnLeave", function() GameTooltip:Hide() end)
  scan:SetEnabled(false)
  f.scanButton = scan

  -- "Último escaneo: hace 3 min", en pequeño a la izquierda del botón; se actualiza cada 30 s
  f.lastScan = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  f.lastScan:SetPoint("RIGHT", scan, "LEFT", -10, 0)
  f.lastScan:SetWidth(170) -- cabe "Cancelado · último: hace 2 días"
  f.lastScan:SetJustifyH("RIGHT")
  f.lastScan:SetWordWrap(false)
  local ticker = CreateFrame("Frame", nil, f)
  ticker.elapsed = 0
  ticker:SetScript("OnUpdate", function(self, delta)
    self.elapsed = self.elapsed + (delta or 0)
    if self.elapsed < 30 then return end
    self.elapsed = 0
    ES:UpdateLastScan()
  end)

  CreateLanguage(f)
  CreateReport(f)

  local close =CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -3, -3)
  f.closeButton = close
end

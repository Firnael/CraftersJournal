local _, ES = ...
local L = ES.L

-- Panel del addon en Opciones > AddOns > Crafter's Journal.
--   Para todos: "Fabricar al pulsar un paso de la ruta" (por defecto, sí).
--   En la copia de desarrollo (ES.DEV_BUILD), además el interruptor "Vista jugador",
--   para ver el addon como lo verá quien se lo baje de CurseForge (fuera de la
--   ventana del addon, así no sale en las capturas).

local panel = CreateFrame("Frame")
panel.name = "Crafter's Journal"
ES.optionsPanel = panel

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Crafter's Journal")

local help = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
help:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
help:SetPoint("RIGHT", -16, 0)
help:SetJustifyH("LEFT")

-- Casilla con su texto y una nota gris debajo
local function Option(anchor, onClick)
  local check = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
  check:SetSize(26, 26)
  check:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == help and -4 or 0, -18)
  check:SetScript("OnClick", onClick)
  check.label = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  check.label:SetPoint("LEFT", check, "RIGHT", 2, 1)
  check.note = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  check.note:SetPoint("TOPLEFT", check, "BOTTOMLEFT", 30, -2)
  check.note:SetPoint("RIGHT", -16, 0)
  check.note:SetJustifyH("LEFT")
  check.note:SetTextColor(0.75, 0.75, 0.75)
  return check
end

-- Fabricar al pulsar un paso de la ruta
panel.craftCheck = Option(help, function(self)
  ES.db.autoCraft = self:GetChecked() and true or false
  if ES.RefreshProfessionPages then ES:RefreshProfessionPages() end
end)

if ES.DEV_BUILD then
  panel.devCheck = Option(panel.craftCheck.note, function(self) ES:SetUserPreview(self:GetChecked() and true or false) end)
end

-- Textos al mostrarse (el idioma puede haber cambiado) y estado de las casillas
panel:SetScript("OnShow", function()
  help:SetText(L["Escribe /cj o pulsa el botón del minimapa para abrir el diario."])
  panel.craftCheck.label:SetText(L["Fabricar al pulsar un paso de la ruta"])
  panel.craftCheck.note:SetText(L["Un clic en un paso abre la receta en tu profesión y fabrica las que faltan para ese paso. Desactivado, el clic solo abre la receta."])
  panel.craftCheck:SetChecked(ES:AutoCraft())
  if panel.devCheck then
    panel.devCheck.label:SetText(L["Vista jugador: ver el addon como en CurseForge"])
    panel.devCheck:SetChecked(not ES.DEV)
    panel.devCheck.note:SetText(L["Solo en tu copia de desarrollo. Marcado: sin Ganar dinero, Subastas, Flipping, Pesca ni buscador, como en la versión publicada."])
  end
end)

if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
  local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
  Settings.RegisterAddOnCategory(category)
elseif InterfaceOptions_AddCategory then
  InterfaceOptions_AddCategory(panel)
end

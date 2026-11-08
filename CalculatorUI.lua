local _, ES = ...
local L = ES.L

-- Pestaña "Calculadora" (Calculator.lua): a la izquierda, tus cálculos guardados con su
-- beneficio (✕ para borrar); a la derecha, la hoja del elegido: materiales en crudo,
-- cantidad, precio (casilla: se puede escribir), de dónde sale y total; venta,
-- comisión, depósito y beneficio. Arriba, un buscador para añadir recetas.

local Calc = ES.Calc
local GREY, ORANGE, GOLD = "|cff999999", "|cffff9933", "|cffffd100"
local LIST_W = 250
local ROW_H = 30      -- filas de material: casillas de 20 px con aire arriba y abajo
local LINE_H = 26     -- líneas de resumen (materiales, venta, comisión, depósito)
local MAX_RESULTS = 8

local function Money(c) return ES.Money(c) end

-- Nombre e icono de la receta de un cálculo
local function RecipeLabel(c)
  local data = ES.Data[c.prof]
  local r = data and data.recipes and data.recipes[c.recipe]
  if not r then return L["Receta desconocida"], ES.ICON end
  local _, _, texture = ES:GetItemData(r.out and r.out[1] or 0)
  local prof
  for _, p in ipairs(ES.PROFESSIONS) do if p.key == c.prof then prof = p end end
  return r.name or ("#" .. c.recipe), texture or (prof and prof.icon) or ES.ICON
end

local function SourceText(res, source)
  if source == "manual" then return GOLD .. L["a mano"] .. "|r" end
  if source == "ah" then return L["AH"] end
  if source == "vendor" then
    if res.discount > 0 then -- la ciudad, en la nota de abajo: aquí no cabe
      return string.format(L["vendedor −%d%%"], math.floor(res.discount * 100 + 0.5))
    end
    return L["vendedor"]
  end
  return ORANGE .. L["sin precio"] .. "|r"
end

-- Precio con tres casillas, oro, plata y cobre, cada una con su icono (como el correo
-- del juego). Al pulsar Intro o salir de una casilla, `commit(cobre)`; con las tres
-- vacías, commit(nil): vuelve al precio automático. Tab pasa a la siguiente.
local COIN_ICONS = { "Interface\\MoneyFrame\\UI-GoldIcon", "Interface\\MoneyFrame\\UI-SilverIcon", "Interface\\MoneyFrame\\UI-CopperIcon" }
local BOX_W = { 40, 28, 28 }  -- oro (hasta 5 cifras), plata y cobre (2)
local ICON_GAP, COIN_GAP = 4, 9 -- casilla → icono, icono → siguiente casilla
-- Ancho de las tres casillas con sus iconos (el marco de la plantilla sobresale ~6 px a la izquierda)
local MONEY_W = 6 + BOX_W[1] + BOX_W[2] + BOX_W[3] + 3 * (ICON_GAP + 12) + 2 * COIN_GAP
local function MoneyInput(parent, commit)
  local input = CreateFrame("Frame", nil, parent)
  input:SetSize(MONEY_W, 20)
  local widths, maxLetters = BOX_W, { 5, 2, 2 }
  local boxes, x = {}, 6
  local function Value()
    local g, s, c = tonumber(boxes[1]:GetText()), tonumber(boxes[2]:GetText()), tonumber(boxes[3]:GetText())
    if not g and not s and not c then return nil end
    return (g or 0) * 10000 + math.min(s or 0, 99) * 100 + math.min(c or 0, 99)
  end
  local function Save()
    if input.saving then return end
    input.saving = true
    commit(Value())
    input.saving = false
  end
  for i = 1, 3 do
    local box = CreateFrame("EditBox", nil, input, "InputBoxTemplate")
    box:SetSize(widths[i], 20)
    box:SetPoint("LEFT", x, 0)
    box:SetAutoFocus(false)
    box:SetNumeric(true)
    box:SetMaxLetters(maxLetters[i])
    box:SetJustifyH("RIGHT")
    local icon = input:CreateTexture(nil, "ARTWORK")
    icon:SetSize(12, 12)
    icon:SetPoint("LEFT", box, "RIGHT", ICON_GAP, 0)
    icon:SetTexture(COIN_ICONS[i])
    x = x + widths[i] + ICON_GAP + 12 + COIN_GAP
    box:SetScript("OnEnterPressed", function(self) self.leaving = true self:ClearFocus() Save() self.leaving = false end)
    box:SetScript("OnEditFocusLost", function(self)
      -- Pasar a otra casilla del mismo precio (Tab) no guarda todavía
      C_Timer.After(0, function()
        for _, b in ipairs(boxes) do if b:HasFocus() == true then return end end
        Save()
      end)
    end)
    box:SetScript("OnTabPressed", function() boxes[i % 3 + 1]:SetFocus() end)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() ES:RenderCalculator() end)
    box:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:AddLine(L["Escribe el precio por unidad"])
      GameTooltip:AddLine(L["Oro, plata y cobre; Tab pasa a la siguiente casilla. Con las tres vacías vuelve al precio automático."], 0.8, 0.8, 0.8, true)
      GameTooltip:Show()
    end)
    box:SetScript("OnLeave", function() GameTooltip:Hide() end)
    boxes[i] = box
  end
  input.g, input.s, input.c = boxes[1], boxes[2], boxes[3]
  -- Pone el precio, salvo si estás escribiendo en alguna de sus casillas
  function input:SetValue(copper)
    for _, b in ipairs(boxes) do if b:HasFocus() == true then return end end
    if not copper then
      for _, b in ipairs(boxes) do b:SetText("") end
      return
    end
    copper = math.floor(copper + 0.5)
    local g, s, c = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
    boxes[1]:SetText(g > 0 and tostring(g) or "")
    boxes[2]:SetText((g > 0 or s > 0) and tostring(s) or "")
    boxes[3]:SetText(tostring(c))
  end
  return input
end

---------------------------------------------------------------------------
-- Buscador: recetas de todas las profesiones; primero las que sabes
---------------------------------------------------------------------------
local function SearchRecipes(query)
  query = query:lower()
  local out = {}
  for _, prof in ipairs(ES.PROFESSIONS) do
    local data = ES.Data[prof.key]
    if data and data.recipes and not data.guide then
      for id, r in pairs(data.recipes) do
        if not r.conversion and ((r.name or ""):lower():find(query, 1, true) or (r.nameEN or ""):lower():find(query, 1, true)) then
          out[#out + 1] = { prof = prof.key, id = id, recipe = r, known = ES:IsRecipeKnown(id) }
        end
      end
    end
  end
  table.sort(out, function(a, b)
    if a.known ~= b.known then return a.known end
    if a.prof ~= b.prof then return a.prof < b.prof end
    return (a.recipe.train or 0) < (b.recipe.train or 0)
  end)
  return out
end

local function CreateSearch(page, head)
  local box = CreateFrame("EditBox", nil, head, "InputBoxTemplate")
  page.search = box
  box:SetSize(240, 22)
  box:SetPoint("RIGHT", -16, 0)
  box:SetAutoFocus(false)
  local hint = ES.UI.Label(box, L["Añadir receta: escribe su nombre"], "GameFontDisableSmall")
  hint:SetPoint("LEFT", 4, 0)

  local list = CreateFrame("Frame", nil, page, "BackdropTemplate")
  page.results = list
  list:SetPoint("TOPRIGHT", box, "BOTTOMRIGHT", 4, -2)
  list:SetWidth(320)
  list:SetFrameStrata("TOOLTIP")
  list:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
  list:SetBackdropColor(0.045, 0.042, 0.037, 0.995)
  list:SetBackdropBorderColor(0.48, 0.40, 0.27, 1)
  list:Hide()
  list.rows = {}

  local function Row(i)
    local row = list.rows[i]
    if row then return row end
    row = CreateFrame("Button", nil, list)
    row:SetHeight(22)
    row:SetPoint("TOPLEFT", 5, -5 - (i - 1) * 22)
    row:SetPoint("TOPRIGHT", -5, -5 - (i - 1) * 22)
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(18, 18)
    row.icon:SetPoint("LEFT", 4, 0)
    row.text = ES.UI.Label(row, "", "GameFontHighlight")
    row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
    row.text:SetPoint("RIGHT", -80, 0)
    row.text:SetJustifyH("LEFT")
    row.text:SetWordWrap(false)
    row.sub = ES.UI.Label(row, "", "GameFontDisableSmall")
    row.sub:SetPoint("RIGHT", -6, 0)
    row:SetScript("OnClick", function(self)
      if not self.result then return end
      Calc:Add(self.result.prof, self.result.id)
      box:SetText("")
      box:ClearFocus()
      list:Hide()
      ES:RenderCalculator()
    end)
    list.rows[i] = row
    return row
  end

  local function Refresh()
    local text = strtrim(box:GetText() or "")
    hint:SetShown(text == "")
    if text:len() < 2 then list:Hide() return end
    local results = SearchRecipes(text)
    local shown = math.min(MAX_RESULTS, #results)
    for i = 1, shown do
      local res, row = results[i], Row(i)
      row.result = res
      local _, _, texture = ES:GetItemData(res.recipe.out and res.recipe.out[1] or 0)
      row.icon:SetTexture(texture or ES.ICON)
      row.text:SetText(res.recipe.name)
      row.text:SetTextColor(res.known and 1 or 0.6, res.known and 1 or 0.6, res.known and 1 or 0.6)
      row.sub:SetText(ES:ProfLabel(res.prof))
      row:Show()
    end
    for i = shown + 1, #list.rows do list.rows[i]:Hide() end
    if shown == 0 then
      local row = Row(1)
      row.result = nil
      row.icon:SetTexture(nil)
      row.text:SetText(L["Sin resultados"])
      row.text:SetTextColor(0.5, 0.5, 0.5)
      row.sub:SetText("")
      row:Show()
      shown = 1
    end
    list:SetHeight(10 + shown * 22)
    list:Show()
  end
  box:SetScript("OnTextChanged", Refresh)
  box:SetScript("OnEscapePressed", function(self) self:SetText("") self:ClearFocus() list:Hide() end)
  box:SetScript("OnEnterPressed", function(self)
    local first = list.rows[1]
    if list:IsShown() and first and first.result then first:GetScript("OnClick")(first) else self:ClearFocus() end
  end)
  box:SetScript("OnEditFocusLost", function()
    C_Timer.After(0.2, function() if box:HasFocus() ~= true then list:Hide() end end)
  end)
  page.searchRefresh = Refresh
end

---------------------------------------------------------------------------
-- Lista de cálculos guardados
---------------------------------------------------------------------------
local function SavedRow(page, i)
  local row = page.saved[i]
  if row then return row end
  row = CreateFrame("Button", nil, page.listPanel)
  row:SetHeight(36)
  row:SetPoint("TOPLEFT", 6, -6 - (i - 1) * 38)
  row:SetPoint("TOPRIGHT", -6, -6 - (i - 1) * 38)
  row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  row.sel = row:CreateTexture(nil, "BACKGROUND")
  row.sel:SetAllPoints()
  row.sel:SetColorTexture(0.8, 0.6, 0.2, 0.18)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(28, 28)
  row.icon:SetPoint("LEFT", 4, 0)
  row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  row.name = ES.UI.Label(row, "", "GameFontHighlightSmall")
  row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, -1)
  row.name:SetPoint("RIGHT", -24, 0)
  row.name:SetJustifyH("LEFT")
  row.name:SetWordWrap(false)
  row.profit = ES.UI.Label(row, "", "GameFontHighlightSmall")
  row.profit:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 6, 1)
  row.del = CreateFrame("Button", nil, row)
  row.del:SetSize(16, 16)
  row.del:SetPoint("RIGHT", -4, 0)
  row.del:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
  row.del:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
  row.del.row = row
  row.del:SetScript("OnClick", function(self)
    Calc:Remove(self.row.calcID)
    ES:RenderCalculator()
  end)
  row.del:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Borrar este cálculo"])
    GameTooltip:Show()
  end)
  row.del:SetScript("OnLeave", function() GameTooltip:Hide() end)
  row:SetScript("OnClick", function(self)
    Calc:Select(self.calcID)
    ES:RenderCalculator()
  end)
  page.saved[i] = row
  return row
end

---------------------------------------------------------------------------
-- Hoja del cálculo elegido
---------------------------------------------------------------------------
-- Columnas (x desde la izquierda del panel; el total, pegado a la derecha). La hoja
-- mide ~610 px con la ventana de 840: nombre 130, cantidad 36 (14 de aire), precio
-- ~170, 12 de aire, de dónde 78 y el total, ~100 a la derecha
local COL_NAME, COL_QTY_RIGHT = 36, 208
local COL_PRICE = COL_QTY_RIGHT + 14
local COL_SOURCE = COL_PRICE + MONEY_W + 12
local SOURCE_W = 78

local function SheetRow(page, i)
  local row = page.sheetRows[i]
  if row then return row end
  local p = page.sheet
  row = CreateFrame("Frame", nil, p)
  row:SetHeight(ROW_H)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(20, 20)
  row.icon:SetPoint("LEFT", 10, 0)
  row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  row.name = ES.UI.Label(row, "", "GameFontHighlightSmall")
  row.name:SetPoint("LEFT", COL_NAME, 0)
  row.name:SetWidth(COL_QTY_RIGHT - 42 - COL_NAME)
  row.name:SetJustifyH("LEFT")
  row.name:SetWordWrap(false)
  row.qty = ES.UI.Label(row, "", "GameFontHighlightSmall")
  row.qty:SetPoint("RIGHT", row, "LEFT", COL_QTY_RIGHT, 0)
  row.qty:SetWidth(36)
  row.qty:SetJustifyH("RIGHT")
  row.box = MoneyInput(row, function(copper)
    local c = Calc:Selected()
    if not c or not row.itemID then return end
    c.prices[row.itemID] = copper -- nil: vuelve al automático
    ES:RenderCalculator()
  end)
  row.box:SetPoint("LEFT", COL_PRICE, 0)
  row.source = ES.UI.Label(row, "", "GameFontDisableSmall")
  row.source:SetPoint("LEFT", COL_SOURCE, 0)
  row.source:SetWidth(SOURCE_W)
  row.source:SetJustifyH("LEFT")
  row.source:SetWordWrap(false)
  row.total = ES.UI.Label(row, "", "GameFontHighlightSmall")
  row.total:SetPoint("RIGHT", -14, 0)
  row.total:SetJustifyH("RIGHT")
  page.sheetRows[i] = row
  return row
end

-- Línea de resumen (etiqueta a la izquierda, importe a la derecha)
local function SummaryLine(p, template)
  local line = CreateFrame("Frame", nil, p)
  line:SetHeight(LINE_H)
  line.label = ES.UI.Label(line, "", template or "GameFontHighlightSmall")
  line.label:SetPoint("LEFT", COL_NAME, 0)
  line.label:SetJustifyH("LEFT")
  line.value = ES.UI.Label(line, "", template or "GameFontHighlightSmall")
  line.value:SetPoint("RIGHT", -14, 0)
  line.value:SetJustifyH("RIGHT")
  return line
end

local function CreateSheet(page)
  local p = page.sheet
  page.title = ES.UI.Label(p, "", "GameFontNormalLarge")
  page.title:SetPoint("TOPLEFT", 14, -12)
  page.title:SetPoint("RIGHT", -170, 0)
  page.title:SetJustifyH("LEFT")
  page.title:SetWordWrap(false)
  page.titleSub = ES.UI.Label(p, "", "GameFontDisableSmall")
  page.titleSub:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -3)

  -- Fabricaciones
  local qtyLabel = ES.UI.Label(p, L["Fabricaciones"], "GameFontNormalSmall")
  qtyLabel:SetPoint("TOPRIGHT", -84, -14)
  page.qty = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
  page.qty:SetSize(50, 20)
  page.qty:SetPoint("LEFT", qtyLabel, "RIGHT", 8, 0)
  page.qty:SetAutoFocus(false)
  page.qty:SetNumeric(true)
  page.qty:SetJustifyH("CENTER")
  local function SaveQty(self)
    local c, n = Calc:Selected(), tonumber(self:GetText())
    if c and n and n >= 1 then c.qty = math.min(n, 9999) end
    ES:RenderCalculator()
  end
  page.qty:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  page.qty:SetScript("OnEditFocusLost", SaveQty)

  -- Cabecera de columnas
  local head = CreateFrame("Frame", nil, p)
  head:SetHeight(18)
  head:SetPoint("TOPLEFT", 6, -54)
  head:SetPoint("TOPRIGHT", -6, -54)
  for _, col in ipairs({ { L["Material"], COL_NAME, "LEFT" }, { L["Cantidad"], COL_QTY_RIGHT, "RIGHT" },
    { L["Precio por unidad"], COL_PRICE + 6, "LEFT" }, { L["De dónde"], COL_SOURCE, "LEFT" } }) do
    local fs = ES.UI.Label(head, col[1], "GameFontNormalSmall")
    fs:SetPoint(col[3], head, "LEFT", col[2], 0)
  end
  local totalHead = ES.UI.Label(head, L["Total"], "GameFontNormalSmall")
  totalHead:SetPoint("RIGHT", -14, 0)
  page.colHead = head

  page.sheetRows = {}
  page.matTotal = SummaryLine(p)
  -- Venta: casilla del precio por unidad
  page.saleLine = SummaryLine(p)
  page.saleLine.label:SetWidth(COL_PRICE - COL_NAME - 8)
  page.saleLine.label:SetWordWrap(false)
  page.saleBox = MoneyInput(page.saleLine, function(copper)
    local c = Calc:Selected()
    if not c then return end
    c.sale = copper -- nil: vuelve al automático
    ES:RenderCalculator()
  end)
  page.saleBox:SetPoint("LEFT", COL_PRICE, 0)
  page.saleSource = ES.UI.Label(page.saleLine, "", "GameFontDisableSmall")
  page.saleSource:SetPoint("LEFT", COL_SOURCE, 0)
  page.saleSource:SetWidth(SOURCE_W)
  page.saleSource:SetJustifyH("LEFT")
  page.saleSource:SetWordWrap(false)
  page.cutLine = SummaryLine(p)
  page.depositLine = SummaryLine(p)
  -- Duración de la subasta: 2 h · 8 h · 24 h (botones unidos; el elegido, en dorado)
  local seg = CreateFrame("Frame", nil, page.depositLine)
  seg:SetSize(3 * 44 + 4, 20)
  seg:SetPoint("LEFT", COL_PRICE + 6, 0)
  seg.buttons = {}
  for i, hours in ipairs(Calc.DURATIONS) do
    local b = CreateFrame("Button", nil, seg, "BackdropTemplate")
    b:SetSize(44, 20)
    b:SetPoint("LEFT", (i - 1) * 46, 0)
    b:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    b.text = ES.UI.Label(b, string.format(L["%d h"], hours), "GameFontHighlightSmall")
    b.text:SetPoint("CENTER", 0, 0)
    b.hours = hours
    b:SetScript("OnClick", function(self)
      local c = Calc:Selected()
      if c then c.hours = self.hours end
      ES:RenderCalculator()
    end)
    b:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:AddLine(string.format(L["Subasta de %d h"], self.hours))
      GameTooltip:AddLine(string.format(L["Depósito: el %d%% del precio de vendedor. Se devuelve si se vende; lo pierdes si caduca o la cancelas."],
        Calc.DepositPct(self.hours)), 0.8, 0.8, 0.8, true)
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    seg.buttons[i] = b
  end
  function seg:SetSelected(hours)
    for _, b in ipairs(self.buttons) do
      local on = b.hours == hours
      b:SetBackdropColor(on and 0.55 or 0.10, on and 0.40 or 0.08, on and 0.12 or 0.06, 0.95)
      b:SetBackdropBorderColor(0.52, 0.38, 0.17, 1)
      b.text:SetTextColor(on and 1 or 0.75, on and 0.85 or 0.72, on and 0.35 or 0.65)
    end
  end
  page.duration = seg
  page.profitLine = SummaryLine(p, "GameFontNormalLarge")
  page.note = ES.UI.Label(p, "", "GameFontDisableSmall")
  page.note:SetJustifyH("LEFT")

  page.reset = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  page.reset:SetSize(170, 22)
  page.reset:SetPoint("BOTTOMRIGHT", -12, 10)
  page.reset:SetText(L["Precios automáticos"])
  page.reset:SetScript("OnClick", function()
    local c = Calc:Selected()
    if c then c.prices, c.sale = {}, nil end
    ES:RenderCalculator()
  end)
  page.reset:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine(L["Borra los precios que has escrito en este cálculo y vuelve a los del último escaneo y el vendedor."], 1, 1, 1, true)
    GameTooltip:Show()
  end)
  page.reset:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function ES:CreateCalculatorPage(page)
  local UI = ES.UI
  page.group = UI.GroupPanel(page)
  local head = UI.Panel(page, UI.BROWN.card[1], UI.BROWN.card[2], UI.BROWN.card[3], UI.BROWN.card[4])
  head:SetPoint("TOPLEFT", UI.PAD, -UI.PAD + 2)
  head:SetPoint("TOPRIGHT", -UI.PAD, -UI.PAD + 2)
  head:SetHeight(66)
  local icon = head:CreateTexture(nil, "ARTWORK")
  icon:SetSize(44, 44)
  icon:SetPoint("LEFT", 12, 0)
  icon:SetTexture("Interface\\Icons\\INV_Misc_Note_02")
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  local title = UI.Label(head, L["Calculadora"], "GameFontNormalHuge")
  title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, 2)
  title:SetTextColor(0.96, 0.79, 0.25)
  local sub = UI.Label(head, L["Cuánto ganas con una receta: materiales en crudo, venta, comisión y depósito. Escribe tus precios si la AH ha cambiado."], "GameFontHighlightSmall")
  sub:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 12, 2)
  sub:SetPoint("RIGHT", -270, 0)
  sub:SetJustifyH("LEFT")
  CreateSearch(page, head)

  page.listPanel = UI.Panel(page, 0.07, 0.05, 0.03, 0.9)
  page.listPanel:SetPoint("TOPLEFT", head, "BOTTOMLEFT", 0, -8)
  page.listPanel:SetPoint("BOTTOMLEFT", UI.PAD, UI.PAD)
  page.listPanel:SetWidth(LIST_W)
  page.saved = {}
  page.listEmpty = UI.Label(page.listPanel, L["Aún no tienes cálculos. Busca una receta arriba a la derecha para añadir el primero."], "GameFontDisable")
  page.listEmpty:SetPoint("TOPLEFT", 12, -14)
  page.listEmpty:SetPoint("RIGHT", -12, 0)
  page.listEmpty:SetJustifyH("LEFT")

  page.sheet = UI.Panel(page, 0.07, 0.05, 0.03, 0.9)
  page.sheet:SetPoint("TOPLEFT", page.listPanel, "TOPRIGHT", 8, 0)
  page.sheet:SetPoint("BOTTOMRIGHT", -UI.PAD, UI.PAD)
  CreateSheet(page)

  page:SetScript("OnShow", function() ES:RenderCalculator() end)
  -- Llegan nombres e iconos que faltaban: se repinta
  ES.SafeRegister(page, "GET_ITEM_INFO_RECEIVED")
  page:SetScript("OnEvent", function(self)
    if self.pendingItems and not self.refreshQueued then
      self.refreshQueued = true
      C_Timer.After(0.5, function()
        self.refreshQueued = false
        if self:IsVisible() then ES:RenderCalculator() end
      end)
    end
  end)
  self.calculatorPage = page
end

local function Qty(n)
  if math.abs(n - math.floor(n + 0.5)) < 0.01 then return tostring(math.floor(n + 0.5)) end
  return string.format("%.1f", n)
end

function ES:RenderCalculator()
  local page = self.calculatorPage
  if not page or not page:IsVisible() then return end
  page.pendingItems = false
  local Signed = ES.UI.Signed

  -- Lista de guardados
  local list = Calc:List()
  local selected = Calc:Selected()
  for i, c in ipairs(list) do
    local row = SavedRow(page, i)
    row.calcID = c.id
    local name, texture = RecipeLabel(c)
    row.icon:SetTexture(texture)
    row.name:SetText(string.format("%s %s×%d|r", name, GREY, c.qty or 1))
    local res = Calc:Compute(c)
    row.profit:SetText(res and (Signed(-res.profit) .. (res.missing and (ORANGE .. " *|r") or "")) or "")
    row.sel:SetShown(selected and selected.id == c.id or false)
    row:Show()
  end
  for i = #list + 1, #page.saved do page.saved[i]:Hide() end
  page.listEmpty:SetShown(#list == 0)

  -- Hoja
  local res = selected and Calc:Compute(selected)
  local showSheet = res ~= nil
  for _, w in ipairs({ page.title, page.titleSub, page.qty, page.colHead, page.matTotal, page.saleLine, page.cutLine,
    page.depositLine, page.profitLine, page.note, page.reset }) do w:SetShown(showSheet) end
  if not showSheet then
    for _, row in ipairs(page.sheetRows) do row:Hide() end
    return
  end

  local name = RecipeLabel(selected)
  page.title:SetText(name)
  page.titleSub:SetText(ES:ProfLabel(selected.prof)
    .. (ES:IsRecipeKnown(selected.recipe) and "" or (ORANGE .. " · " .. L["no la sabes"] .. "|r")))
  if page.qty:HasFocus() ~= true then page.qty:SetText(tostring(selected.qty or 1)) end

  local y = -78
  for i, r in ipairs(res.rows) do
    local row = SheetRow(page, i)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 6, y)
    row:SetPoint("TOPRIGHT", -6, y)
    y = y - ROW_H
    row.itemID = r.itemID
    local label, texture, pending = ES.UI.ItemLabel(r.itemID, L["Objeto "] .. r.itemID)
    if pending then page.pendingItems = true end
    row.icon:SetTexture(texture or 134400)
    row.name:SetText(label)
    row.qty:SetText(Qty(r.qty))
    row.box:SetValue(r.price)
    row.source:SetText(SourceText(res, r.source))
    row.total:SetText(r.total and Money(r.total) or (ORANGE .. "?|r"))
    row:Show()
  end
  for i = #res.rows + 1, #page.sheetRows do page.sheetRows[i]:Hide() end

  local function Place(line, gap)
    y = y - (gap or 0)
    line:ClearAllPoints()
    line:SetPoint("TOPLEFT", 6, y)
    line:SetPoint("TOPRIGHT", -6, y)
    y = y - LINE_H
  end
  Place(page.matTotal, 8)
  page.matTotal.label:SetText(L["Materiales"])
  page.matTotal.value:SetText(Signed(res.cost))

  Place(page.saleLine, 4)
  if res.outID then
    local outLabel = ES.UI.ItemLabel(res.outID, L["Objeto "] .. res.outID)
    page.saleLine.label:SetText(string.format(L["Venta: %s × %s"], Qty(res.outN), outLabel))
    page.saleBox:SetValue(res.sale)
    page.saleBox:Show()
    page.saleSource:SetText(SourceText(res, res.saleSource))
    page.saleLine.value:SetText(Signed(-res.revenue))
  else
    page.saleLine.label:SetText(L["No fabrica un objeto que se pueda vender (encantamiento)."])
    page.saleBox:Hide()
    page.saleSource:SetText("")
    page.saleLine.value:SetText("")
  end

  Place(page.cutLine)
  page.cutLine.label:SetText(string.format(L["Comisión de la AH (%d%%)"], math.floor(res.cutRate * 100 + 0.5)))
  page.cutLine.value:SetText(res.cut > 0 and Signed(res.cut) or (GREY .. "—|r"))
  -- El depósito se devuelve al venderse: no resta, se enseña en gris (lo que arriesgas)
  Place(page.depositLine)
  page.depositLine.label:SetText(L["Depósito"])
  page.depositLine.value:SetText(res.deposit > 0 and (GREY .. ES.Money(res.deposit) .. "|r") or (GREY .. "—|r"))
  page.duration:SetSelected(res.hours)
  page.duration:SetShown(res.outID ~= nil and res.saleSource ~= "vendor")
  Place(page.profitLine, 8)
  page.profitLine.label:SetText(L["Beneficio"])
  page.profitLine.value:SetText(Signed(-res.profit))

  local notes = {}
  if res.deposit > 0 then
    notes[#notes + 1] = string.format(L["Depósito de %d h: el %d%% del precio de vendedor. Se devuelve si se vende (no resta del beneficio); lo pierdes si caduca."],
      res.hours, res.depositPct)
  end
  if #res.made > 0 then
    local parts = {}
    for _, m in ipairs(res.made) do parts[#parts + 1] = Qty(m.qty) .. "× " .. (ES.UI.ItemLabel(m.itemID, "#" .. m.itemID)) end
    notes[#notes + 1] = string.format(L["Lo fabricas tú (ya desglosado en sus materiales): %s."], table.concat(parts, ", "))
  end
  if res.missing then notes[#notes + 1] = ORANGE .. L["Algún material no tiene precio (ni en el escaneo ni en el vendedor): escríbelo para que cuente."] .. "|r" end
  if res.discount > 0 then
    notes[#notes + 1] = string.format(L["Precios de vendedor con el descuento de tu reputación con %s (−%d%%)."], res.city or "", math.floor(res.discount * 100 + 0.5))
  end
  page.note:ClearAllPoints()
  page.note:SetPoint("TOPLEFT", 14, y - 6)
  page.note:SetPoint("RIGHT", -14, 0)
  page.note:SetText(table.concat(notes, "\n"))
end

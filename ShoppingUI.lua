local _, ES = ...
local L = ES.L

-- Pestaña "Lista de compra": las listas que has añadido (Shopping.lua), una sección
-- por cada una, con su progreso. Con la AH abierta, clic en un material (o "Comprar
-- siguiente") abre su compra de Blizzard con la cantidad puesta; confirmas tú.

local GREEN, GREY, ORANGE = "|cff40ff40", "|cff999999", "|cffff9933"

local selected -- el material cuya compra se abrió el último

local function Buy(itemID, left, unit)
  if not (itemID and ES:IsAuctionHouseOpen()) then return end
  selected = itemID
  ES:OpenAuctionBuy(itemID, left, unit)
  ES:RenderShopping()
end

function ES:ShoppingBuyNext()
  local itemID, left, unit = ES.Shopping.NextToBuy(ES.Shopping.Status(), selected)
  Buy(itemID, left, unit)
  return itemID
end

local KIND_ICON = {
  route = "Interface\\Icons\\Trade_BlackSmithing",
  money = "Interface\\Icons\\INV_Misc_Coin_02",
  calc = "Interface\\Icons\\INV_Misc_Note_02",
}

function ES:CreateShoppingPage(page)
  local Label = ES.UI.Label
  local head = ES.UI.CardHead(page) -- (fondo y colores de Subir profesiones)
  local icon = head:CreateTexture(nil, "ARTWORK")
  icon:SetSize(44, 44)
  icon:SetPoint("LEFT", 12, 0)
  icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  local name = Label(head, L["Lista de compra"], "GameFontNormalHuge")
  name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, 2)
  name:SetTextColor(0.96, 0.79, 0.25)
  page.subtitle = Label(head, "", "GameFontHighlightSmall")
  page.subtitle:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 12, 2)
  page.subtitle:SetPoint("RIGHT", -190, 0)
  page.subtitle:SetJustifyH("LEFT")

  page.nextButton = CreateFrame("Button", nil, head, "UIPanelButtonTemplate")
  page.nextButton:SetSize(170, 24)
  page.nextButton:SetPoint("RIGHT", -12, 0)
  page.nextButton:SetText(L["Comprar siguiente"])
  page.nextButton:SetMotionScriptsWhileDisabled(true)
  page.nextButton:SetScript("OnClick", function() ES:ShoppingBuyNext() end)
  page.nextButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:AddLine(L["Comprar siguiente"], 1, 1, 1)
    local itemID, left = ES.Shopping.NextToBuy(ES.Shopping.Status(), selected)
    if itemID then
      GameTooltip:AddLine(string.format("%d× %s", left, (ES.UI.ItemLabel(itemID, L["Objeto "] .. itemID))), 1, 0.82, 0)
    end
    GameTooltip:AddLine(L["Abre la compra de Blizzard con la cantidad puesta (solo las baratas). Confírmala con su botón Comprar ahora y vuelve a pulsar este para el siguiente."], 0.8, 0.8, 0.8, true)
    if not ES:IsAuctionHouseOpen() then GameTooltip:AddLine(L["Abre la Casa de Subastas para comprar."], 1, 0.6, 0.2, true) end
    GameTooltip:Show()
  end)
  page.nextButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

  -- Progreso de toda la lista
  local strip = CreateFrame("Frame", nil, page)
  strip:SetPoint("TOPLEFT", head, "BOTTOMLEFT", 4, -6)
  strip:SetPoint("TOPRIGHT", head, "BOTTOMRIGHT", -4, -6)
  strip:SetHeight(46)
  page.progressText = Label(strip, "", "GameFontHighlight")
  page.progressText:SetPoint("TOPLEFT", 6, -2)
  page.bar = CreateFrame("StatusBar", nil, strip)
  page.bar:SetPoint("TOPLEFT", 6, -22)
  page.bar:SetPoint("RIGHT", -6, 0)
  page.bar:SetHeight(10)
  page.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  page.bar:SetStatusBarColor(0.25, 0.8, 0.25)
  page.bar:SetMinMaxValues(0, 1)
  local barBg = page.bar:CreateTexture(nil, "BACKGROUND")
  barBg:SetAllPoints()
  barBg:SetColorTexture(0, 0, 0, 0.5)
  page.status = Label(page, "", "GameFontHighlightSmall")
  page.status:SetPoint("TOPLEFT", strip, "BOTTOMLEFT", 2, -2)
  page.status:SetPoint("RIGHT", strip, "RIGHT", 0, 0)
  page.status:SetJustifyH("LEFT")
  page.status:SetWordWrap(false)

  local list = ES.UI.ListPanel(page, head, 70)
  local scroll = ES.UI.WheelScroll(list)
  scroll:SetPoint("TOPLEFT", 8, -8)
  scroll:SetPoint("BOTTOMRIGHT", -8, 8)
  page.content = CreateFrame("Frame", nil, scroll)
  page.content:SetSize(ES.UI.LIST_WIDTH, 1)
  scroll:SetScrollChild(page.content)
  page.rows = {}
  page.empty = Label(page.content, "", "GameFontDisable")
  page.empty:SetPoint("TOP", 0, -30)
  page.empty:SetWidth(600)

  -- Repintar: nombres que llegan, compras (la contabilidad las apunta al cambiar el
  -- dinero), resultados de la AH (cuántas baratas hay) y abrir o cerrar la AH
  for _, e in ipairs({ "GET_ITEM_INFO_RECEIVED", "PLAYER_MONEY", "COMMODITY_SEARCH_RESULTS_UPDATED",
    "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED" }) do
    ES.SafeRegister(page, e)
  end
  ES.SafeRegister(page, "BAG_UPDATE_DELAYED") -- (la lista del tramo cuenta lo que llevas)
  page:SetScript("OnEvent", function(self, event)
    if event == "GET_ITEM_INFO_RECEIVED" and not self.pendingItems then return end
    if self.refreshQueued then return end
    self.refreshQueued = true
    C_Timer.After(0.3, function()
      self.refreshQueued = false
      if self:IsVisible() then ES:RenderShopping() end
    end)
  end)
  page:SetScript("OnShow", function() ES:RenderShopping() end)
  self.shoppingPage = page
end

-- Filas de la lista (las mismas en la pestaña y en el panel pequeño de la AH)
local function BuildLines(st, ahOpen)
  local Signed = ES.UI.Signed
  local lines = {}
  for _, s in ipairs(st.lists) do
    local list = s.list
    -- (las listas guardadas antes llevan "(1 → 225)": la flecha no está en la fuente de WoW)
    lines[#lines + 1] = { section = (list.title or ""):gsub(" \226\134\146 ", " - ") } -- (U+2192, la flecha)
    for _, e in ipairs(s.items) do
      local it = e.it
      local name, texture = ES.UI.ItemLabel(it.itemID, L["Objeto "] .. it.itemID)
      local where = it.source == "ah" and string.format(L["AH ~%s/u"], ES.Money(it.unit or 0)) or string.format(L["vendedor %s/u"], ES.Money(it.unit or 0))
      local line = { icon = texture or 134400, item = it.itemID, current = it.itemID == selected and e.left > 0 }
      -- (la lista del tramo se calcula sola: no se quitan materiales a mano)
      if not list.live then
        line.onSkip = function() ES.Shopping.RemoveItem(list, it.itemID) ES:RenderShopping() end
        line.skipTitle, line.skipTip = L["Quitar de la lista"], L["Quita este material de la lista: ya no se compra."]
      end
      -- Tramo: lo que cuenta es lo que llevas; en las guardadas, lo comprado desde que la añadiste
      local progress = L["tienes %d de %d"] -- (todas las listas cuentan lo que llevas)
      if e.left == 0 then
        line.title = GREY .. (name or "") .. "|r"
        line.sub = GREEN .. string.format(progress, e.bought, it.need) .. "|r"
        line.value = "|TInterface\\RaidFrame\\ReadyCheck-Ready:16|t"
      else
        line.title = string.format("%d× %s", e.left, name or "")
        line.sub = where .. (e.bought > 0 and (" · " .. string.format(progress, e.bought, it.need)) or "")
        -- Abierta su compra: cuántas hay baratas ahora
        local t = it.source == "ah" and it.itemID == selected and ES.CommodityTiers and ES:CommodityTiers(it.itemID, it.unit)
        if t and t.next and t.cheap < e.left then
          line.sub = line.sub .. " · " .. ORANGE .. string.format(L["solo %d baratas; luego %s/u"], t.cheap, ES.Money(t.next)) .. "|r"
        end
        line.value = Signed(e.left * (it.unit or 0))
        if it.source == "ah" then
          line.onClick = function() Buy(it.itemID, e.left, it.unit) end
          line.tooltip = function(row)
            GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. it.itemID)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(ahOpen and L["Clic: abrir su compra en la AH con la cantidad puesta."] or L["Abre la Casa de Subastas para comprar."], 0.5, 0.8, 1, true)
            GameTooltip:Show()
          end
        end
      end
      lines[#lines + 1] = line
    end
    if list.live then
      -- Tramo: sin ✕ (se va sola al acabar la ruta; el modo se cambia en la ruta)
      lines[#lines + 1] = { total = true, icon = KIND_ICON.route,
        title = string.format(L["%d de %d listos"], s.done, s.total),
        sub = s.done == s.total and (GREEN .. L["Tienes lo de este tramo. Al acabarlo sale el siguiente."] .. "|r")
          or L["Solo este tramo, con un margen por si los puntos tardan en subir. Al acabarlo sale el siguiente."],
        value = s.cost > 0 and Signed(s.cost) or "" }
    else
    lines[#lines + 1] = { total = true, icon = KIND_ICON[list.kind],
      title = string.format(L["%d de %d listos"], s.done, s.total),
      sub = s.done == s.total and (GREEN .. L["Ya lo tienes todo: quítala con la |TInterface/Buttons/UI-GroupLoot-Pass-Up:0|t."] .. "|r")
        or L["Cuenta lo que llevas en las bolsas."],
      -- (la ✕ de la fila del total quita la lista entera)
      value = s.cost > 0 and Signed(s.cost) or "",
      onSkip = function() ES.Shopping.Remove(list) ES:RenderShopping() end,
      skipTitle = L["Quitar de la lista"], skipTip =L["Quitar esta lista. No cambia nada de lo que has comprado."] }
    end
  end
  return lines
end

local RenderMini -- (panel pequeño junto a la AH, abajo)

function ES:RenderShopping()
  local st = ES.Shopping.Status()
  local ahOpen = ES:IsAuctionHouseOpen()
  local lines = BuildLines(st, ahOpen)
  RenderMini(st, lines, ahOpen)
  local page = self.shoppingPage
  if not page or not page:IsVisible() then return end

  page.subtitle:SetText(L["Añade materiales desde una ruta (vista Materiales), Ganar dinero o la calculadora."])
  page.progressText:SetText(st.total > 0 and string.format(L["%d de %d materiales comprados · te falta ~%s"], st.done, st.total, ES.Money(st.cost)) or "")
  page.bar:SetShown(st.total > 0)
  page.progress = st.total > 0 and st.done / st.total or 0
  page.bar:SetValue(page.progress)
  local nextID = ES.Shopping.NextToBuy(st, selected)
  page.nextButton:SetEnabled(ahOpen and nextID ~= nil)
  page.status:SetText(ahOpen and (GREY .. L["Clic en un material de la AH: abre su compra con la cantidad puesta (solo las baratas). Confirmas tú con Comprar ahora.|r"])
    or (ORANGE .. L["Abre la Casa de Subastas para comprar desde aquí.|r"]))
  page.empty:SetText(#lines == 0 and L["La lista está vacía. Añade materiales con el botón \"Añadir a la lista de compra\" de una ruta (vista Materiales), de Ganar dinero o de la calculadora."] or "")
  ES.UI.RenderLines(page, lines)
end

-- Añadir y avisar (lo usan los botones de cada fuente)
function ES:AddToShopping(kind, title, items, opts)
  local list = ES.Shopping.Add(kind, title, items, opts)
  if list then
    ES:Print(string.format(L["Añadido a la lista de compra: %s (%d materiales)."], title, #list.items))
  else
    ES:Print(L["No hay nada que comprar: ya tienes todos los materiales."])
  end
  ES:RenderShopping()
  return list
end

---------------------------------------------------------------------------
-- Panel pequeño junto a la AH: la misma lista, para comprar sin la ventana grande
---------------------------------------------------------------------------
local MINI_W, MINI_H, MINI_ROW, MINI_SECTION = 300, 440, 34, 20
local mini

local function MiniRow(parent)
  local row = CreateFrame("Button", nil, parent)
  row:SetSize(MINI_W - 44, MINI_ROW)
  row.bg = row:CreateTexture(nil, "BACKGROUND")
  row.bg:SetAllPoints()
  local hl = row:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints()
  hl:SetColorTexture(1, 0.82, 0.25, 0.10)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(24, 24)
  row.icon:SetPoint("LEFT", 2, 0)
  row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  row.skip = CreateFrame("Button", nil, row)
  row.skip:SetSize(14, 14)
  row.skip:SetPoint("RIGHT", -2, 0)
  row.skip:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
  row.skip:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight", "ADD")
  row.skip:SetScript("OnClick", function() if row.line and row.line.onSkip then row.line.onSkip() end end)
  row.skip:SetScript("OnEnter", function(self)
    local line = row.line
    if not line then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(line.skipTitle or L["Quitar de la lista"])
    if line.skipTip then GameTooltip:AddLine(line.skipTip, 0.8, 0.8, 0.8, true) end
    GameTooltip:Show()
  end)
  row.skip:SetScript("OnLeave", function() GameTooltip:Hide() end)
  row.value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.value:SetPoint("TOPRIGHT", row.skip, "TOPLEFT", -4, 6)
  row.value:SetJustifyH("RIGHT")
  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 5, -1)
  row.title:SetPoint("RIGHT", row.value, "LEFT", -4, 0)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)
  row.sub = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.sub:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 5, 1)
  row.sub:SetPoint("RIGHT", row.skip, "LEFT", -4, 0)
  row.sub:SetJustifyH("LEFT")
  row.sub:SetWordWrap(false)
  row.sub:SetTextColor(0.75, 0.72, 0.65)
  row.section = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.section:SetPoint("LEFT", 2, 0)
  row.section:SetPoint("RIGHT", -2, 0)
  row.section:SetJustifyH("LEFT")
  row.section:SetWordWrap(false)
  row:SetScript("OnClick", function(self) if self.line and self.line.onClick then self.line.onClick() end end)
  row:SetScript("OnEnter", function(self) if self.line and self.line.tooltip then self.line.tooltip(self) end end)
  row:SetScript("OnLeave", function() GameTooltip:Hide() end)
  return row
end

local function CreateMini(ahFrame)
  local G = ES.UI.BROWN.group -- (paleta común: el fondo de Subir profesiones)
  local p = ES.UI.Panel(ahFrame, G[1], G[2], G[3], 0.99)
  p:SetSize(MINI_W, MINI_H)
  p:SetPoint("TOPLEFT", ahFrame, "TOPRIGHT", 2, -12)
  p:SetFrameStrata(ahFrame:GetFrameStrata())
  p:EnableMouse(true)

  local title = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 12, -10)
  title:SetText(L["Crafter's Journal · Lista de compra"])
  local close = CreateFrame("Button", nil, p, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetScript("OnClick", function()
    ES.db.shopMiniHidden = true
    p:Hide()
  end)

  p.progressText = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  p.progressText:SetPoint("TOPLEFT", 12, -32)
  p.progressText:SetPoint("RIGHT", -12, 0)
  p.progressText:SetJustifyH("LEFT")
  p.bar = CreateFrame("StatusBar", nil, p)
  p.bar:SetPoint("TOPLEFT", 12, -48)
  p.bar:SetPoint("RIGHT", -12, 0)
  p.bar:SetHeight(8)
  p.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  p.bar:SetStatusBarColor(0.25, 0.8, 0.25)
  p.bar:SetMinMaxValues(0, 1)
  local barBg = p.bar:CreateTexture(nil, "BACKGROUND")
  barBg:SetAllPoints()
  barBg:SetColorTexture(0, 0, 0, 0.5)

  local scroll = ES.UI.WheelScroll(p)
  scroll:SetPoint("TOPLEFT", 10, -62)
  scroll:SetPoint("BOTTOMRIGHT", -10, 40)
  p.content = CreateFrame("Frame", nil, scroll)
  p.content:SetSize(MINI_W - 44, 1)
  scroll:SetScrollChild(p.content)
  p.rows = {}
  p.empty = p.content:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  p.empty:SetPoint("TOP", 0, -20)
  p.empty:SetWidth(MINI_W - 60)

  p.nextButton = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  p.nextButton:SetSize(150, 24)
  p.nextButton:SetPoint("BOTTOMLEFT", 10, 10)
  p.nextButton:SetText(L["Comprar siguiente"])
  p.nextButton:SetScript("OnClick", function() ES:ShoppingBuyNext() end)
  p.nextButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine(L["Comprar siguiente"], 1, 1, 1)
    local itemID, left = ES.Shopping.NextToBuy(ES.Shopping.Status(), selected)
    if itemID then
      GameTooltip:AddLine(string.format("%d× %s", left, (ES.UI.ItemLabel(itemID, L["Objeto "] .. itemID))), 1, 0.82, 0)
    end
    GameTooltip:AddLine(L["Abre la compra de Blizzard con la cantidad puesta (solo las baratas). Confírmala con su botón Comprar ahora y vuelve a pulsar este para el siguiente."], 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
  end)
  p.nextButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

  local full = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  full:SetSize(110, 24)
  full:SetPoint("BOTTOMRIGHT", -10, 10)
  full:SetText(L["Ver completa"])
  full:SetScript("OnClick", function() ES:OpenShoppingAtAuction(ahFrame) end)

  -- Repintar: compras (la contabilidad las apunta al cambiar el dinero), resultados
  -- de la AH (cuántas baratas hay) y nombres que llegan
  for _, e in ipairs({ "PLAYER_MONEY", "COMMODITY_SEARCH_RESULTS_UPDATED", "GET_ITEM_INFO_RECEIVED", "BAG_UPDATE_DELAYED" }) do
    ES.SafeRegister(p, e)
  end
  p:SetScript("OnEvent", function(self)
    if not self:IsShown() or self.refreshQueued then return end
    self.refreshQueued = true
    C_Timer.After(0.3, function()
      self.refreshQueued = false
      ES:RenderShopping()
    end)
  end)
  p:SetScript("OnShow", function() ES:RenderShopping() end)
  return p
end

RenderMini = function(st, lines, ahOpen)
  if not mini or not mini:IsShown() then return end
  mini.progressText:SetText(st.total > 0 and string.format(L["%d de %d materiales comprados · te falta ~%s"], st.done, st.total, ES.Money(st.cost))
    or "")
  mini.bar:SetShown(st.total > 0)
  mini.progress = st.total > 0 and st.done / st.total or 0
  mini.bar:SetValue(mini.progress)
  mini.nextButton:SetEnabled(ahOpen and ES.Shopping.NextToBuy(st, selected) ~= nil)
  mini.empty:SetText(#lines == 0 and L["La lista está vacía. Añade materiales con \"Añadir a la lista de compra\" en Ganar dinero, la calculadora o la vista Materiales de una ruta."] or "")
  local y = 0
  for i, line in ipairs(lines) do
    local row = mini.rows[i] or MiniRow(mini.content)
    mini.rows[i] = row
    row.line = line
    local isSection = line.section ~= nil
    local h = isSection and MINI_SECTION or MINI_ROW
    row:SetHeight(h)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -y)
    row.section:SetText(isSection and ("|cffffd100" .. line.section .. "|r") or "")
    row.icon:SetShown(not isSection and line.icon ~= nil)
    if line.icon then row.icon:SetTexture(line.icon) end
    row.title:SetText(not isSection and line.title or "")
    row.sub:SetText(not isSection and line.sub or "")
    row.value:SetText(not isSection and line.value or "")
    row.skip:SetShown(line.onSkip ~= nil)
    -- (los mismos tonos que las filas de la ruta: total, actual y normal)
    local R = ES.UI.BROWN.row
    if line.total then row.bg:SetColorTexture(0.20, 0.14, 0.06, 0.95)
    elseif line.current then row.bg:SetColorTexture(0.30, 0.23, 0.08, 0.96)
    elseif isSection then row.bg:SetColorTexture(0, 0, 0, 0)
    else row.bg:SetColorTexture(R[1], R[2], R[3], R[4]) end
    y = y + h + 2
    row:Show()
  end
  for i = #lines + 1, #mini.rows do mini.rows[i]:Hide() end
  mini.content:SetHeight(math.max(1, y))
end

-- Al abrir la AH: el panel pequeño (salvo que lo cerraras) y la ventana grande, fuera
function ES:SetupShoppingMini(ahFrame)
  if not mini then mini = CreateMini(ahFrame) end
  ES:HideMainFrame()
  mini:SetShown(not ES.db.shopMiniHidden)
  ES:RenderShopping()
end

-- El botón sobre la AH: enseñar u ocultar el panel pequeño
function ES:ToggleShoppingMini(ahFrame)
  if not mini then return self:SetupShoppingMini(ahFrame) end
  local show = not mini:IsShown()
  ES.db.shopMiniHidden = not show or nil
  mini:SetShown(show)
  if show then ES:RenderShopping() end
end

-- "Ver completa": la pestaña grande al lado de la AH, en lugar del panel pequeño
-- (que vuelve al cerrar la ventana grande, con la AH aún abierta)
function ES:ShowFullShopping()
  if mini and mini:IsShown() then
    mini:Hide()
    local main = self:GetMainFrame()
    if not main.cjMiniHook then
      main.cjMiniHook = true
      main:HookScript("OnHide", function()
        if ES:IsAuctionHouseOpen() and mini and not ES.db.shopMiniHidden then mini:Show() end
      end)
    end
  end
end

ES.ShoppingMini = function() return mini end -- para pruebas

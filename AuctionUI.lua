local _, ES = ...
local L = ES.L

-- Panel junto a la Casa de Subastas con la lista de la compra de la ruta:
--   Comprar:  materiales que el plan compra en la AH; clic (o "Buscar siguiente")
--             busca el objeto en la ventana de la AH para que lo compres tú
--   Vender:   lo fabricado que llevas encima y conviene anunciar (Planner.SaleAdvice)
-- No compra ni vende nada solo: solo rellena la búsqueda de la AH.

local PANEL_W, PANEL_H, ROW_H = 300, 430, 34
local GOLD, GREEN, GREY, ORANGE = "|cffffd100", "|cff40ff40", "|cff999999", "|cffff9933"
local SEARCH_RETRY = 0.3

local panel, toggleButton
local state = { lines = {} } -- profKey, plan, baseline[itemID], need[itemID], live[itemID]

local function ItemName(itemID)
  local name = ES:GetItemData(itemID)
  return name
end

-- Modos del panel: "money" (lote de Ganar dinero) y las profesiones con una ruta
-- empezada ("Empezar ruta"): es lo que vas a comprar. Sin ninguna, el panel dice
-- cómo empezar una.
local MONEY = "money"
-- (la Pesca no compra nada: fuera)
local function ProfessionKeys()
  local keys = {}
  for _, p in ipairs(ES.PROFESSIONS) do
    local data = ES.Data[p.key]
    if data and not data.guide and ES:RouteLock(p.key) then keys[#keys + 1] = p.key end
  end
  keys[#keys + 1] = MONEY -- al final: por defecto sale una ruta
  return keys
end

---------------------------------------------------------------------------
-- Búsqueda en la ventana de la AH
---------------------------------------------------------------------------
local function CanQuery()
  if not CanSendAuctionQuery then return true end
  return (CanSendAuctionQuery())
end

-- Rellena la búsqueda de la AH con el nombre del objeto y la lanza
function ES:SearchAuction(itemID, tries)
  local name = ItemName(itemID)
  if not name then
    -- El juego aún no tiene el nombre: lo pide y reintenta
    if (tries or 0) < 10 then C_Timer.After(SEARCH_RETRY, function() ES:SearchAuction(itemID, (tries or 0) + 1) end) end
    return
  end
  state.searching = itemID
  -- Clásica: pestaña Explorar, caja de nombre y botón Buscar de Blizzard
  if AuctionFrame and BrowseName then
    if AuctionFrameTab1 and AuctionFrameTab_OnClick and AuctionFrame.selectedTab ~= 1 then
      AuctionFrameTab_OnClick(AuctionFrameTab1)
    end
    if not CanQuery() then
      if (tries or 0) < 20 then C_Timer.After(SEARCH_RETRY, function() ES:SearchAuction(itemID, (tries or 0) + 1) end) end
      return
    end
    BrowseName:SetText(name)
    if BrowseMinLevel then BrowseMinLevel:SetText("") end
    if BrowseMaxLevel then BrowseMaxLevel:SetText("") end
    if AuctionFrameBrowse_Search then
      AuctionFrameBrowse_Search()
    elseif QueryAuctionItems then
      QueryAuctionItems(name, nil, nil, 0, nil, nil, false, true, nil)
    end
  -- Moderna: barra de búsqueda de AuctionHouseFrame
  elseif AuctionHouseFrame and AuctionHouseFrame.SearchBar then
    local bar = AuctionHouseFrame.SearchBar
    if bar.SetSearchText then bar:SetSearchText(name) end
    if bar.StartSearch then bar:StartSearch() end
  end
  ES:RenderAuctionPanel()
end

-- Cantidad en la página de compra de materiales de la AH moderna (la de Blizzard)
local function SetBuyQuantity(qty)
  local buy = AuctionHouseFrame and AuctionHouseFrame.CommoditiesBuyFrame
  local display = buy and (buy.BuyDisplay or (buy.GetBuyDisplay and buy:GetBuyDisplay()))
  if not (display and buy:IsShown()) then return false end
  if display.SetQuantitySelected then
    return pcall(display.SetQuantitySelected, display, qty)
  end
  local input = display.QuantityInput
  if input and input.SetQuantity then return pcall(input.SetQuantity, input, qty) end
  return false
end

-- Abre la compra de un material en la AH con la cantidad ya puesta (solo falta
-- pulsar "Comprar ahora" de Blizzard). Si no es un material de la AH moderna, o el
-- juego no deja, se busca como siempre (ES:SearchAuction)
function ES:OpenAuctionBuy(itemID, qty)
  local A, f = C_AuctionHouse, AuctionHouseFrame
  if not (A and A.MakeItemKey and f and f.SelectBrowseResult and f.CommoditiesBuyFrame) then
    return self:SearchAuction(itemID)
  end
  local ok = pcall(function()
    f:SelectBrowseResult({ itemKey = A.MakeItemKey(itemID), minPrice = 0, totalQuantity = 0, containsOwnerItem = false })
  end)
  if not ok or not f.CommoditiesBuyFrame:IsShown() then return self:SearchAuction(itemID) end
  state.searching = itemID
  -- Los resultados llegan un momento después: se pone la cantidad en cuanto se pueda
  SetBuyQuantity(qty)
  C_Timer.After(0.4, function() SetBuyQuantity(qty) end)
  C_Timer.After(1.2, function() SetBuyQuantity(qty) end)
end

-- Lo que hay ahora en la página de resultados para el objeto buscado
local function ReadLivePrice()
  local itemID = state.searching
  if not itemID or not GetNumAuctionItems or not GetAuctionItemInfo then return end
  local n = GetNumAuctionItems("list") or 0
  local min, units = nil, 0
  for i = 1, n do
    local _, _, count, _, _, _, _, _, _, buyout, _, _, _, _, _, _, id = GetAuctionItemInfo("list", i)
    if id == itemID and count and count > 0 then
      units = units + count
      if buyout and buyout > 0 and (not min or buyout / count < min) then min = buyout / count end
    end
  end
  state.live[itemID] = { min = min, units = units }
  ES:RenderAuctionPanel()
end

---------------------------------------------------------------------------
-- Datos: plan de la profesión elegida
---------------------------------------------------------------------------
-- Se calcula una vez al abrir (o al cambiar de profesión / Recalcular). Lo que
-- compras se descuenta comparando con lo que tenías en ese momento, sin
-- recalcular la ruta con cada compra.
function ES:RefreshAuctionPlan(force)
  -- Al abrir la AH se pide dos veces seguidas (panel y refresco general): una basta
  if not force and state.at and GetTime() - state.at < 1 then return end
  state.at = GetTime()
  local keys = ProfessionKeys()
  local function Valid(k)
    for _, key in ipairs(keys) do if key == k then return true end end
  end
  if not Valid(state.profKey) then
    state.profKey = Valid(self.db.lastProf) and self.db.lastProf or keys[1]
  end
  state.need, state.baseline, state.live = {}, {}, {}
  state.plan, state.earn = nil, nil
  if not state.profKey then
    -- Ninguna ruta empezada: nada que comprar (RenderAuctionPanel lo explica)
  elseif state.profKey == MONEY then
    -- Lote de Ganar dinero: lo que ya llevas cuenta (no hay que comprarlo)
    state.earn = ES.Earn:Ideas()
    for _, it in ipairs(state.earn.shopping) do
      if it.source == "ah" then
        local have = ES:ItemCount(it.itemID)
        state.need[it.itemID] = math.max(0, it.quantity - have)
        state.baseline[it.itemID] = have
      end
    end
  else
    state.plan, state.from, state.to = self:ProfessionPlan(state.profKey)
    for _, it in ipairs(state.plan and state.plan.shopping or {}) do
      if it.source == "ah" then
        state.need[it.itemID] = it.quantity
        state.baseline[it.itemID] = ES:ItemCount(it.itemID)
      end
    end
  end
  self:RenderAuctionPanel()
end

local function Remaining(itemID)
  local bought = math.max(0, ES:ItemCount(itemID) - (state.baseline[itemID] or 0))
  return math.max(0, (state.need[itemID] or 0) - bought)
end

-- Siguiente objeto que te falta comprar (después del último buscado)
local function NextToBuy()
  local list, start = {}, 1
  for _, l in ipairs(state.lines) do
    if l.buy and Remaining(l.itemID) > 0 then list[#list + 1] = l.itemID end
  end
  for i, id in ipairs(list) do if id == state.searching then start = i + 1 end end
  return list[start] or list[1]
end

---------------------------------------------------------------------------
-- Panel
---------------------------------------------------------------------------
local function CreateRow(parent, i)
  local row = CreateFrame("Button", nil, parent)
  row:SetSize(PANEL_W - 44, ROW_H)
  local hl = row:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints()
  hl:SetColorTexture(1, 0.82, 0.25, 0.10)
  row.sel = row:CreateTexture(nil, "BACKGROUND")
  row.sel:SetAllPoints()
  row.sel:SetColorTexture(0.2, 0.6, 1, 0.18)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(26, 26)
  row.icon:SetPoint("LEFT", 2, 0)
  row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  row.check = row:CreateTexture(nil, "OVERLAY")
  row.check:SetSize(16, 16)
  row.check:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", 4, -4)
  row.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, -1)
  row.title:SetPoint("RIGHT", -2, 0)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)
  row.sub = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.sub:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 6, 1)
  row.sub:SetPoint("RIGHT", -2, 0)
  row.sub:SetJustifyH("LEFT")
  row.sub:SetWordWrap(false)
  row.sub:SetTextColor(0.75, 0.72, 0.65)
  row.section = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.section:SetPoint("LEFT", 2, 0)
  row:SetScript("OnClick", function(self)
    if not self.itemID then return end
    -- Con lo que falta: la compra abierta con la cantidad puesta; si no, buscarlo
    local left = Remaining(self.itemID)
    if left > 0 then ES:OpenAuctionBuy(self.itemID, left) else ES:SearchAuction(self.itemID) end
  end)
  row:SetScript("OnEnter", function(self)
    if not self.itemID then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. self.itemID)
    GameTooltip:AddLine(" ")
    if self.hint then GameTooltip:AddLine(self.hint, 0.8, 0.8, 0.8, true) end
    GameTooltip:AddLine(L["Clic: buscarlo en la Casa de Subastas."], 0.5, 0.8, 1)
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function() GameTooltip:Hide() end)
  return row
end

local function CreatePanel(ahFrame)
  local p = ES.UI.Panel(ahFrame)
  p:SetSize(PANEL_W, PANEL_H)
  p:SetPoint("TOPLEFT", ahFrame, "TOPRIGHT", 2, -12)
  p:SetFrameStrata(ahFrame:GetFrameStrata())
  p:EnableMouse(true)

  local title = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 12, -10)
  title:SetText(L["Crafter's Journal · Lista de compra"])

  local close = CreateFrame("Button", nil, p, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetScript("OnClick", function()
    ES.db.ahPanelHidden = true
    p:Hide()
  end)

  -- Selector de profesión: < Cocina (75 → 150) >
  local prev = CreateFrame("Button", nil, p)
  prev:SetSize(22, 22)
  prev:SetPoint("TOPLEFT", 8, -28)
  prev:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
  prev:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
  local nextB = CreateFrame("Button", nil, p)
  nextB:SetSize(22, 22)
  nextB:SetPoint("TOPRIGHT", -8, -28)
  nextB:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
  nextB:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
  p.prof = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  p.prof:SetPoint("LEFT", prev, "RIGHT", 4, 0)
  p.prof:SetPoint("RIGHT", nextB, "LEFT", -4, 0)
  p.prevButton, p.nextProfButton = prev, nextB
  local function Cycle(delta)
    local keys = ProfessionKeys()
    if #keys == 0 then return end
    local at = 1
    for i, k in ipairs(keys) do if k == state.profKey then at = i end end
    state.profKey = keys[(at - 1 + delta) % #keys + 1]
    ES:RefreshAuctionPlan(true)
  end
  prev:SetScript("OnClick", function() Cycle(-1) end)
  nextB:SetScript("OnClick", function() Cycle(1) end)

  p.summary = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  p.summary:SetPoint("TOPLEFT", 12, -54)
  p.summary:SetPoint("RIGHT", -12, 0)
  p.summary:SetJustifyH("LEFT")

  local scroll = ES.UI.WheelScroll(p)
  scroll:SetPoint("TOPLEFT", 10, -72)
  scroll:SetPoint("BOTTOMRIGHT", -10, 40)
  p.content = CreateFrame("Frame", nil, scroll)
  p.content:SetSize(PANEL_W - 44, 1)
  scroll:SetScrollChild(p.content)
  p.rows = {}
  p.empty = p.content:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  p.empty:SetPoint("TOP", 0, -20)
  p.empty:SetWidth(PANEL_W - 60)

  p.nextButton = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  p.nextButton:SetSize(150, 24)
  p.nextButton:SetPoint("BOTTOMLEFT", 10, 10)
  p.nextButton:SetText(L["Buscar siguiente"])
  p.nextButton:SetScript("OnClick", function()
    local id = NextToBuy()
    if id then ES:OpenAuctionBuy(id, Remaining(id)) end
  end)

  local recalc = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  recalc:SetSize(110, 24)
  recalc:SetPoint("BOTTOMRIGHT", -10, 10)
  recalc:SetText(L["Recalcular"])
  recalc:SetScript("OnClick", function() ES:RefreshAuctionPlan(true) end)
  recalc:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine(L["Recalcular la ruta"], 1, 1, 1)
    GameTooltip:AddLine(L["Con los precios del último escaneo y lo que tienes ahora en bolsas."], 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
  end)
  recalc:SetScript("OnLeave", function() GameTooltip:Hide() end)

  ES.SafeRegister(p, "BAG_UPDATE_DELAYED")
  ES.SafeRegister(p, "AUCTION_ITEM_LIST_UPDATE")
  p:SetScript("OnEvent", function(_, event)
    if not p:IsShown() then return end
    if event == "AUCTION_ITEM_LIST_UPDATE" then
      if not ES.Scanner:IsBusy() then ReadLivePrice() end
    else
      ES:RenderAuctionPanel()
    end
  end)
  return p
end

-- Líneas: sección Comprar (AH) y sección Vender (lo fabricado que llevas encima)
local function BuildLines()
  local lines = {}
  local plan, earn = state.plan, state.earn
  if not plan and not earn then return lines end
  local buy = {}
  for _, it in ipairs(plan and plan.shopping or earn.shopping) do
    if it.source == "ah" and (plan or state.need[it.itemID] > 0) then -- del lote, solo lo que no llevas ya
      buy[#buy + 1] = it
    end
  end
  if #buy > 0 then
    lines[#lines + 1] = { section = L["Comprar en la AH"] }
    for _, it in ipairs(buy) do lines[#lines + 1] = { buy = true, itemID = it.itemID, it = it } end
  end
  local sell = {}
  if plan then
    for _, d in ipairs(plan.destinations or {}) do
      local a = ES.Planner.SaleAdvice(d)
      local have = ES:ItemCount(d.itemID)
      if a.ah > 0 and have > 0 then sell[#sell + 1] = { itemID = d.itemID, advice = a, have = have, d = d } end
    end
  else
    -- Lote de Ganar dinero: lo fabricado que llevas, a anunciar
    for _, idea in ipairs(earn.batch) do
      local have = ES:ItemCount(idea.itemID)
      if idea.sellWhere == "ah" and have > 0 then
        sell[#sell + 1] = { itemID = idea.itemID, have = have,
          advice = { ah = idea.crafts * idea.e.qty, price = idea.price, verdict = idea.verdict,
            inflated = idea.e.fair and idea.e.fair.inflated } }
      end
    end
  end
  if #sell > 0 then
    lines[#lines + 1] = { section = L["Vender en la AH (lo llevas encima)"] }
    for _, s in ipairs(sell) do lines[#lines + 1] = { sell = true, itemID = s.itemID, s = s } end
  end
  return lines
end

function ES:RenderAuctionPanel()
  if not panel or not panel:IsShown() then return end
  local plan, earn = state.plan, state.earn
  -- Flechas solo si hay más de una lista entre la que elegir
  local several = #ProfessionKeys() > 1
  panel.prevButton:SetShown(several)
  panel.nextProfButton:SetShown(several)
  if not state.profKey then
    panel.prof:SetText(GREY .. L["Ninguna ruta empezada"] .. "|r")
  elseif earn then
    panel.prof:SetText(L["Ganar dinero"] .. " " .. GREY .. L["(lote de hoy)"] .. "|r")
  else
    panel.prof:SetText(string.format("%s %s(%d → %d)|r", ES:ProfLabel(state.profKey), GREY, state.from or 1, state.to or 1))
  end
  local lines = BuildLines()
  state.lines = lines

  local left, total, done = 0, 0, 0
  for _, l in ipairs(lines) do
    if l.buy then
      total = total + 1
      local rem = Remaining(l.itemID)
      if rem == 0 then done = done + 1 else left = left + rem * l.it.unit end
    end
  end
  if not state.profKey then
    panel.summary:SetText(GREY .. L["Aquí sale lo que comprar para tus rutas empezadas.|r"])
  elseif earn and #earn.batch == 0 then
    panel.summary:SetText(GREY .. L["Ninguna receta tuya da beneficio ahora.|r"])
  elseif not plan and not earn then
    panel.summary:SetText(GREEN .. L["Ya estás en el objetivo de esta profesión.|r"])
  elseif total == 0 then
    panel.summary:SetText(GREY .. (earn and L["Tienes todos los materiales del lote.|r"] or L["La ruta no compra nada en la AH.|r"]))
  else
    panel.summary:SetText(string.format(L["%d de %d comprados · te falta ~%s"], done, total, ES.Money(left)))
  end
  panel.empty:SetText(#lines == 0 and (not state.profKey
    and L["En Crafter's Journal, abre una profesión y pulsa Empezar ruta: su lista de la compra saldrá aquí."]
    or (plan or earn) and L["Nada que comprar ni vender aquí."] or "") or "")
  panel.nextButton:SetEnabled(total > done)

  local y = 0
  for i, l in ipairs(lines) do
    local row = panel.rows[i] or CreateRow(panel.content, i)
    panel.rows[i] = row
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -y)
    local isSection = l.section ~= nil
    row:SetHeight(isSection and 20 or ROW_H)
    row.section:SetText(isSection and (GOLD .. l.section .. "|r") or "")
    row.icon:SetShown(not isSection)
    row.title:SetShown(not isSection)
    row.sub:SetShown(not isSection)
    row.itemID = l.itemID
    row.check:Hide()
    row.sel:SetShown(l.itemID ~= nil and l.itemID == state.searching)
    if not isSection then
      local name, quality, texture = ES:GetItemData(l.itemID)
      row.icon:SetTexture(texture or 134400)
      local color = name and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality or 1]
      local label = (name and color and color.hex) and (color.hex .. name .. "|r") or name or (L["Objeto "] .. l.itemID)
      local live = state.live[l.itemID]
      local liveText = live and (live.min and string.format(L[" · ahora %s"], ES.Money(live.min)) or L[" · ahora: no hay"]) or ""
      if l.buy then
        local rem = Remaining(l.itemID)
        row.check:SetShown(rem == 0)
        row.title:SetText(rem == 0 and (GREY .. label .. "|r") or (rem .. "× " .. label))
        row.sub:SetText(rem == 0 and (GREEN .. L["comprado|r"])
          or string.format(L["~%s/u en el plan%s"], ES.Money(l.it.unit), liveText))
        row.hint = string.format(L["Hacen falta %d en total. Precio medio calculado: %s por unidad."], l.it.quantity, ES.Money(l.it.unit))
        -- Más caro ahora que lo que calculó el plan: avisar
        if live and live.min and live.min > l.it.unit * 1.25 and rem > 0 then
          row.sub:SetText(string.format(L["%sahora %s, más caro que el plan (%s)|r"], ORANGE, ES.Money(live.min), ES.Money(l.it.unit)))
        end
      else
        local s = l.s
        local n = math.min(s.have, s.advice.ah)
        row.title:SetText(n .. "× " .. label)
        row.sub:SetText(string.format(L["a %s cada uno · %s%s"], ES.Money(s.advice.price), ES.Market.LABELS[s.advice.verdict], liveText))
        row.hint = s.advice.inflated
          and L["La más barata está inflada (quedan pocas): el precio sugerido es el de los últimos días, algo por encima."]
          or s.advice.verdict == "good"
          and L["Las alertas de mercado están bien: anúncialos al precio de la más barata menos 1 cobre."]
          or L["Anuncia solo unos pocos para probar; si se venden, pon más."]
      end
    end
    y = y + (isSection and 20 or ROW_H) + 2
    row:Show()
  end
  for i = #lines + 1, #panel.rows do panel.rows[i]:Hide() end
  panel.content:SetHeight(math.max(1, y))
end

-- Al abrir la AH: crea el panel (la ventana de la AH se carga bajo demanda)
function ES:SetupAuctionPanel(ahFrame)
  if not panel then
    panel = CreatePanel(ahFrame)
    toggleButton = CreateFrame("Button", nil, ahFrame, "UIPanelButtonTemplate")
    toggleButton:SetSize(120, 24)
    toggleButton:SetText(L["Lista de compra"])
    if CraftersJournalAHButton then
      toggleButton:SetPoint("RIGHT", CraftersJournalAHButton, "LEFT", -4, 0)
    else
      toggleButton:SetPoint("BOTTOMRIGHT", ahFrame, "TOPRIGHT", -184, 2)
    end
    toggleButton:SetScript("OnClick", function()
      ES.db.ahPanelHidden = panel:IsShown() or nil
      if panel:IsShown() then panel:Hide() else panel:Show() ES:RefreshAuctionPlan(true) end
    end)
  end
  state.searching = nil
  if ES.db.ahPanelHidden then
    panel:Hide()
  else
    panel:Show()
    self:RefreshAuctionPlan(true)
  end
end

function ES:AuctionPanelShown()
  return panel ~= nil and panel:IsShown()
end

ES.AuctionPanelState = state -- para pruebas

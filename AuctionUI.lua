local _, ES = ...
local L = ES.L

-- Comprar en la Casa de Subastas: buscar un objeto, o abrir la compra de un material
-- con la cantidad puesta (solo las unidades baratas). Lo usan la pestaña Lista de
-- compra (ShoppingUI.lua) y la vista Materiales de cada ruta.
-- No compra ni vende nada solo: el clic de Comprar ahora de Blizzard es tuyo.
-- Y el botón "Lista de compra" sobre la AH, que enseña u oculta el panel pequeño.

local SEARCH_RETRY = 0.3

local state = {} -- searching (último objeto buscado), buying, applyBuy

local function ItemName(itemID)
  local name = ES:GetItemData(itemID)
  return name
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
end

-- Franja barata: lo que cuesta como mucho esto más que el más barato. Si pides más
-- de lo que hay ahí, otro jugador se lleva los baratos antes que tú y el resto
-- sale mucho más caro (la AH no guarda el precio entre buscar y confirmar).
local CHEAP_BAND = 1.2

-- Lo que hay ahora a la venta de un material en la AH moderna, según los resultados
-- que ya ha recibido la ventana de Blizzard (ordenados del más barato al más caro):
-- { min, units, cheap (unidades en la franja barata), cap (precio límite de la franja),
--   next (precio de la primera fuera de ella) }, o nil si aún no hay resultados.
-- `okUnit`: precio por unidad que sigue siendo aceptable (el del plan); ensancha la franja.
function ES:CommodityTiers(itemID, okUnit)
  local A = C_AuctionHouse
  if not (A and A.GetNumCommoditySearchResults and A.GetCommoditySearchResultInfo) then return nil end
  local okN, n = pcall(A.GetNumCommoditySearchResults, itemID)
  if not okN or not n or n == 0 then return nil end
  local t = { units = 0, cheap = 0 }
  for i = 1, n do
    local ok, r = pcall(A.GetCommoditySearchResultInfo, itemID, i)
    local price = ok and r and r.unitPrice
    -- Las tuyas no se pueden comprar: no cuentan
    local q = ok and r and (r.quantity or 0) - (r.numOwnerItems or 0) or 0
    if price and q > 0 then
      if not t.min then
        t.min = price
        t.cap = math.max(math.floor(price * CHEAP_BAND), okUnit or 0)
      end
      t.units = t.units + q
      if price <= t.cap then t.cheap = t.cheap + q
      elseif not t.next then t.next = price end
    end
  end
  return t.min and t or nil
end

-- Cantidad a poner en la compra: lo que falta, pero como mucho lo de la franja barata
local function CheapQuantity(itemID, qty, okUnit)
  local t = ES:CommodityTiers(itemID, okUnit)
  if t and t.next and t.cheap > 0 and t.cheap < qty then return t.cheap, t end
  return qty, t
end

-- Cantidad en la página de compra de materiales de la AH moderna (la de Blizzard).
-- Si ya está puesta, no se toca (volver a ponerla la hacía parpadear)
local function SetBuyQuantity(qty)
  local buy = AuctionHouseFrame and AuctionHouseFrame.CommoditiesBuyFrame
  local display = buy and (buy.BuyDisplay or (buy.GetBuyDisplay and buy:GetBuyDisplay()))
  if not (display and buy:IsShown()) then return false end
  if display.GetQuantitySelected then
    local ok, cur = pcall(display.GetQuantitySelected, display)
    if ok and cur == qty then return true end
  end
  if display.SetQuantitySelected then
    return pcall(display.SetQuantitySelected, display, qty)
  end
  local input = display.QuantityInput
  if input and input.SetQuantity then return pcall(input.SetQuantity, input, qty) end
  return false
end

-- Abre la compra de un material en la AH con la cantidad ya puesta (solo falta
-- pulsar "Comprar ahora" de Blizzard). Si no es un material de la AH moderna, o el
-- juego no deja, se busca como siempre (ES:SearchAuction).
-- Si solo una parte está barata, pone solo esa parte (ver CHEAP_BAND) y lo dice en
-- el chat: compras por tandas y nadie te deja pagando el precio caro.
-- `okUnit` (opcional): precio por unidad que sigue siendo aceptable.
local RESULTS_WAIT, RESULTS_RETRIES = 3, 2 -- s esperando resultados antes de volver a pedirlos
local REPEAT_GAP = 1 -- s: un segundo clic en el mismo material no vuelve a buscar

local function Select(f, A, itemID)
  return pcall(function()
    f:SelectBrowseResult({ itemKey = A.MakeItemKey(itemID), minPrice = 0, totalQuantity = 0, containsOwnerItem = false })
  end)
end

function ES:OpenAuctionBuy(itemID, qty, okUnit)
  local A, f = C_AuctionHouse, AuctionHouseFrame
  if not (A and A.MakeItemKey and f and f.SelectBrowseResult and f.CommoditiesBuyFrame) then
    return self:SearchAuction(itemID)
  end
  -- Doble clic (o "Comprar siguiente" otra vez) con la búsqueda aún en marcha: cada
  -- búsqueda nueva pisaba la anterior y el servidor dejaba la AH en "Buscando..."
  local now = GetTime and GetTime() or 0
  local b0 = state.buying
  if b0 and b0.i == itemID and b0.q == qty and now - (b0.at or -99) < REPEAT_GAP then return end
  local ok = Select(f, A, itemID)
  if not ok or not f.CommoditiesBuyFrame:IsShown() then return self:SearchAuction(itemID) end
  state.searching = itemID
  local buying = { i = itemID, q = qty, ok = okUnit, at = now }
  state.buying = buying
  -- La cantidad se pone cuando llegan los resultados (COMMODITY_SEARCH_RESULTS_UPDATED,
  -- después del manejador de Blizzard, que la reinicia). Antes se ponía también al
  -- momento y a los 0,4 y 1,2 s: sin resultados ponía todo, Blizzard la devolvía a 1
  -- y la cantidad parpadeaba
  local warned
  local function Apply()
    if state.buying ~= buying then return end
    if not ES:CommodityTiers(itemID, okUnit) then return end -- aún sin resultados
    buying.got = true
    local n, t = CheapQuantity(itemID, qty, okUnit)
    SetBuyQuantity(n)
    if n < qty and not warned then
      warned = true
      ES:Print(string.format(L["%s: solo %d a %s o menos; puesto %d de %d (el resto, desde %s). Compra y vuelve a pulsar."],
        ItemName(itemID) or itemID, n, ES.Money(t.cap), n, qty, ES.Money(t.next)))
    end
  end
  state.applyBuy = Apply
  Apply() -- (si ya estaban, de una búsqueda anterior del mismo material)
  -- Sin resultados al rato (el servidor descartó la búsqueda): se vuelve a pedir, como
  -- al ir atrás y adelante a mano
  local function Watch(tries)
    C_Timer.After(RESULTS_WAIT, function()
      if state.buying ~= buying or buying.got or not f.CommoditiesBuyFrame:IsShown() then return end
      Apply()
      if buying.got or tries >= RESULTS_RETRIES then return end
      Select(f, A, itemID)
      Watch(tries + 1)
    end)
  end
  Watch(0)
end

-- Al llegar los resultados del material abierto: recortar la cantidad (después del
-- manejador de Blizzard, que la reinicia)
do
  local f = CreateFrame("Frame")
  ES.SafeRegister(f, "COMMODITY_SEARCH_RESULTS_UPDATED")
  f:SetScript("OnEvent", function(_, _, itemID)
    local b = state.buying
    if b and b.i == itemID and state.applyBuy then C_Timer.After(0, state.applyBuy) end
  end)
end

---------------------------------------------------------------------------
-- Botón "Lista de compra" sobre la AH: enseña u oculta el panel pequeño
---------------------------------------------------------------------------
local listButton

local function ButtonText()
  local n = ES.Shopping and ES.Shopping.PendingAH() or 0
  return n > 0 and string.format(L["Lista de compra (%d)"], n) or L["Lista de compra"]
end

-- Abre Crafter's Journal en la Lista de compra, a la derecha de la AH
function ES:OpenShoppingAtAuction(ahFrame)
  if self.ShowFullShopping then self:ShowFullShopping() end -- (en lugar del panel pequeño)
  self:ShowMainFrame("shopping")
  local main = self:GetMainFrame()
  ahFrame = ahFrame or AuctionHouseFrame or AuctionFrame
  if ahFrame and main then
    main:ClearAllPoints()
    main:SetPoint("TOPLEFT", ahFrame, "TOPRIGHT", 4, 0) -- (se queda dentro de la pantalla: SetClampedToScreen)
  end
end

function ES:SetupAuctionPanel(ahFrame)
  if not listButton then
    listButton = CreateFrame("Button", nil, ahFrame, "UIPanelButtonTemplate")
    listButton:SetSize(150, 24)
    if CraftersJournalAHButton then
      listButton:SetPoint("RIGHT", CraftersJournalAHButton, "LEFT", -4, 0)
    else
      listButton:SetPoint("BOTTOMRIGHT", ahFrame, "TOPRIGHT", -184, 2)
    end
    listButton:SetScript("OnClick", function() ES:ToggleShoppingMini(ahFrame) end)
    listButton:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:AddLine(L["Lista de compra"])
      GameTooltip:AddLine(L["Enseña u oculta tu lista de compra al lado de la AH, para comprar sus materiales."], 1, 1, 1, true)
      GameTooltip:Show()
    end)
    listButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end
  state.searching, state.buying = nil, nil
  listButton:SetText(ButtonText())
  -- La ventana grande se esconde y sale el panel pequeño con la misma lista (ShoppingUI.lua)
  self:SetupShoppingMini(ahFrame)
end

ES.AuctionState = state -- para pruebas

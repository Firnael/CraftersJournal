local _, ES = ...

-- Puente con Auctionator (si está instalado): manda los materiales de un cálculo a
-- su pestaña Shopping. Usa su API pública v1 (Source/API/v1 de Auctionator):
--   CreateShoppingList: crea (o reemplaza) la lista "Crafter's Journal", que queda
--     en Shopping para cuando abras la AH
--   MultiSearchAdvanced: con la AH abierta, pasa a Shopping y busca ya (solo se
--     puede con la AH abierta; ningún addon puede abrirla: hay que hablar con el
--     subastador)
-- Se busca por el nombre del objeto en el idioma del juego (GetItemInfo), no en el
-- del addon: Auctionator busca por ese nombre. Búsqueda exacta y con la cantidad.
-- Precios de vuelta: tras nuestra búsqueda, cuando Auctionator procesa los precios
-- (RegisterForDBUpdate), se apunta el de cada objeto buscado que ha visto hoy
-- (GetAuctionAgeByItemID == 0) con la hora: ES.db.atrPrices[reino][itemID] =
-- { price, time }. La calculadora usa el más reciente, ese o el del último escaneo.

local AuctionatorBridge = {}
ES.Auctionator = AuctionatorBridge

local CALLER = "Crafter's Journal"
AuctionatorBridge.LIST_NAME = "Crafter's Journal"

local function API()
  local a = _G.Auctionator
  return a and a.API and a.API.v1
end

-- ¿Está Auctionator con lo que hace falta?
function AuctionatorBridge.Available()
  local api = API()
  return api ~= nil and type(api.CreateShoppingList) == "function" and type(api.ConvertToSearchString) == "function"
end

-- ¿AH abierta? (la ventana moderna o la clásica: la misma comprobación que Auctionator)
local function AHOpen()
  return (AuctionHouseFrame and AuctionHouseFrame:IsShown()) or (AuctionFrame and AuctionFrame:IsShown()) or false
end

local function ItemName(itemID)
  local get = (C_Item and C_Item.GetItemInfo) or GetItemInfo
  return get and (get(itemID))
end

-- Términos de búsqueda: { searchString, isExact, quantity }, uno por objeto (sumando
-- cantidades si se repite). items = { { itemID, qty } }; sin qty (lo que fabricas,
-- para ver a cuánto se vende), sin cantidad. Devuelve los términos y cuántos objetos
-- faltan por cargar (sin nombre aún: el juego los está pidiendo)
function AuctionatorBridge.Terms(items)
  local terms, byName, missing = {}, {}, 0
  for _, it in ipairs(items) do
    local name = ItemName(it.itemID)
    if name then
      local qty = it.qty and math.max(1, math.ceil(it.qty - 0.001)) or nil
      if byName[name] then
        if qty then byName[name].quantity = (byName[name].quantity or 0) + qty end
      else
        local term = { searchString = name, isExact = true, quantity = qty }
        byName[name] = term
        terms[#terms + 1] = term
      end
    else
      missing = missing + 1
      if C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, it.itemID) end
    end
  end
  return terms, missing
end

---------------------------------------------------------------------------
-- Precios de nuestras búsquedas
---------------------------------------------------------------------------
local WATCH_SECONDS = 180 -- tras buscar, cuánto se escuchan los precios que procesa Auctionator
local watching          -- { [itemID] = true, until = t }: lo que buscamos y hasta cuándo
local registered = false

local function Store()
  ES.db.atrPrices = ES.db.atrPrices or {}
  local key = ES:RealmKey()
  ES.db.atrPrices[key] = ES.db.atrPrices[key] or {}
  return ES.db.atrPrices[key]
end

-- Precio visto por Auctionator en nuestra búsqueda: { price, time } o nil
function AuctionatorBridge.Price(itemID)
  local s = ES.db and ES.db.atrPrices and ES.db.atrPrices[ES:RealmKey()]
  return s and s[itemID]
end

-- Auctionator ha procesado precios: los de lo que buscamos, si los vio hoy
function AuctionatorBridge.OnPrices()
  local api = API()
  if not (watching and api) then return 0 end
  if time() > watching.untilTime then watching = nil return 0 end
  local s, n = Store(), 0
  for itemID in pairs(watching.items) do
    local okAge, age = pcall(api.GetAuctionAgeByItemID, CALLER, itemID)
    local okPrice, price = pcall(api.GetAuctionPriceByItemID, CALLER, itemID)
    if okAge and okPrice and age == 0 and type(price) == "number" and price > 0 then
      local old = s[itemID]
      if not old or old.price ~= price then n = n + 1 end
      s[itemID] = { price = price, time = time() }
    end
  end
  if n > 0 and ES.RenderCalculator then ES:RenderCalculator() end
  return n
end

local function Watch(items)
  local api = API()
  if not (api and type(api.RegisterForDBUpdate) == "function" and type(api.GetAuctionPriceByItemID) == "function") then return end
  if not registered then
    registered = pcall(api.RegisterForDBUpdate, CALLER, AuctionatorBridge.OnPrices)
  end
  watching = { items = {}, untilTime = time() + WATCH_SECONDS }
  for _, it in ipairs(items) do watching.items[it.itemID] = true end
end

-- Manda los objetos a Auctionator. Devuelve "search" (AH abierta: buscando),
-- "list" (lista creada para cuando abras la AH), o nil y el motivo
-- ("unavailable", "empty", "error"). Con la AH abierta, los precios que encuentre
-- vuelven a la calculadora (ver OnPrices)
function AuctionatorBridge.Send(items)
  local api = API()
  if not AuctionatorBridge.Available() then return nil, "unavailable" end
  local terms, missing = AuctionatorBridge.Terms(items)
  if #terms == 0 then return nil, "empty", missing end
  local strings = {}
  for i, term in ipairs(terms) do
    local ok, s = pcall(api.ConvertToSearchString, CALLER, term)
    if not ok then return nil, "error", missing end
    strings[i] = s
  end
  -- La lista queda guardada en Auctionator (se reemplaza la anterior del addon)
  if not pcall(api.CreateShoppingList, CALLER, AuctionatorBridge.LIST_NAME, strings) then return nil, "error", missing end
  if AHOpen() and type(api.MultiSearchAdvanced) == "function" then
    Watch(items)
    if pcall(api.MultiSearchAdvanced, CALLER, terms) then return "search", nil, missing end
    watching = nil
  end
  return "list", nil, missing
end

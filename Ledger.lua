local _, ES = ...
local L = ES.L

-- Lo que el addon lee del juego al comprar, vender y entrenar (sin apuntar dinero:
-- el gasto real de la ruta se quitó porque se apuntaba mal con varias rutas):
--   (lo comprado en la AH no se sigue hasta el buzón: "tienes" son solo tus bolsas)
--   instructor: el precio real de cada receta (Ledger:ReadTrainer, Planner.Fee)
--   vendedor: qué vende y a cuánto (la ventana de compra de VendorUI.lua)
-- Vender al vendedor y anunciar en la AH desde la vista Profit: siempre con un
-- clic del jugador que dice exactamente qué va a hacer. El addon no compra ni
-- vende nada sin ese clic.

local Ledger = {}
ES.Ledger = Ledger

-- Diario de lo que lee (para diagnosticar en el juego): ES.db.ledgerLog
local function Log(text)
  ES.db.ledgerLog = ES.db.ledgerLog or {}
  local log = ES.db.ledgerLog
  log[#log + 1] = (date and date("%H:%M:%S ") or "") .. text
  while #log > 60 do table.remove(log, 1) end
end
Ledger.Log = Log

local NumSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
local ContainerItemID = (C_Container and C_Container.GetContainerItemID) or GetContainerItemID
local UseItem = (C_Container and C_Container.UseContainerItem) or UseContainerItem

-- Unidades de un objeto en una casilla de las bolsas
local function SlotCount(bag, slot)
  if C_Container and C_Container.GetContainerItemInfo then
    local info = C_Container.GetContainerItemInfo(bag, slot)
    return info and info.stackCount or 0
  end
  local _, count = GetContainerItemInfo(bag, slot)
  return count or 0
end

-- Casillas de las bolsas (no el banco) con este objeto: { {bag, slot, count} }
local function Slots(itemID)
  local list = {}
  if not (NumSlots and ContainerItemID) then return list end
  for bag = 0, 4 do
    for slot = 1, NumSlots(bag) or 0 do
      if ContainerItemID(bag, slot) == itemID then
        list[#list + 1] = { bag = bag, slot = slot, count = SlotCount(bag, slot) }
      end
    end
  end
  return list
end

local function BagCount(itemID)
  local n = 0
  for _, s in ipairs(Slots(itemID)) do n = n + s.count end
  return n
end
Ledger.BagCount = BagCount

-- Profesión del instructor abierto (por la línea de habilidad de lo que enseña), o nil
local PROF_SPELLS = { Alchemy = 2259, Blacksmithing = 2018, Enchanting = 7411, Engineering = 4036,
  Leatherworking = 2108, Tailoring = 3908, Cooking = 2550, FirstAid = 3273 }
local function SpellName(id)
  if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
  return GetSpellInfo and (GetSpellInfo(id))
end
local function TrainerProfession()
  if not (GetNumTrainerServices and GetTrainerServiceSkillLine) then return nil end
  for i = 1, GetNumTrainerServices() or 0 do
    local line = GetTrainerServiceSkillLine(i)
    if line and line ~= "" then
      for key, spell in pairs(PROF_SPELLS) do
        if line == SpellName(spell) or line == ES:ProfLabel(key) then return key end
      end
    end
  end
end

---------------------------------------------------------------------------
-- Precios reales del instructor: al abrirlo se lee lo que cobra y el nivel que pide
-- por cada receta y se guarda en CraftersJournalDB.trainerFees[spellID] =
-- { cost, skill, rep, time }. Forever ha cambiado precios y tiene recetas nuevas
-- sin precio conocido: lo visto en el juego manda sobre los datos (Planner.Fee)
---------------------------------------------------------------------------
-- Descuento del instructor por reputación (UnitReaction: 5 amistoso ... 8 exaltado)
local REP_DISCOUNT = { [5] = 0.05, [6] = 0.10, [7] = 0.15, [8] = 0.20 }
local REP_NAMES = { [5] = "Friendly", [6] = "Honored", [7] = "Revered", [8] = "Exalted" }

-- Precio sin el descuento de reputación (el que vale para todos)
local function BaseCost(seen)
  local d = REP_DISCOUNT[seen.rep or 0]
  return d and math.floor(seen.cost / (1 - d) + 0.5) or seen.cost
end
Ledger.BaseCost = BaseCost

-- Receta de la casilla `i` del instructor: por enlace (hechizo/encantamiento u objeto
-- fabricado) o por nombre (el del juego, en su idioma)
local function ServiceRecipe(i, profs)
  local link = GetTrainerServiceItemLink and GetTrainerServiceItemLink(i)
  local spell = link and tonumber(link:match("spell:(%d+)") or link:match("enchant:(%d+)"))
  local item = link and tonumber(link:match("item:(%d+)"))
  local name = GetTrainerServiceInfo and (GetTrainerServiceInfo(i))
  local names = ES.Data.NamesES and ES.Data.NamesES.spells or {}
  local byName = {}
  for _, key in ipairs(profs) do
    for id, r in pairs(ES.Data[key].recipes) do
      if spell == id then return id, r, key end
      if item and r.out and r.out[1] == item then return id, r, key end
      if name and (name == r.name or name == r.nameEN or name == names[id] or name == SpellName(id)) then
        byName[#byName + 1] = { id, r, key }
      end
    end
  end
  if #byName == 1 then return unpack(byName[1]) end -- con dos del mismo nombre no se adivina
end

-- La lista del instructor sigue sus filtros (disponibles / no disponibles / ya
-- sabidas): al abrirlo se muestran todos un momento para leer todas sus recetas y
-- se dejan como estaban. Solo al abrirlo (TRAINER_SHOW): cambiar un filtro lanza
-- TRAINER_UPDATE, que lee sin tocarlos (así no se repite sin fin)
local FILTERS = { "available", "unavailable", "used" }
function Ledger:ReadAllTrainerServices()
  if not (GetTrainerServiceTypeFilter and SetTrainerServiceTypeFilter) then return self:ReadTrainer() end
  local hidden = {}
  for _, f in ipairs(FILTERS) do
    if not GetTrainerServiceTypeFilter(f) then
      hidden[#hidden + 1] = f
      SetTrainerServiceTypeFilter(f, 1)
    end
  end
  local changed = self:ReadTrainer()
  for _, f in ipairs(hidden) do SetTrainerServiceTypeFilter(f, 0) end
  return changed
end

-- Cuántas recetas de instructor de cada profesión se han visto en el juego y cuántas
-- cobran distinto de los datos: { { prof, total, seen, diff } } (/cj instructor)
function Ledger:TrainerCoverage()
  local list = {}
  for _, p in ipairs(ES.PROFESSIONS or {}) do
    local data = ES.Data[p.key]
    if data and data.recipes and not data.guide then
      local total, seen, diff = 0, 0, 0
      for id, r in pairs(data.recipes) do
        if r.fee or r.trainer then
          total = total + 1
          local s = ES.db.trainerFees and ES.db.trainerFees[id]
          if s then
            seen = seen + 1
            if BaseCost(s) ~= r.fee or (s.skill and s.skill ~= r.train) then diff = diff + 1 end
          end
        end
      end
      list[#list + 1] = { prof = p.key, total = total, seen = seen, diff = diff }
    end
  end
  return list
end

function Ledger:ReadTrainer()
  if not (ES.db and GetNumTrainerServices and GetTrainerServiceCost) then return 0 end
  local prof = TrainerProfession()
  local profs = {}
  if prof then
    profs[1] = ES.Data[prof] and ES.Data[prof].recipes and prof or nil
  else
    for _, p in ipairs(ES.PROFESSIONS or {}) do
      if ES.Data[p.key] and ES.Data[p.key].recipes then profs[#profs + 1] = p.key end
    end
  end
  if #profs == 0 then return 0 end
  ES.db.trainerFees = ES.db.trainerFees or {}
  local rep = UnitReaction and UnitReaction("npc", "player") or nil
  local changed = 0
  local changedProfs = {}
  for i = 1, GetNumTrainerServices() or 0 do
    local kind = GetTrainerServiceInfo and select(3, GetTrainerServiceInfo(i))
    if kind ~= "header" then
      local id, r, key = ServiceRecipe(i, profs)
      local cost = id and GetTrainerServiceCost(i)
      if cost then
        local skill = GetTrainerServiceSkillReq and select(2, GetTrainerServiceSkillReq(i))
        local old = ES.db.trainerFees[id]
        if not old or old.cost ~= cost or old.skill ~= skill or old.rep ~= rep then
          changed = changed + 1
          changedProfs[key] = true
        end
        ES.db.trainerFees[id] = { cost = cost, skill = skill, rep = rep, prof = key, time = time() }
      elseif not id and prof then
        -- Receta que el instructor enseña y los datos no tienen (nueva de Forever, como
        -- Gray Leather Boots): se apunta para añadirla (/cj instructor). Los rangos de la
        -- profesión (Oficial, Experto...) se llaman como ella: esos no
        local name = GetTrainerServiceInfo and GetTrainerServiceInfo(i)
        if name and name ~= ES:ProfLabel(prof) and name ~= SpellName(PROF_SPELLS[prof]) then
          ES.db.trainerUnknown = ES.db.trainerUnknown or {}
          ES.db.trainerUnknown[prof] = ES.db.trainerUnknown[prof] or {}
          ES.db.trainerUnknown[prof][name] = { cost = GetTrainerServiceCost(i),
            skill = GetTrainerServiceSkillReq and select(2, GetTrainerServiceSkillReq(i)),
            link = GetTrainerServiceItemLink and GetTrainerServiceItemLink(i), time = time() }
        end
      end
    end
  end
  if changed > 0 then
    Log(string.format("instructor%s: %d precios nuevos o cambiados", prof and (" de " .. prof) or "", changed))
    -- Las rutas de esas profesiones se rehacen con el precio real, también la fijada:
    -- el precio del instructor es un dato, no un precio de mercado (sus recetas no
    -- cambian, solo lo que cuesta aprenderlas)
    for key in pairs(changedProfs) do
      if ES.InvalidatePlan then ES:InvalidatePlan(key) end
      if ES.lockedPlans then ES.lockedPlans[key] = nil end
    end
    if ES.RefreshProfessionPages then ES:RefreshProfessionPages() end
  end
  return changed
end

-- "1s 35c" (texto plano, sin iconos: va a un CSV)
local function PlainMoney(copper)
  if not copper then return "?" end
  local g, s, c = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
  local parts = {}
  if g > 0 then parts[#parts + 1] = g .. "g" end
  if s > 0 then parts[#parts + 1] = s .. "s" end
  if c > 0 or #parts == 0 then parts[#parts + 1] = c .. "c" end
  return table.concat(parts, " ")
end

-- Lo visto en el instructor que no coincide con los datos, como filas de
-- tools/forever/trainer_fees.csv (spell,name,cost,reqskill,source)
function Ledger:TrainerDiffs()
  local rows = {}
  for id, seen in pairs(ES.db and ES.db.trainerFees or {}) do
    local data = seen.prof and ES.Data[seen.prof]
    local r = data and data.recipes[id]
    if r then
      local base = BaseCost(seen)
      if base ~= r.fee or (seen.skill and seen.skill ~= r.train) then
        local profName = seen.prof:gsub("(%l)(%u)", "%1 %2") -- FirstAid -> First Aid
        local note = string.format("In-game %s trainer%s (%s%s; Requires %s (%s); data says %s at %s)",
          profName, date and (" " .. date("%Y-%m-%d", seen.time)) or "", PlainMoney(seen.cost),
          REP_NAMES[seen.rep or 0] and string.format(" at %s, base %s", REP_NAMES[seen.rep], PlainMoney(base)) or "",
          profName, tostring(seen.skill or "?"), PlainMoney(r.fee), tostring(r.train or "?"))
        local name = r.nameEN or r.name
        if name:find(",") then name = '"' .. name .. '"' end -- CSV
        rows[#rows + 1] = { id = id, line = string.format("%d,%s,%d,%s,%s", id, name, base,
          tostring(seen.skill or r.train or ""), note) }
      end
    end
  end
  table.sort(rows, function(a, b) return a.id < b.id end)
  for i, row in ipairs(rows) do rows[i] = row.line end
  return rows
end

---------------------------------------------------------------------------
-- Vendedor abierto: qué vende y a cuánto (VendorUI.lua)
---------------------------------------------------------------------------
-- Objeto de la casilla `i` del vendedor abierto
local function MerchantItemID(i)
  local id = GetMerchantItemID and GetMerchantItemID(i)
  if not id and GetMerchantItemLink then
    local link = GetMerchantItemLink(i)
    id = link and tonumber(link:match("item:(%d+)"))
  end
  return id
end
Ledger.MerchantItemID = MerchantItemID

-- Precio, cuántos vienen por compra, cuántos quedan (-1 sin límite), si se compra con
-- oro. Forever (cliente moderno) usa C_MerchantFrame.GetItemInfo; el clásico, GetMerchantItemInfo
local function MerchantInfo(i)
  if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
    local info = C_MerchantFrame.GetItemInfo(i)
    if info then
      return info.price, info.stackCount, info.numAvailable, info.isPurchasable ~= false and not info.hasExtendedCost
    end
  elseif GetMerchantItemInfo then
    local _, _, price, stack, avail, purchasable, _, ext = GetMerchantItemInfo(i)
    return price, stack, avail, purchasable ~= false and not ext
  end
end
Ledger.MerchantInfo = MerchantInfo

---------------------------------------------------------------------------
-- Lo que paga de verdad el vendedor: en Forever no siempre coincide con los datos
-- del cliente (Hillman's Shoulders: 6s 59c, no 11s 99c). Al vender algo con el
-- vendedor abierto (con el addon o a mano) se apunta qué y cuántos, y cuando sube
-- tu dinero, a cuánto salió cada uno: ES.db.sellSeen[itemID] = { price, time, ok }.
-- ES:VendorSellPrice lo usa antes que los datos solo si ok (coincide con lo conocido
-- o se ha visto dos veces seguidas)
---------------------------------------------------------------------------
local sellPending = {} -- ventas enviadas aún sin cobrar: { itemID, count, t }
local SELL_WINDOW = 3  -- s entre vender y que suba tu dinero

local function NoteSale(bag, slot)
  if not (MerchantFrame and MerchantFrame:IsShown()) then return end
  local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bag, slot)
  local itemID = info and info.itemID or (ContainerItemID and ContainerItemID(bag, slot))
  local count = info and info.stackCount or SlotCount(bag, slot)
  -- Solo lo que el vendedor compra (sin valor: no hay venta que esperar) y sin
  -- dañar (el equipo dañado se paga menos: no es su precio)
  if not itemID or not count or count <= 0 or (info and info.hasNoValue) then return end
  local getDur = C_Container and C_Container.GetContainerItemDurability or GetContainerItemDurability
  local cur, max = getDur and getDur(bag, slot)
  -- Lo dañado también cobra: ocupa su turno en la cola (sin apuntarse) para que su
  -- dinero no se tome por el de la venta siguiente
  local damaged = cur and max and max > 0 and cur < max
  sellPending[#sellPending + 1] = { itemID = itemID, count = count, t = GetTime and GetTime() or 0, skip = damaged or nil }
end
if hooksecurefunc then
  if C_Container and C_Container.UseContainerItem then
    hooksecurefunc(C_Container, "UseContainerItem", NoteSale)
  elseif UseContainerItem then
    hooksecurefunc("UseContainerItem", NoteSale)
  end
end

-- Sube tu dinero: es el cobro de la venta pendiente más antigua (cada venta sube
-- el dinero por separado; vendiendo varias pilas seguidas, una tras otra). Lo llama
-- Books.OnMoney (la contabilidad) con el vendedor abierto; devuelve la venta cobrada
local LearnPrice
local function ChargeSale(delta)
  local now = GetTime and GetTime() or 0
  while sellPending[1] and now - sellPending[1].t > SELL_WINDOW do table.remove(sellPending, 1) end
  local p = table.remove(sellPending, 1)
  if not p then return nil end
  if not p.skip then LearnPrice(p, delta) end
  return p
end

local function HasPendingSale() return sellPending[1] ~= nil end

-- El precio real del vendedor, de lo que cobró una venta
function LearnPrice(p, delta)
  local itemID = p.itemID
  local unit = math.floor(delta / p.count + 0.5)
  -- Solo si cuadra con el precio que se conocía (entre un 20% y el doble de los
  -- datos o del cliente): otro dinero que llegue a la vez (botín, misión, correo)
  -- no se apunta como precio de venta
  local data = ES.Data.SellPrices[itemID]
  local live = GetItemInfo and select(11, GetItemInfo(itemID))
  local known = data or live
  if not known or known <= 0 or unit < 0.2 * known or unit > 2 * known then return end
  ES.db.sellSeen = ES.db.sellSeen or {}
  local old = ES.db.sellSeen[itemID]
  -- Un cobro suelto puede ser de otra cosa (una venta que no pasó por aquí, una
  -- pieza dañada, dinero que llegó a la vez): un precio distinto del conocido solo
  -- vale cuando se repite (Greater Magic Wand quedó en 1s 68c pagando 2s)
  local ok = unit == data or unit == live or (old ~= nil and old.price == unit)
  ES.db.sellSeen[itemID] = { price = unit, time = time(), ok = ok or nil }
  if ok and not (old and old.ok and old.price == unit) then
    Log(string.format("vendedor: %d paga %d cada uno", itemID, unit))
    if ES.ClearHomeCache then ES:ClearHomeCache() end -- (lo que se recupera vendiendo cambia)
  elseif old and old.ok and not ok then
    if ES.ClearHomeCache then ES:ClearHomeCache() end -- (el anterior deja de valer)
  end
end
Ledger.NoteSale, Ledger.ChargeSale, Ledger.HasPendingSale = NoteSale, ChargeSale, HasPendingSale

do
  local f = CreateFrame("Frame")
  for _, e in ipairs({ "TRAINER_SHOW", "TRAINER_UPDATE", "PLAYER_ENTERING_WORLD",
    "MERCHANT_SHOW", "MERCHANT_CLOSED", "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED" }) do
    ES.SafeRegister(f, e)
  end
  f:SetScript("OnEvent", function(_, event)
    if not ES.db then return end
    if event == "MERCHANT_SHOW" or event == "MERCHANT_CLOSED" or event == "AUCTION_HOUSE_SHOW" or event == "AUCTION_HOUSE_CLOSED" then
      -- La vista Profit cambia sus clics (vender al vendedor, anunciar en la AH)
      if ES.RefreshAfterBags then ES:RefreshAfterBags() end
    elseif event == "TRAINER_SHOW" or event == "TRAINER_UPDATE" then
      local ok, err = pcall(event == "TRAINER_SHOW" and Ledger.ReadAllTrainerServices or Ledger.ReadTrainer, Ledger)
      if not ok then Log("instructor: error leyendo precios: " .. tostring(err)) end
    elseif event == "PLAYER_ENTERING_WORLD" then
      ES.db.mailBought = nil -- compras de la AH "en el correo" (ya no se cuentan)
    end
    -- (los cambios de dinero los sigue Books.lua, que cobra aquí las ventas al vendedor)
  end)
end

---------------------------------------------------------------------------
-- Vender y anunciar (vista Profit): siempre desde un clic del jugador
---------------------------------------------------------------------------
function Ledger:MerchantOpen()
  return MerchantFrame and MerchantFrame:IsShown() and true or false
end

-- Vende hasta `n` unidades al vendedor abierto, pilas enteras que quepan en `n`.
-- Devuelve cuántas vendió.
function Ledger:SellToVendor(itemID, n)
  if not self:MerchantOpen() or not UseItem or n <= 0 then return 0 end
  local sold = 0
  for _, s in ipairs(Slots(itemID)) do
    if sold + s.count <= n then
      UseItem(s.bag, s.slot)
      sold = sold + s.count
    end
  end
  if sold < n then
    ES:Print(string.format(L["Vendidos %d de %d: el resto está en pilas más grandes de lo que hay que vender."], sold, n))
  end
  return sold
end

-- Precio de anuncio en la AH de Forever: solo admite platas enteras (redondeo hacia abajo)
function Ledger.PostPrice(unit)
  unit = math.floor(unit or 0)
  return math.max(unit - unit % 100, 100)
end

-- Anuncia `n` unidades en la AH abierta a `unit` cobre cada una (24 h). Solo con
-- la AH de Forever (C_AuctionHouse); con la clásica, se anuncia a mano. Los
-- materiales (commodities) van en un solo anuncio; el resto, todos de una vez y,
-- si la AH no lo acepta, de uno en uno. Devuelve cuántos anunció.
function Ledger:PostOnAH(itemID, n, unit)
  local AH = C_AuctionHouse
  if not (ES:IsAuctionHouseOpen() and AH and AH.PostItem and ItemLocation) then
    ES:Print(L["Anúncialo desde la ventana de la Casa de Subastas."])
    return 0
  end
  if AH.IsThrottledMessageSystemReady and not AH.IsThrottledMessageSystemReady() then
    ES:Print(L["La Casa de Subastas está ocupada: vuelve a pulsar en un momento."])
    return 0
  end
  local slot
  for _, s in ipairs(Slots(itemID)) do
    local locked = C_Container and C_Container.GetContainerItemInfo and (C_Container.GetContainerItemInfo(s.bag, s.slot) or {}).isLocked
    if not locked then slot = s break end
  end
  if not slot or n <= 0 then return 0 end
  local qty = math.min(n, BagCount(itemID))
  local location = ItemLocation:CreateFromBagAndSlot(slot.bag, slot.slot)
  local commodity = false
  if AH.GetItemCommodityStatus then
    local ok, status = pcall(AH.GetItemCommodityStatus, location)
    local COMMODITY = Enum and Enum.ItemCommodityStatus and Enum.ItemCommodityStatus.Commodity or 2
    commodity = ok and status == COMMODITY
  end
  local price = Ledger.PostPrice(unit)
  local ok, err
  if ES.Books then -- (la contabilidad apunta la subasta y espera su depósito)
    ES.Books.posting = itemID
    ES.Books.postingDeposit = ES.Books.CalcDeposit(commodity, location, itemID, 2, qty)
  end
  if commodity and AH.PostCommodity then
    ok, err = pcall(AH.PostCommodity, location, 2, qty, price)
  else
    ok, err = pcall(AH.PostItem, location, 2, qty, nil, price)
    if not ok and qty > 1 then -- no acepta varios de una vez: uno (el resto, con otro clic)
      qty = 1
      if ES.Books then ES.Books.postingDeposit = ES.Books.CalcDeposit(false, location, itemID, 2, 1) end
      ok, err = pcall(AH.PostItem, location, 2, 1, nil, price)
    end
  end
  if ES.Books then ES.Books.posting, ES.Books.postingDeposit = nil, nil end
  if not ok then
    ES:Print(L["No se pudo anunciar: "] .. tostring(err))
    return 0
  end
  ES:Print(string.format(L["Anunciados %d de %s a %s cada uno (24 h)."], qty, ES:DataItemName(itemID) or itemID, ES.Money(price)))
  return qty
end

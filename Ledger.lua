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

-- Funciones de las bolsas: C_Container (cliente moderno) o las de siempre. Se buscan
-- al usarlas, no al cargar (así también valen las de las pruebas)
local function CC(name) return (C_Container and C_Container[name]) or _G[name] end
local function NumSlots(bag) local f = CC("GetContainerNumSlots") return f and f(bag) or 0 end
local function ContainerItemID(bag, slot) local f = CC("GetContainerItemID") return f and f(bag, slot) end
local function UseItem(bag, slot) local f = CC("UseContainerItem") if f then f(bag, slot) end end

-- Una casilla libre en una bolsa normal (no de hierbas, de encantamiento...): bag, slot
local function EmptySlot()
  local free = CC("GetContainerNumFreeSlots")
  for bag = 0, 4 do
    local n, family = 1, 0
    if free then n, family = free(bag) end
    if (n or 0) > 0 and (family or 0) == 0 then
      for slot = 1, NumSlots(bag) do
        if not ContainerItemID(bag, slot) then return bag, slot end
      end
    end
  end
end

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
  self.fullList = true -- (la lista entera: lo que no sale, este instructor no lo enseña)
  local ok, changed = pcall(self.ReadTrainer, self)
  self.fullList = nil
  for _, f in ipairs(hidden) do SetTrainerServiceTypeFilter(f, 0) end
  if not ok then error(changed, 0) end
  return changed
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
  local listed, top, low = {}, 0, math.huge
  local guid = UnitGUID and UnitGUID("npc")
  local npc = guid and tonumber(guid:match("^%a+%-%d+%-%d+%-%d+%-%d+%-(%d+)%-"))
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
        -- (npc: el instructor donde se vio, para llevarte a él: Forever enseña algunas
        -- solo en sitios concretos, como Stranglethorn)
        ES.db.trainerFees[id] = { cost = cost, skill = skill, rep = rep, prof = key, time = time(), npc = npc or (old and old.npc) }
        listed[id] = true
        if skill and skill > 0 then
          top = math.max(top, skill)
          low = math.min(low, skill)
        end
      end
    end
  end
  -- Recetas de instructor de los datos que no enseña ningún instructor visto (con su
  -- lista entera a la vista): Forever ha quitado o movido algunas (Green Iron
  -- Leggings) y la ruta pedía aprender algo que tu instructor no tiene. Solo dentro
  -- del tramo de niveles que enseña cada instructor visto (en Forever cada rango
  -- tiene los suyos: uno de Experto no dice nada de las de Oficial). Si otro
  -- instructor la enseña (en Stranglethorn, por ejemplo), vuelve
  if self.fullList and prof and top > 0 then
    local seen = ES.db.trainerListed or {}
    ES.db.trainerListed = seen
    seen[prof] = seen[prof] or { ranges = {}, ids = {} }
    local s = seen[prof]
    s.ranges = s.ranges or {}
    local key = low .. "-" .. top
    s.ranges[key] = { low, top }
    for id in pairs(listed) do s.ids[id] = true end
    -- "rank": el instructor de su rango no la tiene; Forever ha subido algunas al
    -- rango siguiente (Green Iron Leggings, de 130, la enseña el de Experto: Bengus
    -- Deepforge), así que la fila Entrenar lleva a ese. "gone": tampoco está en un
    -- instructor de más nivel que hayas visto: no se enseña, fuera de las rutas
    local function Covered(level)
      for _, rg in pairs(s.ranges) do
        if level >= rg[1] and level <= rg[2] then return true end
      end
      return false
    end
    local function Above(level)
      for _, rg in pairs(s.ranges) do
        if rg[1] > level then return true end
      end
      return false
    end
    ES.db.trainerMissing = ES.db.trainerMissing or {}
    local missing = ES.db.trainerMissing
    for id, r in pairs(ES.Data[prof].recipes) do
      local trainerRecipe = (r.fee or r.trainer) and not r.scroll and not r.basic and not r.favor
      local level = r.train or 0
      local now = trainerRecipe and not s.ids[id] and Covered(level) and (Above(level) and "gone" or "rank") or nil
      if missing[id] ~= now then
        missing[id] = now
        changed = changed + 1
        changedProfs[prof] = true
      end
    end
    -- Tu ruta empezada pasa por una de ellas (aún no la has hecho): ya no se puede
    -- seguir; se suelta y se calcula otra desde tu nivel
    local lock = ES.RouteLock and ES:RouteLock(prof)
    if lock and lock.choice then
      local skill = ES:GetProfessionSkill(ES.Data[prof].skillLine) or lock.from
      for s, id in pairs(lock.choice) do
        if s >= skill and missing[id] == "gone" and not (ES.IsRecipeKnown and ES:IsRecipeKnown(id)) then
          ES:StopRoute(prof)
          ES:Print(string.format(L["Tu ruta de %s usaba %s, que este instructor no enseña: se calcula otra desde tu nivel."],
            ES:ProfLabel(prof), ES.Data[prof].recipes[id].name))
          changedProfs[prof] = true
          changed = changed + 1
          break
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
  local itemID = info and info.itemID or ContainerItemID(bag, slot)
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
-- PLAYER_MONEY (abajo) con el vendedor abierto; devuelve la venta cobrada
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

-- Cambia tu dinero: con el vendedor abierto y una venta enviada, es su cobro (de ahí
-- sale el precio real del vendedor, ver LearnPrice). No se apunta nada más del dinero
local lastMoney
function Ledger.OnMoney(money)
  money = money or (GetMoney and GetMoney()) or 0
  local delta = lastMoney and money - lastMoney or 0
  lastMoney = money
  if delta > 0 and Ledger:MerchantOpen() and HasPendingSale() then ChargeSale(delta) end
end

do
  local f = CreateFrame("Frame")
  for _, e in ipairs({ "TRAINER_SHOW", "TRAINER_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_MONEY",
    "MERCHANT_SHOW", "MERCHANT_CLOSED", "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED" }) do
    ES.SafeRegister(f, e)
  end
  f:SetScript("OnEvent", function(_, event)
    if not ES.db then return end
    if event == "PLAYER_MONEY" then
      Ledger.OnMoney()
    elseif event == "MERCHANT_SHOW" or event == "MERCHANT_CLOSED" or event == "AUCTION_HOUSE_SHOW" or event == "AUCTION_HOUSE_CLOSED" then
      -- La vista Profit cambia sus clics (vender al vendedor, anunciar en la AH)
      if ES.RefreshAfterBags then ES:RefreshAfterBags() end
    elseif event == "TRAINER_SHOW" or event == "TRAINER_UPDATE" then
      local ok, err = pcall(event == "TRAINER_SHOW" and Ledger.ReadAllTrainerServices or Ledger.ReadTrainer, Ledger)
      if not ok then Log("instructor: error leyendo precios: " .. tostring(err)) end
    elseif event == "PLAYER_ENTERING_WORLD" then
      ES.db.mailBought = nil -- compras de la AH "en el correo" (ya no se cuentan)
      Ledger.OnMoney() -- (punto de partida del dinero)
    end
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
  if not self:MerchantOpen() or not CC("UseContainerItem") or n <= 0 then return 0 end
  local sold = 0
  local slots = Slots(itemID)
  for _, s in ipairs(slots) do
    if sold + s.count <= n then
      UseItem(s.bag, s.slot)
      sold = sold + s.count
      s.used = true
    end
  end
  -- Lo que queda está en una pila más grande (17 y hay que vender 12): se parte. Las
  -- 12 van a una casilla libre y se vende esa pila; las otras 5 se quedan
  local left = n - sold
  if left > 0 then
    local from
    for _, s in ipairs(slots) do if not s.used and s.count > left then from = s break end end
    local bag, slot = EmptySlot()
    local split, pickup = CC("SplitContainerItem"), CC("PickupContainerItem")
    if from and bag and split and pickup and not (CursorHasItem and CursorHasItem()) then
      split(from.bag, from.slot, left)
      pickup(bag, slot)
      -- (el juego tarda un momento en dejar la pila nueva en su casilla)
      C_Timer.After(0.5, function()
        if self:MerchantOpen() and ContainerItemID(bag, slot) == itemID then UseItem(bag, slot) end
      end)
      sold = n
    elseif from and not bag then
      ES:Print(string.format(L["Vendidos %d de %d: para vender el resto hace falta un hueco libre en la bolsa (se parte la pila)."], sold, n))
    else
      ES:Print(string.format(L["Vendidos %d de %d: el resto está en pilas más grandes de lo que hay que vender."], sold, n))
    end
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
  if commodity and AH.PostCommodity then
    ok, err = pcall(AH.PostCommodity, location, 2, qty, price)
  else
    ok, err = pcall(AH.PostItem, location, 2, qty, nil, price)
    if not ok and qty > 1 then -- no acepta varios de una vez: uno (el resto, con otro clic)
      qty = 1
      ok, err = pcall(AH.PostItem, location, 2, 1, nil, price)
    end
  end
  if not ok then
    ES:Print(L["No se pudo anunciar: "] .. tostring(err))
    return 0
  end
  ES:Print(string.format(L["Anunciados %d de %s a %s cada uno (24 h)."], qty, ES:DataItemName(itemID) or itemID, ES.Money(price)))
  return qty
end

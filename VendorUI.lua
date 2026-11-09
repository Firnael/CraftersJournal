local _, ES = ...
local L = ES.L

-- Al abrir un vendedor que tiene algo de tu lista de la compra (de las rutas
-- empezadas o, si no hay, de la profesión que estabas mirando) sale al lado una
-- ventana con esos materiales: lo que te falta, con un botón "Comprar todo", y lo
-- que ya tienes, en gris. Debajo, lo fabricado que la vista Profit dice que vendas
-- al vendedor y llevas encima, con "Vender todo". Solo compra o vende cuando
-- pulsas (fila o botón).
--
-- Comprar en Forever: cada compra pide un número de objetos (como mucho una pila);
-- el servidor ignora las compras que llegan muy seguidas, así que van de una en
-- una con BUY_GAP de separación y al final se comprueba lo que ha llegado.

local Vendor = { queue = {} }
ES.VendorShop = Vendor

local BUY_GAP = 0.35
local MAX_WAITS = 5 -- comprobaciones (de 1 s) esperando a que llegue lo comprado
local ROW_H, MAX_ROWS = 34, 12
local WIDTH = 270

local function Ledger() return ES.Ledger end

-- Rutas de las que sale la lista de la compra: las empezadas; si no hay ninguna,
-- la de la profesión que estabas mirando (si ya está calculada)
local function Plans()
  local plans = {}
  for _, prof in ipairs(ES.PROFESSIONS) do
    local plan = ES:RouteLock(prof.key) and ES:LockedPlan(prof.key)
    if plan then plans[#plans + 1] = { key = prof.key, plan = plan } end
  end
  -- La última profesión que miraste (si después abriste Ganar dinero, lastProf es
  -- "money": entonces la última profesión de esta sesión)
  local key = ES.db.lastProf
  if not (key and ES.Data[key]) then key = ES.lastRouteProf end
  if #plans == 0 and key then
    local plan
    for _, page in ipairs(ES.professionPages or {}) do
      if page.profKey == key then plan = page.plan end
    end
    plan = plan or (ES.homePlanCache[key] and ES.homePlanCache[key].plan)
    if plan and plan.pointNeed then plans[1] = { key = key, plan = plan } end
  end
  return plans
end

-- Lo que pide la lista de la compra desde tu nivel, y lo que tienes (bolsas, más lo
-- que acabas de comprar aquí y aún no ha llegado): { [itemID] = { need, have } }
local function Needs()
  local need = {}
  for _, p in ipairs(Plans()) do
    local rank = ES:GetProfessionSkill(ES.Data[p.key].skillLine)
    for itemID, q in pairs(ES.Planner.NeedFrom(p.plan, math.max(p.plan.from, rank or p.plan.from))) do
      need[itemID] = (need[itemID] or 0) + q
    end
  end
  -- Lo intermedio que ya has fabricado (Bolt of Silk Cloth, Cured Light Hide...) y
  -- llevas encima ya no necesita sus materiales: si no, se volvían a comprar (la sal
  -- del cuero curado, por ejemplo)
  for _, p in ipairs(Plans()) do
    -- (lo que ya llevabas al calcular la ruta no cuenta: la ruta lo usa sin pedir sus materiales)
    local ownedAtPlan = p.plan.ctx and p.plan.ctx.opts and p.plan.ctx.opts.owned or {}
    for _, c in ipairs(p.plan.crafted or {}) do
      local r = c.recipe
      local made = r and r.r and math.max(0, ES:ItemCount(c.itemID) - (ownedAtPlan[c.itemID] or 0)) or 0
      if made > 0 then
        made = math.min(made, c.quantity or made)
        local per = (r.out and r.out[2]) or 1
        for _, rq in ipairs(r.r) do
          if need[rq[1]] then need[rq[1]] = math.max(0, need[rq[1]] - made * rq[2] / per) end
        end
      end
    end
  end
  local out = {}
  for itemID, q in pairs(need) do
    local n = math.ceil(q - 0.001)
    if n > 0 then
      out[itemID] = { need = n, have = ES:ItemCount(itemID) + Vendor:Pending(itemID) }
    end
  end
  return out
end

-- Lo de la lista de la compra que vende este vendedor:
-- { { index, itemID, need, have, qty (lo que falta, en lotes; 0 si tienes bastante), price, batch, cost } }
function Vendor:List()
  local list = {}
  if not (GetMerchantNumItems and Ledger()) then return list end
  local needs = Needs()
  for i = 1, GetMerchantNumItems() or 0 do
    local itemID = Ledger().MerchantItemID(i)
    local n = itemID and needs[itemID]
    if n then
      local price, batch, avail, gold = Ledger().MerchantInfo(i)
      if price and price > 0 and gold and avail ~= 0 then
        batch = math.max(batch or 1, 1)
        local left = math.max(0, n.need - n.have)
        local qty = math.ceil(left / batch) * batch -- el vendedor vende en sus lotes
        list[#list + 1] = { index = i, itemID = itemID, need = n.need, have = n.have, qty = qty, price = price,
          batch = batch, cost = qty / batch * price }
        needs[itemID] = nil -- un objeto que el vendedor tiene dos veces, una sola fila
      end
    end
  end
  -- Lo que falta primero (lo más caro arriba); lo que ya tienes, al final
  table.sort(list, function(a, b)
    if (a.qty > 0) ~= (b.qty > 0) then return a.qty > 0 end
    return a.cost > b.cost
  end)
  return list
end

-- Lo que la vista Profit dice que vendas al vendedor y llevas en las bolsas (de las
-- mismas rutas): { { itemID, n, unit, value } }, lo que más da arriba
function Vendor:SellList()
  local sell = {}
  if not Ledger() then return {} end
  for _, p in ipairs(Plans()) do
    for _, d in ipairs(p.plan.destinations or {}) do
      local a = ES.Planner.SaleAdvice(d)
      if a.vendor > 0 then sell[d.itemID] = (sell[d.itemID] or 0) + a.vendor end
    end
  end
  local list = {}
  for itemID, n in pairs(sell) do
    n = math.min(n, Ledger().BagCount(itemID))
    local unit = ES:VendorSellPrice(itemID) or 0
    if n > 0 and unit > 0 then list[#list + 1] = { itemID = itemID, n = n, unit = unit, value = n * unit } end
  end
  table.sort(list, function(a, b) return a.value > b.value or (a.value == b.value and a.itemID < b.itemID) end)
  return list
end

-- Vende `entry` (de Vendor:SellList), o todo, de uno en uno con BUY_GAP (como las compras)
function Vendor:Sell(entries)
  local i = 0
  local function Next()
    i = i + 1
    local e = entries[i]
    if not e or not Ledger():MerchantOpen() then
      self.selling = nil
      self:Refresh()
      return
    end
    Ledger():SellToVendor(e.itemID, e.n)
    C_Timer.After(BUY_GAP, Next)
  end
  if self.selling then return end
  self.selling = true
  Next()
end

---------------------------------------------------------------------------
-- Cola de compras
---------------------------------------------------------------------------
function Vendor:Pending(itemID)
  local n = 0
  for _, q in ipairs(self.queue) do if q.itemID == itemID and q.n then n = n + q.n end end
  return n
end

local function StackSize(itemID)
  local get = (C_Item and C_Item.GetItemMaxStackCount) or nil
  local n = get and get(itemID)
  if not n and GetItemInfo then n = select(8, GetItemInfo(itemID)) end
  return math.max(n or 1, 1)
end

local function FindIndex(itemID)
  for i = 1, (GetMerchantNumItems and GetMerchantNumItems()) or 0 do
    if Ledger().MerchantItemID(i) == itemID then return i end
  end
end

-- Lo más que se puede pedir en una compra: lo que deja el vendedor (o una pila), en lotes enteros
local function PerCall(itemID, batch)
  local i = FindIndex(itemID)
  local most = math.max((i and GetMerchantItemMaxStack and GetMerchantItemMaxStack(i)) or 1, StackSize(itemID))
  return math.max(math.floor(most / batch) * batch, batch)
end

-- Pone en la cola `qty` unidades en compras de como mucho `perCall`
local function Enqueue(queue, itemID, qty, perCall, at)
  local calls = {}
  while qty > 0 do
    local n = math.min(qty, perCall)
    calls[#calls + 1] = { itemID = itemID, n = n }
    qty = qty - n
  end
  for k = #calls, 1, -1 do table.insert(queue, at or (#queue + 1), calls[k]) end
end

function Vendor:Pump()
  local q = table.remove(self.queue, 1)
  if not q or not Ledger():MerchantOpen() then
    self.pumping = nil
    if not Ledger():MerchantOpen() then self.queue = {} end
    self:Refresh()
    return
  end
  self.pumping = true
  if q.check then
    -- Comprobación final: lo que no llegó se vuelve a pedir (hasta 2 veces). Pero solo
    -- cuando ya no llega nada más: si el servidor tarda en entregar, volver a pedir al
    -- primer vistazo compraba de más. Se espera (1 s cada vez, hasta MAX_WAITS) mientras
    -- las bolsas sigan cambiando
    local count = ES:ItemCount(q.itemID)
    local short = q.check - count
    if short > 0 and count ~= q.lastCount and (q.waits or 0) < MAX_WAITS then
      table.insert(self.queue, 1, { itemID = q.itemID, check = q.check, tries = q.tries, batch = q.batch,
        lastCount = count, waits = (q.waits or 0) + 1 })
    elseif short > 0 and q.tries < 2 then
      if FindIndex(q.itemID) then
        short = math.ceil(short / q.batch) * q.batch
        table.insert(self.queue, 1, { itemID = q.itemID, check = q.check, tries = q.tries + 1, batch = q.batch })
        Enqueue(self.queue, q.itemID, short, PerCall(q.itemID, q.batch), 1) -- en tandas, delante de la comprobación
      end
    elseif short > 0 then
      ES:Print(string.format(L["El vendedor no vendió %d de %s (sin existencias, sin oro o sin sitio en las bolsas)."],
        short, ES:DataItemName(q.itemID) or q.itemID))
    end
  else
    local i = FindIndex(q.itemID)
    if i then BuyMerchantItem(i, q.n) end
  end
  C_Timer.After(q.check and 1.0 or BUY_GAP, function() Vendor:Pump() end)
end

-- Compra `entry` (de Vendor:List): en tandas de como mucho una pila
function Vendor:Buy(entry)
  -- Ya se está comprando (p. ej. "Comprar todo" y luego un clic en su fila): no dos veces
  for _, q in ipairs(self.queue) do if q.itemID == entry.itemID then return end end
  local target = ES:ItemCount(entry.itemID) + entry.qty
  Enqueue(self.queue, entry.itemID, entry.qty, PerCall(entry.itemID, entry.batch))
  self.queue[#self.queue + 1] = { itemID = entry.itemID, check = target, tries = 0, batch = entry.batch }
  if not self.pumping then self:Pump() end
end

function Vendor:BuyAll()
  local list = {}
  for _, e in ipairs(self:List()) do if e.qty > 0 then list[#list + 1] = e end end
  local total = 0
  for _, e in ipairs(list) do total = total + e.cost end
  if total > ((GetMoney and GetMoney()) or 0) then
    ES:Print(string.format(L["Comprarlo todo cuesta %s: más de lo que llevas."], ES.Money(total)))
    return
  end
  for _, e in ipairs(list) do self:Buy(e) end
  ES:Print(string.format(L["Comprando %d materiales de la lista de la compra por %s..."], #list, ES.Money(total)))
end

---------------------------------------------------------------------------
-- Ventana
---------------------------------------------------------------------------
local panel
local SECTION_H = 20
local SELL_ROWS = 4 -- filas reservadas para vender (ver Refresh)

-- Tooltip y clic de una fila: comprar lo que falta o vender lo que sobra
local function RowClick(self)
  if self.kind == "buy" and self.entry.qty > 0 then Vendor:Buy(self.entry)
  elseif self.kind == "sell" then Vendor:Sell({ self.entry }) end
end

local function RowEnter(self)
  if not self.entry then return end
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  if GameTooltip.SetItemByID then GameTooltip:SetItemByID(self.entry.itemID) end
  GameTooltip:AddLine(" ")
  if self.kind == "sell" then
    GameTooltip:AddLine(string.format(L["Clic: vender %d por %s."], self.entry.n, ES.Money(self.entry.value)), 0.5, 0.8, 1)
  elseif self.entry.qty > 0 then
    GameTooltip:AddLine(string.format(L["Clic: comprar %d por %s."], self.entry.qty, ES.Money(self.entry.cost)), 0.5, 0.8, 1)
  else
    GameTooltip:AddLine(L["Ya tienes lo que te hace falta para la ruta."], 0.4, 1, 0.4)
  end
  GameTooltip:Show()
end

local function CreatePanel()
  local f = CreateFrame("Frame", "CraftersJournalVendorPanel", MerchantFrame or UIParent, "BackdropTemplate")
  f:SetWidth(WIDTH)
  f:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  f:SetBackdropBorderColor(0.68, 0.52, 0.20, 1)
  f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  f.title:SetPoint("TOPLEFT", 12, -10)
  f.sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  f.sub:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -3)
  f.sub:SetWidth(WIDTH - 24)
  f.sub:SetJustifyH("LEFT")
  -- Encabezado de la sección de vender (se coloca al pintar, tras las filas de comprar)
  f.sellHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  f.rows = {}
  for i = 1, MAX_ROWS do
    local row = CreateFrame("Button", nil, f)
    row:SetSize(WIDTH - 16, ROW_H)
    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 0.82, 0.25, 0.1)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(26, 26)
    row.icon:SetPoint("LEFT", 2, 0)
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, -1)
    row.name:SetPoint("RIGHT", -70, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row.qty = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.qty:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 6, 1)
    row.cost = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.cost:SetPoint("RIGHT", -4, 0)
    row:SetScript("OnClick", RowClick)
    row:SetScript("OnEnter", RowEnter)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f.rows[i] = row
  end
  f.buyAll = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  f.buyAll:SetSize(WIDTH - 24, 24)
  f.buyAll:SetScript("OnClick", function() Vendor:BuyAll() end)
  f.sellAll = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  f.sellAll:SetSize(WIDTH - 24, 24)
  f.sellAll:SetScript("OnClick", function()
    local list = Vendor:SellList()
    local total = 0
    for _, e in ipairs(list) do total = total + e.value end
    ES:Print(string.format(L["Vendiendo %d objetos de tus rutas por %s..."], #list, ES.Money(total)))
    Vendor:Sell(list)
  end)
  f:Hide()
  return f
end

local function Icon(row, itemID, grey)
  local _, _, texture = ES:GetItemData(itemID)
  row.icon:SetTexture(texture or (GetItemIcon and GetItemIcon(itemID)) or 134400)
  row.icon:SetDesaturated(grey)
end

local function Label(itemID)
  local name = ES:GetItemData(itemID)
  return name or ES:DataItemName(itemID) or ("#" .. itemID)
end

function Vendor:Refresh()
  if not (MerchantFrame and MerchantFrame:IsShown()) then
    if panel then panel:Hide() end
    return
  end
  local list, sell = self:List(), self:SellList()
  if #list == 0 and #sell == 0 and not self.pumping and not self.selling then
    if panel then panel:Hide() end
    return
  end
  panel = panel or CreatePanel()
  panel:ClearAllPoints()
  panel:SetPoint("TOPLEFT", MerchantFrame, "TOPRIGHT", 4, 0)
  panel.title:SetText("Crafter's Journal")
  local total, missing = 0, 0
  for _, e in ipairs(list) do
    total = total + e.cost
    if e.qty > 0 then missing = missing + 1 end
  end
  panel.sub:SetText(self.pumping and L["Comprando…"] or self.selling and L["Vendiendo…"]
    or #list == 0 and L["Para vender al vendedor, de tus rutas:"]
    or missing > 0 and L["De tu lista de la compra, este vendedor tiene:"]
    or L["Ya tienes todo lo que te hace falta de este vendedor."])
  -- Filas: lo que comprar y, debajo, lo que vender (entre las dos, como mucho MAX_ROWS)
  local y = -40
  -- (con algo que vender, al menos SELL_ROWS filas para ello: una lista de compra
  -- larga no tapa la sección de vender ni su botón)
  local shownBuy = math.min(#list, MAX_ROWS - math.min(#sell, SELL_ROWS))
  local shownSell = math.min(#sell, MAX_ROWS - shownBuy)
  local r = 0
  for i = 1, shownBuy do
    r = r + 1
    local row, e = panel.rows[r], list[i]
    row.kind, row.entry = "buy", e
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 8, y)
    y = y - ROW_H
    Icon(row, e.itemID, e.qty == 0)
    local label = Label(e.itemID)
    if e.qty > 0 then
      row.name:SetText(label)
      row.qty:SetText(string.format(L["Tienes %d/%d · compras %d × %s"], math.min(e.have, e.need), e.need, e.qty,
        ES.Money(e.price / e.batch))
        -- Vende de N en N: puede comprar algo más de lo que falta (que se sepa por qué)
        .. (e.batch > 1 and e.qty > e.need - e.have and (" · " .. string.format(L["en lotes de %d"], e.batch)) or ""))
      row.cost:SetText(ES.Money(e.cost))
    else
      -- Ya lo tienes: se ve, en gris, para que sepas que este vendedor también lo vende
      row.name:SetText("|cff9d9d9d" .. label:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") .. "|r")
      row.qty:SetText("|cff40ff40" .. string.format(L["Tienes %d/%d"], e.have, e.need) .. "|r")
      row.cost:SetText("")
    end
    row:Show()
  end
  panel.buyAll:ClearAllPoints()
  panel.buyAll:SetShown(shownBuy > 0)
  if shownBuy > 0 then
    panel.buyAll:SetPoint("TOP", panel, "TOP", 0, y - 6)
    y = y - 34
    panel.buyAll:SetText(missing > 0 and string.format(L["Comprar todo (%s)"], ES.Money(total)) or L["Nada que comprar"])
    panel.buyAll:SetEnabled(missing > 0 and not self.pumping)
  end
  local sellTotal = 0
  for _, e in ipairs(sell) do sellTotal = sellTotal + e.value end
  panel.sellHeader:SetShown(shownSell > 0 and shownBuy > 0)
  if shownSell > 0 and shownBuy > 0 then
    panel.sellHeader:ClearAllPoints()
    panel.sellHeader:SetPoint("TOPLEFT", 12, y - 4)
    panel.sellHeader:SetText(L["Vender al vendedor"])
    y = y - SECTION_H - 4
  end
  for i = 1, shownSell do
    r = r + 1
    local row, e = panel.rows[r], sell[i]
    row.kind, row.entry = "sell", e
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 8, y)
    y = y - ROW_H
    Icon(row, e.itemID, false)
    row.name:SetText(Label(e.itemID))
    row.qty:SetText(string.format(L["Vendes %d × %s"], e.n, ES.Money(e.unit)))
    row.cost:SetText("|cff40ff40+" .. ES.Money(e.value) .. "|r")
    row:Show()
  end
  for k = r + 1, MAX_ROWS do
    panel.rows[k].entry, panel.rows[k].kind = nil, nil
    panel.rows[k]:Hide()
  end
  panel.sellAll:ClearAllPoints()
  panel.sellAll:SetShown(shownSell > 0)
  if shownSell > 0 then
    panel.sellAll:SetPoint("TOP", panel, "TOP", 0, y - 6)
    y = y - 34
    panel.sellAll:SetText(string.format(L["Vender todo (%s)"], ES.Money(sellTotal)))
    panel.sellAll:SetEnabled(not self.selling)
  end
  panel:SetHeight(-y + 10)
  panel:Show()
end

do
  local f = CreateFrame("Frame")
  for _, e in ipairs({ "MERCHANT_SHOW", "MERCHANT_CLOSED", "MERCHANT_UPDATE", "BAG_UPDATE_DELAYED", "GET_ITEM_INFO_RECEIVED" }) do
    ES.SafeRegister(f, e)
  end
  local queued = false
  local function Later(delay)
    C_Timer.After(delay, function() if MerchantFrame and MerchantFrame:IsShown() then Vendor:Refresh() end end)
  end
  f:SetScript("OnEvent", function(_, event)
    if not ES.db then return end
    if event == "MERCHANT_CLOSED" then
      Vendor.queue, Vendor.pumping, Vendor.selling = {}, nil, nil
      if panel then panel:Hide() end
    elseif MerchantFrame and MerchantFrame:IsShown() then
      if event == "GET_ITEM_INFO_RECEIVED" then
        -- Llegan los objetos del vendedor que el juego aún no tenía: una vez, agrupado
        if not queued then
          queued = true
          C_Timer.After(0.3, function() queued = false if MerchantFrame:IsShown() then Vendor:Refresh() end end)
        end
        return
      end
      Vendor:Refresh()
      -- Al abrir, el juego a veces aún no sabe qué vende (sin enlaces): se vuelve a mirar
      if event == "MERCHANT_SHOW" then Later(0.4) Later(1.5) end
    end
  end)
end

local _, ES = ...
local L = ES.L

-- Contabilidad del personaje: cada cambio de tu dinero queda apuntado como un
-- movimiento con su categoría. La regla que hace que funcione:
--   el total siempre cuadra. Lo que ninguna captura explica se apunta como
--   "otros" (botín, misiones...), así que la suma de los movimientos es siempre
--   lo que ha cambiado tu dinero; lo que puede fallar es la categoría, no el total.
-- Cada captura apunta el movimiento una sola vez, cuando ocurre:
--   antes de que cambie el dinero se anuncia lo que se espera (Expect/Claim: una
--   compra en la AH, el depósito al anunciar, cobrar un correo...) y el cambio de
--   dinero que llega se lo lleva. Si el dinero llega antes que la captura (un trade),
--   la captura reclasifica el "otros" de hace un momento con esa cantidad.
-- Se guarda por personaje en ES.charData.books = { moves, posts, days, partners }:
--   moves[i]  = { t, k = categoría, m = cobre con signo, i = objeto, q = cantidad, w = quién, n = nota }
--   posts[i]  = { t, i, q, u = precio por unidad, name, s = estado (nil abierta, sold, expired, cancelled,
--                 unknown = sin noticias pasada su duración), c = cerrada, mail = cerrada por mensaje, falta su correo }
--   days[YYYY-MM-DD] = { first = dinero antes del primer cambio del día, last }
--   partners[jugador] = { [1] = categoría al recibir dinero, [-1] = al pagar }
-- Del correo solo se lee la factura del que cobras, al cobrarlo: nada más del buzón.

local Books = {}
ES.Books = Books

local DAY = 86400
local MAX_MOVES = 2000
local MAX_POSTS = 1000
local KEEP_DAYS = 90
local EXPECT_WINDOW = 10 -- s que espera una captura a que cambie el dinero
local CLAIM_WINDOW = 5   -- s hacia atrás en los que una captura puede quedarse un "otros"
local POST_LIFE = 50 * 3600 -- la subasta más larga (48 h) y un margen para su correo
local MAIL_REPEAT = 10   -- s en los que un mismo correo no se cuenta otra vez

Books.KINDS = ES.Localize({
  ahSale = "Ventas en la AH", ahBuy = "Compras en la AH", ahDeposit = "Depósitos de la AH",
  ahOther = "Otros de la AH (pujas devueltas...)",
  vendorSale = "Ventas al vendedor", vendorBuy = "Compras al vendedor", repair = "Reparaciones",
  trainer = "Instructor", sale = "Ventas a jugadores", buy = "Compras a jugadores",
  trade = "Trades sin contar", mail = "Correo sin contar", other = "Otros (botín, misiones...)",
})
Books.ORDER = { "ahSale", "vendorSale", "sale", "ahBuy", "vendorBuy", "buy", "ahDeposit", "ahOther",
  "trainer", "repair", "trade", "mail", "other" }

local Log = function(text) if ES.Ledger and ES.Ledger.Log then ES.Ledger.Log("cuentas: " .. text) end end

local function Now() return GetTime and GetTime() or time() end

local function DayKey(t)
  t = t or time()
  if date then return date("%Y-%m-%d", t) end
  return tostring(math.floor(t / DAY))
end

-- Inicio del día de hoy (medianoche local)
local function Midnight()
  if date then
    local d = date("*t")
    d.hour, d.min, d.sec = 0, 0, 0
    return time(d)
  end
  return math.floor(time() / DAY) * DAY
end

function Books.Data()
  local c = ES.charData
  if not c then return nil end
  local b = c.books
  if type(b) ~= "table" then
    b = { moves = {}, posts = {}, days = {}, partners = {} }
    c.books = b
  end
  b.moves, b.posts, b.days, b.partners = b.moves or {}, b.posts or {}, b.days or {}, b.partners or {}
  return b
end

local function Money() return GetMoney and GetMoney() or 0 end

local function ItemName(itemID)
  if not itemID then return nil end
  return (GetItemInfo and (GetItemInfo(itemID))) or (ES.DataItemName and ES:DataItemName(itemID))
end

---------------------------------------------------------------------------
-- Movimientos y lo que se espera
---------------------------------------------------------------------------
local pending = {} -- { kind, amount (exacto) o sign (+1/-1) y max, info, untilT }
local recent = {}  -- movimientos "otros" de hace un momento: { move, at }
local lastMoney
Books.pending, Books.recent = pending, recent -- para pruebas

local function Add(kind, delta, info)
  local b = Books.Data()
  if not b then return nil end
  local m = { t = time(), k = kind, m = delta }
  if info then
    m.i, m.q, m.w, m.n = info.i, info.q, info.w, info.n
    m.g, m.r = info.g, info.r
  end
  b.moves[#b.moves + 1] = m
  return m
end

local function Apply(move, kind, info)
  move.k = kind
  if info then
    move.i, move.q, move.w, move.n = info.i or move.i, info.q or move.q, info.w or move.w, info.n or move.n
    move.g, move.r = info.g or move.g, info.r or move.r
  end
end

-- Lo que se espera que cambie el dinero en los próximos segundos.
--   amount: exacto (con signo); o sign = +1/-1 con min y max (en valor absoluto, opcionales)
function Books.Expect(kind, spec, info)
  local e = { kind = kind, amount = spec.amount, sign = spec.sign, min = spec.min, max = spec.max, info = info,
    untilT = Now() + (spec.window or EXPECT_WINDOW), onMatch = spec.onMatch }
  pending[#pending + 1] = e
  return e
end

-- Una captura que sabe la cantidad exacta: si ese dinero ya llegó (como "otros"),
-- se lo queda; si no, lo espera
function Books.Claim(kind, amount, info, onMatch)
  local t = Now()
  for idx = #recent, 1, -1 do
    local r = recent[idx]
    if t - r.at <= CLAIM_WINDOW and r.move.k == "other" and r.move.m == amount then
      table.remove(recent, idx)
      Apply(r.move, kind, info)
      Log(string.format("%s %d (llegó antes que su causa)", kind, amount))
      if onMatch then onMatch(r.move) end
      return r.move
    end
  end
  Books.Expect(kind, { amount = amount, onMatch = onMatch }, info)
end

local function TakeExpected(delta)
  local t = Now()
  for idx = #pending, 1, -1 do
    if pending[idx].untilT < t then table.remove(pending, idx) end
  end
  -- Primero las exactas; luego las de solo signo, de la más antigua a la más nueva
  for idx, e in ipairs(pending) do
    if e.amount and e.amount == delta then return table.remove(pending, idx) end
  end
  local sign = delta > 0 and 1 or -1
  for idx, e in ipairs(pending) do
    if not e.amount and e.sign == sign and (not e.max or math.abs(delta) <= e.max) and (not e.min or math.abs(delta) >= e.min) then
      return table.remove(pending, idx)
    end
  end
end

local function AHOpen()
  return ES.ahOpen or (AuctionHouseFrame and AuctionHouseFrame:IsShown()) or (AuctionFrame and AuctionFrame:IsShown()) or false
end
local function MerchantOpen() return MerchantFrame and MerchantFrame:IsShown() or false end

-- Ha cambiado tu dinero: se apunta el movimiento (siempre, aunque sea "otros")
function Books.OnMoney(money)
  money = money or Money()
  if lastMoney == nil then lastMoney = money return end
  local delta = money - lastMoney
  lastMoney = money
  if delta == 0 then return end
  local b = Books.Data()
  if not b then return end
  local day = DayKey()
  local d = b.days[day]
  if not d then d = { first = money - delta } b.days[day] = d end
  d.last = money
  b.lastMoney = money

  local e = TakeExpected(delta)
  if e then
    local move = Add(e.kind, delta, e.info)
    if e.onMatch then e.onMatch(move) end
    return move
  end
  -- Venta al vendedor (la detecta Ledger al vender; también aprende el precio real)
  if delta > 0 and MerchantOpen() and ES.Ledger and ES.Ledger.HasPendingSale and ES.Ledger.HasPendingSale() then
    local p = ES.Ledger.ChargeSale(delta)
    if p then return Add("vendorSale", delta, { i = p.itemID, q = p.count }) end
  end
  local note
  if MerchantOpen() then note = L["con el vendedor abierto"]
  elseif AHOpen() then note = L["con la AH abierta"] end
  if note then Log(string.format("%d sin causa conocida (%s)", delta, note)) end
  local move = Add("other", delta, note and { n = note } or nil)
  recent[#recent + 1] = { move = move, at = Now() }
  while #recent > 10 do table.remove(recent, 1) end
  return move
end

-- Al entrar: punto de partida de la sesión (y del día, si es el primero)
function Books.Start()
  local b = Books.Data()
  local money = Money()
  -- Lo último apuntado no coincide con lo que tienes: lo que cambió sin el addon
  -- (otra versión, el addon desactivado...) se apunta, y la sesión y el día empiezan
  -- antes de ese ajuste para que también cuadren
  local before = money
  if b then
    if b.lastMoney and b.lastMoney ~= money then before = b.lastMoney end
    local day = DayKey()
    b.days[day] = b.days[day] or { first = before, last = before }
    if before ~= money then
      Add("other", money - before, { n = L["fuera de sesión"] })
      b.days[day].last = money
    end
    b.lastMoney = money
  end
  lastMoney = money
  Books.session = Books.session or { start = before, t = time() }
  Books.Prune()
end

function Books.Prune()
  local b = Books.Data()
  if not b then return end
  local cutoff = time() - KEEP_DAYS * DAY
  local keep = {}
  for _, m in ipairs(b.moves) do if m.t >= cutoff then keep[#keep + 1] = m end end
  while #keep > MAX_MOVES do table.remove(keep, 1) end
  b.moves = keep
  local posts = {}
  for _, p in ipairs(b.posts) do
    -- Más vieja que la subasta más larga y sin noticias: no se sabe qué pasó (no cuenta
    -- ni como vendida ni como caducada)
    if not p.s and time() - p.t > POST_LIFE then p.s, p.c = "unknown", time() end
    if not p.c or p.c >= cutoff then posts[#posts + 1] = p end
  end
  while #posts > MAX_POSTS do table.remove(posts, 1) end
  b.posts = posts
  local oldDay = DayKey(cutoff)
  for day in pairs(b.days) do if day < oldDay then b.days[day] = nil end end
end

---------------------------------------------------------------------------
-- Resúmenes
---------------------------------------------------------------------------
-- Suma por categoría de los movimientos desde `from` (time()): { [kind] = cobre }, total
function Books.Totals(from)
  local b = Books.Data()
  local totals, total = {}, 0
  for _, m in ipairs(b and b.moves or {}) do
    if m.t >= from then
      totals[m.k] = (totals[m.k] or 0) + m.m
      total = total + m.m
    end
  end
  return totals, total
end

-- Hoy: { totals, total (de los movimientos), net (dinero de ahora - el de antes del primer cambio) }
function Books.Today()
  local b = Books.Data()
  local totals, total = Books.Totals(Midnight())
  local d = b and b.days[DayKey()]
  return { totals = totals, total = total, net = d and (d.last - d.first) or 0 }
end

function Books.Session()
  if not Books.session then return nil end
  local totals, total = Books.Totals(Books.session.t)
  return { totals = totals, total = total, net = Money() - Books.session.start }
end

local function PrintTotals(title, s)
  ES:Print(string.format("%s: %s%s", title, ES.UI and ES.UI.Signed and ES.UI.Signed(-s.net) or tostring(s.net),
    s.total == s.net and "" or ("|cffff4040 " .. string.format(L["(los movimientos suman %s: no cuadra)"], ES.Money(math.abs(s.total))) .. "|r")))
  for _, k in ipairs(Books.ORDER) do
    local v = s.totals[k]
    if v and v ~= 0 then
      print(string.format("   %s: %s", Books.KINDS[k], ES.UI and ES.UI.Signed and ES.UI.Signed(-v) or tostring(v)))
    end
  end
end

-- /cj cuentas: hoy y la sesión por categoría; /cj cuentas log: los últimos movimientos
function Books.Report(what)
  if not Books.Data() then return end
  if what == "log" then
    local moves = Books.Data().moves
    ES:Print(L["Últimos movimientos de dinero:"])
    for idx = math.max(1, #moves - 14), #moves do
      local m = moves[idx]
      local item = m.i and (ItemName(m.i) or ("#" .. m.i)) or nil
      print(string.format("   %s %s %s%s%s%s", date and date("%H:%M", m.t) or "", ES.UI.Signed(-m.m), Books.KINDS[m.k] or m.k,
        item and (" · " .. (m.q and (m.q .. "× ") or "") .. item) or "", m.w and (" · " .. m.w) or "", m.n and (" · " .. m.n) or ""))
    end
    return
  end
  PrintTotals(L["Hoy"], Books.Today())
  local s = Books.Session()
  if s then PrintTotals(L["Esta sesión"], s) end
  local open = 0
  for _, p in ipairs(Books.Data().posts) do if not p.s then open = open + 1 end end
  if open > 0 then ES:Print(string.format(L["%d subastas anunciadas sin vender ni caducar todavía."], open)) end
  ES:Print(L["/cj cuentas log: los últimos movimientos."])
end

---------------------------------------------------------------------------
-- Subastas anunciadas: se abren al anunciar y se cierran con el mensaje del juego
-- (vendida, caducada, cancelada). Las usarán las estadísticas de venta.
---------------------------------------------------------------------------
-- deposit: el que se calculó antes de anunciar (exacto), o nil (cualquier bajada en 5 s)
function Books.NotePost(itemID, qty, unit, deposit)
  local b = Books.Data()
  if not b then return end
  b.posts[#b.posts + 1] = { t = time(), i = itemID, q = qty, u = unit, name = ItemName(itemID) }
  if deposit and deposit > 0 then
    -- (con un margen: el cálculo del juego puede redondear distinto que el cobro)
    Books.Expect("ahDeposit", { sign = -1, min = math.floor(deposit * 0.95), max = math.ceil(deposit * 1.05) + 1, window = 5 },
      { i = itemID, q = qty })
  elseif not deposit then
    Books.Expect("ahDeposit", { sign = -1, window = 5 }, { i = itemID, q = qty })
  end
end

local function IsPost(p, name) return p.name == name or (p.i ~= nil and ItemName(p.i) == name) end

-- La subasta abierta más antigua de ese objeto (por nombre: es lo que dan los mensajes)
local function OpenPost(name)
  local b = Books.Data()
  for _, p in ipairs(b and b.posts or {}) do
    if not p.s and IsPost(p, name) then return p end
  end
end

-- Mensaje del juego (vendida, caducada, cancelada): se cierra la más antigua abierta y
-- queda a la espera de su correo (el dinero o el objeto devuelto)
function Books.ClosePost(name, status)
  local p = OpenPost(name)
  if not p then return nil end
  p.s, p.c, p.mail = status, time(), true
  return p
end

-- Llega el correo de una subasta: es el de la que ya cerró su mensaje, si la hay; si
-- no (pasó estando desconectado, sin mensaje), se cierra la abierta más antigua
function Books.PostMail(name, status)
  local b = Books.Data()
  if not (b and name) then return nil end
  for _, p in ipairs(b.posts) do
    if p.mail and p.s == status and IsPost(p, name) then
      p.mail = nil
      return p
    end
  end
  local p = OpenPost(name)
  if p then p.s, p.c = status, time() end
  return p
end

-- "%s" del juego -> patrón de Lua
local function Pattern(fmt)
  if type(fmt) ~= "string" then return nil end
  local p = fmt:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
  p = p:gsub("%%%%s", "(.+)"):gsub("%%%%d", "(%%d+)")
  return "^" .. p .. "$"
end
Books.Pattern = Pattern

function Books.OnSystemMessage(msg)
  if type(msg) ~= "string" then return end
  for _, s in ipairs({ { "ERR_AUCTION_SOLD_S", "sold" }, { "ERR_AUCTION_EXPIRED_S", "expired" }, { "ERR_AUCTION_REMOVED_S", "cancelled" } }) do
    local pat = Pattern(_G[s[1]])
    local name = pat and msg:match(pat)
    if name then
      local p = Books.ClosePost(name, s[2])
      Log(string.format("subasta %s: %s%s", s[2], name, p and "" or " (no estaba apuntada)"))
      return s[2], name
    end
  end
end

---------------------------------------------------------------------------
-- Dinero de jugadores (trade, correo): se pregunta cómo contarlo
---------------------------------------------------------------------------
local asks = {}
local asking

local function ItemsText(list)
  local parts = {}
  for _, it in ipairs(list or {}) do parts[#parts + 1] = (it.q or 1) .. "× " .. (ItemName(it.i) or it.name or "?") end
  return table.concat(parts, ", ")
end

local function ShowNextAsk()
  if asking or #asks == 0 then return end
  if not (StaticPopupDialogs and StaticPopup_Show) then asks = {} return end
  asking = table.remove(asks, 1)
  local move = asking
  local sale = move.m > 0
  StaticPopupDialogs.CRAFTERSJOURNAL_BOOKS = {
    text = "%s", button1 = sale and L["Sí, venta"] or L["Sí, compra"], button2 = L["No contar"],
    button3 = string.format(sale and L["Siempre venta con %s"] or L["Siempre compra con %s"], move.w or "?"),
    OnAccept = function() Books.Resolve(move, sale and "sale" or "buy") end,
    OnCancel = function() Books.Resolve(move, nil) end,
    OnAlt = function() Books.Resolve(move, sale and "sale" or "buy", true) end,
    -- Cerrado sin pasar por sus botones (otro addon, una pantalla de carga...): se
    -- queda sin contar y la cola sigue
    OnHide = function() if asking == move then Books.Resolve(move, nil) end end,
    timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
  }
  local text
  if move.k == "trade" then
    local gave, got = ItemsText(move.g), ItemsText(move.r)
    if sale then
      gave, got = gave ~= "" and gave or L["nada"], ES.Money(move.m)
    else
      gave, got = ES.Money(-move.m), got ~= "" and got or L["nada"]
    end
    text = string.format(L["Trade con %s: diste %s y recibiste %s."], move.w or "?", gave, got)
  else
    text = sale and string.format(L["Correo de %s con %s."], move.w or "?", ES.Money(move.m))
      or string.format(L["Pagaste %s a %s por un correo contra reembolso."], ES.Money(-move.m), move.w or "?")
  end
  text = text .. "\n\n" .. (sale and L["¿Lo cuento como venta en tus ganancias?"] or L["¿Lo cuento como compra de materiales en tus gastos?"])
  StaticPopup_Show("CRAFTERSJOURNAL_BOOKS", text)
end

-- Respuesta del jugador: kind nil = no contar (se queda como trade o correo)
function Books.Resolve(move, kind, always)
  if kind then move.k = kind end
  if always and move.w then
    local b = Books.Data()
    b.partners[move.w] = b.partners[move.w] or {}
    b.partners[move.w][move.m > 0 and 1 or -1] = kind
  end
  if asking == move then asking = nil end
  -- El siguiente, cuando este haya terminado de cerrarse (desde sus propios botones
  -- no se puede abrir otro del mismo tipo)
  if C_Timer and C_Timer.After then C_Timer.After(0.1, ShowNextAsk) else ShowNextAsk() end
end

-- Un movimiento de dinero con otro jugador: lo que se eligió para él antes, o se pregunta
function Books.Ask(move)
  local b = Books.Data()
  local pref = b and move.w and b.partners[move.w] and b.partners[move.w][move.m > 0 and 1 or -1]
  if pref then
    move.k = pref
    ES:Print(string.format(L["%s con %s contado como %s (como siempre con este jugador)."], ES.Money(math.abs(move.m)),
      move.w, Books.KINDS[pref]))
    return
  end
  asks[#asks + 1] = move
  ShowNextAsk()
end

---------------------------------------------------------------------------
-- Capturas
---------------------------------------------------------------------------
local H = {}
Books.hooks = H -- para pruebas

local function ItemIDFromLink(link)
  return type(link) == "string" and tonumber(link:match("item:(%d+)")) or nil
end

-- AH moderna: materiales (empezar compra -> precio -> confirmar) y objetos (puja/compra)
local commodity = {}
function H.StartCommoditiesPurchase(itemID, qty) commodity = { i = itemID, q = qty } end
function H.CommodityPrice(_, total) commodity.total = total end
function H.ConfirmCommoditiesPurchase(itemID, qty)
  local total = commodity.i == itemID and commodity.total or nil
  Books.Expect("ahBuy", { sign = -1, max = total }, { i = itemID, q = qty })
  commodity = {}
end
function H.PlaceBid(_, amount)
  local itemID
  pcall(function()
    local key = AuctionHouseFrame.ItemBuyFrame:GetItemKey()
    itemID = key and key.itemID
  end)
  if amount and amount > 0 then Books.Claim("ahBuy", -amount, { i = itemID }) end
end
-- AH clásica
function H.PlaceAuctionBid(listType, index, bid)
  local itemID, count
  if GetAuctionItemInfo then
    local info = { GetAuctionItemInfo(listType, index) }
    count, itemID = info[3], info[17]
  end
  if not itemID and GetAuctionItemLink then itemID = ItemIDFromLink(GetAuctionItemLink(listType, index)) end
  if bid and bid > 0 then Books.Claim("ahBuy", -bid, { i = itemID, q = count }) end
end

-- Anunciar: moderna (PostItem/PostCommodity, también las de Ledger:PostOnAH) y clásica
local function LocationItem(location)
  local id
  pcall(function() id = C_Item and C_Item.GetItemID and C_Item.GetItemID(location) end)
  return id
end
-- Depósito que cobrará el juego (AH moderna), o nil si no se puede calcular
function Books.CalcDeposit(commodity, location, itemID, duration, qty)
  local A, d = C_AuctionHouse, nil
  if not A then return nil end
  pcall(function()
    if commodity and itemID and A.CalculateCommodityDeposit then
      d = A.CalculateCommodityDeposit(itemID, duration, qty)
    elseif location and A.CalculateItemDeposit then
      d = A.CalculateItemDeposit(location, duration, qty)
    end
  end)
  return type(d) == "number" and d or nil
end

-- Ledger:PostOnAH dice antes de anunciar qué anuncia y su depósito (Books.posting,
-- Books.postingDeposit): tras anunciar, la casilla puede no responder ya. Las que
-- anuncias a mano, con lo que se pueda leer después
local function Posted(commodity, location, duration, qty)
  local id = LocationItem(location) or Books.posting
  local deposit = Books.postingDeposit or Books.CalcDeposit(commodity, location, id, duration, qty)
  Books.posting, Books.postingDeposit = nil, nil
  return id, deposit
end
function H.PostItem(location, duration, qty, _, buyout)
  local id, deposit = Posted(false, location, duration, qty)
  Books.NotePost(id, qty, buyout, deposit)
end
function H.PostCommodity(location, duration, qty, unit)
  local id, deposit = Posted(true, location, duration, qty)
  Books.NotePost(id, qty, unit, deposit)
end
function H.PostAuction(_, buyout, _, stackSize, numStacks)
  local itemID
  if GetAuctionSellItemInfo then
    local info = { GetAuctionSellItemInfo() }
    itemID = info[10]
  end
  stackSize = stackSize or 1
  for _ = 1, math.max(1, numStacks or 1) do
    Books.NotePost(itemID, stackSize, buyout and math.floor(buyout / stackSize) or nil)
  end
end

-- Vendedor
function H.BuyMerchantItem(index, qty)
  local price, stack = ES.Ledger.MerchantInfo(index)
  if not price or price <= 0 then return end
  local n = qty or math.max(1, stack or 1)
  -- (tope: precio x cantidad, valga la cantidad unidades o paquetes en este cliente)
  Books.Expect("vendorBuy", { sign = -1, max = price * math.max(1, n) + 1 }, { i = ES.Ledger.MerchantItemID(index), q = n })
end
function H.BuybackItem(index)
  local price, qty = select(3, GetBuybackItemInfo(index))
  if price and price > 0 then
    Books.Claim("vendorBuy", -price, { i = GetBuybackItemLink and ItemIDFromLink(GetBuybackItemLink(index)), q = qty, n = L["recompra"] })
  end
end
function H.RepairAllItems() Books.Expect("repair", { sign = -1, window = 5 }) end

-- Instructor
function H.BuyTrainerService(index)
  local cost = GetTrainerServiceCost and GetTrainerServiceCost(index)
  if cost and cost > 0 then Books.Expect("trainer", { sign = -1, max = cost }, { n = GetTrainerServiceInfo and (GetTrainerServiceInfo(index)) or nil }) end
end

-- Correo: al cobrar uno, su factura (si es de la AH) o quién lo manda.
-- Un mismo correo no se cuenta dos veces (un addon de correo puede llamar a
-- TakeInboxMoney y a AutoLootMailItem para el mismo). Dos correos iguales (dos
-- ventas del mismo objeto al mismo precio) no son el mismo: entre uno y otro el
-- buzón cambia (MAIL_INBOX_UPDATE), y eso vacía lo visto
local seenMail = {}
local function Repeated(what, index, sender, subject, money, daysLeft)
  local key = table.concat({ what, tostring(index), tostring(sender), tostring(subject), tostring(money), tostring(daysLeft) }, "|")
  local t = Now()
  for k, at in pairs(seenMail) do if t - at > MAIL_REPEAT then seenMail[k] = nil end end
  if seenMail[key] then return true end
  seenMail[key] = t
  return false
end
Books.seenMail = seenMail -- para pruebas

-- Nombre del objeto del asunto de un correo de la AH ("Auction expired: %s"), o nil
local function SubjectItem(subject, global)
  local pat = Pattern(_G[global])
  return pat and type(subject) == "string" and subject:match(pat) or nil
end

function H.TakeInboxMoney(index)
  if not GetInboxHeaderInfo then return end
  local _, _, sender, subject, money, _, daysLeft, _, _, _, _, canReply = GetInboxHeaderInfo(index)
  if not money or money <= 0 or Repeated("money", index, sender, subject, money, daysLeft) then return end
  local invoiceType, itemName, _, _, _, _, _, _, _, count
  if GetInboxInvoiceInfo then invoiceType, itemName, _, _, _, _, _, _, _, count = GetInboxInvoiceInfo(index) end
  if invoiceType == "seller" then
    local post = Books.PostMail(itemName, "sold")
    local itemID = post and post.i
    Books.Claim("ahSale", money, { i = itemID, q = type(count) == "number" and count or (post and post.q), n = not itemID and itemName or nil })
  elseif invoiceType then
    Books.Claim("ahOther", money, { n = subject })
  elseif canReply then
    -- De un jugador: se pregunta cuando llegue el dinero
    Books.Claim("mail", money, { w = sender, n = subject }, Books.Ask)
  else
    Books.Claim("mail", money, { w = sender, n = subject })
  end
end
-- Coger el objeto de un correo: si es una subasta devuelta (caducada o cancelada), se
-- cierra; si es contra reembolso, lo pagas
function H.TakeInboxItem(index)
  if not GetInboxHeaderInfo then return end
  local _, _, sender, subject, _, cod, daysLeft = GetInboxHeaderInfo(index)
  if Repeated("item", index, sender, subject, cod, daysLeft) then return end
  local expired, removed = SubjectItem(subject, "AUCTION_EXPIRED_MAIL_SUBJECT"), SubjectItem(subject, "AUCTION_REMOVED_MAIL_SUBJECT")
  if expired or removed then
    local p = Books.PostMail(expired or removed, expired and "expired" or "cancelled")
    Log(string.format("correo de subasta %s: %s%s", expired and "caducada" or "cancelada", expired or removed, p and "" or " (no estaba apuntada)"))
  end
  if cod and cod > 0 then Books.Claim("mail", -cod, { w = sender, n = subject }, Books.Ask) end
end
function H.AutoLootMailItem(index)
  H.TakeInboxMoney(index)
  H.TakeInboxItem(index)
end

-- Trade: lo que hay en la ventana justo antes de cerrarse
local trade
local MAX_TRADE = MAX_TRADABLE_ITEMS or 6
function H.TradeSnapshot()
  if not (GetPlayerTradeMoney and GetTargetTradeMoney) then return end
  local t = { w = UnitName and UnitName("NPC") or nil, give = GetPlayerTradeMoney() or 0, get = GetTargetTradeMoney() or 0, g = {}, r = {} }
  -- (con "x and f()" solo llegaría el primer valor: se llama aparte)
  local function Read(list, info, link, idx)
    if not info then return end
    local name, _, n = info(idx)
    if name then list[#list + 1] = { i = ItemIDFromLink(link and link(idx)), q = n, name = name } end
  end
  for idx = 1, MAX_TRADE do
    Read(t.g, GetTradePlayerItemInfo, GetTradePlayerItemLink, idx)
    Read(t.r, GetTradeTargetItemInfo, GetTradeTargetItemLink, idx)
  end
  trade = t
end
function H.TradeComplete()
  local t = trade
  trade = nil
  if not t then return end
  local delta = t.get - t.give
  if delta == 0 then return end
  local g, r = {}, {}
  for _, it in ipairs(t.g) do g[#g + 1] = { i = it.i, q = it.q } end
  for _, it in ipairs(t.r) do r[#r + 1] = { i = it.i, q = it.q } end
  Books.Claim("trade", delta, { w = t.w, g = #g > 0 and g or nil, r = #r > 0 and r or nil }, Books.Ask)
end

-- Un error en una captura no rompe la función del juego, pero queda apuntado
-- (en el diario y en /cj errores)
local function Hook(tbl, name, fn)
  if not hooksecurefunc then return end
  local function Safe(...)
    local ok, err = pcall(fn, ...)
    if not ok then
      Log("error en " .. name .. ": " .. tostring(err))
      if ES.RecordError then ES:RecordError("cuentas", name .. ": " .. tostring(err)) end
    end
  end
  if tbl then
    if type(tbl[name]) == "function" then hooksecurefunc(tbl, name, Safe) end
  elseif type(_G[name]) == "function" then
    hooksecurefunc(name, Safe)
  end
end
Books.Hook = Hook -- para pruebas

do
  Hook(C_AuctionHouse, "StartCommoditiesPurchase", H.StartCommoditiesPurchase)
  Hook(C_AuctionHouse, "ConfirmCommoditiesPurchase", H.ConfirmCommoditiesPurchase)
  Hook(C_AuctionHouse, "PlaceBid", H.PlaceBid)
  Hook(C_AuctionHouse, "PostItem", H.PostItem)
  Hook(C_AuctionHouse, "PostCommodity", H.PostCommodity)
  Hook(nil, "PlaceAuctionBid", H.PlaceAuctionBid)
  Hook(nil, "PostAuction", H.PostAuction)
  Hook(nil, "BuyMerchantItem", H.BuyMerchantItem)
  Hook(nil, "BuybackItem", H.BuybackItem)
  Hook(nil, "RepairAllItems", H.RepairAllItems)
  Hook(nil, "BuyTrainerService", H.BuyTrainerService)
  Hook(nil, "TakeInboxMoney", H.TakeInboxMoney)
  Hook(nil, "TakeInboxItem", H.TakeInboxItem)
  Hook(nil, "AutoLootMailItem", H.AutoLootMailItem)

  local f = CreateFrame("Frame")
  for _, e in ipairs({ "PLAYER_ENTERING_WORLD", "PLAYER_MONEY", "PLAYER_LOGOUT", "CHAT_MSG_SYSTEM", "UI_INFO_MESSAGE",
    "TRADE_ACCEPT_UPDATE", "TRADE_MONEY_CHANGED", "TRADE_PLAYER_ITEM_CHANGED", "TRADE_TARGET_ITEM_CHANGED",
    "COMMODITY_PRICE_UPDATED", "MAIL_INBOX_UPDATE" }) do
    ES.SafeRegister(f, e)
  end
  f:SetScript("OnEvent", function(_, event, a1, a2)
    if not ES.db then return end
    local ok, err = pcall(function()
      if event == "PLAYER_ENTERING_WORLD" then
        if lastMoney == nil then Books.Start() end
      elseif event == "PLAYER_MONEY" then
        Books.OnMoney()
      elseif event == "PLAYER_LOGOUT" then
        local b = Books.Data()
        if b then b.lastMoney = Money() end
      elseif event == "CHAT_MSG_SYSTEM" then
        Books.OnSystemMessage(a1)
      elseif event == "UI_INFO_MESSAGE" then
        -- (moderno: tipo, texto; clásico: texto)
        local msg = type(a2) == "string" and a2 or a1
        if ERR_TRADE_COMPLETE and msg == ERR_TRADE_COMPLETE then H.TradeComplete() end
      elseif event == "COMMODITY_PRICE_UPDATED" then
        H.CommodityPrice(a1, a2)
      elseif event == "MAIL_INBOX_UPDATE" then
        for k in pairs(seenMail) do seenMail[k] = nil end
      else
        H.TradeSnapshot()
      end
    end)
    if not ok then
      Log("error en " .. event .. ": " .. tostring(err))
      if ES.RecordError then ES:RecordError("cuentas", event .. ": " .. tostring(err)) end
    end
  end)
end

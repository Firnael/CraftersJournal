local _, ES = ...
local L = ES.L

-- Pestaña "Flipping": comprar barato en la AH para revender. Con los escaneos
-- guardados (History.lua, Market.lua) se buscan dos cosas:
--   por debajo del vendedor: subastas más baratas de lo que paga el vendedor
--     (beneficio seguro: el vendedor siempre compra)
--   han bajado: el mínimo de ahora, un % o más (lo eliges: 5, 10, 25 o 50) por
--     debajo de su referencia de los últimos días (con al menos MIN_DAYS días de
--     historial). Se revende a esa referencia, menos la comisión y el depósito.
--     Cuántas comprar según las alertas de mercado: hasta una pila si va "bien",
--     unas pocas si es dudoso, ninguna si dice "evitar".
-- Se ve como una tabla: el precio de ahora y el más bajo de cada uno de los últimos días.
-- En pruebas (solo en desarrollo): depende de escanear a menudo.

local Flipping = {}
ES.Flipping = Flipping

local GREEN, GREY, ORANGE, GOLD = "|cff40ff40", "|cff999999", "|cffff9933", "|cffffd100"
local DROPS = { 0.05, 0.10, 0.25, 0.50 } -- bajada mínima que se puede elegir
local DEFAULT_DROP = 0.10
local MIN_DAYS = 2         -- días de historial para fiarse de la referencia
local MIN_UNIT_PROFIT = 10 -- cobre por unidad como mínimo
local MIN_ROI = 0.05       -- y un 5% sobre lo que pagas
local FEW = 5              -- con alertas dudosas, como mucho estas
local MAX_UNITS = 20       -- y como mucho estas (una pila): revender cientos no es realista
local MAX_SHOWN = 60
local FRESH = 60 * 60      -- con precios más viejos que esto, avisar
local DAYS = 5             -- columnas de días: hoy, ayer, hace 2, 3 y 4 días
local TIP_DAYS = 7         -- en el tooltip, toda la semana del historial
local ROW_HEIGHT = 22
local date = date or os.date

local function Ladder(entry)
  if entry.ladder and #entry.ladder > 0 then return entry.ladder end
  if entry.minUnit then return { entry.minUnit, entry.quantity or 1 } end
end

-- Unidades de la escalera por debajo de `limit` (precio por unidad), las más baratas
-- primero y como mucho `max`: cuántas y cuánto cuestan
local function Below(ladder, limit, max)
  local units, cost = 0, 0
  for i = 1, #ladder, 2 do
    local price = ladder[i]
    local q = math.min(ladder[i + 1], max - units)
    if price >= limit or q <= 0 then break end
    units, cost = units + q, cost + price * q
  end
  return units, cost
end

-- El precio más bajo de cada día (días del calendario de tu PC): [1] hoy, [2] ayer…
function Flipping.DailyMins(itemID, days)
  local now, slot, mins = time(), {}, {}
  for k = 1, days do slot[date("%Y-%m-%d", now - (k - 1) * 86400)] = k end
  for _, p in ipairs(ES.Market:Index().points[itemID] or {}) do
    local k = slot[date("%Y-%m-%d", p.time)]
    if k and (not mins[k] or p.min < mins[k]) then mins[k] = p.min end
  end
  return mins
end

-- Oportunidades con una bajada mínima `minDrop` (0.25 = un 25%):
-- { itemID, kind ("vendor" | "drop"), units, cost, unitSell, profit, roi,
--   current, ref, drop, days, verdict, vendor }
function Flipping:List(minDrop)
  minDrop = minDrop or DEFAULT_DROP
  local scan = ES.db.scans and ES.db.scans[ES:RealmKey()]
  local list = {}
  if not scan then return list, nil end
  for id, entry in pairs(scan.items) do
    local ladder = entry.minUnit and Ladder(entry)
    if ladder then
      local vendor = ES:VendorSellPrice(id) or 0
      local opp
      -- 1. Por debajo de lo que paga el vendedor
      if vendor > 0 and entry.minUnit < vendor then
        local units, cost = Below(ladder, vendor, MAX_UNITS)
        if units > 0 and vendor * units - cost >= MIN_UNIT_PROFIT then
          opp = { kind = "vendor", units = units, cost = cost, unitSell = vendor, profit = vendor * units - cost }
        end
      end
      -- 2. Ha bajado respecto a su precio de los últimos días
      local ref, days = ES.Market:ReferencePrice(id)
      if not opp and ref and days and days >= MIN_DAYS and entry.minUnit <= ref * (1 - minDrop) then
        local verdict = ES.Market:Signals(id).verdict
        if verdict ~= "avoid" then
          local deposit, cut = ES.Planner.AuctionCosts(vendor, { hours = 24, neutral = ES:IsNeutralAH() })
          local sell = math.floor(ref * (1 - cut) - deposit)
          -- (la bajada elegida solo decide si sale; se compran las que dejan beneficio)
          local units, cost = Below(ladder, sell - MIN_UNIT_PROFIT + 1, verdict == "good" and MAX_UNITS or FEW)
          local profit = sell * units - cost
          if units > 0 and profit >= MIN_UNIT_PROFIT * units and profit >= MIN_ROI * cost then
            opp = { kind = "drop", units = units, cost = cost, unitSell = sell, profit = profit, verdict = verdict }
          end
        end
      end
      if opp then
        opp.itemID, opp.current, opp.ref, opp.days, opp.vendor = id, entry.minUnit, ref, days, vendor
        opp.drop = ref and (1 - entry.minUnit / ref) or nil
        opp.roi = opp.cost > 0 and opp.profit / opp.cost or 0
        list[#list + 1] = opp
      end
    end
  end
  table.sort(list, function(a, b) return a.profit > b.profit or (a.profit == b.profit and a.itemID < b.itemID) end)
  return list, scan.time
end

---------------------------------------------------------------------------
-- Página
---------------------------------------------------------------------------
-- Icono de dos flechas (⇄) sobre un fondo oscuro: la flecha de "siguiente" y la de
-- "anterior" del libro de hechizos. Lo usan la pestaña lateral y la cabecera
function ES.UI.FlipIcon(tex)
  tex:SetColorTexture(0.12, 0.09, 0.05, 1)
  local parent = tex:GetParent()
  local w = tex:GetWidth() > 0 and tex:GetWidth() or 44
  local function Arrow(file, x, y)
    local a = parent:CreateTexture(nil, "OVERLAY")
    a:SetTexture(file)
    a:SetSize(w * 0.62, w * 0.62)
    a:SetPoint("CENTER", tex, "CENTER", x * w, y * w)
    return a
  end
  return Arrow("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", 0.12, 0.17),
    Arrow("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", -0.12, -0.17)
end

-- Dinero corto para las columnas: 1g 59s · 59s 96c · 123g
local function Short(c)
  if not c then return GREY .. "—|r" end
  c = math.floor(c + 0.5)
  local g, s, cp = math.floor(c / 10000), math.floor(c / 100) % 100, c % 100
  if g >= 100 then return string.format("%d|cffffd100g|r", g) end
  if g > 0 then return s > 0 and string.format("%d|cffffd100g|r %d|cffc7c7cfs|r", g, s) or string.format("%d|cffffd100g|r", g) end
  if s > 0 then return cp > 0 and string.format("%d|cffc7c7cfs|r %d|cffeda55fc|r", s, cp) or string.format("%d|cffc7c7cfs|r", s) end
  return string.format("%d|cffeda55fc|r", cp)
end
Flipping.Short = Short

local function DayTitle(k)
  if k == 1 then return L["Hoy"] elseif k == 2 then return L["Ayer"] end
  return string.format(L["Hace %d d"], k - 1)
end

local function Columns()
  local cols = {
    { key = "name", title = L["Objeto"], width = 196, justify = "LEFT" },
    { key = "now",  title = L["Ahora"],  width = 70 },
  }
  for k = 1, DAYS do cols[#cols + 1] = { key = "d" .. k, title = DayTitle(k), width = 62 } end
  cols[#cols + 1] = { key = "change", title = L["Cambio"], width = 52 }
  cols[#cols + 1] = { key = "profit", title = L["Ganas"],  width = 80 }
  return cols
end

local function ItemLabel(itemID) return ES.UI.ItemLabel(itemID, L["Objeto "] .. itemID) end

local function Tooltip(o, mins)
  return function(row)
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    if GameTooltip.SetItemByID then GameTooltip:SetItemByID(o.itemID) else GameTooltip:AddLine((ItemLabel(o.itemID))) end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(string.format(L["Compras %d a %s/u"], o.units, ES.Money(math.floor(o.cost / o.units + 0.5))),
      ES.Money(o.cost), 1, 0.82, 0, 1, 1, 1)
    if o.kind == "vendor" then
      GameTooltip:AddDoubleLine(string.format(L["Las vendes al vendedor a %s/u"], ES.Money(o.unitSell)), ES.Money(o.unitSell * o.units),
        1, 0.82, 0, 1, 1, 1)
      GameTooltip:AddLine(L["Beneficio seguro: el vendedor siempre compra."], 0.4, 1, 0.4, true)
    else
      GameTooltip:AddDoubleLine(string.format(L["Las revendes a ~%s/u"], ES.Money(o.ref)), ES.Money(o.unitSell * o.units), 1, 0.82, 0, 1, 1, 1)
      GameTooltip:AddLine(string.format(L["Precio de los últimos %d días: ~%s. Ahora la más barata está a %s (-%d%%)."],
        o.days, ES.Money(o.ref), ES.Money(o.current), math.floor(o.drop * 100 + 0.5)), 0.8, 0.8, 0.8, true)
      GameTooltip:AddLine(L["(lo que te queda tras la comisión del 5% y el depósito)"], 0.6, 0.6, 0.6)
      if o.verdict ~= "good" then
        GameTooltip:AddLine(L["Alertas de mercado dudosas: solo unas pocas, para probar."], 1, 0.6, 0.2, true)
      end
    end
    GameTooltip:AddDoubleLine(L["Beneficio"], GREEN .. "+" .. ES.Money(o.profit) .. "|r", 1, 0.82, 0, 1, 1, 1)
    -- Toda la semana: el más bajo de cada día
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["El más barato de cada día:"], 1, 0.82, 0)
    for k = 1, TIP_DAYS do
      if mins[k] then GameTooltip:AddDoubleLine(DayTitle(k), ES.Money(mins[k]), 0.8, 0.8, 0.8, 1, 1, 1) end
    end
    if o.kind == "drop" then ES.Market.AddToTooltip(o.itemID) end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(ES:IsAuctionHouseOpen() and L["Clic: buscarlo en la Casa de Subastas."]
      or L["Abre la Casa de Subastas para buscarlo desde aquí."], 0.5, 0.8, 1, true)
    GameTooltip:Show()
  end
end

-- Fila de la tabla: cabecera, título de sección u objeto
local function CreateRow(page, i)
  local row = CreateFrame("Button", nil, page.content)
  row:SetHeight(ROW_HEIGHT)
  row.bg = row:CreateTexture(nil, "BACKGROUND")
  row.bg:SetAllPoints()
  row.bg:SetColorTexture(1, 1, 1, 0.04)
  local hl = row:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints()
  hl:SetColorTexture(0.2, 0.6, 1, 0.15)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(18, 18)
  row.icon:SetPoint("LEFT", 4, 0)
  row.section = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.section:SetPoint("LEFT", 4, 0)
  row.cells = {}
  local x = 26
  for c, col in ipairs(page.columns) do
    local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    local w = (c == 1) and (col.width - 26) or col.width
    fs:SetSize(w, ROW_HEIGHT)
    fs:SetPoint("LEFT", x, 0)
    fs:SetJustifyH(col.justify or "RIGHT")
    fs:SetWordWrap(false)
    row.cells[col.key] = fs
    x = x + w + 4
  end
  row:SetScript("OnEnter", function(self) if self.tooltip then self.tooltip(self) end end)
  row:SetScript("OnLeave", function() GameTooltip:Hide() end)
  row:SetScript("OnClick", function(self) if self.onClick then self.onClick() end end)
  return row
end

local function FillRow(page, row, line)
  row.tooltip, row.onClick = line.tooltip, line.onClick
  row.section:SetText(line.section or "")
  row.icon:SetShown(line.icon ~= nil)
  if line.icon then row.icon:SetTexture(line.icon) end
  row.bg:SetShown(line.alt == true)
  for _, col in ipairs(page.columns) do
    local fs = row.cells[col.key]
    fs:SetFontObject(line.header and "GameFontNormalSmall" or "GameFontHighlightSmall")
    fs:SetText(line.cells and line.cells[col.key] or "")
  end
end

local function ItemLine(page, o, alt)
  local name, texture, pending = ItemLabel(o.itemID)
  if pending then page.pendingItems = true end
  local mins = Flipping.DailyMins(o.itemID, TIP_DAYS)
  local cells = {
    name = string.format("%d× %s", o.units, name or ("#" .. o.itemID)),
    now = GREEN .. Short(o.current) .. "|r",
    change = o.drop and o.drop > 0 and string.format("%s-%d%%|r", GREEN, math.floor(o.drop * 100 + 0.5))
      or (o.drop and string.format("%s+%d%%|r", GREY, math.floor(-o.drop * 100 + 0.5))) or (GREY .. "—|r"),
    profit = GREEN .. "+" .. Short(o.profit) .. "|r",
  }
  for k = 1, DAYS do cells["d" .. k] = Short(mins[k]) end
  return {
    icon = texture or 134400, cells = cells, alt = alt, tooltip = Tooltip(o, mins),
    onClick = function()
      if not ES:IsAuctionHouseOpen() then return end
      if ES.OpenAuctionBuy then ES:OpenAuctionBuy(o.itemID, o.units, o.unitSell - 1) else ES:SearchAuction(o.itemID) end
    end,
  }
end

function ES:CreateFlippingPage(page)
  ES.UI.ListPage(page, L["Flipping"], nil, {
    { key = "count",  label = L["Oportunidades"] },
    { key = "invest", label = L["Inviertes"] },
    { key = "profit", label = L["Beneficio posible"] },
  })
  ES.UI.FlipIcon(page.icon)
  page.subtitle:SetText(L["Objetos de la AH que han bajado de precio o están por debajo del vendedor: cómpralos y revéndelos."])
  page.columns = Columns()
  page.rows = {}
  -- Bajada mínima: 5% · 10% · 25% · 50%
  page.dropButtons = {}
  local prev
  for i = #DROPS, 1, -1 do
    local value = DROPS[i]
    local b = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    b:SetSize(46, 20)
    b:SetText(string.format("%d%%", value * 100))
    if prev then b:SetPoint("RIGHT", prev, "LEFT", -4, 0) else b:SetPoint("TOPRIGHT", -14, -78) end
    b.value = value
    b:SetScript("OnClick", function()
      ES.db.flipDrop = value
      ES:RenderFlipping()
    end)
    page.dropButtons[#page.dropButtons + 1] = b
    prev = b
  end
  local dropLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  dropLabel:SetPoint("RIGHT", prev, "LEFT", -8, 0)
  dropLabel:SetText(L["Bajada mínima:"])

  page.Render = function() ES:RenderFlipping() end
  page:SetScript("OnShow", page.Render)
  -- Abres o cierras la AH: el clic busca o no (los escaneos repintan con ES:RefreshAllViews)
  local f = CreateFrame("Frame")
  ES.SafeRegister(f, "AUCTION_HOUSE_SHOW")
  ES.SafeRegister(f, "AUCTION_HOUSE_CLOSED")
  f:SetScript("OnEvent", function() if page:IsVisible() then ES:RenderFlipping() end end)
  self.flippingPage = page
end

function ES:RenderFlipping()
  local page = self.flippingPage
  if not page or not page:IsVisible() then return end
  local drop = ES.db.flipDrop or DEFAULT_DROP
  for _, b in ipairs(page.dropButtons) do
    if b.value == drop then b:LockHighlight() else b:UnlockHighlight() end
  end
  local list, scanTime = Flipping:List(drop)
  local Signed = ES.UI.Signed
  local safe, drops = {}, {}
  local invest, profit = 0, 0
  for i, o in ipairs(list) do
    if i > MAX_SHOWN then break end
    if o.kind == "vendor" then safe[#safe + 1] = o else drops[#drops + 1] = o end
    invest, profit = invest + o.cost, profit + o.profit
  end
  page.stats.count:SetText(tostring(#safe + #drops))
  page.stats.invest:SetText(invest > 0 and Signed(invest) or (GREY .. "—|r"))
  page.stats.profit:SetText(profit > 0 and Signed(-profit) or (GREY .. "—|r"))
  if not scanTime then
    page.status:SetText(ORANGE .. L["Sin escaneo de la AH: escanea para buscar oportunidades.|r"])
  elseif time() - scanTime > FRESH then
    page.status:SetText(ORANGE .. string.format(L["Precios de hace %d min: las gangas vuelan, escanea antes de comprar.|r"],
      math.floor((time() - scanTime) / 60)))
  else
    page.status:SetText(GREY .. string.format(L["Precios de hace %d min · reventa tras comisión y depósito|r"],
      math.floor((time() - scanTime) / 60)))
  end

  page.pendingItems = false
  local lines = {}
  if #safe + #drops > 0 then
    local header = { header = true, cells = {} }
    for _, col in ipairs(page.columns) do header.cells[col.key] = col.title end
    lines[1] = header
  end
  local function Section(title, items)
    if #items == 0 then return end
    lines[#lines + 1] = { section = title }
    for i, o in ipairs(items) do lines[#lines + 1] = ItemLine(page, o, i % 2 == 0) end
  end
  Section(L["Por debajo del vendedor (beneficio seguro)"], safe)
  Section(string.format(L["Han bajado un %d%% o más"], drop * 100), drops)

  local y = 0
  for i, line in ipairs(lines) do
    local row = page.rows[i] or CreateRow(page, i)
    page.rows[i] = row
    FillRow(page, row, line)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -y)
    row:SetPoint("RIGHT", page.content, "RIGHT", 0, 0)
    row:Show()
    y = y + ROW_HEIGHT + (line.section and 4 or 0)
  end
  for i = #lines + 1, #page.rows do page.rows[i]:Hide() end
  page.content:SetHeight(math.max(1, y))
  page.empty:SetText(#lines == 0 and (scanTime and L["Ninguna oportunidad con los precios del último escaneo."]
    or L["Escanea la AH para buscar oportunidades."]) or "")
end

local _, ES = ...
local L = ES.L

-- Página "Ganar dinero": qué fabricar hoy con las recetas que sabes (Earn.lua),
-- el lote recomendado y lo descartado
-- por las alertas de mercado.

local GREEN, GREY, ORANGE = "|cff40ff40", "|cff999999", "|cffff9933"
local MORE_IDEAS = 15 -- además del lote
local MAX_AVOIDED = 8

local function ItemLabel(itemID, fallback)
  return ES.UI.ItemLabel(itemID, fallback)
end

local function IdeaTooltip(idea)
  return function(row)
    local e = idea.e
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine((ItemLabel(e.itemID, e.recipe.name)))
    GameTooltip:AddLine(ES:ProfLabel(idea.profKey) .. " · " .. e.recipe.name, 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(e.qty > 1 and string.format(L["Materiales (1 fabricación = %s uds):"], ES.Num(e.qty)) or L["Materiales (1 fabricación):"], 1, 0.82, 0)
    for _, rg in ipairs(e.reagents or {}) do
      GameTooltip:AddDoubleLine(string.format("%dx %s", rg.qty, (ItemLabel(rg.item, L["Objeto "] .. rg.item))), ES.Money(rg.cost), 1, 1, 1, 1, 1, 1)
    end
    GameTooltip:AddLine(" ")
    local W = { 0.8, 0.8, 0.8, 1, 1, 1 }
    GameTooltip:AddDoubleLine(L["Coste por fabricación"], ES.Money(e.cost), unpack(W))
    if idea.sellWhere == "ah" then
      GameTooltip:AddDoubleLine(L["La más barata en la AH"], ES.Money(e.ahMin), unpack(W))
      ES.Market.AddFairToTooltip(e.fair)
      GameTooltip:AddDoubleLine(L["A la venta ahora"], string.format(L["%d subastas, %d uds"], e.listings, e.quantity), unpack(W))
      GameTooltip:AddDoubleLine(string.format(e.fair and e.fair.inflated and L["Te queda al precio de los últimos días (-%d%%, depósito)"]
        or L["Te queda igualando a la más barata (-%d%%, depósito)"], e.cut * 100), ES.Money(e.ahNet), unpack(W))
    else
      GameTooltip:AddDoubleLine(L["Vendedor te paga"], ES.Money(e.vendor), unpack(W))
    end
    GameTooltip:AddDoubleLine(L["Beneficio por fabricación"], GREEN .. "+" .. ES.Money(e.profit) .. "|r", unpack(W))
    if idea.crafts then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(string.format(L["Fabrica %d: %s"], idea.crafts, idea.why or ""), 1, 0.82, 0, true)
      if idea.why2 then GameTooltip:AddLine(idea.why2, 0.6, 1, 0.6, true) end
      if idea.fewer then GameTooltip:AddLine(L["Menos de las que caben: con más, los materiales salen más caros y ya no compensa."], 1, 0.6, 0.2, true) end
      if idea.crafts > 0 then
        GameTooltip:AddDoubleLine(L["Inviertes"], ES.Money(idea.invest), unpack(W))
        GameTooltip:AddDoubleLine(L["Beneficio si se venden todas"], GREEN .. "+" .. ES.Money(idea.profit) .. "|r", unpack(W))
      end
      if idea.sellWhere == "ah" then
        GameTooltip:AddLine(string.format(e.fair and e.fair.inflated and L["Anúncialos a %s (el precio de los últimos días, algo por encima)."]
          or L["Anúncialos a %s (1 cobre menos que la más barata)."], ES.Money(idea.price)), 0.8, 0.8, 0.8, true)
      end
    end
    if idea.sellWhere == "ah" then ES.Market.AddToTooltip(e.itemID) end
    GameTooltip:Show()
  end
end

local function IdeaLine(idea, dim)
  local e = idea.e
  local name, texture = ItemLabel(e.itemID, e.recipe.name)
  local where = idea.sellWhere == "ah"
    and (string.format(L["AH %s/u (%d a la venta) · %s"], ES.Money(e.ahPrice or e.ahMin), e.quantity, ES.Market.LABELS[idea.verdict])
      .. (e.fair and e.fair.inflated and (ORANGE .. L[" · ahora inflado"] .. "|r") or ""))
    or string.format(L["vendedor %s/u"], ES.Money(e.vendor))
  local sub = string.format(L["%s · coste %s/u · %s"], ES:ProfLabel(idea.profKey), ES.Money(e.cost), where)
  if dim then
    return { icon = texture or 134400, title = GREY .. (name or e.recipe.name) .. "|r", sub = sub,
      value = GREY .. "+" .. ES.Money(e.profit) .. "/u|r", item = e.itemID, tooltip = IdeaTooltip(idea) }
  end
  if idea.crafts == 0 then
    -- Ya tienes las que tocan: no hay que fabricar, solo anunciarlas
    return { icon = texture or 134400, title = string.format(L["Ya tienes %d× %s"], idea.have, name or e.recipe.name),
      sub = sub, value = GREEN .. L["anúncialas"] .. "|r", item = e.itemID, tooltip = IdeaTooltip(idea) }
  end
  return { icon = texture or 134400, title = string.format("%d× %s", idea.crafts, name or e.recipe.name), sub = sub,
    value = ES.UI.Signed(-idea.profit), item = e.itemID, tooltip = IdeaTooltip(idea) }
end

function ES:CreateEarnPage(page)
  local Panel, Label = ES.UI.Panel, ES.UI.Label
  local head = Panel(page)
  head:SetPoint("TOPLEFT", 10, -2)
  head:SetPoint("TOPRIGHT", -10, -2)
  head:SetHeight(66)
  local icon = head:CreateTexture(nil, "ARTWORK")
  icon:SetSize(44, 44)
  icon:SetPoint("LEFT", 12, 0)
  icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_02")
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  local name = Label(head, L["Ganar dinero"], "GameFontNormalHuge")
  name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, 2)
  name:SetTextColor(0.96, 0.79, 0.25)
  page.subtitle = Label(head, "", "GameFontHighlightSmall")
  page.subtitle:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 12, 2)
  page.subtitle:SetPoint("RIGHT", -16, 0)
  page.subtitle:SetJustifyH("LEFT")

  local strip = CreateFrame("Frame", nil, page)
  strip:SetPoint("TOPLEFT", head, "BOTTOMLEFT", 4, -6)
  strip:SetPoint("TOPRIGHT", head, "BOTTOMRIGHT", -4, -6)
  strip:SetHeight(46)
  page.stats = {}
  local STATS = {
    { key = "invest", label = L["Inviertes en materiales"] },
    { key = "profit", label = L["Beneficio si se vende todo"] },
    { key = "count",  label = L["Recetas en el lote"] },
  }
  for i, s in ipairs(STATS) do
    local label = Label(strip, s.label, "GameFontDisableSmall")
    label:SetPoint("TOPLEFT", (i - 1) * 196 + 6, -2)
    local value = Label(strip, "", "GameFontHighlightLarge")
    value:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -3)
    page.stats[s.key] = value
  end
  page.status = Label(page, "", "GameFontHighlightSmall")
  page.status:SetPoint("TOPLEFT", strip, "BOTTOMLEFT", 2, -2)
  page.status:SetPoint("RIGHT", strip, "RIGHT", 0, 0)
  page.status:SetJustifyH("LEFT")
  page.status:SetWordWrap(false)

  local list = Panel(page, 0.07, 0.05, 0.03, 0.9)
  list:SetPoint("TOPLEFT", head, "BOTTOMLEFT", 0, -70)
  list:SetPoint("BOTTOMRIGHT", -10, 4)
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

  ES.SafeRegister(page, "GET_ITEM_INFO_RECEIVED")
  page:SetScript("OnEvent", function(self)
    if self.pendingItems and not self.refreshQueued then
      self.refreshQueued = true
      C_Timer.After(0.5, function()
        self.refreshQueued = false
        if self:IsVisible() then ES:RenderEarn() end
      end)
    end
  end)
  page:SetScript("OnShow", function()
    ES.db.lastProf = "money" -- la lista de compra de la AH empieza por el lote
    ES:RenderEarn()
  end)
  self.earnPage = page
end

function ES:RenderEarn()
  local page = self.earnPage
  if not page or not page:IsVisible() then return end
  local res = ES.Earn:Ideas()
  local Signed = ES.UI.Signed

  page.stats.invest:SetText(#res.batch > 0 and Signed(res.invest) or (GREY .. "—|r"))
  page.stats.profit:SetText(#res.batch > 0 and Signed(-res.profit) or (GREY .. "—|r"))
  page.stats.count:SetText(tostring(#res.batch))

  local profs = {}
  for _, k in ipairs(res.profs) do profs[#profs + 1] = ES:ProfLabel(k) end
  page.subtitle:SetText(#profs > 0 and string.format(L["Con las %d recetas que sabes de %s."], res.known, table.concat(profs, ", "))
    or L["Este personaje no tiene profesiones de fabricación."])

  local status
  if not res.scanTime then
    status = ORANGE .. L["Sin escaneo de la AH: escanea para ver qué da beneficio.|r"]
  elseif time() - res.scanTime > ES.Earn.OLD_SCAN then
    status = ORANGE .. string.format(L["Precios de hace %d h: escanea antes de fabricar.|r"], math.floor((time() - res.scanTime) / 3600))
  else
    status = GREY .. string.format(L["Precios de la AH de hace %d min · beneficio igualando a la más barata (comisión y depósito descontados)|r"],
      math.floor((time() - res.scanTime) / 60))
  end
  page.status:SetText(status)

  local lines = {}
  if #res.batch > 0 then
    lines[#lines + 1] = { section = L["Lote de hoy"] }
    for _, idea in ipairs(res.batch) do lines[#lines + 1] = IdeaLine(idea) end
    lines[#lines + 1] = { total = true, title = L["Total del lote"],
      sub = L["En la Casa de Subastas, el panel Crafter's Journal busca estos materiales (modo Ganar dinero)."],
      value = Signed(-res.profit) }
  end
  if #res.ideas > #res.batch then
    lines[#lines + 1] = { section = L["Más opciones con beneficio"] }
    for i = #res.batch + 1, math.min(#res.ideas, #res.batch + MORE_IDEAS) do lines[#lines + 1] = IdeaLine(res.ideas[i]) end
  end
  -- Enfriamientos (transmutaciones...) que sabes
  local cds = ES.Earn:Cooldowns()
  if #cds > 0 then
    lines[#lines + 1] = { section = L["Enfriamientos"] }
    for _, c in ipairs(cds) do
      local name, texture = ItemLabel(c.recipe.out and c.recipe.out[1] or 0, c.recipe.name)
      lines[#lines + 1] = { icon = texture or 134400, title = name or c.recipe.name,
        sub = c.ready and (GREEN .. L["Listo: fabrícalo hoy"] .. "|r")
          or string.format(L["Listo en %d h"], math.ceil(c.left / 3600)),
        value = c.profit and (c.profit > 0 and Signed(-c.profit) or (GREY .. L["sin beneficio ahora|r"])) or "",
        item = c.recipe.out and c.recipe.out[1] }
    end
  end
  if #res.avoided > 0 then
    lines[#lines + 1] = { section = L["Con beneficio pero las alertas dicen evitar"] }
    for i = 1, math.min(#res.avoided, MAX_AVOIDED) do lines[#lines + 1] = IdeaLine(res.avoided[i], true) end
  end
  -- Materiales que llevas y no usa ninguna receta que sabes: para vender
  local left = ES.Earn:Leftovers()
  if #left > 0 then
    lines[#lines + 1] = { section = L["Materiales que llevas y no usas (para vender)"] }
    for i = 1, math.min(#left, 10) do
      local it = left[i]
      local name, texture = ItemLabel(it.itemID, L["Objeto "] .. it.itemID)
      local where = it.ahPrice and it.ahPrice * 0.95 > it.vendor
        and (string.format(L["AH %s/u"], ES.Money(it.ahPrice)) .. (it.fair and it.fair.inflated and (ORANGE .. L[" · ahora inflado"] .. "|r") or ""))
        or string.format(L["vendedor %s/u"], ES.Money(it.vendor))
      lines[#lines + 1] = { icon = texture or 134400, title = it.count .. "× " .. (name or ""), sub = where,
        value = ES.UI.Signed(-it.value), item = it.itemID,
        onClick = ES.ahOpen and function() ES:SearchAuction(it.itemID) end or nil }
    end
  end
  page.empty:SetText(#lines == 0 and (#res.profs == 0 and L["Aprende una profesión de fabricación para ver ideas."]
    or not res.scanTime and L["Escanea la AH para ver qué da beneficio."]
    or L["Ninguna receta que sabes da beneficio con los precios actuales."]) or "")
  ES.UI.RenderLines(page, lines)
end

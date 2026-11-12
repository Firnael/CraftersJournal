local _, ES = ...
local L = ES.L

-- Portada del panel: una tarjeta por profesión (dos por fila) con su imagen de
-- fondo, lo que cuesta subirla desde tu nivel hasta el máximo y tu nivel
-- actual. Tus profesiones salen primero.

-- Planes de las tarjetas ya calculados (ver ProfessionEntries)
ES.homePlanCache = {}
function ES:ClearHomeCache()
  self.homePlanCache = {}
  self.planGen = (self.planGen or 0) + 1 -- descarta las rutas que se estén calculando
end
-- Cuándo se rehace una ruta (solo la de esa profesión; se calcula cuando se ve):
--   cambian tus bolsas: solo las que usan lo de las bolsas y no tienen la ruta fijada
--   aprendes una receta: solo la profesión cuyas recetas sabidas cambiaron (el
--     instructor lanza TRAINER_UPDATE al mirar, sin aprender nada)
--   subes de nivel: nada que borrar (el nivel va en la clave de la caché)
--   escaneo nuevo: todas las no fijadas (su hora va en la clave; ES:RefreshAllViews)
-- Las fijadas no se rehacen nunca: tienen sus recetas y precios guardados.
local BAG_REFRESH_DELAY = 0.8 -- s sin cambios en las bolsas antes de repintar
local knownCount = {} -- [profesión] = recetas sabidas la última vez que se miró

local function KnownCount(profKey)
  local n = 0
  for id in pairs(ES.Data[profKey].recipes) do
    if ES:IsRecipeKnown(id) then n = n + 1 end
  end
  return n
end

-- Profesiones del personaje cuyas recetas sabidas cambiaron: su ruta se rehace
local function CheckLearned()
  local changed = false
  for _, prof in ipairs(ES.PROFESSIONS) do
    local data = ES.Data[prof.key]
    if data and data.recipes and ES:GetProfessionSkill(data.skillLine) then
      local n = KnownCount(prof.key)
      if knownCount[prof.key] and knownCount[prof.key] ~= n then
        ES:InvalidatePlan(prof.key)
        changed = true
      end
      knownCount[prof.key] = n
    end
  end
  return changed
end
ES.CheckLearned = CheckLearned -- para pruebas

do
  local f = CreateFrame("Frame")
  for _, event in ipairs({ "PLAYER_LOGIN", "BAG_UPDATE_DELAYED", "NEW_RECIPE_LEARNED", "LEARNED_SPELL_IN_TAB", "TRAINER_UPDATE" }) do
    ES.SafeRegister(f, event)
  end
  local bagStamp, learnStamp = 0, 0
  f:SetScript("OnEvent", function(_, event)
    if not ES.db then return end
    if event == "PLAYER_LOGIN" then
      CheckLearned() -- lo que ya sabes al entrar (punto de partida)
      return
    end
    -- Aprendes una receta (instructor, pergamino): la profesión abierta lo enseña
    -- al momento (la fila de aprender queda hecha; sin ruta fijada, se recalcula)
    if event ~= "BAG_UPDATE_DELAYED" then
      learnStamp = learnStamp + 1
      local stamp = learnStamp
      local function Check()
        return stamp == learnStamp and CheckLearned() and ES.RefreshAfterLearn and (ES:RefreshAfterLearn() or true)
      end
      C_Timer.After(0.3, function()
        -- (si el juego aún no la da por sabida, otra vez un poco después)
        if stamp == learnStamp and not Check() then C_Timer.After(2, Check) end
      end)
      return
    end
    -- Compras al vendedor, cosas sacadas del correo, fabricar...: la profesión
    -- abierta se actualiza (la lista de la compra dice cuántos tienes y cuántos
    -- faltan). Llegan en ráfagas (una por objeto): se espera a que paren
    for _, prof in ipairs(ES.PROFESSIONS) do
      local settings = ES.db.prof and ES.db.prof[prof.key]
      if settings and settings.useBags and not settings.lock then ES:InvalidatePlan(prof.key) end
    end
    if ES.RefreshAfterBags then
      bagStamp = bagStamp + 1
      local stamp = bagStamp
      C_Timer.After(BAG_REFRESH_DELAY, function()
        if stamp == bagStamp then ES:RefreshAfterBags() end
      end)
    end
  end)
end

local MIN_CARD_W, CARD_H, GAP = 383, 112, 12
local GREEN, RED, GREY, ORANGE, GOLD = "|cff40ff40", "|cffff4040", "|cff9d9d9d", "|cffff9933", "|cffffd100"
local BORDER = { 0.55, 0.45, 0.28 }
local BORDER_HOVER = { 1, 0.82, 0.25 }
local BORDER_ACTIVE = { 0.35, 0.85, 0.35 } -- profesión con una ruta en curso ("Empezar ruta")
local INSET = 4 -- borde de la tarjeta

-- Ilustraciones del libro de profesiones oficial de Forever (atlas del cliente).
-- Las de profesión principal miden 664x142 (el dibujo está a la derecha). Las
-- secundarias son verticales (225x275) y traen su propio marco: se ponen sobre
-- la genérica, a su tamaño, recortando solo la zona del dibujo (detail = u1,u2,v1,v2).
local WIDE_ASPECT = 664 / 142
local ART = {
  Alchemy        = { wide = "Profession-overview-Card-Alchemy" },
  Blacksmithing  = { wide = "Profession-overview-Card-Blacksmithing" },
  Enchanting     = { wide = "Profession-overview-Card-Enchanting" },
  Engineering    = { wide = "Profession-overview-Card-Engineering" },
  Leatherworking = { wide = "Profession-overview-Card-Leatherworking" },
  Tailoring      = { wide = "Profession-overview-Card-Tailoring" },
  Cooking        = { wide = "Profession-overview-Card", detail = "Profession-overview-card-generic-cooking", crop = { 0.08, 0.92, 0.30, 0.80 } },
  FirstAid       = { wide = "Profession-overview-Card", detail = "Profession-overview-card-generic-firstaid", crop = { 0.08, 0.92, 0.36, 0.86 } },
}
local DETAIL_SIZE = { 225, 275 }

-- Color de cada profesión (las ilustraciones de Forever son marrones y apagadas):
-- tint = tono de la ilustración; glow = resplandor que se suma desde la izquierda
local COLORS = {
  Alchemy        = { tint = { 0.70, 1.00, 0.70 }, glow = { 0.15, 0.55, 0.20 } },
  Blacksmithing  = { tint = { 1.00, 0.75, 0.55 }, glow = { 0.75, 0.30, 0.08 } },
  Enchanting     = { tint = { 0.88, 0.70, 1.00 }, glow = { 0.45, 0.20, 0.75 } },
  Engineering    = { tint = { 0.70, 0.88, 1.00 }, glow = { 0.12, 0.40, 0.70 } },
  Leatherworking = { tint = { 1.00, 0.88, 0.65 }, glow = { 0.60, 0.38, 0.12 } },
  Tailoring      = { tint = { 0.78, 0.80, 1.00 }, glow = { 0.28, 0.28, 0.72 } },
  Cooking        = { tint = { 1.00, 0.90, 0.60 }, glow = { 0.70, 0.45, 0.08 } },
  FirstAid       = { tint = { 1.00, 0.72, 0.72 }, glow = { 0.70, 0.12, 0.12 } },
}
local GLOW_ALPHA = 0.55 -- fuerza del resplandor a la izquierda (a la derecha, casi nada)

local function Atlas(name)
  local info = name and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name)
  if info and (info.file or info.filename) then return info end
end

-- Parte [u1,u2]x[v1,v2] (0-1) de un atlas
local function SetAtlasPart(tex, info, u1, u2, v1, v2)
  local l, r, t, b = info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord
  tex:SetTexture(info.file or info.filename)
  tex:SetTexCoord(l + (r - l) * u1, l + (r - l) * u2, t + (b - t) * v1, t + (b - t) * v2)
end

-- Fundido hacia la izquierda (transparente a la izquierda, opaco a la derecha)
local function FadeLeft(tex)
  if CreateColor and tex.SetGradient then
    tex:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0), CreateColor(1, 1, 1, 1))
  elseif tex.SetGradientAlpha then
    tex:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 0, 1, 1, 1, 1)
  end
end

-- Pone la ilustración de `key` en una tarjeta de w x h; sin atlas, el icono ampliado
local function SetCardArt(card, key, icon, w, h)
  local art = ART[key] or {}
  local iw, ih = w - 2 * INSET, h - 2 * INSET
  local aspect = iw / ih
  local wide = Atlas(art.wide)
  if wide then
    -- Llenar sin deformar: recortar a lo ancho (quedándose con la derecha) o a lo alto (centro)
    if aspect < WIDE_ASPECT then
      SetAtlasPart(card.art, wide, 1 - aspect / WIDE_ASPECT, 1, 0, 1)
    else
      local f = WIDE_ASPECT / aspect
      SetAtlasPart(card.art, wide, 0, 1, (1 - f) / 2, (1 + f) / 2)
    end
    card.art:SetVertexColor(1, 1, 1)
  else
    card.art:SetTexture(icon)
    card.art:SetTexCoord(0.08, 0.92, 0.365, 0.635)
    card.art:SetVertexColor(0.7, 0.7, 0.7)
  end

  -- Color de la profesión: tono de la ilustración y resplandor desde la izquierda
  local color = COLORS[key]
  if color then
    if wide then card.art:SetVertexColor(color.tint[1], color.tint[2], color.tint[3]) end
    local g = color.glow
    if CreateColor and card.glow.SetGradient then
      card.glow:SetGradient("HORIZONTAL", CreateColor(g[1], g[2], g[3], GLOW_ALPHA), CreateColor(g[1], g[2], g[3], 0.05))
    elseif card.glow.SetGradientAlpha then
      card.glow:SetGradientAlpha("HORIZONTAL", g[1], g[2], g[3], GLOW_ALPHA, g[1], g[2], g[3], 0.05)
    end
    card.glow:Show()
  else
    card.glow:Hide()
  end

  -- Dibujo de profesión secundaria a la derecha, a su tamaño (alto de la tarjeta)
  local detail = Atlas(art.detail)
  if detail then
    local c = art.crop
    local cropW, cropH = DETAIL_SIZE[1] * (c[2] - c[1]), DETAIL_SIZE[2] * (c[4] - c[3])
    card.detail:SetSize(ih * cropW / cropH, ih)
    SetAtlasPart(card.detail, detail, c[1], c[2], c[3], c[4])
    card.detail:SetVertexColor(1, 1, 1)
    FadeLeft(card.detail)
    card.detail:Show()
  else
    card.detail:Hide()
  end
end

-- Coste en oro con signo: rojo "-" si cuesta, verde "+" si se recupera
local function SignedCost(net)
  if net >= 0.5 then return RED .. "-" .. ES.Money(net) .. "|r" end
  if net <= -0.5 then return GREEN .. "+" .. ES.Money(-net) .. "|r" end
  return ES.Money(0)
end

local function CreateCard(parent)
  local card = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  card:SetSize(MIN_CARD_W, CARD_H)
  card:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  card:SetBackdropColor(0.06, 0.05, 0.04, 1)
  card:SetBackdropBorderColor(unpack(BORDER))

  -- Imagen de fondo: la ilustración de la profesión (ver SetCardArt)
  card.art = card:CreateTexture(nil, "BACKGROUND", nil, 1)
  card.art:SetPoint("TOPLEFT", INSET, -INSET)
  card.art:SetPoint("BOTTOMRIGHT", -INSET, INSET)
  card.detail = card:CreateTexture(nil, "BACKGROUND", nil, 2)
  card.detail:SetPoint("RIGHT", -INSET, 0)
  card.detail:Hide()
  -- Resplandor del color de la profesión, sumado encima de la ilustración (ver SetCardArt)
  card.glow = card:CreateTexture(nil, "BACKGROUND", nil, 3)
  card.glow:SetPoint("TOPLEFT", INSET, -INSET)
  card.glow:SetPoint("BOTTOMRIGHT", -INSET, INSET)
  card.glow:SetColorTexture(1, 1, 1, 1)
  card.glow:SetBlendMode("ADD")
  card.glow:Hide()

  -- Bandas oscuras suaves para que se lea el texto (arriba el nombre, abajo el nivel)
  card.top = card:CreateTexture(nil, "BORDER")
  card.top:SetPoint("TOPLEFT", 4, -4)
  card.top:SetPoint("TOPRIGHT", -4, -4)
  card.top:SetHeight(40)
  card.top:SetColorTexture(0, 0, 0, 0.35)
  card.bottom = card:CreateTexture(nil, "BORDER")
  card.bottom:SetPoint("BOTTOMLEFT", 4, 4)
  card.bottom:SetPoint("BOTTOMRIGHT", -4, 4)
  card.bottom:SetHeight(26)
  card.bottom:SetColorTexture(0, 0, 0, 0.45)

  card.icon = card:CreateTexture(nil, "ARTWORK")
  card.icon:SetSize(28, 28)
  card.icon:SetPoint("TOPLEFT", 12, -10)
  card.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

  card.name = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  card.name:SetPoint("LEFT", card.icon, "RIGHT", 10, 0)
  card.name:SetJustifyH("LEFT")

  card.cost = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  card.cost:SetPoint("TOPRIGHT", -14, -16)
  card.cost:SetJustifyH("RIGHT")

  -- Marca verde: profesión que tiene este personaje
  card.check = card:CreateTexture(nil, "OVERLAY")
  card.check:SetSize(20, 20)
  card.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  card.check:SetPoint("RIGHT", card.cost, "LEFT", -8, 0)

  card.level = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  card.level:SetPoint("BOTTOMLEFT", 14, 11)
  card.level:SetJustifyH("LEFT")

  card.note = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  card.note:SetPoint("BOTTOMRIGHT", -14, 12)
  card.note:SetJustifyH("RIGHT")

  local hl = card:CreateTexture(nil, "HIGHLIGHT")
  hl:SetPoint("TOPLEFT", 4, -4)
  hl:SetPoint("BOTTOMRIGHT", -4, 4)
  hl:SetColorTexture(1, 0.82, 0.25, 0.08)

  card:SetScript("OnEnter", function(self)
    self:SetBackdropBorderColor(unpack(BORDER_HOVER))
    if self.tooltip then self.tooltip(self) end
  end)
  card:SetScript("OnLeave", function(self)
    self:SetBackdropBorderColor(unpack(self.active and BORDER_ACTIVE or BORDER))
    GameTooltip:Hide()
  end)
  card:SetScript("OnClick", function(self)
    if self.onClick then self.onClick() else ES:SelectPage(self.key) end
  end)
  return card
end

-- Tarjetas compartidas con la pestaña de la colección (PatternsUI.lua)
ES.UI.CreateCard, ES.UI.SetCardArt = CreateCard, SetCardArt
ES.UI.CARD_MIN_W, ES.UI.CARD_H, ES.UI.CARD_GAP = MIN_CARD_W, CARD_H, GAP

-- Pinta las tarjetas `cards` ({ key, name, icon, learned, cost, level, note, tooltip, onClick, active })
-- en page.content (page.cards guarda los marcos) y las coloca. active: ruta en curso (borde verde)
function ES.UI.RenderCards(page, cards)
  for i, c in ipairs(cards) do
    local card = page.cards[i] or CreateCard(page.content)
    page.cards[i] = card
    card.key, card.tooltip, card.iconPath, card.onClick = c.key, c.tooltip, c.icon, c.onClick
    card.active = c.active
    card:SetBackdropBorderColor(unpack(c.active and BORDER_ACTIVE or BORDER))
    card.icon:SetTexture(c.icon)
    card.name:SetText(c.name)
    card.cost:SetText(c.cost)
    card.check:Hide() -- sin check: tus profesiones ya van primero
    card.level:SetText(c.level)
    card.note:SetText(c.note)
    card:Show()
  end
  for i = #cards + 1, #page.cards do page.cards[i]:Hide() end
  page.shownCards = #cards
  -- Las que tiene el personaje van primero (las dos listas se ordenan así)
  page.learnedCount = 0
  for _, c in ipairs(cards) do if c.learned then page.learnedCount = page.learnedCount + 1 end end
  ES.UI.LayoutCards(page)
end

-- Fila plegable "Otras profesiones (6)" entre las tuyas y las demás
local OTHERS_H = 28
local function OthersHeader(page)
  if page.othersHeader then return page.othersHeader end
  local h = CreateFrame("Button", nil, page.content, BackdropTemplateMixin and "BackdropTemplate" or nil)
  h:SetHeight(OTHERS_H)
  h:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 } })
  h:SetBackdropColor(unpack(ES.UI.BROWN.row))
  h:SetBackdropBorderColor(unpack(BORDER))
  h.arrow = h:CreateTexture(nil, "ARTWORK")
  h.arrow:SetSize(14, 14)
  h.arrow:SetPoint("LEFT", 10, 0)
  h.text = h:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  h.text:SetPoint("LEFT", h.arrow, "RIGHT", 6, 0)
  h:SetScript("OnClick", function()
    ES.db.othersCollapsed = not ES.UI.OthersCollapsed()
    ES.UI.LayoutCards(page)
  end)
  h:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(BORDER_HOVER)) end)
  h:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(BORDER)) end)
  page.othersHeader = h
  return h
end

-- Plegadas por defecto: tus profesiones primero y el resto a un clic (se recuerda)
function ES.UI.OthersCollapsed()
  return ES.db.othersCollapsed ~= false
end

-- Coloca las tarjetas (dos por fila) al ancho de la ventana; se llama también
-- al cambiar su tamaño. El recorte de la ilustración depende del tamaño.
-- Si el personaje tiene alguna profesión, las demás van tras "Otras profesiones".
function ES.UI.LayoutCards(page)
  if not page or not page.shownCards then return end
  local width = math.max(MIN_CARD_W * 2 + GAP, math.floor(page.scroll:GetWidth()))
  local cardW = math.floor((width - GAP) / 2)
  page.content:SetWidth(width)
  local learned = page.learnedCount or 0
  local others = page.shownCards - learned
  local split = learned > 0 and others > 0
  local collapsed = split and ES.UI.OthersCollapsed()
  local y = 0
  local function Place(first, last)
    for i = first, last do
      local card, k = page.cards[i], i - first
      card:SetSize(cardW, CARD_H)
      card:ClearAllPoints()
      card:SetPoint("TOPLEFT", (k % 2) * (cardW + GAP), -(y + math.floor(k / 2) * (CARD_H + GAP)))
      SetCardArt(card, card.key, card.iconPath, cardW, CARD_H)
      card:Show()
    end
    if last >= first then y = y + math.ceil((last - first + 1) / 2) * (CARD_H + GAP) end
  end
  if not split then
    Place(1, page.shownCards)
    if page.othersHeader then page.othersHeader:Hide() end
  else
    Place(1, learned)
    local h = OthersHeader(page)
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", 0, -y)
    h:SetWidth(width)
    h.text:SetText(string.format(L["Otras profesiones (%d)"], others))
    h.arrow:SetTexture(collapsed and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up")
    h:Show()
    y = y + OTHERS_H + GAP
    if collapsed then
      for i = learned + 1, page.shownCards do page.cards[i]:Hide() end
    else
      Place(learned + 1, page.shownCards)
    end
  end
  page.content:SetHeight(math.max(1, y))
end

-- Cabecera de las portadas (profesiones y colección): fondo agrupado, texto y línea
function ES.UI.CoverPage(page, text)
  page.group = ES.UI.GroupPanel(page)
  local subtitle = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  subtitle:SetPoint("TOPLEFT", 18, -12)
  subtitle:SetTextColor(0.75, 0.75, 0.75)
  subtitle:SetText(text)

  local line = page:CreateTexture(nil, "ARTWORK")
  line:SetPoint("TOPLEFT", 16, -30)
  line:SetPoint("TOPRIGHT", -16, -30)
  line:SetHeight(1)
  line:SetColorTexture(1, 0.82, 0, 0.25)

  local scroll = ES.UI.WheelScroll(page)
  scroll:SetPoint("TOPLEFT", 16, -40)
  scroll:SetPoint("BOTTOMRIGHT", -16, 16)
  return scroll
end

function ES:CreateHomePage(page)
  local scroll = ES.UI.CoverPage(page,
    string.format(L["Elige una profesión para ver cómo subirla y qué fabricar. Coste de subir desde tu nivel hasta %d."], ES.MAX_SKILL))
  page.content = CreateFrame("Frame", nil, scroll)
  page.content:SetSize(MIN_CARD_W * 2 + GAP, 1)
  scroll:SetScrollChild(page.content)
  page.scroll = scroll
  page.cards = {}
  self.homePage = page
end

-- Una entrada por profesión: nivel, si la tiene y el plan hasta el máximo
local function ProfessionEntries()
  local list = {}
  for order, prof in ipairs(ES.PROFESSIONS) do
    local data = ES.Data[prof.key]
    if data then
      local rank, cap = ES:GetProfessionSkill(data.skillLine)
      -- Mismo objetivo que el detalle de la profesión, para que el coste coincida
      local e = { key = prof.key, prof = prof, order = order, rank = rank, learned = rank ~= nil, from = rank or 1,
        target = ES:ProfessionTarget(prof.key) }
      e.cap = rank and cap or nil
      list[#list + 1] = e
    end
  end
  -- Las tuyas primero; en cada sección, el orden fijo (el mismo que en Patterns)
  ES.SortProfessionCards(list)
  -- Rutas: de la caché, o repartidas entre fotogramas (la tarjeta pone
  -- "Calculando…" y se repinta al acabar). Solo las profesiones que tienes: las
  -- demás (de 1 a 300, las más caras de calcular) se calculan al abrirlas, y la
  -- tarjeta enseña esa ruta si sigue valiendo
  for _, e in ipairs(list) do
    if e.from < e.target then
      if e.learned then
        e.plan = ES:RequestPlan(e.key, e.from, e.target, e.cap, function() ES:RenderHome() end, "home")
        e.pending = not e.plan
      else
        e.plan = ES:CachedPlan(e.key, e.from, e.target, e.cap)
      end
    end
  end
  return list
end

local function ProfessionTooltip(e)
  return function(card)
    GameTooltip:SetOwner(card, "ANCHOR_RIGHT")
    GameTooltip:AddLine(ES:ProfLabel(e.key))
    GameTooltip:AddLine(e.learned and string.format(L["Tu nivel: %d · objetivo %d"], e.rank, e.target)
      or string.format(L["Este personaje no la tiene: el plan va de 1 a %d."], e.target), 0.8, 0.8, 0.8)
    if e.target < ES.MAX_SKILL then
      GameTooltip:AddLine(string.format(L["El objetivo se cambia dentro de la profesión (máximo %d)."], ES.MAX_SKILL), 0.6, 0.6, 0.6, true)
    end
    local plan = e.plan
    local lock = ES:RouteLock(e.key)
    if lock and plan then
      GameTooltip:AddLine(string.format(L["Ruta en curso (de %d a %d): lo que compras no cambia la ruta ni su coste"], lock.from, lock.to),
        0.4, 1, 0.4, true)
    end
    if plan then
      local W = { 0.8, 0.8, 0.8, 1, 1, 1 }
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(string.format(L["Subir de %d a %d:"], e.from, plan.reached), 1, 0.82, 0)
      GameTooltip:AddDoubleLine(L["Materiales"], ES.Money(plan.reagentCost), unpack(W))
      GameTooltip:AddDoubleLine(L["Recuperas vendiendo (al vendedor)"], ES.Money(plan.resale), unpack(W))
      GameTooltip:AddDoubleLine(L["Instructor"], ES.Money(plan.fees), unpack(W))
      if plan.toolsCost > 0 then GameTooltip:AddDoubleLine(L["Herramientas"], ES.Money(plan.toolsCost), unpack(W)) end
      GameTooltip:AddDoubleLine(L["Total"], SignedCost(plan.net), 1, 0.82, 0, 1, 1, 1)
      if plan.stoppedAt then
        GameTooltip:AddLine(string.format(L["Con recetas de instructor el plan llega hasta %d."], plan.reached), 1, 0.6, 0.2, true)
      end
      if not plan.scanTime then
        GameTooltip:AddLine(L["Sin escaneo de la AH: solo cuenta precios de vendedor. Escanea para un coste real."], 1, 0.6, 0.2, true)
      end
    elseif e.pending then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(L["Calculando la ruta…"], 0.6, 0.6, 0.6)
    elseif e.from >= e.target then
      GameTooltip:AddLine(e.from >= ES.MAX_SKILL and L["Ya está al máximo."] or L["Ya has llegado a tu objetivo."], 0.4, 1, 0.4)
    elseif not e.learned then
      -- (las que no tienes no se calculan solas: ver ProfessionEntries)
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(L["Su ruta se calcula al abrirla (solo se calculan solas las profesiones que tienes)."], 0.6, 0.6, 0.6, true)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["Pulsa para ver el plan paso a paso y qué fabricar."], 0.5, 0.8, 1)
    GameTooltip:Show()
  end
end

function ES:RenderHome()
  local page = self.homePage
  if not page or not page:IsVisible() then return end -- se calcula al mostrarse

  local entries = ProfessionEntries()
  local cards = {}
  for _, e in ipairs(entries) do
    local plan = e.plan
    local note
    local lock = ES:RouteLock(e.key)
    if lock and plan then
      -- Ruta empezada: se ve de un vistazo (borde verde y aviso)
      note = GREEN .. string.format(lock.completed and L["Ruta completada · de %d a %d"] or L["Ruta en curso · de %d a %d"],
        lock.from, lock.to) .. "|r"
    elseif e.pending then
      note = GREY .. L["Calculando la ruta…"] .. "|r"
    elseif plan and #plan.steps == 0 then
      -- Ni un paso: faltan precios de materiales. Un coste de 0 engañaría
      note = ORANGE .. L["Faltan precios: escanea la AH|r"]
      plan = nil
    elseif plan and plan.stoppedAt then
      note = ORANGE .. L["El plan llega hasta "] .. plan.reached .. "|r"
    elseif not e.learned then
      note = GREY .. L["No la tienes|r"]
    elseif plan and not plan.scanTime then
      note = ORANGE .. L["Sin escaneo: precios de vendedor|r"]
    end
    cards[#cards + 1] = {
      key = e.key, name = ES:ProfLabel(e.key), icon = e.prof.icon or ES.ICON, learned = e.learned,
      cost = plan and SignedCost(plan.net) or e.pending and (GREY .. "…|r") or (e.from >= e.target and (GREEN .. (e.from >= ES.MAX_SKILL and L["Al máximo"] or L["Objetivo cumplido"]) .. "|r") or (GREY .. "—|r")),
      level = string.format(L["Nivel %s%d|r / %d"], e.learned and GOLD or GREY, e.from, e.target),
      note = note or "", tooltip = ProfessionTooltip(e), active = (lock and plan) and true or nil,
    }
  end

  ES.UI.RenderCards(page, cards)
end

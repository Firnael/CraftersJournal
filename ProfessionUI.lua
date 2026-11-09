local _, ES = ...
local L = ES.L

-- Detalle de una profesión, al estilo del diario de mazmorras:
--   cabecera: icono, nombre, nivel actual (el del personaje) y objetivo editable;
--             a la derecha, usar bolsas (icono) y las vistas Ruta / Profit /
--             Lista de compra / Recetas
--   franja:   materiales, profit, instructor y herramientas, total
--   lista:    filas de dos líneas según la vista

local MAX_SKILL = ES.MAX_SKILL
local LOW_CHANCE_CRAFTS = 3 -- más fabricaciones por punto que esto: se avisa
local ROW_HEIGHT, ROW_GAP, SECTION_HEIGHT = 40, 4, 24
local LIST_WIDTH = 762
-- Filas de cita (line.quote, ver CreateRow): comillas, texto y margen
local QUOTE_SIZE, QUOTE_TEXT_SIZE, QUOTE_PAD, QUOTE_TEXT_X = 34, 11, 12, 52
local QUOTE_COIN_Y = -2 -- píxeles que se bajan los iconos de monedas en la cita (quedan altos)
local LEVEL_W = 70 -- columna de nivel de la vista Ruta (cabe "225–300")
local VIEW_BUTTON_H = 32 -- botones Ruta / Profit / Lista de compra (como los del diario de mazmorras)
local STATUS_BUTTON_H = 26 -- Empezar / Recalcular ruta y Actualizar precios (barra de estado)
local LIST_TOP = 80        -- de la cabecera a la lista (sin la fila "Real")
-- Marrones del diario de mazmorras: el fondo que agrupa la página, la tarjeta de la
-- cabecera (la más clara), el panel de la lista y las filas (más oscuras que el panel)
local BROWN = {
  group = { 0.165, 0.125, 0.086, 0.97 },
  card  = { 0.23, 0.18, 0.12, 0.97 },
  list  = { 0.18, 0.14, 0.10, 0.95 },
  row   = { 0.13, 0.10, 0.07, 0.95 },
}
local PAD = 14 -- margen interior: del fondo de la página a sus paneles

local SOURCE_LABEL = ES.Localize({
  vendor = "Vendedor", ah = "AH", craft = "Fabricar", stock = "Tuyo",
  owned = "Bolsas",
})
local LEARN_LABEL = ES.Localize({ trainer = "instructor", vendor = "receta del vendedor", scroll = "pergamino AH", unknown = "pergamino/drop, precio ?", favor = "Merchant's Favor",
  quest = "misión", ah = "pergamino en la AH", owned = "pergamino en tus bolsas", known = "ya la sabes" })
local RANK_NAMES = ES.Localize({ [150] = "Oficial", [225] = "Experto", [300] = "Artesano" })
local GOLD, GREEN, GREY, RED, ORANGE = "|cffffd100", "|cff40ff40", "|cff999999", "|cffff4040", "|cffff9933"

local VIEWS = ES.Localize({
  { key = "route",  label = "Ruta",            width = 96,  icon = "Interface\\Icons\\INV_Misc_Map_01" },
  { key = "shop",   label = "Lista de compra", width = 136, icon = "Interface\\Icons\\INV_Misc_Note_01" },
  { key = "profit", label = "Profit",          width = 96,  icon = "Interface\\Icons\\INV_Misc_Coin_02" },
}, "label")
local VIEW_KEYS = { route = true, profit = true, shop = true }

-- Coste con signo: lo que pagas en rojo con "-", lo que ganas en verde con "+"
-- (`copper` es coste: positivo = pagas, negativo = ganas)
local function Signed(copper)
  if copper <= -0.5 then return GREEN .. "+" .. ES.Money(-copper) .. "|r" end
  if copper >= 0.5 then return RED .. "-" .. ES.Money(copper) .. "|r" end
  return ES.Money(0)
end

-- Nombre del objeto en su color de calidad. Si el juego aún no lo ha cargado, el
-- nombre de los datos del addon (o `fallback`); el tercer valor dice que falta
function ES:ItemName(itemID)
  return (self:GetItemData(itemID)) or self:DataItemName(itemID)
end

local function ItemLabel(itemID, fallback)
  local name, quality, texture = ES:GetItemData(itemID)
  local color = name and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality or 1]
  if name and color and color.hex then
    name = color.hex .. name .. "|r"
  end
  return name or ES:DataItemName(itemID) or fallback, texture, name == nil
end

local function Label(parent, text, template)
  local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormalSmall")
  fs:SetText(text)
  return fs
end

local function CheckBox(parent, text, onClick)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetSize(24, 24)
  local label = Label(parent, text, "GameFontHighlightSmall")
  label:SetPoint("LEFT", cb, "RIGHT", 2, 1)
  cb:SetScript("OnClick", onClick)
  cb.label = label
  return cb
end

local function Panel(parent, r, g, b, a)
  local p = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  p:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  p:SetBackdropColor(r or 0.13, g or 0.09, b or 0.05, a or 0.94)
  p:SetBackdropBorderColor(0.52, 0.38, 0.17, 1)
  return p
end

-- ¿La AH activa es la neutral? (más depósito y 15% de comisión)
function ES:IsNeutralAH()
  return self:RealmKey():match("%-Neutral$") ~= nil
end

-- Marco desplazable con la rueda del ratón, sin barra de desplazamiento a la vista
local function WheelScroll(parent, step)
  local scroll = CreateFrame("ScrollFrame", nil, parent)
  scroll:EnableMouseWheel(true)
  scroll:SetScript("OnMouseWheel", function(self, delta)
    -- Sin la plantilla, algunos clientes no recalculan solos el alto del contenido
    if self.UpdateScrollChildRect then self:UpdateScrollChildRect() end
    local range = tonumber(self:GetVerticalScrollRange()) or 0
    local cur = tonumber(self:GetVerticalScroll()) or 0
    self:SetVerticalScroll(math.max(0, math.min(range, cur - delta * (step or 40))))
  end)
  return scroll
end

-- Indicador de desplazamiento de un WheelScroll: una guía fina pegada a su borde
-- derecho con un tirador que dice dónde estás y cuánto queda; se puede arrastrar.
-- Solo se ve si hay más contenido del que cabe. Deja `width` px libres a la derecha
-- del contenido para que no tape nada. Llamar a :Update() al cambiar el contenido.
local function ScrollIndicator(scroll, content, width)
  width = width or 5
  local track = CreateFrame("Frame", nil, scroll:GetParent())
  track:SetWidth(width)
  track:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, 0)
  track:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0, 0)
  track:SetFrameLevel(scroll:GetFrameLevel() + 5)
  local bg = track:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.35)
  local thumb = CreateFrame("Frame", nil, track)
  thumb:SetWidth(width)
  thumb:EnableMouse(true)
  local tex = thumb:CreateTexture(nil, "ARTWORK")
  tex:SetAllPoints()
  local function Tint(hover) tex:SetColorTexture(0.80, 0.62, 0.26, hover and 1 or 0.75) end
  Tint(false)

  local function Range()
    return math.max(0, (tonumber(content:GetHeight()) or 0) - (tonumber(scroll:GetHeight()) or 0))
  end
  function track:Update()
    local range, h = Range(), tonumber(track:GetHeight()) or 0
    if range <= 1 or h <= 0 then track:Hide() return end
    track:Show()
    local view = tonumber(scroll:GetHeight()) or 0
    local th = math.max(24, h * view / (view + range))
    thumb:SetHeight(th)
    local cur = math.max(0, math.min(range, tonumber(scroll:GetVerticalScroll()) or 0))
    thumb:ClearAllPoints()
    thumb:SetPoint("TOP", track, "TOP", 0, -(h - th) * cur / range)
  end

  -- Arrastrar el tirador: lo que baja el ratón, proporcional a todo el recorrido
  local startY, startScroll
  thumb:SetScript("OnMouseDown", function(self)
    local _, y = GetCursorPosition()
    startY, startScroll = y / (self:GetEffectiveScale() or 1), tonumber(scroll:GetVerticalScroll()) or 0
    self:SetScript("OnUpdate", function(s)
      local _, cy = GetCursorPosition()
      local free = (tonumber(track:GetHeight()) or 0) - (tonumber(s:GetHeight()) or 0)
      if free <= 0 then return end
      local delta = (startY - cy / (s:GetEffectiveScale() or 1)) * Range() / free
      scroll:SetVerticalScroll(math.max(0, math.min(Range(), startScroll + delta)))
    end)
  end)
  thumb:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
  thumb:SetScript("OnEnter", function() Tint(true) end)
  thumb:SetScript("OnLeave", function() Tint(false) end)

  scroll:HookScript("OnVerticalScroll", function() track:Update() end)
  scroll:HookScript("OnSizeChanged", function() track:Update() end)
  track:Hide()
  return track
end

-- Utilidades compartidas con otras pestañas
-- Fondo que agrupa toda una página (como el del diario de mazmorras), detrás de lo demás
local function GroupPanel(page)
  local g = Panel(page, BROWN.group[1], BROWN.group[2], BROWN.group[3], BROWN.group[4])
  g:SetPoint("TOPLEFT", 2, 0)
  g:SetPoint("BOTTOMRIGHT", -2, 2)
  g:SetFrameLevel(page:GetFrameLevel())
  return g
end

ES.UI = { Label = Label, CheckBox = CheckBox, ItemLabel = ItemLabel, Panel = Panel, WheelScroll = WheelScroll,
  ScrollIndicator = ScrollIndicator,
  BROWN = BROWN, GroupPanel = GroupPanel, PAD = PAD }

-- Objetivo de una profesión (editable en su detalle; por defecto, el máximo).
-- Lo usan la tarjeta de la portada y el detalle, para que el coste coincida.
function ES:ProfessionTarget(profKey)
  local settings = self.db.prof and self.db.prof[profKey] or {}
  return math.max(1, math.min(MAX_SKILL, tonumber(settings.target) or MAX_SKILL))
end

-- Opciones del plan de una profesión con los ajustes guardados. Las usan el
-- detalle y la tarjeta de la portada, para que el coste salga igual en los dos.
-- Depósito de subasta de 24 h y reutilizar lo fabricado: fijos por ahora.
function ES:PlanOptions(profKey, from, to, cap)
  self.db.prof = self.db.prof or {}
  local settings = self.db.prof[profKey] or {}
  -- Materiales que no quieres fabricar (✕ en "Fabrica 30× Light Leather"): se compran
  local via
  for itemID in pairs(settings.noCraft or {}) do
    via = via or {}
    via[itemID] = "buy"
  end
  return {
    via = via,
    -- La última ruta calculada de esta profesión: el GPS la prueba primero (ver PlanGPS)
    hint = self.lastRoutes[profKey],
    from = from, to = to, cap = cap,
    hours = 24,
    neutral = self:IsNeutralAH(),
    owned = settings.useBags and self:GetOwnedReagents(ES.Data[profKey]) or nil,
    ignoreSupply = true, -- no se mira cuántos hay a la venta: el plan no se para por existencias
    includeScrolls = false, -- recetas de pergamino/drop: pendiente para una versión futura
    reuseCrafted = true,
    -- Prueba piloto: recetas de pergamino por sus fuentes reales (misión, vendedor, AH)
    sourcedScrolls = ES.Waypoints.SOURCED_PROFESSIONS[profKey] or nil,
    noQuests = settings.useQuests == false or nil, -- icono de misión desactivado
    excluded = settings.excluded and next(settings.excluded) and settings.excluded or nil, -- quitadas con la ✕
    useFavor = settings.useFavor or nil, -- recetas de Merchant's Favor (icono; por defecto no)
  }
end

-- Recetas quitadas de la ruta y materiales que no quieres fabricar, en orden fijo
-- (para la clave de la caché)
local function ExcludedKey(settings)
  local ids = {}
  for id in pairs(settings.excluded or {}) do ids[#ids + 1] = id end
  for id in pairs(settings.noCraft or {}) do ids[#ids + 1] = -id end
  table.sort(ids)
  return table.concat(ids, ",")
end

---------------------------------------------------------------------------
-- Ruta fijada ("Empezar ruta"): una vez decidida, comprar (AH, vendedor, correo)
-- no la cambia ni cambia sus totales. Se guardan las recetas de cada nivel y lo
-- que llevabas en las bolsas al empezar (solo eso cuenta como gratis: lo que
-- compras para la ruta ya está contado como gasto). La lista de la compra dice
-- cuánto tienes de lo que falta desde tu nivel. Se libera con "Recalcular ruta",
-- al cambiar el objetivo u otra opción, con la ✕, o al llegar al objetivo.
--   settings.lock = { from, to, cap, choice = { [nivel] = receta }, via = { [material] = "craft" | "buy" },
--                     owned, started, scanTime }
---------------------------------------------------------------------------
ES.lockedPlans = {} -- ruta fijada ya calculada, por profesión (en memoria)
ES.lastRoutes = {}  -- última ruta calculada de cada profesión { choice, via } (pista para el GPS)

local function Remember(profKey, plan)
  if plan and plan.choice then ES.lastRoutes[profKey] = { choice = plan.choice, via = plan.ctx and plan.ctx.via } end
end

function ES:RouteLock(profKey)
  local settings = self.db.prof and self.db.prof[profKey]
  return settings and settings.lock
end

-- Precios del escaneo de los objetos que usa una ruta: materiales, lo que se
-- fabrica antes, lo que sale de cada paso, los pergaminos y las herramientas.
-- Con ellos la ruta fijada se rehace igual aunque haya escaneos nuevos.
local function RoutePrices(plan)
  local scan = ES.db.scans and ES.db.scans[ES:RealmKey()]
  local items = scan and scan.items or {}
  local ids = {}
  local function Recipe(r)
    if not r then return end
    for _, rq in ipairs(r.r or {}) do ids[rq[1]] = true end
    if r.out then ids[r.out[1]] = true end
    if r.scroll then ids[r.scroll] = true end
  end
  for _, st in ipairs(plan.steps) do Recipe(st.recipe) end
  for _, c in ipairs(plan.crafted or {}) do ids[c.itemID] = true Recipe(c.recipe) end
  for _, it in ipairs(plan.shopping or {}) do ids[it.itemID] = true end
  for _, tl in ipairs(plan.tools or {}) do ids[tl.item] = true end
  local prices = {}
  for id in pairs(ids) do prices[id] = items[id] end
  return prices, scan and scan.time
end

-- La ruta fijada: la de esta sesión tal cual; tras recargar se rehace con las
-- mismas recetas, las bolsas y los precios del principio (una sola pasada: rápido)
function ES:LockedPlan(profKey)
  local lock = self:RouteLock(profKey)
  if not lock then return nil end
  local plan = self.lockedPlans[profKey]
  if plan and plan.lockStarted == lock.started and plan.lockPrices == lock.scanTime then return plan end
  local opts = self:PlanOptions(profKey, lock.from, lock.to, lock.cap)
  opts.owned, opts.forced, opts.excluded, opts.via, opts.fullInfo = lock.owned, lock.choice, nil, lock.via, true
  opts.prices, opts.pricesTime = lock.prices, lock.scanTime
  plan = self.Planner:Plan(ES.Data[profKey], opts)
  plan.lockStarted, plan.lockPrices = lock.started, lock.scanTime
  self.lockedPlans[profKey] = plan
  return plan
end

-- "Actualizar precios": la misma ruta (mismas recetas por nivel) con los precios
-- del último escaneo.
function ES:RefreshRoutePrices(profKey)
  local lock = self:RouteLock(profKey)
  if not lock then return end
  local opts = self:PlanOptions(profKey, lock.from, lock.to, lock.cap)
  opts.owned, opts.forced, opts.excluded, opts.via, opts.fullInfo = lock.owned, lock.choice, nil, lock.via, true
  local plan = self.Planner:Plan(ES.Data[profKey], opts) -- con el último escaneo
  lock.prices, lock.scanTime = RoutePrices(plan)
  plan.lockStarted, plan.lockPrices = lock.started, lock.scanTime
  self.lockedPlans[profKey] = plan
end

function ES:StartRoute(page)
  local plan = page.plan
  if not plan or #plan.steps == 0 then return end
  local owned
  if plan.ctx and plan.ctx.opts.owned then
    owned = {}
    for itemID, q in pairs(plan.ctx.opts.owned) do owned[itemID] = q end
  end
  local choice = {}
  for s, id in pairs(plan.choice) do choice[s] = id end
  -- Materiales que se fabrican o se compran (ver Planner:Plan): igual al rehacerla
  local via = {}
  for itemID, way in pairs(plan.ctx and plan.ctx.via or {}) do via[itemID] = way end
  local prices, scanTime = RoutePrices(plan)
  local lock = { from = plan.from, to = plan.to, cap = page.detected and page.detected.cap or nil, choice = choice,
    via = via, owned = owned, started = time(), scanTime = scanTime, prices = prices }
  self.db.prof[page.profKey].lock = lock
  plan.lockStarted, plan.lockPrices = lock.started, lock.scanTime
  self.lockedPlans[page.profKey] = plan
  self:RenderPlan(page)
  self:RefreshAuctionAfterRoute()
end

function ES:StopRoute(profKey)
  local settings = self.db.prof and self.db.prof[profKey]
  if settings then settings.lock = nil end
  self.lockedPlans[profKey] = nil
  self:RefreshAuctionAfterRoute()
end

-- La lista de la compra junto a la AH solo enseña las rutas empezadas: con la AH
-- abierta, se actualiza al empezar o soltar una
function ES:RefreshAuctionAfterRoute()
  if self.RefreshAuctionPlan and self.IsAuctionHouseOpen and self:IsAuctionHouseOpen() then
    self:RefreshAuctionPlan(true)
  end
end

-- Plan de una profesión con su nivel actual y su objetivo, sin necesidad de abrir
-- su página (lo usan la lista de compra de la AH). nil si ya estás en el objetivo.
function ES:ProfessionPlan(profKey)
  local data = ES.Data[profKey]
  local rank, maxRank = self:GetProfessionSkill(data.skillLine)
  local from, to = rank or 1, self:ProfessionTarget(profKey)
  if from >= to then return nil, from, to end
  local locked = self:LockedPlan(profKey)
  if locked then return locked, from, to end
  local cap = rank and maxRank or nil
  local key = self:PlanKey(profKey, from, to, cap)
  local cached = self.homePlanCache[profKey]
  if cached and cached.key == key then return cached.plan, from, to end
  local plan = self.Planner:Plan(data, self:PlanOptions(profKey, from, to, cap))
  self.homePlanCache[profKey] = { key = key, plan = plan }
  Remember(profKey, plan)
  return plan, from, to
end

-- Rutas ya calculadas, una por profesión: las comparten la portada, la página de
-- la profesión y la lista de compra de la AH. La clave recoge todo lo que cambia
-- la ruta (nivel, objetivo, escaneo, opciones); ES:ClearHomeCache (idioma, vista)
-- sube planGen para todas, y ES:InvalidatePlan (bolsas, recetas aprendidas) solo
-- para una: con cada fabricación no se recalculan las 8 profesiones.
ES.planGen = 0
ES.planGens = {}
function ES:InvalidatePlan(profKey)
  self.planGens[profKey] = (self.planGens[profKey] or 0) + 1
  self.homePlanCache[profKey] = nil
end
function ES:PlanKey(profKey, from, to, cap)
  local settings = self.db.prof and self.db.prof[profKey] or {}
  local scan = self.db.scans and self.db.scans[self:RealmKey()]
  return table.concat({ profKey, self.planGen .. "." .. (self.planGens[profKey] or 0), scan and scan.time or 0, from, to, tostring(cap), tostring(settings.useBags),
    tostring(settings.useQuests), self:RealmKey(), ExcludedKey(settings), tostring(settings.useFavor) }, ":")
end

-- La ruta ya calculada (fijada, o en la caché y aún válida), sin calcular nada
function ES:CachedPlan(profKey, from, to, cap)
  local locked = self:LockedPlan(profKey)
  if locked then return locked end
  local cached = self.homePlanCache[profKey]
  if cached and cached.key == self:PlanKey(profKey, from, to, cap) then return cached.plan end
end

-- Ruta de una profesión: la de la caché si vale; si no, se calcula repartida entre
-- fotogramas (Jobs.lua) y al acabar se llama a onDone(plan). Devuelve la ruta si ya
-- está (en caché, o calculada de golpe fuera del juego). `owner` identifica a quien
-- la pide (la portada, una página) para no avisarle dos veces.
function ES:RequestPlan(profKey, from, to, cap, onDone, owner)
  local locked = self:LockedPlan(profKey) -- ruta fijada: la portada enseña la misma
  if locked then return locked end
  local key = self:PlanKey(profKey, from, to, cap)
  local cached = self.homePlanCache[profKey]
  if cached and cached.key == key then return cached.plan end
  local inline = true
  self.Jobs.Run("plan:" .. profKey .. ":" .. tostring(owner), key, function()
    return self.Planner:Plan(ES.Data[profKey], self:PlanOptions(profKey, from, to, cap))
  end, function(plan)
    if self:PlanKey(profKey, from, to, cap) == key then
      self.homePlanCache[profKey] = { key = key, plan = plan }
      Remember(profKey, plan)
    end
    if not inline and onDone then onDone(plan) end
  end, owner)
  inline = false
  cached = self.homePlanCache[profKey]
  if cached and cached.key == key then return cached.plan end
end

---------------------------------------------------------------------------
-- Tooltips
---------------------------------------------------------------------------
-- Por qué se para un plan, en una frase
local function StopReason(plan)
  local short, missing = {}, 0
  for itemID in pairs(plan.shortSupply) do
    short[#short + 1] = (ItemLabel(itemID, L["objeto "] .. itemID))
    if #short >= 3 then break end
  end
  for _ in pairs(plan.missingPrice) do missing = missing + 1 end
  if #short > 0 then
    return L["no quedan suficientes en la AH de: "] .. table.concat(short, ", ")
  elseif missing > 0 then
    return string.format(L["%d materiales sin precio (no están en la AH)"], missing)
  end
  return L["no hay más recetas de instructor para ese nivel"]
end

---------------------------------------------------------------------------
-- Alternativas de cada paso: la segunda mejor receta y por qué es peor
---------------------------------------------------------------------------
local ALT_BUDGET = 8   -- ms por fotograma calculándolas (se reparten: no traban el juego)
local ALT_BATCH = 10   -- sin debugprofilestop: pasadas por fotograma
local ALT_SHOWN = 3    -- en el tooltip, las mejores

-- Motivo en el idioma del addon (al pintar: si se cambia de idioma, cambia)
local function AltReason(st, alt)
  local k = ES.Planner.AlternativeReason(st, alt)
  if k == "materials" then return L["materiales más caros"] end
  if k == "sale" then return L["se recupera menos vendiéndolo"] end
  if k == "fee" then return L["hay que aprenderla"] end
  if k == "crafts" then return L["hacen falta más fabricaciones"] end
  return L["encarece otros pasos de la ruta"]
end

-- Calcula, poco a poco, las alternativas de cada paso de la ruta y repinta al acabar
-- (plan.alts[i] = lista de la más barata a la más cara; vacía si no hay otra receta)
function ES:ComputeAlternatives(page, plan)
  if plan.alts or plan.altsRunning or not plan.choice or not (plan.ctx and plan.ctx.opts) then return end
  plan.altsRunning = true
  local P, data = self.Planner, page.data
  local jobs, results = {}, {}
  for i, st in ipairs(plan.steps) do
    results[i] = {}
    for _, id in ipairs(P.AlternativeCandidates(data, plan, st)) do jobs[#jobs + 1] = { i, id } end
  end
  local k = 1
  local function Work()
    if page.plan ~= plan then plan.altsRunning = nil return end -- ruta nueva: se deja
    local started = debugprofilestop and debugprofilestop()
    local n = 0
    while k <= #jobs do
      local i, id = jobs[k][1], jobs[k][2]
      local alt = P.EvaluateAlternative(data, plan, plan.steps[i], id)
      if alt then table.insert(results[i], alt) end
      k, n = k + 1, n + 1
      if started then
        if debugprofilestop() - started > ALT_BUDGET then break end
      elseif n >= ALT_BATCH then break end
    end
    if k <= #jobs then C_Timer.After(0, Work) return end
    for _, list in pairs(results) do table.sort(list, function(a, b) return a.delta < b.delta end) end
    plan.alts, plan.altsRunning = results, nil
    if page:IsVisible() and page.plan == plan then ES:RenderPlan(page) end
  end
  Work()
end

-- "2ª: White Bandit Mask, +57s (se recupera menos vendiéndolo)" para la fila del paso
local function AltSummary(plan, i, data)
  local list = plan.alts and plan.alts[i]
  if not list then return nil end
  local alt = list[1]
  if not alt then return GREY .. L["única receta que da puntos aquí"] .. "|r" end
  local r = data.recipes[alt.id]
  if alt.delta <= -0.5 then
    local extra = math.floor((alt.step.expected or 0) - (plan.steps[i].expected or 0) + 0.5)
    if extra > 0 then
      -- La ruta paga un poco más a cambio de fabricar menos veces (a propósito)
      return GREY .. string.format(L["2ª: %s, %s más barata pero con %d fabricaciones más"], r and r.name or "?",
        ES.Money(-alt.delta), extra) .. "|r"
    end
    -- Más barata y sin más fabricaciones: el planificador no la encontró; que se vea
    return GREEN .. string.format(L["%s sale %s más barata"], r and r.name or "?", ES.Money(-alt.delta)) .. "|r"
  end
  if alt.delta < 0.5 then return GREY .. string.format(L["2ª: %s, igual de cara"], r and r.name or "?") .. "|r" end
  return GREY .. string.format(L["2ª: %s, %s (%s)"], r and r.name or "?", "+" .. ES.Money(alt.delta),
    AltReason(plan.steps[i], alt)) .. "|r"
end

-- Las mejores alternativas del paso, con sus cifras frente a la de la ruta
local function AddAltTooltip(plan, i, data)
  local list = plan.alts and plan.alts[i]
  GameTooltip:AddLine(" ")
  if not list then
    GameTooltip:AddLine(L["Comparando con otras recetas…"], 0.6, 0.6, 0.6)
    return
  end
  if #list == 0 then
    GameTooltip:AddLine(L["Es la única receta que puedes usar en este tramo."], 0.8, 0.8, 0.8, true)
    return
  end
  local st = plan.steps[i]
  GameTooltip:AddLine(L["Por qué esta y no otra:"], 1, 0.82, 0)
  for n = 1, math.min(ALT_SHOWN, #list) do
    local alt = list[n]
    local a, r = alt.step, data.recipes[alt.id]
    GameTooltip:AddDoubleLine(string.format("%d. %s", n + 1, r and r.name or "?"),
      alt.delta >= 0.5 and (RED .. "+" .. ES.Money(alt.delta) .. "|r")
      or alt.delta <= -0.5 and (GREEN .. "-" .. ES.Money(-alt.delta) .. "|r") or L["igual"], 1, 1, 1, 1, 1, 1)
    GameTooltip:AddLine("   " .. string.format(L["%d fabricaciones (aquí %d) · %s/u (aquí %s) · recuperas %s/u (aquí %s)"],
      a.crafts, st.crafts, ES.Money(a.unitCost), ES.Money(st.unitCost), ES.Money(a.unitValue), ES.Money(st.unitValue))
      .. ((a.fee or 0) > 0 and (" · " .. L["aprender"] .. " " .. ES.Money(a.fee)) or ""), 0.75, 0.75, 0.75, true)
    if alt.delta > -0.5 then
      GameTooltip:AddLine("   " .. L["Peor porque: "] .. AltReason(st, alt), 0.75, 0.75, 0.75, true)
    elseif (a.expected or 0) > (st.expected or 0) + 0.5 then
      GameTooltip:AddLine("   " .. L["La ruta prefiere pagar un poco más a cambio de fabricar menos veces."], 0.75, 0.75, 0.75, true)
    else
      GameTooltip:AddLine("   " .. L["Sale mejor que la de la ruta: quita la de la ruta con su ✕ para usar esta."], 0.4, 1, 0.4, true)
    end
    if alt.ahGain > alt.delta + 0.5 then
      GameTooltip:AddLine("   " .. string.format(L["Vendiendo lo fabricado en la AH saldría %s mejor que la ruta, si se vende (la ruta cuenta el vendedor, que es lo seguro)."],
        ES.Money(alt.ahGain - alt.delta)), 1, 0.82, 0, true)
    end
  end
end

local function RecipeTooltip(step, plan)
  return function(row)
    local r = step.recipe
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(ItemLabel(r.out and r.out[1] or 0, r.name))
    GameTooltip:AddLine(string.format(L["Amarilla desde %d · verde desde %d · gris desde %d"], r.t[2], r.t[3], r.t[4]), 0.8, 0.8, 0.8)

    -- Por qué hacen falta tantas fabricaciones
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(string.format(L["De %d a %d: probabilidad de subir del %d%% al %d%%"], step.from, step.to,
      math.floor(step.firstChance * 100 + 0.5), math.floor(step.lastChance * 100 + 0.5)), 1, 0.82, 0)
    GameTooltip:AddLine(string.format(L["%d puntos necesitan unas %s fabricaciones (se redondea a %d)."],
      step.to - step.from, ES.Num(step.expected), step.crafts), 0.8, 0.8, 0.8, true)

    -- Si sale caro por baja probabilidad, explicar por qué no hay algo mejor
    if step.expected / (step.to - step.from) > LOW_CHANCE_CRAFTS then
      if #step.blocked > 0 then
        GameTooltip:AddLine(L["Hay recetas con más probabilidad, pero falta el precio de algún material en la AH:"], 1, 0.5, 0, true)
        for i, rid in ipairs(step.blocked) do
          if i > 4 then break end
          local br = plan.ctx.data.recipes[rid]
          local missing = {}
          for itemID in pairs(step.blocked[rid]) do missing[#missing + 1] = (ItemLabel(itemID, L["objeto "] .. itemID)) end
          GameTooltip:AddLine("  " .. (ItemLabel(br.out and br.out[1] or 0, br.name)) .. L[": falta "] .. table.concat(missing, ", "), 1, 0.7, 0.4, true)
        end
        GameTooltip:AddLine(L["Si consigues esos materiales (o aparecen en la AH), el plan las usará."], 0.8, 0.8, 0.8, true)
      else
        GameTooltip:AddLine(L["No hay ninguna receta de instructor mejor en este tramo: esta es la única opción."], 1, 0.5, 0, true)
      end
    end

    -- Materiales de todo el paso, con su precio medio real de compra
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["Materiales de este paso:"], 1, 0.82, 0)
    for _, rg in ipairs(step.reagents) do
      local name = ItemLabel(rg.item, L["Objeto "] .. rg.item)
      local kinds = {}
      for kind in pairs(rg.kinds) do kinds[#kinds + 1] = SOURCE_LABEL[kind] or kind end
      GameTooltip:AddDoubleLine(string.format("%dx %s", math.ceil(rg.qty - 0.001), name),
        string.format("%s %s(%s/u, %s)|r", ES.Money(rg.cost), GREY, ES.Money(rg.cost / rg.qty), table.concat(kinds, "+")),
        1, 1, 1, 1, 1, 1)
    end

    -- Parte de lo fabricado se usa más adelante en el plan
    local kept = r.out and plan.keptByItem[r.out[1]]
    if kept then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(string.format(L["Guarda %d para pasos posteriores (en total en el plan). Se cuentan a su precio de venta: es lo que dejas de ganar por no venderlos, y a cambio no tienes que comprarlos."], kept), 0.6, 1, 0.6, true)
    end

    -- La cuenta del total del paso
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(L["Coste medio por fabricación"], ES.Money(step.unitCost), 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine(L["Recuperas vendiendo (media)"], ES.Money(step.unitValue), 1, 1, 1, 1, 1, 1)
    local net = step.unitCost - step.unitValue
    GameTooltip:AddLine(string.format(L["Total = %d x (%s - %s)%s = %s"], step.crafts,
      ES.Money(step.unitCost), ES.Money(step.unitValue),
      step.fee > 0 and (" + " .. ES.Money(step.fee) .. L[" aprender"]) or "",
      net * step.crafts + step.fee < 0 and ("+" .. ES.Money(-(net * step.crafts + step.fee)) .. L[" de beneficio"])
        or ES.Money(net * step.crafts + step.fee)), 1, 1, 1, true)

    local sale = step.sale
    if sale then
      GameTooltip:AddLine(" ")
      GameTooltip:AddDoubleLine(L["Precio de vendedor"], ES.Money(sale.vendor), 0.8, 0.8, 0.8, 1, 1, 1)
      if sale.ahMin then
        GameTooltip:AddDoubleLine(L["Mínimo anunciado en la AH"], ES.Money(sale.ahMin), 0.8, 0.8, 0.8, 1, 1, 1)
        ES.Market.AddFairToTooltip(sale.fair)
      end
      GameTooltip:AddDoubleLine(L["Depósito por unidad (subasta de 24 h)"], ES.Money(sale.deposit), 0.8, 0.8, 0.8, 1, 1, 1)
      GameTooltip:AddLine(L["El plan cuenta la venta al vendedor: es lo único seguro."], 0.8, 0.8, 0.8, true)
      if sale.ahNet then
        GameTooltip:AddDoubleLine(L["En la AH te quedaría (igualando a la más barata)"], ES.Money(sale.ahNet), 0.8, 0.8, 0.8, 1, 1, 1)
        GameTooltip:AddLine(string.format(L["Si lo vendes en la AH podrías sacar hasta %s más en este paso, pero no se sabe cuántos se venden."],
          ES.Money(step.crafts * sale.qty * (sale.ahNet - sale.vendor))), 1, 0.82, 0, true)
        ES.Market.AddToTooltip(sale.itemID)
      elseif sale.ahMin then
        GameTooltip:AddLine(L["En la AH no te quedaría más que en el vendedor."], 0.8, 0.8, 0.8, true)
      end
      if sale.risk then
        GameTooltip:AddLine(L["Precio poco fiable: "] .. sale.risk .. ".", 1, 0.5, 0, true)
      end
    end
    if step.learnSource then
      GameTooltip:AddDoubleLine(L["Aprender ("] .. LEARN_LABEL[step.learnSource] .. ")",
        step.learnSource == "unknown" and "?" or ES.Money(step.fee), 1, 1, 1, 1, 1, 1)
    end
    GameTooltip:Show()
  end
end

local function DestinationTooltip(d, name, signals)
  return function(row)
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(name)
    GameTooltip:AddLine(string.format(L["Fabricas %d en total en el plan."], d.produced), 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ")
    if d.keep > 0 then
      GameTooltip:AddLine(string.format(L["Guarda %d (no los vendas):"], d.keep), 0.4, 1, 0.4)
      for _, u in ipairs(d.usedIn) do
        local where = u.step and string.format(L[" (paso %d-%d)"], u.step.from, u.step.to) or ""
        GameTooltip:AddLine(string.format(L["  %dx para %s%s"], u.qty, (ItemLabel(u.recipe.out and u.recipe.out[1] or 0, u.recipe.name)), where), 1, 1, 1, true)
      end
    end
    if d.sell > 0 then
      GameTooltip:AddLine(string.format(L["Te sobran %d. El plan cuenta venderlos al vendedor a %s cada uno."],
        d.sell, ES.Money(d.sale.vendor)), 0.8, 0.8, 0.8, true)
      if signals then
        GameTooltip:AddLine(string.format(L["En la AH te quedarían %s cada uno igualando a la más barata (subasta de 24 h, comisión y depósito de %s descontados): hasta %s más en total."],
          ES.Money(d.sale.ahNet), ES.Money(d.sale.deposit), ES.Money(d.ahExtra)), 1, 0.82, 0, true)
        GameTooltip:AddLine(L["Pero el juego no dice cuántos se venden: puede que no los vendas todos, o ninguno. Anuncia unos pocos y mira las alertas:"], 1, 0.6, 0.2, true)
        ES.Market.AddToTooltip(d.itemID)
      end
      -- Consejo final
      local a = d.advice or ES.Planner.SaleAdvice(d)
      GameTooltip:AddLine(" ")
      if a.ah > 0 and a.verdict == "good" then
        GameTooltip:AddLine(string.format(L["Consejo: pon los %d en la AH a %s (1 cobre menos que la más barata)."], a.ah, ES.Money(a.price)), 0.4, 1, 0.4, true)
      elseif a.ah > 0 then
        GameTooltip:AddLine(string.format(L["Consejo: pon solo %d en la AH a %s para probar y vende el resto al vendedor; si se venden, anuncia más."], a.ah, ES.Money(a.price)), 1, 0.82, 0, true)
      elseif signals and signals.verdict == "avoid" then
        GameTooltip:AddLine(L["Consejo: con estas alertas, mejor véndelos al vendedor."], 1, 0.4, 0.4, true)
      elseif a.vendor > 0 then
        GameTooltip:AddLine(L["Consejo: véndelos al vendedor; en la AH no compensa la diferencia."], 0.8, 0.8, 0.8, true)
      end
    end
    GameTooltip:Show()
  end
end

local function ShopTooltip(it, plan)
  return function(row)
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. it.itemID)
    if it.source == "ah" then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(string.format(L["%d uds a %s de media, comprando de la más barata a la más cara (ahora hay %d a la venta)."],
        it.quantity, ES.Money(it.unit), it.supply or 0), 0.8, 0.8, 0.8, true)
      if it.supply and it.quantity > it.supply then
        GameTooltip:AddLine(string.format(L["Hacen falta más de las que hay: las %d que faltan se cuentan al precio típico (mediana)."],
          it.quantity - it.supply), 1, 0.6, 0.2, true)
      end
    end
    -- Si también se puede fabricar: por qué se compra en vez de hacerlo tú
    local craftUnit, craftRecipe = ES.Planner.CraftUnitCost(plan.ctx, it.itemID)
    if craftUnit then
      local mats = {}
      for _, rq in ipairs(craftRecipe.r) do
        mats[#mats + 1] = rq[2] .. "x " .. (ItemLabel(rq[1], L["objeto "] .. rq[1]))
      end
      GameTooltip:AddLine(" ")
      GameTooltip:AddDoubleLine(L["Fabricarlo tú ("] .. table.concat(mats, ", ") .. ")", ES.Money(craftUnit) .. " /u", 0.8, 0.8, 0.8, 1, 1, 1)
      if craftUnit > it.unit then
        GameTooltip:AddLine(string.format(L["Comprarlo hecho sale más barato (%s frente a %s por unidad), así que el plan lo compra."],
          ES.Money(it.unit), ES.Money(craftUnit)), 0.6, 1, 0.6, true)
      end
    end
    if it.source == "vendor" then
      ES.Waypoints.AddToTooltip(L["Vendedor más cercano"], ES.Waypoints.Target("vendor", it.itemID))
    end
    GameTooltip:Show()
  end
end

local function SimpleTooltip(itemID, text)
  return function(row)
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. itemID)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(text, 0.6, 1, 0.6, true)
    GameTooltip:Show()
  end
end

---------------------------------------------------------------------------
-- Filas de la lista
---------------------------------------------------------------------------
local function CreateRow(parent)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetWidth(LIST_WIDTH)
  row:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  local hl = row:CreateTexture(nil, "HIGHLIGHT")
  row.hl = hl
  hl:SetPoint("TOPLEFT", 2, -2)
  hl:SetPoint("BOTTOMRIGHT", -2, 2)
  hl:SetColorTexture(1, 0.82, 0.25, 0.08)

  -- Columna de nivel (vista Ruta): "72–75" en fabricar, "75" en aprender o entrenar.
  -- Sin ancho fijo (nunca se corta) y centrada en la columna y a media altura
  row.level = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.level:SetPoint("CENTER", row, "LEFT", LEVEL_W / 2 + 1, 0)
  row.level:SetWordWrap(false)
  row.levelLine = row:CreateTexture(nil, "ARTWORK")
  row.levelLine:SetSize(1, ROW_HEIGHT - 12)
  row.levelLine:SetPoint("LEFT", LEVEL_W, 0)
  row.levelLine:SetColorTexture(0.40, 0.29, 0.13, 0.8)

  -- Hueco del icono (30x30): el texto se alinea con él aunque el icono sea más
  -- pequeño (line.iconSize: texturas de botón, que ampliadas se ven pixeladas)
  row.iconSlot = row:CreateTexture(nil, "BACKGROUND")
  row.iconSlot:SetSize(30, 30)
  row.iconSlot:SetPoint("LEFT", 6, 0)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(30, 30)
  row.icon:SetPoint("CENTER", row.iconSlot)
  row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.title:SetPoint("TOPLEFT", row.iconSlot, "TOPRIGHT", 10, -1)
  row.title:SetPoint("RIGHT", -170, 0)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)

  row.sub = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.sub:SetPoint("BOTTOMLEFT", row.iconSlot, "BOTTOMRIGHT", 10, 1)
  row.sub:SetPoint("RIGHT", -170, 0)
  row.sub:SetJustifyH("LEFT")
  row.sub:SetWordWrap(false)
  row.sub:SetTextColor(0.75, 0.72, 0.65)

  row.value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.value:SetPoint("RIGHT", -12, 0)
  row.value:SetJustifyH("RIGHT")

  -- Fila de cita (line.quote): el texto en varias líneas entre comillas grandes,
  -- con margen alrededor para que ni las comillas ni el texto toquen el borde.
  -- La comilla se dibuja en la parte alta de su caja (unos 0,78 del tamaño por
  -- encima del pie): la de cerrar se baja para que su dibujo quede a QUOTE_PAD del borde
  local QUOTE_FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
  row.quoteOpen = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.quoteOpen:SetFont(QUOTE_FONT, QUOTE_SIZE)
  row.quoteOpen:SetText("\226\128\156") -- “
  row.quoteOpen:SetTextColor(1, 0.82, 0.25, 0.55)
  row.quoteOpen:SetPoint("TOPLEFT", QUOTE_PAD + 4, -QUOTE_PAD + 6)
  row.quoteClose = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.quoteClose:SetFont(QUOTE_FONT, QUOTE_SIZE)
  row.quoteClose:SetText("\226\128\157") -- ”
  row.quoteClose:SetTextColor(1, 0.82, 0.25, 0.55)
  row.quoteClose:SetPoint("BOTTOMRIGHT", -(QUOTE_PAD + 4), QUOTE_PAD - math.floor(QUOTE_SIZE * 0.78))
  row.quote = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.quote:SetFont(QUOTE_FONT, QUOTE_TEXT_SIZE)
  row.quote:SetPoint("LEFT", QUOTE_TEXT_X, 0) -- ancho: el de la fila menos los márgenes (StyleRow)
  row.quote:SetJustifyH("LEFT")
  row.quote:SetWordWrap(true)
  row.quote:SetSpacing(3)
  row.quote:SetTextColor(0.78, 0.75, 0.68) -- atenuado: es información, no un paso

  -- Encabezado de sección (sin recuadro)
  row.section = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.section:SetPoint("LEFT", 4, 0)

  -- ✕ para quitar la receta de la ruta (solo en los pasos de la ruta: line.onSkip)
  local skip = CreateFrame("Button", nil, row)
  row.skip = skip
  skip:SetSize(16, 16)
  skip:SetPoint("RIGHT", -8, 0)
  skip:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
  skip:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight", "ADD")
  skip:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
  skip:SetScript("OnClick", function() if row.onSkip then row.onSkip() end end)
  skip:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Quitar de la ruta"])
    GameTooltip:AddLine(row.skipTip or L["La ruta busca otra receta en su lugar (por ejemplo, si no quieres ir a por este pergamino)."], 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
  end)
  skip:SetScript("OnLeave", function() GameTooltip:Hide() end)
  skip:Hide()

  row:SetScript("OnEnter", function(self)
    if self.go and not self.onClick then ES.Waypoints.HoverRow(self) end -- estrella al pulsar (Waypoints.lua)
    if self.tooltip then self.tooltip(self) end
  end)
  row:SetScript("OnLeave", function() GameTooltip:Hide() end)
  -- Filas de instructor o vendedor: clic para marcar el camino al más cercano
  row:SetScript("OnClick", function(self)
    if self.onClick then
      self.onClick()
    elseif self.ahItem and ES:IsAuctionHouseOpen() then
      ES:SearchAuction(self.ahItem) -- (receta en la AH, con la AH abierta: buscarla)
    elseif self.go then
      ES.Waypoints.Go(self.go)
    end
  end)
  return row
end

-- Tooltip de una fila con camino: qué es, y el instructor o vendedor más cercano
local function TravelTooltip(title, text, label, pick)
  return function(row)
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(title)
    if text then GameTooltip:AddLine(text, 0.8, 0.8, 0.8, true) end
    ES.Waypoints.AddToTooltip(label, pick)
    GameTooltip:Show()
  end
end

-- Alto de una línea de la lista: las de cita llevan el suyo (line.height)
local function LineHeight(line)
  return line.section and SECTION_HEIGHT or line.height or ROW_HEIGHT
end

-- Pinta una línea en una fila y devuelve el alto que ocupa
local function StyleRow(row, line)
  local isSection = line.section ~= nil
  local isQuote = line.quote ~= nil
  row.quote:SetText(line.quote or "")
  row.quoteOpen:SetShown(isQuote)
  row.quoteClose:SetShown(isQuote)
  row.quote:SetShown(isQuote)
  row.hl:SetShown(not isQuote) -- la cita solo informa: no se resalta al pasar el ratón
  -- La cita, tan alta como su texto más el margen (como mínimo line.height)
  local height = LineHeight(line)
  if isQuote then
    -- Ancho fijo (la fila aún no está colocada): así el alto del texto ya se puede medir
    row.quote:SetWidth(math.max(100, (tonumber(row:GetWidth()) or LIST_WIDTH) - 2 * QUOTE_TEXT_X))
    local textH = tonumber(row.quote:GetStringHeight()) or 0
    height = math.max(height, math.ceil(textH) + 2 * (QUOTE_PAD + 8))
  end
  row:SetHeight(height)
  if isSection then
    row:SetBackdropColor(0, 0, 0, 0)
    row:SetBackdropBorderColor(0, 0, 0, 0)
  elseif line.total then
    row:SetBackdropColor(0.20, 0.14, 0.06, 0.95)
    row:SetBackdropBorderColor(0.68, 0.52, 0.20, 1)
  elseif line.current then
    -- Ruta empezada: el paso en el que estás
    row:SetBackdropColor(0.17, 0.13, 0.06, 0.96)
    row:SetBackdropBorderColor(1, 0.82, 0.25, 1)
  else
    row:SetBackdropColor(BROWN.row[1], BROWN.row[2], BROWN.row[3], BROWN.row[4])
    row:SetBackdropBorderColor(0.40, 0.29, 0.13, 1)
  end
  row.section:SetText(isSection and (GOLD .. line.section .. "|r") or "")
  -- Columna de nivel: todas las filas de la ruta la llevan; el resto empieza en el borde
  local hasLevel = line.level ~= nil
  local left = hasLevel and (LEVEL_W + 8) or 6
  row.level:SetText(hasLevel and ((line.done and GREY or "") .. line.level .. (line.done and "|r" or "")) or "")
  row.levelLine:SetShown(hasLevel)
  row.iconSlot:ClearAllPoints()
  row.iconSlot:SetPoint("LEFT", left, 0)
  row.icon:SetShown(not isSection and not isQuote and line.icon ~= nil)
  if line.icon == ES.QUEST_ICON then ES.SetQuestIcon(row.icon) else row.icon:SetTexture(line.icon) end
  -- Icono más pequeño (textura de botón): entera, sin recortar el borde como los de objeto
  row.icon:SetSize(line.iconSize or 30, line.iconSize or 30)
  if line.iconSize then row.icon:SetTexCoord(0, 1, 0, 1) elseif line.icon ~= ES.QUEST_ICON then row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) end
  row.title:SetText(not isQuote and line.title or "")
  row.sub:SetText(not isQuote and line.sub or "")
  row.value:SetText(line.value or "")
  -- Sin icono, el texto empieza más a la izquierda
  row.title:ClearAllPoints()
  row.sub:ClearAllPoints()
  local anchor, x = row.iconSlot, 10
  if not line.icon then anchor, x = row, left + 6 end
  if line.icon then
    row.title:SetPoint("TOPLEFT", anchor, "TOPRIGHT", x, -1)
    row.sub:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", x, 1)
  else
    row.title:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, -7)
    row.sub:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", x, 7)
  end
  row.title:SetPoint("RIGHT", -170, 0)
  row.sub:SetPoint("RIGHT", -170, 0)
  row.tooltip = line.tooltip
  row.go = line.go
  row.ahItem = line.ahItem
  row.onClick = line.onClick
  row.onSkip, row.skipTip = line.onSkip, line.skipTip
  row.skip:SetShown(line.onSkip ~= nil)
  row.value:ClearAllPoints()
  row.value:SetPoint("RIGHT", line.onSkip and -30 or -12, 0)
  return height
end

-- Filas de dos líneas compartidas con otras páginas (Ganar dinero, Colección)
ES.UI.CreateRow, ES.UI.StyleRow, ES.UI.Signed = CreateRow, StyleRow, Signed
ES.UI.ROW_HEIGHT, ES.UI.ROW_GAP, ES.UI.SECTION_HEIGHT, ES.UI.LIST_WIDTH = ROW_HEIGHT, ROW_GAP, SECTION_HEIGHT, LIST_WIDTH

-- Ancho de las filas: el de la zona de la lista (llegan hasta el borde, también al
-- cambiar el tamaño de la ventana); sin ella, el fijo de siempre
local function ListWidth(page)
  local w = page.scroll and page.scroll:GetWidth()
  return (w and w > 50) and w or LIST_WIDTH
end
ES.UI.ListWidth = ListWidth

-- Pinta una lista de líneas (ver StyleRow) en page.content con page.rows
function ES.UI.RenderLines(page, lines)
  local y = 0
  page.pendingItems = false
  local width = ListWidth(page)
  page.content:SetWidth(width)
  for i, line in ipairs(lines) do
    local row = page.rows[i] or CreateRow(page.content)
    page.rows[i] = row
    row:SetWidth(width)
    local height = StyleRow(row, line)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -y)
    y = y + height + ROW_GAP
    if line.item and not ES:GetItemData(line.item) then page.pendingItems = true end
    row:Show()
  end
  for i = #lines + 1, #page.rows do page.rows[i]:Hide() end
  page.content:SetHeight(math.max(1, y))
end

---------------------------------------------------------------------------
-- Página de la profesión
---------------------------------------------------------------------------
function ES:CreateProfessionPage(page, profKey)
  local data = ES.Data[profKey]
  if data.guide then return self:CreateFishingPage(page, profKey) end -- Pesca: guía de zonas (FishingUI.lua)
  self.db.prof = self.db.prof or {}
  self.db.prof[profKey] = self.db.prof[profKey] or {}
  local settings = self.db.prof[profKey]
  settings.sellAH, settings.duration, settings.reuseCrafted = nil, nil, nil -- opciones retiradas

  local prof
  for _, p in ipairs(ES.PROFESSIONS) do if p.key == profKey then prof = p end end
  page.data, page.profKey, page.rows, page.lines = data, profKey, {}, {}
  page.profName = ES:ProfLabel(profKey)
  page.profIcon = prof and prof.icon or ES.ICON
  page.view = "route"
  for _, v in ipairs(VIEWS) do if v.key == settings.view then page.view = v.key end end

  -- Fondo que agrupa toda la página (como el del diario de mazmorras): un marrón más
  -- claro, de la tarjeta de la profesión hasta debajo del total
  page.group = GroupPanel(page)

  -- Cabecera de la profesión
  local head = Panel(page, BROWN.card[1], BROWN.card[2], BROWN.card[3], BROWN.card[4])
  head:SetPoint("TOPLEFT", PAD, -PAD + 2)
  head:SetPoint("TOPRIGHT", -PAD, -PAD + 2)
  head:SetHeight(66)
  page.head = head

  local icon = head:CreateTexture(nil, "ARTWORK")
  icon:SetSize(44, 44)
  icon:SetPoint("LEFT", 12, 0)
  icon:SetTexture(prof and prof.icon or ES.ICON)
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

  local name = Label(head, page.profName, "GameFontNormalHuge")
  name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, 2)
  name:SetTextColor(0.96, 0.79, 0.25)

  page.levelText = Label(head, "", "GameFontHighlight")
  page.levelText:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 12, 0)

  -- Objetivo: lo único editable; al cambiarlo se recalcula
  page.toBox = CreateFrame("EditBox", nil, head, "InputBoxTemplate")
  page.toBox:SetSize(36, 18)
  page.toBox:SetAutoFocus(false)
  page.toBox:SetNumeric(true)
  page.toBox:SetMaxLetters(3)
  page.toBox:SetJustifyH("CENTER")
  page.toBox:SetPoint("LEFT", page.levelText, "RIGHT", 10, 0)
  page.toBox:SetText(ES:ProfessionTarget(profKey))
  local function TargetChanged(self)
    self:ClearFocus()
    ES:CalculatePlan(page)
  end
  page.toBox:SetScript("OnEnterPressed", TargetChanged)
  page.toBox:SetScript("OnEditFocusLost", function(self)
    if tonumber(self:GetText()) ~= page.lastTarget then ES:CalculatePlan(page) end
  end)
  page.toBox:SetScript("OnEscapePressed", function(self)
    self:SetText(page.lastTarget or MAX_SKILL)
    self:ClearFocus()
  end)
  local toHint = Label(head, L["(máx. "] .. MAX_SKILL .. ")", "GameFontDisableSmall")
  toHint:SetPoint("LEFT", page.toBox, "RIGHT", 6, 0)

  -- Empezar ruta (la fija) / Recalcular ruta (la libera y la rehace con lo que llevas)
  -- (a la derecha de la línea de estado, bajo la franja de resumen: se coloca allí abajo)
  local routeButton = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
  page.routeButton = routeButton
  routeButton:SetSize(140, STATUS_BUTTON_H)
  routeButton:SetMotionScriptsWhileDisabled(true)
  routeButton:SetScript("OnClick", function()
    local now = GetTime and GetTime() or 0
    if ES:RouteLock(profKey) then
      -- El botón pasa de Empezar a Recalcular en el mismo sitio: un doble clic
      -- soltaba la ruta recién fijada sin querer
      if page.routeStartedAt and now - page.routeStartedAt < 1 then return end
      ES:StopRoute(profKey)
      ES:ClearHomeCache() -- con lo que llevas ahora
      ES:CalculatePlan(page)
    else
      page.routeStartedAt = now
      ES:StartRoute(page)
    end
  end)
  routeButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    if ES:RouteLock(profKey) then
      GameTooltip:AddLine(L["Recalcular ruta"])
      GameTooltip:AddLine(L["Vuelve a calcular la ruta con los precios y lo que llevas ahora. Lo que ya has comprado contará como tuyo (gratis)."], 0.8, 0.8, 0.8, true)
    else
      GameTooltip:AddLine(L["Empezar ruta"])
      GameTooltip:AddLine(L["Fija esta ruta: mientras compras en la AH, al vendedor o sacas del correo, ni la ruta ni su coste cambian. La lista de la compra va marcando lo que te falta."], 0.8, 0.8, 0.8, true)
      GameTooltip:AddLine(L["Púlsalo antes de empezar a comprar."], 0.5, 0.8, 1, true)
    end
    GameTooltip:Show()
  end)
  routeButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

  -- Actualizar precios: misma ruta con el último escaneo (solo si hay uno más nuevo)
  local pricesButton = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
  page.pricesButton = pricesButton
  pricesButton:SetSize(140, STATUS_BUTTON_H)
  pricesButton:SetPoint("RIGHT", routeButton, "LEFT", -6, 0)
  pricesButton:SetScript("OnClick", function()
    ES:RefreshRoutePrices(profKey)
    ES:CalculatePlan(page)
  end)
  pricesButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine(L["Actualizar precios"])
    GameTooltip:AddLine(L["La misma ruta (mismas recetas en cada nivel) con los precios del último escaneo. Lo que llevas gastado y vendido se mantiene."], 0.8, 0.8, 0.8, true)
    GameTooltip:AddLine(L["Recalcular ruta, en cambio, busca una ruta nueva."], 0.6, 0.6, 0.6, true)
    GameTooltip:Show()
  end)
  pricesButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
  pricesButton:Hide()

  -- Botones de vista, de derecha a izquierda
  page.viewButtons = {}
  local prev
  for i = #VIEWS, 1, -1 do
    local v = VIEWS[i]
    -- Como los del diario de mazmorras: más altos, icono grande a la izquierda
    local b = CreateFrame("Button", nil, head, "UIPanelButtonTemplate")
    b:SetSize(v.width, VIEW_BUTTON_H)
    if prev then b:SetPoint("RIGHT", prev, "LEFT", -6, 0) else b:SetPoint("RIGHT", -12, 0) end
    b.icon = b:CreateTexture(nil, "OVERLAY")
    b.icon:SetSize(VIEW_BUTTON_H - 6, VIEW_BUTTON_H - 6)
    b.icon:SetPoint("LEFT", 3, 0)
    b.icon:SetTexture(v.icon)
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b:SetText(v.label)
    local label = b:GetFontString()
    if label then
      label:ClearAllPoints()
      label:SetPoint("LEFT", b.icon, "RIGHT", 4, 0)
      label:SetPoint("RIGHT", -6, 0)
      label:SetJustifyH("CENTER")
    end
    b:SetScript("OnClick", function() ES:SelectProfessionView(page, v.key) end)
    b.key = v.key
    page.viewButtons[#page.viewButtons + 1] = b
    prev = b
  end

  -- Filtros: iconos que se tachan al desactivarlos y recalculan al pulsarlos.
  -- isOn() lee el ajuste; toggle() lo cambia; lines() da el texto del tooltip
  local function FilterIcon(anchor, texture, title, isOn, toggle, lines)
    local b = CreateFrame("Button", nil, head, "BackdropTemplate")
    b:SetSize(30, 30)
    b:SetPoint("RIGHT", anchor, "LEFT", anchor == prev and -12 or -6, 0)
    b:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10 })
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", 3, -3)
    b.icon:SetPoint("BOTTOMRIGHT", -3, 3)
    if texture == ES.QUEST_ICON then ES.SetQuestIcon(b.icon) else b.icon:SetTexture(texture) end
    if texture:find("Icons") then b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) end
    b.cross = b:CreateTexture(nil, "OVERLAY")
    b.cross:SetPoint("TOPLEFT", 4, -4)
    b.cross:SetPoint("BOTTOMRIGHT", -4, 4)
    b.cross:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(b.icon)
    hl:SetColorTexture(1, 1, 1, 0.15)
    function b:Refresh()
      local on = isOn()
      self.icon:SetDesaturated(not on)
      self.icon:SetAlpha(on and 1 or 0.55)
      self.cross:SetShown(not on)
      self:SetBackdropBorderColor(on and 1 or 0.4, on and 0.82 or 0.4, on and 0.25 or 0.4, 1)
    end
    b:SetScript("OnClick", function(self)
      toggle()
      self:Refresh()
      ES:StopRoute(profKey) -- otra opción es otra ruta: decisión tuya (comprar o fabricar no la libera)
      ES:CalculatePlan(page)
      if self:IsMouseOver() then self:GetScript("OnEnter")(self) end
    end)
    b:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
      GameTooltip:AddLine(title)
      for i, l in ipairs(lines()) do GameTooltip:AddLine(l, i == 1 and 1 or 0.7, i == 1 and 1 or 0.7, i == 1 and 1 or 0.7, true) end
      GameTooltip:AddLine(L["Pulsa para cambiarlo."], 0.5, 0.8, 1)
      if ES:RouteLock(profKey) then
        GameTooltip:AddLine(L["Con la ruta empezada, cambiarlo calcula una ruta nueva."], 1, 0.6, 0.2, true)
      end
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:Refresh()
    return b
  end

  -- Usar lo de las bolsas
  page.bagsButton = FilterIcon(prev, "Interface\\Icons\\INV_Misc_Bag_08", L["Usar lo que tienes en bolsas"],
    function() return settings.useBags and true or false end,
    function() settings.useBags = not settings.useBags end,
    function()
      return { settings.useBags and L["Activado: en la misma ruta, usa tus materiales (gratis) antes de comprar."]
        or L["Desactivado: el plan compra todo, aunque lo tengas."],
        L["Si con lo que llevas otra ruta sale más barata, la propone. Pulsa Empezar ruta antes de comprar: lo que compres para la ruta no contará como gratis."] }
    end)

  -- Contar misiones para conseguir recetas (prueba piloto: solo en las profesiones con fuentes reales)
  if ES.Waypoints.SOURCED_PROFESSIONS[profKey] then
    page.questButton = FilterIcon(page.bagsButton, ES.QUEST_ICON, L["Recetas de misiones"],
      function() return settings.useQuests ~= false end,
      function() settings.useQuests = settings.useQuests == false end,
      function()
        return { settings.useQuests ~= false and L["Activado: si una misión de tu bando da la receta, cuenta como gratis."]
          or L["Desactivado: las recetas solo se consiguen comprándolas (vendedor o Casa de Subastas)."],
          L["Útil si no quieres ir a hacer la misión."] }
      end)
  end

  -- Recetas de Merchant's Favor (fichas y reputación del campamento): por defecto no
  page.favorButton = FilterIcon(page.questButton or page.bagsButton, "Interface\\Icons\\INV_Misc_Coin_17",
    L["Recetas de Merchant's Favor"],
    function() return settings.useFavor and true or false end,
    function() settings.useFavor = not settings.useFavor or nil end,
    function()
      return { settings.useFavor and L["Activado: la ruta puede usar recetas que se compran con Merchant's Favor en el campamento de tu bando (cuestan fichas, no oro)."]
        or L["Desactivado: la ruta no usa recetas de Merchant's Favor."],
        L["Hace falta la reputación del campamento que pide cada una: el addon no puede comprobarla."] }
    end)

  -- Franja de resumen: materiales, profit, instructor y herramientas, total
  local strip = CreateFrame("Frame", nil, page)
  strip:SetPoint("TOPLEFT", head, "BOTTOMLEFT", 4, -6)
  strip:SetPoint("TOPRIGHT", head, "BOTTOMRIGHT", -4, -6)
  strip:SetHeight(46)
  page.strip = strip
  page.stats = {}
  local STATS = {
    { key = "materials", label = L["Materiales"] },
    { key = "profit",    label = L["Profit (vendiendo lo que fabricas)"] },
    { key = "fees",      label = L["Instructor y herramientas"] },
    { key = "total",     label = L["Total"] },
  }
  for i, s in ipairs(STATS) do
    local label = Label(strip, s.label, "GameFontDisableSmall")
    label:SetPoint("TOPLEFT", (i - 1) * 196 + 6, -2)
    local value = Label(strip, "", i == #STATS and "GameFontNormalLarge" or "GameFontHighlightLarge")
    value:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -3)
    page.stats[s.key] = value
  end
  page.routeButton:SetPoint("TOPRIGHT", strip, "BOTTOMRIGHT", 0, 0)
  page.status = Label(page, "", "GameFontHighlightSmall")
  page.status:SetPoint("TOPLEFT", strip, "BOTTOMLEFT", 2, -4)
  page.status:SetPoint("RIGHT", page.routeButton, "LEFT", -10, 0)
  page.status:SetJustifyH("LEFT")
  page.status:SetWordWrap(false)

  -- Lista
  local list = Panel(page, BROWN.list[1], BROWN.list[2], BROWN.list[3], BROWN.list[4])
  list:SetPoint("TOPLEFT", head, "BOTTOMLEFT", 0, -LIST_TOP)
  list:SetPoint("BOTTOMRIGHT", -PAD, PAD)
  page.listPanel = list
  local scroll = WheelScroll(list)
  scroll:SetPoint("TOPLEFT", 8, -8)
  scroll:SetPoint("BOTTOMRIGHT", -8, 8)
  page.content = CreateFrame("Frame", nil, scroll)
  page.content:SetSize(LIST_WIDTH, 1)
  scroll:SetScrollChild(page.content)
  page.scroll = scroll
  -- Al cambiar el tamaño de la ventana, las filas siguen llegando hasta el borde
  scroll:HookScript("OnSizeChanged", function()
    local width = ListWidth(page)
    page.content:SetWidth(width)
    for _, row in ipairs(page.rows) do row:SetWidth(width) end
  end)
  page.empty = Label(page.content, "", "GameFontDisable")
  page.empty:SetPoint("TOP", 0, -30)
  page.empty:SetWidth(600)

  ES.SafeRegister(page, "GET_ITEM_INFO_RECEIVED")
  page:SetScript("OnEvent", function(self)
    if not self.plan or self.refreshQueued then return end
    -- Faltaban nombres (repintar) o precios de vendedor (recalcular)
    local needsRecalc = self.plan.pendingInfo
    if self.pendingItems or needsRecalc then
      self.refreshQueued = true
      C_Timer.After(0.5, function()
        self.refreshQueued = false
        if not self:IsVisible() then return end
        if needsRecalc and not ES:RouteLock(self.profKey) then
          ES:ClearHomeCache() -- si no, la caché devolvería la misma ruta con el precio antiguo
          ES:CalculatePlan(self)
        else
          ES:RenderPlan(self)
        end
      end)
    end
  end)

  -- Al mostrarse: nivel actual del personaje (puede haber subido) y recalcular
  page:SetScript("OnShow", function(self)
    self.initialized = true
    ES:DetectSkill(self)
    ES:CalculatePlan(self)
    ES:SelectProfessionView(self, self.view)
  end)

  self.professionPages = self.professionPages or {}
  self.professionPages[#self.professionPages + 1] = page
end

-- Nivel actual: el del personaje (no se edita); si no tiene la profesión, 1
function ES:DetectSkill(page)
  local rank, maxRank = self:GetProfessionSkill(page.data.skillLine)
  page.from = rank or 1
  page.detected = rank and { rank = rank, cap = maxRank } or nil -- tope real (p. ej. 75 sin Oficial)
  page.levelText:SetText(string.format(L["Nivel %s%d|r%s   %sObjetivo:|r"], GOLD, page.from,
    rank and "" or (GREY .. L[" (no la tienes)|r"]), GREY))
end

function ES:SelectProfessionView(page, key)
  if not VIEW_KEYS[key] then key = "route" end -- "market" (Recetas) ya no existe: está en Colección
  page.view = key
  self.db.prof[page.profKey].view = key
  self.db.lastProf = page.profKey -- la lista de compra de la AH empieza por esta
  self.lastRouteProf = page.profKey -- (y la ventana del vendedor, aunque luego abras Ganar dinero)
  for _, b in ipairs(page.viewButtons) do
    if b.key == key then b:LockHighlight() else b:UnlockHighlight() end
  end
  self:RenderPlan(page)
end

-- Solo la que está a la vista: las demás se recalculan al mostrarse (OnShow),
-- así un escaneo no congela el juego recalculando las 8 profesiones
-- Cambian tus bolsas (compras, correo, fabricar): con la ruta fijada o sin "usar
-- lo de las bolsas" la ruta no cambia y basta con repintar (la lista de la compra
-- cuenta lo que llevas); sin fijar y con bolsas, se recalcula
function ES:RefreshAfterBags()
  for _, page in ipairs(self.professionPages or {}) do
    if page.initialized and page:IsVisible() and page.data and not page.data.guide then
      local settings = self.db.prof and self.db.prof[page.profKey] or {}
      if settings.useBags and not settings.lock then self:CalculatePlan(page) else self:RenderPlan(page) end
    end
  end
end

-- Aprendes una receta: con la ruta fijada se repinta (su fila de aprender queda
-- hecha); sin fijar, se recalcula (ya no hay que pagarla)
function ES:RefreshAfterLearn()
  for _, page in ipairs(self.professionPages or {}) do
    if page.initialized and page:IsVisible() and page.data and not page.data.guide then
      if self:RouteLock(page.profKey) then self:RenderPlan(page) else self:CalculatePlan(page) end
    end
  end
end

-- Sube tu nivel (fabricando): la profesión abierta lo relee al momento. Con la ruta
-- empezada solo se repinta (paso actual, lo que falta, pasos hechos); sin empezar,
-- la ruta se recalcula desde el nivel nuevo
function ES:RefreshAfterSkill()
  for _, page in ipairs(self.professionPages or {}) do
    if page.initialized and page:IsVisible() and page.data and not page.data.guide then
      local before = page.from
      self:DetectSkill(page)
      if page.from ~= before then
        if self:RouteLock(page.profKey) and page.from < self:RouteLock(page.profKey).to then
          self:RenderPlan(page)
        else
          self:CalculatePlan(page)
        end
      end
    end
  end
end

do
  local f, stamp = CreateFrame("Frame"), 0
  for _, e in ipairs({ "SKILL_LINES_CHANGED", "CHAT_MSG_SKILL" }) do ES.SafeRegister(f, e) end
  f:SetScript("OnEvent", function()
    if not ES.db then return end
    stamp = stamp + 1
    local mine = stamp
    C_Timer.After(0.3, function() if mine == stamp then ES:RefreshAfterSkill() end end)
  end)
end

function ES:RefreshProfessionPages()
  for _, page in ipairs(self.professionPages or {}) do
    if page.initialized and page:IsVisible() then self:CalculatePlan(page) end
  end
end

---------------------------------------------------------------------------
-- Cálculo y pintado
---------------------------------------------------------------------------
function ES:CalculatePlan(page)
  local from = page.from or 1
  local to = tonumber(page.toBox:GetText()) or MAX_SKILL
  to = math.max(1, math.min(MAX_SKILL, to))
  -- Ruta empezada: cambiar el objetivo es otra ruta (decisión tuya: se libera). Lo
  -- que pasa jugando no la libera: subir de nivel, comprar... y al llegar al
  -- objetivo se queda como completada hasta que la recalcules
  local lock = self:RouteLock(page.profKey)
  if lock and to ~= lock.to then
    self:StopRoute(page.profKey)
    lock = nil
  end
  if lock and from >= lock.to and not lock.completed then
    lock.completed = true
    self:Print(string.format(L["¡Ruta completada! %s de %d a %d."], page.profName, lock.from, lock.to))
  end
  page.toBox:SetText(to)
  page.lastTarget = to
  self.db.prof[page.profKey].target = to
  page.calculating = nil
  if lock then
    page.plan, page.planKey = self:LockedPlan(page.profKey), nil
  elseif from >= to then
    page.plan, page.planKey = nil, nil -- y si llega una ruta pedida antes, se descarta
  else
    -- Con el nivel detectado se usa el tope real para saber qué rangos faltan.
    -- Si no está en la caché, se calcula repartida entre fotogramas: mientras, se
    -- ve "Calculando la ruta…" (o la ruta anterior) y al acabar se repinta
    local cap = page.detected and page.detected.cap or nil
    local key = self:PlanKey(page.profKey, from, to, cap)
    page.planKey = key
    local plan = self:RequestPlan(page.profKey, from, to, cap, function(result)
      if page.planKey ~= key then return end -- se pidió otra ruta después
      page.calculating = nil
      page.plan = result
      self:RenderPlan(page)
    end, page)
    if plan then page.plan = plan else page.calculating = true end
  end
  self:RenderPlan(page)
end

-- Líneas de la vista Ruta: pasos con entrenamientos, herramientas y lo que hay
-- que fabricar antes, cada cosa en su sitio
local TRAIN_ICON = "Interface\\Icons\\INV_Misc_Book_09"   -- libro del instructor
local RECIPE_ICON = "Interface\\Icons\\INV_Scroll_03"     -- receta comprada (vendedor/AH)
local LEARN_WHERE = ES.Localize({ trainer = "Instructor", vendor = "Vendedor de recetas", scroll = "Pergamino en la AH", unknown = "Pergamino o botín" })
local WP = ES.Waypoints
local QUEST_ICON = ES.QUEST_ICON -- se pinta con el atlas en alta resolución (Core.lua)
local AH_ICON = "Interface\\Icons\\INV_Misc_Coin_01"

-- Abrir la receta en la ventana de la profesión y fabricar (la ventana moderna de
-- Forever: C_TradeSkillUI). Solo desde un clic del jugador.
function ES:OpenRecipe(recipeID)
  if InCombatLockdown and InCombatLockdown() then
    self:Print(L["No se pueden abrir las profesiones en combate."])
    return false
  end
  local T = C_TradeSkillUI
  if T and T.OpenRecipe and pcall(T.OpenRecipe, recipeID) then return true end
  self:Print(L["Abre la ventana de tu profesión para ver la receta."])
  return false
end

-- Abre la receta y fabrica `count` (todo en el mismo clic: el juego lo pide)
function ES:CraftRecipe(recipeID, count)
  if InCombatLockdown and InCombatLockdown() then
    self:Print(L["No se puede fabricar en combate."])
    return
  end
  self:OpenRecipe(recipeID)
  local T = C_TradeSkillUI
  -- Como mucho, las que te dan los materiales (el juego lo sabe con la ventana abierta)
  local info = T and T.GetRecipeInfo and select(2, pcall(T.GetRecipeInfo, recipeID))
  if type(info) == "table" and info.numAvailable and info.numAvailable > 0 then
    count = math.min(count, info.numAvailable)
  end
  if T and T.CraftRecipe then
    local ok, err = pcall(T.CraftRecipe, recipeID, count)
    if ok then
      self:Print(string.format(L["Fabricando %d..."], count))
      return
    end
    self:Print(L["No se pudo fabricar: "] .. tostring(err))
  end
end

-- Opción "Fabricar al pulsar un paso de la ruta" (Opciones > AddOns; por defecto sí)
function ES:AutoCraft()
  return self.db.autoCraft ~= false
end

local function CostOrFree(copper)
  if copper and copper >= 0.5 then return Signed(copper) end
  return GREEN .. L["gratis|r"]
end

-- Prueba piloto: fila "Conseguir receta" con su mejor fuente (misión, vendedor
-- o AH), el clic a quien da la misión o la vende, y todas las fuentes en el tooltip
local function SourcedLearnLine(r, st, profName, plan)
  local src = WP.RecipeSource(r, plan.ctx.prices, plan.ctx.opts.noQuests)
  local best = src and src.best
  if not best then return nil end
  local title = L["Conseguir receta: "] .. r.name
  local also = src.ah and best.kind ~= "ah" and (L[" · también en la AH: "] .. ES.Money(src.ah.price)) or ""
  local icon, sub, pick, label
  if best.kind == "owned" then
    icon, title = RECIPE_ICON, L["Aprender receta: "] .. r.name
    sub = string.format(L["La tienes en la bolsa%s · úsala para aprenderla"], best.count > 1 and (" (" .. best.count .. ")") or "")
  elseif best.kind == "quest" then
    icon, label = QUEST_ICON, L["Da la misión"]
    sub = L["Misión: "] .. best.quest.name .. also
    pick = function() return WP.Nearest(best.quest.starters) end
  elseif best.kind == "vendor" then
    icon, label = RECIPE_ICON, L["Vendedor más cercano"]
    sub = L["Vendedor de recetas"] .. also
    pick = function() return WP.Nearest(src.vendors) end
  else
    -- En la AH: clic al subastador más cercano; con la AH abierta, la busca
    icon, label = AH_ICON, L["Subastador más cercano"]
    sub = string.format(L["Casa de Subastas · la más barata ahora (%d a la venta)"], src.ah.listings)
    pick = WP.Target("auction")
  end

  local function Tooltip(row)
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Receta: "] .. r.name)
    GameTooltip:AddDoubleLine(L["Requiere "] .. profName, tostring(r.train or st.from), 0.8, 0.8, 0.8, 1, 1, 1)
    GameTooltip:AddLine(" ")
    local function Mark(kind) return best.kind == kind and ES.Market.ICON_OK or ES.Market.ICON_NONE end
    if src.owned then
      GameTooltip:AddDoubleLine(Mark("owned") .. L["En tus bolsas"], src.owned .. L[" · gratis"], 1, 0.82, 0, 1, 1, 1)
    end
    for _, q in ipairs(src.quests) do
      if src.questsOff then
        GameTooltip:AddDoubleLine(ES.Market.ICON_BAD .. L["Misión"], q.name .. L[" · desactivada"], 0.6, 0.6, 0.6, 0.6, 0.6, 0.6)
      else
        GameTooltip:AddDoubleLine(Mark("quest") .. L["Misión"], q.name .. L[" · gratis"], 1, 0.82, 0, 1, 1, 1)
      end
      local starter = WP.Nearest(q.starters)
      local npc = starter and WP.NPC(starter)
      if npc then GameTooltip:AddDoubleLine(" ", npc.name .. " · " .. WP.LocationText(npc), 1, 1, 1, 0.6, 0.6, 0.6) end
      if q.level > 0 then GameTooltip:AddDoubleLine(" ", L["nivel "] .. q.level, 1, 1, 1, 0.6, 0.6, 0.6) end
    end
    if src.vendors[1] then
      local opt
      for _, o in ipairs(src.options) do if o.kind == "vendor" then opt = o end end
      GameTooltip:AddDoubleLine(Mark("vendor") .. L["Vendedores"], string.format("%d · %s", #src.vendors,
        opt and opt.unknownPrice and L["precio ?"] or ES.Money(opt and opt.cost or 0)), 1, 0.82, 0, 1, 1, 1)
      local v = WP.Nearest(src.vendors)
      local npc = v and WP.NPC(v)
      if npc then GameTooltip:AddDoubleLine(" ", npc.name .. " · " .. WP.LocationText(npc), 1, 1, 1, 0.6, 0.6, 0.6) end
    end
    if src.ah then
      GameTooltip:AddDoubleLine(Mark("ah") .. L["AH ahora"], string.format(L["%s · %d a la venta"], ES.Money(src.ah.price), src.ah.listings),
        1, 0.82, 0, 1, 1, 1)
    else
      GameTooltip:AddDoubleLine(ES.Market.ICON_NONE .. L["AH ahora"], L["no hay ninguna"], 1, 0.82, 0, 0.6, 0.6, 0.6)
    end
    if src.noQuestie then
      GameTooltip:AddLine(L["Sin Questie no se saben misiones ni vendedores: solo cuenta la AH."], 1, 0.6, 0.2, true)
    end
    GameTooltip:AddLine(" ")
    if best.kind == "owned" then
      GameTooltip:AddLine(L["Ya la tienes: haz clic derecho sobre el pergamino en la bolsa para aprenderla."], 0.5, 0.8, 1, true)
    elseif best.kind == "ah" then
      if ES:IsAuctionHouseOpen() then
        GameTooltip:AddLine(L["Clic: buscarla en la Casa de Subastas."], 0.5, 0.8, 1)
      else
        WP.AddToTooltip(label, pick)
      end
    elseif pick then
      GameTooltip:AddLine(L["Clic: marcar el camino ("] .. (best.kind == "quest" and L["a quien da la misión"] or L["al vendedor"]) .. ").", 0.5, 0.8, 1)
    end
    GameTooltip:Show()
  end

  return { icon = icon, title = title, sub = sub, value = CostOrFree(st.fee), go = pick, tooltip = Tooltip,
    ahItem = best.kind == "ah" and r.scroll or nil }
end

-- Cita "Con lo que llevas": por qué la ruta no usa una receta que podrías hacer
-- con tus materiales, en una frase que se entienda de un vistazo (sin desglose: la
-- cuenta la hace el addon). Solo informa, no se pulsa. Si compensa, la ruta ya la
-- incluye (Planner:Plan) y no hay nada que explicar; salvo con la ruta fijada, que
-- no cambia sola: entonces se dice que recalcules. nil si no hay que decir nada.
local function BagsLine(alt, locked)
  local diff = alt.saving - alt.value -- > 0: hacerla con lo tuyo sale mejor que venderlo
  -- Compensa o empata (ver Planner.BagsWorth): la ruta ya la usa; solo con la ruta
  -- fijada hay que decirlo (no cambia sola). Si no, solo sale cuando vender es
  -- claramente mejor: por 3s de diferencia no merece una cita
  local worth = ES.Planner.BagsWorth(alt)
  if worth and not locked then return nil end
  local r = alt.recipe
  local name = ItemLabel(r.out[1], r.name)
  -- "50 Earthroot y 25 Peacebloom"
  local parts = {}
  for _, u in ipairs(alt.use) do
    parts[#parts + 1] = string.format("%d %s", u.qty, (ItemLabel(u.itemID, L["Objeto "] .. u.itemID)))
  end
  local mats = #parts > 1 and (table.concat(parts, ", ", 1, #parts - 1) .. L[" y "] .. parts[#parts]) or parts[1]
  -- Monedas centradas con la letra pequeña de la cita
  local function Coins(copper) return ES.MoneyInline(copper, QUOTE_COIN_Y) end
  local spend = alt.spend > 0 and string.format(L["solo gastas %s en el instructor y el vendedor"], Coins(alt.spend))
    or L["no gastas oro"]
  if alt.feeUnknown then spend = spend .. L[" (más el instructor, precio desconocido)"] end
  -- La conclusión, en su propia línea y en un color apagado (es información, no un aviso)
  local verdict
  if worth and diff > 0 then
    verdict = "|cff8fc98f" .. string.format(L["Hacerla con lo tuyo te sale unos %s mejor que venderlo y seguir la ruta. Pulsa Recalcular ruta para incluirla."], Coins(diff)) .. "|r"
  elseif worth then
    verdict = "|cff8fc98f" .. L["Sale casi igual que venderlo, así que es más cómodo usar lo tuyo. Pulsa Recalcular ruta para incluirla."] .. "|r"
  else
    verdict = "|cffd9a066" .. string.format(L["Vender lo tuyo y seguir la ruta te sale unos %s mejor."], Coins(-diff)) .. "|r"
  end
  return {
    -- Cita: la frase entera en la fila, entre comillas grandes (alto según el texto)
    quote = string.format(L["Con lo que llevas podrías hacer %s (%d–%d): %s, pero usas %s, por los que te darían unos %s vendiéndolos."],
      name, alt.from, alt.to, spend, mats, Coins(alt.value)) .. "\n" .. verdict,
    height = 76,
    alt = alt, -- (para pruebas)
  }
end

local function RouteLines(plan, page)
  local lines = {}
  local profIcon, profName = page.profIcon or ES.ICON, page.profName
  local settings = ES.db.prof[page.profKey]
  local locked = settings.lock ~= nil
  -- ✕ de cada paso: quita la receta y se recalcula la ruta con otra en su lugar
  -- (con la ruta empezada, la libera: es decisión tuya cambiarla)
  local function Skip(id)
    return function()
      settings.excluded = settings.excluded or {}
      settings.excluded[id] = true
      ES:StopRoute(page.profKey)
      ES:CalculatePlan(page)
    end
  end
  -- ✕ de "Fabrica 30× Light Leather": no fabricarlo, comprarlo hecho (y no sus materiales)
  local function SkipCraft(itemID)
    return function()
      settings.noCraft = settings.noCraft or {}
      settings.noCraft[itemID] = true
      ES:StopRoute(page.profKey)
      ES:CalculatePlan(page)
    end
  end
  -- Lo que se fabrica antes va justo delante del primer paso que lo usa. Si no lo
  -- usa un paso sino otro material que también se fabrica (Light Leather para la
  -- Fine Leather Tunic), va donde va ese, delante de él: así se fabrica justo
  -- cuando hace falta y no al principio de la ruta
  local craftBefore = {}
  local direct = {} -- [itemID] = primer paso que lo usa directamente
  for _, c in ipairs(plan.crafted) do
    for i, st in ipairs(plan.steps) do
      local uses = false
      for _, rg in ipairs(st.reagents) do
        if rg.item == c.itemID and rg.kinds.craft then uses = true break end
      end
      if uses then direct[c.itemID] = i break end
    end
  end
  -- Herramientas que se fabrican (Runed Golden Rod): van en el paso donde hacen
  -- falta (el nivel de su fila "Herramienta:"), no al principio de la ruta
  local toolAt = {}
  for _, tl in ipairs(plan.tools) do
    for i, st in ipairs(plan.steps) do
      if tl.skill < st.to then toolAt[tl.item] = i break end
    end
  end
  -- Paso donde va cada uno y cuántos fabricados hay entre él y ese paso (depth)
  local placed = {}
  local function Place(c, seen)
    if placed[c.itemID] then return placed[c.itemID] end
    seen = seen or {}
    seen[c.itemID] = true
    local at, depth = direct[c.itemID] or toolAt[c.itemID], 0
    if not at then
      for _, c2 in ipairs(plan.crafted) do
        if not seen[c2.itemID] and c2.recipe then
          for _, rq in ipairs(c2.recipe.r or {}) do
            if rq[1] == c.itemID then
              local p = Place(c2, seen)
              if not at or p.at < at then at, depth = p.at, p.depth + 1 end
            end
          end
        end
      end
    end
    placed[c.itemID] = { at = at or 1, depth = depth }
    return placed[c.itemID]
  end
  for _, c in ipairs(plan.crafted) do
    local p = Place(c)
    craftBefore[p.at] = craftBefore[p.at] or {}
    table.insert(craftBefore[p.at], c)
  end
  -- En el mismo paso, primero lo que usan los otros (el cuero antes que la túnica)
  for _, list in pairs(craftBefore) do
    table.sort(list, function(a, b) return placed[a.itemID].depth > placed[b.itemID].depth end)
  end
  local events = {}
  for _, rk in ipairs(plan.ranks) do events[#events + 1] = { skill = rk.skill, rank = rk } end
  for _, tl in ipairs(plan.tools) do events[#events + 1] = { skill = tl.skill, tool = tl } end
  table.sort(events, function(a, b) return a.skill < b.skill end)

  local ev = 1
  local function AddEvent(e)
    if e.rank then
      local rk = e.rank
      local rankName = RANK_NAMES[rk.cap] or (L["rango "] .. rk.cap)
      -- En las secundarias, Experto es un libro del vendedor (y Artesano, una misión)
      local secondary = (page.profKey == "Cooking" or page.profKey == "FirstAid") and rk.cap > 150
      local book = secondary and WP.RANK_BOOKS[page.profKey] and WP.RANK_BOOKS[page.profKey][rk.cap]
      local where = secondary and (rk.cap > 225 and L["Misión"] or L["Libro del vendedor"]) or L["Instructor"]
      local pick, label
      if book then
        pick, label = WP.Target("vendor", book), L["Vendedor más cercano"]
      elseif not secondary then
        pick, label = WP.Target("trainer", page.profKey, rk.cap), L["Instructor más cercano"]
      end
      local line = {
        level = tostring(rk.skill),
        icon = profIcon, -- como en el instructor: el rango lleva el icono de la profesión
        title = string.format(L["Entrenar %s %s(%s)|r"], rankName, GREY, profName),
        sub = string.format(L["%s · sube el tope a %d%s"], where, rk.cap,
          (rk.level or 0) > 0 and string.format(L[" · pide nivel %d"], rk.level) or ""),
        value = Signed(rk.fee), go = pick,
      }
      if pick then
        line.tooltip = TravelTooltip(string.format(L["Entrenar %s (%s)"], rankName, profName),
          string.format(L["Sube el tope de %s a %d."], profName, rk.cap), label, pick)
      end
      lines[#lines + 1] = line
    else
      local tl = e.tool
      local name, texture = ItemLabel(tl.item, L["Herramienta "] .. tl.item)
      lines[#lines + 1] = {
        level = tostring(tl.skill),
        icon = texture or 134400, title = L["Herramienta: "] .. name,
        sub = L["Se consigue una vez y no se gasta"],
        value = Signed(tl.cost), item = tl.item,
        tooltip = SimpleTooltip(tl.item, L["Los siguientes pasos la necesitan. Sus materiales están en la lista de compra."]),
      }
    end
  end
  for i, st in ipairs(plan.steps) do
    while events[ev] and events[ev].skill <= st.from do AddEvent(events[ev]) ev = ev + 1 end
    -- Ruta fijada: los pasos que ya has pasado se marcan hechos (sin fila de aprender)
    local done = locked and st.to <= (page.from or 0)
    -- Ruta empezada: tu nivel cae en el tramo de este paso
    local inStep = locked and not done and (page.from or 0) >= st.from and (page.from or 0) < st.to
    -- Lo que hay que fabricar antes: en el paso actual, la primera que te falta es
    -- el paso en el que estás (antes que aprender la receta o fabricarla)
    local prepPending = false
    for _, c in ipairs(craftBefore[i] or {}) do
      local name, texture = ItemLabel(c.itemID, L["Objeto "] .. c.itemID)
      local conversion = c.recipe and c.recipe.conversion
      -- Clic: como en los pasos, abre su receta y fabrica lo que falta (3 restos -> 1 cuero)
      local outQty = c.recipe and c.recipe.out and c.recipe.out[2] or 1
      local missing = math.max(0, c.quantity - ES:ItemCount(c.itemID))
      local crafts = math.ceil(missing / outQty - 0.001)
      local recipeID = c.recipe and c.recipe.id
      local craftNow = not conversion and recipeID and crafts > 0 and ES:IsRecipeKnown(recipeID) and ES:AutoCraft()
      local current = inStep and not prepPending and missing > 0
      if current then prepPending = true end
      -- Obligatorio: no se puede comprar hecho (se liga al recogerlo, o no está en la
      -- AH ni en ningún vendedor). Sin ✕: no hay otra forma de tenerlo
      local isTool = toolAt[c.itemID] ~= nil
      local buyable = not (c.recipe and c.recipe.bop)
        and (ES.Data.VendorPrices[c.itemID] or (plan.ctx and plan.ctx.ladders[c.itemID])) ~= nil
      local mandatory = not buyable
      local why = mandatory and (isTool and L["Herramienta para los pasos siguientes: no se puede comprar, hay que fabricarla"]
        or L["Hace falta para los pasos siguientes y no se puede comprar: hay que fabricarlo"])
      local title, sub = string.format("%s %d× %s", L["Fabrica"], c.quantity, name),
        why or (isTool and L["Herramienta para los pasos siguientes: sale más barato que comprarla"]
          or L["Para los pasos siguientes: sale más barato que comprarlo"])
      if conversion then
        -- Esencias: se convierten con clic derecho sobre las de origen (1 Greater Magic
        -- Essence -> 3 Lesser, o 3 Lesser -> 1 Greater). Se dice cuáles, cuántas
        -- veces y, si aún no las tienes, que se compran antes (lista de la compra)
        local fromID, per = c.recipe.r[1][1], c.recipe.r[1][2]
        local uses = math.ceil((missing > 0 and missing or c.quantity) / outQty - 0.001)
        local fromName = ItemLabel(fromID, L["Objeto "] .. fromID)
        title = string.format(L["Convierte %d %s en %d %s"], uses * per, fromName, uses * outQty, name)
        sub = string.format(L["Clic derecho en las %s de tus bolsas (%d veces)"], ES:DataItemName(fromID) or fromName, uses)
        if missing > 0 and ES:ItemCount(fromID) < uses * per then
          sub = sub .. ORANGE .. L[" · primero cómpralas (lista de la compra)"] .. "|r"
        end
      end
      lines[#lines + 1] = {
        level = tostring(st.from),
        icon = texture or 134400,
        title = title,
        sub = sub,
        item = c.itemID, current = current,
        craftCount = craftNow and crafts or nil, -- (para pruebas)
        onClick = not conversion and recipeID and function()
          if craftNow then ES:CraftRecipe(recipeID, crafts) else ES:OpenRecipe(recipeID) end
        end or nil,
        -- ✕: no fabricarlo, comprarlo hecho (se recupera con "Recetas quitadas")
        onSkip = not conversion and not mandatory and SkipCraft(c.itemID) or nil,
        skipTip = L["No fabricarlo: la ruta lo compra hecho en la AH (sin comprar sus materiales). Se recupera con la fila de recetas quitadas."],
        tooltip = function(row)
          SimpleTooltip(c.itemID, L["Sale más barato fabricarlo que comprarlo; sus materiales ya están en la lista de compra."])(row)
          if not conversion and recipeID then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(craftNow and string.format(L["Clic: abrir la receta y fabricar %d (como mucho, las que te dan los materiales que llevas)."], crafts)
              or L["Clic: abrir la receta en tu profesión."], 0.5, 0.8, 1, true)
            GameTooltip:Show()
          end
        end,
      }
    end
    local r = st.recipe
    local name, texture = ItemLabel(r.out and r.out[1] or 0, r.name)
    -- Aprender la receta: fila propia (como en el instructor), con su coste
    -- Ya la sabes ("known"): sin fila de aprender
    local learnSource = not done and st.learnSource ~= "known" and st.learnSource or nil
    local learnLines = #lines -- (para marcar la fila de aprender si ya la sabes)
    -- Precio y nivel del instructor: lo visto en el juego, si no, los datos
    local fee, train = ES.Planner.Fee(r)
    local sourcedLine = learnSource and learnSource ~= "favor" and r.scroll and not fee and WP.SOURCED_PROFESSIONS[page.profKey]
      and SourcedLearnLine(r, st, profName, plan)
    if learnSource == "favor" then
      -- Merchant's Favor: en el campamento de tu bando, con fichas (no oro)
      local title = L["Conseguir receta: "] .. r.name
      local pick = WP.Target("vendor", r.scroll)
      local sub = string.format(L["Merchant's Favor: %d fichas"], r.favor)
        .. (r.favorRep and (" · " .. string.format(L["pide %s con el campamento"], ES.StandingName(r.favorRep))) or "")
      lines[#lines + 1] = {
        level = tostring(st.from), -- cuándo toca en la ruta (la columna va en orden)
        icon = "Interface\\Icons\\INV_Misc_Coin_17", title = title, sub = sub,
        value = string.format("|cff66bbff%d|r", r.favor), go = pick, onSkip = Skip(st.id),
        tooltip = TravelTooltip(title, sub, L["Vendedor más cercano"], pick),
      }
    elseif sourcedLine then
      sourcedLine.onSkip = Skip(st.id)
      sourcedLine.level = tostring(st.from) -- cuándo toca en la ruta (la columna va en orden)
      lines[#lines + 1] = sourcedLine
    elseif learnSource then
      local trainer = st.learnSource == "trainer"
      local learnAt = train or st.from
      -- Al pulsar: el instructor que enseña hasta ese nivel, o quien vende la receta
      local pick, label
      if trainer then
        pick, label = WP.Target("trainer", page.profKey, learnAt + 1), L["Instructor más cercano"]
      elseif r.scroll then
        pick, label = WP.Target("vendor", r.scroll), L["Vendedor más cercano"]
      end
      local title = string.format("%s %s", trainer and L["Entrenar"] or L["Comprar receta:"], r.name)
      lines[#lines + 1] = {
        level = tostring(st.from), -- cuándo toca en la ruta (se puede aprender desde learnAt)
        icon = trainer and TRAIN_ICON or RECIPE_ICON,
        title = title,
        sub = LEARN_WHERE[st.learnSource] or "?",
        -- "?": fuente desconocida, o instructor de una receta nueva de Forever (precio sin datos)
        value = (st.learnSource == "unknown" or (r.trainer and not fee)) and (GREY .. "?|r") or Signed(st.fee),
        go = pick, onSkip = Skip(st.id),
        tooltip = pick and TravelTooltip(title, string.format(L["%s · requiere %s (%d) · cuesta %s"], LEARN_WHERE[st.learnSource] or "?",
          profName, learnAt, (r.trainer and not fee) and L["precio desconocido"] or ES.Money(st.fee)), label, pick) or nil,
      }
    end
    local learnPending = false
    if locked and #lines > learnLines then
      local line = lines[#lines]
      if ES:IsRecipeKnown(st.id) then
        -- Ya aprendida (en el instructor, de pergamino...): la fila de aprender queda
        -- hecha, como los pasos acabados (✓ y en gris)
        local function Plain(s) return (tostring(s or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end
        line.title = ES.Market.ICON_OK .. GREY .. Plain(line.title) .. "|r"
        line.sub = GREY .. L["Aprendida"] .. "|r"
        line.value = line.value and (GREY .. Plain(line.value) .. "|r") or nil
        line.done, line.onSkip, line.go = true, nil, nil
      elseif inStep then
        -- Aún no la sabes y ya toca: el paso actual es aprenderla, no fabricarla
        -- (salvo que antes falte fabricar algún material: entonces es ese)
        line.current, learnPending = not prepPending, true
      end
    end
    local perPoint = st.expected / (st.to - st.from)
    -- Lo que falta de este paso desde tu nivel (con la ruta empezada puedes ir por la mitad)
    local level = math.max(st.from, math.min(st.to, page.from or st.from))
    local left = math.ceil(st.expected * (st.to - level) / (st.to - st.from) - 0.001)
    -- El paso en el que estás (si antes hay que aprender la receta, es esa fila)
    local current = inStep and not learnPending and not prepPending
    -- Clic: abre la receta y, con la opción "Fabricar al pulsar" (por defecto), fabrica lo que falta
    local craftNow = not done and left > 0 and ES:IsRecipeKnown(st.id) and ES:AutoCraft()
    local tooltip = RecipeTooltip(st, plan)
    lines[#lines + 1] = {
      onClick = function()
        if craftNow then ES:CraftRecipe(st.id, left) else ES:OpenRecipe(st.id) end
      end,
      craftCount = craftNow and left or nil, -- (para pruebas)
      level = st.from .. "–" .. st.to, -- columna de nivel: el tramo
      done = done, current = current,
      icon = texture or 134400,
      -- Hecho: icono de "listo" (la fuente no tiene ✓) y el nombre en gris (sin el color de calidad)
      title = done and (ES.Market.ICON_OK .. GREY .. name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") .. "|r") or name,
      sub = done and (GREY .. L["Hecho"] .. "|r")
        -- Lo que llevas se mide en puntos (tu nivel), no en fabricaciones de esta
        -- receta: los puntos que te dé otra (Bolt of Woolen Cloth) también cuentan
        or current and string.format(L["%d/%d puntos · ~%s%d|r fabricaciones más · %s/u"], level - st.from, st.to - st.from,
          GOLD, left, ES.Money(st.unitCost))
        or string.format(L["%s%d fabricaciones|r · %s/u"], perPoint > LOW_CHANCE_CRAFTS and ORANGE or "",
        st.crafts, ES.Money(st.unitCost))
        -- La segunda mejor receta y por qué es peor (si ya está calculada)
        .. (AltSummary(plan, i, page.data) and ("  " .. AltSummary(plan, i, page.data)) or ""),
      value = Signed(st.total - st.fee), item = r.out and r.out[1], -- lo de aprender va en su fila
      onSkip = not done and Skip(st.id) or nil,
      tooltip = function(row)
        tooltip(row)
        AddAltTooltip(plan, i, page.data)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(craftNow and string.format(L["Clic: abrir la receta y fabricar %d (como mucho, las que te dan los materiales que llevas)."], left)
          or L["Clic: abrir la receta en tu profesión."], 0.5, 0.8, 1, true)
        GameTooltip:Show()
      end,
    }
  end
  while events[ev] do AddEvent(events[ev]) ev = ev + 1 end
  if plan.stoppedAt then
    lines[#lines + 1] = { title = ORANGE .. L["El plan se queda en "] .. plan.stoppedAt .. "|r", sub = StopReason(plan) }
  end
  -- Recetas quitadas con la ✕: clic para volver a ponerlas todas
  local excluded = {}
  for id in pairs(settings.excluded or {}) do
    local r = page.data.recipes[id]
    if r then excluded[#excluded + 1] = r.name end
  end
  -- Y los materiales que no quieres fabricar (se compran hechos)
  for itemID in pairs(settings.noCraft or {}) do
    excluded[#excluded + 1] = string.format(L["Fabricar %s (se compra hecho)"], (ItemLabel(itemID, L["Objeto "] .. itemID)))
  end
  -- Y los avisos "Con lo que llevas" descartados con su ✕ (no cambian la ruta)
  local onlyNotes = #excluded == 0
  for id in pairs(settings.dismissedNotes or {}) do
    local r = page.data.recipes[id]
    if r then excluded[#excluded + 1] = string.format(L["Aviso: %s con lo que llevas"], r.name) end
  end
  -- Con "usar lo de las bolsas": receta que podrías hacer con lo que llevas y la ruta no
  -- usa (las de avisos descartados, no: se mira la siguiente)
  if settings.useBags then
    local skip = {}
    for id in pairs(settings.excluded or {}) do skip[id] = true end
    for id in pairs(settings.dismissedNotes or {}) do skip[id] = true end
    local alt = ES.Planner.BagsAlternative(page.data, plan, ES:GetOwnedReagents(page.data), page.from, skip)
    local quote = alt and BagsLine(alt, locked)
    if quote then
      -- ✕: no volver a avisar de esta receta (solo informa: la ruta no cambia)
      quote.onSkip = function()
        settings.dismissedNotes = settings.dismissedNotes or {}
        settings.dismissedNotes[alt.id] = true
        ES:RenderPlan(page)
      end
      quote.skipTip = L["No volver a avisar de esta receta. Es solo un aviso: la ruta no cambia. Se recupera con la fila de recetas quitadas."]
      lines[#lines + 1] = quote
    end
  end
  if #excluded > 0 then
    table.sort(excluded)
    lines[#lines + 1] = {
      icon = "Interface\\Buttons\\UI-RefreshButton", iconSize = 16, -- textura de 16 px: más grande se pixela
      -- Solo avisos descartados: la ruta es la misma, el título no dice que se quitó nada
      title = string.format(onlyNotes and L["Avisos ocultos: %d"] or L["Recetas quitadas de la ruta: %d"], #excluded),
      sub = L["Clic para volver a tenerlas en cuenta"],
      onClick = function()
        settings.excluded, settings.noCraft, settings.dismissedNotes = nil, nil, nil
        -- Solo avisos descartados: la ruta no cambia, basta con repintar
        if onlyNotes then ES:RenderPlan(page) return end
        ES:StopRoute(page.profKey)
        ES:CalculatePlan(page)
      end,
      tooltip = function(row)
        GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Quitadas de la ruta"])
        for _, name in ipairs(excluded) do GameTooltip:AddLine(name, 0.8, 0.8, 0.8) end
        GameTooltip:AddLine(L["Clic para volver a tenerlas en cuenta"], 0.5, 0.8, 1)
        GameTooltip:Show()
      end,
    }
  end
  lines[#lines + 1] = { total = true, title = L["Total"], sub = string.format(L["Subir de %d a %d"], plan.from, plan.reached), value = Signed(plan.net) }
  return lines
end

-- Clic de una fila de la vista Profit: con el vendedor abierto vende lo que toca
-- vender; con la AH abierta anuncia lo que toca anunciar; si no, marca el
-- subastador o el vendedor más cercano. Devuelve onClick, go, etiqueta del botón.
local ACTION = "|cff80c0ff"
local function SaleAction(d, advice, page)
  local Ledger = ES.Ledger
  if not Ledger then return nil end
  local have = Ledger.BagCount(d.itemID)
  local toVendor, toAH = math.min(have, advice.vendor), math.min(have, advice.ah)
  local function Done() ES:RenderPlan(page) end
  if Ledger:MerchantOpen() and toVendor > 0 then
    return function() Ledger:SellToVendor(d.itemID, toVendor) C_Timer.After(0.5, Done) end, nil,
      string.format(L["Vender %d al vendedor"], toVendor)
  elseif ES:IsAuctionHouseOpen() and toAH > 0 then
    -- Las que diga la ruta, como mucho las que llevas; a platas enteras (la AH de Forever)
    local price = Ledger.PostPrice(advice.price)
    return function() Ledger:PostOnAH(d.itemID, toAH, price) C_Timer.After(0.5, Done) end, nil,
      string.format(L["Anunciar %d en la AH a %s"], toAH, ES.Money(price))
  elseif ES:IsAuctionHouseOpen() and advice.ah > 0 then
    -- AH abierta pero no llevas ninguno encima (en el banco o aún sin fabricar): el
    -- título ya dice "0 en bolsas", así que sin texto de clic (si pulsas, lo avisa)
    return function() ES:Print(string.format(L["No llevas %s en las bolsas."], ES:DataItemName(d.itemID) or d.itemID)) end, nil, nil
  elseif advice.ah > 0 then
    return nil, WP.Target("auction"), nil
  elseif advice.vendor > 0 then
    return nil, WP.Target("sell"), nil
  end
end

-- Líneas de la vista Profit: qué hacer con todo lo que fabricas
local function ProfitLines(plan, page)
  local lines = {}
  local dests = {}
  for _, d in ipairs(plan.destinations) do dests[#dests + 1] = d end
  table.sort(dests, function(a, b) return a.income + (a.ahExtra or 0) > b.income + (b.ahExtra or 0) end)
  local total, extra = 0, 0
  for _, d in ipairs(dests) do
    local name, texture = ItemLabel(d.itemID, L["Objeto "] .. d.itemID)
    local parts = {} -- cuántas fabricas: en la columna de la izquierda
    if d.keep > 0 then parts[#parts + 1] = GREEN .. L["guarda "] .. d.keep .. L[" para pasos siguientes|r"] end
    local signals = d.sale.ahNet and d.sell > 0 and ES.Market:Signals(d.itemID)
    local advice = ES.Planner.SaleAdvice(d)
    d.advice = advice
    if advice.ah > 0 then
      parts[#parts + 1] = string.format(L["%spon %d en la AH a %s|r (%s)"], GOLD, advice.ah,
        ES.Money(ES.Ledger and ES.Ledger.PostPrice(advice.price) or advice.price), -- platas enteras, como se anuncia
        ES.Market.LABELS[advice.verdict])
    end
    if advice.vendor > 0 then
      parts[#parts + 1] = string.format(L["%s %d al vendedor"], advice.ah > 0 and L["el resto,"] or L["vende"], advice.vendor)
    end
    if advice.unsold > 0 then
      parts[#parts + 1] = GREY .. advice.unsold .. L[" no los compra el vendedor|r"]
    end
    if signals then extra = extra + d.ahExtra end
    total = total + d.income
    local onClick, go, action = SaleAction(d, advice, page)
    if action then table.insert(parts, 1, ACTION .. L["Clic: "] .. action .. "|r") end -- vendedor o AH abiertos
    local tip = DestinationTooltip(d, name, signals)
    -- Cuántos llevas ahora en las bolsas (lo que puedes vender o anunciar ya)
    local have = ES.Ledger and ES.Ledger.BagCount(d.itemID) or 0
    local bags = (have > 0 and "|cffffffff" or GREY) .. string.format(L["%d en bolsas"], have) .. "|r"
    lines[#lines + 1] = {
      level = "×" .. d.produced,
      icon = texture or 134400, title = name .. GREY .. " · |r" .. bags,
      sub = table.concat(parts, " · "),
      value = d.income > 0 and Signed(-d.income) or (GREY .. "—|r"), item = d.itemID,
      onClick = onClick, go = go,
      tooltip = function(row)
        tip(row)
        if action then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(L["Clic: "] .. action .. ".", 0.5, 0.8, 1)
        elseif go then
          WP.AddToTooltip(advice.ah > 0 and L["Subastador más cercano"] or L["Vendedor más cercano"], go)
        end
        GameTooltip:Show()
      end,
    }
  end
  if #lines == 0 then return lines end
  lines[#lines + 1] = {
    total = true, title = L["Recuperas vendiendo al vendedor"],
    sub = extra > 0 and string.format(L["Vendiendo en la AH podrías sacar hasta %s más (sin garantía de venta)"], ES.Money(extra)) or L["Lo que no se guarda para pasos siguientes"],
    value = Signed(-total),
  }
  return lines
end

-- Líneas de la vista Lista de compra
local function ShopLines(plan, page)
  local lines = {}
  local total = 0
  local function Section(title, items, build)
    if #items == 0 then return end
    lines[#lines + 1] = { section = title }
    for _, it in ipairs(items) do lines[#lines + 1] = build(it) end
  end
  local ah, vendor = {}, {}
  -- Lo que la ruta gasta de cada material desde tu nivel actual (compras + lo que
  -- usa de tus bolsas) frente a lo que llevas: cuántos tienes y cuántos faltan. Se
  -- actualiza al comprar, sacar del correo o fabricar (BAG_UPDATE_DELAYED, HomeUI.lua)
  for _, it in ipairs(plan.shopping) do
    if it.source == "ah" then ah[#ah + 1] = it else vendor[#vendor + 1] = it end
    total = total + it.total
  end
  local need = ES.Planner.NeedFrom(plan, math.max(plan.from, page.from or plan.from))
  -- Lo que tienes: solo las bolsas (ni banco ni correo)
  local function Progress(itemID)
    local have = ES:ItemCount(itemID)
    local n = math.ceil((need[itemID] or 0) - 0.001)
    if n <= 0 then return GREEN .. L["Ya no hace falta"] .. "|r" end
    if have >= n then return GREEN .. string.format(L["Tienes %d/%d"], have, n) .. "|r" end
    return string.format(L["Tienes %d/%d · faltan %s%d|r"], have, n, ORANGE, n - have)
  end
  local function Buy(it)
    local name, texture = ItemLabel(it.itemID, L["Objeto "] .. it.itemID)
    local sub = it.source == "ah"
      and string.format("AH · %s/u%s", ES.Money(it.unit), it.supply and string.format(L[" · hay %d a la venta"], it.supply) or "")
      or string.format(L["Vendedor · %s/u"], ES.Money(it.unit))
    sub = Progress(it.itemID) .. " · " .. sub
    -- Clic: con la AH abierta, la busca; con el vendedor abierto, compra lo que falta
    -- (si lo vende); si no, marca el subastador o el vendedor más cercano
    local action, onClick
    local vendorEntry
    if it.source == "vendor" and ES.Ledger and ES.Ledger:MerchantOpen() and ES.VendorShop then
      for _, e in ipairs(ES.VendorShop:List()) do if e.itemID == it.itemID then vendorEntry = e end end
    end
    if it.source == "ah" and ES:IsAuctionHouseOpen() then
      -- Abre la compra con lo que falta ya puesto (solo queda "Comprar ahora" de Blizzard)
      local missing = math.ceil((need[it.itemID] or it.quantity) - 0.001) - ES:ItemCount(it.itemID)
      if missing > 0 then
        action = string.format(L["abrir la compra de %d en la AH"], missing)
        onClick = function() ES:OpenAuctionBuy(it.itemID, missing) end
      else
        action, onClick = L["buscarlo en la AH"], function() ES:SearchAuction(it.itemID) end
      end
    elseif vendorEntry then
      action = string.format(L["comprar %d a este vendedor"], vendorEntry.qty)
      onClick = function() ES.VendorShop:Buy(vendorEntry) end
    end
    if action then sub = ACTION .. L["Clic: "] .. action .. "|r · " .. sub end
    local go = not onClick and WP.Target(it.source == "ah" and "auction" or "vendor", it.itemID) or nil
    local tip = ShopTooltip(it, plan)
    return { level = "×" .. it.quantity, icon = texture or 134400, title = name, sub = sub, value = Signed(it.total),
      item = it.itemID, onClick = onClick, go = go,
      tooltip = function(row)
        tip(row)
        if action then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(L["Clic: "] .. action .. ".", 0.5, 0.8, 1)
        else
          WP.AddToTooltip(it.source == "ah" and L["Subastador más cercano"] or L["Vendedor más cercano"], go)
        end
        GameTooltip:Show()
      end }
  end
  -- Ruta empezada: las secciones salen de lo que llevas AHORA (lo que gastas o
  -- compras mueve cada material de "comprar" a "ya lo tienes" y al revés), no de lo
  -- que llevabas al empezarla; los totales de la ruta siguen congelados
  if ES:RouteLock(page.profKey) then
    local shopping = {}
    for _, it in ipairs(plan.shopping) do shopping[it.itemID] = it end
    local buyAH, buyVendor, haveAll, left = {}, {}, {}, 0
    local ids = {}
    for itemID in pairs(need) do ids[#ids + 1] = itemID end
    table.sort(ids)
    for _, itemID in ipairs(ids) do
      local n = math.ceil(need[itemID] - 0.001)
      if n > 0 then
        local missing = n - ES:ItemCount(itemID)
        if missing > 0 then
          local planned = shopping[itemID]
          local vendorPrice = ES.Data.VendorPrices and ES.Data.VendorPrices[itemID]
          local source = planned and planned.source or (vendorPrice and "vendor" or "ah")
          local ahEntry = plan.ctx and plan.ctx.prices[itemID]
          local unit = planned and planned.unit or vendorPrice or (ahEntry and ahEntry.minUnit) or 0
          local it = { itemID = itemID, quantity = missing, source = source, unit = unit, total = unit * missing,
            supply = planned and planned.supply or (ahEntry and ahEntry.quantity) }
          left = left + it.total
          if source == "ah" then buyAH[#buyAH + 1] = it else buyVendor[#buyVendor + 1] = it end
        else
          haveAll[#haveAll + 1] = { itemID = itemID, quantity = n }
        end
      end
    end
    Section(L["Comprar en la Casa de Subastas"], buyAH, Buy)
    Section(L["Comprar al vendedor"], buyVendor, Buy)
    Section(L["Ya lo tienes"], haveAll, function(it)
      local name, texture = ItemLabel(it.itemID, L["Objeto "] .. it.itemID)
      return { level = "×" .. it.quantity, icon = texture or 134400, title = name, sub = Progress(it.itemID),
        item = it.itemID, tooltip = SimpleTooltip(it.itemID, L["Ya tienes lo que te hace falta para lo que queda de ruta."]) }
    end)
    lines[#lines + 1] = { total = true, title = L["Te falta por comprar"],
      sub = L["Lo que te falta para lo que queda de ruta, con lo que llevas ahora"], value = Signed(left) }
    return lines
  end

  Section(L["Comprar en la Casa de Subastas"], ah, Buy)
  Section(L["Comprar al vendedor"], vendor, Buy)
  -- Lo que también se compra ya dice arriba cuántos tienes y cuántos faltan: aquí
  -- solo que esa parte sale de tus bolsas (sin repetir el recuento)
  local alsoBought = {}
  for _, it in ipairs(plan.shopping) do alsoBought[it.itemID] = true end
  Section(L["Usar de tus bolsas"], plan.owned, function(it)
    local name, texture = ItemLabel(it.itemID, L["Objeto "] .. it.itemID)
    local sub = alsoBought[it.itemID] and L["Lo que tienes se usa primero; el resto se compra (arriba)"]
      or (Progress(it.itemID) .. " · " .. L["Ya lo tienes: se usa antes de comprar"])
    return { level = "×" .. it.quantity, icon = texture or 134400, title = name, sub = sub,
      item = it.itemID, tooltip = SimpleTooltip(it.itemID, L["Ya lo tienes: el plan lo usa antes de comprar nada."]) }
  end)
  if #plan.shopping > 0 then
    lines[#lines + 1] = { total = true, title = L["Total de la compra"], sub = L["Materiales y herramientas a comprar"], value = Signed(total) }
  end
  return lines
end

function ES:RenderPlan(page)
  local plan = page.plan

  -- Calculando la primera ruta: nada que enseñar aún
  local stats = page.stats
  if page.calculating and not plan then
    for _, fs in pairs(stats) do fs:SetText(GREY .. "—|r") end
    page.status:SetText(GREY .. L["Calculando la ruta…"] .. "|r")
    page.lines = {}
    page.empty:SetText("")
    ES.UI.RenderLines(page, page.lines)
    return
  end

  -- Franja de resumen
  if plan and #plan.steps > 0 then
    stats.materials:SetText(Signed(plan.reagentCost))
    stats.profit:SetText(Signed(-plan.resale))
    stats.fees:SetText(Signed(plan.fees + plan.toolsCost))
    stats.total:SetText(Signed(plan.net))
  else
    for _, fs in pairs(stats) do fs:SetText(GREY .. "—|r") end
  end

  local status
  if not plan then
    status = GREEN .. L["Ya estás en el objetivo. Sube el objetivo para ver la ruta.|r"]
  elseif #plan.steps == 0 then
    status = ORANGE .. L["No se puede subir desde "] .. plan.from .. ": " .. StopReason(plan) .. ".|r"
  elseif plan.stoppedAt then
    status = ORANGE .. L["Con recetas de instructor el plan llega hasta "] .. plan.stoppedAt .. ": " .. StopReason(plan) .. ".|r"
  elseif not plan.scanTime then
    status = ORANGE .. L["Sin escaneo de la AH: solo precios de vendedor. Escanea para un coste real.|r"]
  else
    status = GREY .. string.format(L["Precios de la AH de hace %d min · lo fabricado se cuenta vendido al vendedor"],
      math.floor((time() - plan.scanTime) / 60)) .. "|r"
  end
  -- Ruta con coste simbólico por fabricación: cuánto ahorra frente a la más barata
  if plan and plan.cheapest then
    local saved = plan.cheapest.crafts - self.Planner.TotalCrafts(plan)
    local extra = plan.net - plan.cheapest.net
    status = status .. GREY .. string.format(L[" · %d fabricaciones menos que la ruta más barata%s|r"], saved,
      extra >= 0.5 and (L[", por "] .. ES.Money(extra) .. L[" más"]) or "")
  end
  -- Ruta fijada: lo que compras no la cambia; un escaneo nuevo solo avisa
  local lock = self:RouteLock(page.profKey)
  local newPrices = false
  if lock and plan then
    local scan = self.db.scans and self.db.scans[self:RealmKey()]
    status = GREEN .. (lock.completed
      and string.format(L["¡Ruta completada! (de %d a %d) · pulsa Recalcular ruta para empezar otra"], lock.from, lock.to)
      or string.format(L["Ruta en curso (de %d a %d): lo que compras no cambia la ruta ni su coste"], lock.from, lock.to)) .. "|r"
    if scan and scan.time ~= lock.scanTime then
      newPrices = true
      status = status .. ORANGE .. L[" · hay precios nuevos de la AH|r"]
    end
  elseif plan and #plan.steps > 0 and not page.calculating and self.db.prof[page.profKey].useBags then
    status = status .. GREY .. L[" · pulsa Empezar ruta antes de comprar|r"]
  end
  page.routeButton:SetText(lock and L["Recalcular ruta"] or L["Empezar ruta"])
  page.pricesButton:SetText(L["Actualizar precios"])
  page.pricesButton:SetShown(newPrices)
  page.status:SetPoint("RIGHT", newPrices and page.pricesButton or page.routeButton, "LEFT", -10, 0)
  page.routeButton:SetEnabled(lock ~= nil or (plan ~= nil and #plan.steps > 0 and not page.calculating))
  -- Recalculando: se ve la ruta anterior hasta que esté la nueva
  if page.calculating then status = GREY .. L["Calculando la ruta…"] .. "|r" end
  page.status:SetText(status)

  local lines = {}
  if plan and #plan.steps > 0 then
    if page.view == "profit" then lines = ProfitLines(plan, page)
    elseif page.view == "shop" then lines = ShopLines(plan, page)
    else lines = RouteLines(plan, page) end
  end
  page.lines = lines
  page.empty:SetText(#lines == 0 and (plan and #plan.steps > 0 and L["Nada que mostrar en esta vista."] or "") or "")

  ES.UI.RenderLines(page, lines)
  -- Segunda mejor receta de cada paso: se calcula después, sin trabar (y se repinta)
  if plan and #plan.steps > 0 and not page.calculating then self:ComputeAlternatives(page, plan) end
end

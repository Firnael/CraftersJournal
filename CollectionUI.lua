local _, ES = ...
local L = ES.L

-- Colección de una profesión (Collection.lua), al estilo del diario de mazmorras:
--   cabecera: barra de recetas conseguidas (como la de nivel del libro de profesiones) y botón Filtros
--   izquierda: todas las recetas; las que ya tienes, en verde apagado con su check
--   derecha:   la ficha de la receta pulsada (dónde se consigue, precios, materiales)
-- La palabra "Receta" va del color de la calidad del pergamino (blanco, verde, azul...).
-- Sin barras de desplazamiento: la lista y la ficha se mueven con la rueda del ratón.

local GREEN, GREY, ORANGE, GOLD, WHITE = "|cff40ff40", "|cff9d9d9d", "|cffff9933", "|cffffd100", "|cffffffff"
-- Filas como las del instructor de Forever: icono grande con marco, nombre dorado,
-- de dónde sale en blanco pequeño debajo y el nivel arriba a la derecha
local ROW_H, ROW_GAP, LIST_W = 48, 3, 372
local ROW_ICON = 36
local SCROLL_W = 5                   -- indicador de desplazamiento a la derecha de la lista
local ROW_W = LIST_W - 12 - SCROLL_W - 5 -- filas: dejan sitio al indicador
local ROW_STEP = ROW_H + ROW_GAP
local LINE_H = 18
local MATERIAL_ICON = 24

local function WheelScroll(parent, step) return ES.UI.WheelScroll(parent, step) end -- ProfessionUI.lua
local CHECK = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14|t"
local QUEST = "|cffffd200"

-- Icono de una fila o de la ficha (el de misión va con el atlas en alta resolución)
local function SetIcon(tex, icon)
  if icon == ES.QUEST_ICON then ES.SetQuestIcon(tex) else tex:SetTexture(icon) end
end
local FAVOR, FAVOR_ICON = "|cff66c8ff", "|TInterface\\Icons\\INV_Misc_Coin_17:13|t"
local RED = "|cffff4040"

-- "Honorable Alba Argenta (Amistoso)": la reputación que pide y, entre paréntesis,
-- la tuya en verde si la cumples o en rojo si no
local function RepShort(rep)
  local have = (ES:Standing(rep[1]))
  return string.format("%s %s (%s%s|r)", ES.StandingName(rep[2]), ES:FactionName(rep[1]),
    have >= rep[2] and GREEN or RED, ES.StandingName(have))
end

-- Qué recetas mostrar (casillas, todas marcadas por defecto): cada receta está en
-- uno de estos tres estados
local SHOW = ES.Localize({
  { key = "known",   label = "Aprendidas" },
  { key = "now",     label = "Puedo aprender ya" },
  { key = "missing", label = "Me faltan" },
}, "label")
local function State(e)
  return e.known and "known" or e.learnableNow and "now" or "missing"
end
local SORTS = ES.Localize({
  { key = "level",    label = "Nivel" },
  { key = "scroll",   label = "Precio del pergamino" },
  { key = "profit",   label = "Beneficio" },
  { key = "cheapest", label = "Más barata de conseguir" },
}, "label")

local function QualityHex(q)
  local c = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q or 1]
  return c and c.hex or WHITE
end

-- "Receta" del color de la calidad del pergamino (las de instructor no tienen pergamino)
local function RecipeWord(r)
  return QualityHex(r.sq) .. L["Receta"] .. "|r"
end

-- Criaturas de un botín agrupadas por zona: { { name = zona, npcs = { id... } } },
-- la zona con más criaturas primero
local function DropZones(ids)
  local WP = ES.Waypoints
  local byName, zones = {}, {}
  for _, id in ipairs(ids) do
    local npc = WP.NPC(id)
    if npc then
      local zone = WP.ZoneName(npc)
      if not byName[zone] then
        byName[zone] = { name = zone, npcs = {} }
        zones[#zones + 1] = byName[zone]
      end
      table.insert(byName[zone].npcs, id)
    end
  end
  table.sort(zones, function(a, b)
    if #a.npcs ~= #b.npcs then return #a.npcs > #b.npcs end
    return a.name < b.name
  end)
  return zones
end

-- De dónde sale, en una línea: "Instructor", "Receta · Botín: Kobold Geomancer · Elwynn"...
local function Where(e, s, short)
  local WP = ES.Waypoints
  s = s or e.mainSource
  if not s then return L["Fuente desconocida"] end
  if s.kind == "trainer" then return L["Instructor"] .. (s.cost and s.cost > 0 and (" · " .. ES.Money(s.cost)) or "") end
  if s.kind == "basic" then return L["Se aprende sola al tener la profesión"] end
  if s.kind == "quest" then
    -- En amarillo y con el "!" de misión, para distinguirlas de un vistazo
    return ES.QuestIconMarkup(14) .. " " .. QUEST .. L["Misión: "] .. s.quest.name
      .. (s.quest.level > 0 and string.format(L[" (nivel %d)"], s.quest.level) or "") .. "|r"
  end
  if s.kind == "favor" then
    -- Moneda de los campamentos de Forever: su icono, en azul y lo que cuesta en fichas
    return FAVOR_ICON .. " " .. FAVOR .. string.format(L["Merchant's Favor: %d"], s.favor)
      .. (s.rep and (" · " .. ES.StandingName(s.rep)) or "") .. "|r"
  end
  -- En la fila (short), solo la reputación: el vendedor y dónde está, en la ficha
  if short and (s.kind == "vendor" or s.kind == "rep") and e.recipe.rep then return RepShort(e.recipe.rep) end
  if s.kind == "vendor" or s.kind == "rep" then
    local v = s.vendors and WP.Nearest(WP.Usable(s.vendors))
    local npc = v and WP.NPC(v)
    local text = npc and (L["Vendedor: "] .. npc.name .. " · " .. WP.LocationText(npc))
      or (s.vendors and #s.vendors > 0 and L["Vendedor del otro bando"]) or L["Vendedor"]
    if e.recipe.rep then text = RepShort(e.recipe.rep) .. " · " .. text end
    return text
  end
  if s.kind == "drop" then
    local d = s.drops
    if d.npcs[1] then
      -- Una criatura: "Botín: Kobold Geomancer (12-14) · Bosque de Elwynn"
      if #d.npcs == 1 then
        local npc = WP.NPC(d.npcs[1])
        local lv = WP.NPCLevel(d.npcs[1])
        return L["Botín: "] .. (npc and (npc.name .. (lv and (" (" .. lv .. ")") or "") .. " · " .. WP.ZoneName(npc)) or "?")
      end
      -- Varias: la zona principal y cuántas son (la lista entera, en la ficha)
      local zones = DropZones(d.npcs)
      return string.format(L["Botín: %s · %d criaturas"], zones[1] and zones[1].name or "?", #d.npcs)
        .. (#zones > 1 and string.format(L[" y %d zonas más"], #zones - 1) or "")
    end
    if d.world and d.levels then
      return string.format(L["Botín del mundo · criaturas de nivel %d a %d"], d.levels[1], d.levels[2])
    end
    if d.world then return string.format(L["Botín del mundo (%d criaturas)"], d.world) end
    return string.format(L["En %d cofres u objetos"], d.objects or 0)
  end
  return L["Fuente desconocida"]
end

local function SourceLine(e)
  local text = Where(e, nil, true)
  if e.recipe.scroll then return RecipeWord(e.recipe) .. GREY .. " · |r" .. text end
  return text
end

-- Adónde lleva "marcar en el mapa" para una fuente (nil si no hay a quién ir)
local function GoFor(e, s)
  local WP = ES.Waypoints
  if s.kind == "trainer" then return WP.Target("trainer", e.profKey, e.level) end
  if (s.kind == "vendor" or s.kind == "rep" or (s.kind == "favor" and #s.vendors > 0)) and e.recipe.scroll then
    return WP.Target("vendor", e.recipe.scroll)
  end
  if s.kind == "quest" then return function() return WP.Nearest(s.quest.starters) end end
  if s.kind == "drop" and s.drops.npcs[1] then return function() return WP.Nearest(s.drops.npcs) end end
end

---------------------------------------------------------------------------
-- Filtros (ventana como la del diario de mazmorras)
---------------------------------------------------------------------------
local function Settings()
  -- Filtros de la versión anterior ("Mostrar" de una sola opción): se empieza de cero
  if ES.db.collection and ES.db.collection.show ~= nil then ES.db.collection = nil end
  ES.db.collection = ES.db.collection or {}
  local s = ES.db.collection
  s.hiddenState = s.hiddenState or {} -- estados ocultos (aprendidas, puedo aprender ya, me faltan)
  s.sort = s.sort or "level"
  s.hidden = s.hidden or {} -- fuentes ocultas
  return s
end

-- Filtros que no son los de por defecto (para "Filtros (2)")
local function ActiveFilters(s)
  local n = (s.sort ~= "level" and 1 or 0) + (s.hideBound and 1 or 0)
  for _ in pairs(s.hidden) do n = n + 1 end
  for _ in pairs(s.hiddenState) do n = n + 1 end
  return n
end

local function CreateFilterPopup(frame)
  local Panel, Label = ES.UI.Panel, ES.UI.Label
  local p = Panel(frame, 0.08, 0.06, 0.04, 0.98)
  p:SetSize(300, 380)
  p:SetPoint("TOPRIGHT", frame.filterButton, "BOTTOMRIGHT", 0, -4)
  p:SetFrameStrata("DIALOG")
  p:EnableMouse(true)
  p:Hide()
  local title = Label(p, L["Filtros"], "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 14, -12)
  local close = CreateFrame("Button", nil, p, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -2, -2)
  p.checks = {}
  local y = -40
  local function Header(text)
    local h = Label(p, text, "GameFontNormal")
    h:SetPoint("TOPLEFT", 14, y)
    y = y - 20
  end
  local function Check(text, x, get, set)
    local cb = ES.UI.CheckBox(p, text, function(self) set(self:GetChecked()) ES:RenderCollection(frame) end)
    cb:SetPoint("TOPLEFT", x, y)
    cb.get = get
    p.checks[#p.checks + 1] = cb
    return cb
  end
  Header(L["Mostrar"])
  for i, o in ipairs(SHOW) do
    Check(o.label, 10 + ((i - 1) % 2) * 140, function() return not Settings().hiddenState[o.key] end,
      function(on) Settings().hiddenState[o.key] = not on or nil end)
    if i % 2 == 0 then y = y - 22 end
  end
  if #SHOW % 2 == 1 then y = y - 22 end
  y = y - 6
  Header(L["Fuente"])
  for i, k in ipairs(ES.Collection.SOURCES) do
    Check(ES.Collection.SOURCE_LABEL[k], 10 + ((i - 1) % 2) * 140, function() return not Settings().hidden[k] end,
      function(on) Settings().hidden[k] = not on or nil end)
    if i % 2 == 0 then y = y - 22 end
  end
  if #ES.Collection.SOURCES % 2 == 1 then y = y - 22 end
  y = y - 6
  Header(L["Venta"])
  Check(L["Ocultar las que no se venden en la AH (ligadas)"], 10, function() return Settings().hideBound end,
    function(on) Settings().hideBound = on or nil end)
  y = y - 28
  Header(L["Orden"])
  for i, o in ipairs(SORTS) do
    Check(o.label, 10 + ((i - 1) % 2) * 140, function() return Settings().sort == o.key end,
      function() Settings().sort = o.key end)
    if i % 2 == 0 then y = y - 22 end
  end
  local reset = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  reset:SetSize(110, 22)
  reset:SetPoint("BOTTOMLEFT", 12, 12)
  reset:SetText(L["Restablecer"])
  reset:SetScript("OnClick", function()
    ES.db.collection = nil
    ES:RenderCollection(frame)
  end)
  local ok = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
  ok:SetSize(90, 22)
  ok:SetPoint("BOTTOMRIGHT", -12, 12)
  ok:SetText(L["Aceptar"])
  ok:SetScript("OnClick", function() p:Hide() end)
  function p:Sync()
    for _, cb in ipairs(self.checks) do cb:SetChecked(cb.get() and true or false) end
  end
  return p
end

---------------------------------------------------------------------------
-- Lista (izquierda)
---------------------------------------------------------------------------
local function CreateRow(parent)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetSize(ROW_W, ROW_H)
  row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
  -- Fondo en degradado (más claro arriba), como las filas del instructor
  row.bg = row:CreateTexture(nil, "BACKGROUND", nil, 1)
  row.bg:SetPoint("TOPLEFT", 1, -1)
  row.bg:SetPoint("BOTTOMRIGHT", -1, 1)
  row.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
  -- Icono con marco oscuro de 1 px
  row.iconFrame = row:CreateTexture(nil, "ARTWORK", nil, 1)
  row.iconFrame:SetSize(ROW_ICON + 2, ROW_ICON + 2)
  row.iconFrame:SetPoint("LEFT", 5, 0)
  row.iconFrame:SetColorTexture(0, 0, 0, 0.9)
  row.icon = row:CreateTexture(nil, "ARTWORK", nil, 2)
  row.icon:SetSize(ROW_ICON, ROW_ICON)
  row.icon:SetPoint("CENTER", row.iconFrame)
  row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.title:SetPoint("TOPLEFT", row.iconFrame, "TOPRIGHT", 8, -3)
  row.title:SetPoint("RIGHT", -52, 0)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)
  row.sub = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.sub:SetPoint("BOTTOMLEFT", row.iconFrame, "BOTTOMRIGHT", 8, 3)
  row.sub:SetPoint("RIGHT", -10, 0)
  row.sub:SetJustifyH("LEFT")
  row.sub:SetWordWrap(false)
  row.level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.level:SetPoint("TOPRIGHT", -9, -6)
  row.level:SetJustifyH("RIGHT")
  row:SetScript("OnEnter", function(self) if not self.selected then self:SetBackdropBorderColor(1, 0.82, 0.25, 0.6) end end)
  row:SetScript("OnLeave", function(self) ES.UI.StyleCollectionRow(self) end)
  return row
end

-- Degradado vertical del fondo: `top` arriba, `bottom` abajo ({ r, g, b, a })
local function Gradient(tex, top, bottom)
  if tex.SetGradient and CreateColor then
    tex:SetColorTexture(1, 1, 1, 1)
    tex:SetGradient("VERTICAL", CreateColor(unpack(bottom)), CreateColor(unpack(top)))
  else
    tex:SetColorTexture(unpack(top))
  end
end

-- Colores de la fila: rojizo oscuro con borde dorado apagado, como el instructor;
-- la que tienes, verde apagado; la elegida, borde dorado
local ROW_TOP, ROW_BOTTOM = { 0.32, 0.12, 0.07, 0.95 }, { 0.17, 0.07, 0.04, 0.95 }
local KNOWN_TOP, KNOWN_BOTTOM = { 0.14, 0.30, 0.11, 0.75 }, { 0.07, 0.17, 0.06, 0.75 }
function ES.UI.StyleCollectionRow(row)
  local e = row.entry
  row:SetBackdropColor(0, 0, 0, 0) -- el fondo es el degradado (row.bg)
  if e and e.known then
    Gradient(row.bg, KNOWN_TOP, KNOWN_BOTTOM)
    row:SetBackdropBorderColor(0.30, 0.65, 0.25, 0.8)
  else
    Gradient(row.bg, ROW_TOP, ROW_BOTTOM)
    row:SetBackdropBorderColor(0.62, 0.47, 0.20, 0.9)
  end
  if row.selected then row:SetBackdropBorderColor(1, 0.82, 0.25, 1) end
end

local FillRow

-- Lista virtual: solo existen las filas que caben a la vista (más una); al
-- desplazarse se recolocan y se rellenan con las recetas que tocan
local function PlaceRows(frame)
  local list = frame.list or {}
  local offset = tonumber(frame.scroll:GetVerticalScroll()) or 0
  local first = math.max(1, math.floor(offset / ROW_STEP) + 1)
  local count = math.ceil((tonumber(frame.scroll:GetHeight()) or 0) / ROW_STEP) + 1
  local pending = false
  for k = 1, math.max(count, #frame.rows) do
    local i = first + k - 1
    local row = frame.rows[k]
    if k <= count and list[i] then
      if not row then
        row = CreateRow(frame.content)
        row:SetScript("OnClick", function(self) ES:SelectCollectionEntry(frame, self.entry) end)
        frame.rows[k] = row
      end
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_STEP)
      if FillRow(row, list[i], list[i] == frame.selected) then pending = true end
      row:Show()
    elseif row then
      row.entry = nil
      row:Hide()
    end
  end
  if pending then frame.pendingItems = true end -- se vuelve a pintar al cargarse (ver OnEvent)
end

function FillRow(row, e, selected)
  local _, _, texture = ES:GetItemData(e.itemID or 0)
  row.entry = e
  row.selected = selected
  local icon = texture or ES.Collection.SOURCE_ICON[e.main]
  SetIcon(row.icon, icon)
  -- Recorta el borde de los iconos de objeto (el de misión es un atlas: tal cual)
  if icon ~= ES.QUEST_ICON then row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) end
  row.icon:SetDesaturated(e.known and true or false)
  -- Nombre dorado, como en el instructor; la que ya tienes, en gris
  row.title:SetText(e.known and (GREY .. (e.recipe.name or "?") .. "|r") or (e.recipe.name or "?"))
  row.sub:SetText(SourceLine(e))
  -- Arriba a la derecha (donde el instructor pone el precio): el nivel; aprendida, el check
  row.level:SetText(e.known and CHECK or ((e.learnableNow and ORANGE or WHITE) .. e.level .. "|r"))
  ES.UI.StyleCollectionRow(row)
  return texture == nil and e.itemID ~= nil -- el juego aún no ha cargado el objeto
end

---------------------------------------------------------------------------
-- Barra de progreso como la del nivel en el libro de profesiones: fondo oscuro
-- que se distingue del relleno, relleno cálido, marco y "Peletería 25 / 541" encima
---------------------------------------------------------------------------
local BAR_H = 22

local function CreateProgressBar(frame)
  local bar = CreateFrame("StatusBar", nil, frame)
  bar:SetHeight(BAR_H)
  bar:SetMinMaxValues(0, 1)
  bar:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
  bar:SetStatusBarColor(0.95, 0.45, 0.08)
  local bg = bar:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.04, 0.02, 0.01, 0.9)
  -- Marco dorado fino alrededor
  local border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
  border:SetPoint("TOPLEFT", -3, 3)
  border:SetPoint("BOTTOMRIGHT", 3, -3)
  border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
  border:SetBackdropBorderColor(0.75, 0.6, 0.3, 1)
  bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  bar.text:SetPoint("CENTER", 0, 0)
  bar.text:SetShadowOffset(1, -1)
  return bar
end

---------------------------------------------------------------------------
-- Ficha (derecha): líneas "texto ... valor", algunas con clic
---------------------------------------------------------------------------
local function DetailLine(d, height)
  d.used = d.used + 1
  local line = d.lines[d.used]
  if not line then
    line = CreateFrame("Button", nil, d.content)
    line:SetHeight(LINE_H)
    -- El texto de la izquierda pasa a varias líneas si no cabe (sin "…")
    line.left = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line.left:SetPoint("TOPLEFT", 0, -3)
    line.left:SetJustifyH("LEFT")
    line.left:SetJustifyV("TOP")
    line.left:SetWordWrap(true)
    line.right = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line.right:SetPoint("TOPRIGHT", 0, -3)
    line.right:SetJustifyH("RIGHT")
    line:SetScript("OnEnter", function(self)
      if self.item then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:" .. self.item)
        GameTooltip:Show()
      elseif self.hint then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(self.hint, 0.5, 0.8, 1, true)
        GameTooltip:Show()
      end
    end)
    line:SetScript("OnLeave", function() GameTooltip:Hide() end)
    line:SetScript("OnClick", function(self) if self.onClick then self.onClick() end end)
    d.lines[d.used] = line
  end
  line:ClearAllPoints()
  line:SetPoint("TOPLEFT", 0, -d.y)
  line:SetPoint("RIGHT", d.content, "RIGHT", 0, 0)
  line.minHeight = height or LINE_H
  line.item, line.hint, line.onClick = nil, nil, nil
  line.left:SetFontObject("GameFontHighlightSmall")
  line:Show()
  return line
end

-- Pone los textos y la altura que necesitan: el de la izquierda ocupa el ancho que
-- deja el de la derecha y crece hacia abajo
local function FillLine(d, line, left, right)
  line.right:SetText(right or "")
  local rightW = (right and right ~= "") and (tonumber(line.right:GetStringWidth()) or 0) + 10 or 0
  local width = math.max(60, (tonumber(d.content:GetWidth()) or 330) - rightW)
  line.left:SetWidth(width)
  line.left:SetText(left)
  local h = math.max(line.minHeight, math.ceil(tonumber(line.left:GetStringHeight()) or 0) + 6)
  line:SetHeight(h)
  d.y = d.y + h
end

local function Section(d, text)
  d.y = d.y + 6
  local line = DetailLine(d)
  line.left:SetFontObject("GameFontNormal")
  FillLine(d, line, text, "")
end

local function KV(d, left, right, opts)
  local line = DetailLine(d, opts and opts.height)
  FillLine(d, line, left, right)
  if opts then line.item, line.hint, line.onClick = opts.item, opts.hint, opts.onClick end
  return line
end

local function CreateDetail(frame)
  local Panel, Label = ES.UI.Panel, ES.UI.Label
  local B = ES.UI.BROWN -- como el panel de la lista (el diario de mazmorras usa el mismo)
  local d = Panel(frame, B.list[1], B.list[2], B.list[3], B.list[4])
  d:SetPoint("TOPLEFT", frame.listPanel, "TOPRIGHT", 12, 0)
  d:SetPoint("BOTTOMRIGHT", 0, 0)
  d.icon = CreateFrame("Button", nil, d)
  d.icon:SetSize(40, 40)
  d.icon:SetPoint("TOPLEFT", 12, -12)
  d.icon.tex = d.icon:CreateTexture(nil, "ARTWORK")
  d.icon.tex:SetAllPoints()
  d.icon:SetScript("OnEnter", function(self)
    if not self.item then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. self.item)
    GameTooltip:Show()
  end)
  d.icon:SetScript("OnLeave", function() GameTooltip:Hide() end)
  d.title = Label(d, "", "GameFontNormalLarge")
  d.title:SetPoint("TOPLEFT", d.icon, "TOPRIGHT", 10, -1)
  d.title:SetPoint("RIGHT", -12, 0)
  d.title:SetJustifyH("LEFT")
  d.title:SetWordWrap(false)
  d.sub = Label(d, "", "GameFontHighlightSmall")
  d.sub:SetPoint("TOPLEFT", d.title, "BOTTOMLEFT", 0, -4)
  d.sub:SetPoint("RIGHT", -12, 0)
  d.sub:SetJustifyH("LEFT")
  d.status = Label(d, "", "GameFontHighlight")
  d.status:SetPoint("TOPLEFT", d.icon, "BOTTOMLEFT", 0, -8)
  d.status:SetPoint("RIGHT", -12, 0)
  d.status:SetJustifyH("LEFT")
  local scroll = WheelScroll(d, LINE_H * 3)
  scroll:SetPoint("TOPLEFT", 12, -84)
  scroll:SetPoint("BOTTOMRIGHT", -12, 10)
  d.content = CreateFrame("Frame", nil, scroll)
  d.content:SetSize(330, 1)
  scroll:SetScrollChild(d.content)
  scroll:SetScript("OnSizeChanged", function(self, w) if w and w > 0 then d.content:SetWidth(w) end end)
  d.lines = {}
  return d
end

-- Umbrales de dificultad con sus colores: naranja, amarilla, verde, gris
local function Thresholds(t)
  return string.format("|cffff8040%d|r  |cffffff00%d|r  |cff40c040%d|r  |cff808080%d|r", t[1], t[2], t[3], t[4])
end

function ES:RenderCollectionDetail(frame)
  local d, e = frame.detail, frame.selected
  d.used, d.y = 0, 0
  if not e then
    d.icon.tex:SetTexture(nil)
    d.title:SetText("")
    d.sub:SetText("")
    d.status:SetText(GREY .. L["Elige una receta de la lista."] .. "|r")
    for _, line in ipairs(d.lines) do line:Hide() end
    return
  end
  local r = e.recipe
  local profName = ES:ProfLabel(frame.profKey)
  local _, _, texture = ES:GetItemData(e.itemID or 0)
  SetIcon(d.icon.tex, texture or ES.Collection.SOURCE_ICON[e.main])
  d.icon.item = e.itemID
  d.title:SetText(r.name or "?")
  d.sub:SetText((r.scroll and (RecipeWord(r) .. " · ") or (L["Instructor"] .. " · ")) .. profName .. " " .. e.level
    .. GREY .. "   ·   |r" .. Thresholds({ e.level, r.t[2], r.t[3], r.t[4] })) -- naranja = nivel para aprenderla
  local status
  if e.known then status = GREEN .. CHECK .. " " .. L["La tienes"] .. "|r"
  elseif e.learnableNow then status = ORANGE .. L["Puedes aprenderla ya"] .. "|r"
  elseif frame.data.skill and frame.data.skill < e.level then status = GREY .. string.format(L["Te falta: necesitas %s %d"], profName, e.level) .. "|r"
  else status = GREY .. L["Te falta"] .. "|r" end
  if #e.alts > 0 then status = status .. GREY .. " · |r" .. string.format(L["La tiene tu personaje: %s"], table.concat(e.alts, ", ")) end
  d.status:SetText(status)

  -- Dónde conseguirla: cada fuente, con clic para marcar el camino
  Section(d, L["Dónde conseguirla"])
  local WP = ES.Waypoints
  for _, s in ipairs(e.sources) do
    local go = GoFor(e, s)
    local cost = s.cost and s.cost > 0 and ES.Money(s.cost) or ""
    KV(d, Where(e, s), go and ("|cff80c0ff" .. L["Marcar en el mapa"] .. "|r") or cost,
      go and { onClick = function() WP.Go(go) end, hint = L["Clic: marcar el camino (mapa, minimapa y seguimiento)."] } or nil)
    -- Botín de varias criaturas: todas, agrupadas por zona, con su nivel y clic
    -- para marcar cada una en el mapa
    if s.kind == "drop" and #s.drops.npcs > 1 then
      for _, zone in ipairs(DropZones(s.drops.npcs)) do
        KV(d, "   " .. zone.name)
        for _, id in ipairs(zone.npcs) do
          local npc = WP.NPC(id)
          local lv = WP.NPCLevel(id)
          local onMap = npc.map ~= nil
          KV(d, GREY .. "      " .. npc.name .. (lv and string.format(L[" (nivel %s)"], lv) or "") .. "|r",
            onMap and ("|cff80c0ff" .. L["Marcar en el mapa"] .. "|r") or "",
            onMap and { onClick = function() WP.SetWaypoint(id) end, hint = L["Clic: marcar el camino (mapa, minimapa y seguimiento)."] } or nil)
        end
      end
    end
  end

  -- Precios: pergamino, fabricar, vender lo fabricado y beneficio
  local scanned = frame.data.scanned
  Section(d, L["Precios"])
  if r.scroll then
    local ahText = e.scrollAH and string.format(L["%s · %d a la venta"], ES.Money(e.scrollAH), e.scrollListings)
      or GREY .. (scanned and L["no hay ninguno"] or L["sin escanear"]) .. "|r"
    KV(d, RecipeWord(r) .. L[" en la AH"], ahText, e.scrollAH and ES.ahOpen and {
      onClick = function() ES:SearchAuction(r.scroll) end, hint = L["Clic: buscar el pergamino en la Casa de Subastas."] } or { item = r.scroll })
    if r.scrollPrice then KV(d, RecipeWord(r) .. L[" en el vendedor"], ES.Money(r.scrollPrice)) end
  end
  KV(d, L["Fabricar 1"], e.cost and ES.UI.Signed(e.cost) or (GREY .. L["faltan precios"] .. "|r"))
  if e.itemID then
    local sell
    if e.sellWhere == "ah" and e.ahPrice then sell = ES.Money(e.ahPrice) .. GREY .. L[" (AH)"] .. "|r"
    elseif e.vendor and e.vendor > 0 then sell = ES.Money(e.vendor) .. GREY .. L[" (vendedor)"] .. "|r"
    else sell = GREY .. (scanned and L["no hay ninguno"] or L["sin escanear"]) .. "|r" end
    KV(d, (e.qty or 1) > 1 and string.format(L["Vender lo fabricado (%s uds)"], ES.Num(e.qty)) or L["Vender lo fabricado"], sell, { item = e.itemID })
    if r.bop then KV(d, ORANGE .. L["Se liga al recogerlo: no se puede vender en la AH"] .. "|r") end
    if e.profit then KV(d, L["Beneficio por fabricación"], ES.UI.Signed(-e.profit)) end
    local price = e.scrollAH or r.scrollPrice
    if not e.known and price and e.profit and e.profit > 0 then
      KV(d, L["Recuperas el pergamino tras"], string.format(L["%d fabricaciones"], math.ceil(price / e.profit)))
    end
  end

  -- Materiales de una fabricación, con su icono grande. Si el juego aún no ha
  -- cargado alguno, se repinta cuando llegue (GET_ITEM_INFO_RECEIVED)
  local reagents = e.reagents and #e.reagents > 0 and e.reagents or nil
  if reagents or r.r then
    Section(d, L["Materiales"])
    for _, rg in ipairs(reagents or r.r) do
      local item, qty = rg.item or rg[1], rg.qty or rg[2]
      local loaded, _, icon = ES:GetItemData(item)
      if not loaded then frame.pendingItems = true end
      KV(d, string.format("|T%s:%d|t  %s× %s", icon or 134400, MATERIAL_ICON, ES.Num(qty), ES:ItemName(item) or (L["Objeto "] .. item)),
        reagents and ES.Money(rg.cost or 0) or "", { item = item, height = MATERIAL_ICON + 4 })
    end
  end
  if e.itemID and not ES:GetItemData(e.itemID) then frame.pendingItems = true end
  for i = d.used + 1, #d.lines do d.lines[i]:Hide() end
  d.content:SetHeight(math.max(1, d.y))
end

-- Elegir una receta: se marca en la lista y se pinta su ficha
function ES:SelectCollectionEntry(frame, e)
  frame.selected = e
  frame.selectedID = e and e.id
  self:RenderCollection(frame)
end

---------------------------------------------------------------------------
-- Vista
---------------------------------------------------------------------------
function ES:CreateCollectionView(frame, profKey)
  local Label, Panel = ES.UI.Label, ES.UI.Panel
  frame.profKey = profKey
  frame.rows = {}

  -- Cabecera: barra de progreso y Filtros; debajo, cuántas puedes aprender ya
  frame.filterButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  frame.filterButton:SetSize(100, 24)
  frame.filterButton:SetPoint("TOPRIGHT", -10, -10)
  -- Tarjeta de la cabecera (barra, filtros y buscador), como la de una profesión
  local B = ES.UI.BROWN
  frame.headCard = Panel(frame, B.card[1], B.card[2], B.card[3], B.card[4])
  frame.headCard:SetPoint("TOPLEFT", 0, 0)
  frame.headCard:SetPoint("TOPRIGHT", 0, 0)
  frame.headCard:SetHeight(82)
  frame.headCard:SetFrameLevel(frame:GetFrameLevel())
  frame.filterButton:SetScript("OnClick", function()
    local p = frame.filterPopup
    if p:IsShown() then p:Hide() else p:Sync() p:Show() end
  end)
  frame.bar = CreateProgressBar(frame)
  frame.bar:SetPoint("TOPLEFT", 14, -11)
  frame.bar:SetPoint("RIGHT", frame.filterButton, "LEFT", -14, 0)
  frame.counter = frame.bar.text
  frame.counterSub = Label(frame, "", "GameFontHighlightSmall")
  frame.counterSub:SetPoint("TOPLEFT", frame.bar, "BOTTOMLEFT", 2, -6)

  frame.search = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
  frame.search:SetHeight(20)
  frame.search:SetPoint("TOPLEFT", 18, -54)
  frame.search:SetWidth(LIST_W - 14)
  frame.search:SetAutoFocus(false)
  frame.search:SetScript("OnTextChanged", function() ES:RenderCollection(frame) end)
  frame.search:SetScript("OnEscapePressed", function(self) self:SetText("") self:ClearFocus() end)
  frame.search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  frame.searchHint = Label(frame.search, L["Buscar receta o material"], "GameFontDisableSmall")
  frame.searchHint:SetPoint("LEFT", 4, 0)

  -- Lista
  frame.listPanel = Panel(frame, B.list[1], B.list[2], B.list[3], B.list[4])
  frame.listPanel:SetPoint("TOPLEFT", 0, -92)
  frame.listPanel:SetPoint("BOTTOMLEFT", 0, 0)
  frame.listPanel:SetWidth(LIST_W)
  local scroll = WheelScroll(frame.listPanel, ROW_STEP * 2)
  scroll:SetPoint("TOPLEFT", 6, -6)
  scroll:SetPoint("BOTTOMRIGHT", -6, 6)
  frame.scroll = scroll
  scroll:HookScript("OnVerticalScroll", function() PlaceRows(frame) end)
  scroll:HookScript("OnSizeChanged", function() PlaceRows(frame) end)
  frame.content = CreateFrame("Frame", nil, scroll)
  frame.content:SetSize(ROW_W, 1)
  scroll:SetScrollChild(frame.content)
  frame.scrollIndicator = ES.UI.ScrollIndicator(scroll, frame.content, SCROLL_W)
  frame.empty = Label(frame.content, "", "GameFontDisable")
  frame.empty:SetPoint("TOP", 0, -30)
  frame.empty:SetWidth(LIST_W - 50)

  frame.detail = CreateDetail(frame)
  frame.filterPopup = CreateFilterPopup(frame)

  ES.SafeRegister(frame, "GET_ITEM_INFO_RECEIVED")
  frame:SetScript("OnEvent", function(self)
    if self.pendingItems and not self.refreshQueued then
      self.refreshQueued = true
      C_Timer.After(0.5, function()
        self.refreshQueued = false
        if self:IsVisible() then ES:RenderCollection(self) end
      end)
    end
  end)
  frame:SetScript("OnShow", function(self) ES:RefreshCollection(self) end)
  frame:Hide()
end

-- Recalcula (al mostrarse, tras un escaneo) y pinta
function ES:RefreshCollection(frame)
  if not frame:IsVisible() then return end
  frame.data = ES.Collection:Build(frame.profKey)
  local scan = ES.db.scans and ES.db.scans[ES:RealmKey()]
  frame.data.scanned = scan ~= nil
  for _, e in ipairs(frame.data.entries) do
    e.profKey = frame.profKey
    for _, s in ipairs(e.sources) do if s.kind == e.main then e.mainSource = s break end end
  end
  self:RenderCollection(frame)
end

local function SortedEntries(res, sortKey)
  if sortKey == "level" then return res.entries end
  local entries = {}
  for i, e in ipairs(res.entries) do entries[i] = e end
  local function Value(e)
    if sortKey == "scroll" then return e.scrollAH or math.huge end
    if sortKey == "profit" then return -(e.profit or -math.huge) end
    return e.getCost or (e.scrollAH or math.huge) -- más barata de conseguir
  end
  table.sort(entries, function(a, b)
    local va, vb = Value(a), Value(b)
    if va ~= vb then return va < vb end
    return a.level < b.level
  end)
  return entries
end

function ES:RenderCollection(frame)
  local res = frame.data
  if not res then return end
  frame.pendingItems = false -- lo vuelven a marcar las filas o la ficha si falta algún objeto
  local s = Settings()
  local profName = ES:ProfLabel(frame.profKey)
  local pct = res.total > 0 and math.floor(res.known / res.total * 100 + 0.5) or 0
  local now = 0
  for _, e in ipairs(res.entries) do if e.learnableNow then now = now + 1 end end
  frame.bar:SetValue(res.total > 0 and res.known / res.total or 0)
  frame.counter:SetText(string.format(L["%s %d/%d"], profName, res.known, res.total))
  frame.counterSub:SetText(GREY .. string.format(L["%d%% · %d puedes aprender ya"], pct, now) .. "|r")
  local active = ActiveFilters(s)
  frame.filterButton:SetText(active > 0 and string.format(L["Filtros (%d)"], active) or L["Filtros"])
  if frame.filterPopup:IsShown() then frame.filterPopup:Sync() end

  local query = (frame.search:GetText() or ""):lower()
  frame.searchHint:SetShown(query == "")
  local list = {}
  for _, e in ipairs(SortedEntries(res, s.sort)) do
    -- Al buscar se mira en todas: si no, una receta oculta por los filtros parece que no existe
    local ok = query ~= "" or not s.hiddenState[State(e)]
    if ok and query == "" and s.hidden[e.main] then ok = false end
    if ok and query == "" and s.hideBound and e.recipe.bop then ok = false end
    if ok and query ~= "" then
      ok = (e.recipe.name or ""):lower():find(query, 1, true) or (e.recipe.nameEN or ""):lower():find(query, 1, true)
      for _, rq in ipairs(e.recipe.r or {}) do
        if not ok then
          local name = ES:GetItemData(rq[1])
          ok = name and name:lower():find(query, 1, true)
        end
      end
    end
    if ok then list[#list + 1] = e end
  end

  -- Receta elegida: la de antes si sigue (por id: los datos se rehacen al escanear)
  if frame.selectedID and (not frame.selected or frame.selected.id ~= frame.selectedID) then
    frame.selected = nil
    for _, e in ipairs(res.entries) do if e.id == frame.selectedID then frame.selected = e end end
  end
  if not frame.selected then frame.selected = list[1] or res.entries[1] end
  frame.selectedID = frame.selected and frame.selected.id

  frame.list = list
  frame.shown = #list
  -- Que se vea si los filtros esconden recetas (si no, parece que faltan)
  local hidden = res.total - #list
  frame.counterSub:SetText(GREY .. string.format(L["%d%% · %d puedes aprender ya"], pct, now) .. "|r"
    .. (hidden > 0 and (ORANGE .. string.format(L[" · %d ocultas por los filtros"], hidden) .. "|r") or ""))
  frame.content:SetHeight(math.max(1, #list * ROW_STEP))
  -- Al buscar, arriba del todo; y nunca más abajo que el final de la lista: si se había
  -- bajado y la búsqueda deja pocas recetas, las filas quedaban fuera de la vista
  -- (la lista parecía vacía)
  local maxScroll = math.max(0, #list * ROW_STEP - (tonumber(frame.scroll:GetHeight()) or 0))
  local offset = tonumber(frame.scroll:GetVerticalScroll()) or 0
  if query ~= frame.lastQuery then offset = 0 end
  frame.lastQuery = query
  if offset > maxScroll then offset = maxScroll end
  if offset ~= (tonumber(frame.scroll:GetVerticalScroll()) or 0) then
    if frame.scroll.UpdateScrollChildRect then frame.scroll:UpdateScrollChildRect() end
    frame.scroll:SetVerticalScroll(offset)
  end
  PlaceRows(frame)
  frame.scrollIndicator:Update()
  frame.empty:SetText(#list == 0 and (res.known == res.total and L["¡Las tienes todas!"] or L["Ninguna receta cumple los filtros."]) or "")
  self:RenderCollectionDetail(frame)
end

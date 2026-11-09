"""Carga el addon completo con una API de WoW simulada y ejecuta la UI."""
import re
import sys
from pathlib import Path

import os
sys.path.insert(0, os.environ.get("ESLUA", r"C:\Users\bruno\AppData\Local\Temp\eslua"))  # carpeta con lupa (Lua 5.1)
from lupa import lua51

ADDON = Path(__file__).resolve().parent.parent  # el repositorio (no depende del enlace en AddOns)
lua = lua51.LuaRuntime(unpack_returned_tuples=True)

lua.execute(r"""
NOW = 2000000
time = function() return NOW end
bit = bit or { band = function(a, b) local r, p = 0, 1 while a > 0 and b > 0 do if a % 2 == 1 and b % 2 == 1 then r = r + p end a, b, p = math.floor(a / 2), math.floor(b / 2), p * 2 end return r end }
local function Mock(name)
  local m = { _scripts = {}, _name = name }
  return setmetatable(m, { __index = function(t, k)
    if k == "SetScript" then return function(self, n, f) self._scripts[n] = f end end
    if k == "GetScript" then return function(self, n) return self._scripts[n] end end
    if k == "GetWidth" or k == "GetHeight" or k == "GetEffectiveScale" or k == "GetStringWidth" or k == "GetFrameLevel" or k == "GetLeft" or k == "GetTop" then return function() return 100 end end
    if k == "GetScale" then return function(self) return self._scale or 1 end end
    if k == "SetScale" then return function(self, v) self._scale = v end end
    if k == "GetText" then return function(self) return self._text or "" end end
    if k == "SetText" then return function(self, v) self._text = v and tostring(v) end end
    if k == "GetCenter" then return function() return 0, 0 end end
    if k == "SetAttribute" then return function(self, a, v) self._attributes = self._attributes or {} self._attributes[a] = v end end
    if k == "GetAttribute" then return function(self, a) return self._attributes and self._attributes[a] end end
    if k == "Show" then return function(self) self._shown = true end end
    if k == "Hide" then return function(self) self._shown = false end end
    if k == "SetShown" then return function(self, v) self._shown = v and true or false end end
    if k == "IsShown" or k == "IsVisible" then return function() return true end end
    if k == "GetChecked" then return function(self) if self._checked == nil then return true end return self._checked end end
    if k == "SetChecked" then return function(self, v) self._checked = v and true or false end end
    -- Como en WoW: solo los métodos (con mayúscula) existen; los campos propios no
    if type(k) ~= "string" or not k:match("^%u") then return nil end
    return function() return Mock(k) end
  end })
end
CreateFrame = function(_, name) local f = Mock("frame") if name then _G[name] = f end return f end
UIParent, Minimap, GameTooltip = Mock(), Mock(), Mock()
UISpecialFrames, SlashCmdList = {}, {}
tinsert = table.insert
strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
C_Timer = { After = function(_, f) end }
GetRealmName = function() return "Realm" end
UnitFactionGroup = function() return "Alliance" end
ITEM_QUALITY_COLORS = { [1] = { r = 1, g = 1, b = 1, hex = "|cffffffff" } }
GetItemInfo = function(id) return nil end
GetCursorPosition = function() return 0, 0 end
GetTime = function() return 0 end
FrameUtil = {}
UnitExists = function() return true end
UnitName = function() return "Bruno" end
""")

# Globales escritas desde los archivos del addon (los mocks del test no cuentan)
lua.execute(r"""
LEAKS = {}
local ALLOWED = { CraftersJournalDB = true, SLASH_CRAFTERSJOURNAL1 = true, SLASH_CRAFTERSJOURNAL2 = true, SLASH_CRAFTERSJOURNAL3 = true,
  CraftersJournal_OnAddonCompartmentClick = true, CraftersJournal = true, CraftersJournalMainFrame = true,
  CraftersJournalAHButton = true, CraftersJournalMinimapButton = true, CraftersJournalRowMarkButton = true, }
setmetatable(_G, { __newindex = function(t, k, v)
  local info = debug.getinfo(2, "S")
  if info and info.source:match("^@[%w\\/]+%.lua$") and not ALLOWED[k] then LEAKS[#LEAKS + 1] = info.source .. ":" .. tostring(k) end
  rawset(t, k, v)
end })
""")

toc = (ADDON / "CraftersJournal.toc").read_text(encoding="utf-8")
files = [l.strip() for l in toc.splitlines() if l.strip() and not l.startswith("#")]
ES = lua.eval("{}")
loader = lua.eval("function(src, name, ES) assert(loadstring(src, '@' .. name))('CraftersJournal', ES) end")
for f in files:
    loader((ADDON / f.replace("\\", "/")).read_text(encoding="utf-8"), f, ES)
lua.globals().ES = ES
lua.execute("SOURCES, SOURCE_NAMES = {}, {}")
for f in files:
    lua.eval("function(s, n) SOURCES[#SOURCES + 1] = s SOURCE_NAMES[#SOURCES] = n end")(
        (ADDON / f.replace("\\", "/")).read_text(encoding="utf-8"), f)
print("cargados:", ", ".join(files))

lua.execute(r"""
-- Eventos de inicio
CraftersJournalDB = nil
local events
-- El frame de eventos de Core es el primero creado con OnEvent: lo buscamos por el handler
for _, v in pairs(_G) do end
""")

# --v1: todo con el planificador antiguo (el de antes del GPS), para comparar
if "--v1" in sys.argv:
    lua.execute("ES.Planner.USE_GPS = false")

out = lua.execute(r"""
local log = {}
local function step(name, fn)
  local ok, err = pcall(fn)
  log[#log + 1] = (ok and "OK   " or "FAIL ") .. name .. (ok and "" or (": " .. tostring(err)))
end

-- Simular ADDON_LOADED a mano (el mock no dispara eventos)
CraftersJournalDB = { scans = {} }
ES.db = CraftersJournalDB
ES.db.minimap = { angle = 225 }

local key = ES:RealmKey()
local S = ES.History
local function sigs(list)
  local t = {}
  for _, a in ipairs(list) do
    local sig = S.Signature(a[1], a[2], a[3], a[4])
    S.AddAuction(t, sig, a[5])
  end
  return t
end

step("historial: 3 escaneos", function()
  -- t0: 5 pantalones (4242) y 10 cuero ligero (2318 x5) con tiempo largo
  local a = {}
  for i = 1, 5 do a[#a+1] = { 4242, 1, 900, "Pepe", 4 } end
  for i = 1, 10 do a[#a+1] = { 2318, 5, 125, "Ana", 4 } end
  NOW = 2000000; S:Record(key, sigs(a), ";4242:900:5;2318:25:10", NOW)
  -- t0+1h: se venden 2 pantalones y 4 lotes de cuero
  local b = {}
  for i = 1, 3 do b[#b+1] = { 4242, 1, 900, "Pepe", 4 } end
  for i = 1, 6 do b[#b+1] = { 2318, 5, 125, "Ana", 4 } end
  NOW = 2003600; S:Record(key, sigs(b), ";4242:900:3;2318:25:6", NOW)
  -- t0+2h: se vende 1 pantalÃ³n mÃ¡s
  local c = {}
  for i = 1, 2 do c[#c+1] = { 4242, 1, 1000, "Pepe", 4 } end
  for i = 1, 6 do c[#c+1] = { 2318, 5, 125, "Ana", 4 } end
  NOW = 2007200; S:Record(key, sigs(c), ";4242:1000:2;2318:25:6", NOW)
  ES.db.scans[key] = { time = NOW, total = 8, unique = 2, items = {
    [4242] = { listings = 2, quantity = 2, minUnit = 1000, avgUnit = 1000, sellers = 1, topShare = 1 },
    [2318] = { listings = 6, quantity = 30, minUnit = 25, avgUnit = 25, sellers = 1, topShare = 1 },
    [2934] = { listings = 2, quantity = 40, minUnit = 5, avgUnit = 5, sellers = 2, topShare = 0.5 },
  } }
  local n, c2 = S:Summary()
  log[#log+1] = string.format("     resumen: %d escaneos, %d comparaciones", n, c2)
  assert(n == 3 and c2 == 2, "resumen incorrecto")
  log[#log+1] = "     snapshot antiguo pantalones: " .. tostring(S:OldestSnapshot(4242, 86400))
  local last = ES.db.history[key][3]
  log[#log+1] = "     baratas que siguen (último): " .. tostring(last.stuck)
  assert(last.sold == nil, "el historial no debe guardar ventas")
end)

step("crear panel", function() ES:ShowMainFrame() end)
step("pintar mercado", function() ES:RenderResults() end)
step("pintar mercado (3 días, todas las columnas)", function()
  ES.db.topWindow = "3d"
  for _, h in ipairs(CraftersJournalMainFrame.headers) do h._scripts.OnClick(h) h._scripts.OnClick(h) end
end)
step("tooltip fila mercado", function()
  local row = CraftersJournalMainFrame.rows[1]
  row._scripts.OnEnter(row)
  log[#log+1] = "     fila1: " .. tostring(row.cells.name._text) .. " | subastas " .. tostring(row.cells.listings._text)
    .. " | tendencia " .. tostring(row.cells.trend._text) .. " | mercado " .. tostring(row.cells.market._text)
end)
step("franja de 7 días y versión antigua guardada", function()
  ES.db.topWindow = "all"; ES.db.topSortBy = { key = "sold", asc = false } -- de versiones anteriores
  ES:RenderResults()
  assert(ES.db.topSortBy.key == "listings", "no migró el orden antiguo")
end)

step("pestaÃ±a peleterÃ­a", function()
  ES:SelectPage("lw")
  local page
  for _, p in ipairs(ES.professionPages) do if p.profKey == "Leatherworking" then page = p end end
  page._scripts.OnShow(page)
  -- El nivel actual no se edita (sin la profesión: 1); el objetivo sí, y recalcula
  assert(page.from == 1, "nivel actual " .. tostring(page.from))
  page.toBox._text = "75"
  page.toBox._scripts.OnEnterPressed(page.toBox)
  assert(page.plan and page.plan.to == 75, "no recalculó al cambiar el objetivo")
  log[#log+1] = string.format("     resumen: materiales %s | profit %s | instructor %s | total %s",
    tostring(page.stats.materials._text), tostring(page.stats.profit._text), tostring(page.stats.fees._text), tostring(page.stats.total._text))
  log[#log+1] = "     estado: " .. tostring(page.status._text)
  assert(#page.viewButtons == 3, "la vista Recetas ya no está dentro de la profesión")
  for _, view in ipairs({ "route", "profit", "shop" }) do
    local b
    for _, vb in ipairs(page.viewButtons) do if vb.key == view then b = vb end end
    b._scripts.OnClick(b)
    local n = 0
    for i = 1, #page.lines do
      local row = page.rows[i]
      if row.tooltip then row._scripts.OnEnter(row) end
      n = n + 1
      if i <= 3 then log[#log+1] = string.format("       %s %d: %s | %s | %s", view, i, tostring(row.title._text), tostring(row.sub._text), tostring(row.value._text)) end
    end
    log[#log+1] = string.format("     vista %s: %d filas", view, n)
  end
  assert(ES.db.prof.Leatherworking.view == "shop", "no recuerda la vista")
  -- Vista guardada de una versión anterior ("market"): vuelve a la ruta
  ES:SelectProfessionView(page, "market")
  assert(page.view == "route", "la vista antigua debería volver a Ruta")
  ES:SelectProfessionView(page, "route")
  -- Icono de bolsas: alterna y recalcula
  local before = ES.db.prof.Leatherworking.useBags
  page.bagsButton._scripts.OnClick(page.bagsButton)
  assert(ES.db.prof.Leatherworking.useBags ~= before, "el icono de bolsas no cambió el ajuste")
  page.bagsButton._scripts.OnEnter(page.bagsButton)
  page.bagsButton._scripts.OnClick(page.bagsButton)
end)
step("lista de la compra desglosada", function()
  local page
  for _, p in ipairs(ES.professionPages) do if p.profKey == "Leatherworking" then page = p end end
  local plan = page.plan
  for _, c in ipairs(plan.crafted) do
    log[#log+1] = string.format("     fabricar antes: %dx item %d", c.quantity, c.itemID)
  end
  for _, s in ipairs(plan.shopping) do
    log[#log+1] = string.format("     comprar: %dx item %d (%s)%s", s.quantity, s.itemID, tostring(s.source),
      s.ahShort and (" ¡solo " .. s.ahShort .. " en AH!") or "")
  end
  log[#log+1] = "     pendingInfo=" .. tostring(plan.pendingInfo)
end)
step("señales de mercado (1 escaneo cada 12 h)", function()
  -- 7777 atascado: las baratas siguen, el mínimo no se mueve, cada escaneo 6 más
  -- 8888 se mueve: las baratas desaparecen, el precio cambia, pocas subastas
  -- 6666 material con mucha competencia que se vende: muro en el mínimo pero rota
  local saved = { ES.db.history, ES.db.track }
  ES.db.history, ES.db.track = {}, {}
  local T = 3000000
  for k = 0, 4 do
    local a = {}
    local n = 10 + 6 * k
    for i = 1, n do a[#a+1] = { 7777, 1, 100, "?", 4 } end
    local p = 500 + 37 * k -- cada vez otras subastas, a otro precio
    for i = 1, 3 do a[#a+1] = { 8888, 1, p, "?", 4 } end
    for i = 1, 8 do a[#a+1] = { 6666, 20, 200 + k * 20, "?", 4 } end
    NOW = T + k * 12 * 3600
    S:Record(key, sigs(a), string.format(";7777:100:%d:100:%d;8888:%d:3:%d:3;6666:10:8:10:160", n, n, p, p), NOW)
  end
  local bad, good, wall = ES.Market:Signals(7777), ES.Market:Signals(8888), ES.Market:Signals(6666)
  for _, l in ipairs(ES.Market.Describe(bad)) do log[#log+1] = "     7777 " .. l[1] end
  for _, l in ipairs(ES.Market.Describe(good)) do log[#log+1] = "     8888 " .. l[1] end
  for _, l in ipairs(ES.Market.Describe(wall)) do log[#log+1] = "     6666 " .. l[1] end
  assert(bad.verdict == "avoid" and bad.flags == 3, "7777: esperado evitar 3/3, salió " .. bad.verdict .. " " .. bad.flags)
  assert(good.verdict == "good", "8888: esperado bien, salió " .. good.verdict .. " " .. good.flags)
  assert(wall.verdict ~= "avoid" and not wall.stuck.flag, "6666: la competencia sola no debe dar evitar, salió " .. wall.verdict)
  ES.db.history, ES.db.track = saved[1], saved[2]
end)
step("precio inflado (caso Westfall Stew)", function()
  local saved = { ES.db.history, ES.db.track }
  ES.db.history, ES.db.track = {}, {}
  local T = 4000000
  -- 3 días a ~4s90 y hoy, sin existencias baratas, el mínimo salta a 23s
  local mins = { 494, 493, 490, 489, 2300 }
  for k, m in ipairs(mins) do
    NOW = T + (k - 1) * 20 * 3600
    S:Record(key, sigs({ { 733, 1, m, "?", 4 } }), string.format(";733:%d:10:%d:40", m, m), NOW)
  end
  local fp = ES.Market:FairPrice(733, 2300)
  log[#log+1] = string.format("     referencia %s (%s días) · inflado %s · se cuenta a %s · anunciar a %s",
    tostring(fp.ref), tostring(fp.days), tostring(fp.inflated), tostring(fp.price), tostring(ES.Market.ListPrice(fp)))
  assert(fp.inflated and fp.ref >= 489 and fp.ref <= 494, "debería detectar el pico")
  assert(fp.price == math.floor(fp.ref * ES.Market.PREMIUM + 0.5), "precio realista")
  -- Normal: el mínimo de siempre se anuncia 1 cobre por debajo
  local normal = ES.Market:FairPrice(733, 500)
  assert(not normal.inflated and ES.Market.ListPrice(normal) == 499, "precio normal")
  -- Malvendido: se avisa pero se iguala
  local cheap = ES.Market:FairPrice(733, 200)
  assert(cheap.deflated and cheap.price == 200, "malvendido")
  -- Escaneos sueltos: un día a 4s90, nada en 4 días y hoy 23s: sigue detectando el pico
  ES.db.history, ES.db.track = {}, {}
  NOW = T
  S:Record(key, sigs({ { 733, 1, 490, "?", 4 } }), ";733:490:10:490:40", NOW)
  NOW = T + 4 * 86400 + 3600
  S:Record(key, sigs({ { 733, 1, 2300, "?", 4 } }), ";733:2300:10:2300:40", NOW)
  local loose = ES.Market:FairPrice(733, 2300)
  log[#log+1] = string.format("     escaneos sueltos: referencia %s de hace %s días · inflado %s", tostring(loose.ref), tostring(loose.ago), tostring(loose.inflated))
  assert(loose.inflated and loose.ref == 490 and loose.ago == 4, "escaneos sueltos")
  -- Sin historial: se avisa
  local none = ES.Market:FairPrice(99999, 1000)
  assert(none.noHistory and none.price == 1000, "sin historial")
  ES.db.history, ES.db.track = saved[1], saved[2]
end)
step("lista de compra en la AH", function()
  local searched
  AuctionFrame = CreateFrame("Frame")
  BrowseName = CreateFrame("EditBox")
  AuctionFrameBrowse_Search = function() searched = BrowseName:GetText() end
  CanSendAuctionQuery = function() return true, true end
  local realData = ES.GetItemData
  ES.GetItemData = function(self, id) return "Item" .. id, 1, 134400 end
  -- Solo salen las profesiones con una ruta empezada: sin ninguna, Peletería no está
  ES:SetupAuctionPanel(AuctionFrame)
  local st = ES.AuctionPanelState
  assert(st.profKey ~= "Leatherworking", "sin ruta empezada no debería salir Peletería")
  -- Con la de Peletería empezada (la ruta de siempre, sin fijar de verdad), sale ella
  local realLock, realLocked = ES.RouteLock, ES.LockedPlan
  ES.RouteLock = function(self, key) if key == "Leatherworking" then return {} end return realLock(self, key) end
  ES.LockedPlan = function(self, key) if key == "Leatherworking" then return nil end return realLocked(self, key) end
  ES.db.lastProf = "Leatherworking"
  st.profKey = nil -- como al volver a abrir la AH
  ES:RefreshAuctionPlan(true)
  ES.RouteLock, ES.LockedPlan = realLock, realLocked
  assert(st.profKey == "Leatherworking", "profesión: " .. tostring(st.profKey))
  local buys = 0
  for _, l in ipairs(st.lines) do if l.buy then buys = buys + 1 end end
  assert(buys > 0, "sin materiales que comprar")
  local first
  for _, l in ipairs(st.lines) do if l.buy then first = l.itemID break end end
  ES:SearchAuction(first)
  assert(searched == "Item" .. first, "no buscó: " .. tostring(searched))
  -- "Comprar" el primero: deja de salir como pendiente y Buscar siguiente pasa al segundo
  local real = ES.ItemCount
  ES.ItemCount = function(self, id) if id == first then return 999 end return real(self, id) end
  ES:RenderAuctionPanel()
  log[#log+1] = string.format("     %d materiales a comprar; buscado %s", buys, searched)
  for _, l in ipairs(st.lines) do
    if l.sell then log[#log+1] = "     vender: " .. l.itemID .. " x" .. l.s.advice.ah .. " a " .. l.s.advice.price end
  end
  ES.ItemCount = real
  ES.GetItemData = realData
end)
step("ganar dinero (sin correo)", function()
  -- Peletería al 150 sabiendo todas sus recetas de instructor
  local realSkill, realKnown = ES.GetProfessionSkill, ES.IsRecipeKnown
  ES.GetProfessionSkill = function(self, line) if line == ES.Data.Leatherworking.skillLine then return 150, 225 end end
  ES.IsRecipeKnown = function(self, id) local r = ES.Data.Leatherworking.recipes[id] return r ~= nil and r.fee ~= nil end
  -- El buzón no se lee ni se guarda (ni el módulo existe)
  assert(ES.Mail == nil, "el addon no debería leer el correo")
  ES.Earn:Clear()
  local res = ES.Earn:Ideas()
  assert(res.known > 0, "no detecta recetas conocidas")
  log[#log+1] = string.format("     %d conocidas, %d ideas, %d evitar, lote %d: invierte %s gana %s, %d materiales",
    res.known, #res.ideas, #res.avoided, #res.batch, ES.Money(res.invest), ES.Money(res.profit), #res.shopping)
  for i = 1, math.min(3, #res.batch) do
    local idea = res.batch[i]
    log[#log+1] = string.format("       %dx %s +%s (%s, %s)", idea.crafts, idea.e.recipe.name, ES.Money(idea.profit), tostring(idea.verdict or idea.sellWhere), idea.why)
  end
  -- Lo que ya llevas fabricado: no se vuelve a fabricar
  if res.batch[1] then
    local item = res.batch[1].itemID
    local real = ES.ItemCount
    ES.ItemCount = function(self, id) if id == item then return 999 end return real(self, id) end
    ES.Earn:Clear()
    local again = ES.Earn:Ideas()
    local found
    for _, idea in ipairs(again.ideas) do if idea.itemID == item then found = idea end end
    assert(found and found.crafts == 0 and found.invest == 0, "debería no fabricar lo que ya tienes")
    ES.ItemCount = real
    ES.Earn:Clear()
  end
  -- Página y portada
  ES:SelectPage("money")
  ES:RenderEarn()
  ES:SelectPage("home")
  -- Panel de la AH en modo Ganar dinero
  ES.AuctionPanelState.profKey = "money"
  ES:RefreshAuctionPlan(true)
  assert(ES.AuctionPanelState.earn ~= nil, "panel sin modo ganar dinero")
  ES.GetProfessionSkill, ES.IsRecipeKnown = realSkill, realKnown
  ES.Earn:Clear()
  ES.AuctionPanelState.profKey = nil
end)
step("colección de recetas", function()
  local realSkill, realKnown = ES.GetProfessionSkill, ES.IsRecipeKnown
  ES.GetProfessionSkill = function(self, line) if line == ES.Data.Leatherworking.skillLine then return 150, 225 end end
  ES.IsRecipeKnown = function(self, id) local r = ES.Data.Leatherworking.recipes[id] return r ~= nil and r.fee ~= nil and (r.train or 1) <= 100 end
  local res = ES.Collection:Build("Leatherworking")
  local parts = {}
  for _, k in ipairs(ES.Collection.SOURCES) do parts[#parts+1] = k .. " " .. res.by[k].known .. "/" .. res.by[k].total end
  log[#log+1] = string.format("     peletería: %d/%d · %s · siguientes %d", res.known, res.total, table.concat(parts, ", "), #res.next)
  assert(res.total > 500 and res.known > 0 and res.by.drop.total > 0, "colección incompleta")
  -- Recetas sabidas guardadas para los alters
  assert(ES.db.known[ES:CharKey()].Leatherworking and #ES.db.known[ES:CharKey()].Leatherworking == res.known, "no guarda las sabidas")
  -- Pestaña "Colección de recetas": tarjetas con el progreso y la página de una profesión
  ES:SelectPage("patterns")
  ES:RenderPatterns()
  local pcard
  for _, c in ipairs(ES.patternsPage.cards) do if c.key == "Leatherworking" then pcard = c end end
  -- Mismo orden fijo que la portada (ES.PROFESSIONS)
  local porder, want = {}, {}
  for _, c in ipairs(ES.patternsPage.cards) do if c.key then porder[#porder + 1] = c.key end end
  for _, learnedPass in ipairs({ true, false }) do
    for _, pr in ipairs(ES.PROFESSIONS) do
      local has = ES.Data[pr.key] and ES:GetProfessionSkill(ES.Data[pr.key].skillLine) ~= nil
      if ES:ProfessionVisible(pr) and ES.Data[pr.key] and has == learnedPass then want[#want + 1] = pr.key end
    end
  end
  assert(table.concat(porder, ",") == table.concat(want, ","), "orden de Patterns: " .. table.concat(porder, ","))
  log[#log+1] = "     tarjeta colección: " .. tostring(pcard.cost._text) .. " | " .. tostring(pcard.level._text)
  assert(tostring(pcard.level._text):find(res.known .. "|r de " .. res.total), "progreso en la tarjeta")
  pcard._scripts.OnClick(pcard) -- abre la colección de peletería
  local page
  for _, p in ipairs(ES.patternPages) do if p.collectionFrame.profKey == "Leatherworking" then page = p end end
  assert(ES.db.lastPage == "pattern:Leatherworking", "no abrió la colección")
  local cf = page.collectionFrame
  ES.db.collection = nil
  ES:RefreshCollection(cf)
  local function Visible() return cf.shown end -- el simulacro no guarda qué filas se ocultan
  -- Por defecto se ven todas (las que tienes, apagadas con su check)
  assert(Visible() == res.total, "por defecto deberían verse todas: " .. Visible() .. " de " .. res.total)
  log[#log+1] = "     1ª fila: " .. tostring(cf.rows[1].title._text) .. " | " .. tostring(cf.rows[1].sub._text) .. " | " .. tostring(cf.rows[1].level._text)
  log[#log+1] = "     contador: " .. tostring(cf.counter._text) .. " | " .. tostring(cf.counterSub._text)
  -- Mostrar: casillas por estado (aprendidas, puedo aprender ya, me faltan)
  ES.db.collection.hiddenState = { known = true }
  ES:RenderCollection(cf)
  log[#log+1] = string.format("     sin las aprendidas: %d filas · %s", Visible(), tostring(cf.counterSub._text))
  assert(Visible() == res.total - res.known, "ocultar aprendidas")
  ES.db.collection.hiddenState = { known = true, missing = true }
  ES:RenderCollection(cf)
  log[#log+1] = string.format("     solo puedo aprender ya: %d filas", Visible())
  ES.db.collection.hiddenState = {}
  ES:RenderCollection(cf)
  assert(Visible() == res.total, "volver a todas")
  -- Filtros guardados por la versión anterior: se empieza de cero
  ES.db.collection = { show = "all", hidden = { trainer = true, vendor = true } }
  ES:RenderCollection(cf)
  assert(Visible() == res.total, "los filtros antiguos deberían reiniciarse")
  -- Ventana de filtros: abrirla, pulsar cada casilla (fuentes, orden) y restablecer
  cf.filterButton._scripts.OnClick(cf.filterButton)
  for _, cb in ipairs(cf.filterPopup.checks) do cb._scripts.OnClick(cb) end
  log[#log+1] = "     botón con filtros activos: " .. tostring(cf.filterButton._text)
  for _, o in ipairs({ "level", "scroll", "profit", "cheapest" }) do ES.db.collection.sort = o ES:RenderCollection(cf) end
  ES:RenderCollection(cf)
  -- Restablecer
  ES.db.collection = nil
  ES:RenderCollection(cf)
  assert(cf.filterButton._text == "Filtros", "tras restablecer no quedan filtros: " .. tostring(cf.filterButton._text))
  -- Lista virtual: solo se crean las filas que caben a la vista
  log[#log+1] = "     filas creadas para " .. cf.shown .. " recetas: " .. #cf.rows
  assert(#cf.rows < 30, "la lista no es virtual: " .. #cf.rows .. " filas")
  -- Pulsar una fila elige su receta
  local row1 = cf.rows[2]
  row1._scripts.OnClick(row1)
  assert(cf.selected == row1.entry, "no eligió la receta pulsada")
  -- Una receta de botín: su ficha a la derecha
  local drop
  for _, e in ipairs(cf.data.entries) do if e.main == "drop" then drop = e break end end
  ES:SelectCollectionEntry(cf, drop)
  assert(cf.selected == drop, "no eligió la receta de botín")
  local d = cf.detail
  local texts = {}
  for i = 1, d.used do texts[#texts + 1] = tostring(d.lines[i].left._text) .. " = " .. tostring(d.lines[i].right._text) end
  log[#log+1] = "     ficha: " .. tostring(d.title._text) .. " | " .. tostring(d.sub._text)
  for i = 1, math.min(8, #texts) do log[#log+1] = "       " .. texts[i] end
  assert(d.used >= 4, "ficha casi vacía")
  -- Las líneas con clic (marcar en el mapa) no fallan
  for i = 1, d.used do local line = d.lines[i] if line.onClick then line._scripts.OnClick(line) end end
  -- Barra como la del libro de profesiones: "Peletería 25/541"
  assert(tostring(cf.counter._text) == "Peletería " .. res.known .. "/" .. res.total, "texto de la barra: " .. tostring(cf.counter._text))
  -- La rueda del ratón mueve la lista (sin barra de desplazamiento)
  cf.scroll._scripts.OnMouseWheel(cf.scroll, -1)
  -- El estandarte de facción del otro bando no está (personaje de la Alianza)
  ES:DropOtherFactionRecipes() -- en el juego, al entrar (PLAYER_LOGIN)
  local banners = 0
  for _, r in pairs(ES.Data.Tailoring.recipes) do if r.name == "Faction Banner" then banners = banners + 1 end end
  assert(banners == 1, "estandartes de facción: " .. banners)
  -- "Volver" lleva a la pestaña de la colección
  ES.mainFrameForTests = ES:GetMainFrame()
  ES.mainFrameForTests.back._scripts.OnClick(ES.mainFrameForTests.back)
  assert(ES.db.lastPage == "patterns", "Volver debería ir a la colección")
  ES:SelectPage("home")
  -- Aviso de pergaminos de botín en la AH
  local scan = ES.db.scans[ES:RealmKey()]
  ES.Collection:AlertScan(scan)
  ES.GetProfessionSkill, ES.IsRecipeKnown = realSkill, realKnown
end)
step("escanear con barrera de 15 min", function()
  local f = ES:GetMainFrame()
  ES.ahOpen = true
  ES.db.lastFullScan = nil
  ES:RefreshScanButtons()
  assert(f.scanButton._text == "Escanear", "sin escaneos previos se puede escanear")
  -- Escaneo de verdad con la API clásica: arranca y el botón pasa a %
  local started
  GetFramesRegisteredForEvent = function() end
  QueryAuctionItems = function() started = true end
  CanSendAuctionQuery = function() return true, true end
  GetNumAuctionItems = function() return 0 end
  local pending
  C_Timer.After = function(_, fn) pending = fn end
  local realGetTime = GetTime
  local clock = 0
  GetTime = function() return clock end
  ES.Scanner:Start()
  assert(started and ES.Scanner:IsBusy(), "no arrancó el escaneo")
  log[#log+1] = "     botón al pulsar: " .. tostring(f.scanButton._text)
  assert(f.scanButton._text == "5%", "el botón debería mostrar el progreso")
  clock = 12 pending()
  log[#log+1] = "     esperando al servidor: " .. tostring(f.scanButton._text)
  assert(f.scanButton._text == "5% · 12s", "el botón debería mostrar la espera: " .. tostring(f.scanButton._text))
  ES.Scanner:Abort()
  -- Tras pedir, la barrera corre desde la petición: cuenta atrás y no se vuelve a pedir
  log[#log+1] = "     tras el escaneo: " .. tostring(f.scanButton._text)
  assert(f.scanButton._text == "15:00", "cuenta atrás de 15 min: " .. tostring(f.scanButton._text))
  -- Junto al botón se avisa de que el último intento no acabó
  log[#log+1] = "     tras cancelar: " .. tostring(f.lastScan._text)
  assert(tostring(f.lastScan._text):find("Cancelado"), "debería avisar del escaneo cancelado: " .. tostring(f.lastScan._text))
  ES.db.lastScanFail = nil
  started = false
  ES.Scanner:Start()
  assert(not started and not ES.Scanner:IsBusy(), "no debe pedirse otra vez antes de 15 min")
  -- El servidor no responde: se abandona a los 120 s con la cuenta atrás ya corriendo
  ES.db.lastFullScan = { [ES:CharKey()] = NOW - 16 * 60 }
  ES:RefreshScanButtons()
  assert(f.scanButton._text == "Escanear", "pasados 15 min se puede escanear")
  ES.Scanner:Start()
  assert(ES.Scanner:IsBusy(), "debería pedir")
  clock = clock + 61 pending()
  assert(ES.Scanner:IsBusy(), "a los 60 s aún debe esperar (reinos llenos tardan)")
  clock = clock + 60 pending()
  assert(not ES.Scanner:IsBusy(), "debería abandonar sin respuesta")
  assert(f.scanButton._text:match("^1[345]:%d%d$"), "cuenta atrás tras no responder: " .. tostring(f.scanButton._text))
  -- Si el cliente dice que no se puede, no se pide
  ES.db.lastFullScan = nil
  CanSendAuctionQuery = function() return true, false end
  started = false
  ES.Scanner:Start()
  assert(not started and not ES.Scanner:IsBusy(), "con canGetAll = false no debe pedirse")
  GetTime = realGetTime
  C_Timer.After = function() end
  ES.db.lastFullScan, ES.countdownTicking = nil, false
  QueryAuctionItems, CanSendAuctionQuery, GetNumAuctionItems = nil, nil, nil
  ES.ahOpen = false
  ES:RefreshScanButtons()
end)
step("instructores por rango (Forever)", function()
  -- Georgio Bolero (1346) solo enseña Experto: nunca para Oficial (75-150)
  local function Has(list, id) for _, v in ipairs(list) do if v == id then return true end end end
  local journeyman = ES.Waypoints.Trainers("Tailoring", 150)
  assert(not Has(journeyman, 1346), "Georgio Bolero no enseña Oficial")
  assert(Has(journeyman, 5567), "Sellandus enseña Oficial en Ventormenta")
  assert(Has(ES.Waypoints.Trainers("Tailoring", 225), 1346), "Georgio Bolero enseña Experto")
  assert(Has(ES.Waypoints.Trainers("Tailoring", 60), 1300), "Lawrence Schneider enseña Aprendiz y sus recetas")
  assert(Has(ES.Waypoints.Trainers("Tailoring", 300), 11052), "Timothy Worthington enseña Artesano")
end)
step("sin variables globales sueltas", function()
  assert(#LEAKS == 0, "globales: " .. table.concat(LEAKS, ", "))
end)
step("idioma inglés", function()
  -- Todas las claves L[...] del código tienen traducción al inglés
  local missing = {}
  for _, src in ipairs(SOURCES) do
    for key in src:gmatch('L%["(.-[^\\])"%]') do
      key = key:gsub('\\"', '"'):gsub("\\n", "\n")
      if key ~= "texto" and not ES.Locales.en[key] then missing[#missing + 1] = key end
    end
  end
  assert(#missing == 0, #missing .. " sin traducir: " .. table.concat(missing, " | "))
  -- Y ninguna traducción sobra (texto que ya no está en el código). Se busca en
  -- todo menos en las propias traducciones, donde siempre aparecería
  local code = {}
  for i, src in ipairs(SOURCES) do
    if not SOURCE_NAMES[i]:find("^Locales") then code[#code + 1] = src end
  end
  local all = table.concat(code, "\n")
  local unused = {}
  for key in pairs(ES.Locales.en) do
    local escaped = key:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")
    if not all:find('"' .. escaped .. '"', 1, true) then unused[#unused + 1] = key end
  end
  assert(#unused == 0, #unused .. " traducciones sin uso: " .. table.concat(unused, " | "))
  ES.lang = "en"
  ES.ApplyLocalization()
  assert(ES.L["Ruta"] == "Route" and ES.Num(2.5) == "2.5", "inglés no aplicado")
  assert(ES:ProfLabel("Leatherworking") == "Leatherworking", "profesión: " .. ES:ProfLabel("Leatherworking"))
  ES.lang = "es"
  assert(ES.Num(2.5) == "2,5" and ES.L["Ruta"] == "Ruta", "español")
end)
step("recetas de reputación", function()
  -- Heavy Timbermaw Belt pide Amistoso con Fauces de Madera (576)
  local r, n = nil, 0
  for id, rc in pairs(ES.Data.Leatherworking.recipes) do
    if rc.rep then n = n + 1 end
    if rc.scroll == 19202 then r = rc; rc.id = id end
  end
  assert(r and r.rep and r.rep[1] == 576 and r.rep[2] == 5, "falta rep en Heavy Timbermaw Belt")
  local o = { sourcedScrolls = true }
  assert(ES.Planner.LearnSkill(r, o) == nil, "sin reputación no debería estar disponible")
  local _, src = ES.Planner.LearnCost({ opts = o, prices = {} }, r)
  assert(src == "rep", "LearnCost debería decir rep, dice " .. tostring(src))
  local old = GetFactionInfoByID
  GetFactionInfoByID = function(id) if id == 576 then return "Timbermaw Hold", "", 5 end return "x", "", 4 end
  ES.repStamp = ES:RepStamp()
  local _, src2 = ES.Planner.LearnCost({ opts = o, prices = {} }, r)
  assert(src2 ~= "rep", "con Amistoso debería poder aprenderse")
  log[#log+1] = string.format("     %d recetas de peletería con reputación; con Amistoso: %s", n, tostring(src2))
  GetFactionInfoByID = old
  ES.repStamp = ES:RepStamp()
end)
step("colección de las 8 profesiones", function()
  assert(#ES.patternPages == #ES.PROFESSIONS, "páginas: " .. #ES.patternPages)
  for _, page in ipairs(ES.patternPages) do
    local cf = page.collectionFrame
    ES:RefreshCollection(cf)
    cf.search:SetText("a")
    cf.search._scripts.OnTextChanged(cf.search)
    cf.search:SetText("")
    cf.search._scripts.OnTextChanged(cf.search)
    log[#log+1] = string.format("     %s: %d recetas", cf.profKey, cf.data.total)
    if cf.profKey == "Tailoring" then
      -- Buscar tras bajar en la lista: antes las filas quedaban fuera de la vista (vacía)
      local sc = cf.scroll
      sc._vs = 0
      sc.GetVerticalScroll = function(self) return self._vs end
      sc.SetVerticalScroll = function(self, v) self._vs = v end
      sc.GetHeight = function() return 400 end
      sc._vs = 6000
      cf.search:SetText("bag")
      cf.search._scripts.OnTextChanged(cf.search)
      local drawn = 0
      for _, row in ipairs(cf.rows) do if row._shown and row.entry then drawn = drawn + 1 end end
      assert(cf.shown > 0, "'bag' no encuentra recetas de sastrería")
      assert(sc._vs == 0 and drawn > 0, "buscar tras bajar deja la lista vacía: scroll " .. sc._vs .. ", filas " .. drawn)
      log[#log+1] = string.format("     buscar 'bag' tras bajar: %d recetas, %d filas a la vista", cf.shown, drawn)
      cf.search:SetText("")
      cf.search._scripts.OnTextChanged(cf.search)
    end
  end
end)
step("portada: tarjetas de profesiones", function()
  -- El personaje tiene Peletería a 120 (tope 150)
  GetProfessions = function() return 1, nil end
  GetProfessionInfo = function(i) return "Leatherworking", nil, 120, 150, 0, 0, 165 end
  -- Atlas del libro de profesiones: existen todos menos el de Alquimia (usa el icono)
  local atlasAsked = {}
  C_Texture = { GetAtlasInfo = function(name)
    atlasAsked[#atlasAsked + 1] = name
    if name:find("^Profession%-overview") and not name:find("Alchemy") then
      return { file = 4071, leftTexCoord = 0.1, rightTexCoord = 0.6, topTexCoord = 0.2, bottomTexCoord = 0.4 }
    end
  end }
  -- Con una profesión aprendida, las demás van plegadas tras "Otras profesiones (7)"
  ES.db.othersCollapsed = nil
  ES:SelectPage("home")
  local header = ES.homePage.othersHeader
  log[#log+1] = "     plegadas: " .. tostring(header and header.text._text)
  assert(header and tostring(header.text._text):find(tostring(#ES.PROFESSIONS - 1)), "falta la fila de otras profesiones")
  assert(#atlasAsked == 1, "plegadas no deberían pintarse: " .. #atlasAsked)
  -- Al pulsarla se despliegan (y se recuerda)
  atlasAsked = {}
  header._scripts.OnClick(header)
  assert(ES.db.othersCollapsed == false, "no recuerda que están desplegadas")
  log[#log+1] = "     atlas pedidos: " .. table.concat(atlasAsked, ", ")
  -- Uno de fondo por tarjeta + el dibujo de las secundarias (cocina, primeros auxilios y pesca)
  assert(#atlasAsked == ES.homePage.shownCards + 3, "atlas pedidos: " .. #atlasAsked)
  -- Escalar: arrastrar la esquina al 150% del tamaño amplía la ventana x1,5 en
  -- ancho y alto (en el simulacro: marco de 100x100 en (100,100), escala de UI 100)
  local f = CraftersJournalMainFrame
  local savedCursor = GetCursorPosition
  GetCursorPosition = function() return 25000, -5000 end
  f.resize._scripts.OnMouseDown(f.resize, "LeftButton")
  f.resize._scripts.OnUpdate(f.resize)
  f.resize._scripts.OnMouseUp(f.resize)
  assert(math.abs(f:GetScale() - 1.5) < 0.001, "escala " .. tostring(f:GetScale()))
  assert(ES.db.frameScale == 1.5, "no guardó la escala")
  GetCursorPosition = function() return 99999, -99999 end -- más allá del máximo
  f.resize._scripts.OnMouseDown(f.resize, "LeftButton")
  f.resize._scripts.OnUpdate(f.resize)
  assert(f:GetScale() <= 1.8, "superó la escala máxima")
  f.resize._scripts.OnMouseUp(f.resize)
  f.resize._scripts.OnDoubleClick(f.resize)
  assert(f:GetScale() == 1 and ES.db.frameScale == 1, "doble clic no volvió a escala 1")
  GetCursorPosition = savedCursor
  C_Texture = nil
  local cards = {}
  for _, c in ipairs(ES.homePage.cards) do if c._shown ~= false then cards[#cards + 1] = c end end
  -- Solo las 8 profesiones: Ganar dinero, la colección y Subastas son pestañas
  assert(ES.homePage.shownCards == #ES.PROFESSIONS, "tarjetas: " .. tostring(ES.homePage.shownCards))
  local first = ES.homePage.cards[1]
  log[#log+1] = "     1ª: " .. tostring(first.name._text) .. " | " .. tostring(first.cost._text) .. " | " .. tostring(first.level._text) .. " | " .. tostring(first.note._text)
  -- Orden: secciones (tuyas / demás) y dentro el fijo de ES.PROFESSIONS; el mismo en Patterns
  local order = {}
  for i, c in ipairs(ES.homePage.cards) do if c._shown ~= false and c.key then order[#order + 1] = c.key end end
  -- Primero las que tienes, luego las demás; en cada sección, el orden de ES.PROFESSIONS
  local want = {}
  for _, learnedPass in ipairs({ true, false }) do
    for _, p in ipairs(ES.PROFESSIONS) do
      local has = ES.Data[p.key] and ES:GetProfessionSkill(ES.Data[p.key].skillLine) ~= nil
      if ES:ProfessionVisible(p) and has == learnedPass then want[#want + 1] = p.key end
    end
  end
  assert(table.concat(order, ",") == table.concat(want, ","), "orden de la portada: " .. table.concat(order, ","))
  log[#log+1] = "     orden: " .. table.concat(order, ", ")
  local lw
  for _, c in ipairs(ES.homePage.cards) do if c.key == "Leatherworking" then lw = c end end
  assert(tostring(lw.level._text):find("%d+|r / %d+"), "nivel no mostrado: " .. tostring(lw.level._text))
  -- Pestañas laterales: cada una abre su página y queda marcada
  local mf = ES:GetMainFrame()
  assert(#mf.tabs == 7, "pestañas: " .. #mf.tabs)
  for _, tab in ipairs(mf.tabs) do
    tab._scripts.OnClick(tab)
    assert(ES.db.lastPage == tab.key, "la pestaña " .. tab.key .. " no abre su página")
    tab._scripts.OnEnter(tab)
  end
  ES:SelectPage("Leatherworking") -- una profesión pertenece a la pestaña de subir
  assert(mf.backTarget == "home", "Volver de una profesión")
  ES:SelectPage("home")
  for i, c in ipairs(ES.homePage.cards) do
    c._scripts.OnEnter(c) c._scripts.OnLeave(c)
    log[#log+1] = string.format("     %d. %s | %s | %s", i, tostring(c.name._text), tostring(c.cost._text):gsub("|T[^|]+|t", ""), tostring(c.level._text))
  end
  -- El coste de la tarjeta es el mismo que el del detalle (de 120 a 225)
  local page
  for _, p in ipairs(ES.professionPages) do if p.profKey == "Leatherworking" then page = p end end
  page._scripts.OnShow(page) -- detecta el nivel 120 del personaje
  assert(page.from == 120, "no detectó el nivel del personaje")
  page.toBox._text = "225"
  ES:CalculatePlan(page)
  local plan = ES.Planner:Plan(ES.Data.Leatherworking, ES:PlanOptions("Leatherworking", 120, 225, 150))
  assert(math.abs(page.plan.net - plan.net) < 1, "coste distinto en portada y detalle")
  -- Con otro objetivo guardado (p. ej. 150) la tarjeta usa ese mismo objetivo
  page.toBox._text = "150"
  ES:CalculatePlan(page)
  ES:SelectPage("home")
  local card
  for _, c in ipairs(ES.homePage.cards) do if c.key == "Leatherworking" then card = c end end
  assert(tostring(card.level._text):find("/ 150"), "la tarjeta no muestra el objetivo: " .. tostring(card.level._text))
  local detailCost = page.plan and page.plan.net or 0
  log[#log+1] = "     objetivo 150: tarjeta " .. tostring(card.cost._text):gsub("|T[^|]+|t", "") .. " | detalle " .. tostring(detailCost)
  local cardPlan = ES.Planner:Plan(ES.Data.Leatherworking, ES:PlanOptions("Leatherworking", 120, ES:ProfessionTarget("Leatherworking"), 150))
  assert(math.abs(cardPlan.net - detailCost) < 1, "tarjeta y detalle no coinciden con objetivo 150")
  page.toBox._text = "225"
  ES:CalculatePlan(page)
  -- Clic en un paso: abre la receta en la profesión; "Fabricar N" fabrica (C_TradeSkillUI)
  local opened, crafted
  C_TradeSkillUI = { OpenRecipe = function(id) opened = id end, CraftRecipe = function(id, n) crafted = { id, n } end }
  local savedKnown = ES.IsRecipeKnown
  ES.IsRecipeKnown = function() return true end
  ES:RenderPlan(page)
  local craftLine
  -- (un paso de la ruta, no "Fabrica N×" de un material: esos se prueban aparte)
  for _, l in ipairs(page.lines) do if l.craftCount and not l.skipTip then craftLine = l break end end
  assert(craftLine, "con la opción por defecto, el clic en un paso debería fabricar")
  craftLine.onClick() -- un solo clic: abre la receta y fabrica lo que falta
  assert(opened == page.plan.steps[1].id, "el clic no abrió la receta del paso")
  assert(crafted and crafted[1] == page.plan.steps[1].id and crafted[2] == page.plan.steps[1].crafts, "el clic no fabricó lo del paso")
  log[#log+1] = "     fabricar: " .. tostring(craftLine.title)
  -- Opción desactivada (Opciones > AddOns): el clic solo abre la receta
  local op = ES.optionsPanel
  op._scripts.OnShow(op)
  op.craftCheck:SetChecked(false)
  op.craftCheck._scripts.OnClick(op.craftCheck)
  assert(ES.db.autoCraft == false, "la opción no se guardó")
  ES:RenderPlan(page)
  crafted, opened = nil, nil
  for _, l in ipairs(page.lines) do assert(not l.craftCount, "con la opción desactivada no debería fabricar") end
  for _, l in ipairs(page.lines) do if l.onClick and l.item then l.onClick() break end end
  assert(opened and not crafted, "con la opción desactivada el clic solo abre la receta")
  ES.db.autoCraft = nil
  ES.IsRecipeKnown, C_TradeSkillUI = savedKnown, nil
  ES:RenderPlan(page)
  -- ✕ en un paso: la receta sale de la ruta y una fila permite recuperarla
  local firstStep = page.plan.steps[1].id
  local skipRow
  -- (la de un paso de receta, no la de fabricar un material: esa lo compra hecho)
  for _, row in ipairs(page.rows) do if row.onSkip and not row.skipTip and row._shown ~= false then skipRow = row break end end
  assert(skipRow, "los pasos de la ruta deberían tener la ✕")
  skipRow.skip._scripts.OnEnter(skipRow.skip)
  skipRow.skip._scripts.OnClick(skipRow.skip)
  assert(ES.db.prof.Leatherworking.excluded and next(ES.db.prof.Leatherworking.excluded), "no se quitó la receta")
  for _, st in ipairs(page.plan.steps) do
    assert(not ES.db.prof.Leatherworking.excluded[st.id], "la receta quitada sigue en la ruta: " .. st.recipe.name)
  end
  local restore
  for _, l in ipairs(page.lines) do if l.title and l.title:find("Recetas quitadas") then restore = l end end
  assert(restore, "falta la fila para recuperar las recetas quitadas")
  log[#log+1] = "     quitar receta: " .. restore.title .. " · primer paso ahora " .. page.plan.steps[1].recipe.name
  restore.onClick()
  assert(not ES.db.prof.Leatherworking.excluded and page.plan.steps[1].id == firstStep, "no se recuperó la ruta")
  -- Lista de la compra: cuántos tienes y cuántos faltan; se actualiza al cambiar las bolsas
  local bags = 0
  GetItemCount = function() return bags end
  page.view = "shop"
  ES:RenderPlan(page)
  local buyLine
  for _, l in ipairs(page.lines) do if l.sub and l.sub:find("Tienes") then buyLine = l break end end
  assert(buyLine, "la lista de la compra debería decir cuántos tienes")
  assert(buyLine.sub:find("faltan"), "sin nada en las bolsas deberían faltar: " .. buyLine.sub)
  bags = 100000
  ES:RefreshAfterBags()
  for _, l in ipairs(page.lines) do
    if l.item == buyLine.item and l.sub then
      assert(not l.sub:find("faltan"), "con todo en las bolsas no debería faltar nada: " .. l.sub)
    end
  end
  log[#log+1] = "     lista de la compra: " .. buyLine.title
  -- Clic en un material de la AH: sin la AH abierta marca el subastador; con ella, lo busca
  local savedSearch, savedOpen = ES.SearchAuction, ES.IsAuctionHouseOpen
  ES.IsAuctionHouseOpen = function() return false end
  ES:RenderPlan(page)
  local ahLine
  for _, l in ipairs(page.lines) do if l.go and not l.onClick and l.sub and l.sub:find("AH ·") then ahLine = l break end end
  assert(ahLine, "sin la AH abierta, el clic en un material de la AH debería marcar el subastador")
  local searched
  ES.SearchAuction = function(_, id) searched = id end
  ES.IsAuctionHouseOpen = function() return true end
  ES:RenderPlan(page)
  for _, l in ipairs(page.lines) do if l.item == ahLine.item and l.onClick then l.onClick() end end
  assert(searched == ahLine.item, "con la AH abierta, el clic debería buscar el objeto")
  ES.SearchAuction, ES.IsAuctionHouseOpen = savedSearch, savedOpen
  -- AH moderna: abre la compra del material con la cantidad que falta ya puesta
  local selected, qtySet
  local savedAHF, savedCAH = AuctionHouseFrame, C_AuctionHouse
  AuctionHouseFrame = { SelectBrowseResult = function(_, r) selected = r.itemKey end,
    CommoditiesBuyFrame = { IsShown = function() return true end,
      BuyDisplay = { SetQuantitySelected = function(_, q) qtySet = q end } } }
  C_AuctionHouse = { MakeItemKey = function(id) return { itemID = id } end }
  ES:OpenAuctionBuy(ahLine.item, 7)
  assert(selected and selected.itemID == ahLine.item and qtySet == 7, "no abrió la compra con la cantidad puesta")
  AuctionHouseFrame, C_AuctionHouse = savedAHF, savedCAH
  -- Empezar ruta: comprar (cambian las bolsas) no cambia la ruta ni su coste
  page.view = "route"
  bags = 0
  ES:CalculatePlan(page)
  local before = page.plan
  page.routeButton._scripts.OnEnter(page.routeButton)
  page.routeButton._scripts.OnClick(page.routeButton)
  local lock = ES.db.prof.Leatherworking.lock
  assert(lock and lock.choice and lock.to == 225, "no se fijó la ruta")
  local net = page.plan.net
  local savedBags = ES.db.prof.Leatherworking.useBags
  ES.db.prof.Leatherworking.useBags = true
  bags = 500
  ES:ClearHomeCache()
  ES:RefreshAfterBags()
  ES:CalculatePlan(page)
  assert(page.plan == before and page.plan.net == net, "la ruta fijada cambió al comprar")
  assert(tostring(page.status._text):find("Ruta en curso"), "falta el aviso de ruta en curso: " .. tostring(page.status._text))
  -- Tras recargar se rehace igual: mismas recetas y mismo coste
  ES.lockedPlans = {}
  local rebuilt = ES:LockedPlan("Leatherworking")
  assert(#rebuilt.steps == #before.steps and rebuilt.steps[1].id == before.steps[1].id, "la ruta fijada cambió al recargar")
  assert(math.abs(rebuilt.net - net) < 1, "el coste de la ruta fijada cambió al recargar")
  log[#log+1] = string.format("     ruta fijada: %d pasos, %s", #rebuilt.steps, tostring(page.routeButton._text))
  -- Escaneo nuevo con la ruta fijada: ni la ruta ni sus totales cambian, aunque se
  -- rehaga (recarga); "Actualizar precios" la recalcula con el escaneo nuevo
  local scanKey = ES:RealmKey()
  local oldScan = ES.db.scans[scanKey]
  local newItems = {}
  for id, e in pairs(oldScan.items) do
    local c = {}
    for k, v in pairs(e) do c[k] = v end
    if c.minUnit then c.minUnit = c.minUnit * 3 end
    if c.ladder then
      c.ladder = {}
      for i, v in ipairs(e.ladder) do c.ladder[i] = (i % 2 == 1) and v * 3 or v end
    end
    newItems[id] = c
  end
  ES.db.scans[scanKey] = { time = oldScan.time + 3600, total = oldScan.total, unique = oldScan.unique, items = newItems }
  ES.lockedPlans = {}
  local frozen = ES:LockedPlan("Leatherworking")
  assert(math.abs(frozen.net - net) < 1, string.format("la ruta fijada cambió de coste con el escaneo nuevo: %d -> %d", net, frozen.net))
  ES:RenderPlan(page)
  assert(page.pricesButton._shown ~= false, "falta Actualizar precios con un escaneo nuevo")
  page.pricesButton._scripts.OnEnter(page.pricesButton)
  page.pricesButton._scripts.OnClick(page.pricesButton)
  local updated = ES:LockedPlan("Leatherworking")
  assert(updated.net > net + 1 and updated.steps[1].id == frozen.steps[1].id, "Actualizar precios no usó el escaneo nuevo con la misma ruta")
  log[#log+1] = string.format("     precios: fijada %d, actualizada %d (mismas recetas)", frozen.net, updated.net)
  ES.db.scans[scanKey] = oldScan
  ES:RefreshRoutePrices("Leatherworking")
  -- Subes de nivel fabricando: el paso actual se resalta y dice cuántas faltan
  local savedDetect = ES.DetectSkill
  local s1 = rebuilt.steps[1]
  local newLevel = s1.from + math.max(1, math.floor((s1.to - s1.from) / 2))
  ES.DetectSkill = function(_, p) p.from = newLevel end
  page.view = "route"
  local knownBefore = ES.IsRecipeKnown
  ES.IsRecipeKnown = function() return false end
  ES:RefreshAfterSkill()
  local cur
  -- Sin saber aún la receta del paso, lo que toca es aprenderla (o, antes, fabricar
  -- el material que haga falta: "Fabrica N× ...")
  if s1.fee and s1.fee > 0 then
    for _, l in ipairs(page.lines) do if l.current then cur = l end end
    assert(cur and (cur.skipTip or (cur.title:find("Entrenar") or cur.title:find("Comprar"))) ~= nil,
      "sin saber la receta, el paso actual debería ser aprenderla: " .. tostring(cur and cur.title))
  end
  -- Sabiéndola y con lo que hay que fabricar antes ya hecho, el de fabricar, con lo que queda
  ES.IsRecipeKnown = function() return true end
  local countBefore = ES.ItemCount
  ES.ItemCount = function() return 1000000 end
  ES:RenderPlan(page)
  cur = nil
  for _, l in ipairs(page.lines) do if l.current then cur = l end end
  ES.IsRecipeKnown, ES.ItemCount = knownBefore, countBefore
  -- (lo que llevas en puntos, no en fabricaciones de esa receta: otras también suben)
  assert(cur and cur.sub:find("puntos") and cur.sub:find("fabricaciones más"), "falta el paso actual con lo que queda: " .. tostring(cur and cur.sub))
  local curRow
  for _, row in ipairs(page.rows) do if row._shown ~= false and row.title._text == cur.title then curRow = row end end
  log[#log+1] = "     paso actual: " .. tostring(cur.level) .. " · " .. tostring(cur.sub)
  ES.DetectSkill = savedDetect
  ES:DetectSkill(page)
  -- Llegar al objetivo no libera la ruta: se queda como completada
  local lp = ES.db.prof.Leatherworking
  ES.DetectSkill = function(_, p) p.from = 225 end
  ES:RefreshAfterSkill()
  assert(lp.lock and lp.lock.completed, "al llegar al objetivo la ruta debería quedar completada, no liberarse")
  assert(tostring(page.status._text):find("completada"), "falta el aviso de ruta completada: " .. tostring(page.status._text))
  ES.DetectSkill = savedDetect
  lp.lock.completed = nil
  ES:DetectSkill(page)
  ES:CalculatePlan(page)
  -- Sin registro de dinero: la franja no tiene fila "Real" y Profit no cuenta vendidos
  local buyItem, sellItem = rebuilt.shopping[1].itemID, nil
  for _, st in ipairs(rebuilt.steps) do if st.sale then sellItem = st.sale.itemID break end end
  local counts = { [buyItem] = 0, [sellItem] = 10 }
  GetItemCount = function(id) return counts[id] or 0 end
  GetMerchantNumItems = function() return 1 end
  GetMerchantItemID = function() return buyItem end
  GetMerchantItemInfo = function() return "x", nil, 300, 3 end -- 3 por 300: 100 cada uno
  ES:RenderPlan(page)
  assert(page.real == nil, "la franja no debería tener la fila Real")
  page.view = "profit"
  ES:RenderPlan(page)
  local sellLine
  for _, l in ipairs(page.lines) do if l.item == sellItem then sellLine = l end end
  assert(sellLine and not (sellLine.sub or ""):find("vendidos"), "Profit no debería contar vendidos")
  assert(sellLine.go, "sin vendedor ni AH abiertos, el clic marca dónde venderlo")
  assert(sellLine.title:find("en bolsas"), "Profit debería decir cuántos llevas en las bolsas: " .. sellLine.title)
  -- Sin correo: lo comprado en la AH no cuenta hasta que está en las bolsas
  assert(ES.Ledger.InMail == nil and ES.Ledger.NoteAHPurchase == nil, "el correo ya no debería contar")
  -- Lista de la compra con la ruta empezada: secciones según lo que llevas ahora
  page.view = "shop"
  ES:RenderPlan(page)
  local sections, haveSection = {}, false
  for _, l in ipairs(page.lines) do
    if l.section then sections[#sections + 1] = l.section end
    if l.section == "Ya lo tienes" then haveSection = true end
  end
  local lastLine = page.lines[#page.lines]
  assert(lastLine.total and lastLine.title == "Te falta por comprar", "con la ruta empezada, el total es lo que falta: " .. tostring(lastLine.title))
  log[#log+1] = "     lista con ruta empezada: " .. table.concat(sections, " | ")
  page.view = "route"
  -- Anunciar en la AH: a platas enteras (la AH de Forever no admite cobres)
  assert(ES.Ledger.PostPrice(2070) == 2000 and ES.Ledger.PostPrice(50) == 100, "precio de anuncio en platas enteras")
  -- Con la AH abierta y nada en las bolsas, el clic avisa en vez de marcar el subastador
  -- (y sin repetir "no llevas ninguno": el título ya dice "0 en bolsas")
  local savedOpen = ES.IsAuctionHouseOpen
  ES.IsAuctionHouseOpen = function() return true end
  page.view = "profit"
  ES:RenderPlan(page)
  for _, l in ipairs(page.lines) do
    if l.title and l.title:find("0 en bolsas") and l.onClick then
      assert(not l.go, "con la AH abierta y sin el objeto, el clic no debería marcar el subastador")
      assert(not (l.sub or ""):find("no llevas ninguno"), "repite que no llevas ninguno")
      l.onClick()
    end
  end
  page.view = "route"
  ES.IsAuctionHouseOpen = savedOpen
  -- Vendedor abierto con la ruta empezada: ventana al lado con lo que falta y "Comprar todo"
  local bought = {}
  MerchantFrame = CreateFrame("Frame")
  GetMoney = function() return 10000000 end
  C_MerchantFrame = { GetItemInfo = function() return { price = 300, stackCount = 3, numAvailable = -1, isPurchasable = true } end }
  BuyMerchantItem = function(i, n) bought[#bought + 1] = n end
  counts[buyItem] = 0
  ES.VendorShop:Refresh()
  local vp = CraftersJournalVendorPanel
  assert(vp and vp.rows[1].entry and vp.rows[1].entry.itemID == buyItem, "la ventana del vendedor no lista lo que falta")
  assert(vp.rows[1].entry.qty % 3 == 0, "se compra en los lotes del vendedor: " .. vp.rows[1].entry.qty)
  vp.rows[1]._scripts.OnEnter(vp.rows[1])
  vp.buyAll._scripts.OnClick(vp.buyAll)
  assert(#bought > 0 and bought[1] > 0, "Comprar todo no compró nada")
  -- Pulsar su fila mientras se compra no lo compra dos veces
  local queued = #ES.VendorShop.queue
  ES.VendorShop:Buy({ itemID = buyItem, qty = 3, batch = 3, price = 300, cost = 300 })
  assert(#ES.VendorShop.queue == queued, "compró dos veces el mismo material")
  log[#log+1] = string.format("     vendedor: %s · primera compra de %d", tostring(vp.buyAll._text), bought[1])
  -- Lo que la vista Profit dice que vendas al vendedor, en la misma ventana, con "Vender todo"
  local savedBag, savedSell, savedOpen2 = ES.Ledger.BagCount, ES.Ledger.SellToVendor, ES.Ledger.MerchantOpen
  local sold = {}
  ES.Ledger.BagCount = function(id) return counts[id] or 0 end
  ES.Ledger.SellToVendor = function(_, id, n) sold[#sold + 1] = { id, n } return n end
  ES.Ledger.MerchantOpen = function() return true end
  ES.VendorShop.queue, ES.VendorShop.pumping = {}, nil
  local sellList = ES.VendorShop:SellList()
  if #sellList > 0 then
    ES.VendorShop:Refresh()
    local sellRow
    for _, row in ipairs(vp.rows) do if row.kind == "sell" and row._shown ~= false then sellRow = row break end end
    assert(sellRow and sellRow.entry.n > 0, "falta la fila de vender en la ventana del vendedor")
    sellRow._scripts.OnEnter(sellRow)
    assert(vp.sellAll._shown ~= false and tostring(vp.sellAll._text):find("Vender todo"), "falta Vender todo")
    vp.sellAll._scripts.OnClick(vp.sellAll)
    assert(#sold > 0 and sold[1][1] == sellList[1].itemID, "Vender todo no vendió")
    log[#log+1] = string.format("     vendedor: %s · vende %d de %s", tostring(vp.sellAll._text), sold[1][2], ES:DataItemName(sold[1][1]) or sold[1][1])
  else
    log[#log+1] = "     vendedor: nada que vender en esta ruta"
  end
  ES.Ledger.BagCount, ES.Ledger.SellToVendor, ES.Ledger.MerchantOpen = savedBag, savedSell, savedOpen2
  ES.VendorShop.selling = nil
  ES.VendorShop.queue, ES.VendorShop.pumping = {}, nil
  MerchantFrame, C_MerchantFrame, BuyMerchantItem, GetMoney = nil, nil, nil, nil
  page.view = "route"
  GetMerchantNumItems, GetMerchantItemID, GetMerchantItemInfo = nil, nil, nil
  -- Portada: la tarjeta de la profesión con la ruta en curso se distingue
  ES:SelectPage("home")
  ES:RenderHome()
  local activeCard
  for _, c in ipairs(ES.homePage.cards) do if c.key == "Leatherworking" then activeCard = c end end
  assert(activeCard and activeCard.active and tostring(activeCard.note._text):find("Ruta en curso"),
    "la tarjeta no indica la ruta en curso: " .. tostring(activeCard and activeCard.note._text))
  activeCard._scripts.OnEnter(activeCard)
  activeCard._scripts.OnLeave(activeCard)
  log[#log+1] = "     portada: " .. tostring(activeCard.note._text)
  ES:SelectPage("Leatherworking")
  -- Con lo que llevas (bolsas activadas): una cita que solo informa (no se pulsa).
  -- Con alternativas de mentira: no compensa -> "mejor vender"; compensa con la
  -- ruta fijada -> "Recalcular ruta"; compensa sin fijar -> nada (ya va en la ruta)
  local function FindBagsLine()
    for _, l in ipairs(page.lines) do if l.quote then return l end end
  end
  local savedAlt = ES.Planner.BagsAlternative
  local fake = { saving = 380, value = 900 }
  ES.Planner.BagsAlternative = function(data, plan, owned, from, excluded)
    local st = plan.steps[#plan.steps]
    if excluded and excluded[st.id] then return nil end
    local r = data.recipes[st.id]
    return { id = st.id, recipe = r, from = st.from, to = st.to, crafts = 3, fee = 0, gold = 120, spend = 150, value = fake.value,
      routeCost = 500, saving = fake.saving, use = { { itemID = r.r[1][1], qty = 6, value = fake.value } } }
  end
  ES:RenderPlan(page)
  local bagsLine = FindBagsLine()
  assert(bagsLine and bagsLine.quote:find("Con lo que llevas podrías hacer") and bagsLine.quote:find("Vender lo tuyo"),
    "falta la cita de Con lo que llevas (no compensa)")
  assert(not bagsLine.onClick and not bagsLine.tooltip, "la cita no debería pulsarse")
  log[#log+1] = "     con lo que llevas: " .. bagsLine.quote:gsub("\n", " / ")
  -- ✕ en la cita: deja de salir (la ruta no cambia) y se recupera con "Recetas quitadas"
  local lockBefore = ES.db.prof.Leatherworking.lock
  assert(bagsLine.onSkip, "la cita debería tener la ✕ para descartarla")
  bagsLine.onSkip()
  assert(not FindBagsLine(), "la cita descartada sigue saliendo")
  assert(ES.db.prof.Leatherworking.lock == lockBefore, "descartar la cita no debería soltar la ruta")
  local restoreNote
  for _, l in ipairs(page.lines) do if l.title and l.title:find("Avisos ocultos") then restoreNote = l end end
  assert(restoreNote, "falta la fila para recuperar la cita descartada")
  restoreNote.onClick()
  assert(FindBagsLine(), "la cita no volvió al recuperarla")
  assert(ES.db.prof.Leatherworking.lock == lockBefore, "recuperar la cita no debería soltar la ruta")
  fake.saving, fake.value = 900, 100
  ES:RenderPlan(page)
  bagsLine = FindBagsLine()
  assert(bagsLine and bagsLine.quote:find("Recalcular ruta"), "con la ruta fijada, la cita debería pedir recalcular")
  -- Aprendes la receta (instructor) con la ruta fijada: su fila de aprender queda hecha
  local learnRows = 0
  for _, l in ipairs(page.lines) do if l.onSkip and l.title and (l.title:find("Entrenar") or l.title:find("Comprar receta")) then learnRows = learnRows + 1 end end
  local knownBefore = ES.IsRecipeKnown
  ES.IsRecipeKnown = function() return true end
  ES:RefreshAfterLearn()
  local learned, pendingLearn = 0, 0
  for _, l in ipairs(page.lines) do
    if l.sub and l.sub:find("Aprendida") then learned = learned + 1 end
    if l.onSkip and l.title and (l.title:find("Entrenar") or l.title:find("Comprar receta")) then pendingLearn = pendingLearn + 1 end
  end
  ES.IsRecipeKnown = knownBefore
  assert(pendingLearn == 0 and learned == learnRows, string.format("al aprenderla, la fila no quedó hecha (%d de %d)", learned, learnRows))
  log[#log+1] = string.format("     aprendidas: %d filas de aprender marcadas como hechas", learned)
  -- Un doble clic en Empezar ruta no la suelta; Recalcular ruta (más tarde) sí
  page.routeStartedAt = GetTime and GetTime() or 0
  page.routeButton._scripts.OnClick(page.routeButton)
  assert(ES.db.prof.Leatherworking.lock, "un doble clic en Empezar ruta la soltó")
  page.routeStartedAt = nil
  page.routeButton._scripts.OnClick(page.routeButton)
  assert(not ES.db.prof.Leatherworking.lock, "Recalcular ruta no la liberó")
  ES:RenderPlan(page)
  assert(not FindBagsLine(), "sin fijar, lo que compensa ya va en la ruta: no hay cita")
  ES.Planner.BagsAlternative = savedAlt
  ES.db.prof.Leatherworking.useBags = savedBags
  GetItemCount = nil
  ES:ClearHomeCache()
  ES:CalculatePlan(page)
  ES:SelectPage("home")
  -- Pulsar la tarjeta abre la profesión; Volver regresa
  local lwCard
  for _, c in ipairs(ES.homePage.cards) do if c.key == "Leatherworking" then lwCard = c end end
  lwCard._scripts.OnClick(lwCard)
  assert(ES.db.lastPage == "Leatherworking", "no abrió la profesión")
  CraftersJournalMainFrame.back._scripts.OnClick(CraftersJournalMainFrame.back)
  assert(ES.db.lastPage == "home", "Volver no regresó a la portada")
  GetProfessions, GetProfessionInfo = nil, nil
end)
step("cabecera: buscador e idioma", function()
  local f = CraftersJournalMainFrame
  assert(f.title._text == "Crafter's Journal", "título: " .. tostring(f.title._text))
  local box, list = f.globalSearch, f.searchResults
  box._text = "pelet"
  box._scripts.OnTextChanged(box)
  assert(list.results[1] and list.results[1].kind == "prof" and list.results[1].profKey == "Leatherworking", "no encontró Peletería")
  box._text = "armor kit"
  box._scripts.OnTextChanged(box)
  local recipe
  for _, r in ipairs(list.results) do if r.kind == "recipe" and r.profKey == "Leatherworking" then recipe = r break end end
  assert(recipe, "no encontró recetas de armor kit")
  log[#log+1] = string.format("     'armor kit': %d resultados, 1º %s (%s)", #list.results, list.results[1].text, list.results[1].profKey)
  -- Elegir una receta: abre su ficha en la Colección, con la lista filtrada por ella
  local chosen = list.rows[1].result
  list.rows[1]._scripts.OnClick(list.rows[1])
  assert(ES.db.lastPage == "pattern:" .. chosen.profKey, "no abrió la colección: " .. tostring(ES.db.lastPage))
  local cf = f.pages["pattern:" .. chosen.profKey].collectionFrame
  assert(cf.search._text == chosen.recipe.name, "no filtró por la receta")
  assert(cf.selectedID == chosen.id, "no eligió la receta")
  -- Sin resultados: la fila no hace nada al pulsarla
  box._text = "zzzzqq"
  box._scripts.OnTextChanged(box)
  list.rows[1]._scripts.OnClick(list.rows[1])
  -- Botón Escanear: durante el escaneo muestra el % de progreso y al acabar vuelve a "Escanear"
  local savedBusy = ES.Scanner.IsBusy
  ES.Scanner.IsBusy = function() return true end
  ES.Scanner.progress = 0.05
  ES:OnScanProgress()
  assert(f.scanButton._text == "5%", "progreso inicial: " .. tostring(f.scanButton._text))
  ES.Scanner.progress = 0.537
  ES:OnScanProgress()
  log[#log+1] = "     botón durante el escaneo: " .. tostring(f.scanButton._text)
  assert(f.scanButton._text == "53%", "progreso: " .. tostring(f.scanButton._text))
  ES.Scanner.IsBusy = savedBusy
  ES:RefreshScanButtons()
  assert(f.scanButton._text == "Escanear", "al acabar el botón vuelve a decir Escanear")
  -- "Último escaneo: hace N min" junto al botón (sin intentos cancelados de pasos anteriores)
  ES.db.lastScanFail = nil
  ES:UpdateLastScan()
  log[#log+1] = "     junto al botón: " .. tostring(f.lastScan._text)
  assert(tostring(f.lastScan._text):find("Último escaneo") or f.lastScan._text == "Sin escanear", "último escaneo")
  -- Idioma: desplegable con Español
  f.languageButton._scripts.OnClick(f.languageButton)
  f.languageButton._scripts.OnEnter(f.languageButton)
  -- Informar de un error: ventana con el enlace del Discord listo para copiar
  assert(f.reportButton, "falta el botón Informar")
  f.reportButton._scripts.OnEnter(f.reportButton)
  f.reportButton._scripts.OnClick(f.reportButton)
  local d = CraftersJournalReportDialog
  assert(d, "no se creó la ventana de informar")
  d._scripts.OnShow(d)
  assert(d.box._text == ES.DISCORD_URL, "el enlace del Discord: " .. tostring(d.box._text))
  d.box._scripts.OnTextChanged(d.box, true)
  assert(d.box._text == ES.DISCORD_URL, "el enlace no se puede editar")
  log[#log+1] = "     informar: " .. tostring(d.title._text) .. " · " .. d.box._text
  d.ok._scripts.OnClick(d.ok)
  ES:SelectPage("home")
end)
step("ir al instructor o vendedor más cercano", function()
  local page
  for _, p in ipairs(ES.professionPages) do if p.profKey == "Leatherworking" then page = p end end
  page.from = 1
  page.toBox._text = "75"
  ES:CalculatePlan(page)
  ES:SelectProfessionView(page, "route")
  local trainRow
  for i = 1, #page.lines do
    if (page.lines[i].title or ""):find("^Entrenar ") and page.lines[i].go then trainRow = page.rows[i] break end
  end
  assert(trainRow, "no hay fila de Entrenar con camino")
  -- Sin Questie: solo avisa, no rompe
  PRINTED = {}
  local savedPrint = ES.Print
  ES.Print = function(_, msg) PRINTED[#PRINTED + 1] = msg end
  trainRow._scripts.OnClick(trainRow)
  -- Sin Questie también funciona: los PNJ vienen en Data/Sources.lua
  assert(PRINTED[1] and not PRINTED[1]:find("Instala Questie"), "sin Questie debería funcionar con los datos propios: " .. tostring(PRINTED[1]))
  log[#log+1] = "     sin Questie: " .. tostring(PRINTED[1])
  -- Respaldo con QuestieDB (si faltaran los datos propios): se quitan un momento
  local savedNPCs = ES.Data.NPCs
  ES.Data.NPCs = nil
  ES.Waypoints.ResetCache()
  -- QuestieDB simulado: instructores de Peletería de Aprendiz (en Forever cada rango
  -- tiene los suyos): 11096 Ventormenta, 5811 Orgrimmar, 1466 Forjaz
  local NPCS = {
    [11096] = { "Randal Worth", { [1519] = { { 46, 50 } } }, 1519, "A" },
    [5811] = { "Kamari", { [1637] = { { 80, 40 } } }, 1637, "H" },
    [1466] = { "Gretta Finespindle", { [1537] = { { 40, 20 } } }, 1537, "A" },
  }
  LibQuestieDB = {
    RequireContract = function() return true end,
    Meta = { ItemMeta = { itemKeys = { vendors = 1 } },
             NpcMeta = { npcKeys = { name = 1, spawns = 2, zoneID = 3, friendlyToFaction = 4 } } },
    Item = { GetAll = function(id) return { {} } end },
    Npc = { GetAll = function(id) return NPCS[id] end },
    Support = { Get = function() return { private = {
      areaIdToUiMapId = "return { [1519] = 1453, [1637] = 1454, [1537] = 1455 }",
      subZoneToParentZone = "return {}" } } end },
  }
  local WORLD = { [1453] = { 0, 100, 100 }, [1454] = { 1, 0, 0 }, [1455] = { 0, 5000, 5000 } }
  CreateVector2D = function(x, y) return { x = x, y = y } end
  C_Map = {
    GetWorldPosFromMapPos = function(map, v) local w = WORLD[map] return w[1], { GetXY = function() return w[2], w[3] end } end,
    GetMapInfo = function(map) return { name = "Mapa " .. map } end,
    CanSetUserWaypointOnMap = function() return true end,
    SetUserWaypoint = function(point) WAYPOINT = point end,
    GetBestMapForUnit = function() return 1453 end,
    GetPlayerMapPosition = function() return nil end,
  }
  UiMapPoint = { CreateFromCoordinates = function(map, x, y) return { map = map, x = x, y = y } end }
  C_SuperTrack = { SetSuperTrackedUserWaypoint = function(v) SUPERTRACK = v end }
  UnitPosition = function() return 90, 90, 0, 0 end -- en Ventormenta
  UnitFactionGroup = function() return "Alliance" end
  InCombatLockdown = function() return false end
  trainRow._scripts.OnEnter(trainRow)
  trainRow._scripts.OnClick(trainRow)
  assert(WAYPOINT and WAYPOINT.map == 1453, "no marcó el instructor más cercano: " .. tostring(WAYPOINT and WAYPOINT.map))
  assert(math.abs(WAYPOINT.x - 0.46) < 0.001 and math.abs(WAYPOINT.y - 0.5) < 0.001, "coordenadas mal")
  assert(SUPERTRACK == true, "no puso el punto en seguimiento")
  log[#log+1] = "     clic en '" .. tostring(trainRow.title._text) .. "': " .. tostring(PRINTED[#PRINTED])
  -- La Horda no cuenta para la Alianza aunque esté más cerca
  UnitPosition = function() return 1, 1, 0, 1 end -- otro continente que 1453
  assert(ES.Waypoints.Nearest({ 1385, 3365 }) ~= 3365, "eligió un PNJ de la Horda")
  ES.Data.NPCs = savedNPCs
  -- Con los datos propios: el instructor de Peletería de la Alianza más cercano a Ventormenta
  ES.Waypoints.ResetCache()
  -- Mundo simulado: cada mapa en su sitio; el jugador en Ventormenta (1453)
  C_Map.GetWorldPosFromMapPos = function(map, v) return 0, { GetXY = function() return map * 10 + v.x * 5, v.y * 5 end } end
  UnitPosition = function() return 1453 * 10 + 2.5, 2.5, 0, 0 end
  local near = ES.Waypoints.Nearest(ES.Waypoints.Trainers("Leatherworking", 76))
  local npc = near and ES.Waypoints.NPC(near)
  assert(npc and npc.side ~= "H", "datos propios: eligió " .. tostring(npc and npc.name))
  log[#log+1] = "     datos propios: instructor de Peletería más cercano: " .. tostring(npc and npc.name)
  ES.Print = savedPrint
end)
step("estrella sobre el PNJ al que te manda el addon", function()
  -- Poner marcas está protegido: el addon no llama a SetRaidTarget; al pasar el
  -- ratón por una fila de vendedor, un botón seguro con la macro se pone encima
  local WP = ES.Waypoints
  local called = false
  local savedSet, savedGo, savedAvail = SetRaidTarget, WP.Go, WP.Available
  SetRaidTarget = function() called = true end
  WP.Go, WP.Available = function() end, function() return true end
  local npcID = WP.Nearest(ES.Data.Auctioneers) or next(ES.Data.NPCs or {})
  local npc = WP.NPC(npcID)
  local row = CreateFrame("Button")
  row.go = function() return npcID end
  WP.HoverRow(row)
  local h = WP.HoverButton()
  local macro = h and h:GetAttribute("macrotext")
  assert(h._shown and macro and macro:find("/targetexact [nocombat] " .. npc.name, 1, true) and macro:find("/tm [nocombat,exists] 1", 1, true),
    "falta el botón seguro sobre la fila: " .. tostring(macro)) -- (su clic: PostClick, solo en el juego)
  assert(not called, "el addon no puede llamar a SetRaidTarget por su cuenta (acción bloqueada)")
  assert(CraftersJournalMarkButton == nil, "no debería haber botón flotante")
  -- En combate no se toca
  local savedLock = InCombatLockdown
  InCombatLockdown = function() return true end
  local other = CreateFrame("Button")
  other.go = function() return npcID end
  WP.HoverRow(other)
  assert(h.row == row, "en combate el botón seguro no debería moverse")
  InCombatLockdown = savedLock
  WP.ReleaseHover()
  assert(h._shown == false, "al salir de la fila el botón seguro se suelta")
  SetRaidTarget, WP.Go, WP.Available = savedSet, savedGo, savedAvail
  log[#log+1] = "     estrella: " .. macro:gsub("\n", " / ")
end)
step("precio real del vendedor, aprendido al vender", function()
  -- Hillman's Shoulders: los datos del cliente dicen 11s 99c; el vendedor paga 6s 59c
  local savedMF, savedCC, savedSeen = MerchantFrame, C_Container, ES.db.sellSeen
  MerchantFrame = CreateFrame("Frame")
  C_Container = { GetContainerItemInfo = function() return { itemID = 4251, stackCount = 10 } end }
  ES.db.sellSeen = nil
  ES.Ledger.NoteSale(0, 1)
  ES.Ledger.ChargeSale(6590)
  assert(ES:VendorSellPrice(4251) == 659, "no aprendió el precio real: " .. tostring(ES:VendorSellPrice(4251)))
  -- Dos pilas vendidas seguidas: cada cobro con su venta
  C_Container.GetContainerItemInfo = function(_, slot) return { itemID = 2318, stackCount = slot } end
  ES.Ledger.NoteSale(0, 20)
  ES.Ledger.NoteSale(0, 5)
  ES.Ledger.ChargeSale(200)
  ES.Ledger.ChargeSale(50)
  assert(ES:VendorSellPrice(2318) == 10, "dos pilas: " .. tostring(ES:VendorSellPrice(2318)))
  MerchantFrame, C_Container, ES.db.sellSeen = savedMF, savedCC, savedSeen
end)
step("conversión de esencias: dice cuáles, cuántas veces y que se compran antes", function()
  local page
  for _, p in ipairs(ES.professionPages) do if p.profKey == "Enchanting" then page = p end end
  local savedDetect, savedCount = ES.DetectSkill, ES.ItemCount
  ES.DetectSkill = function(_, pg) pg.from = 28 end
  ES.ItemCount = function() return 0 end
  ES.db.prof.Enchanting = ES.db.prof.Enchanting or {}
  ES.db.prof.Enchanting.target, ES.db.prof.Enchanting.lock = 225, nil
  page.toBox._text = "225"
  ES:DetectSkill(page)
  ES:CalculatePlan(page)
  ES:SelectProfessionView(page, "route")
  local conv
  for _, l in ipairs(page.lines) do if l.title and l.title:find("^Convierte") then conv = l end end
  local hasConv = false
  for _, c in ipairs(page.plan and page.plan.crafted or {}) do if c.recipe and c.recipe.conversion then hasConv = true end end
  assert(not hasConv or conv, "la ruta convierte esencias pero no hay fila que lo explique")
  if conv then
    assert(conv.sub:find("veces") and conv.sub:find("cómpralas"), "la conversión no explica qué hacer: " .. tostring(conv.sub))
    log[#log+1] = "     " .. conv.title .. " · " .. conv.sub
  else
    log[#log+1] = "     (esta ruta no convierte esencias)"
  end
  -- Herramientas fabricadas (Runed Golden Rod): en el nivel donde hacen falta, y sin
  -- ✕ si no se pueden comprar (se ligan al recogerlas)
  local toolSkill = {}
  for _, tl in ipairs(page.plan and page.plan.tools or {}) do toolSkill[tl.item] = tl.skill end
  for _, l in ipairs(page.lines) do
    if l.item and toolSkill[l.item] and l.title and l.title:find("^Fabrica") then
      assert(tonumber(l.level) == toolSkill[l.item], string.format("herramienta fuera de sitio: %s en %s (hace falta en %d)", l.title, tostring(l.level), toolSkill[l.item]))
      if l.sub:find("no se puede comprar") then assert(not l.onSkip, "una herramienta que no se puede comprar no debería tener la ✕") end
      log[#log+1] = "     " .. l.level .. " · " .. l.title .. " · " .. l.sub
    end
  end
  ES.DetectSkill, ES.ItemCount = savedDetect, savedCount
end)
step("comandos /es", function()
  SlashCmdList.CRAFTERSJOURNAL("") SlashCmdList.CRAFTERSJOURNAL("cancel")
  -- Registro de errores: los iguales juntos, con cuántas veces; /cj errores los lista y los borra   ES.db.errorLog = nil   ES:RecordError("lua", "Interface/AddOns/CraftersJournal/Planner.lua:1: boom", "pila")   ES:RecordError("lua", "Interface/AddOns/CraftersJournal/Planner.lua:1: boom", "pila")   ES:RecordError("bloqueada", "SetRaidTarget()")   assert(#ES.db.errorLog == 2 and ES.db.errorLog[1].count == 2, "no agrupó los errores iguales")   SlashCmdList.CRAFTERSJOURNAL("errores")   SlashCmdList.CRAFTERSJOURNAL("errores borrar")   assert(ES.db.errorLog == nil, "/cj errores borrar no lo vació")
end)
step("rutas repartidas entre fotogramas (sin tirones)", function()
  -- En el juego (con debugprofilestop) las rutas no se calculan al abrir: cada
  -- fotograma hace un trozo de 8 ms y las tarjetas ponen "Calculando la ruta…"
  local frames = {}
  local realAfter = C_Timer.After
  C_Timer.After = function(_, fn) frames[#frames + 1] = fn end
  local ms = 0
  debugprofilestop = function() ms = ms + 0.05 return ms end
  -- El personaje tiene Peletería (nivel 50); las demás no se calculan solas
  local savedSkill = ES.GetProfessionSkill
  ES.GetProfessionSkill = function(self, line)
    if line == ES.Data.Leatherworking.skillLine then return 50, 225 end
    return savedSkill(self, line)
  end
  ES:ClearHomeCache()
  ES:SelectPage("home")
  local first = ES.homePage.cards[1]
  for _, c in ipairs(ES.homePage.cards) do
    if c.key == "Leatherworking" then first = c
    else assert(not tostring(c.note._text):find("Calculando"), "no debería calcular una profesión que no tienes: " .. tostring(c.key)) end
  end
  log[#log+1] = "     al abrir: " .. tostring(first.cost._text) .. " | " .. tostring(first.note._text)
  assert(tostring(first.note._text):find("Calculando"), "la tarjeta debería poner Calculando: " .. tostring(first.note._text))
  local n = 0
  while #frames > 0 and n < 100000 do
    local fn = table.remove(frames, 1)
    local before = ms
    fn()
    assert(ms - before < 30, "un fotograma ha durado " .. (ms - before) .. " ms simulados")
    n = n + 1
  end
  log[#log+1] = "     fotogramas hasta tener la ruta de tu profesión: " .. n
  assert(n > 1, "no se repartió el cálculo (" .. n .. " fotogramas)")
  for _, c in ipairs(ES.homePage.cards) do if c.key == "Leatherworking" then first = c end end
  log[#log+1] = "     al acabar: " .. tostring(first.cost._text) .. " | " .. tostring(first.note._text)
  assert(not tostring(first.note._text):find("Calculando"), "sigue calculando tras acabar")
  -- Abrir la profesión con la ruta ya calculada: sin esperar (de la caché)
  frames = {}
  ES:SelectPage(first.key)
  local page = ES.professionPages[1]
  for _, p in ipairs(ES.professionPages) do if p.profKey == first.key then page = p end end
  page._scripts.OnShow(page) -- el simulacro no lanza OnShow al mostrar
  assert(page.plan and not page.calculating, "la página debería usar la ruta de la portada: " .. tostring(page.planKey)
    .. " vs " .. tostring(ES.homePlanCache[first.key] and ES.homePlanCache[first.key].key))
  assert(#frames == 0, "no debería recalcular: " .. #frames)
  debugprofilestop = nil
  C_Timer.After = realAfter
  ES.GetProfessionSkill = savedSkill
  ES:SelectPage("home")
end)
step("inventario: qué vender de las bolsas, dónde y qué guardar", function()
  -- Bolsas: 20 Light Leather (la ruta fijada necesita 5), 3 de un objeto que ha subido,
  -- 2 que solo valen para el vendedor y 1 ligado
  local LL, UP, JUNK, BOUND = 2318, 4234, 4251, 5000
  local bags = { { LL, 20 }, { UP, 3 }, { JUNK, 2 }, { BOUND, 1, true } }
  local savedCC, savedScans, savedVendor = C_Container, ES.db.scans, ES.VendorSellPrice
  local savedRef, savedSig, savedLock, savedLocked, savedNeed = ES.Market.ReferencePrice, ES.Market.Signals, ES.RouteLock, ES.LockedPlan, ES.Planner.NeedFrom
  local savedMerchant, savedSell, savedPost, savedAH = ES.Ledger.MerchantOpen, ES.Ledger.SellToVendor, ES.Ledger.PostOnAH, ES.IsAuctionHouseOpen
  C_Container = {
    GetContainerNumSlots = function(bag) return bag == 0 and #bags or 0 end,
    GetContainerItemID = function(bag, slot) return bags[slot] and bags[slot][1] end,
    GetContainerItemInfo = function(bag, slot) local b = bags[slot] return b and { stackCount = b[2], isBound = b[3] } end,
  }
  local VENDOR = { [LL] = 15, [UP] = 100, [JUNK] = 659, [BOUND] = 500 }
  ES.VendorSellPrice = function(_, id) return VENDOR[id] end
  ES.db.scans = { [ES:RealmKey()] = { time = time() - 600, items = {
    [LL] = { minUnit = 40, quantity = 50 }, [UP] = { minUnit = 5000, quantity = 2 }, [JUNK] = { minUnit = 600, quantity = 4 },
    [BOUND] = { minUnit = 9000, quantity = 1 } } } }
  local REF = { [LL] = 45, [UP] = 3000, [JUNK] = 650 }
  ES.Market.ReferencePrice = function(_, id) if REF[id] then return REF[id], 3, 0 end end
  ES.Market.Signals = function() return { verdict = "good" } end
  ES.RouteLock = function(_, k) return k == "Leatherworking" end
  ES.LockedPlan = function() return { from = 1 } end
  ES.Planner.NeedFrom = function() return { [LL] = 5 } end
  local list = ES.Inventory:List()
  local by = {}
  for _, e in ipairs(list) do by[e.itemID] = e end
  assert(by[LL] and by[LL].keep == 5 and by[LL].ahN + by[LL].vendorN == 15, "Light Leather: guarda 5 y vende 15")
  assert(by[LL].ahN == 15, "Light Leather a 40 en la AH deja más que 15 del vendedor: " .. by[LL].ahN)
  assert(by[UP] and by[UP].rise and by[UP].ahN == 3, "lo que ha subido va a la AH y se marca")
  assert(by[JUNK] and by[JUNK].ahN == 0 and by[JUNK].vendorN == 2, "la AH no deja más que el vendedor: al vendedor")
  assert(not by[BOUND] or by[BOUND].ahN == 0, "un objeto ligado no se anuncia en la AH")
  -- La página: secciones, cifras y el botón de vender (solo con el vendedor abierto)
  ES:SelectPage("inventory")
  local page = ES.inventoryPage
  page._shown = true
  local sold = {}
  ES.Ledger.MerchantOpen = function() return true end
  ES.Ledger.SellToVendor = function(_, id, n) sold[id] = n end
  ES:RenderInventory()
  local sections = {}
  for i, row in ipairs(page.rows) do if row._shown and row.title then sections[#sections + 1] = tostring(row.title._text) end end
  log[#log+1] = "     inventario: " .. tostring(page.stats.total._text) .. " · " .. table.concat(sections, " | "):sub(1, 220)
  assert(page.action._shown, "con el vendedor abierto sale el botón de vender")
  page.action._scripts.OnClick(page.action)
  assert(sold[JUNK] == 2 and not sold[LL] and not sold[UP], "el botón solo vende lo que va al vendedor")
  -- Clic en una fila con la AH abierta: anuncia
  local posted
  ES.IsAuctionHouseOpen = function() return true end
  ES.Ledger.PostOnAH = function(_, id, n, price) posted = { id, n, price } end
  for _, row in ipairs(page.rows) do if row.onClick and row.title and tostring(row.title._text):find("3×") then row.onClick() end end
  assert(posted and posted[1] == UP and posted[2] == 3, "el clic con la AH abierta no anunció")
  C_Container, ES.db.scans, ES.VendorSellPrice = savedCC, savedScans, savedVendor
  ES.Market.ReferencePrice, ES.Market.Signals, ES.RouteLock, ES.LockedPlan, ES.Planner.NeedFrom = savedRef, savedSig, savedLock, savedLocked, savedNeed
  ES.Ledger.MerchantOpen, ES.Ledger.SellToVendor, ES.Ledger.PostOnAH, ES.IsAuctionHouseOpen = savedMerchant, savedSell, savedPost, savedAH
  ES:SelectPage("home")
end)
step("inventario: sin saber si se vende, el depósito que se pierde cuenta", function()
  -- Crimson Silk Pantaloons: 32s en la AH (30s 39c tras la comisión) frente a 24s 30c del
  -- vendedor; el depósito de 24 h (14s 58c) se pierde si caduca. Con pocos datos, vendedor
  local PANTS = 7062
  local savedCC, savedScans, savedVendor, savedSig, savedRef = C_Container, ES.db.scans, ES.VendorSellPrice, ES.Market.Signals, ES.Market.ReferencePrice
  C_Container = {
    GetContainerNumSlots = function(bag) return bag == 0 and 1 or 0 end,
    GetContainerItemID = function(bag, slot) return slot == 1 and PANTS or nil end,
    GetContainerItemInfo = function() return { stackCount = 5 } end,
  }
  ES.VendorSellPrice = function(_, id) return id == PANTS and 2430 or 1 end
  ES.Market.ReferencePrice = function() return nil end
  ES.db.scans = { [ES:RealmKey()] = { time = time() - 600, items = { [PANTS] = { minUnit = 3200, quantity = 3 } } } }
  local function Pants()
    for _, e in ipairs(ES.Inventory:List()) do if e.itemID == PANTS then return e end end
  end
  ES.Market.Signals = function() return { verdict = "unknown" } end
  local e = Pants()
  assert(e.ahN == 0 and e.vendorN == 5 and e.riskyAH, "con pocos datos, al vendedor (y avisando): ah " .. e.ahN)
  assert(math.abs(e.depositRisk - 2430 * 0.6) < 1, "riesgo = depósito de 24 h: " .. tostring(e.depositRisk))
  -- Si se sabe que se vende, a la AH (el depósito se devuelve)
  ES.Market.Signals = function() return { verdict = "good" } end
  e = Pants()
  assert(e.ahN == 5 and not e.riskyAH, "con buen mercado, a la AH")
  C_Container, ES.db.scans, ES.VendorSellPrice, ES.Market.Signals, ES.Market.ReferencePrice = savedCC, savedScans, savedVendor, savedSig, savedRef
end)
step("inventario: lo que daría desencantar (solo informativo)", function()
  -- Un verde de armadura nivel 22 ligado (4-6 polvos extraños de media al 75%), un arma
  -- verde del mismo nivel (sobre todo esencias), un gris y un verde que se vende caro
  local ARMOR, WEAPON, GREY, PRICEY = 9001, 9002, 9003, 9004
  local bags = { { ARMOR, 1, true }, { WEAPON, 1 }, { GREY, 1 }, { PRICEY, 1 } }
  local INFO = { [ARMOR] = { 2, 22, 4 }, [WEAPON] = { 2, 22, 2 }, [GREY] = { 0, 22, 4 }, [PRICEY] = { 2, 22, 4 } }
  local savedCC, savedScans, savedVendor, savedGII = C_Container, ES.db.scans, ES.VendorSellPrice, GetItemInfo
  local savedSkill, savedSpell, savedSig = ES.GetProfessionSkill, GetSpellInfo, ES.Market.Signals
  C_Container = {
    GetContainerNumSlots = function(bag) return bag == 0 and #bags or 0 end,
    GetContainerItemID = function(bag, slot) return bags[slot] and bags[slot][1] end,
    GetContainerItemInfo = function(bag, slot) local b = bags[slot] return b and { stackCount = b[2], isBound = b[3] } end,
  }
  GetItemInfo = function(id) local i = INFO[id] if i then return "Obj" .. id, nil, i[1], i[2], 20, nil, nil, 1, nil, 134400, 100, i[3] end
    return savedGII(id) end
  local VENDOR = { [ARMOR] = 100, [WEAPON] = 100, [GREY] = 100, [PRICEY] = 100 }
  ES.VendorSellPrice = function(_, id) return VENDOR[id] or 1 end
  -- Polvo extraño a 50c, esencia astral menor a 1s; el verde caro se vende a 50s en la AH
  ES.db.scans = { [ES:RealmKey()] = { time = time() - 600, items = {
    [10940] = { minUnit = 50, quantity = 100 }, [10998] = { minUnit = 100, quantity = 20 },
    [PRICEY] = { minUnit = 5000, quantity = 1 } } } }
  ES.Market.Signals = function() return { verdict = "good" } end
  GetSpellInfo = function(id) if id == 13262 then return "Desencantar" end end
  local function By()
    local by = {}
    for _, e in ipairs(ES.Inventory:List()) do by[e.itemID] = e end
    return by
  end
  -- Solo informativo: el reparto AH / vendedor no cambia, y se dice lo que daría
  ES.GetProfessionSkill = function() return nil end
  local by = By()
  local de = by[ARMOR] and by[ARMOR].de
  -- 0.75 x 5 polvos x ~47c + 0.15 x 1.5 esencias x ~95c + 0.10 x fragmento (sin precio: vendedor 1c)
  log[#log+1] = string.format("     verde nivel 22 (armadura): desencantado ~%dc frente a 100c del vendedor", de and de.value or -1)
  assert(de and not by[ARMOR].deCan and by[ARMOR].vendorN == 1, "sin Encantamiento: se informa y se sigue vendiendo")
  assert(de.value > 150 and de.value < 220, "valor medio del verde de armadura: " .. de.value)
  assert(de.partial, "el fragmento no estaba en el escaneo: se avisa")
  assert(by[WEAPON] and by[WEAPON].de and by[WEAPON].de.value < de.value, "un arma da sobre todo esencias (aquí valen menos que los polvos)")
  assert(not by[GREY] or not by[GREY].de, "un gris no se desencanta")
  assert(by[PRICEY] and not by[PRICEY].de and by[PRICEY].ahN == 1, "si en la AH vale más, no se habla de desencantar")
  -- Con Encantamiento: 30 llega al 25 que pide el nivel 22; 10 no
  ES.GetProfessionSkill = function(_, line) if line == 333 then return 30, 75 end end
  by = By()
  assert(by[ARMOR].deCan and by[ARMOR].vendorN == 1, "con Encantamiento 30 se puede, pero sigue en vender")
  ES.GetProfessionSkill = function(_, line) if line == 333 then return 10, 75 end end
  by = By()
  assert(not by[ARMOR].deCan and by[ARMOR].deRank == 10, "con 10 no llega al 25 que pide")
  -- La página: la fila lo dice; no hay botón de desencantar
  ES:SelectPage("inventory")
  local page = ES.inventoryPage
  page._shown = true
  ES:RenderInventory()
  assert(page.deButton == nil, "no debe haber botón de desencantar")
  local found
  for _, row in ipairs(page.rows) do if row._shown and row.sub and tostring(row.sub._text):find("desencantado") then found = tostring(row.sub._text) end end
  assert(found, "la fila debería decir lo que daría desencantado")
  log[#log+1] = "     fila: " .. found:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  C_Container, ES.db.scans, ES.VendorSellPrice, GetItemInfo = savedCC, savedScans, savedVendor, savedGII
  ES.GetProfessionSkill, GetSpellInfo, ES.Market.Signals = savedSkill, savedSpell, savedSig
  ES:SelectPage("home")
end)
step("flipping: gangas de la AH", function()
  local CHEAP, DROP, SAME, AVOID = 2318, 2319, 4234, 4304
  local savedScans, savedVendor, savedRef, savedSig = ES.db.scans, ES.VendorSellPrice, ES.Market.ReferencePrice, ES.Market.Signals
  local VENDOR = { [CHEAP] = 100, [DROP] = 20, [SAME] = 20, [AVOID] = 20 }
  ES.VendorSellPrice = function(_, id) return VENDOR[id] end
  ES.db.scans = { [ES:RealmKey()] = { time = time() - 300, items = {
    [CHEAP] = { minUnit = 40, ladder = { 40, 4, 90, 2, 300, 10 } },     -- 6 por debajo del vendedor
    [DROP] = { minUnit = 500, ladder = { 500, 3, 700, 2, 1000, 20 } },  -- normalmente 1000: -50%
    [SAME] = { minUnit = 950, ladder = { 950, 10 } },                    -- precio normal
    [AVOID] = { minUnit = 300, ladder = { 300, 5 } },                    -- -70% pero alertas: evitar
  } } }
  local REF = { [DROP] = 1000, [SAME] = 1000, [AVOID] = 1000 }
  ES.Market.ReferencePrice = function(_, id) if REF[id] then return REF[id], 3, 0 end end
  ES.Market.Signals = function(_, id) return { verdict = id == AVOID and "avoid" or "good" } end
  local list = ES.Flipping:List()
  local by = {}
  for _, o in ipairs(list) do by[o.itemID] = o end
  assert(by[CHEAP] and by[CHEAP].kind == "vendor" and by[CHEAP].units == 6 and by[CHEAP].profit == 600 - 340,
    "por debajo del vendedor: " .. tostring(by[CHEAP] and by[CHEAP].profit))
  assert(by[DROP] and by[DROP].kind == "drop" and by[DROP].units == 5, "ha bajado un 50%: las 5 baratas")
  assert(not by[SAME], "a su precio normal no es una ganga")
  assert(not by[AVOID], "con alertas de evitar no se propone")
  ES:SelectPage("flipping")
  local page = ES.flippingPage
  page._shown = true
  ES:RenderFlipping()
  log[#log+1] = "     flipping: " .. tostring(page.stats.count._text) .. " oportunidades · " .. tostring(page.stats.profit._text)
  assert(page.stats.count._text == "2", "oportunidades: " .. tostring(page.stats.count._text))
  ES.db.scans, ES.VendorSellPrice, ES.Market.ReferencePrice, ES.Market.Signals = savedScans, savedVendor, savedRef, savedSig
  ES:SelectPage("home")
end)
step("versión publicada: sin las pestañas en desarrollo", function()
  -- En el repositorio es copia de desarrollo; el empaquetador comenta el bloque @debug@
  assert(ES.DEV_BUILD == true and ES.DEV == true, "en desarrollo ES.DEV_BUILD y ES.DEV deberían ser true")
  local src
  for i, n in ipairs(SOURCE_NAMES) do if n == "Core.lua" then src = SOURCES[i] end end
  assert(src:find("%-%-@debug@\nES.DEV_BUILD = true\n%-%-@end%-debug@"), "falta el bloque @debug@ de ES.DEV_BUILD")
  -- Como en la publicada: Subastas, Flipping y la Pesca no se abren; Ganar dinero sí
  ES.DEV = false
  for _, key in ipairs({ "ah", "flipping", "Fishing", "pattern:Fishing" }) do
    ES:SelectPage(key)
    assert(ES.db.lastPage == "home", key .. " no debería abrirse en la versión publicada")
  end
  ES:SelectPage("money")
  assert(ES.db.lastPage == "money", "Ganar dinero debería abrirse en la versión publicada")
  ES:SelectPage("home")
  ES.DEV = true
end)
step("interruptor de desarrollo: vista de jugador", function()
  ES:ShowMainFrame("home")
  local f = ES:GetMainFrame()
  assert(not f.devToggle, "el interruptor ya no va en la cabecera (sale en las capturas)")
  -- Está en Opciones > AddOns > Crafter's Journal
  local panel = ES.optionsPanel
  assert(panel and panel.devCheck, "en la copia de desarrollo el panel de opciones debería tener el interruptor")
  panel._scripts.OnShow(panel)
  assert(not panel.devCheck:GetChecked(), "en modo DEV la casilla debería estar desmarcada")
  log[#log+1] = "     interruptor: " .. tostring(panel.devCheck.label._text)
  panel.devCheck:SetChecked(true)
  panel.devCheck._scripts.OnClick(panel.devCheck)
  -- Vista de jugador: ventana nueva sin las pestañas, el buscador ni la Pesca
  local g = ES:GetMainFrame()
  assert(ES.DEV == false and ES.db.userPreview == true, "no pasó a vista de jugador")
  assert(#g.tabs == 5, "pestañas en vista de jugador: " .. #g.tabs) -- portada, ganar dinero, inventario, calculadora y colección
  ES:SelectPage("home")
  for _, c in ipairs(ES.homePage.cards) do
    if c._shown ~= false then assert(c.key ~= "Fishing", "la Pesca no debería verse") end
  end
  assert(ES.homePage.shownCards == #ES.PROFESSIONS - 1, "tarjetas en vista de jugador: " .. ES.homePage.shownCards)
  log[#log+1] = "     vista de jugador: " .. #g.tabs .. " pestañas"
  -- Y vuelta al modo desarrollo
  panel.devCheck:SetChecked(false)
  panel.devCheck._scripts.OnClick(panel.devCheck)
  assert(ES.DEV == true and not ES.db.userPreview and #ES:GetMainFrame().tabs == 7, "no volvió al modo desarrollo")
end)
step("ruta: la segunda mejor receta de cada paso y por qué es peor", function()
  local page
  for _, p in ipairs(ES.professionPages) do if p.profKey == "Leatherworking" then page = p end end
  ES:SelectPage("Leatherworking")
  page._shown = true
  page.toBox._text = "225"
  ES:CalculatePlan(page)
  local plan = page.plan
  assert(plan and #plan.steps > 0, "sin ruta de peletería")
  -- Se calculan repartidas en fotogramas: se ejecutan todos
  local savedAfter, queue = C_Timer.After, {}
  C_Timer.After = function(_, fn) queue[#queue + 1] = fn end
  plan.alts, plan.altsRunning = nil, nil
  ES:ComputeAlternatives(page, plan)
  local ticks = 0
  while #queue > 0 and ticks < 100000 do table.remove(queue, 1)() ticks = ticks + 1 end
  C_Timer.After = savedAfter
  assert(plan.alts, "no calculó las alternativas")
  local withAlt, cheaper = 0, 0
  for i = 1, #plan.steps do
    local list = plan.alts[i]
    assert(list, "paso " .. i .. " sin lista de alternativas")
    if list[1] then withAlt = withAlt + 1 end
    if list[1] and list[1].delta < -0.5 then
      cheaper = cheaper + 1
      local st, a = plan.steps[i], list[1]
      log[#log+1] = string.format("       más barata en %d-%d: %s %+.0fc, %s fabricaciones frente a %s (ruta: %s)", st.from, st.to,
        ES.Data.Leatherworking.recipes[a.id].name, a.delta, ES.Num(a.step.expected), ES.Num(st.expected), st.recipe.name)
    end
    for k = 2, #list do assert(list[k].delta >= list[k - 1].delta, "alternativas sin ordenar") end
  end
  log[#log+1] = string.format("     %d pasos: %d con segunda opción, %d con una más barata que la ruta (%d fotogramas)", #plan.steps, withAlt, cheaper, ticks)
  assert(withAlt > 0, "ningún paso con segunda opción")
  -- La fila del paso lo dice; el tooltip, las cifras y el motivo
  ES:RenderPlan(page)
  local line
  for _, l in ipairs(page.lines) do
    local s = tostring(l.sub or "")
    if s:find("2ª") or s:find("más barata") or s:find("única") then line = l break end
  end
  assert(line, "ninguna fila dice cuál es la segunda opción")
  log[#log+1] = "     fila: " .. tostring(line.sub):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T[^|]+|t", "")
  local tip, savedAdd, savedDouble = {}, GameTooltip.AddLine, GameTooltip.AddDoubleLine
  GameTooltip.AddLine = function(_, t) tip[#tip + 1] = tostring(t) end
  GameTooltip.AddDoubleLine = function(_, a, b) tip[#tip + 1] = tostring(a) .. " | " .. tostring(b) end
  line.tooltip(CreateFrame("Frame"))
  GameTooltip.AddLine, GameTooltip.AddDoubleLine = savedAdd, savedDouble
  local why = false
  for _, t in ipairs(tip) do if t:find("Por qué esta y no otra") or t:find("única receta") then why = true end end
  assert(why, "el tooltip no explica por qué esta y no otra")
  for _, t in ipairs(tip) do if t:find("Peor porque") then log[#log+1] = "     tooltip: " .. t:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") break end end
  ES:SelectPage("home")
end)
step("calculadora: desglose en crudo, precios a mano y cálculos guardados", function()
  local Calc = ES.Calc
  -- Dinero escrito como en una hoja de cálculo
  assert(Calc.ParseMoney("2,7") == 270 and Calc.ParseMoney("2.7") == 270, "2,7 = 2s 70c")
  assert(Calc.ParseMoney("1g 20s 5c") == 12005 and Calc.ParseMoney("1o 20p") == 12000, "con unidades")
  assert(Calc.ParseMoney("27c") == 27 and Calc.ParseMoney("") == nil and Calc.ParseMoney("abc") == nil, "cobre, vacío y basura")
  assert(Calc.FormatMoney(12005) == "1g 20s 5c" and Calc.FormatMoney(0) == "0c", "formato: " .. Calc.FormatMoney(12005))
  -- Una receta de sastrería que pide Bolt of Silk Cloth (4305), que sabes fabricar
  local data = ES.Data.Tailoring
  local SILK, BOLT, recipeID, boltID = 4306, 4305
  for id, r in pairs(data.recipes) do
    if r.out and r.out[1] == BOLT then boltID = id end
  end
  for id, r in pairs(data.recipes) do
    for _, rq in ipairs(r.r) do if rq[1] == BOLT and r.out and (not recipeID or id < recipeID) then recipeID = id end end
  end
  assert(boltID and recipeID, "no hay receta con Bolt of Silk Cloth")
  local savedKnown, savedScans, savedStanding, savedCalcs = ES.IsRecipeKnown, ES.db.scans, ES.Standing, ES.db.calcs
  ES.IsRecipeKnown = function(_, id) return id == boltID end
  ES.db.calcs = nil
  local outID = data.recipes[recipeID].out[1]
  ES.db.scans = { [ES:RealmKey()] = { time = time() - 600, items = {
    [SILK] = { minUnit = 200, quantity = 500 }, [outID] = { minUnit = 50000, quantity = 3 } } } }
  ES.Standing = function() return 4 end
  local c = Calc:Add("Tailoring", recipeID)
  local res = Calc:Compute(c)
  local by = {}
  for _, row in ipairs(res.rows) do by[row.itemID] = row end
  assert(not by[BOLT] and by[SILK], "el Bolt de seda debería desglosarse en su tela")
  assert(#res.made == 1 and res.made[1].itemID == BOLT, "y decirse que lo fabricas tú")
  local boltsNeeded
  for _, rq in ipairs(data.recipes[recipeID].r) do if rq[1] == BOLT then boltsNeeded = rq[2] end end
  local silkPerBolt
  for _, rq in ipairs(data.recipes[boltID].r) do if rq[1] == SILK then silkPerBolt = rq[2] end end
  assert(by[SILK].qty == boltsNeeded * silkPerBolt / (data.recipes[boltID].out[2] or 1), "tela: " .. by[SILK].qty)
  assert(by[SILK].source == "ah" and by[SILK].price == 200, "la seda, del escaneo")
  -- Las cuentas: venta - comisión - materiales. El depósito (24 h: 60% del precio de
  -- vendedor) se devuelve al venderse: se enseña, pero no resta
  assert(math.abs(res.profit - (res.revenue - res.cut - res.cost)) < 0.01, "beneficio mal sumado")
  local outVendor = ES:VendorSellPrice(outID) or 0
  -- Mínimo de Forever: 1s por subasta (por montón en lo que se apila)
  assert(Calc.Deposit(1.5, 1, 1) == 100, "por debajo de 1s, 1s")
  assert(Calc.Deposit(300, 2, 1) == 600, "dos subastas de 3s")
  local d, n = Calc.Deposit(2, 20, 20)
  assert(d == 100 and n == 1, "un montón de 20 paga el mínimo una vez")
  d, n = Calc.Deposit(2, 25, 20)
  assert(d == 200 and n == 2, "25 en montones de 20: dos subastas")
  local stack = Calc.StackSize(outID)
  assert(res.hours == 24 and math.abs(res.deposit - Calc.Deposit(outVendor * 0.6, res.outN, stack)) < 0.01, "depósito 24 h = 60% del vendedor: " .. res.deposit)
  -- Duración elegida: 2 h = 5%, 8 h = 20% (y el beneficio no cambia: se devuelve)
  for hours, pct in pairs({ [2] = 0.05, [8] = 0.20 }) do
    c.hours = hours
    local rh = Calc:Compute(c)
    assert(math.abs(rh.deposit - Calc.Deposit(outVendor * pct, rh.outN, stack)) < 0.01 and rh.depositPct == pct * 100, hours .. " h: " .. rh.deposit)
    assert(math.abs(rh.profit - res.profit) < 0.01, "la duración no cambia el beneficio")
  end
  c.hours = nil
  assert(res.cutRate == 0.05 and res.saleSource == "ah" and res.sale == 49999, "venta en la AH a 1c menos: " .. tostring(res.sale))
  -- Precio a mano: solo en este cálculo
  c.prices[SILK] = Calc.ParseMoney("2,7")
  local res2 = Calc:Compute(c)
  for _, row in ipairs(res2.rows) do if row.itemID == SILK then assert(row.source == "manual" and row.price == 270, "precio a mano") end end
  assert(res2.cost > res.cost, "con la seda más cara, más coste")
  local c2 = Calc:Add("Tailoring", boltID)
  local r3 = Calc:Compute(c2)
  assert(r3.rows[1].price == 200, "el precio a mano de un cálculo no cambia otro")
  -- Cantidad: el doble de fabricaciones, el doble de materiales
  c.qty = 2
  assert(math.abs(Calc:Compute(c).cost - 2 * res2.cost) < 0.01, "cantidad x2")
  -- Descuento de vendedor por reputación con una capital (honorable: -10%)
  local vendorItem
  for _, rq in ipairs(data.recipes[recipeID].r) do if ES.Data.VendorPrices[rq[1]] then vendorItem = rq[1] end end
  if vendorItem then
    ES.Standing = function(_, id) return id == 72 and 6 or 4 end
    local r4 = Calc:Compute(c)
    for _, row in ipairs(r4.rows) do
      if row.itemID == vendorItem then
        assert(row.source == "vendor" and row.price == math.floor(ES.Data.VendorPrices[vendorItem] * 0.9 + 0.5), "descuento de ciudad")
      end
    end
    assert(r4.discount == 0.10, "descuento: " .. r4.discount)
  end
  -- La página: lista de guardados, hoja y escribir un precio en su casilla
  ES:SelectPage("calc")
  local page = ES.calculatorPage
  page._shown = true
  Calc:Select(c.id)
  ES:RenderCalculator()
  assert(page.saved[1]._shown and page.saved[2]._shown, "dos cálculos guardados en la lista")
  local silkRow
  for _, row in ipairs(page.sheetRows) do if row._shown and row.itemID == SILK then silkRow = row end end
  -- Tres casillas: oro, plata y cobre
  local b = silkRow and silkRow.box
  assert(b and b.g._text == "" and b.s._text == "2" and b.c._text == "70",
    "casillas con 2s 70c: " .. tostring(b and b.g._text) .. "|" .. tostring(b and b.s._text) .. "|" .. tostring(b and b.c._text))
  b.g:SetText("1") b.s:SetText("3") b.c:SetText("")
  b.s._scripts.OnEnterPressed(b.s)
  assert(c.prices[SILK] == 10300, "1 oro y 3 platas = 1g 3s: " .. tostring(c.prices[SILK]))
  assert(b.g._text == "1" and b.s._text == "3" and b.c._text == "0", "se repinta con 1g 3s 0c")
  b.g:SetText("") b.s:SetText("") b.c:SetText("")
  b.c._scripts.OnEnterPressed(b.c)
  assert(c.prices[SILK] == nil, "con las tres vacías vuelve al automático")
  -- Selector de duración: 24 h marcado; pulsar 8 h lo guarda en el cálculo
  assert(page.duration._shown, "el selector de duración se ve al vender en la AH")
  local b8 = page.duration.buttons[2]
  b8._scripts.OnClick(b8)
  assert(c.hours == 8, "pulsar 8 h guarda la duración: " .. tostring(c.hours))
  b8._scripts.OnEnter(b8)
  log[#log+1] = "     calculadora: " .. tostring(page.title._text) .. " · beneficio " .. tostring(page.profitLine.value._text)
  -- Buscar y añadir; borrar con la ✕
  page.search:SetText("silk")
  page.search._scripts.OnTextChanged(page.search)
  assert(page.results._shown and page.results.rows[1].result, "el buscador no encuentra 'silk'")
  page.results.rows[1]._scripts.OnClick(page.results.rows[1])
  assert(#Calc:List() == 3, "el buscador debería añadir un cálculo")
  page.saved[1].del._scripts.OnClick(page.saved[1].del)
  assert(#Calc:List() == 2, "la ✕ debería borrarlo")
  ES.IsRecipeKnown, ES.db.scans, ES.Standing, ES.db.calcs = savedKnown, savedScans, savedStanding, savedCalcs
  ES:SelectPage("home")
end)
step("materiales: o se fabrican o se compran, y la ✕ los compra hechos", function()
  local data = ES.Data.Leatherworking
  -- Nunca las dos cosas a la vez con un mismo material
  local opts = ES:PlanOptions("Leatherworking", 75, 125, nil)
  local plan = ES.Planner:Plan(data, opts)
  local crafted = {}
  for _, c in ipairs(plan.crafted) do crafted[c.itemID] = true end
  for _, it in ipairs(plan.shopping) do
    assert(not (crafted[it.itemID] and it.source == "ah"), "se fabrica y se compra a la vez: " .. it.itemID)
  end
  -- Con la ✕ (comprarlo) no se fabrica: un material que se pueda comprar en la AH
  -- (sin precio, fabricarlo es la única vía y se fabrica igual)
  local item
  for id in pairs(plan.ctx.via) do if plan.ctx.ladders[id] then item = id break end end
  if item then
    local o = ES:PlanOptions("Leatherworking", 75, 125, nil)
    o.via = { [item] = "buy" }
    local p = ES.Planner:Plan(data, o)
    for _, c in ipairs(p.crafted) do assert(c.itemID ~= item, "con la ✕ no debería fabricarlo") end
  end
  -- La fila de fabricar tiene la ✕; al pulsarla queda en "Recetas quitadas" y se recupera
  local page
  for _, pg in ipairs(ES.professionPages) do if pg.profKey == "Leatherworking" then page = pg end end
  page.view = "route"
  ES:CalculatePlan(page)
  local craftLine
  for _, l in ipairs(page.lines) do if l.skipTip and l.onSkip then craftLine = l end end
  if craftLine then
    craftLine.onSkip()
    assert(ES.db.prof.Leatherworking.noCraft and next(ES.db.prof.Leatherworking.noCraft), "la ✕ no apuntó el material")
    local restore
    for _, l in ipairs(page.lines) do if l.title and l.title:find("Recetas quitadas") then restore = l end end
    assert(restore, "falta la fila para recuperar el material")
    restore.onClick()
    assert(not ES.db.prof.Leatherworking.noCraft, "no se recuperó el material")
    log[#log+1] = "     ✕ en fabricar: " .. craftLine.title
  else
    log[#log+1] = "     ✕ en fabricar: la ruta de prueba no fabrica materiales"
  end
end)
step("cada personaje tiene sus rutas", function()
  -- El hunter empieza una ruta y sale; el warrior (que se llama igual, en el mismo
  -- reino: en Forever pasa) no la ve; el hunter vuelve y la recupera
  local savedGUID, savedProf = UnitGUID, ES.db.prof -- los ajustes de las demás pruebas
  UnitGUID = function() return "Player-70-0000AAAA" end
  ES.LoadCharacterData()
  ES.db.prof.Leatherworking = ES.db.prof.Leatherworking or {}
  ES.db.prof.Leatherworking.lock = { from = 1, to = 2, started = 1, choice = {} }
  ES.db.prof.Leatherworking.target = 175
  ES.SaveCharacterData()
  assert(ES.db.prof == nil, "al salir no deberían quedar copias sueltas")
  UnitGUID = function() return "Player-70-0000BBBB" end -- mismo nombre (UnitName no cambia)
  ES.LoadCharacterData()
  assert(not (ES.db.prof.Leatherworking and ES.db.prof.Leatherworking.lock), "otro personaje con el mismo nombre ve la ruta del primero")
  ES.SaveCharacterData()
  UnitGUID = function() return "Player-70-0000AAAA" end
  ES.LoadCharacterData()
  assert(ES.db.prof.Leatherworking.lock and ES.db.prof.Leatherworking.target == 175, "al volver, el personaje no recupera su ruta")
  ES.db.prof.Leatherworking.lock, ES.db.prof.Leatherworking.target = nil, nil
  ES.lockedPlans = {}
  -- De vuelta al personaje de las demás pruebas
  ES.SaveCharacterData()
  UnitGUID = savedGUID
  ES.LoadCharacterData()
  ES.charData.prof, ES.db.prof = savedProf, savedProf
end)
step("al volver a abrir, sigue donde estabas", function()
  local mf = ES:GetMainFrame()
  ES:SelectPage("Leatherworking")
  mf.openPage = nil
  mf._scripts.OnShow(mf) -- cerrar y volver a abrir la ventana
  assert(ES.db.lastPage == "Leatherworking", "al abrir debería seguir en la profesión: " .. tostring(ES.db.lastPage))
  -- Otra sesión (otro personaje): se empieza en la portada, no en lo del otro
  ES.sessionPage = nil
  mf._scripts.OnShow(mf)
  assert(ES.db.lastPage == "home", "con otro personaje debería abrir en la portada: " .. tostring(ES.db.lastPage))
end)
step("merchant's favor: solo con su icono", function()
  -- Por defecto la ruta no usa recetas de Merchant's Favor; con el icono, sí (0 oro)
  local data = ES.Data.Engineering
  local plan = ES.Planner:Plan(data, ES:PlanOptions("Engineering", 1, 225, nil))
  for _, st in ipairs(plan.steps) do assert(not st.recipe.favor, "receta de Merchant's Favor sin el icono: " .. st.recipe.name) end
  local favor
  for _, r in pairs(data.recipes) do if r.favor then favor = r break end end
  assert(ES.Planner.LearnSkill(favor, { useFavor = true }) == (favor.train or 1), "con el icono se puede aprender")
  local page
  for _, p in ipairs(ES.professionPages) do if p.profKey == "Engineering" then page = p end end
  assert(page and page.favorButton, "falta el icono de Merchant's Favor")
  page.favorButton._scripts.OnEnter(page.favorButton)
  page.favorButton._scripts.OnClick(page.favorButton)
  assert(ES.db.prof.Engineering.useFavor, "el icono no activó Merchant's Favor")
  local withFavor = ES.Planner:Plan(data, ES:PlanOptions("Engineering", 1, 225, nil))
  local used = 0
  for _, st in ipairs(withFavor.steps) do if st.recipe.favor then used = used + 1 end end
  log[#log+1] = string.format("     merchant's favor: %d pasos con el icono, neto %.1f oro (sin él %.1f)", used, withFavor.net / 10000, plan.net / 10000)
  page.favorButton._scripts.OnClick(page.favorButton)
  assert(not ES.db.prof.Engineering.useFavor, "el icono no desactivó Merchant's Favor")
end)
step("instructor: aprende los precios reales", function()
  -- Receta nueva de Forever sin precio conocido (trainer = true, sin fee): al abrir
  -- el instructor se lee lo que cobra y el nivel que pide, y manda sobre los datos
  local data = ES.Data.Alchemy
  ES.Planner.Annotate(data)
  local acid, mana = data.recipes[1249633], data.recipes[2331]
  local saved = { acid.fee, acid.train, acid.trainer }
  acid.fee, acid.train, acid.trainer = nil, nil, true
  ES.db.trainerFees = nil
  local ctx = { opts = {}, prices = {} }
  local cost, source = ES.Planner.LearnCost(ctx, acid)
  assert(cost == 0 and source == "trainer", "sin precio conocido debería ser instructor a 0 (\"?\")")
  -- Ventana del instructor de Alquimia: una cabecera, el ácido por nombre y la
  -- poción de maná por el objeto que fabrica
  local services = {
    { name = "Alchemy", kind = "header" },
    { name = acid.nameEN or acid.name, kind = "available", cost = 135, skill = 40 },
    { name = "Whatever", kind = "used", cost = 100, skill = 25, link = "|cffffffff|Hitem:2455::::::::|h[Minor Mana Potion]|h|r" },
  }
  GetNumTrainerServices = function() return #services end
  GetTrainerServiceInfo = function(i) return services[i].name, "", services[i].kind end
  GetTrainerServiceSkillLine = function() return ES:ProfLabel("Alchemy") end
  GetTrainerServiceCost = function(i) return services[i].cost end
  GetTrainerServiceSkillReq = function(i) return "Alchemy", services[i].skill, true end
  GetTrainerServiceItemLink = function(i) return services[i].link end
  UnitReaction = function() return 4 end -- neutral: sin descuento
  -- Al abrirlo se leen todas, aunque sus filtros oculten algunas (y se dejan como estaban)
  local filters = { available = 1, unavailable = nil, used = nil }
  local shownAtRead
  GetTrainerServiceTypeFilter = function(f) return filters[f] end
  SetTrainerServiceTypeFilter = function(f, v) filters[f] = v == 1 and 1 or nil end
  local realCount = GetNumTrainerServices
  GetNumTrainerServices = function() shownAtRead = filters.unavailable and filters.used return realCount() end
  local changed = ES.Ledger:ReadAllTrainerServices()
  assert(shownAtRead, "al leer, los filtros del instructor deberían mostrarlo todo")
  assert(filters.available == 1 and not filters.unavailable and not filters.used, "los filtros deberían quedar como estaban")
  GetTrainerServiceTypeFilter, SetTrainerServiceTypeFilter, GetNumTrainerServices = nil, nil, realCount
  assert(changed == 2, "debería haber leído 2 recetas: " .. tostring(changed))
  -- Cuánto se ha comprobado de cada profesión (/cj instructor)
  local cov
  for _, c in ipairs(ES.Ledger:TrainerCoverage()) do if c.prof == "Alchemy" then cov = c end end
  assert(cov and cov.seen == 2 and cov.diff == 2 and cov.total > 2, "cobertura de Alquimia: " .. tostring(cov and cov.seen))
  local seen = ES.db.trainerFees[1249633]
  assert(seen and seen.cost == 135 and seen.skill == 40, "no guardó el precio del ácido")
  cost, source = ES.Planner.LearnCost(ctx, acid)
  assert(cost == 135 and source == "trainer", "no usa el precio visto: " .. tostring(cost))
  assert(ES.Planner.LearnSkill(acid, {}) == 40, "no usa el nivel visto")
  assert(ES.Planner.LearnCost(ctx, mana) == 100, "la poción de maná debería costar lo visto (100)")
  -- Lo distinto de los datos, para copiar a tools/forever/trainer_fees.csv
  local rows = ES.Ledger:TrainerDiffs()
  local text = table.concat(rows, "\n")
  log[#log+1] = "     instructor: " .. text:gsub("\n", "\n     instructor: ")
  assert(text:find("^2331,Minor Mana Potion,100,25,") and text:find("\n1249633,Sulfuric Acid,135,40,"), "diferencias: " .. text)
  -- Con reputación el instructor rebaja: el CSV lleva el precio base
  assert(ES.Ledger.BaseCost({ cost = 135, rep = 6 }) == 150, "precio base con Honorable")
  -- El comando lo imprime y lo deja en SavedVariables
  local printed = 0
  local savedPrint = print
  print = function(s) if tostring(s):find("^%d+,") then printed = printed + 1 end end
  SlashCmdList.CRAFTERSJOURNAL("instructor")
  print = savedPrint
  assert(printed == 2 and #ES.db.trainerFeesCSV == 2, "/cj instructor no listó las diferencias")
  -- Ruta fijada: el precio real del instructor también la corrige (mismas recetas)
  local lw = ES.Data.Leatherworking
  local hideID, from -- una receta de instructor de pago de nivel bajo (en los datos)
  for id, r in pairs(lw.recipes) do
    if r.fee and r.fee > 200 and r.train and r.train >= 10 and r.train <= 50 and r.t[4] > r.train + 15 and (not hideID or id < hideID) then hideID, from = id, r.train end
  end
  local choice = {}
  for s = from, from + 9 do choice[s] = hideID end
  ES.db.prof.Leatherworking = ES.db.prof.Leatherworking or {}
  local lp = ES.db.prof.Leatherworking
  local savedLock = lp.lock
  lp.lock = { from = from, to = from + 10, choice = choice, via = {}, started = 12345 }
  ES.lockedPlans.Leatherworking = nil
  local savedKnown = ES.IsRecipeKnown
  ES.IsRecipeKnown = function() return false end
  local before = ES:LockedPlan("Leatherworking")
  local fee = lw.recipes[hideID].fee
  services = { { name = lw.recipes[hideID].nameEN or lw.recipes[hideID].name, kind = "available", cost = fee - 100, skill = from } }
  GetTrainerServiceSkillLine = function() return ES:ProfLabel("Leatherworking") end
  ES.Ledger:ReadTrainer()
  local after = ES:LockedPlan("Leatherworking")
  assert(after ~= before and math.abs((before.fees - after.fees) - 100) < 1,
    string.format("la ruta fijada no usó el precio del instructor: %d -> %d (pasos %d, para en %s, fee %s)", before.fees, after.fees, #before.steps, tostring(before.stoppedAt), tostring(before.steps[1] and before.steps[1].fee)))
  assert(after.steps[1].id == hideID, "la ruta fijada debería seguir con las mismas recetas")
  log[#log+1] = string.format("     ruta fijada: instructor %d -> %d", before.fees, after.fees)
  lp.lock = savedLock
  ES.IsRecipeKnown = savedKnown
  ES.lockedPlans.Leatherworking = nil
  acid.fee, acid.train, acid.trainer = saved[1], saved[2], saved[3]
  ES.db.trainerFees, ES.db.trainerFeesCSV = nil, nil
  GetNumTrainerServices, GetTrainerServiceInfo, GetTrainerServiceSkillLine, GetTrainerServiceCost = nil, nil, nil, nil
  GetTrainerServiceSkillReq, GetTrainerServiceItemLink, UnitReaction = nil, nil, nil
end)
step("pesca: guía por tramos", function()
  -- Página propia: tramos con cómo conseguir el rango y las zonas; marca el tuyo
  local page = ES:GetMainFrame().pages.Fishing
  assert(page and ES.fishingPage == page, "no hay página de Pesca")
  ES:SelectPage("Fishing")
  page._scripts.OnShow(page)
  local sections, zones = 0, 0
  for _, l in ipairs(page.lines) do
    if l.section then sections = sections + 1 elseif l.icon == "Interface\\Icons\\INV_Misc_Map_01" then zones = zones + 1 end
  end
  log[#log+1] = string.format("     pesca: %d tramos, %d zonas · %s", sections, zones, tostring(page.lines[1].section))
  assert(sections == 4 and zones > 20, "guía incompleta")
  assert(tostring(page.lines[1].section):find("1%-75"), "el primer tramo debería ser 1-75")
  -- Las filas con camino (instructor, libro, Nat Pagle) se pueden pulsar
  for i, l in ipairs(page.lines) do if l.go then page.rows[i]._scripts.OnClick(page.rows[i]) end end
  -- Tramo según el nivel
  assert(ES.FishingStep(ES.Data.Fishing, 160).rank == "expert", "tramo de 160")
  -- La colección de Pesca: las mejoras de campamento
  local known, total = ES.Collection:Progress("Fishing")
  assert(total == 3, "mejoras de campamento: " .. total)
  ES:SelectPage("home")
end)
step("recetas y objetos en español", function()
  -- Addon en español: las recetas toman su nombre en español (y el buscador encuentra las dos)
  ES.lang = "es"
  ES:LocalizeRecipeNames()
  local r = ES.Data.Cooking.recipes[2538]
  log[#log+1] = "     receta 2538: " .. tostring(r.name) .. " / " .. tostring(r.nameEN)
  assert(r.name == "Carne de lobo carbonizada" and r.nameEN == "Charred Wolf Meat", "nombre de receta: " .. tostring(r.name))
  -- Objeto sin cargar en el juego: el nombre de los datos en el idioma del addon
  assert(ES:DataItemName(2318) == "Cuero ligero", "objeto: " .. tostring(ES:DataItemName(2318)))
  ES.lang = "en"
  assert(ES:DataItemName(2318) == "Light Leather", "objeto en inglés: " .. tostring(ES:DataItemName(2318)))
  ES.lang = "es"
end)
step("cambiar de idioma al momento (sin recargar)", function()
  local reloaded = false
  ReloadUI = function() reloaded = true end
  ES.lang = "es"
  ES.ApplyLocalization()
  ES:LocalizeRecipeNames()
  ES:ShowMainFrame("patterns")
  local old = ES:GetMainFrame()
  -- A inglés: pestañas, nombres de recetas y la ventana nueva en la misma página
  ES:SetLanguage("en")
  assert(not reloaded, "no debería recargar la interfaz")
  assert(ES.db.lang == "en" and ES.lang == "en", "no guardó el idioma")
  local f = ES:GetMainFrame()
  assert(f ~= old, "debería crear la ventana de nuevo")
  assert(ES.db.lastPage == "patterns", "debería volver a la misma página: " .. tostring(ES.db.lastPage))
  assert(ES.Data.Cooking.recipes[2538].name == "Charred Wolf Meat", "receta en inglés: " .. ES.Data.Cooking.recipes[2538].name)
  assert(ES:ProfLabel("Leatherworking") == "Leatherworking", "profesión en inglés")
  local tabTip
  GameTooltip.AddLine = function(_, t) tabTip = tabTip or t end
  f.tabs[1]._scripts.OnEnter(f.tabs[1])
  GameTooltip.AddLine = nil
  log[#log+1] = "     pestaña en inglés: " .. tostring(tabTip)
  assert(tabTip ~= "Subir profesiones", "la pestaña sigue en español")
  -- Y de vuelta a español
  ES:SetLanguage("es")
  assert(ES.Data.Cooking.recipes[2538].name == "Carne de lobo carbonizada", "receta en español")
  assert(ES:ProfLabel("Leatherworking") == "Peletería", "profesión en español")
  ReloadUI = nil
end)
step("estado escaneo sin AH", function() ES.Scanner:Start() end)

return table.concat(log, "\n")
""")
print(out)



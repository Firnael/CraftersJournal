"""Auditoría de rutas con sentido, con los precios del último escaneo (SavedVariables).

Para cada profesión y tramo (con y sin materiales en las bolsas) comprueba lo que un
jugador vería mal:
  - ORDEN: los pasos van seguidos (sin huecos ni solapes) y llegan al objetivo
  - PUNTOS ESCONDIDOS: algo que aún da puntos se fabrica como preparación
  - MEZCLA: un material se compra mientras aún da puntos y se fabrica después
  - SIN INGREDIENTE: un paso usa lo fabricado antes (lo de la ruta) sin que esté hecho
    todavía (simulando nivel a nivel lo producido y lo gastado)
  - PANTALLA: la columna de nivel de la vista Ruta no baja, y cada "Fabrica N×" sale
    antes del primer nivel que lo necesita
  - LENTO (aviso, no error): pasos de más de 8 fabricaciones por punto

Uso:  python -X utf8 tools/route_audit.py        (sale con código 1 si hay errores)
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from harness import run  # noqa: E402

out = run(r"""
local out = {}
local function P(...) out[#out+1] = string.format(...) end
local Planner = ES.Planner
local EPS = 0.01
local errors, warnings = 0, 0
local function N(id) return tostring(ES:DataItemName(id) or id) end
local TOOLS = {}
for _, t in pairs(ES.Data.Tools or {}) do TOOLS[t.item] = true end

-- Materiales de ejemplo en las bolsas (lo típico de quien sube: piedra, cuero, tela)
local BAGS = { [2835] = 300, [2836] = 100, [2318] = 60, [2934] = 120, [2589] = 120, [2840] = 60, [765] = 40, [2447] = 40 }

local page
ES:GetMainFrame()

local function Audit(prof, from, to, owned, forced, label)
  local opts = ES:PlanOptions(prof, from, to, nil)
  opts.owned = owned
  opts.forced = forced
  local p = Planner:Plan(ES.Data[prof], opts)
  local where = label or string.format("%s %d-%d%s", prof, from, to, owned and " (bolsas)" or "")
  local errs, warns = {}, {}
  local function E(...) errs[#errs+1] = string.format(...) end
  local function W(...) warns[#warns+1] = string.format(...) end
  -- ORDEN
  local at = from
  for _, st in ipairs(p.steps) do
    if st.from ~= at then E("ORDEN: %s %d-%d (esperaba empezar en %d)", st.recipe.name, st.from, st.to, at) end
    at = st.to
    local per = st.crafts / math.max(1, st.to - st.from)
    if per > 8 then W("LENTO: %s %d-%d, %.1f fabricaciones por punto", st.recipe.name, st.from, st.to, per) end
  end
  -- Lo fabricado de más en un paso para los siguientes: sus puntos tienen que estar
  -- en el paso (alargado), no escondidos
  for _, st in ipairs(p.steps) do
    if (st.aheadGain or 0) >= 1 and not forced then
      E("PUNTOS ESCONDIDOS: %s %d-%d fabrica %d de más que aún darían %d puntos", st.recipe.name, st.from, st.to, st.aheadCrafts, st.aheadGain)
    end
  end
  -- ...y ese paso va antes que el que lo usa
  for s = from, (p.reached or to) - 1 do
    for item, u in pairs(p.pointUse and p.pointUse[s] or {}) do
      if (u.ahead or 0) > EPS then
        local ok = false
        for _, st in ipairs(p.steps) do
          if st.to <= s and st.recipe.out and st.recipe.out[1] == item and st.aheadCrafts then ok = true end
        end
        if not ok then E("SIN INGREDIENTE: a %d se usa %s hecho de más en un paso que no hay antes", s, N(item)) end
      end
    end
  end
  if p.unfollowable then E("A MEDIAS: un paso pide a mitad fabricar lo que ya necesitaba al empezar") end
  -- Lo que se prepara para un paso sale al empezarlo, no a mitad
  for _, c in ipairs(p.crafted or {}) do
    for _, st in ipairs(p.steps) do
      if c.from and st.from < c.from and c.from < st.to and st.reagents[c.itemID] then
        E("A MEDIAS: 'Fabrica %s' a %d, dentro de %s %d-%d que ya lo usa", N(c.itemID), c.from, st.recipe.name, st.from, st.to)
      end
    end
  end
  if not p.stoppedAt and p.reached ~= to then E("ORDEN: llega a %s, no a %d", tostring(p.reached), to) end
  -- Recetas de lo que se fabrica como preparación
  local craftRecipe = {}
  for _, c in ipairs(p.crafted or {}) do craftRecipe[c.itemID] = c.recipe end
  -- Nivel a nivel: lo fabricado como preparación, lo comprado, lo de la ruta (stock)
  local produced, consumed = {}, {}
  local boughtAt, craftedAt = {}, {}
  -- AL EMPEZAR: lo que un paso gasta de lo fabricado antes tiene que estar hecho al
  -- empezar el paso, todo (no "llega justo de media" nivel a nivel)
  local stepAt, stepUse, stepHave = {}, {}, {}
  for _, st in ipairs(p.steps) do stepAt[st.from] = st end
  local cur
  for s = from, (p.reached or to) - 1 do
    if stepAt[s] then
      cur = stepAt[s]
      stepUse[cur], stepHave[cur] = {}, {}
      for item, q in pairs(produced) do stepHave[cur][item] = q end
    end
    for item, u in pairs(p.pointUse and p.pointUse[s] or {}) do
      if cur and (u.stock or 0) > EPS then stepUse[cur][item] = (stepUse[cur][item] or 0) + u.stock end
    end
    local use = p.pointUse and p.pointUse[s] or {}
    for item, u in pairs(use) do
      local r = craftRecipe[item]
      if (u.craft or 0) > EPS and r and not r.intermediate and not r.conversion and not TOOLS[item]
        and Planner.Chance(r.t, s) > 0 then
        E("PUNTOS ESCONDIDOS: %s se fabrica como preparación a %d, donde aún da puntos", N(item), s)
      end
      if ((u.ah or 0) + (u.vendor or 0)) > EPS then boughtAt[item] = boughtAt[item] or s end
      if (u.craft or 0) > EPS then craftedAt[item] = craftedAt[item] or s end
      if (u.stock or 0) > EPS then
        consumed[item] = (consumed[item] or 0) + u.stock
        if consumed[item] > (produced[item] or 0) + 0.5 then
          E("SIN INGREDIENTE: a %d se usan %.0f %s de la ruta y solo se han hecho %.0f", s, consumed[item], N(item), produced[item] or 0)
        end
      end
    end
    -- Lo que fabrica el paso de este nivel queda para los siguientes
    local id = p.choice and p.choice[s]
    local r = id and ES.Data[prof].recipes[id]
    local ch = p.pointChance and p.pointChance[s]
    if r and r.out and ch and ch > 0 then
      produced[r.out[1]] = (produced[r.out[1]] or 0) + (r.out[2] or 1) / ch
    end
  end
  for _, st in ipairs(p.steps) do
    for item, q in pairs(stepUse[st] or {}) do
      local have = stepHave[st][item] or 0
      if q > have + 1 then
        E("AL EMPEZAR: %s %d-%d gasta %.0f %s de pasos anteriores y al empezar solo hay %.0f", st.recipe.name, st.from, st.to, q, N(item), have)
      end
    end
  end
  for item, b in pairs(boughtAt) do
    local c, r = craftedAt[item], craftRecipe[item]
    if c and b < c and r and not r.intermediate and not r.conversion and Planner.Chance(r.t, b) > 0 then
      E("MEZCLA: %s se compra desde %d (aún da puntos) y se fabrica desde %d", N(item), b, c)
    end
  end
  -- PANTALLA: la vista Ruta como la ve el jugador
  if not page then for _, pg in ipairs(ES.professionPages or {}) do if pg.profKey == prof then page = pg end end end
  local pg
  for _, x in ipairs(ES.professionPages or {}) do if x.profKey == prof then pg = x end end
  if pg and #p.steps > 0 then
    pg.plan, pg.view = p, "route"
    ES:RenderPlan(pg)
    local last = 0
    for _, l in ipairs(pg.lines or {}) do
      local n = l.level and tonumber(tostring(l.level):match("^(%d+)"))
      if n then
        if n < last then E("PANTALLA: '%s' en %d sale tras el nivel %d", tostring(l.title):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""), n, last) end
        last = n
        local item = l.craftCount and l.item
        if item and craftedAt[item] and n > craftedAt[item] + 1 then
          E("PANTALLA: 'Fabrica %s' sale a %d pero hace falta desde %d", N(item), n, craftedAt[item])
        end
      end
    end
  end
  -- (las guías se recorren solo para compararlas: sus fallos no cuentan como nuestros)
  if not forced then errors, warnings = errors + #errs, warnings + #warns end
  P("%-34s %9.2fg  %2d pasos %4d fab%s%s", where, (p.net or 0) / 10000, #p.steps, Planner.TotalCrafts(p),
    #errs > 0 and ("\n    ! " .. table.concat(errs, "\n    ! ")) or "",
    #warns > 0 and ("\n    ~ " .. table.concat(warns, "\n    ~ ")) or "")
  return p, #errs
end

-- Guías de wow-professions.com (Forever), solo como referencia de sentido común: no
-- se copian. Cada guía se recorre con nuestros precios; nuestra ruta tiene que salir
-- igual o mejor (puntuación con el mismo criterio). Si la guía sale mejor y tiene
-- sentido (sin errores), al algoritmo se le escapa algo
local GUIDES = {
  { "Engineering", 1, 150, {
    { 1, 30, 3918 }, { 30, 50, 3922 }, { 50, 51, 7430 }, { 51, 75, 3923 }, { 75, 90, 3929 },
    { 90, 100, 3931 }, { 100, 105, 3973 }, { 105, 125, 3938 }, { 125, 135, 3978 },
    { 135, 145, 3945 }, { 145, 150, 3942 } } },
  { "Alchemy", 1, 150, {
    { 1, 10, 1245246 }, { 10, 55, 7183 }, { 55, 65, 2331 }, { 65, 90, 2334 }, { 90, 120, 3171 },
    { 120, 130, 3173 }, { 130, 150, 7837 } } },
  { "Blacksmithing", 1, 150, {
    { 1, 25, 2660 }, { 25, 50, 3320 }, { 50, 70, 3326 }, { 70, 75, 3323 }, { 75, 95, 2666 },
    { 95, 100, 2672 }, { 100, 112, 3337 }, { 112, 125, 2672 }, { 125, 140, 2742 }, { 140, 150, 9985 } } },
}
local function Guides()
  local Score = Planner.RouteScore
  for _, g in ipairs(GUIDES) do
    local choice = {}
    for _, rg in ipairs(g[4]) do for s = rg[1], rg[2] - 1 do choice[s] = rg[3] end end
    local ours = Audit(g[1], g[2], g[3], nil)
    local guide, gErrs = Audit(g[1], g[2], g[3], nil, choice, "  guía " .. g[1])
    local so, sg = Score(ours), Score(guide)
    if guide.reached ~= g[3] then
      P("    (la guía no llega con nuestros datos: se para en %s)", tostring(guide.stoppedAt))
    elseif gErrs == 0 and so > sg + 100 then
      errors = errors + 1
      P("    ! GUÍA MEJOR: la guía puntúa %.2fg y la nuestra %.2fg", sg / 10000, so / 10000)
    else
      P("    puntuación nuestra %.2fg, guía %.2fg", so / 10000, sg / 10000)
    end
  end
end

for _, prof in ipairs({ "Engineering", "Blacksmithing", "Leatherworking", "Tailoring", "Alchemy", "Enchanting", "Cooking", "FirstAid" }) do
  for _, rg in ipairs({ { 1, 151 }, { 1, 300 }, { 75, 225 }, { 150, 300 } }) do
    Audit(prof, rg[1], rg[2], nil)
  end
  Audit(prof, 1, 151, BAGS)
end
-- Discord: Ingeniería empezada en 6 con Rough Stone en las bolsas (la dinamita sin pólvora)
Audit("Engineering", 6, 125, { [2835] = 300 })
P("== Guías")
Guides()
P("ERRORES: %d · avisos: %d", errors, warnings)
return table.concat(out, "\n")
""")
print(out)
sys.exit(1 if "ERRORES: 0 " not in out else 0)

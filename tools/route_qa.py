"""QA de rutas: planificador de siempre (v1) frente al GPS (v2, Planner.PlanGPS).

Para cada escenario (profesión, tramo, con o sin bolsas) calcula las dos rutas con
los precios del último escaneo (SavedVariables) y compara, con la misma vara
(Planner.RouteScore: coste, 5c por fabricación, 1s por paso, lo de tus bolsas por
lo que vale):
  - PEOR: v2 sale peor que v1 (no debe pasar nunca)
  - tiempo de cálculo de cada una
  - pasos, fabricaciones por punto (POCAS PROB si un paso pide más de 3)
Y la estabilidad: convirtiendo chatarras en cuero la ruta no debe saltar.
Con --deep, además, a fuerza bruta: quitando cada receta de la ruta v2 (y cada
pareja) ninguna ruta debe salir mejor (MEJORABLE).

Uso:  python -X utf8 tools/route_qa.py [--deep]
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from harness import run  # noqa: E402

DEEP = "--deep" in sys.argv

print(run(("DEEP = true\n" if DEEP else "DEEP = false\n") + r"""
local out = {}
local function P(...) out[#out+1] = string.format(...) end
local Planner = ES.Planner
local Score = Planner.RouteScore
local function Route(p)
  local s = {}
  for _, st in ipairs(p.steps) do s[#s+1] = string.format("%s %d-%d", st.recipe.name, st.from, st.to) end
  return table.concat(s, " | ")
end
local function MaxPerPoint(p)
  local m = 0
  for _, st in ipairs(p.steps) do m = math.max(m, st.crafts / math.max(1, st.to - st.from)) end
  return m
end

local bags
for _, c in pairs(ES.db.characters or {}) do
  local lw = c.prof and c.prof.Leatherworking
  if lw and lw.lock and lw.lock.owned then bags = lw.lock.owned end
end

local SC = {}
for _, prof in ipairs({ "Leatherworking", "Tailoring", "Blacksmithing", "Alchemy", "Engineering", "Enchanting", "Cooking", "FirstAid" }) do
  for _, rg in ipairs({ { 1, 75 }, { 50, 100 }, { 75, 125 }, { 100, 150 }, { 150, 200 }, { 1, 225 } }) do
    SC[#SC + 1] = { prof, rg[1], rg[2] }
  end
end
if bags then
  SC[#SC + 1] = { "Leatherworking", 75, 115, bags }
  SC[#SC + 1] = { "Leatherworking", 75, 150, bags }
end
SC[#SC + 1] = { "Leatherworking", 1, 225, { [2318] = 100, [2319] = 100, [2934] = 200 } }

local function Plan(sc, gps, excluded)
  Planner.USE_GPS = gps
  local opts = ES:PlanOptions(sc[1], sc[2], sc[3], nil)
  opts.owned = sc[4]
  opts.excluded = excluded
  local t0 = py_clock()
  local p = Planner:Plan(ES.Data[sc[1]], opts)
  return p, py_clock() - t0
end

local worse, better, same, improvable, slow = 0, 0, 0, 0, 0
local t1, t2 = 0, 0
for _, sc in ipairs(SC) do
  local a, ta = Plan(sc, false)
  local b, tb = Plan(sc, true)
  t1, t2 = t1 + ta, t2 + tb
  local sa, sb = Score(a), Score(b)
  -- v1 no alarga el paso con lo que fabrica de más (ver Walk en PlanGPS): esos puntos
  -- quedan sin contar y la ruta no es la que harías. No vale como referencia
  local hidden = false
  for _, st in ipairs(a.steps) do if (st.aheadGain or 0) >= 1 then hidden = true end end
  if hidden then sa = math.huge end
  local tag
  -- (menos de un 0,05% de diferencia: igual, es redondeo)
  local tol = math.max(1, 0.0005 * math.abs(sa))
  if b.reached < a.reached or (b.reached == a.reached and sb > sa + tol) then tag, worse = "PEOR", worse + 1
  elseif b.reached > a.reached or sb < sa - tol then tag, better = "mejor", better + 1
  else tag, same = "igual", same + 1 end
  if tb > math.max(2 * ta, ta + 0.5) then slow = slow + 1 end
  P("%-14s %3d-%3d %s v1 %8.2fs %5.2fs | v2 %8.2fs %5.2fs %s  pasos %d  máx %.1f fab/punto",
    sc[1], sc[2], sc[3], sc[4] and "B" or " ", sa / 100, ta, sb / 100, tb, tag, #b.steps, MaxPerPoint(b))
  if tag ~= "igual" then
    P("      v1: %s", Route(a))
    P("      v2: %s", Route(b))
  end
  if MaxPerPoint(b) > 3 then P("      POCAS PROB: un paso pide %.1f fabricaciones por punto", MaxPerPoint(b)) end
  if DEEP then
    local ids = {}
    for _, st in ipairs(b.steps) do ids[#ids + 1] = st.id end
    local found
    local function Try(ex, label)
      local p = Plan(sc, true, ex)
      if p.reached >= b.reached and Score(p) < sb - 1 and (not found or Score(p) < Score(found.p)) then found = { p = p, label = label } end
    end
    for i = 1, #ids do
      Try({ [ids[i]] = true }, ES.Data[sc[1]].recipes[ids[i]].name)
      for j = i + 1, #ids do Try({ [ids[i]] = true, [ids[j]] = true }, "pareja") end
    end
    if found then
      improvable = improvable + 1
      P("      MEJORABLE quitando %s: %.2fs (%.2fs mejor) :: %s", found.label, Score(found.p) / 100, (sb - Score(found.p)) / 100, Route(found.p))
    end
  end
end

-- Estabilidad: convertir chatarras en Light Leather no debe cambiar la ruta
local jumps = 0
if bags then
  local routes = {}
  for _, made in ipairs({ 0, 6, 12, 18, 24, 29 }) do
    local o = {}
    for k, q in pairs(bags) do o[k] = q end
    o[2934], o[2318] = 88 - 3 * made, 23 + made
    -- Como en el juego: con la ruta de antes como pista (ES.lastRoutes, ver PlanGPS)
    local p = Plan({ "Leatherworking", 75, 115, o }, true)
    ES.lastRoutes.Leatherworking = { choice = p.choice, via = p.ctx.via }
    routes[#routes + 1] = Route(p)
  end
  for i = 2, #routes do if routes[i] ~= routes[1] then jumps = jumps + 1 end end
  P("estabilidad (convertir chatarras): %s", jumps == 0 and "la ruta no cambia" or (jumps .. " saltos: " .. table.concat(routes, " || ")))
end
ES.lastRoutes.Leatherworking = nil
Planner.USE_GPS = true

P("")
P("RESUMEN: %d escenarios · v2 mejor %d, igual %d, PEOR %d · v2 más lento %d · %s· tiempo v1 %.1fs, v2 %.1fs",
  #SC, better, same, worse, slow, DEEP and (improvable .. " MEJORABLES · ") or "", t1, t2)
return table.concat(out, "\n")
"""))

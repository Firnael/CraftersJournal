local _, ES = ...

-- Cálculos largos (las rutas de las profesiones) repartidos entre fotogramas para
-- que el juego no dé tirones: cada trabajo es una corrutina que cede el control
-- (ES.Yield) cuando se gasta el presupuesto del fotograma, y sigue en el siguiente.
-- Sin debugprofilestop (fuera del juego) los trabajos se hacen de golpe.

-- LIGHT_BUDGET: los trabajos en segundo plano ("¿hay una ruta mejor?"), que nadie
-- espera: menos tiempo por fotograma, después de los demás y nunca en combate
local Jobs = { BUDGET = 8, LIGHT_BUDGET = 3 } -- ms por fotograma
ES.Jobs = Jobs

local queue = {}
local scheduled = false
local frameStart
local budget = Jobs.BUDGET

local function OverBudget()
  return frameStart and debugprofilestop() - frameStart > budget
end

-- Llamado desde dentro de los cálculos largos: cede si se acabó el tiempo del fotograma
function ES.Yield()
  if frameStart and OverBudget() and coroutine.running() then coroutine.yield() end
end

local function Finish(job, ok, result)
  for i, j in ipairs(queue) do
    if j == job then table.remove(queue, i) break end
  end
  if not ok then
    if geterrorhandler then geterrorhandler()(result) end
    return
  end
  for _, fn in pairs(job.listeners) do fn(result) end
end

local Step
local function Schedule()
  if scheduled or #queue == 0 then return end
  scheduled = true
  C_Timer.After(0, Step)
end

function Step()
  scheduled = false
  -- Con la ventana cerrada no se calcula nada: lo pedido sigue en la cola y se
  -- retoma al abrirla (Jobs.Resume, UI.lua). Las rutas solo se calculan si se ven
  if CraftersJournalMainFrame and not CraftersJournalMainFrame:IsShown() then return end
  -- Los de segundo plano van detrás de los que alguien espera
  for i, job in ipairs(queue) do
    if not job.light then
      if i > 1 then table.insert(queue, 1, table.remove(queue, i)) end
      break
    end
  end
  if queue[1] and queue[1].light and InCombatLockdown and InCombatLockdown() then
    scheduled = true
    C_Timer.After(1, Step) -- en combate, nada en segundo plano
    return
  end
  budget = queue[1] and queue[1].light and Jobs.LIGHT_BUDGET or Jobs.BUDGET
  frameStart = debugprofilestop()
  while queue[1] and not OverBudget() do
    local job = queue[1]
    job.co = job.co or coroutine.create(job.fn)
    local ok, result = coroutine.resume(job.co)
    if not ok or coroutine.status(job.co) == "dead" then Finish(job, ok, result) end
  end
  frameStart = nil
  Schedule()
end

-- Lanza `fn` en el hueco `key` para obtener `version` (lo que identifica el
-- resultado). Si ya se está calculando esa versión en cualquier hueco, solo se
-- apunta `onDone` entre quienes esperan (uno por `owner`: si el mismo lo pide otra
-- vez, no se repite). Si en el hueco había otro trabajo, se descarta: lo que
-- calculaba ya no le sirve a nadie. onDone(resultado) se llama al acabar.
function Jobs.Run(key, version, fn, onDone, owner, light)
  owner = owner or onDone
  if not debugprofilestop then
    onDone(fn())
    return
  end
  for _, job in ipairs(queue) do
    if job.version == version then
      job.listeners[owner] = onDone
      return
    end
  end
  for i, job in ipairs(queue) do
    if job.key == key then
      job.listeners[owner] = nil
      if not next(job.listeners) then table.remove(queue, i) end -- otro lo espera: sigue
      break
    end
  end
  queue[#queue + 1] = { key = key, version = version, fn = fn, listeners = { [owner] = onDone }, light = light }
  Schedule()
end

function Jobs.Resume() Schedule() end

function Jobs.Busy(key)
  for _, job in ipairs(queue) do
    if job.key == key then return true end
  end
  return false
end

-- ¿Hay en la cola algún trabajo cuyo hueco empiece por `prefix`? ("plan:Alchemy:")
function Jobs.Queued(prefix)
  for _, job in ipairs(queue) do
    if job.key:sub(1, #prefix) == prefix then return true end
  end
  return false
end

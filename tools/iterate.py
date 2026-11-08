exec(open(__file__.replace("iterate.py", "harness.py"), encoding="utf-8").read())

print(run(r"""
local out = {}
local function log(...) out[#out+1] = string.format(...) end
local function check(cond, ...) if not cond then log("  BUG: " .. string.format(...)) end return cond end
local function step(name, fn)
  PRINTS = {}
  local ok, err = pcall(fn)
  log("%s %s%s", ok and "[OK]  " or "[FAIL]", name, ok and "" or (": " .. tostring(err)))
  for _, p in ipairs(PRINTS) do log("      chat> %s", p) end
end

---------------------------------------------------------------------------
-- Construir subastas a partir del escaneo real
---------------------------------------------------------------------------
local base = CraftersJournalDB.scans[ES:RealmKey()]
local owners = { "Ana", "Pepe", "Luis", "Marta", "Bot" }
local seed = 12345
local function rand(n) seed = (seed * 16807) % 2147483647 return seed % n + 1 end

local function BuildAuctions()
  local list = {}
  for itemID, e in pairs(base.items) do
    if e.ladder and #e.ladder > 0 then
      for i = 1, #e.ladder, 2 do
        local price, qty = e.ladder[i], e.ladder[i + 1]
        while qty > 0 do
          local c = math.min(qty, 20)
          list[#list+1] = { item = itemID, count = c, buyout = price * c, owner = owners[rand(5)], tl = rand(4) }
          qty = qty - c
        end
      end
    elseif e.minUnit then
      local per = math.max(1, math.floor(e.quantity / e.listings))
      for i = 1, e.listings do
        list[#list+1] = { item = itemID, count = per, buyout = e.minUnit * per, owner = owners[rand(5)], tl = rand(4) }
      end
    end
  end
  return list
end

---------------------------------------------------------------------------
-- A. Escaneo completo
---------------------------------------------------------------------------
local firstAuctions
step("A. escaneo completo (AH de facciÃ³n)", function()
  ES.db.lastGetAll = {}
  ES.db.track = {}          -- empezar el seguimiento limpio para comprobar nÃºmeros
  ES.db.history = {}
  AUCTIONS = BuildAuctions()
  firstAuctions = AUCTIONS
  NPC_FACTION = "Alliance"
  FireEvent("AUCTION_HOUSE_SHOW")
  local t0 = py_clock()
  SlashCmdList.CRAFTERSJOURNAL("scan")
  RunTimers()
  local scan = CraftersJournalDB.scans[ES:RealmKey()]
  log("      %d subastas simuladas -> escaneo %d subastas, %d objetos (%.2fs CPU)", #AUCTIONS, scan.total, scan.unique, py_clock() - t0)
  check(scan.total == #AUCTIONS, "total %d ~= %d", scan.total, #AUCTIONS)
  check(not ES.Scanner:IsBusy(), "el escÃ¡ner sigue ocupado: %s", ES.Scanner.state)
  local withLadder = 0
  for _, e in pairs(scan.items) do if e.ladder then withLadder = withLadder + 1 end end
  log("      objetos con escalera de precios: %d", withLadder)
  -- los frames silenciados deben volver a escuchar el evento
  check(AuctionFrame ~= nil, "")
end)

---------------------------------------------------------------------------
-- B. Segundo escaneo con ventas, caducidades y recolocaciones conocidas
---------------------------------------------------------------------------
step("B. segundo escaneo 1h después: las baratas que siguen", function()
  NOW = NOW + 3600
  -- Por objeto, las más baratas (hasta un 10% sobre el mínimo) del primer escaneo.
  -- Se compran 1 de cada 7 de las que no caducan; 1 de cada 11 se recoloca a otro
  -- precio; las de tiempo corto/medio caducan. Las que siguen tal cual = "siguen".
  local minUnit = {}
  for _, a in ipairs(firstAuctions) do
    if a.buyout > 0 and ES.History:IsTracked(a.item) then
      local u = a.buyout / a.count
      if not minUnit[a.item] or u < minUnit[a.item] then minUnit[a.item] = u end
    end
  end
  local soldIdx, byItem = {}, {}
  for i, a in ipairs(firstAuctions) do
    if a.tl >= 3 and i % 11 ~= 0 then
      byItem[a.item] = byItem[a.item] or {}
      table.insert(byItem[a.item], i)
    end
  end
  for _, list in pairs(byItem) do
    table.sort(list, function(x, y)
      local ax, ay = firstAuctions[x], firstAuctions[y]
      return ax.buyout / ax.count < ay.buyout / ay.count
    end)
    for k = 1, math.floor(#list / 7) do soldIdx[list[k]] = true end
  end
  local nextList, expRem, expTot = {}, 0, 0
  for i, a in ipairs(firstAuctions) do
    local cheap = minUnit[a.item] and a.buyout > 0 and a.buyout / a.count <= minUnit[a.item] * 1.10
    if cheap then expTot = expTot + 1 end
    if a.tl <= 2 or soldIdx[i] then
      -- caduca o se vende: desaparece
    elseif i % 11 == 0 then
      nextList[#nextList+1] = { item = a.item, count = a.count, buyout = math.floor(a.buyout * 0.95), owner = a.owner, tl = 4 }
    else
      nextList[#nextList+1] = { item = a.item, count = a.count, buyout = a.buyout, owner = a.owner, tl = a.tl }
      if cheap then expRem = expRem + 1 end
    end
  end
  AUCTIONS = nextList
  FireEvent("AUCTION_HOUSE_SHOW")
  SlashCmdList.CRAFTERSJOURNAL("scan")
  RunTimers()
  local h = ES.History:Entries()
  local entry = h[#h]
  -- RunTimers también corre la cuenta atrás de 15 min del botón (y adelanta el reloj)
  check(entry.elapsed >= 3600 and entry.elapsed < 3600 + 15 * 60 + 100, "no se comparó con el escaneo anterior (elapsed %s)", tostring(entry.elapsed))
  local rem, tot = 0, 0
  for _, r, t in (entry.stuck or ""):gmatch(";(%d+):(%d+):(%d+)") do rem, tot = rem + r, tot + t end
  log("      baratas: esperadas %d que siguen de %d; guardadas %d de %d", expRem, expTot, rem, tot)
  check(tot == expTot, "baratas contadas %d ~= %d", tot, expTot)
  -- Una recolocada puede caer justo en la firma de otra que sigue: margen mínimo
  check(math.abs(rem - expRem) <= math.max(1, expRem * 0.01), "las que siguen %d ~= %d", rem, expRem)
  check(entry.sold == nil, "el historial no debe guardar ventas")
end)

step("B2. escaneo antes de 15 min (bloqueado)", function()
  NOW = NOW + 60
  ES.db.lastFullScan = { [ES:CharKey()] = NOW - 60 } -- la cuenta atrás de B ya adelantó el reloj
  SlashCmdList.CRAFTERSJOURNAL("scan")
  RunTimers()
  check(PRINTS[1] and PRINTS[1]:find("15 min"), "no avisÃ³ del lÃ­mite")
end)

step("B3. servidor que no responde (timeout)", function()
  NOW = NOW + 3600
  AH_RESPONDS = false
  local before = #ES.History:Entries()
  SlashCmdList.CRAFTERSJOURNAL("scan")
  RunTimers()
  AH_RESPONDS = true
  check(not ES.Scanner:IsBusy(), "el escÃ¡ner se quedÃ³ ocupado")
  check(#ES.History:Entries() == before, "se guardÃ³ un escaneo sin datos")
end)

step("B4. cerrar la AH a mitad de escaneo", function()
  NOW = NOW + 3600
  SlashCmdList.CRAFTERSJOURNAL("scan")
  RunTimers(1)          -- solo el primer tick
  FireEvent("AUCTION_HOUSE_CLOSED")
  RunTimers()
  check(not ES.Scanner:IsBusy(), "sigue ocupado tras cerrar la AH")
  -- los frames silenciados deben haber vuelto
  local listeners = { GetFramesRegisteredForEvent("AUCTION_ITEM_LIST_UPDATE") }
  log("      frames escuchando AUCTION_ITEM_LIST_UPDATE tras cancelar: %d", #listeners)
end)

---------------------------------------------------------------------------
-- C. AH neutral separada
---------------------------------------------------------------------------
step("C. AH neutral", function()
  NOW = NOW + 3600
  local factionKey = ES:RealmKey()
  NPC_FACTION = nil
  FireEvent("AUCTION_HOUSE_SHOW")
  local nk = ES:RealmKey()
  check(nk ~= factionKey and nk:find("Neutral"), "clave neutral incorrecta: %s", nk)
  AUCTIONS = { { item = 2318, count = 5, buyout = 100, owner = "Gob", tl = 4 } }
  SlashCmdList.CRAFTERSJOURNAL("scan")
  RunTimers()
  check(#ES.History:Entries(nk) == 1, "la AH neutral deberÃ­a tener 1 escaneo")
  check(ES.History:Entries(nk)[1].elapsed == 0, "la neutral se comparÃ³ con otra AH")
  NPC_FACTION = "Alliance"
  FireEvent("AUCTION_HOUSE_SHOW")
  check(ES:RealmKey() == factionKey, "no volviÃ³ a la AH de facciÃ³n")
  FireEvent("AUCTION_HOUSE_CLOSED")
end)

---------------------------------------------------------------------------
-- D. Barrido de planes con invariantes
---------------------------------------------------------------------------
local ranges = { {1,50}, {1,75}, {50,100}, {75,150}, {100,150}, {150,200}, {200,250}, {250,300}, {1,300}, {140,160}, {299,300} }
local data = ES.Data.Leatherworking
local function bad(x) return x ~= x or x == math.huge or x == -math.huge end
step("D. barrido de planes (3 profesiones, con y sin existencias)", function()
  for _, profKey in ipairs({ "Leatherworking", "Enchanting", "Tailoring", "Blacksmithing", "Alchemy", "Engineering", "Cooking", "FirstAid" }) do
  local data = ES.Data[profKey]
  for _, rg in ipairs(ranges) do
    for _, ignore in ipairs({ false, true }) do
      local all = false
      local t0 = py_clock()
      local plan = ES.Planner:Plan(data, { from = rg[1], to = rg[2], sellDays = 2, includeScrolls = all, reuseCrafted = true, ignoreSupply = ignore })
      local dt = py_clock() - t0
      local tag = string.format("%s %d-%d %s", profKey:sub(1, 5), rg[1], rg[2], ignore and "sinstock" or "stock")
      -- pasos contiguos
      local cursor = rg[1]
      local sumTotals = 0
      for _, st in ipairs(plan.steps) do
        check(st.from == cursor, "%s: hueco en pasos (%d esperado, empieza %d)", tag, cursor, st.from)
        cursor = st.to
        check(st.crafts >= 1, "%s: paso con %d fabricaciones", tag, st.crafts)
        check(not bad(st.unitCost) and not bad(st.unitValue) and not bad(st.total), "%s: NaN/inf en %s", tag, st.recipe.name)
        local learn = ES.Planner.LearnSkill(st.recipe, { includeScrolls = all })
        check(learn and learn <= st.from, "%s: %s usada antes de poder aprenderla (%s > %d)", tag, st.recipe.name, tostring(learn), st.from)
        check(ES.Planner.Chance(st.recipe.t, st.to - 1) > 0, "%s: %s usada en gris", tag, st.recipe.name)
        sumTotals = sumTotals + st.total
      end
      check(cursor == plan.reached, "%s: los pasos acaban en %d pero reached=%d", tag, cursor, plan.reached)
      for _, rk in ipairs(plan.ranks) do sumTotals = sumTotals + rk.fee end
      for _, tl in ipairs(plan.tools) do sumTotals = sumTotals + tl.cost end
      check(math.abs(sumTotals - plan.net) < 1, "%s: suma de la columna Total (%.0f) ~= neto del plan (%.0f)", tag, sumTotals, plan.net)
      -- compras <= existencias (solo si se respetan existencias)
      for _, sh in ipairs(plan.shopping) do
        if sh.source == "ah" and not ignore then
          check(sh.quantity <= (sh.supply or 0) + 1, "%s: compra %d de %d pero solo hay %s", tag, sh.quantity, sh.itemID, tostring(sh.supply))
        end
        check(not bad(sh.total), "%s: NaN en compra", tag)
      end
      -- coste de materiales de los pasos ~ total de la lista de la compra
      local shopTotal = 0
      for _, sh in ipairs(plan.shopping) do shopTotal = shopTotal + sh.total end
      local expectedCost = 0
      for _, st in ipairs(plan.steps) do expectedCost = expectedCost + st.costSum end
      expectedCost = expectedCost - plan.stockValue + plan.toolsCost -- inventario no se compra; herramientas sí
      check(math.abs(shopTotal - expectedCost) < 1 + expectedCost * 0.001, "%s: lista de la compra %.0f ~= materiales esperados %.0f", tag, shopTotal, expectedCost)
      log("      %-24s neto %10.0f  llega %3d  pasos %2d  compra %2d  herram %d  %.2fs%s", tag, plan.net, plan.reached, #plan.steps, #plan.shopping, #plan.tools, dt,
        plan.stoppedAt and "  (parado)" or "")
      check(dt < 1.0, "%s: el cálculo tarda %.2fs (congelaría el juego)", tag, dt)
    end
  end
  end
end)

---------------------------------------------------------------------------
-- D2. Detalle de planes para revisar a mano
---------------------------------------------------------------------------
step("D2. detalle 100-160 con y sin inventario del plan", function()
  for _, reuse in ipairs({ false, true }) do
    local plan = ES.Planner:Plan(data, { from = 100, to = 160, sellAH = true, sellDays = 2, includeScrolls = false, reuseCrafted = reuse })
    log("      --- %s: neto %.0f, llega a %d, valor usado del inventario %.0f", reuse and "CON inventario" or "SIN inventario", plan.net, plan.reached, plan.stockValue)
    for _, k in ipairs(plan.kept) do log("      GUARDAR %dx item %d", k.quantity, k.itemID) end
    for _, st in ipairs(plan.steps) do
      log("      %3d-%3d %-32s x%-3d coste %7.0f venta %6.0f aprender %6d %-8s total %9.0f",
        st.from, st.to, st.recipe.name, st.crafts, st.unitCost, st.unitValue, st.fee, tostring(st.learnSource or ""), st.total)
    end
    local s, m = {}, {}
    for it in pairs(plan.shortSupply) do s[#s+1] = it end
    for it in pairs(plan.missingPrice) do m[#m+1] = it end
    log("      parado por existencias: %s | sin precio: %d objetos", table.concat(s, ","), #m)
  end
  -- Â¿quÃ© recetas de instructor hay por encima de 250?
  local above = {}
  for id, r in pairs(data.recipes) do
    if r.fee and r.t[4] > 250 then above[#above+1] = string.format("%s(%d, aprende %d)", r.name, r.t[4], r.train) end
  end
  log("      recetas de instructor con gris > 250: %s", table.concat(above, "; "))
end)

---------------------------------------------------------------------------
-- F. Silenciar/devolver eventos a la UI de Blizzard
---------------------------------------------------------------------------
step("F. la UI de Blizzard recupera AUCTION_ITEM_LIST_UPDATE", function()
  local blizz = CreateFrame("Frame")
  blizz:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
  local got = 0
  blizz:SetScript("OnEvent", function() got = got + 1 end)
  NOW = NOW + 3600
  FireEvent("AUCTION_HOUSE_SHOW")
  AUCTIONS = BuildAuctions()
  SlashCmdList.CRAFTERSJOURNAL("scan")
  RunTimers()
  check(got == 0, "la UI de Blizzard recibiÃ³ el getAll (%d veces): congelarÃ­a el juego", got)
  check(blizz._events["AUCTION_ITEM_LIST_UPDATE"], "la UI de Blizzard no recuperÃ³ el evento tras el escaneo")
  -- cancelado a mitad
  NOW = NOW + 3600
  SlashCmdList.CRAFTERSJOURNAL("scan")
  RunTimers(1)
  FireEvent("AUCTION_HOUSE_CLOSED")
  RunTimers()
  check(blizz._events["AUCTION_ITEM_LIST_UPDATE"], "la UI de Blizzard no recuperÃ³ el evento tras cancelar")
end)

---------------------------------------------------------------------------
-- G. Datos guardados: serializables y de tamaÃ±o razonable
---------------------------------------------------------------------------
local function Size(v, seen, depth)
  local t = type(v)
  if t == "number" then return 8 end
  if t == "string" then return #v + 4 end
  if t == "boolean" then return 5 end
  if t == "table" then
    if seen[v] then error("ciclo en los datos guardados") end
    if depth > 20 then error("anidado demasiado profundo") end
    seen[v] = true
    local s = 2
    for k, x in pairs(v) do s = s + Size(k, seen, depth + 1) + Size(x, seen, depth + 1) + 4 end
    seen[v] = nil
    return s
  end
  error("tipo no guardable en SavedVariables: " .. t)
end
step("G. SavedVariables serializables y tamaÃ±o tras muchos escaneos", function()
  log("      tamaÃ±o actual aprox: %.0f KB", Size(CraftersJournalDB, {}, 0) / 1024)
  local track = ES.db.track[ES:RealmKey()]
  local n = 0
  for _ in pairs(track.sigs) do n = n + 1 end
  log("      firmas de seguimiento del Ãºltimo escaneo: %d", n)
  -- simular 100 escaneos mÃ¡s cada 30 min
  local base2 = BuildAuctions()
  for i = 1, 100 do
    NOW = NOW + 1800
    AUCTIONS = base2
    FireEvent("AUCTION_HOUSE_SHOW")
    SlashCmdList.CRAFTERSJOURNAL("scan")
    RunTimers()
  end
  local h = ES.History:Entries()
  log("      escaneos en historial: %d; tamaÃ±o aprox tras 100 escaneos: %.0f KB", #h, Size(CraftersJournalDB, {}, 0) / 1024)
  ES:ShowMainFrame()
  ES:SelectPage("ah")
  for _, w in ipairs({ "24h", "3d", "7d" }) do
    ES.db.topWindow = w
    local t0 = py_clock()
    ES:RenderResults()
    local shown = 0
    for _, row in ipairs(CraftersJournalMainFrame.rows) do if row._shown then shown = shown + 1 end end
    log("      pintar mercado (%s) con historial lleno: %.3fs, %d filas", w, py_clock() - t0, shown)
  end
  local t0
  t0 = py_clock()
  ES.Planner:Plan(data, { from = 1, to = 300, sellAH = true, sellDays = 2, includeScrolls = true })
  log("      plan 1-300 con historial lleno: %.3fs", py_clock() - t0)
end)

---------------------------------------------------------------------------
-- H. Cliente con la API moderna de la AH (C_AuctionHouse)
---------------------------------------------------------------------------
step("H. escaneo con API moderna", function()
  local saved = { QueryAuctionItems, GetNumAuctionItems, GetAuctionItemInfo, GetAuctionItemTimeLeft, CanSendAuctionQuery }
  QueryAuctionItems, GetNumAuctionItems, GetAuctionItemInfo, GetAuctionItemTimeLeft, CanSendAuctionQuery = nil, nil, nil, nil, nil
  C_AuctionHouse = {
    ReplicateItems = function() C_Timer.After(5, function() FireEvent("REPLICATE_ITEM_LIST_UPDATE") end) end,
    GetNumReplicateItems = function() return #AUCTIONS end,
    GetReplicateItemInfo = function(i) local a = AUCTIONS[i + 1] if not a then return end
      return nil, nil, a.count, 1, true, 1, nil, 0, 0, a.buyout, 0, nil, nil, a.owner, a.owner, 0, a.item, true end,
    GetReplicateItemTimeLeft = function(i) return AUCTIONS[i + 1] and AUCTIONS[i + 1].tl - 1 end,
  }
  AuctionHouseFrame = CreateFrame("Frame")
  NOW = NOW + 3600
  AUCTIONS = BuildAuctions()
  FireEvent("AUCTION_HOUSE_SHOW")
  SlashCmdList.CRAFTERSJOURNAL("scan")
  RunTimers()
  local scan = CraftersJournalDB.scans[ES:RealmKey()]
  check(scan.total == #AUCTIONS, "API moderna: total %d ~= %d", scan.total, #AUCTIONS)
  -- Por tandas (como el servidor de Forever): el evento llega con la primera; antes se
  -- procesaba ahí y el escaneo se quedaba en 1024 justas
  local avail = 0
  C_AuctionHouse.GetNumReplicateItems = function() return avail end
  local getInfo = C_AuctionHouse.GetReplicateItemInfo
  C_AuctionHouse.GetReplicateItemInfo = function(i) if i < avail then return getInfo(i) end end
  C_AuctionHouse.ReplicateItems = function()
    C_Timer.After(5, function() avail = math.floor(#AUCTIONS / 2) FireEvent("REPLICATE_ITEM_LIST_UPDATE") end)
    C_Timer.After(8, function() avail = #AUCTIONS FireEvent("REPLICATE_ITEM_LIST_UPDATE") end)
  end
  NOW = NOW + 3600
  SlashCmdList.CRAFTERSJOURNAL("scan")
  RunTimers()
  scan = CraftersJournalDB.scans[ES:RealmKey()]
  check(scan.total == #AUCTIONS, "API moderna por tandas: total %d ~= %d", scan.total, #AUCTIONS)
  log("      por tandas: %d de %d subastas", scan.total, #AUCTIONS)
  QueryAuctionItems, GetNumAuctionItems, GetAuctionItemInfo, GetAuctionItemTimeLeft, CanSendAuctionQuery = unpack(saved)
  C_AuctionHouse, AuctionHouseFrame = nil, nil
end)

---------------------------------------------------------------------------
-- I. Plan sin límite de existencias y con bolsas
---------------------------------------------------------------------------
step("I. plan hasta 300 sin mirar existencias + opciones", function()
  local base = { from = 1, to = 300, sellDays = 2, reuseCrafted = true, ignoreSupply = true }
  local function run(label, extraOpts)
    local o = {}
    for k, v in pairs(base) do o[k] = v end
    for k, v in pairs(extraOpts or {}) do o[k] = v end
    local plan = ES.Planner:Plan(data, o)
    local sum = 0
    for _, st in ipairs(plan.steps) do sum = sum + st.total end
    for _, rk in ipairs(plan.ranks) do sum = sum + rk.fee end
    check(math.abs(sum - plan.net) < 1, "%s: Total no cuadra", label)
    log("      %-28s neto %10.0f  llega %3d  bolsas %d%s", label, plan.net, plan.reached,
      #plan.owned, plan.stoppedAt and ("  parado: " .. tostring(next(plan.shortSupply) or next(plan.missingPrice) or "sin recetas")) or "")
    return plan
  end
  run("normal")
  run("con 200 cueros ligeros en bolsa", { owned = { [2318] = 200 } })
end)

step("J. colección: la ficha de todas las recetas", function()
  ES:ShowMainFrame()
  local function bad(t) t = tostring(t or "") return t:find("%f[%w]nan%f[%W]") or t:find("%f[%w]inf%f[%W]") end
  local n = 0
  for _, page in ipairs(ES.patternPages) do
    local cf = page.collectionFrame
    ES:SelectPage("pattern:" .. cf.profKey)
    cf._shown = true
    ES:RefreshCollection(cf)
    for _, e in ipairs(cf.data.entries) do
      ES:SelectCollectionEntry(cf, e)
      n = n + 1
      local d = cf.detail
      for i = 1, d.used do
        local line = d.lines[i]
        if bad(line.left._text) or bad(line.right._text) then log("  BUG: ficha con nan/inf: %s = %s", tostring(line.left._text), tostring(line.right._text)) end
      end
      if bad(d.sub._text) or bad(d.status._text) then log("  BUG: cabecera de ficha con nan/inf (%s)", e.recipe.name) end
    end
  end
  log("      fichas pintadas: %d", n)
end)

---------------------------------------------------------------------------
-- E. UI con datos reales
---------------------------------------------------------------------------
step("E. UI: pestaÃ±as, planes y tooltips", function()
  ES:ShowMainFrame()
  for _, w in ipairs({ "24h", "3d", "7d" }) do
    ES.db.topWindow = w
    ES:RenderResults()
  end
  local f = CraftersJournalMainFrame
  for _, row in ipairs(f.rows) do if row._shown then TOOLTIP = {} row._scripts.OnEnter(row) end end
  local function clean(t) return (tostring(t):gsub("|T[^|]+|t", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end
  local function bad(t) t = t or "" return t:find("%f[%w]nan%f[%W]") or t:find("%f[%w]inf%f[%W]") end
  for pi, page in ipairs(ES.professionPages) do
  ES:SelectPage(page.profKey)
  for _, rg in ipairs(ranges) do
    -- El nivel actual lo fija el personaje; aquí se simula para recorrer tramos
    page.from, page.toBox._text = rg[1], tostring(rg[2])
    ES:CalculatePlan(page)
    if rg[1] == 1 and rg[2] == 300 then
      log("      %s 1-%d: total %s · materiales %s · profit %s", page.profKey, page.plan and page.plan.reached or 0,
        clean(page.stats.total._text), clean(page.stats.materials._text), clean(page.stats.profit._text))
    end
    for _, view in ipairs({ "route", "profit", "shop" }) do
      ES:SelectProfessionView(page, view)
      for i = 1, #page.lines do
        local row = page.rows[i]
        if row.tooltip then
          TOOLTIP = {}
          row._scripts.OnEnter(row)
          for _, l in ipairs(TOOLTIP) do if bad(l) then log("  BUG: tooltip con nan/inf: %s", l) end end
        end
        for _, t in ipairs({ row.title._text, row.sub._text, row.value._text }) do
          if bad(t) then log("  BUG: fila con nan/inf: %s", t) end
        end
      end
    end
    for _, fs in pairs(page.stats) do if bad(fs._text) then log("  BUG: resumen con nan/inf: %s", fs._text) end end
  end
  ES:SelectProfessionView(page, "route")
  end
  log("      páginas de profesión: %d, de colección: %d", #ES.professionPages, #ES.patternPages)
end)

return table.concat(out, "\n")
"""))


local _, ES = ...
local L = ES.L

-- Colección: todas las recetas que ofrece el juego en una profesión, cuáles
-- tienes y de dónde sale cada una (instructor, vendedor, misión, reputación,
-- botín, AH), con lo que cuesta fabricarla y a cuánto se vende lo fabricado.
-- También recuerda qué recetas sabe cada personaje (para "la tiene tu alter")
-- y avisa al escanear si aparece en la AH un pergamino de botín que te falta.

local Collection = {}
ES.Collection = Collection

-- Fuente principal de una receta (para contar y filtrar), por orden de prioridad
Collection.SOURCES = { "trainer", "basic", "quest", "favor", "rep", "vendor", "drop", "unknown" }
Collection.SOURCE_LABEL = ES.Localize({
  trainer = "Instructor", basic = "Básica", quest = "Misión", favor = "Merchant's Favor", rep = "Reputación",
  vendor = "Vendedor", drop = "Botín", unknown = "Desconocida",
})
Collection.SOURCE_ICON = {
  trainer = "Interface\\Icons\\INV_Misc_Book_09", basic = "Interface\\Icons\\INV_Misc_Book_09",
  quest = ES.QUEST_ICON, rep = "Interface\\Icons\\INV_Misc_Token_ArgentDawn",
  favor = "Interface\\Icons\\INV_Misc_Coin_17",
  vendor = "Interface\\Icons\\INV_Scroll_03", drop = "Interface\\Icons\\INV_Misc_Bag_10", unknown = "Interface\\Icons\\INV_Misc_QuestionMark",
}

local NEXT_COUNT = 5

-- Recetas que sabe el personaje actual en una profesión; se guardan para los alters
function Collection:SaveKnown(profKey)
  local data = ES.Data[profKey]
  if not data or not ES:GetProfessionSkill(data.skillLine) then return end
  ES.Planner.Annotate(data)
  local list = {}
  for id, r in pairs(data.recipes) do
    if not r.intermediate and not r.conversion and ES:IsRecipeKnown(id) then list[#list + 1] = id end
  end
  ES.db.known = ES.db.known or {}
  local char = ES:CharKey()
  ES.db.known[char] = ES.db.known[char] or {}
  ES.db.known[char][profKey] = list
end

-- Otros personajes (de cualquier reino) que saben la receta
local function AltsKnowing(profKey, id, altSets)
  local names = {}
  for char, set in pairs(altSets) do
    if set[id] then names[#names + 1] = char:match("^[^-]+") or char end
  end
  return names
end

local function AltSets(profKey)
  local sets, me = {}, ES:CharKey()
  for char, profs in pairs(ES.db.known or {}) do
    if char ~= me and profs[profKey] then
      local set = {}
      for _, id in ipairs(profs[profKey]) do set[id] = true end
      sets[char] = set
    end
  end
  return sets
end

-- Fuentes de una receta: lista de { kind, ... } y la principal
local function Sources(r, e)
  local list, main = {}, nil
  local WP = ES.Waypoints
  local function Add(s) list[#list + 1] = s end
  -- Instructor (con precio, o nueva de Forever sin precio conocido: r.trainer)
  local fee = ES.Planner.Fee(r) -- lo visto en el instructor manda sobre los datos
  if fee or r.trainer then Add({ kind = "trainer", cost = fee }) end
  if r.basic then
    Add({ kind = "basic" }) -- se aprende sola al coger la profesión (dato del cliente)
  elseif r.gone then
    -- De instructor en Classic, pero en Forever no la enseña ninguno (ver gen_profession.py)
    Add({ kind = "unknown", gone = true })
  elseif not fee and not r.trainer and not r.scroll and not r.favor and r.basic == nil then
    Add({ kind = r.t[2] <= 50 and "basic" or "unknown" }) -- datos antiguos, sin ese dato
  end
  -- Merchant's Favor: se compra en el campamento de tu bando con esa moneda (no con oro)
  if r.favor then
    local vendors = r.scroll and WP.Vendors(r.scroll) or {}
    Add({ kind = "favor", favor = r.favor, rep = r.favorRep, vendors = vendors, usable = #WP.Usable(vendors) > 0 })
  end
  if r.scroll then
    for _, q in ipairs(WP.QuestsFor(r.scroll) or {}) do Add({ kind = "quest", quest = q }) end
    local vendors = WP.Vendors(r.scroll) or {}
    if #vendors > 0 and not r.favor then -- los del campamento ya van en "favor"
      Add({ kind = r.rep and "rep" or "vendor", vendors = vendors, cost = r.scrollPrice,
        usable = #WP.Usable(vendors) > 0 }) -- algún vendedor de tu bando
    end
    if r.rep and #vendors == 0 and not r.favor then Add({ kind = "rep" }) end
    local drops = WP.Drops(r.scroll)
    if drops then Add({ kind = "drop", drops = drops }) end
    if #list == 0 then Add({ kind = "unknown" }) end
  end
  for _, kind in ipairs(Collection.SOURCES) do
    for _, s in ipairs(list) do
      if s.kind == kind then main = kind break end
    end
    if main then break end
  end
  return list, main or "unknown"
end

-- Todo lo de una profesión. Devuelve { entries, total, known, by = { [fuente] = { total, known } }, next }
function Collection:Build(profKey)
  local data = ES.Data[profKey]
  self:SaveKnown(profKey)
  local skill = ES:GetProfessionSkill(data.skillLine)
  local entries = ES.Planner:RecipeMarket(data, {
    all = true, hours = 24, neutral = ES:IsNeutralAH(),
    sourcedScrolls = ES.Waypoints.SOURCED_PROFESSIONS[profKey] or nil,
  })
  local scan = ES.db.scans and ES.db.scans[ES:RealmKey()]
  local prices = scan and scan.items or {}
  local altSets = AltSets(profKey)
  local res = { entries = {}, total = 0, known = 0, by = {}, skill = skill }
  for _, k in ipairs(Collection.SOURCES) do res.by[k] = { total = 0, known = 0 } end
  for _, e in ipairs(entries) do
    local r = e.recipe
    e.known = e.learnSource == "known"
    e.sources, e.main = Sources(r, e)
    local scrollAH = r.scroll and prices[r.scroll]
    e.scrollAH = scrollAH and scrollAH.minUnit
    e.scrollListings = scrollAH and scrollAH.listings or 0
    e.alts = AltsKnowing(profKey, e.id, altSets)
    e.repOK = not r.rep or ES:RepMet(r.rep)
    -- ¿Puedes aprenderla ya? nivel suficiente y una fuente a mano (no botín)
    -- (las que Forever no enseña no tienen nivel de instructor: el de ponerse amarilla)
    local level = r.train or (r.gone and r.t and r.t[2]) or (r.t and r.t[1]) or 1
    e.level = level
    if not e.known and skill and skill >= level and e.repOK then
      local best
      for _, s in ipairs(e.sources) do
        local here = s.kind == "trainer" or s.kind == "quest" or s.kind == "basic"
          or ((s.kind == "vendor" or s.kind == "rep") and s.usable)
        if here then
          local c = s.cost or 0
          if not best or c < best then best = c end
        end
      end
      if e.scrollAH and (not best or e.scrollAH < best) then best = e.scrollAH end
      if best then e.learnableNow, e.getCost = true, best end
    end
    res.total = res.total + 1
    local b = res.by[e.main]
    b.total = b.total + 1
    if e.known then res.known, b.known = res.known + 1, b.known + 1 end
    res.entries[#res.entries + 1] = e
  end
  table.sort(res.entries, function(a, b)
    if a.level ~= b.level then return a.level < b.level end
    return (a.recipe.name or "") < (b.recipe.name or "")
  end)
  -- Siguientes recetas para completar: las que puedes aprender ya, las más baratas
  local nxt = {}
  for _, e in ipairs(res.entries) do if e.learnableNow then nxt[#nxt + 1] = e end end
  table.sort(nxt, function(a, b) return (a.getCost or 0) < (b.getCost or 0) end)
  res.next = {}
  for i = 1, math.min(NEXT_COUNT, #nxt) do res.next[i] = nxt[i] end
  return res
end

-- Recetas sabidas / totales de una profesión (para la tarjeta de la portada)
function Collection:Progress(profKey)
  local data = ES.Data[profKey]
  ES.Planner.Annotate(data)
  local total, known = 0, 0
  for id, r in pairs(data.recipes) do
    if not r.intermediate and not r.conversion then
      total = total + 1
      if ES:IsRecipeKnown(id) then known = known + 1 end
    end
  end
  return known, total
end

-- Tras un escaneo: pergaminos de botín o reputación que te faltan y están en la AH
-- (los de vendedor se pueden comprar cuando quieras: no se avisa)
function Collection:AlertScan(scan)
  if not scan or not scan.items then return end
  local found = {}
  for _, p in ipairs(ES.PROFESSIONS) do
    local data = ES.Data[p.key]
    if data and ES:GetProfessionSkill(data.skillLine) then
      ES.Planner.Annotate(data)
      for id, r in pairs(data.recipes) do
        local ah = r.scroll and scan.items[r.scroll]
        if ah and ah.minUnit and not ES:IsRecipeKnown(id) and #(ES.Waypoints.Vendors(r.scroll) or {}) == 0
          and #(ES.Waypoints.QuestsFor(r.scroll) or {}) == 0 then
          found[#found + 1] = { name = r.name, price = ah.minUnit, prof = ES:ProfLabel(p.key) }
        end
      end
    end
  end
  if #found == 0 then return end
  table.sort(found, function(a, b) return a.price < b.price end)
  local parts = {}
  for i = 1, math.min(5, #found) do
    parts[i] = string.format("%s (%s, %s)", found[i].name, found[i].prof, ES.Money(found[i].price))
  end
  ES:Print(string.format(L["En la AH hay %d recetas de botín que te faltan: %s%s"], #found, table.concat(parts, ", "),
    #found > 5 and "..." or ""))
end

do
  local f = CreateFrame("Frame")
  ES.SafeRegister(f, "TRADE_SKILL_SHOW")
  ES.SafeRegister(f, "LEARNED_SPELL_IN_TAB")
  f:SetScript("OnEvent", function()
    if not ES.db then return end
    for _, p in ipairs(ES.PROFESSIONS) do Collection:SaveKnown(p.key) end
  end)
end

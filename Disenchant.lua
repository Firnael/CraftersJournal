local _, ES = ...

-- Desencantar: qué da cada objeto (tabla de Classic por calidad, nivel de objeto y si
-- es arma o armadura) y cuánto vale de media a precios de tu AH. Lo usa el Inventario
-- para proponer desencantar en vez de vender cuando sale más a cuenta.
-- Es una estimación: la tabla es la de Classic (Forever podría haberla tocado) y el
-- resultado de cada desencantamiento es al azar; aquí va la media.

local Disenchant = {}
ES.Disenchant = Disenchant

local ENCHANTING = 333
local WEAPON, ARMOR = 2, 4
local GREEN, BLUE, PURPLE = 2, 3, 4

-- Objetos (polvos, esencias, fragmentos)
local STRANGE, SOUL, VISION, DREAM, ILLUSION = 10940, 11083, 11137, 11176, 16204
local LMAGIC, GMAGIC, LASTRAL, GASTRAL, LMYSTIC, GMYSTIC = 10938, 10939, 10998, 11082, 11134, 11135
local LNETHER, GNETHER, LETERNAL, GETERNAL = 11174, 11175, 16202, 16203
local SGLIMMER, LGLIMMER, SGLOW, LGLOW, SRADIANT, LRADIANT = 10978, 11084, 11138, 11139, 11177, 11178
local SBRILLIANT, LBRILLIANT, NEXUS = 14343, 14344, 20725

-- Verdes: por nivel de objeto máximo, { polvo, {min, max} }, { esencia, {min, max} },
-- fragmento, y la probabilidad de polvo / esencia / fragmento en armaduras (en armas
-- se cambian las de polvo y esencia)
local UNCOMMON = {
  { max = 15,  dust = { STRANGE, 1, 2 },  ess = { LMAGIC, 1, 2 },   p = { 0.80, 0.20, 0 } },
  { max = 20,  dust = { STRANGE, 2, 3 },  ess = { GMAGIC, 1, 2 },   shard = SGLIMMER,   p = { 0.75, 0.20, 0.05 } },
  { max = 25,  dust = { STRANGE, 4, 6 },  ess = { LASTRAL, 1, 2 },  shard = SGLIMMER,   p = { 0.75, 0.15, 0.10 } },
  { max = 30,  dust = { SOUL, 1, 2 },     ess = { GASTRAL, 1, 2 },  shard = LGLIMMER,   p = { 0.75, 0.20, 0.05 } },
  { max = 35,  dust = { SOUL, 2, 5 },     ess = { LMYSTIC, 1, 2 },  shard = SGLOW,      p = { 0.75, 0.20, 0.05 } },
  { max = 40,  dust = { VISION, 1, 2 },   ess = { GMYSTIC, 1, 2 },  shard = LGLOW,      p = { 0.75, 0.20, 0.05 } },
  { max = 45,  dust = { VISION, 2, 5 },   ess = { LNETHER, 1, 2 },  shard = SRADIANT,   p = { 0.75, 0.20, 0.05 } },
  { max = 50,  dust = { DREAM, 1, 2 },    ess = { GNETHER, 1, 2 },  shard = LRADIANT,   p = { 0.75, 0.20, 0.05 } },
  { max = 55,  dust = { DREAM, 2, 5 },    ess = { LETERNAL, 1, 2 }, shard = SBRILLIANT, p = { 0.75, 0.20, 0.05 } },
  { max = 60,  dust = { ILLUSION, 1, 2 }, ess = { GETERNAL, 1, 2 }, shard = LBRILLIANT, p = { 0.75, 0.20, 0.05 } },
  { max = 999, dust = { ILLUSION, 2, 5 }, ess = { GETERNAL, 2, 3 }, shard = LBRILLIANT, p = { 0.75, 0.20, 0.05 } },
}
-- Azules: un fragmento (los de nivel 56+, a veces un cristal de nexo)
local RARE = {
  { max = 25, shard = SGLIMMER }, { max = 30, shard = LGLIMMER }, { max = 35, shard = SGLOW },
  { max = 40, shard = LGLOW }, { max = 45, shard = SRADIANT }, { max = 50, shard = LRADIANT },
  { max = 55, shard = SBRILLIANT }, { max = 999, shard = LBRILLIANT, nexus = 0.005 },
}
-- Épicos
local EPIC = {
  { max = 45, out = { SRADIANT, 2, 4 } }, { max = 50, out = { LRADIANT, 2, 4 } },
  { max = 55, out = { SBRILLIANT, 2, 4 } }, { max = 60, out = { NEXUS, 1, 1 } },
  { max = 999, out = { NEXUS, 1, 2 } },
}

-- Nivel de Encantamiento que pide desencantar un objeto de ese nivel
local function RequiredSkill(ilvl)
  if ilvl <= 20 then return 1 end
  if ilvl <= 60 then return 25 * math.ceil((ilvl - 20) / 5) end
  return 225
end

local function Band(tbl, ilvl)
  for _, b in ipairs(tbl) do if ilvl <= b.max then return b end end
end

local function GetItemInfoCompat(itemID)
  return ((C_Item and C_Item.GetItemInfo) or GetItemInfo)(itemID)
end

-- Lo que da desencantar un objeto: { { itemID, media de unidades }, ... }, nivel de
-- Encantamiento que pide; nil si no se puede desencantar (o el juego aún no lo tiene)
function Disenchant:Results(itemID)
  local _, _, quality, ilvl, _, _, _, _, _, _, _, classID = GetItemInfoCompat(itemID)
  if not quality or not ilvl or (classID ~= WEAPON and classID ~= ARMOR) then return nil end
  local out = {}
  local function Add(id, chance, lo, hi) if id and chance > 0 then out[#out + 1] = { id, chance * (lo + hi) / 2 } end end
  if quality == GREEN and ilvl >= 5 then
    local b = Band(UNCOMMON, ilvl)
    local pDust, pEss = b.p[1], b.p[2]
    if classID == WEAPON then pDust, pEss = pEss, pDust end
    Add(b.dust[1], pDust, b.dust[2], b.dust[3])
    Add(b.ess[1], pEss, b.ess[2], b.ess[3])
    Add(b.shard, b.p[3], 1, 1)
  elseif quality == BLUE and ilvl >= 11 then
    local b = Band(RARE, ilvl)
    Add(b.shard, 1 - (b.nexus or 0), 1, 1)
    Add(NEXUS, b.nexus or 0, 1, 1)
  elseif quality == PURPLE and ilvl >= 40 then
    local b = Band(EPIC, ilvl)
    Add(b.out[1], 1, b.out[2], b.out[3])
  else
    return nil
  end
  return out, RequiredSkill(ilvl)
end

-- Lo que vale un material: en la AH, lo que te queda tras la comisión; sin precio de
-- AH, lo que paga el vendedor (y se avisa: el valor puede ser mayor)
local function MaterialValue(itemID, scan)
  local entry = scan and scan.items[itemID]
  if entry and entry.minUnit then
    local price = ES.Market.ListPrice(ES.Market:FairPrice(itemID, entry.minUnit))
    local _, cut = ES.Planner.AuctionCosts(ES:VendorSellPrice(itemID) or 0, { hours = 24, neutral = ES:IsNeutralAH() })
    return math.floor(price * (1 - cut)), true
  end
  return ES:VendorSellPrice(itemID) or 0, false
end

-- Valor medio de desencantar un objeto:
-- { value, results = { {itemID, unidades, valor} }, skill, partial (algún material sin
-- precio de AH) }, o nil si no se puede desencantar
function Disenchant:Value(itemID, scan)
  local results, skill = self:Results(itemID)
  if not results then return nil end
  local total, partial, lines = 0, false, {}
  for _, r in ipairs(results) do
    local unit, priced = MaterialValue(r[1], scan)
    if not priced then partial = true end
    total = total + r[2] * unit
    lines[#lines + 1] = { r[1], r[2], r[2] * unit }
  end
  return { value = math.floor(total), results = lines, skill = skill, partial = partial }
end

-- ¿Puedes desencantarlo? true; o false y el nivel de Encantamiento que tienes (nil si no
-- tienes Encantamiento)
function Disenchant:CanDisenchant(skill)
  local rank = ES:GetProfessionSkill(ENCHANTING)
  return rank ~= nil and rank >= skill, rank
end

-- Nombre del hechizo Desencantar en el idioma del cliente (para la macro)
function Disenchant:SpellName()
  local name = GetSpellInfo and GetSpellInfo(13262)
  if not name and C_Spell and C_Spell.GetSpellName then name = C_Spell.GetSpellName(13262) end
  return name
end

-- Generado por tools/gen_profession.py (Alchemy). No editar a mano.
-- Datos: cliente de WoW Forever (wago.tools DB2), instructores de CMaNGOS classic-db, vendedores de QuestieDB.
local _, ES = ...
ES.Data = ES.Data or {}

-- t = { naranja, amarilla, verde, gris }; fee/train = precio y habilidad del instructor
-- (sin fee = se aprende de pergamino: de dónde sale, en Data/Sources.lua; scrollPrice = su precio si lo vende un PNJ)
-- rep = { facción, nivel } que pide el pergamino para aprenderla (5 amistoso, 6 honorable, 7 venerado, 8 exaltado)
-- r = { {itemID, cantidad} }; out = { itemID, cantidad }
-- sq / oq = calidad del pergamino / de lo fabricado (0 pobre, 1 común, 2 poco común, 3 raro, 4 épico)
-- faction = bando que puede aprenderla, si solo es de uno
-- bop = lo fabricado se liga al recogerlo: no se puede vender en la AH (sí al vendedor)
-- favor / favorRep = se compra con Merchant's Favor en el campamento de tu bando, y la reputación que pide
-- train ajustado a Forever: nivel de Classic menos lo que Forever bajó la amarilla de esa receta
-- basic = se aprende sola al coger la profesión; trainer = de instructor sin precio conocido
--   (receta nueva de Forever que no está en CMaNGOS: se aprende al ponerse amarilla)
ES.Data.Alchemy = {
  skillLine = 171,
  ranks = { -- { tope, precio, habilidad requerida, nivel de personaje }
    { 150, 450, 50, 10 },
    { 225, 5000, 125, 20 },
    { 300, 45000, 200, 35 },
  },
  -- { PNJ instructor, rangos que enseña: 1 aprendiz (75), 2 oficial (150), 4 experto (225), 8 artesano (300) }
  trainers = { { 1215, 1 }, { 1246, 1 }, { 1386, 8 }, { 1470, 1 }, { 2132, 1 }, { 2391, 2 }, { 2837, 2 }, { 3009, 2 }, { 3184, 1 }, { 3347, 2 }, { 3603, 1 }, { 3964, 2 }, { 4160, 4 }, { 4609, 2 }, { 4611, 4 }, { 4900, 2 }, { 5177, 2 }, { 5499, 2 }, { 5500, 1 }, { 7948, 8 }, { 11041, 1 }, { 11042, 2 }, { 11044, 1 }, { 11046, 1 }, { 11047, 1 }, { 246793, 4 }, { 246795, 4 }, { 253004, 1 }, { 257005, 1 }, { 257019, 1 }, { 259585, 8 }, { 275322, 4 } },
  recipes = {
    [2329] = { name = "Elixir of Minor Strength", t = { 1, 55, 75, 95 }, fee = 50, train = 15, r = { { 2449, 1 }, { 765, 1 }, { 3371, 1 } }, out = { 2454, 1 }, oq = 1 },
    [2331] = { name = "Minor Mana Potion", t = { 1, 65, 85, 105 }, fee = 90, train = 25, r = { { 785, 1 }, { 2447, 1 }, { 3371, 1 } }, out = { 2455, 1 }, oq = 1 },
    [2333] = { name = "Elixir of Lesser Agility", t = { 1, 165, 185, 205 }, scroll = 3396, train = 140, sq = 2, r = { { 3355, 1 }, { 2452, 1 }, { 3372, 1 } }, out = { 3390, 1 }, oq = 1 },
    [2365] = { name = "Draught of Tongues", t = { 1, 100, 120, 140 }, scroll = 2556, train = 90, sq = 1, r = { { 2449, 2 }, { 785, 2 }, { 3371, 1 } }, out = { 2460, 1 }, oq = 1 },
    [3170] = { name = "Minor Troll's Blood Elixir", t = { 1, 60, 80, 100 }, fee = 50, train = 15, r = { { 2447, 1 }, { 2449, 2 }, { 3371, 1 } }, out = { 3382, 1 }, oq = 1 },
    [3171] = { name = "Elixir of Wisdom", t = { 1, 120, 140, 160 }, fee = 500, train = 90, r = { { 785, 1 }, { 2450, 2 }, { 3371, 1 } }, out = { 3383, 1 }, oq = 1 },
    [3172] = { name = "Minor Magic Resistance Potion", t = { 1, 135, 155, 175 }, scroll = 3393, train = 110, sq = 1, r = { { 785, 3 }, { 3355, 1 }, { 3371, 1 } }, out = { 3384, 1 }, oq = 1 },
    [3173] = { name = "Lesser Mana Potion", t = { 1, 145, 165, 185 }, fee = 1500, train = 120, r = { { 785, 1 }, { 3820, 1 }, { 3371, 1 } }, out = { 3385, 1 }, oq = 1 },
    [3174] = { name = "Potion of Poison Cleansing", t = { 1, 145, 165, 185 }, scroll = 3394, train = 120, sq = 1, r = { { 1288, 1 }, { 2453, 1 }, { 3372, 1 } }, out = { 3386, 1 }, oq = 1 },
    [3175] = { name = "Limited Invulnerability Potion", t = { 1, 275, 295, 315 }, scroll = 3395, train = 250, sq = 2, r = { { 8839, 2 }, { 8845, 1 }, { 8925, 1 } }, out = { 3387, 1 }, oq = 1 },
    [3176] = { name = "Lesser Troll's Blood Elixir", t = { 1, 150, 170, 190 }, fee = 1500, train = 125, r = { { 2453, 2 }, { 2450, 2 }, { 3372, 1 } }, out = { 3388, 1 }, oq = 1 },
    [3177] = { name = "Elixir of Lesser Defense", t = { 1, 155, 175, 195 }, fee = 2000, train = 130, r = { { 3355, 1 }, { 3820, 1 }, { 3372, 1 } }, out = { 3389, 1 }, oq = 1 },
    [3188] = { name = "Elixir of Ogre Strength", t = { 1, 175, 195, 215 }, scroll = 6211, train = 150, sq = 1, r = { { 2449, 1 }, { 3356, 1 }, { 3372, 1 } }, out = { 3391, 1 }, oq = 1 },
    [3230] = { name = "Elixir of Minor Agility", t = { 1, 80, 100, 120 }, scroll = 2553, train = 50, sq = 2, r = { { 2452, 1 }, { 765, 1 }, { 3371, 1 } }, out = { 2457, 1 }, oq = 1 },
    [3448] = { name = "Lesser Invisibility Potion", t = { 1, 185, 205, 225 }, fee = 5000, train = 165, r = { { 3818, 1 }, { 3355, 1 }, { 3372, 1 } }, out = { 3823, 1 }, oq = 1 },
    [3449] = { name = "Shadow Oil", t = { 1, 190, 210, 230 }, scroll = 6068, train = 165, scrollPrice = 1500, sq = 1, r = { { 3818, 4 }, { 3369, 4 }, { 3372, 1 } }, out = { 3824, 2 }, oq = 1 },
    [3450] = { name = "Elixir of Lesser Fortitude", t = { 1, 195, 215, 235 }, fee = 6000, train = 175, r = { { 3355, 1 }, { 3821, 1 }, { 3372, 1 } }, out = { 3825, 1 }, oq = 1 },
    [3451] = { name = "Troll's Blood Elixir", t = { 1, 200, 220, 240 }, scroll = 3831, train = 180, sq = 1, r = { { 3357, 1 }, { 2453, 1 }, { 3372, 1 } }, out = { 3826, 1 }, oq = 1 },
    [3452] = { name = "Mana Potion", t = { 1, 180, 200, 220 }, fee = 5000, train = 160, r = { { 3820, 1 }, { 3356, 1 }, { 3372, 1 } }, out = { 3827, 1 }, oq = 1 },
    [3453] = { name = "Draught of Detect Lesser Invisibility", t = { 1, 215, 235, 255 }, scroll = 3832, train = 195, sq = 2, r = { { 3358, 1 }, { 3818, 1 }, { 3372, 1 } }, out = { 3828, 1 }, oq = 1 },
    [3454] = { name = "Frost Oil", t = { 1, 220, 240, 260 }, scroll = 14634, train = 200, scrollPrice = 2500, sq = 2, r = { { 3358, 4 }, { 3819, 2 }, { 3372, 1 } }, out = { 3829, 2 }, oq = 1 },
    [4508] = { name = "Minor Discolored Healing Potion", t = { 1, 55, 75, 95 }, fee = 10, train = 50, tr = { 1937, 249713 }, r = { { 3371, 1 }, { 2447, 1 }, { 730, 1 } }, out = { 4596, 1 }, oq = 1 },
    [4942] = { name = "Lesser Stoneshield Potion", t = { 1, 230, 250, 270 }, scroll = 4624, train = 215, sq = 1, r = { { 3858, 1 }, { 3821, 1 }, { 3372, 1 } }, out = { 4623, 1 }, oq = 1 },
    [6617] = { name = "Rage Potion", t = { 1, 90, 110, 130 }, scroll = 5640, train = 60, scrollPrice = 100, sq = 1, r = { { 5635, 1 }, { 2450, 1 }, { 3371, 1 } }, out = { 5631, 1 }, oq = 1 },
    [6618] = { name = "Great Rage Potion", t = { 1, 195, 215, 235 }, scroll = 5643, train = 175, scrollPrice = 2000, sq = 1, r = { { 5637, 1 }, { 3356, 1 }, { 3372, 1 } }, out = { 5633, 1 }, oq = 1 },
    [6624] = { name = "Free Action Potion", t = { 1, 175, 195, 215 }, scroll = 5642, train = 150, scrollPrice = 1800, sq = 1, r = { { 6370, 2 }, { 3820, 1 }, { 3372, 1 } }, out = { 5634, 1 }, oq = 1 },
    [7179] = { name = "Draught of Water Breathing", t = { 1, 120, 140, 160 }, fee = 450, train = 90, r = { { 3820, 1 }, { 6370, 2 }, { 3371, 1 } }, out = { 5996, 1 }, oq = 1 },
    [7183] = { name = "Elixir of Minor Defense", t = { 1, 55, 75, 95 }, basic = true, r = { { 765, 1 }, { 2447, 1 }, { 3371, 1 } }, out = { 5997, 1 }, oq = 1 },
    [7255] = { name = "Holy Protection Potion", t = { 1, 130, 150, 170 }, scroll = 6053, train = 100, scrollPrice = 800, sq = 1, r = { { 2453, 1 }, { 2452, 1 }, { 3371, 1 } }, out = { 6051, 1 }, oq = 1 },
    [7256] = { name = "Shadow Protection Potion", t = { 1, 160, 180, 200 }, scroll = 6054, train = 135, scrollPrice = 900, sq = 1, r = { { 3369, 1 }, { 3356, 1 }, { 3372, 1 } }, out = { 6048, 1 }, oq = 1 },
    [7257] = { name = "Fire Protection Potion", t = { 1, 210, 230, 250 }, scroll = 6055, train = 165, scrollPrice = 1500, sq = 1, r = { { 4402, 1 }, { 6371, 1 }, { 3372, 1 } }, out = { 6049, 1 }, oq = 1 },
    [7258] = { name = "Frost Protection Potion", t = { 1, 205, 225, 245 }, scroll = 6056, train = 190, scrollPrice = 2000, sq = 1, r = { { 3819, 1 }, { 3821, 1 }, { 3372, 1 } }, out = { 6050, 1 }, oq = 1 },
    [7259] = { name = "Nature Protection Potion", t = { 1, 210, 230, 250 }, scroll = 6057, train = 190, scrollPrice = 2000, sq = 1, r = { { 3357, 1 }, { 3820, 1 }, { 3372, 1 } }, out = { 6052, 1 }, oq = 1 },
    [7836] = { name = "Blackmouth Oil", t = { 1, 80, 90, 100 }, fee = 250, train = 80, r = { { 6358, 2 }, { 3371, 1 } }, out = { 6370, 1 }, oq = 1 },
    [7837] = { name = "Fire Oil", t = { 1, 150, 160, 170 }, fee = 1000, train = 130, r = { { 6359, 2 }, { 3371, 1 } }, out = { 6371, 2 }, oq = 1 },
    [7841] = { name = "Swim Speed Potion", t = { 1, 130, 150, 170 }, fee = 1000, train = 100, r = { { 2452, 1 }, { 6370, 1 }, { 3371, 1 } }, out = { 6372, 1 }, oq = 1 },
    [7845] = { name = "Elixir of Fire Power", t = { 1, 165, 185, 205 }, fee = 3000, train = 140, r = { { 6371, 2 }, { 3356, 1 }, { 3372, 1 } }, out = { 6373, 1 }, oq = 1 },
    [8240] = { name = "Elixir of Giant Growth", t = { 1, 120, 140, 160 }, scroll = 6663, train = 90, sq = 2, r = { { 6522, 1 }, { 2449, 1 }, { 3371, 1 } }, out = { 6662, 1 }, oq = 1 },
    [11447] = { name = "Draught of Water Walking", t = { 1, 190, 210, 230 }, scroll = 288206, train = 180, sq = 1, r = { { 6370, 1 }, { 3357, 1 }, { 3372, 1 } }, out = { 8827, 1 }, oq = 1 },
    [11448] = { name = "Greater Mana Potion", t = { 1, 220, 240, 260 }, fee = 9000, train = 205, r = { { 3358, 1 }, { 3821, 1 }, { 3372, 1 } }, out = { 6149, 1 }, oq = 1 },
    [11449] = { name = "Elixir of Agility", t = { 1, 205, 225, 245 }, fee = 6500, train = 185, r = { { 3820, 1 }, { 3821, 1 }, { 3372, 1 } }, out = { 8949, 1 }, oq = 1 },
    [11450] = { name = "Elixir of Defense", t = { 1, 215, 235, 255 }, fee = 7500, train = 195, r = { { 3355, 1 }, { 3821, 1 }, { 3372, 1 } }, out = { 8951, 1 }, oq = 1 },
    [11451] = { name = "Oil of Immolation", t = { 1, 220, 240, 260 }, fee = 8000, train = 205, r = { { 4625, 1 }, { 3821, 1 }, { 8925, 1 } }, out = { 8956, 1 }, oq = 1 },
    [11452] = { name = "Restorative Potion", t = { 1, 225, 245, 265 }, r = { { 7067, 1 }, { 3821, 1 }, { 8925, 1 } }, out = { 9030, 1 }, oq = 1 },
    [11453] = { name = "Magic Resistance Potion", t = { 1, 225, 245, 265 }, scroll = 9293, train = 210, sq = 2, r = { { 3358, 1 }, { 8831, 1 }, { 8925, 1 } }, out = { 9036, 1 }, oq = 1 },
    [11456] = { name = "Goblin Rocket Fuel", t = { 1, 225, 245, 265 }, scroll = 10644, train = 210, sq = 1, r = { { 4625, 1 }, { 9260, 1 }, { 3372, 1 } }, out = { 9061, 2 }, oq = 1 },
    [11458] = { name = "Wildvine Potion", t = { 1, 225, 237, 250 }, scroll = 9294, train = 225, sq = 2, r = { { 8153, 1 }, { 8831, 1 }, { 8925, 1 } }, out = { 9144, 1 }, oq = 1 },
    [11459] = { name = "Philosopher's Stone", t = { 1, 240, 260, 280 }, scroll = 9303, train = 225, scrollPrice = 8000, sq = 1, r = { { 3575, 4 }, { 9262, 1 }, { 8831, 4 }, { 4625, 4 } }, out = { 9149, 1 }, oq = 1, bop = true },
    [11460] = { name = "Draught of Detect Undead", t = { 1, 245, 265, 285 }, fee = 5000, train = 230, r = { { 8836, 1 }, { 8925, 1 } }, out = { 9154, 1 }, oq = 1 },
    [11461] = { name = "Arcane Elixir", t = { 1, 250, 270, 290 }, fee = 10000, train = 235, r = { { 8839, 1 }, { 3821, 1 }, { 8925, 1 } }, out = { 9155, 1 }, oq = 1 },
    [11464] = { name = "Invisibility Potion", t = { 1, 250, 270, 290 }, scroll = 9295, train = 235, sq = 2, r = { { 8845, 1 }, { 8838, 1 }, { 8925, 1 } }, out = { 9172, 1 }, oq = 1 },
    [11465] = { name = "Elixir of Greater Intellect", t = { 1, 250, 270, 290 }, fee = 12000, train = 235, r = { { 8839, 1 }, { 3358, 1 }, { 8925, 1 } }, out = { 9179, 1 }, oq = 1 },
    [11466] = { name = "Gift of Arthas", t = { 1, 255, 275, 295 }, scroll = 9296, train = 240, sq = 2, r = { { 8836, 1 }, { 8839, 1 }, { 8925, 1 } }, out = { 9088, 1 }, oq = 1 },
    [11467] = { name = "Elixir of Greater Agility", t = { 1, 255, 275, 295 }, fee = 12000, train = 240, r = { { 8838, 1 }, { 3821, 1 }, { 8925, 1 } }, out = { 9187, 1 }, oq = 1 },
    [11468] = { name = "Draught of Dream Vision", t = { 1, 255, 275, 295 }, scroll = 9297, train = 240, sq = 2, r = { { 8831, 3 }, { 8925, 1 } }, out = { 9197, 1 }, oq = 1 },
    [11472] = { name = "Elixir of Greater Strength", t = { 1, 260, 280, 300 }, scroll = 9298, train = 245, sq = 2, r = { { 8838, 1 }, { 8846, 1 }, { 8925, 1 } }, out = { 9206, 1 }, oq = 1 },
    [11473] = { name = "Ghost Dye", t = { 1, 260, 280, 300 }, scroll = 9302, train = 245, scrollPrice = 9000, sq = 1, r = { { 8845, 2 }, { 4342, 1 }, { 8925, 1 } }, out = { 9210, 2 }, oq = 1 },
    [11476] = { name = "Elixir of Shadow Power", t = { 1, 265, 285, 305 }, scroll = 9301, train = 250, scrollPrice = 10000, sq = 2, r = { { 8845, 3 }, { 8925, 1 } }, out = { 9264, 1 }, oq = 1 },
    [11477] = { name = "Potion of Demon Slaying", t = { 1, 265, 285, 305 }, scroll = 9300, train = 250, scrollPrice = 10000, sq = 1, r = { { 8846, 1 }, { 8845, 1 }, { 8925, 1 } }, out = { 9224, 1 }, oq = 1 },
    [11478] = { name = "Draught of Detect Demon", t = { 1, 265, 285, 305 }, fee = 14000, train = 250, r = { { 8846, 2 }, { 8925, 1 } }, out = { 9233, 1 }, oq = 1 },
    [11479] = { name = "Transmute: Iron to Gold", t = { 1, 240, 260, 280 }, fee = 2500, train = 225, tr = { 3137, 4254 }, r = { { 3575, 1 } }, tool = 12, out = { 3577, 1 }, oq = 2 },
    [11480] = { name = "Transmute: Mithril to Truesilver", t = { 1, 240, 260, 280 }, fee = 10000, train = 225, tr = { 3137, 4254 }, r = { { 3860, 1 } }, tool = 12, out = { 6037, 1 }, oq = 2 },
    [12609] = { name = "Catseye Draught", t = { 1, 220, 240, 260 }, fee = 8000, train = 200, r = { { 3821, 1 }, { 3818, 1 }, { 3372, 1 } }, out = { 10592, 1 }, oq = 1 },
    [15833] = { name = "Dreamless Sleep Potion", t = { 1, 245, 265, 285 }, fee = 10000, train = 230, r = { { 8831, 3 }, { 8925, 1 } }, out = { 12190, 1 }, oq = 1 },
    [17187] = { name = "Transmute: Arcanite", t = { 1, 275, 282, 290 }, scroll = 12958, train = 275, scrollPrice = 50000, sq = 1, r = { { 12359, 1 }, { 12363, 1 } }, tool = 12, out = { 12360, 1 }, oq = 2 },
    [17551] = { name = "Stonescale Oil", t = { 1, 250, 255, 260 }, fee = 15000, train = 250, r = { { 13422, 1 }, { 3372, 1 } }, out = { 13423, 2 }, oq = 1 },
    [17552] = { name = "Mighty Rage Potion", t = { 1, 270, 290, 310 }, scroll = 13476, train = 255, sq = 2, r = { { 8846, 3 }, { 8925, 1 } }, out = { 13442, 1 }, oq = 1 },
    [17553] = { name = "Superior Mana Potion", t = { 1, 275, 295, 315 }, scroll = 13477, train = 260, scrollPrice = 12000, sq = 1, r = { { 8838, 2 }, { 8839, 2 }, { 8925, 1 } }, out = { 13443, 1 }, oq = 1 },
    [17554] = { name = "Elixir of Greater Defense", t = { 1, 280, 300, 320 }, scroll = 13478, train = 265, scrollPrice = 13000, sq = 1, r = { { 13423, 2 }, { 8838, 1 }, { 8925, 1 } }, out = { 13445, 1 }, oq = 1 },
    [17555] = { name = "Elixir of the Sages", t = { 1, 285, 305, 325 }, scroll = 13479, train = 270, sq = 2, r = { { 13463, 1 }, { 13466, 2 }, { 8925, 1 } }, out = { 13447, 1 }, oq = 1 },
    [17557] = { name = "Elixir of Brute Force", t = { 1, 290, 310, 330 }, scroll = 13481, train = 275, sq = 2, r = { { 8846, 2 }, { 13466, 2 }, { 8925, 1 } }, out = { 13453, 1 }, oq = 1 },
    [17559] = { name = "Transmute: Air to Fire", t = { 1, 275, 282, 290 }, scroll = 13482, train = 275, scrollPrice = 15000, rep = { 529, 5 }, sq = 2, r = { { 7082, 1 } }, tool = 12, out = { 7078, 1 }, oq = 2 },
    [17560] = { name = "Transmute: Fire to Earth", t = { 1, 275, 282, 290 }, scroll = 13483, train = 275, sq = 2, r = { { 7078, 1 } }, tool = 12, out = { 7076, 1 }, oq = 2 },
    [17561] = { name = "Transmute: Earth to Water", t = { 1, 275, 282, 290 }, scroll = 13484, train = 275, scrollPrice = 15000, rep = { 576, 4 }, sq = 2, r = { { 7076, 1 } }, tool = 12, out = { 7080, 1 }, oq = 2 },
    [17562] = { name = "Transmute: Water to Air", t = { 1, 275, 282, 290 }, scroll = 13485, train = 275, scrollPrice = 15000, sq = 2, r = { { 7080, 1 } }, tool = 12, out = { 7082, 1 }, oq = 2 },
    [17563] = { name = "Transmute: Undeath to Water", t = { 1, 275, 282, 290 }, scroll = 13486, train = 275, sq = 2, r = { { 12808, 1 } }, tool = 12, out = { 7080, 1 }, oq = 2 },
    [17564] = { name = "Transmute: Water to Undeath", t = { 1, 275, 282, 290 }, scroll = 13487, train = 275, sq = 2, r = { { 7080, 1 } }, tool = 12, out = { 12808, 1 }, oq = 2 },
    [17565] = { name = "Transmute: Life to Earth", t = { 1, 275, 282, 290 }, scroll = 13488, train = 275, sq = 2, r = { { 12803, 1 } }, tool = 12, out = { 7076, 1 }, oq = 2 },
    [17566] = { name = "Transmute: Earth to Life", t = { 1, 275, 282, 290 }, scroll = 13489, train = 275, sq = 2, r = { { 7076, 1 } }, tool = 12, out = { 12803, 1 }, oq = 2 },
    [17570] = { name = "Greater Stoneshield Potion", t = { 1, 295, 315, 335 }, scroll = 13490, train = 280, sq = 2, r = { { 13423, 3 }, { 10620, 1 }, { 8925, 1 } }, out = { 13455, 1 }, oq = 1 },
    [17571] = { name = "Elixir of the Mongoose", t = { 1, 295, 315, 335 }, scroll = 13491, train = 280, sq = 2, r = { { 13465, 2 }, { 13466, 2 }, { 8925, 1 } }, out = { 13452, 1 }, oq = 1 },
    [17572] = { name = "Purification Potion", t = { 1, 300, 320, 340 }, scroll = 13492, train = 285, sq = 2, r = { { 13467, 2 }, { 13466, 2 }, { 8925, 1 } }, out = { 13462, 1 }, oq = 1 },
    [17573] = { name = "Greater Arcane Elixir", t = { 1, 300, 320, 340 }, scroll = 13493, train = 285, sq = 2, r = { { 13463, 3 }, { 13465, 1 }, { 8925, 1 } }, out = { 13454, 1 }, oq = 1 },
    [17574] = { name = "Greater Fire Protection Potion", t = { 1, 305, 325, 345 }, scroll = 13494, train = 290, sq = 2, r = { { 7068, 1 }, { 13463, 1 }, { 8925, 1 } }, out = { 13457, 1 }, oq = 1 },
    [17575] = { name = "Greater Frost Protection Potion", t = { 1, 305, 325, 345 }, scroll = 13495, train = 290, sq = 2, r = { { 7070, 1 }, { 13463, 1 }, { 8925, 1 } }, out = { 13456, 1 }, oq = 1 },
    [17576] = { name = "Greater Nature Protection Potion", t = { 1, 305, 325, 345 }, scroll = 13496, train = 290, sq = 2, r = { { 7067, 1 }, { 13463, 1 }, { 8925, 1 } }, out = { 13458, 1 }, oq = 1 },
    [17577] = { name = "Greater Arcane Protection Potion", t = { 1, 305, 325, 345 }, scroll = 13497, train = 290, sq = 2, r = { { 11176, 1 }, { 13463, 1 }, { 8925, 1 } }, out = { 13461, 1 }, oq = 1 },
    [17578] = { name = "Greater Shadow Protection Potion", t = { 1, 305, 325, 345 }, scroll = 13499, train = 290, sq = 2, r = { { 3824, 1 }, { 13463, 1 }, { 8925, 1 } }, out = { 13459, 1 }, oq = 1 },
    [17579] = { name = "Greater Holy Protection Potion", t = { 1, 305, 325, 345 }, scroll = 13500, train = 290, sq = 2, r = { { 7069, 1 }, { 13463, 1 }, { 8925, 1 } }, out = { 13460, 1 }, oq = 1 },
    [17580] = { name = "Major Mana Potion", t = { 1, 310, 330, 350 }, scroll = 13501, train = 295, scrollPrice = 30000, sq = 2, r = { { 13463, 3 }, { 13467, 2 }, { 8925, 1 } }, out = { 13444, 1 }, oq = 1 },
    [17632] = { name = "Alchemist's Stone", t = { 1, 315, 322, 330 }, scroll = 13517, train = 275, scrollPrice = 40000, sq = 1, r = { { 7078, 8 }, { 7076, 8 }, { 7082, 8 }, { 7080, 8 }, { 12803, 8 }, { 9262, 2 }, { 13468, 4 } }, out = { 13503, 1 }, oq = 2, bop = true },
    [17634] = { name = "Flask of Petrification", t = { 1, 315, 322, 330 }, scroll = 13518, train = 300, scrollPrice = 40000, sq = 2, r = { { 13423, 30 }, { 13465, 10 }, { 13468, 1 }, { 8925, 1 } }, tool = 12, out = { 13506, 1 }, oq = 1 },
    [17635] = { name = "Flask of the Titans", t = { 1, 315, 322, 330 }, scroll = 13519, train = 300, scrollPrice = 40000, sq = 2, r = { { 8846, 30 }, { 13423, 10 }, { 13468, 1 }, { 8925, 1 } }, out = { 13510, 1 }, oq = 1 },
    [17636] = { name = "Flask of Distilled Wisdom", t = { 1, 315, 322, 330 }, scroll = 13520, train = 300, scrollPrice = 40000, sq = 2, r = { { 13463, 30 }, { 13467, 10 }, { 13468, 1 }, { 8925, 1 } }, out = { 13511, 1 }, oq = 1 },
    [17637] = { name = "Flask of Supreme Power", t = { 1, 315, 322, 330 }, scroll = 13521, train = 300, scrollPrice = 40000, sq = 2, r = { { 13463, 30 }, { 13465, 10 }, { 13468, 1 }, { 8925, 1 } }, out = { 13512, 1 }, oq = 1 },
    [17638] = { name = "Flask of Chromatic Resistance", t = { 1, 315, 322, 330 }, scroll = 13522, train = 300, scrollPrice = 40000, sq = 2, r = { { 13467, 30 }, { 13465, 10 }, { 13468, 1 }, { 8925, 1 } }, out = { 13513, 1 }, oq = 1 },
    [21923] = { name = "Elixir of Frost Power", t = { 1, 210, 230, 250 }, scroll = 17709, train = 190, sq = 1, r = { { 3819, 2 }, { 3358, 1 }, { 3372, 1 } }, out = { 17708, 1 }, oq = 1 },
    [22430] = { name = "Refined Scale of Onyxia", t = { 1, 315, 322, 330 }, r = { { 15410, 1 } }, tool = 12, out = { 17967, 1 }, oq = 3 },
    [22732] = { name = "Major Rejuvenation Potion", t = { 1, 310, 320, 330 }, scroll = 18257, train = 300, sq = 3, r = { { 10286, 1 }, { 13464, 4 }, { 13463, 4 }, { 18256, 1 } }, out = { 18253, 1 }, oq = 1 },
    [22808] = { name = "Draught of Greater Water Breathing", t = { 1, 230, 250, 270 }, fee = 10000, train = 215, r = { { 7972, 1 }, { 8831, 2 }, { 8925, 1 } }, out = { 18294, 1 }, oq = 1 },
    [24266] = { name = "Gurubashi Mojo Madness", t = { 1, 315, 322, 330 }, r = { { 12938, 1 }, { 19943, 1 }, { 12804, 6 }, { 13468, 1 } }, out = { 19931, 3 }, oq = 3 },
    [24365] = { name = "Mageblood Elixir", t = { 1, 290, 310, 330 }, scroll = 20011, train = 275, scrollPrice = 50000, rep = { 270, 6 }, sq = 1, r = { { 13463, 1 }, { 13466, 2 }, { 8925, 1 } }, out = { 20007, 1 }, oq = 1 },
    [24366] = { name = "Greater Dreamless Sleep Potion", t = { 1, 290, 310, 330 }, scroll = 20012, train = 275, scrollPrice = 50000, rep = { 270, 4 }, sq = 1, r = { { 13463, 2 }, { 13464, 1 }, { 8925, 1 } }, out = { 20002, 1 }, oq = 1 },
    [24367] = { name = "Living Action Potion", t = { 1, 300, 320, 340 }, scroll = 20013, train = 285, scrollPrice = 50000, rep = { 270, 7 }, sq = 1, r = { { 13467, 2 }, { 13465, 2 }, { 10286, 2 }, { 8925, 1 } }, out = { 20008, 1 }, oq = 1 },
    [24368] = { name = "Major Troll's Blood Elixir", t = { 1, 305, 325, 345 }, scroll = 20014, train = 290, scrollPrice = 50000, rep = { 270, 5 }, sq = 1, r = { { 8846, 1 }, { 13466, 2 }, { 8925, 1 } }, out = { 20004, 1 }, oq = 1 },
    [25146] = { name = "Transmute: Elemental Fire", t = { 1, 301, 305, 310 }, scroll = 20761, train = 300, rep = { 59, 4 }, sq = 1, r = { { 7077, 1 } }, tool = 12, out = { 7068, 3 }, oq = 1 },
    [26277] = { name = "Elixir of Holy Power", t = { 1, 265, 285, 305 }, scroll = 21547, train = 250, sq = 2, r = { { 6371, 3 }, { 4625, 3 }, { 8925, 1 } }, out = { 21546, 1 }, oq = 1 },
    [426607] = { name = "Elixir of Coalesced Regret", t = { 1, 90, 100, 110 }, scroll = 210709, train = 90, sq = 2, r = { { 3820, 5 }, { 3372, 1 }, { 3369, 5 }, { 11083, 1 } }, out = { 210708, 1 }, oq = 1 },
    [435969] = { name = "Insulating Gniodine", t = { 1, 200, 210, 220 }, scroll = 215434, train = 200, sq = 4, r = { { 3372, 1 }, { 213371, 5 } }, out = { 213372, 1 }, oq = 1 },
    [435971] = { name = "Mildly Irradiated Rejuvenation Potion", t = { 1, 225, 230, 235 }, scroll = 215163, train = 225, sq = 4, r = { { 213371, 1 }, { 2456, 1 }, { 215430, 3 }, { 8925, 5 } }, out = { 215162, 5 }, oq = 1 },
    [1213544] = { name = "Flask of Unyielding Sorrow", t = { 1, 315, 322, 330 }, scroll = 234252, train = 305, sq = 1, r = { { 16203, 1 }, { 234012, 1 }, { 13511, 1 }, { 8925, 1 } }, tool = 12, out = { 233966, 1 }, oq = 1 },
    [1230564] = { name = "Mana Well", t = { 1, 20, 22, 25 }, fee = 0, train = 20, r = { { 2447, 1 }, { 3371, 1 } }, out = { 279956, 1 }, oq = 1 },
    [1231583] = { name = "Major Discolored Healing Potion", t = { 1, 290, 310, 330 }, fee = 10000, train = 250, tr = { 1937, 249713 }, r = { { 8925, 1 }, { 13466, 1 }, { 730, 1 } }, out = { 241650, 1 }, oq = 1 },
    [1244421] = { name = "Distilled Firewater", t = { 1, 260, 265, 270 }, scroll = 236754, train = 250, sq = 2, r = { { 3819, 4 }, { 8846, 2 }, { 3372, 1 } }, out = { 246948, 1 }, oq = 1 },
    [1244645] = { name = "Lesser Discolored Healing Potion", t = { 1, 85, 105, 125 }, fee = 100, train = 85, tr = { 1937, 249713 }, r = { { 3371, 1 }, { 2450, 1 }, { 730, 1 } }, out = { 247239, 1 }, oq = 1 },
    [1244646] = { name = "Discolored Healing Potion", t = { 1, 135, 155, 175 }, fee = 500, train = 135, tr = { 1937, 249713 }, r = { { 3372, 1 }, { 2453, 1 }, { 730, 1 } }, out = { 247240, 1 }, oq = 1 },
    [1244647] = { name = "Greater Discolored Healing Potion", t = { 1, 175, 195, 215 }, fee = 1500, train = 175, tr = { 1937, 249713 }, r = { { 3372, 1 }, { 3356, 1 }, { 730, 1 } }, out = { 247241, 1 }, oq = 1 },
    [1244648] = { name = "Superior Discolored Healing Potion", t = { 1, 230, 250, 270 }, fee = 5000, train = 230, tr = { 1937, 249713 }, r = { { 8925, 1 }, { 8838, 1 }, { 730, 1 } }, out = { 247242, 1 }, oq = 1 },
    [1245246] = { name = "Minor Arcane Elixir", t = { 1, 10, 12, 15 }, basic = true, r = { { 2447, 1 }, { 3371, 1 } }, out = { 247754, 1 }, oq = 1 },
    [1245250] = { name = "Elixir of Minor Force", t = { 1, 10, 12, 15 }, basic = true, r = { { 765, 1 }, { 3371, 1 } }, out = { 247755, 1 }, oq = 1 },
    [1249630] = { name = "Cerulean Dye", t = { 1, 50, 70, 90 }, fee = 135, train = 40, r = { { 249399, 2 }, { 3371, 1 } }, out = { 249409, 1 }, oq = 2 },
    [1249631] = { name = "Magenta Dye", t = { 1, 130, 142, 155 }, fee = 1500, train = 120, r = { { 249424, 2 }, { 3372, 1 } }, out = { 249430, 1 }, oq = 2 },
    [1249632] = { name = "Viridian Dye", t = { 1, 230, 250, 270 }, fee = 10000, train = 215, r = { { 249274, 2 }, { 8925, 1 } }, out = { 249431, 1 }, oq = 2 },
    [1249633] = { name = "Sulfuric Acid", t = { 1, 50, 70, 90 }, fee = 135, train = 40, r = { { 249391, 2 }, { 3371, 1 } }, out = { 249410, 1 }, oq = 2 },
    [1250775] = { name = "Revealing Draught", t = { 1, 205, 207, 210 }, scroll = 250362, train = 195, sq = 1, r = { { 3818, 3 }, { 3358, 1 }, { 3372, 1 } }, out = { 250326, 1 }, oq = 1 },
    [1250776] = { name = "Potion of Predatory Senses", t = { 1, 200, 202, 205 }, scroll = 250363, train = 195, sq = 1, r = { { 3818, 2 }, { 3821, 2 }, { 3372, 1 } }, out = { 250327, 1 }, oq = 1 },
    [1250777] = { name = "Elixir of Cunning", t = { 1, 280, 282, 285 }, scroll = 250364, train = 275, sq = 1, favor = 180, favorRep = 6, r = { { 13463, 3 }, { 8846, 2 }, { 8925, 1 } }, out = { 250328, 1 }, oq = 1 },
    [1250778] = { name = "Elixir of the Phalanx", t = { 1, 255, 257, 260 }, scroll = 250365, train = 250, sq = 1, favor = 180, favorRep = 6, r = { { 13464, 2 }, { 8838, 4 }, { 8925, 1 } }, out = { 250329, 1 }, oq = 1 },
    [1250779] = { name = "Minor Cleric's Elixir", t = { 1, 50, 52, 55 }, scroll = 250366, train = 45, sq = 1, r = { { 785, 2 }, { 2453, 1 }, { 3371, 1 } }, out = { 250330, 1 }, oq = 1 },
    [1250780] = { name = "Lesser Cleric's Elixir", t = { 1, 100, 102, 105 }, scroll = 250367, train = 95, sq = 1, favor = 45, r = { { 3356, 2 }, { 3357, 2 }, { 3372, 1 } }, out = { 250331, 1 }, oq = 1 },
    [1250781] = { name = "Cleric's Elixir", t = { 1, 150, 152, 155 }, scroll = 250368, train = 145, sq = 1, r = { { 3819, 2 }, { 4625, 2 }, { 3372, 1 } }, out = { 250332, 1 }, oq = 1 },
    [1250782] = { name = "Greater Cleric's Elixir", t = { 1, 200, 202, 205 }, scroll = 250369, train = 195, sq = 1, favor = 120, favorRep = 5, r = { { 8836, 3 }, { 8831, 1 }, { 8925, 1 } }, out = { 250333, 1 }, oq = 1 },
    [1250783] = { name = "Elixir of Fortitude", t = { 1, 155, 157, 160 }, scroll = 250370, train = 150, sq = 1, r = { { 3821, 4 }, { 3372, 1 } }, out = { 250334, 1 }, oq = 1 },
    [1250784] = { name = "Elixir of Greater Fortitude", t = { 1, 205, 207, 210 }, scroll = 250371, train = 200, sq = 1, favor = 120, favorRep = 5, r = { { 8838, 4 }, { 8925, 1 } }, out = { 250335, 1 }, oq = 1 },
    [1250785] = { name = "Elixir of Wicked Regeneration", t = { 1, 290, 292, 295 }, scroll = 250372, train = 285, sq = 1, favor = 180, favorRep = 6, r = { { 13464, 3 }, { 13463, 2 }, { 8925, 1 } }, out = { 250336, 1 }, oq = 1 },
    [1250786] = { name = "Elixir of the Owl", t = { 1, 285, 287, 290 }, scroll = 250373, train = 280, sq = 1, favor = 180, favorRep = 6, r = { { 13463, 4 }, { 13465, 2 }, { 18256, 1 } }, out = { 250337, 1 }, oq = 1 },
    [1250787] = { name = "Elixir of Sages", t = { 1, 280, 282, 285 }, scroll = 250374, train = 275, sq = 1, favor = 180, favorRep = 6, r = { { 13463, 4 }, { 13464, 2 }, { 18256, 1 } }, out = { 250338, 1 }, oq = 1 },
    [1250788] = { name = "Minor Mageblood Elixir", t = { 1, 30, 32, 35 }, scroll = 250375, train = 25, sq = 1, r = { { 785, 2 }, { 3371, 1 } }, out = { 250339, 1 }, oq = 1 },
    [1250789] = { name = "Lesser Mageblood Elixir", t = { 1, 80, 82, 85 }, scroll = 250376, train = 75, sq = 1, favor = 45, r = { { 3356, 3 }, { 3371, 1 } }, out = { 250340, 1 }, oq = 1 },
    [1250790] = { name = "Greater Mageblood Elixir", t = { 1, 180, 182, 185 }, scroll = 250377, train = 175, sq = 1, favor = 120, favorRep = 5, r = { { 8839, 3 }, { 8836, 2 }, { 8925, 1 } }, out = { 250341, 1 }, oq = 1 },
    [1250791] = { name = "Lesser Arcane Elixir", t = { 1, 125, 127, 130 }, scroll = 250378, train = 120, sq = 1, favor = 45, r = { { 3356, 4 }, { 3372, 1 } }, out = { 250342, 1 }, oq = 1 },
    [1250792] = { name = "Elixir of Nature Power", t = { 1, 290, 292, 295 }, scroll = 250379, train = 285, sq = 1, favor = 180, favorRep = 6, r = { { 13464, 4 }, { 8838, 2 }, { 8925, 1 } }, out = { 250343, 1 }, oq = 1 },
    [1250793] = { name = "Elixir of Minor Spirit", t = { 1, 20, 22, 25 }, scroll = 250380, train = 15, sq = 1, r = { { 2449, 2 }, { 2447, 1 }, { 3371, 1 } }, out = { 250344, 1 }, oq = 1 },
    [1250794] = { name = "Elixir of Lesser Spirit", t = { 1, 70, 72, 75 }, scroll = 250381, train = 65, sq = 1, favor = 45, r = { { 3355, 2 }, { 785, 1 }, { 3371, 1 } }, out = { 250345, 1 }, oq = 1 },
    [1250795] = { name = "Elixir of Spirit", t = { 1, 120, 122, 125 }, scroll = 250382, train = 115, sq = 1, r = { { 3358, 3 }, { 3356, 1 }, { 3372, 1 } }, out = { 250346, 1 }, oq = 1 },
    [1250796] = { name = "Elixir of Greater Spirit", t = { 1, 170, 172, 175 }, scroll = 250383, train = 165, sq = 1, favor = 120, favorRep = 5, r = { { 8836, 3 }, { 8831, 2 }, { 8925, 1 } }, out = { 250347, 1 }, oq = 1 },
    [1250797] = { name = "Elixir of the Whale", t = { 1, 280, 282, 285 }, scroll = 250384, train = 275, sq = 1, favor = 180, favorRep = 6, r = { { 13463, 3 }, { 8846, 1 }, { 8925, 1 } }, out = { 250348, 1 }, oq = 1 },
    [1250798] = { name = "Elixir of Strength", t = { 1, 155, 157, 160 }, scroll = 250385, train = 150, sq = 1, r = { { 3355, 3 }, { 3821, 1 }, { 3372, 1 } }, out = { 250349, 1 }, oq = 1 },
    [1250799] = { name = "Elixir of Ferocity", t = { 1, 280, 282, 285 }, scroll = 250386, train = 275, sq = 1, favor = 180, favorRep = 6, r = { { 8846, 3 }, { 8845, 1 }, { 8925, 1 } }, out = { 250350, 1 }, oq = 1 },
    [1250800] = { name = "Elixir of the Grizzly", t = { 1, 305, 307, 310 }, scroll = 250387, train = 300, sq = 1, favor = 240, favorRep = 6, r = { { 8846, 3 }, { 8839, 1 }, { 8925, 1 } }, out = { 250351, 1 }, oq = 1 },
    [1250801] = { name = "Elixir of Lesser Intellect", t = { 1, 100, 102, 105 }, scroll = 250388, train = 95, sq = 1, favor = 45, r = { { 3356, 3 }, { 3372, 1 } }, out = { 250353, 1 }, oq = 1 },
    [1250802] = { name = "Elixir of Intellect", t = { 1, 140, 142, 145 }, scroll = 250389, train = 135, sq = 1, r = { { 3358, 3 }, { 3372, 1 } }, out = { 250354, 1 }, oq = 1 },
    [1251729] = { name = "Minor Spellblasting Potion", t = { 1, 40, 42, 45 }, scroll = 250976, train = 35, sq = 1, r = { { 765, 1 }, { 2447, 1 }, { 3371, 1 } }, out = { 250932, 1 }, oq = 1 },
    [1251730] = { name = "Lesser Spellblasting Potion", t = { 1, 90, 92, 95 }, scroll = 250977, train = 85, sq = 1, r = { { 785, 1 }, { 765, 2 }, { 3371, 1 } }, out = { 250933, 1 }, oq = 1 },
    [1251731] = { name = "Spellblasting Potion", t = { 1, 140, 142, 145 }, scroll = 250978, train = 135, sq = 1, favor = 45, r = { { 3355, 1 }, { 3369, 1 }, { 3371, 1 } }, out = { 250934, 1 }, oq = 1 },
    [1251732] = { name = "Greater Spellblasting Potion", t = { 1, 190, 192, 195 }, scroll = 250979, train = 185, sq = 2, r = { { 3356, 2 }, { 3818, 1 }, { 3372, 1 } }, out = { 250935, 1 }, oq = 1 },
    [1251733] = { name = "Superior Spellblasting Potion", t = { 1, 240, 242, 245 }, scroll = 250980, train = 235, sq = 1, r = { { 3819, 2 }, { 3358, 2 }, { 3372, 1 } }, out = { 250936, 1 }, oq = 1 },
    [1251734] = { name = "Major Spellblasting Potion", t = { 1, 290, 292, 295 }, scroll = 250981, train = 285, sq = 1, favor = 180, favorRep = 6, r = { { 13463, 2 }, { 13465, 1 }, { 18256, 1 } }, out = { 250937, 1 }, oq = 1 },
    [1251735] = { name = "Minor Frenzy Potion", t = { 1, 45, 47, 50 }, scroll = 250982, train = 40, sq = 1, r = { { 2449, 1 }, { 765, 1 }, { 3371, 1 } }, out = { 250938, 1 }, oq = 1 },
    [1251736] = { name = "Lesser Frenzy Potion", t = { 1, 95, 97, 100 }, scroll = 250983, train = 90, sq = 1, r = { { 2450, 1 }, { 2449, 2 }, { 3371, 1 } }, out = { 250939, 1 }, oq = 1 },
    [1251737] = { name = "Frenzy Potion", t = { 1, 145, 147, 150 }, scroll = 250984, train = 140, sq = 1, favor = 45, r = { { 3818, 2 }, { 2450, 2 }, { 3372, 1 } }, out = { 250940, 1 }, oq = 1 },
    [1251738] = { name = "Greater Frenzy Potion", t = { 1, 195, 197, 200 }, scroll = 250985, train = 190, sq = 2, r = { { 4625, 3 }, { 3818, 2 }, { 3372, 1 } }, out = { 250941, 1 }, oq = 1 },
    [1251739] = { name = "Superior Frenzy Potion", t = { 1, 245, 247, 250 }, scroll = 250986, train = 240, sq = 1, r = { { 8839, 3 }, { 4625, 2 }, { 8925, 1 } }, out = { 250942, 1 }, oq = 1 },
    [1251740] = { name = "Major Frenzy Potion", t = { 1, 295, 297, 300 }, scroll = 250987, train = 290, sq = 1, favor = 240, favorRep = 6, r = { { 13466, 3 }, { 8839, 2 }, { 18256, 1 } }, out = { 250943, 1 }, oq = 1 },
    [1251741] = { name = "Minor Mender's Potion", t = { 1, 35, 37, 40 }, scroll = 250988, train = 30, sq = 1, r = { { 785, 2 }, { 2453, 1 }, { 3371, 1 } }, out = { 250944, 1 }, oq = 1 },
    [1251742] = { name = "Lesser Mender's Potion", t = { 1, 85, 87, 90 }, scroll = 250989, train = 80, sq = 1, r = { { 3356, 2 }, { 3357, 2 }, { 3372, 1 } }, out = { 250945, 1 }, oq = 1 },
    [1251743] = { name = "Mender's Potion", t = { 1, 135, 137, 140 }, scroll = 250990, train = 130, sq = 1, favor = 45, r = { { 3819, 2 }, { 4625, 2 }, { 3372, 1 } }, out = { 250946, 1 }, oq = 1 },
    [1251744] = { name = "Greater Mender's Potion", t = { 1, 185, 187, 190 }, scroll = 250991, train = 180, sq = 1, r = { { 8836, 2 }, { 8831, 1 }, { 8925, 1 } }, out = { 250947, 1 }, oq = 1 },
    [1251745] = { name = "Superior Mender's Potion", t = { 1, 235, 237, 240 }, scroll = 250992, train = 230, sq = 1, r = { { 8838, 2 }, { 8836, 1 }, { 8925, 1 } }, out = { 250948, 1 }, oq = 1 },
    [1251747] = { name = "Major Mender's Potion", t = { 1, 285, 287, 290 }, scroll = 250993, train = 280, sq = 1, favor = 180, favorRep = 6, r = { { 13463, 3 }, { 8838, 1 }, { 18256, 1 } }, out = { 250949, 1 }, oq = 1 },
    [1251748] = { name = "Potion of Venomous Blood", t = { 1, 280, 282, 285 }, scroll = 250994, train = 275, sq = 1, favor = 180, favorRep = 6, r = { { 8846, 3 }, { 13466, 2 }, { 8925, 1 } }, out = { 250950, 1 }, oq = 1 },
    [1251749] = { name = "Caustic Smog Potion", t = { 1, 270, 272, 275 }, scroll = 250995, train = 265, sq = 1, favor = 180, favorRep = 6, r = { { 8845, 2 }, { 3369, 2 }, { 8925, 1 } }, out = { 250951, 1 }, oq = 1 },
    [1251751] = { name = "Dragonfire Potion", t = { 1, 250, 252, 255 }, scroll = 250997, train = 245, sq = 1, favor = 120, favorRep = 5, r = { { 13465, 2 }, { 4625, 2 }, { 8925, 1 } }, out = { 250953, 1 }, oq = 1 },
    [1251752] = { name = "Potion of Elemental Purging", t = { 1, 285, 287, 290 }, scroll = 250998, train = 280, sq = 1, favor = 180, favorRep = 6, r = { { 4625, 2 }, { 3819, 2 }, { 8925, 1 } }, out = { 250954, 1 }, oq = 1 },
    [1251753] = { name = "Potion of Beast Slaying", t = { 1, 285, 287, 290 }, scroll = 250999, train = 280, sq = 1, r = { { 8846, 2 }, { 13466, 2 }, { 18256, 1 } }, out = { 250955, 1 }, oq = 1 },
    [1263005] = { name = "Fermenter", t = { 1, 140, 142, 145 }, scroll = 273085, train = 140, sq = 2, r = { { 3372, 1 }, { 3356, 1 }, { 2452, 1 } }, out = { 279970, 1 }, oq = 1 },
    [1293559] = { name = "Flask of Natural Accuracy", t = { 1, 320, 325, 330 }, scroll = 274277, train = 300, sq = 3, r = { { 248822, 1 }, { 248821, 12 }, { 13464, 9 }, { 18256, 1 } }, out = { 274273, 1 }, oq = 2 },
    [1293560] = { name = "Flask of Natural Aggression", t = { 1, 320, 325, 330 }, scroll = 274278, train = 300, sq = 3, r = { { 248822, 1 }, { 248821, 18 }, { 13465, 6 }, { 18256, 1 } }, out = { 274274, 1 }, oq = 2 },
    [1293561] = { name = "Flask of Natural Precision", t = { 1, 320, 325, 330 }, scroll = 274279, train = 300, sq = 3, r = { { 248822, 1 }, { 248823, 12 }, { 13463, 9 }, { 18256, 1 } }, out = { 274275, 1 }, oq = 2 },
    [1293562] = { name = "Flask of Natural Swiftness", t = { 1, 320, 325, 330 }, scroll = 274280, train = 300, sq = 3, r = { { 248822, 1 }, { 248823, 18 }, { 13467, 6 }, { 18256, 1 } }, out = { 274276, 1 }, oq = 2 },
    [1317279] = { name = "Transmute: Legionite", t = { 1, 275, 282, 290 }, scroll = 284871, train = 275, sq = 1, r = { { 251291, 1 }, { 248819, 1 } }, tool = 12, out = { 251290, 1 }, oq = 2 },
    [2332] = { name = "Minor Rejuvenation Potion", t = { 40, 70, 90, 110 }, fee = 150, train = 40, r = { { 785, 2 }, { 2447, 1 }, { 3371, 1 } }, out = { 2456, 1 }, oq = 1 },
    [2334] = { name = "Elixir of Minor Fortitude", t = { 50, 80, 100, 120 }, fee = 250, train = 50, r = { { 2449, 2 }, { 2447, 1 }, { 3371, 1 } }, out = { 2458, 1 }, oq = 1 },
    [2335] = { name = "Swiftness Potion", t = { 60, 90, 110, 130 }, scroll = 2555, train = 60, sq = 2, r = { { 2452, 1 }, { 2450, 1 }, { 3371, 1 } }, out = { 2459, 1 }, oq = 1 },
  },
}

-- Herramientas: [categoría] = { objeto, máscara } (un bastón superior cubre a los inferiores)
ES.Data.Tools = ES.Data.Tools or {}
ES.Data.Tools[12] = { item = 9149, mask = 1, family = "stone" }
ES.Data.Tools[14] = { item = 6219, mask = 1, family = "spanner" }
ES.Data.Tools[15] = { item = 10498, mask = 2, family = "adjustor" }
ES.Data.Tools[162] = { item = 5956, mask = 4, family = "hammer" }
ES.Data.Tools[373] = { item = 6218, mask = 1, family = "rod" }
ES.Data.Tools[374] = { item = 6339, mask = 3, family = "rod" }
ES.Data.Tools[375] = { item = 11130, mask = 7, family = "rod" }
ES.Data.Tools[376] = { item = 11145, mask = 15, family = "rod" }
ES.Data.Tools[377] = { item = 16207, mask = 31, family = "rod" }

ES.Data.VendorPrices = ES.Data.VendorPrices or {}
ES.Data.SellPrices = ES.Data.SellPrices or {}
ES.Data.VendorPrices[3371] = 4
ES.Data.VendorPrices[3372] = 40
ES.Data.VendorPrices[4342] = 2500
ES.Data.VendorPrices[8925] = 500
ES.Data.VendorPrices[18256] = 6000
ES.Data.SellPrices[730] = 16
ES.Data.SellPrices[765] = 10
ES.Data.SellPrices[785] = 20
ES.Data.SellPrices[1288] = 185
ES.Data.SellPrices[2447] = 10
ES.Data.SellPrices[2449] = 20
ES.Data.SellPrices[2450] = 25
ES.Data.SellPrices[2452] = 15
ES.Data.SellPrices[2453] = 25
ES.Data.SellPrices[2454] = 20
ES.Data.SellPrices[2455] = 10
ES.Data.SellPrices[2456] = 15
ES.Data.SellPrices[2457] = 15
ES.Data.SellPrices[2458] = 15
ES.Data.SellPrices[2459] = 25
ES.Data.SellPrices[3355] = 50
ES.Data.SellPrices[3356] = 30
ES.Data.SellPrices[3357] = 75
ES.Data.SellPrices[3358] = 175
ES.Data.SellPrices[3369] = 25
ES.Data.SellPrices[3371] = 1
ES.Data.SellPrices[3372] = 10
ES.Data.SellPrices[3382] = 10
ES.Data.SellPrices[3383] = 100
ES.Data.SellPrices[3384] = 20
ES.Data.SellPrices[3385] = 30
ES.Data.SellPrices[3386] = 35
ES.Data.SellPrices[3387] = 30
ES.Data.SellPrices[3388] = 40
ES.Data.SellPrices[3389] = 40
ES.Data.SellPrices[3390] = 35
ES.Data.SellPrices[3391] = 20
ES.Data.SellPrices[3575] = 200
ES.Data.SellPrices[3577] = 600
ES.Data.SellPrices[3818] = 125
ES.Data.SellPrices[3819] = 100
ES.Data.SellPrices[3820] = 100
ES.Data.SellPrices[3821] = 150
ES.Data.SellPrices[3823] = 100
ES.Data.SellPrices[3824] = 150
ES.Data.SellPrices[3825] = 110
ES.Data.SellPrices[3826] = 105
ES.Data.SellPrices[3827] = 120
ES.Data.SellPrices[3828] = 150
ES.Data.SellPrices[3829] = 150
ES.Data.SellPrices[3858] = 250
ES.Data.SellPrices[3860] = 400
ES.Data.SellPrices[4342] = 625
ES.Data.SellPrices[4402] = 250
ES.Data.SellPrices[4596] = 25
ES.Data.SellPrices[4623] = 375
ES.Data.SellPrices[4625] = 250
ES.Data.SellPrices[5631] = 30
ES.Data.SellPrices[5633] = 150
ES.Data.SellPrices[5634] = 75
ES.Data.SellPrices[5635] = 45
ES.Data.SellPrices[5637] = 75
ES.Data.SellPrices[5996] = 95
ES.Data.SellPrices[5997] = 5
ES.Data.SellPrices[6037] = 1250
ES.Data.SellPrices[6048] = 100
ES.Data.SellPrices[6049] = 170
ES.Data.SellPrices[6050] = 300
ES.Data.SellPrices[6051] = 62
ES.Data.SellPrices[6052] = 300
ES.Data.SellPrices[6149] = 120
ES.Data.SellPrices[6358] = 4
ES.Data.SellPrices[6359] = 5
ES.Data.SellPrices[6370] = 10
ES.Data.SellPrices[6371] = 12
ES.Data.SellPrices[6372] = 35
ES.Data.SellPrices[6373] = 35
ES.Data.SellPrices[6522] = 4
ES.Data.SellPrices[6662] = 95
ES.Data.SellPrices[7067] = 400
ES.Data.SellPrices[7068] = 400
ES.Data.SellPrices[7069] = 400
ES.Data.SellPrices[7070] = 400
ES.Data.SellPrices[7076] = 400
ES.Data.SellPrices[7077] = 400
ES.Data.SellPrices[7078] = 400
ES.Data.SellPrices[7080] = 400
ES.Data.SellPrices[7082] = 400
ES.Data.SellPrices[7972] = 400
ES.Data.SellPrices[8153] = 5
ES.Data.SellPrices[8827] = 125
ES.Data.SellPrices[8831] = 300
ES.Data.SellPrices[8836] = 95
ES.Data.SellPrices[8838] = 60
ES.Data.SellPrices[8839] = 375
ES.Data.SellPrices[8845] = 375
ES.Data.SellPrices[8846] = 250
ES.Data.SellPrices[8925] = 125
ES.Data.SellPrices[8949] = 200
ES.Data.SellPrices[8951] = 200
ES.Data.SellPrices[8956] = 200
ES.Data.SellPrices[9030] = 200
ES.Data.SellPrices[9036] = 20
ES.Data.SellPrices[9061] = 250
ES.Data.SellPrices[9088] = 250
ES.Data.SellPrices[9144] = 250
ES.Data.SellPrices[9149] = 250
ES.Data.SellPrices[9154] = 300
ES.Data.SellPrices[9155] = 400
ES.Data.SellPrices[9172] = 500
ES.Data.SellPrices[9179] = 1000
ES.Data.SellPrices[9187] = 600
ES.Data.SellPrices[9197] = 600
ES.Data.SellPrices[9206] = 700
ES.Data.SellPrices[9210] = 750
ES.Data.SellPrices[9224] = 700
ES.Data.SellPrices[9233] = 500
ES.Data.SellPrices[9260] = 400
ES.Data.SellPrices[9262] = 1000
ES.Data.SellPrices[9264] = 35
ES.Data.SellPrices[10286] = 400
ES.Data.SellPrices[10592] = 150
ES.Data.SellPrices[10620] = 250
ES.Data.SellPrices[11083] = 1
ES.Data.SellPrices[11176] = 1
ES.Data.SellPrices[12190] = 250
ES.Data.SellPrices[12359] = 600
ES.Data.SellPrices[12360] = 5000
ES.Data.SellPrices[12363] = 2000
ES.Data.SellPrices[12803] = 500
ES.Data.SellPrices[12804] = 2000
ES.Data.SellPrices[12808] = 1000
ES.Data.SellPrices[13422] = 10
ES.Data.SellPrices[13423] = 125
ES.Data.SellPrices[13442] = 500
ES.Data.SellPrices[13443] = 400
ES.Data.SellPrices[13444] = 1500
ES.Data.SellPrices[13445] = 500
ES.Data.SellPrices[13447] = 1250
ES.Data.SellPrices[13452] = 1250
ES.Data.SellPrices[13453] = 1250
ES.Data.SellPrices[13454] = 750
ES.Data.SellPrices[13455] = 750
ES.Data.SellPrices[13456] = 750
ES.Data.SellPrices[13457] = 750
ES.Data.SellPrices[13458] = 750
ES.Data.SellPrices[13459] = 100
ES.Data.SellPrices[13460] = 750
ES.Data.SellPrices[13461] = 750
ES.Data.SellPrices[13462] = 750
ES.Data.SellPrices[13463] = 100
ES.Data.SellPrices[13464] = 100
ES.Data.SellPrices[13465] = 150
ES.Data.SellPrices[13466] = 250
ES.Data.SellPrices[13467] = 250
ES.Data.SellPrices[13468] = 1000
ES.Data.SellPrices[13503] = 25000
ES.Data.SellPrices[13506] = 5000
ES.Data.SellPrices[13510] = 5000
ES.Data.SellPrices[13511] = 5000
ES.Data.SellPrices[13512] = 5000
ES.Data.SellPrices[13513] = 5000
ES.Data.SellPrices[15410] = 5000
ES.Data.SellPrices[16203] = 1
ES.Data.SellPrices[17708] = 35
ES.Data.SellPrices[17967] = 5000
ES.Data.SellPrices[18253] = 15
ES.Data.SellPrices[18256] = 1500
ES.Data.SellPrices[18294] = 250
ES.Data.SellPrices[19943] = 2000
ES.Data.SellPrices[20002] = 1000
ES.Data.SellPrices[20004] = 1000
ES.Data.SellPrices[20007] = 1000
ES.Data.SellPrices[20008] = 600
ES.Data.SellPrices[21546] = 35
ES.Data.SellPrices[210708] = 40
ES.Data.SellPrices[215430] = 250
ES.Data.SellPrices[234012] = 15
ES.Data.SellPrices[241650] = 25
ES.Data.SellPrices[246948] = 200
ES.Data.SellPrices[247239] = 25
ES.Data.SellPrices[247240] = 75
ES.Data.SellPrices[247241] = 125
ES.Data.SellPrices[247242] = 250
ES.Data.SellPrices[247754] = 25
ES.Data.SellPrices[247755] = 25
ES.Data.SellPrices[248819] = 3000
ES.Data.SellPrices[248821] = 225
ES.Data.SellPrices[248822] = 1500
ES.Data.SellPrices[248823] = 150
ES.Data.SellPrices[249274] = 250
ES.Data.SellPrices[249391] = 100
ES.Data.SellPrices[249399] = 30
ES.Data.SellPrices[249409] = 75
ES.Data.SellPrices[249410] = 125
ES.Data.SellPrices[249424] = 95
ES.Data.SellPrices[249430] = 250
ES.Data.SellPrices[249431] = 375
ES.Data.SellPrices[250327] = 100
ES.Data.SellPrices[250328] = 125
ES.Data.SellPrices[250329] = 125
ES.Data.SellPrices[250330] = 25
ES.Data.SellPrices[250331] = 50
ES.Data.SellPrices[250332] = 75
ES.Data.SellPrices[250333] = 100
ES.Data.SellPrices[250334] = 75
ES.Data.SellPrices[250335] = 100
ES.Data.SellPrices[250336] = 125
ES.Data.SellPrices[250337] = 125
ES.Data.SellPrices[250338] = 125
ES.Data.SellPrices[250339] = 25
ES.Data.SellPrices[250340] = 50
ES.Data.SellPrices[250341] = 100
ES.Data.SellPrices[250342] = 50
ES.Data.SellPrices[250343] = 125
ES.Data.SellPrices[250344] = 25
ES.Data.SellPrices[250345] = 50
ES.Data.SellPrices[250346] = 75
ES.Data.SellPrices[250347] = 100
ES.Data.SellPrices[250348] = 125
ES.Data.SellPrices[250349] = 75
ES.Data.SellPrices[250350] = 125
ES.Data.SellPrices[250351] = 125
ES.Data.SellPrices[250353] = 50
ES.Data.SellPrices[250354] = 75
ES.Data.SellPrices[250932] = 1
ES.Data.SellPrices[250933] = 25
ES.Data.SellPrices[250934] = 25
ES.Data.SellPrices[250935] = 1
ES.Data.SellPrices[250936] = 1
ES.Data.SellPrices[250937] = 1
ES.Data.SellPrices[250938] = 1
ES.Data.SellPrices[250939] = 1
ES.Data.SellPrices[250940] = 1
ES.Data.SellPrices[250941] = 1
ES.Data.SellPrices[250942] = 1
ES.Data.SellPrices[250943] = 1
ES.Data.SellPrices[250944] = 1
ES.Data.SellPrices[250945] = 1
ES.Data.SellPrices[250946] = 1
ES.Data.SellPrices[250947] = 1
ES.Data.SellPrices[250948] = 1
ES.Data.SellPrices[250949] = 1
ES.Data.SellPrices[250950] = 1
ES.Data.SellPrices[250951] = 1
ES.Data.SellPrices[250953] = 1
ES.Data.SellPrices[250954] = 1
ES.Data.SellPrices[250955] = 1
ES.Data.SellPrices[251290] = 5000
ES.Data.SellPrices[251291] = 1500
ES.Data.SellPrices[274273] = 5000
ES.Data.SellPrices[274274] = 5000
ES.Data.SellPrices[274275] = 5000
ES.Data.SellPrices[274276] = 5000

-- Nombre de cada objeto (inglés, del cliente): se muestra mientras el juego no lo ha cargado
ES.Data.ItemNames = ES.Data.ItemNames or {}
ES.Data.ItemNames[730] = "Murloc Eye"
ES.Data.ItemNames[765] = "Silverleaf"
ES.Data.ItemNames[785] = "Mageroyal"
ES.Data.ItemNames[1288] = "Large Venom Sac"
ES.Data.ItemNames[2447] = "Peacebloom"
ES.Data.ItemNames[2449] = "Earthroot"
ES.Data.ItemNames[2450] = "Briarthorn"
ES.Data.ItemNames[2452] = "Swiftthistle"
ES.Data.ItemNames[2453] = "Bruiseweed"
ES.Data.ItemNames[2454] = "Elixir of Minor Strength"
ES.Data.ItemNames[2455] = "Minor Mana Potion"
ES.Data.ItemNames[2456] = "Minor Rejuvenation Potion"
ES.Data.ItemNames[2457] = "Elixir of Minor Agility"
ES.Data.ItemNames[2458] = "Elixir of Minor Fortitude"
ES.Data.ItemNames[2459] = "Swiftness Potion"
ES.Data.ItemNames[3355] = "Wild Steelbloom"
ES.Data.ItemNames[3356] = "Kingsblood"
ES.Data.ItemNames[3357] = "Liferoot"
ES.Data.ItemNames[3358] = "Khadgar's Whisker"
ES.Data.ItemNames[3369] = "Grave Moss"
ES.Data.ItemNames[3371] = "Empty Vial"
ES.Data.ItemNames[3372] = "Leaded Vial"
ES.Data.ItemNames[3382] = "Minor Troll's Blood Elixir"
ES.Data.ItemNames[3383] = "Elixir of Wisdom"
ES.Data.ItemNames[3384] = "Minor Magic Resistance Potion"
ES.Data.ItemNames[3385] = "Lesser Mana Potion"
ES.Data.ItemNames[3386] = "Potion of Poison Cleansing"
ES.Data.ItemNames[3387] = "Limited Invulnerability Potion"
ES.Data.ItemNames[3388] = "Lesser Troll's Blood Elixir"
ES.Data.ItemNames[3389] = "Elixir of Lesser Defense"
ES.Data.ItemNames[3390] = "Elixir of Lesser Agility"
ES.Data.ItemNames[3391] = "Elixir of Ogre Strength"
ES.Data.ItemNames[3575] = "Iron Bar"
ES.Data.ItemNames[3577] = "Gold Bar"
ES.Data.ItemNames[3818] = "Fadeleaf"
ES.Data.ItemNames[3819] = "Wintersbite"
ES.Data.ItemNames[3820] = "Stranglekelp"
ES.Data.ItemNames[3821] = "Goldthorn"
ES.Data.ItemNames[3823] = "Lesser Invisibility Potion"
ES.Data.ItemNames[3824] = "Shadow Oil"
ES.Data.ItemNames[3825] = "Elixir of Lesser Fortitude"
ES.Data.ItemNames[3826] = "Troll's Blood Elixir"
ES.Data.ItemNames[3827] = "Mana Potion"
ES.Data.ItemNames[3828] = "Draught of Detect Lesser Invisibility"
ES.Data.ItemNames[3829] = "Frost Oil"
ES.Data.ItemNames[3858] = "Mithril Ore"
ES.Data.ItemNames[3860] = "Mithril Bar"
ES.Data.ItemNames[4342] = "Purple Dye"
ES.Data.ItemNames[4402] = "Small Flame Sac"
ES.Data.ItemNames[4596] = "Minor Discolored Healing Potion"
ES.Data.ItemNames[4623] = "Lesser Stoneshield Potion"
ES.Data.ItemNames[4625] = "Firebloom"
ES.Data.ItemNames[5631] = "Rage Potion"
ES.Data.ItemNames[5633] = "Great Rage Potion"
ES.Data.ItemNames[5634] = "Free Action Potion"
ES.Data.ItemNames[5635] = "Sharp Claw"
ES.Data.ItemNames[5637] = "Large Fang"
ES.Data.ItemNames[5996] = "Draught of Water Breathing"
ES.Data.ItemNames[5997] = "Elixir of Minor Defense"
ES.Data.ItemNames[6037] = "Truesilver Bar"
ES.Data.ItemNames[6048] = "Shadow Protection Potion"
ES.Data.ItemNames[6049] = "Fire Protection Potion"
ES.Data.ItemNames[6050] = "Frost Protection Potion"
ES.Data.ItemNames[6051] = "Holy Protection Potion"
ES.Data.ItemNames[6052] = "Nature Protection Potion"
ES.Data.ItemNames[6149] = "Greater Mana Potion"
ES.Data.ItemNames[6358] = "Oily Blackmouth"
ES.Data.ItemNames[6359] = "Firefin Snapper"
ES.Data.ItemNames[6370] = "Blackmouth Oil"
ES.Data.ItemNames[6371] = "Fire Oil"
ES.Data.ItemNames[6372] = "Swim Speed Potion"
ES.Data.ItemNames[6373] = "Elixir of Fire Power"
ES.Data.ItemNames[6522] = "Deviate Fish"
ES.Data.ItemNames[6662] = "Elixir of Giant Growth"
ES.Data.ItemNames[7067] = "Elemental Earth"
ES.Data.ItemNames[7068] = "Elemental Fire"
ES.Data.ItemNames[7069] = "Elemental Air"
ES.Data.ItemNames[7070] = "Elemental Water"
ES.Data.ItemNames[7076] = "Essence of Earth"
ES.Data.ItemNames[7077] = "Heart of Fire"
ES.Data.ItemNames[7078] = "Essence of Fire"
ES.Data.ItemNames[7080] = "Essence of Water"
ES.Data.ItemNames[7082] = "Essence of Air"
ES.Data.ItemNames[7972] = "Ichor of Undeath"
ES.Data.ItemNames[8153] = "Wildvine"
ES.Data.ItemNames[8827] = "Draught of Water Walking"
ES.Data.ItemNames[8831] = "Purple Lotus"
ES.Data.ItemNames[8836] = "Arthas' Tears"
ES.Data.ItemNames[8838] = "Sungrass"
ES.Data.ItemNames[8839] = "Blindweed"
ES.Data.ItemNames[8845] = "Ghost Mushroom"
ES.Data.ItemNames[8846] = "Gromsblood"
ES.Data.ItemNames[8925] = "Crystal Vial"
ES.Data.ItemNames[8949] = "Elixir of Agility"
ES.Data.ItemNames[8951] = "Elixir of Defense"
ES.Data.ItemNames[8956] = "Oil of Immolation"
ES.Data.ItemNames[9030] = "Restorative Potion"
ES.Data.ItemNames[9036] = "Magic Resistance Potion"
ES.Data.ItemNames[9061] = "Goblin Rocket Fuel"
ES.Data.ItemNames[9088] = "Gift of Arthas"
ES.Data.ItemNames[9144] = "Wildvine Potion"
ES.Data.ItemNames[9149] = "Philosopher's Stone"
ES.Data.ItemNames[9154] = "Draught of Detect Undead"
ES.Data.ItemNames[9155] = "Arcane Elixir"
ES.Data.ItemNames[9172] = "Invisibility Potion"
ES.Data.ItemNames[9179] = "Elixir of Greater Intellect"
ES.Data.ItemNames[9187] = "Elixir of Greater Agility"
ES.Data.ItemNames[9197] = "Draught of Dream Vision"
ES.Data.ItemNames[9206] = "Elixir of Greater Strength"
ES.Data.ItemNames[9210] = "Ghost Dye"
ES.Data.ItemNames[9224] = "Potion of Demon Slaying"
ES.Data.ItemNames[9233] = "Draught of Detect Demon"
ES.Data.ItemNames[9260] = "Volatile Rum"
ES.Data.ItemNames[9262] = "Black Vitriol"
ES.Data.ItemNames[9264] = "Elixir of Shadow Power"
ES.Data.ItemNames[10286] = "Heart of the Wild"
ES.Data.ItemNames[10592] = "Catseye Draught"
ES.Data.ItemNames[10620] = "Thorium Ore"
ES.Data.ItemNames[11083] = "Soul Dust"
ES.Data.ItemNames[11176] = "Dream Dust"
ES.Data.ItemNames[12190] = "Dreamless Sleep Potion"
ES.Data.ItemNames[12359] = "Thorium Bar"
ES.Data.ItemNames[12360] = "Arcanite Bar"
ES.Data.ItemNames[12363] = "Arcane Crystal"
ES.Data.ItemNames[12803] = "Living Essence"
ES.Data.ItemNames[12804] = "Powerful Mojo"
ES.Data.ItemNames[12808] = "Essence of Undeath"
ES.Data.ItemNames[12938] = "Blood of Heroes"
ES.Data.ItemNames[13422] = "Stonescale Eel"
ES.Data.ItemNames[13423] = "Stonescale Oil"
ES.Data.ItemNames[13442] = "Mighty Rage Potion"
ES.Data.ItemNames[13443] = "Superior Mana Potion"
ES.Data.ItemNames[13444] = "Major Mana Potion"
ES.Data.ItemNames[13445] = "Elixir of Greater Defense"
ES.Data.ItemNames[13447] = "Elixir of the Sages"
ES.Data.ItemNames[13452] = "Elixir of the Mongoose"
ES.Data.ItemNames[13453] = "Elixir of Brute Force"
ES.Data.ItemNames[13454] = "Greater Arcane Elixir"
ES.Data.ItemNames[13455] = "Greater Stoneshield Potion"
ES.Data.ItemNames[13456] = "Greater Frost Protection Potion"
ES.Data.ItemNames[13457] = "Greater Fire Protection Potion"
ES.Data.ItemNames[13458] = "Greater Nature Protection Potion"
ES.Data.ItemNames[13459] = "Greater Shadow Protection Potion"
ES.Data.ItemNames[13460] = "Greater Holy Protection Potion"
ES.Data.ItemNames[13461] = "Greater Arcane Protection Potion"
ES.Data.ItemNames[13462] = "Purification Potion"
ES.Data.ItemNames[13463] = "Dreamfoil"
ES.Data.ItemNames[13464] = "Golden Sansam"
ES.Data.ItemNames[13465] = "Mountain Silversage"
ES.Data.ItemNames[13466] = "Plaguebloom"
ES.Data.ItemNames[13467] = "Icecap"
ES.Data.ItemNames[13468] = "Black Lotus"
ES.Data.ItemNames[13503] = "Alchemist's Stone"
ES.Data.ItemNames[13506] = "Flask of Petrification"
ES.Data.ItemNames[13510] = "Flask of the Titans"
ES.Data.ItemNames[13511] = "Flask of Distilled Wisdom"
ES.Data.ItemNames[13512] = "Flask of Supreme Power"
ES.Data.ItemNames[13513] = "Flask of Chromatic Resistance"
ES.Data.ItemNames[15410] = "Scale of Onyxia"
ES.Data.ItemNames[16203] = "Greater Eternal Essence"
ES.Data.ItemNames[17708] = "Elixir of Frost Power"
ES.Data.ItemNames[17967] = "Refined Scale of Onyxia"
ES.Data.ItemNames[18253] = "Major Rejuvenation Potion"
ES.Data.ItemNames[18256] = "Imbued Vial"
ES.Data.ItemNames[18294] = "Draught of Greater Water Breathing"
ES.Data.ItemNames[19931] = "Gurubashi Mojo Madness"
ES.Data.ItemNames[19943] = "Massive Mojo"
ES.Data.ItemNames[20002] = "Greater Dreamless Sleep Potion"
ES.Data.ItemNames[20004] = "Major Troll's Blood Elixir"
ES.Data.ItemNames[20007] = "Mageblood Elixir"
ES.Data.ItemNames[20008] = "Living Action Potion"
ES.Data.ItemNames[21546] = "Elixir of Holy Power"
ES.Data.ItemNames[210708] = "Elixir of Coalesced Regret"
ES.Data.ItemNames[213371] = "Crate of Tainted Gniodine Solution"
ES.Data.ItemNames[215430] = "Gnomeregan Fallout"
ES.Data.ItemNames[234012] = "Hive Thistle"
ES.Data.ItemNames[241650] = "Major Discolored Healing Potion"
ES.Data.ItemNames[246948] = "Distilled Firewater"
ES.Data.ItemNames[247239] = "Lesser Discolored Healing Potion"
ES.Data.ItemNames[247240] = "Discolored Healing Potion"
ES.Data.ItemNames[247241] = "Greater Discolored Healing Potion"
ES.Data.ItemNames[247242] = "Superior Discolored Healing Potion"
ES.Data.ItemNames[247754] = "Minor Arcane Elixir"
ES.Data.ItemNames[247755] = "Elixir of Minor Force"
ES.Data.ItemNames[248819] = "Fel Crystal"
ES.Data.ItemNames[248821] = "Demonsage"
ES.Data.ItemNames[248822] = "Death Lotus"
ES.Data.ItemNames[248823] = "Marefoil"
ES.Data.ItemNames[249274] = "Stranglevine"
ES.Data.ItemNames[249391] = "Pyrite"
ES.Data.ItemNames[249399] = "Frilled Lichen"
ES.Data.ItemNames[249409] = "Cerulean Dye"
ES.Data.ItemNames[249410] = "Sulfuric Acid"
ES.Data.ItemNames[249424] = "Rosecap"
ES.Data.ItemNames[249430] = "Magenta Dye"
ES.Data.ItemNames[249431] = "Viridian Dye"
ES.Data.ItemNames[250327] = "Potion of Predatory Senses"
ES.Data.ItemNames[250328] = "Elixir of Cunning"
ES.Data.ItemNames[250329] = "Elixir of the Phalanx"
ES.Data.ItemNames[250330] = "Minor Cleric's Elixir"
ES.Data.ItemNames[250331] = "Lesser Cleric's Elixir"
ES.Data.ItemNames[250332] = "Cleric's Elixir"
ES.Data.ItemNames[250333] = "Greater Cleric's Elixir"
ES.Data.ItemNames[250334] = "Elixir of Fortitude"
ES.Data.ItemNames[250335] = "Elixir of Greater Fortitude"
ES.Data.ItemNames[250336] = "Elixir of Wicked Regeneration"
ES.Data.ItemNames[250337] = "Elixir of the Owl"
ES.Data.ItemNames[250338] = "Elixir of Sages"
ES.Data.ItemNames[250339] = "Minor Mageblood Elixir"
ES.Data.ItemNames[250340] = "Lesser Mageblood Elixir"
ES.Data.ItemNames[250341] = "Greater Mageblood Elixir"
ES.Data.ItemNames[250342] = "Lesser Arcane Elixir"
ES.Data.ItemNames[250343] = "Elixir of Nature Power"
ES.Data.ItemNames[250344] = "Elixir of Minor Spirit"
ES.Data.ItemNames[250345] = "Elixir of Lesser Spirit"
ES.Data.ItemNames[250346] = "Elixir of Spirit"
ES.Data.ItemNames[250347] = "Elixir of Greater Spirit"
ES.Data.ItemNames[250348] = "Elixir of the Whale"
ES.Data.ItemNames[250349] = "Elixir of Strength"
ES.Data.ItemNames[250350] = "Elixir of Ferocity"
ES.Data.ItemNames[250351] = "Elixir of the Grizzly"
ES.Data.ItemNames[250353] = "Elixir of Lesser Intellect"
ES.Data.ItemNames[250354] = "Elixir of Intellect"
ES.Data.ItemNames[250932] = "Minor Spellblasting Potion"
ES.Data.ItemNames[250933] = "Lesser Spellblasting Potion"
ES.Data.ItemNames[250934] = "Spellblasting Potion"
ES.Data.ItemNames[250935] = "Greater Spellblasting Potion"
ES.Data.ItemNames[250936] = "Superior Spellblasting Potion"
ES.Data.ItemNames[250937] = "Major Spellblasting Potion"
ES.Data.ItemNames[250938] = "Minor Frenzy Potion"
ES.Data.ItemNames[250939] = "Lesser Frenzy Potion"
ES.Data.ItemNames[250940] = "Frenzy Potion"
ES.Data.ItemNames[250941] = "Greater Frenzy Potion"
ES.Data.ItemNames[250942] = "Superior Frenzy Potion"
ES.Data.ItemNames[250943] = "Major Frenzy Potion"
ES.Data.ItemNames[250944] = "Minor Mender's Potion"
ES.Data.ItemNames[250945] = "Lesser Mender's Potion"
ES.Data.ItemNames[250946] = "Mender's Potion"
ES.Data.ItemNames[250947] = "Greater Mender's Potion"
ES.Data.ItemNames[250948] = "Superior Mender's Potion"
ES.Data.ItemNames[250949] = "Major Mender's Potion"
ES.Data.ItemNames[250950] = "Potion of Venomous Blood"
ES.Data.ItemNames[250951] = "Caustic Smog Potion"
ES.Data.ItemNames[250953] = "Dragonfire Potion"
ES.Data.ItemNames[250954] = "Potion of Elemental Purging"
ES.Data.ItemNames[250955] = "Potion of Beast Slaying"
ES.Data.ItemNames[251290] = "Legionite Bar"
ES.Data.ItemNames[251291] = "Heavy Thorium Bar"
ES.Data.ItemNames[274273] = "Flask of Natural Accuracy"
ES.Data.ItemNames[274274] = "Flask of Natural Aggression"
ES.Data.ItemNames[274275] = "Flask of Natural Precision"
ES.Data.ItemNames[274276] = "Flask of Natural Swiftness"
ES.Data.ItemNames[279956] = "Mana Well"
ES.Data.ItemNames[279970] = "Fermenter"

-- Material -> profesión de recolección que lo consigue (393 Desuello, 182 Herboristería, 186 Minería).
-- Sin uso por ahora: reservado para la vía "Vender en bruto" de Ganar dinero (docs/PLAN.md, G1).
ES.Data.GatheredBy = ES.Data.GatheredBy or {}
ES.Data.GatheredBy[765] = 182
ES.Data.GatheredBy[785] = 182
ES.Data.GatheredBy[2447] = 182
ES.Data.GatheredBy[2449] = 182
ES.Data.GatheredBy[2450] = 182
ES.Data.GatheredBy[2452] = 182
ES.Data.GatheredBy[2453] = 182
ES.Data.GatheredBy[3355] = 182
ES.Data.GatheredBy[3356] = 182
ES.Data.GatheredBy[3357] = 182
ES.Data.GatheredBy[3358] = 182
ES.Data.GatheredBy[3369] = 182
ES.Data.GatheredBy[3575] = 186
ES.Data.GatheredBy[3818] = 182
ES.Data.GatheredBy[3819] = 182
ES.Data.GatheredBy[3820] = 182
ES.Data.GatheredBy[3821] = 182
ES.Data.GatheredBy[3858] = 186
ES.Data.GatheredBy[3860] = 186
ES.Data.GatheredBy[4625] = 182
ES.Data.GatheredBy[8153] = 182
ES.Data.GatheredBy[8831] = 182
ES.Data.GatheredBy[8836] = 182
ES.Data.GatheredBy[8838] = 182
ES.Data.GatheredBy[8839] = 182
ES.Data.GatheredBy[8845] = 182
ES.Data.GatheredBy[8846] = 182
ES.Data.GatheredBy[10620] = 186
ES.Data.GatheredBy[12359] = 186
ES.Data.GatheredBy[13463] = 182
ES.Data.GatheredBy[13464] = 182
ES.Data.GatheredBy[13465] = 182
ES.Data.GatheredBy[13466] = 182
ES.Data.GatheredBy[13467] = 182
ES.Data.GatheredBy[13468] = 182
ES.Data.GatheredBy[15410] = 393
ES.Data.GatheredBy[234012] = 182
ES.Data.GatheredBy[248821] = 182
ES.Data.GatheredBy[248822] = 182
ES.Data.GatheredBy[248823] = 182
ES.Data.GatheredBy[249274] = 182
ES.Data.GatheredBy[249391] = 186
ES.Data.GatheredBy[249399] = 182
ES.Data.GatheredBy[249424] = 182
ES.Data.GatheredBy[251291] = 186

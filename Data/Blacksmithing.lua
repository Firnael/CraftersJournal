-- Generado por tools/gen_profession.py (Blacksmithing). No editar a mano.
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
ES.Data.Blacksmithing = {
  skillLine = 164,
  ranks = { -- { tope, precio, habilidad requerida, nivel de personaje }
    { 150, 450, 50, 10 },
    { 225, 4500, 125, 20 },
    { 300, 50000, 200, 35 },
  },
  -- { PNJ instructor, rangos que enseña: 1 aprendiz (75), 2 oficial (150), 4 experto (225), 8 artesano (300) }
  trainers = { { 514, 1 }, { 957, 1 }, { 1241, 1 }, { 1383, 2 }, { 2836, 8 }, { 2998, 2 }, { 3136, 2 }, { 3174, 1 }, { 3355, 4 }, { 3478, 2 }, { 3557, 1 }, { 4258, 4 }, { 4596, 2 }, { 4605, 1 }, { 5511, 2 }, { 6299, 1 }, { 10266, 1 }, { 10276, 2 }, { 10277, 1 }, { 10278, 1 }, { 251913, 3 }, { 252479, 3 }, { 256658, 1 }, { 259250, 1 }, { 276067, 3 } },
  recipes = {
    [2660] = { name = "Rough Sharpening Stone", t = { 1, 15, 35, 55 }, basic = true, r = { { 2835, 1 } }, out = { 2862, 1 }, oq = 1 },
    [2661] = { name = "Copper Chain Belt", t = { 1, 70, 90, 110 }, fee = 100, train = 30, r = { { 2840, 6 } }, tool = 162, out = { 2851, 1 }, oq = 2 },
    [2663] = { name = "Copper Bracers", t = { 1, 20, 40, 60 }, basic = true, r = { { 2840, 2 } }, tool = 162, out = { 2853, 1 }, oq = 1 },
    [2664] = { name = "Runed Copper Bracers", t = { 1, 90, 102, 115 }, fee = 500, train = 65, r = { { 2840, 10 }, { 3470, 3 } }, tool = 162, out = { 2854, 1 }, oq = 2 },
    [2671] = { name = "Rough Bronze Bracers", t = { 1, 115, 130, 145 }, scroll = 5577, train = 105, sq = 1, r = { { 2841, 4 } }, tool = 162, out = { 2867, 1 }, oq = 2 },
    [2673] = { name = "Silvered Bronze Breastplate", t = { 1, 135, 150, 165 }, scroll = 5578, train = 105, sq = 2, r = { { 2841, 10 }, { 2842, 2 }, { 3478, 2 }, { 1705, 1 } }, tool = 162, out = { 2869, 1 }, oq = 2 },
    [2737] = { name = "Copper Mace", t = { 1, 55, 75, 95 }, fee = 50, train = 15, r = { { 2840, 6 }, { 2880, 1 }, { 2589, 2 } }, tool = 162, out = { 2844, 1 }, oq = 1 },
    [2738] = { name = "Copper Axe", t = { 1, 60, 80, 100 }, fee = 50, train = 20, r = { { 2840, 6 }, { 2880, 1 }, { 2589, 2 } }, tool = 162, out = { 2845, 1 }, oq = 1 },
    [3115] = { name = "Rough Weightstone", t = { 1, 15, 35, 55 }, basic = true, r = { { 2835, 1 } }, out = { 3239, 1 }, oq = 1 },
    [3116] = { name = "Coarse Weightstone", t = { 1, 40, 47, 55 }, fee = 100, train = 40, r = { { 2836, 1 } }, out = { 3240, 1 }, oq = 1 },
    [3117] = { name = "Heavy Weightstone", t = { 1, 100, 107, 115 }, fee = 1000, train = 100, r = { { 2838, 1 } }, out = { 3241, 1 }, oq = 1 },
    [3292] = { name = "Heavy Copper Broadsword", t = { 1, 110, 130, 150 }, fee = 500, train = 70, r = { { 2840, 14 }, { 2880, 2 }, { 818, 2 }, { 2319, 2 } }, tool = 162, out = { 3487, 1 }, oq = 2 },
    [3293] = { name = "Copper Battle Axe", t = { 1, 70, 90, 110 }, fee = 250, train = 30, r = { { 2840, 12 }, { 2880, 2 }, { 774, 2 }, { 3470, 2 }, { 2318, 2 } }, tool = 162, out = { 3488, 1 }, oq = 2 },
    [3294] = { name = "Thick War Axe", t = { 1, 85, 105, 125 }, fee = 500, train = 45, r = { { 2840, 10 }, { 2880, 2 }, { 2842, 2 }, { 3470, 2 }, { 2318, 2 } }, tool = 162, out = { 3489, 1 }, oq = 2 },
    [3295] = { name = "Deadly Bronze Poniard", t = { 1, 130, 145, 160 }, scroll = 2883, train = 100, sq = 2, r = { { 2841, 4 }, { 3466, 1 }, { 2459, 1 }, { 1210, 2 }, { 3478, 2 }, { 2319, 2 } }, tool = 162, out = { 3490, 1 }, oq = 2 },
    [3296] = { name = "Heavy Bronze Mace", t = { 1, 135, 150, 165 }, fee = 1000, train = 105, r = { { 2841, 8 }, { 3466, 1 }, { 1206, 1 }, { 1210, 1 }, { 3478, 2 }, { 2319, 2 } }, tool = 162, out = { 3491, 1 }, oq = 2 },
    [3297] = { name = "Mighty Iron Hammer", t = { 1, 150, 165, 180 }, scroll = 3608, train = 120, sq = 2, r = { { 3575, 6 }, { 3466, 2 }, { 3391, 1 }, { 1705, 2 }, { 3478, 2 }, { 2319, 2 } }, tool = 162, out = { 3492, 1 }, oq = 2 },
    [3319] = { name = "Copper Chain Boots", t = { 1, 60, 80, 100 }, fee = 50, train = 20, r = { { 2840, 8 } }, tool = 162, out = { 3469, 1 }, oq = 2 },
    [3320] = { name = "Rough Grinding Stone", t = { 1, 45, 65, 85 }, fee = 100, train = 25, r = { { 2835, 2 } }, out = { 3470, 1 }, oq = 1 },
    [3321] = { name = "Copper Chain Vest", t = { 1, 70, 90, 110 }, scroll = 3609, train = 30, sq = 2, r = { { 2840, 8 }, { 774, 1 }, { 3470, 2 } }, tool = 162, out = { 3471, 1 }, oq = 2 },
    [3323] = { name = "Runed Copper Gauntlets", t = { 1, 75, 95, 115 }, fee = 100, train = 35, r = { { 2840, 8 }, { 3470, 2 } }, tool = 162, out = { 3472, 1 }, oq = 2 },
    [3324] = { name = "Runed Copper Pants", t = { 1, 75, 95, 115 }, fee = 200, train = 35, r = { { 2840, 8 }, { 2320, 3 }, { 3470, 3 } }, tool = 162, out = { 3473, 1 }, oq = 2 },
    [3325] = { name = "Gemmed Copper Gauntlets", t = { 1, 75, 95, 115 }, scroll = 3610, train = 35, sq = 2, r = { { 2840, 8 }, { 818, 1 }, { 774, 1 } }, tool = 162, out = { 3474, 1 }, oq = 2 },
    [3326] = { name = "Coarse Grinding Stone", t = { 1, 50, 62, 75 }, fee = 250, train = 50, r = { { 2836, 2 } }, out = { 3478, 1 }, oq = 1 },
    [3328] = { name = "Rough Bronze Shoulders", t = { 1, 115, 130, 145 }, fee = 500, train = 85, r = { { 2841, 5 }, { 1210, 1 }, { 3478, 1 } }, tool = 162, out = { 3480, 1 }, oq = 2 },
    [3330] = { name = "Silvered Bronze Shoulders", t = { 1, 130, 145, 160 }, scroll = 2882, train = 100, sq = 2, r = { { 2841, 8 }, { 2842, 2 }, { 3478, 2 } }, tool = 162, out = { 3481, 1 }, oq = 2 },
    [3331] = { name = "Silvered Bronze Boots", t = { 1, 135, 150, 165 }, fee = 500, train = 105, r = { { 2841, 6 }, { 2842, 1 }, { 3478, 2 } }, tool = 162, out = { 3482, 1 }, oq = 2 },
    [3333] = { name = "Silvered Bronze Gauntlets", t = { 1, 140, 155, 170 }, fee = 1000, train = 110, r = { { 2841, 8 }, { 2842, 1 }, { 3478, 2 } }, tool = 162, out = { 3483, 1 }, oq = 2 },
    [3334] = { name = "Green Iron Boots", t = { 1, 150, 165, 180 }, scroll = 3611, train = 120, sq = 2, r = { { 3575, 4 }, { 1705, 2 }, { 3478, 2 }, { 2605, 1 } }, tool = 162, out = { 3484, 1 }, oq = 2 },
    [3336] = { name = "Green Iron Gauntlets", t = { 1, 155, 170, 185 }, scroll = 3612, train = 125, sq = 2, r = { { 3575, 4 }, { 5498, 2 }, { 3478, 2 }, { 2605, 1 } }, tool = 162, out = { 3485, 1 }, oq = 2 },
    [3337] = { name = "Heavy Grinding Stone", t = { 1, 100, 112, 125 }, fee = 1000, train = 100, r = { { 2838, 3 } }, out = { 3486, 1 }, oq = 1 },
    [3491] = { name = "Big Bronze Knife", t = { 1, 110, 125, 140 }, fee = 600, train = 80, r = { { 2841, 6 }, { 2880, 4 }, { 3470, 2 }, { 818, 1 }, { 2319, 1 } }, tool = 162, out = { 3848, 1 }, oq = 2 },
    [3492] = { name = "Hardened Iron Shortsword", t = { 1, 160, 172, 185 }, scroll = 12162, train = 135, scrollPrice = 3000, sq = 1, r = { { 3575, 6 }, { 3466, 2 }, { 3486, 1 }, { 1705, 2 }, { 4234, 3 } }, tool = 162, out = { 3849, 1 }, oq = 2 },
    [3493] = { name = "Jade Serpentblade", t = { 1, 175, 187, 200 }, scroll = 3866, train = 150, sq = 2, r = { { 3575, 8 }, { 3466, 2 }, { 3486, 2 }, { 1529, 2 }, { 4234, 3 } }, tool = 162, out = { 3850, 1 }, oq = 2 },
    [3494] = { name = "Solid Iron Maul", t = { 1, 155, 167, 180 }, scroll = 10858, train = 130, scrollPrice = 3000, sq = 1, r = { { 3575, 8 }, { 3466, 2 }, { 3486, 1 }, { 2842, 4 }, { 4234, 2 } }, tool = 162, out = { 3851, 1 }, oq = 2 },
    [3495] = { name = "Golden Iron Destroyer", t = { 1, 170, 182, 195 }, scroll = 3867, train = 145, sq = 2, r = { { 3575, 10 }, { 3577, 4 }, { 1705, 2 }, { 3466, 2 }, { 4234, 2 }, { 3486, 2 } }, tool = 162, out = { 3852, 1 }, oq = 2 },
    [3496] = { name = "Moonsteel Broadsword", t = { 1, 180, 192, 205 }, scroll = 12163, train = 155, scrollPrice = 4400, sq = 1, r = { { 3859, 8 }, { 3466, 2 }, { 3486, 2 }, { 1705, 3 }, { 4234, 3 } }, tool = 162, out = { 3853, 1 }, oq = 2 },
    [3497] = { name = "Frost Tiger Blade", t = { 1, 200, 212, 225 }, scroll = 3868, train = 175, sq = 2, r = { { 3859, 8 }, { 3466, 2 }, { 3486, 2 }, { 1529, 2 }, { 3829, 1 }, { 4234, 4 } }, tool = 162, out = { 3854, 1 }, oq = 2 },
    [3498] = { name = "Massive Iron Axe", t = { 1, 185, 197, 210 }, scroll = 12164, train = 160, scrollPrice = 4400, sq = 1, r = { { 3575, 14 }, { 3466, 2 }, { 3486, 2 }, { 3577, 4 }, { 4234, 2 } }, tool = 162, out = { 3855, 1 }, oq = 2 },
    [3500] = { name = "Shadow Crescent Axe", t = { 1, 200, 212, 225 }, scroll = 3869, train = 175, sq = 2, r = { { 3859, 10 }, { 3466, 2 }, { 3486, 3 }, { 3864, 2 }, { 3824, 1 }, { 4234, 3 } }, tool = 162, out = { 3856, 1 }, oq = 2 },
    [3501] = { name = "Green Iron Bracers", t = { 1, 165, 177, 190 }, fee = 1000, train = 140, tr = { 2836, 3355, 4258 }, r = { { 3575, 6 }, { 2605, 1 } }, tool = 162, out = { 3835, 1 }, oq = 2 },
    [3502] = { name = "Green Iron Helm", t = { 1, 170, 182, 195 }, fee = 1250, train = 145, tr = { 2836, 3355, 4258 }, r = { { 3575, 12 }, { 3864, 1 }, { 2605, 1 } }, tool = 162, out = { 3836, 1 }, oq = 2 },
    [3503] = { name = "Golden Scale Coif", t = { 1, 190, 202, 215 }, scroll = 6047, train = 165, scrollPrice = 4400, sq = 1, r = { { 3859, 8 }, { 3577, 2 }, { 3486, 2 } }, tool = 162, out = { 3837, 1 }, oq = 2 },
    [3504] = { name = "Green Iron Shoulders", t = { 1, 160, 172, 185 }, scroll = 3870, train = 135, sq = 2, r = { { 3575, 7 }, { 3486, 1 }, { 2605, 1 } }, tool = 162, out = { 3840, 1 }, oq = 2 },
    [3505] = { name = "Golden Scale Shoulders", t = { 1, 175, 187, 200 }, scroll = 3871, train = 150, sq = 3, r = { { 3859, 6 }, { 3577, 2 }, { 3486, 1 } }, tool = 162, out = { 3841, 1 }, oq = 2 },
    [3506] = { name = "Green Iron Leggings", t = { 1, 155, 167, 180 }, fee = 5000, train = 130, tr = { 2836, 3355, 4258 }, r = { { 3575, 8 }, { 3486, 1 }, { 2605, 1 } }, tool = 162, out = { 3842, 1 }, oq = 2 },
    [3507] = { name = "Golden Scale Leggings", t = { 1, 170, 182, 195 }, scroll = 3872, train = 145, sq = 2, r = { { 3575, 10 }, { 3577, 2 }, { 3486, 1 } }, tool = 162, out = { 3843, 1 }, oq = 2 },
    [3508] = { name = "Green Iron Hauberk", t = { 1, 180, 192, 205 }, fee = 7500, train = 155, r = { { 3575, 20 }, { 3486, 4 }, { 1529, 2 }, { 1206, 2 }, { 4255, 1 } }, tool = 162, out = { 3844, 1 }, oq = 3 },
    [3511] = { name = "Golden Scale Cuirass", t = { 1, 195, 207, 220 }, scroll = 3873, train = 170, sq = 2, r = { { 3859, 12 }, { 3577, 2 }, { 3486, 4 }, { 1529, 2 } }, tool = 162, out = { 3845, 1 }, oq = 2 },
    [3513] = { name = "Polished Steel Boots", t = { 1, 185, 197, 210 }, scroll = 3874, train = 160, sq = 2, r = { { 3859, 8 }, { 3864, 1 }, { 1705, 1 }, { 3486, 2 } }, tool = 162, out = { 3846, 1 }, oq = 2 },
    [3515] = { name = "Golden Scale Boots", t = { 1, 200, 212, 225 }, scroll = 3875, train = 175, sq = 3, r = { { 3859, 10 }, { 3577, 4 }, { 3486, 4 }, { 3864, 1 } }, tool = 162, out = { 3847, 1 }, oq = 2 },
    [6517] = { name = "Pearl-handled Dagger", t = { 1, 115, 130, 145 }, fee = 800, train = 85, r = { { 2841, 6 }, { 3466, 1 }, { 5498, 2 }, { 3478, 2 } }, tool = 162, out = { 5540, 1 }, oq = 2 },
    [6518] = { name = "Iridescent Hammer", t = { 1, 145, 160, 175 }, scroll = 5543, train = 115, sq = 2, r = { { 2841, 10 }, { 3466, 1 }, { 5500, 1 }, { 3478, 2 }, { 2319, 2 } }, tool = 162, out = { 5541, 1 }, oq = 2 },
    [7221] = { name = "Iron Shield Spike", t = { 1, 155, 170, 185 }, scroll = 6044, train = 125, sq = 2, r = { { 3575, 6 }, { 3478, 4 } }, tool = 162, out = { 6042, 1 }, oq = 1 },
    [7222] = { name = "Iron Counterweight", t = { 1, 165, 177, 190 }, scroll = 6045, train = 140, sq = 2, r = { { 3575, 4 }, { 3478, 2 }, { 1705, 1 } }, tool = 162, out = { 6043, 1 }, oq = 1 },
    [7223] = { name = "Golden Scale Bracers", t = { 1, 185, 197, 210 }, fee = 1000, train = 160, r = { { 3859, 5 }, { 3486, 2 } }, tool = 162, out = { 6040, 1 }, oq = 2 },
    [7224] = { name = "Steel Weapon Chain", t = { 1, 190, 202, 215 }, scroll = 6046, train = 165, sq = 2, r = { { 3859, 8 }, { 3486, 2 }, { 4234, 4 } }, tool = 162, out = { 6041, 1 }, oq = 1 },
    [7408] = { name = "Heavy Copper Maul", t = { 1, 80, 100, 120 }, fee = 300, train = 40, r = { { 2840, 12 }, { 2880, 2 }, { 2318, 2 } }, tool = 162, out = { 6214, 1 }, oq = 2 },
    [7817] = { name = "Rough Bronze Boots", t = { 1, 100, 115, 130 }, fee = 200, train = 70, r = { { 2841, 6 }, { 3470, 6 } }, tool = 162, out = { 6350, 1 }, oq = 2 },
    [7818] = { name = "Silver Rod", t = { 1, 80, 82, 85 }, fee = 100, train = 75, r = { { 2842, 1 }, { 3470, 2 } }, tool = 162, out = { 6338, 1 }, oq = 1 },
    [8366] = { name = "Ironforge Chain", t = { 1, 80, 100, 120 }, scroll = 6734, train = 70, sq = 1, r = { { 2840, 12 }, { 774, 2 }, { 3470, 2 } }, tool = 162, out = { 6730, 1 }, oq = 2 },
    [8367] = { name = "Ironforge Breastplate", t = { 1, 115, 135, 155 }, scroll = 6735, train = 100, sq = 2, r = { { 2840, 16 }, { 818, 2 }, { 3470, 3 } }, tool = 162, out = { 6731, 1 }, oq = 2 },
    [8368] = { name = "Ironforge Gauntlets", t = { 1, 140, 155, 170 }, scroll = 6736, train = 130, sq = 1, r = { { 2841, 8 }, { 1210, 3 }, { 3478, 4 } }, tool = 162, out = { 6733, 1 }, oq = 2 },
    [8768] = { name = "Iron Buckle", t = { 1, 125, 127, 130 }, fee = 250, train = 125, r = { { 3575, 1 } }, tool = 162, out = { 7071, 2 }, oq = 1 },
    [8880] = { name = "Copper Dagger", t = { 1, 65, 85, 105 }, fee = 100, train = 25, r = { { 2840, 6 }, { 2880, 1 }, { 3470, 1 }, { 2318, 1 } }, tool = 162, out = { 7166, 1 }, oq = 2 },
    [9811] = { name = "Barbaric Iron Shoulders", t = { 1, 160, 172, 185 }, scroll = 7978, train = 135, sq = 2, r = { { 3575, 8 }, { 5635, 4 }, { 1210, 2 }, { 3486, 2 } }, tool = 162, out = { 7913, 1 }, oq = 2 },
    [9813] = { name = "Barbaric Iron Breastplate", t = { 1, 160, 172, 185 }, scroll = 7979, train = 135, sq = 2, r = { { 3575, 20 }, { 3486, 4 } }, tool = 162, out = { 7914, 1 }, oq = 2 },
    [9814] = { name = "Barbaric Iron Helm", t = { 1, 175, 187, 200 }, scroll = 7980, train = 150, sq = 2, r = { { 3575, 10 }, { 5637, 2 }, { 5635, 2 } }, tool = 162, out = { 7915, 1 }, oq = 2 },
    [9818] = { name = "Barbaric Iron Boots", t = { 1, 180, 192, 205 }, scroll = 7981, train = 155, sq = 2, r = { { 3575, 12 }, { 5637, 4 }, { 818, 4 }, { 3486, 2 } }, tool = 162, out = { 7916, 1 }, oq = 2 },
    [9820] = { name = "Barbaric Iron Gloves", t = { 1, 185, 197, 210 }, scroll = 7982, train = 160, sq = 2, r = { { 3575, 14 }, { 3486, 3 }, { 5637, 2 } }, tool = 162, out = { 7917, 1 }, oq = 2 },
    [9916] = { name = "Steel Breastplate", t = { 1, 200, 212, 225 }, fee = 2500, train = 175, r = { { 3859, 16 }, { 3486, 3 } }, tool = 162, out = { 7963, 1 }, oq = 2 },
    [9918] = { name = "Solid Sharpening Stone", t = { 1, 175, 180, 185 }, fee = 2500, train = 175, r = { { 7912, 1 } }, out = { 7964, 1 }, oq = 1 },
    [9920] = { name = "Solid Grinding Stone", t = { 1, 175, 180, 185 }, fee = 2500, train = 175, r = { { 7912, 4 } }, out = { 7966, 1 }, oq = 1 },
    [9921] = { name = "Solid Weightstone", t = { 1, 175, 180, 185 }, fee = 2500, train = 175, r = { { 7912, 1 } }, out = { 7965, 1 }, oq = 1 },
    [9926] = { name = "Heavy Mithril Shoulder", t = { 1, 200, 210, 220 }, fee = 5000, train = 180, r = { { 3860, 8 }, { 4234, 6 } }, tool = 162, out = { 7918, 1 }, oq = 2 },
    [9928] = { name = "Heavy Mithril Gauntlet", t = { 1, 200, 210, 220 }, fee = 5000, train = 180, r = { { 3860, 6 }, { 4338, 4 } }, tool = 162, out = { 7919, 1 }, oq = 2 },
    [9931] = { name = "Mithril Plate Pants", t = { 1, 205, 215, 225 }, fee = 5000, train = 185, r = { { 3860, 12 } }, tool = 162, out = { 7920, 1 }, oq = 2 },
    [9933] = { name = "Heavy Mithril Pants", t = { 1, 205, 215, 225 }, scroll = 7975, train = 185, sq = 2, r = { { 3860, 10 }, { 1705, 2 } }, tool = 162, out = { 7921, 1 }, oq = 2 },
    [9935] = { name = "Steel Plate Helm", t = { 1, 210, 220, 230 }, fee = 5000, train = 190, r = { { 3859, 14 }, { 7966, 1 } }, tool = 162, out = { 7922, 1 }, oq = 2 },
    [9937] = { name = "Mithril Plate Bracers", t = { 1, 210, 220, 230 }, scroll = 7995, train = 190, scrollPrice = 6000, sq = 1, r = { { 3860, 8 }, { 3864, 2 } }, tool = 162, out = { 7924, 1 }, oq = 2 },
    [9939] = { name = "Mithril Shield Spike", t = { 1, 210, 220, 230 }, scroll = 7976, train = 190, sq = 3, r = { { 3860, 4 }, { 6037, 2 }, { 7966, 4 } }, tool = 162, out = { 7967, 1 }, oq = 2 },
    [9942] = { name = "Mithril Plate Gloves", t = { 1, 215, 225, 235 }, scroll = 7977, train = 205, sq = 1, r = { { 3860, 8 }, { 4234, 6 }, { 4338, 4 } }, tool = 162, out = { 7925, 1 }, oq = 2 },
    [9945] = { name = "Ornate Mithril Pants", t = { 1, 215, 225, 235 }, scroll = 7983, train = 195, sq = 2, r = { { 3860, 12 }, { 6037, 1 }, { 7966, 1 }, { 7909, 1 } }, tool = 162, out = { 7926, 1 }, oq = 2 },
    [9950] = { name = "Ornate Mithril Gloves", t = { 1, 215, 225, 235 }, scroll = 7984, train = 195, sq = 2, r = { { 3860, 10 }, { 4338, 6 }, { 6037, 1 }, { 7966, 1 } }, tool = 162, out = { 7927, 1 }, oq = 2 },
    [9952] = { name = "Ornate Mithril Shoulders", t = { 1, 220, 230, 240 }, scroll = 7985, train = 200, sq = 2, r = { { 3860, 12 }, { 6037, 1 }, { 4304, 6 } }, tool = 162, out = { 7928, 1 }, oq = 2 },
    [9954] = { name = "Truesilver Gauntlets", t = { 1, 220, 230, 240 }, fee = 10000, train = 220, tr = { 7230 }, r = { { 3860, 10 }, { 6037, 8 }, { 7909, 3 }, { 3864, 3 }, { 5966, 1 }, { 7966, 2 } }, tool = 162, out = { 7938, 1 }, oq = 3 },
    [9957] = { name = "Orcish War Leggings", t = { 1, 225, 235, 245 }, scroll = 7994, train = 215, sq = 1, r = { { 3860, 12 }, { 7067, 1 } }, tool = 162, out = { 7929, 1 }, oq = 2 },
    [9959] = { name = "Heavy Mithril Breastplate", t = { 1, 225, 235, 245 }, fee = 15000, train = 205, tr = { 2836 }, r = { { 3860, 16 } }, tool = 162, out = { 7930, 1 }, oq = 2 },
    [9961] = { name = "Mithril Coif", t = { 1, 225, 235, 245 }, fee = 15000, train = 205, tr = { 2836 }, r = { { 3860, 10 }, { 4338, 6 } }, tool = 162, out = { 7931, 1 }, oq = 2 },
    [9964] = { name = "Mithril Spurs", t = { 1, 230, 240, 250 }, scroll = 7989, train = 210, sq = 2, r = { { 3860, 4 }, { 7966, 3 } }, tool = 162, out = { 7969, 1 }, oq = 2 },
    [9966] = { name = "Mithril Plate Shoulders", t = { 1, 230, 240, 250 }, scroll = 7991, train = 210, sq = 3, r = { { 3860, 14 }, { 4304, 4 }, { 3864, 4 } }, tool = 162, out = { 7932, 1 }, oq = 2 },
    [9968] = { name = "Heavy Mithril Boots", t = { 1, 230, 240, 250 }, fee = 20000, train = 210, tr = { 2836 }, r = { { 3860, 14 }, { 4304, 4 } }, tool = 162, out = { 7933, 1 }, oq = 2 },
    [9970] = { name = "Heavy Mithril Helm", t = { 1, 230, 240, 250 }, scroll = 7990, train = 220, sq = 2, r = { { 3860, 14 }, { 7909, 1 } }, tool = 162, out = { 7934, 1 }, oq = 2 },
    [9972] = { name = "Ornate Mithril Breastplate", t = { 1, 235, 245, 255 }, scroll = 7986, train = 225, sq = 1, r = { { 3860, 16 }, { 6037, 6 }, { 7077, 1 }, { 7966, 1 } }, tool = 162, out = { 7935, 1 }, oq = 2 },
    [9974] = { name = "Truesilver Breastplate", t = { 1, 240, 250, 260 }, fee = 10000, train = 240, tr = { 7230 }, r = { { 3860, 12 }, { 6037, 24 }, { 7910, 4 }, { 7971, 4 }, { 7966, 2 } }, tool = 162, out = { 7939, 1 }, oq = 3 },
    [9979] = { name = "Ornate Mithril Boots", t = { 1, 240, 250, 260 }, scroll = 7988, train = 230, sq = 1, r = { { 3860, 14 }, { 6037, 2 }, { 4304, 4 }, { 7966, 1 }, { 7909, 1 } }, tool = 162, out = { 7936, 1 }, oq = 2 },
    [9980] = { name = "Ornate Mithril Helm", t = { 1, 240, 250, 260 }, scroll = 7987, train = 230, sq = 1, r = { { 3860, 16 }, { 6037, 2 }, { 7971, 1 }, { 7966, 1 } }, tool = 162, out = { 7937, 1 }, oq = 2 },
    [9983] = { name = "Copper Claymore", t = { 1, 65, 85, 105 }, fee = 100, train = 25, r = { { 2840, 10 }, { 2880, 2 }, { 3470, 1 }, { 2318, 1 } }, tool = 162, out = { 7955, 1 }, oq = 2 },
    [9985] = { name = "Bronze Warhammer", t = { 1, 155, 170, 185 }, fee = 250, train = 100, r = { { 2841, 8 }, { 3466, 1 }, { 2319, 1 } }, tool = 162, out = { 7956, 1 }, oq = 2 },
    [9986] = { name = "Bronze Greatsword", t = { 1, 135, 150, 165 }, fee = 500, train = 105, r = { { 2841, 12 }, { 3466, 2 }, { 2319, 2 } }, tool = 162, out = { 7957, 1 }, oq = 2 },
    [9987] = { name = "Bronze Battle Axe", t = { 1, 140, 155, 170 }, fee = 500, train = 110, r = { { 2841, 14 }, { 3466, 1 }, { 2319, 2 } }, tool = 162, out = { 7958, 1 }, oq = 2 },
    [9993] = { name = "Heavy Mithril Axe", t = { 1, 210, 222, 235 }, fee = 10000, train = 185, r = { { 3860, 12 }, { 3864, 2 }, { 7966, 1 }, { 4234, 4 } }, tool = 162, out = { 7941, 1 }, oq = 2 },
    [9995] = { name = "Blue Glittering Axe", t = { 1, 220, 232, 245 }, scroll = 7992, train = 195, sq = 2, r = { { 3860, 16 }, { 7909, 2 }, { 7966, 1 }, { 4304, 4 } }, tool = 162, out = { 7942, 1 }, oq = 2 },
    [9997] = { name = "Wicked Mithril Blade", t = { 1, 225, 237, 250 }, scroll = 8029, train = 200, sq = 2, r = { { 3860, 14 }, { 6037, 4 }, { 7966, 1 }, { 4304, 2 } }, tool = 162, out = { 7943, 1 }, oq = 2 },
    [10001] = { name = "Big Black Mace", t = { 1, 230, 242, 255 }, fee = 15000, train = 205, tr = { 2836 }, r = { { 3860, 16 }, { 7971, 1 }, { 1210, 4 }, { 7966, 1 }, { 4304, 2 } }, tool = 162, out = { 7945, 1 }, oq = 2 },
    [10003] = { name = "The Shatterer", t = { 1, 235, 247, 260 }, gone = true, r = { { 3860, 24 }, { 7075, 4 }, { 6037, 6 }, { 3864, 5 }, { 1529, 5 }, { 7966, 4 }, { 4304, 4 } }, tool = 162, out = { 7954, 1 }, oq = 3 },
    [10005] = { name = "Dazzling Mithril Rapier", t = { 1, 240, 252, 265 }, scroll = 7993, train = 215, sq = 2, r = { { 3860, 14 }, { 7909, 1 }, { 1705, 2 }, { 1206, 2 }, { 7966, 1 }, { 4338, 2 } }, tool = 162, out = { 7944, 1 }, oq = 2 },
    [10007] = { name = "Phantom Blade", t = { 1, 245, 257, 270 }, gone = true, r = { { 3860, 28 }, { 7081, 6 }, { 6037, 8 }, { 3823, 2 }, { 7909, 6 }, { 7966, 4 }, { 4304, 2 } }, tool = 162, out = { 7961, 1 }, oq = 3 },
    [10009] = { name = "Runed Mithril Hammer", t = { 1, 245, 257, 270 }, scroll = 8028, train = 220, sq = 3, r = { { 3860, 18 }, { 7075, 2 }, { 7966, 1 }, { 4304, 4 } }, tool = 162, out = { 7946, 1 }, oq = 2 },
    [10011] = { name = "Blight", t = { 1, 250, 262, 275 }, gone = true, r = { { 3860, 28 }, { 7972, 10 }, { 6037, 10 }, { 7966, 6 }, { 4304, 6 } }, tool = 162, out = { 7959, 1 }, oq = 3 },
    [10013] = { name = "Ebon Shiv", t = { 1, 255, 267, 280 }, scroll = 8030, train = 230, scrollPrice = 10000, sq = 1, r = { { 3860, 12 }, { 6037, 6 }, { 7910, 2 }, { 7966, 1 }, { 4304, 2 } }, tool = 162, out = { 7947, 1 }, oq = 2 },
    [10015] = { name = "Truesilver Champion", t = { 1, 260, 272, 285 }, gone = true, r = { { 3860, 30 }, { 6037, 16 }, { 7910, 6 }, { 7081, 4 }, { 7966, 8 }, { 4304, 6 } }, tool = 162, out = { 7960, 1 }, oq = 3 },
    [11454] = { name = "Inlaid Mithril Cylinder", t = { 1, 200, 212, 225 }, scroll = 10713, train = 200, sq = 1, r = { { 3860, 5 }, { 3577, 1 }, { 6037, 1 } }, tool = 162, out = { 9060, 1 }, oq = 1 },
    [11643] = { name = "Golden Scale Gauntlets", t = { 1, 200, 210, 220 }, scroll = 9367, train = 180, sq = 2, r = { { 3859, 10 }, { 3577, 4 }, { 3486, 4 }, { 3864, 1 } }, tool = 162, out = { 9366, 1 }, oq = 2 },
    [12259] = { name = "Silvered Bronze Leggings", t = { 1, 155, 167, 180 }, scroll = 10424, train = 130, sq = 2, r = { { 2841, 12 }, { 2842, 4 }, { 3478, 2 } }, tool = 162, out = { 10423, 1 }, oq = 2 },
    [12260] = { name = "Rough Copper Vest", t = { 1, 15, 35, 55 }, basic = true, r = { { 2840, 4 } }, tool = 162, out = { 10421, 1 }, oq = 2 },
    [14379] = { name = "Golden Rod", t = { 1, 130, 132, 135 }, fee = 250, train = 125, r = { { 3577, 1 }, { 3478, 2 } }, tool = 162, out = { 11128, 1 }, oq = 1 },
    [14380] = { name = "Truesilver Rod", t = { 1, 180, 182, 185 }, fee = 2500, train = 175, r = { { 6037, 1 }, { 3486, 1 } }, tool = 162, out = { 11144, 1 }, oq = 1 },
    [15292] = { name = "Dark Iron Pulverizer", t = { 1, 260, 270, 280 }, scroll = 11610, train = 240, sq = 3, r = { { 11371, 18 }, { 7077, 4 } }, tool = 162, out = { 11608, 1 }, oq = 3 },
    [15293] = { name = "Dark Iron Mail", t = { 1, 265, 275, 285 }, scroll = 11614, train = 245, sq = 2, r = { { 11371, 10 }, { 7077, 2 } }, tool = 162, out = { 11606, 1 }, oq = 2 },
    [15294] = { name = "Dark Iron Sunderer", t = { 1, 270, 280, 290 }, scroll = 11611, train = 250, sq = 3, r = { { 11371, 26 }, { 7077, 4 } }, tool = 162, out = { 11607, 1 }, oq = 3 },
    [15295] = { name = "Dark Iron Shoulders", t = { 1, 275, 285, 295 }, scroll = 11615, train = 255, sq = 2, r = { { 11371, 6 }, { 7077, 1 } }, tool = 162, out = { 11605, 1 }, oq = 2 },
    [15296] = { name = "Dark Iron Plate", t = { 1, 280, 290, 300 }, scroll = 11612, train = 260, sq = 3, r = { { 11371, 20 }, { 7077, 8 } }, tool = 162, out = { 11604, 1 }, oq = 3, bop = true },
    [15972] = { name = "Glinting Steel Dagger", t = { 1, 180, 192, 205 }, fee = 7500, train = 155, r = { { 3859, 10 }, { 3466, 2 }, { 1206, 1 }, { 7067, 1 }, { 4234, 1 } }, tool = 162, out = { 12259, 1 }, oq = 2 },
    [15973] = { name = "Searing Golden Blade", t = { 1, 190, 202, 215 }, scroll = 12261, train = 165, sq = 2, r = { { 3859, 10 }, { 3577, 4 }, { 7068, 2 }, { 4234, 2 } }, tool = 162, out = { 12260, 1 }, oq = 2 },
    [16639] = { name = "Dense Grinding Stone", t = { 1, 230, 232, 235 }, fee = 10000, train = 225, tr = { 2836 }, r = { { 12365, 4 } }, out = { 12644, 1 }, oq = 1 },
    [16640] = { name = "Dense Weightstone", t = { 1, 230, 232, 235 }, fee = 10000, train = 225, tr = { 2836 }, r = { { 12365, 1 } }, out = { 12643, 1 }, oq = 1 },
    [16641] = { name = "Dense Sharpening Stone", t = { 1, 230, 232, 235 }, fee = 10000, train = 225, tr = { 2836 }, r = { { 12365, 1 } }, out = { 12404, 1 }, oq = 1 },
    [16642] = { name = "Thorium Armor", t = { 1, 245, 255, 265 }, scroll = 12682, train = 225, sq = 2, r = { { 12359, 16 }, { 12361, 1 }, { 11188, 4 } }, tool = 162, out = { 12405, 1 }, oq = 2 },
    [16643] = { name = "Thorium Belt", t = { 1, 245, 255, 265 }, scroll = 12683, train = 225, sq = 2, r = { { 12359, 12 }, { 11186, 4 } }, tool = 162, out = { 12406, 1 }, oq = 2 },
    [16644] = { name = "Thorium Bracers", t = { 1, 250, 260, 270 }, scroll = 12684, train = 230, sq = 2, r = { { 12359, 12 }, { 11184, 4 } }, tool = 162, out = { 12408, 1 }, oq = 2 },
    [16645] = { name = "Radiant Belt", t = { 1, 255, 265, 275 }, scroll = 12685, train = 235, sq = 2, r = { { 12359, 10 }, { 7077, 2 } }, tool = 162, out = { 12416, 1 }, oq = 2 },
    [16646] = { name = "Imperial Plate Shoulders", t = { 1, 260, 270, 280 }, scroll = 12687, train = 240, sq = 2, r = { { 12359, 24 }, { 8170, 6 }, { 3864, 2 } }, tool = 162, out = { 12428, 1 }, oq = 2 },
    [16647] = { name = "Imperial Plate Belt", t = { 1, 260, 270, 280 }, scroll = 12688, train = 240, sq = 2, r = { { 12359, 22 }, { 8170, 6 }, { 7909, 1 } }, tool = 162, out = { 12424, 1 }, oq = 2 },
    [16648] = { name = "Radiant Breastplate", t = { 1, 265, 275, 285 }, scroll = 12689, train = 245, sq = 2, r = { { 12359, 18 }, { 7077, 2 }, { 7910, 1 } }, tool = 162, out = { 12415, 1 }, oq = 2 },
    [16649] = { name = "Imperial Plate Bracers", t = { 1, 265, 275, 285 }, scroll = 12690, train = 245, sq = 2, r = { { 12359, 20 }, { 7910, 1 } }, tool = 162, out = { 12425, 1 }, oq = 2 },
    [16651] = { name = "Thorium Shield Spike", t = { 1, 270, 280, 290 }, scroll = 12692, train = 250, sq = 2, r = { { 12359, 4 }, { 12644, 4 }, { 7076, 2 } }, tool = 162, out = { 12645, 1 }, oq = 2 },
    [16652] = { name = "Thorium Boots", t = { 1, 275, 285, 295 }, scroll = 12693, train = 255, sq = 2, r = { { 12359, 20 }, { 8170, 8 }, { 11185, 4 } }, tool = 162, out = { 12409, 1 }, oq = 2 },
    [16653] = { name = "Thorium Helm", t = { 1, 275, 285, 295 }, scroll = 12694, train = 255, sq = 2, r = { { 12359, 24 }, { 7910, 1 }, { 11188, 4 } }, tool = 162, out = { 12410, 1 }, oq = 2 },
    [16654] = { name = "Radiant Gloves", t = { 1, 280, 290, 300 }, scroll = 12695, train = 260, sq = 2, r = { { 12359, 18 }, { 7077, 4 } }, tool = 162, out = { 12418, 1 }, oq = 2 },
    [16655] = { name = "Fiery Plate Gauntlets", t = { 1, 285, 295, 305 }, scroll = 12699, train = 265, sq = 3, r = { { 12359, 20 }, { 12655, 6 }, { 7078, 2 }, { 7910, 4 } }, tool = 162, out = { 12631, 1 }, oq = 3 },
    [16656] = { name = "Radiant Boots", t = { 1, 285, 295, 305 }, scroll = 12697, train = 265, sq = 2, r = { { 12359, 14 }, { 7077, 4 } }, tool = 162, out = { 12419, 1 }, oq = 2 },
    [16657] = { name = "Imperial Plate Boots", t = { 1, 290, 300, 310 }, scroll = 12700, train = 270, sq = 2, r = { { 12359, 34 }, { 7910, 1 }, { 7909, 1 } }, tool = 162, out = { 12426, 1 }, oq = 2 },
    [16658] = { name = "Imperial Plate Helm", t = { 1, 290, 300, 310 }, scroll = 12701, train = 270, sq = 2, r = { { 12359, 34 }, { 7910, 2 } }, tool = 162, out = { 12427, 1 }, oq = 2 },
    [16659] = { name = "Radiant Circlet", t = { 1, 290, 300, 310 }, scroll = 12702, train = 270, sq = 2, r = { { 12359, 18 }, { 7077, 4 } }, tool = 162, out = { 12417, 1 }, oq = 2 },
    [16660] = { name = "Dawnbringer Shoulders", t = { 1, 285, 295, 305 }, scroll = 12698, train = 265, scrollPrice = 22000, rep = { 529, 6 }, sq = 3, r = { { 12359, 20 }, { 12360, 4 }, { 12364, 2 }, { 7080, 2 } }, tool = 162, out = { 12625, 1 }, oq = 3 },
    [16662] = { name = "Thorium Leggings", t = { 1, 295, 305, 315 }, scroll = 12704, train = 275, sq = 2, r = { { 12359, 26 }, { 11186, 4 } }, tool = 162, out = { 12414, 1 }, oq = 2 },
    [16663] = { name = "Imperial Plate Chest", t = { 1, 295, 305, 315 }, scroll = 12705, train = 275, sq = 2, r = { { 12359, 40 }, { 7910, 2 } }, tool = 162, out = { 12422, 1 }, oq = 2 },
    [16664] = { name = "Runic Plate Shoulders", t = { 1, 295, 305, 315 }, scroll = 12706, train = 275, sq = 2, r = { { 12359, 20 }, { 12360, 2 }, { 3577, 6 } }, tool = 162, out = { 12610, 1 }, oq = 2 },
    [16665] = { name = "Runic Plate Boots", t = { 1, 295, 305, 315 }, scroll = 12707, train = 275, sq = 2, r = { { 12359, 20 }, { 12360, 2 }, { 2842, 10 } }, tool = 162, out = { 12611, 1 }, oq = 2 },
    [16667] = { name = "Demon Forged Breastplate", t = { 1, 280, 290, 300 }, scroll = 12696, train = 260, sq = 3, r = { { 12359, 40 }, { 12662, 10 }, { 12361, 4 }, { 7910, 4 } }, tool = 162, out = { 12628, 1 }, oq = 1 },
    [16724] = { name = "Whitesoul Helm", t = { 1, 310, 320, 330 }, scroll = 12711, train = 290, sq = 3, r = { { 12359, 20 }, { 12655, 4 }, { 6037, 6 }, { 3577, 6 }, { 12800, 2 } }, tool = 162, out = { 12633, 1 }, oq = 3 },
    [16725] = { name = "Radiant Leggings", t = { 1, 300, 310, 320 }, scroll = 12713, train = 280, sq = 2, r = { { 12359, 20 }, { 7077, 4 } }, tool = 162, out = { 12420, 1 }, oq = 2 },
    [16726] = { name = "Runic Plate Helm", t = { 1, 300, 310, 320 }, scroll = 12714, train = 280, sq = 2, r = { { 12359, 30 }, { 12360, 2 }, { 6037, 2 }, { 12364, 1 } }, tool = 162, out = { 12612, 1 }, oq = 2 },
    [16729] = { name = "Lionheart Helm", t = { 1, 320, 330, 340 }, scroll = 12717, train = 300, sq = 4, r = { { 12359, 80 }, { 12360, 12 }, { 8146, 40 }, { 12361, 10 }, { 12800, 4 } }, tool = 162, out = { 12640, 1 }, oq = 4 },
    [16730] = { name = "Imperial Plate Leggings", t = { 1, 300, 310, 320 }, scroll = 12715, train = 280, sq = 2, r = { { 12359, 44 }, { 7910, 2 } }, tool = 162, out = { 12429, 1 }, oq = 2 },
    [16731] = { name = "Runic Breastplate", t = { 1, 305, 315, 325 }, scroll = 12718, train = 285, sq = 2, r = { { 12359, 40 }, { 12360, 2 }, { 7910, 1 } }, tool = 162, out = { 12613, 1 }, oq = 2 },
    [16732] = { name = "Runic Plate Leggings", t = { 1, 305, 315, 325 }, scroll = 12719, train = 285, sq = 2, r = { { 12359, 40 }, { 12360, 2 }, { 7910, 1 } }, tool = 162, out = { 12614, 1 }, oq = 2 },
    [16741] = { name = "Stronghold Gauntlets", t = { 1, 320, 330, 340 }, scroll = 228118, train = 300, sq = 4, r = { { 12360, 15 }, { 12655, 20 }, { 7076, 10 }, { 12361, 4 }, { 12799, 4 } }, tool = 162, out = { 12639, 1 }, oq = 4 },
    [16742] = { name = "Enchanted Thorium Helm", t = { 1, 320, 330, 340 }, scroll = 12725, train = 300, sq = 3, r = { { 12360, 6 }, { 12655, 16 }, { 7076, 6 }, { 12799, 2 }, { 12800, 1 } }, tool = 162, out = { 12620, 1 }, oq = 3 },
    [16744] = { name = "Enchanted Thorium Leggings", t = { 1, 320, 330, 340 }, scroll = 12726, train = 300, sq = 3, r = { { 12360, 10 }, { 12655, 20 }, { 7080, 6 }, { 12361, 2 }, { 12364, 1 } }, tool = 162, out = { 12619, 1 }, oq = 3 },
    [16745] = { name = "Enchanted Thorium Breastplate", t = { 1, 320, 330, 340 }, scroll = 12727, train = 300, sq = 3, r = { { 12360, 8 }, { 12655, 24 }, { 7076, 4 }, { 7080, 4 }, { 12364, 2 }, { 12800, 2 } }, tool = 162, out = { 12618, 1 }, oq = 3 },
    [16960] = { name = "Thorium Greatsword", t = { 1, 260, 272, 285 }, scroll = 12816, train = 250, sq = 1, r = { { 12359, 16 }, { 12644, 2 }, { 8170, 4 } }, tool = 162, out = { 12764, 1 }, oq = 2 },
    [16965] = { name = "Bleakwood Hew", t = { 1, 270, 282, 295 }, scroll = 12817, train = 260, sq = 1, r = { { 12359, 30 }, { 12803, 6 }, { 8153, 6 }, { 12799, 6 }, { 12644, 2 }, { 8170, 8 } }, tool = 162, out = { 12769, 1 }, oq = 3 },
    [16967] = { name = "Inlaid Thorium Hammer", t = { 1, 270, 282, 295 }, scroll = 12818, train = 260, sq = 1, r = { { 12359, 30 }, { 3577, 4 }, { 6037, 2 }, { 12361, 2 }, { 8170, 4 } }, tool = 162, out = { 12772, 1 }, oq = 2 },
    [16969] = { name = "Ornate Thorium Handaxe", t = { 1, 275, 287, 300 }, scroll = 12819, train = 250, scrollPrice = 16000, sq = 2, r = { { 12359, 20 }, { 12799, 2 }, { 12644, 2 }, { 8170, 4 } }, tool = 162, out = { 12773, 1 }, oq = 2, bop = true },
    [16970] = { name = "Dawn's Edge", t = { 1, 275, 287, 300 }, scroll = 12821, train = 250, sq = 3, r = { { 12359, 30 }, { 12655, 4 }, { 7910, 4 }, { 12361, 4 }, { 12644, 2 }, { 8170, 4 } }, tool = 162, out = { 12774, 1 }, oq = 3 },
    [16971] = { name = "Huge Thorium Battleaxe", t = { 1, 280, 292, 305 }, scroll = 12823, train = 255, scrollPrice = 20000, sq = 1, r = { { 12359, 40 }, { 12644, 6 }, { 8170, 6 } }, tool = 162, out = { 12775, 1 }, oq = 2 },
    [16973] = { name = "Enchanted Battlehammer", t = { 1, 280, 292, 305 }, scroll = 12824, train = 255, sq = 2, r = { { 12359, 20 }, { 12655, 6 }, { 12364, 2 }, { 12804, 4 }, { 8170, 4 } }, tool = 162, out = { 12776, 1 }, oq = 3 },
    [16978] = { name = "Blazing Rapier", t = { 1, 280, 292, 305 }, scroll = 12825, train = 255, sq = 2, r = { { 12655, 10 }, { 7078, 4 }, { 7077, 4 }, { 12800, 2 }, { 12644, 2 } }, tool = 162, out = { 12777, 1 }, oq = 3 },
    [16980] = { name = "Rune Edge", t = { 1, 285, 297, 310 }, scroll = 12826, train = 275, sq = 1, r = { { 12359, 30 }, { 12799, 2 }, { 12644, 2 }, { 8170, 4 } }, tool = 162, out = { 12779, 1 }, oq = 1 },
    [16983] = { name = "Serenity", t = { 1, 285, 297, 310 }, scroll = 12827, train = 260, sq = 2, r = { { 12655, 6 }, { 12360, 2 }, { 12804, 4 }, { 12799, 2 }, { 12361, 2 }, { 12364, 1 } }, tool = 162, out = { 12781, 1 }, oq = 3 },
    [16984] = { name = "Volcanic Hammer", t = { 1, 290, 302, 315 }, scroll = 12828, train = 265, sq = 2, r = { { 12359, 30 }, { 7077, 4 }, { 7910, 4 }, { 8170, 4 } }, tool = 162, out = { 12792, 1 }, oq = 2 },
    [16985] = { name = "Corruption", t = { 1, 290, 302, 315 }, scroll = 12830, train = 265, sq = 1, r = { { 12359, 40 }, { 12360, 2 }, { 12662, 16 }, { 12808, 8 }, { 12361, 2 }, { 12644, 2 }, { 8170, 4 } }, tool = 162, out = { 12782, 1 }, oq = 3, bop = true },
    [16986] = { name = "Blood Talon", t = { 1, 325, 337, 350 }, scroll = 12831, train = 315, sq = 1, r = { { 12655, 10 }, { 12360, 10 }, { 12662, 8 }, { 7910, 10 }, { 12644, 2 } }, tool = 162, out = { 12795, 1 }, oq = 3, bop = true },
    [16987] = { name = "Darkspear", t = { 1, 325, 337, 350 }, scroll = 12832, train = 315, sq = 1, r = { { 12655, 20 }, { 12804, 20 }, { 12364, 2 }, { 12800, 2 }, { 12644, 2 } }, tool = 162, out = { 12802, 1 }, oq = 3 },
    [16988] = { name = "Hammer of the Titans", t = { 1, 320, 330, 340 }, scroll = 12833, train = 300, sq = 3, r = { { 12359, 50 }, { 12360, 15 }, { 12809, 4 }, { 12810, 6 }, { 7076, 10 } }, tool = 162, out = { 12796, 1 }, oq = 3 },
    [16990] = { name = "Arcanite Champion", t = { 1, 320, 330, 340 }, scroll = 12834, train = 300, sq = 3, r = { { 12360, 15 }, { 12800, 8 }, { 12811, 1 }, { 12799, 4 }, { 12810, 8 }, { 12644, 2 } }, tool = 162, out = { 12790, 1 }, oq = 3 },
    [16991] = { name = "Annihilator", t = { 1, 295, 305, 315 }, scroll = 12835, train = 300, sq = 3, r = { { 12359, 40 }, { 12360, 12 }, { 12808, 10 }, { 12364, 8 }, { 12644, 2 }, { 12810, 4 } }, tool = 162, out = { 12798, 1 }, oq = 3 },
    [16992] = { name = "Frostguard", t = { 1, 320, 330, 340 }, scroll = 12836, train = 300, sq = 3, r = { { 12360, 18 }, { 12361, 8 }, { 12800, 8 }, { 7080, 4 }, { 12644, 2 }, { 12810, 4 } }, tool = 162, out = { 12797, 1 }, oq = 3 },
    [16993] = { name = "Masterwork Stormhammer", t = { 1, 320, 330, 340 }, scroll = 12837, train = 300, sq = 3, r = { { 12655, 20 }, { 12364, 8 }, { 12799, 8 }, { 7076, 6 }, { 12810, 4 } }, tool = 162, out = { 12794, 1 }, oq = 3 },
    [16994] = { name = "Arcanite Reaper", t = { 1, 320, 330, 340 }, scroll = 12838, train = 300, sq = 3, r = { { 12360, 20 }, { 12810, 6 }, { 12644, 2 } }, tool = 162, out = { 12784, 1 }, oq = 3 },
    [16995] = { name = "Heartseeker", t = { 1, 320, 330, 340 }, scroll = 12839, train = 300, sq = 3, r = { { 12360, 10 }, { 12655, 10 }, { 12810, 2 }, { 7910, 6 }, { 12800, 6 }, { 12799, 6 }, { 12644, 4 } }, tool = 162, out = { 12783, 1 }, oq = 3 },
    [19666] = { name = "Silver Skeleton Key", t = { 1, 75, 85, 95 }, fee = 100, train = 75, r = { { 2842, 1 }, { 3470, 1 } }, tool = 162, out = { 15869, 2 }, oq = 2 },
    [19667] = { name = "Golden Skeleton Key", t = { 1, 125, 135, 145 }, fee = 250, train = 125, r = { { 3577, 1 }, { 3486, 1 } }, tool = 162, out = { 15870, 2 }, oq = 2 },
    [19668] = { name = "Truesilver Skeleton Key", t = { 1, 175, 185, 195 }, fee = 2500, train = 175, r = { { 6037, 1 }, { 7966, 1 } }, tool = 162, out = { 15871, 2 }, oq = 2 },
    [19669] = { name = "Arcanite Skeleton Key", t = { 1, 250, 255, 260 }, fee = 10000, train = 250, r = { { 12360, 1 }, { 12644, 1 } }, tool = 162, out = { 15872, 2 }, oq = 2 },
    [20201] = { name = "Arcanite Rod", t = { 1, 250, 255, 260 }, fee = 10000, train = 250, r = { { 12360, 3 }, { 12644, 1 } }, tool = 162, out = { 16206, 1 }, oq = 1 },
    [20872] = { name = "Fiery Chain Girdle", t = { 1, 290, 300, 310 }, scroll = 17049, train = 270, rep = { 59, 5 }, sq = 3, r = { { 11371, 6 }, { 17010, 3 }, { 17011, 3 } }, tool = 162, out = { 16989, 1 }, oq = 4 },
    [20873] = { name = "Fiery Chain Shoulders", t = { 1, 320, 330, 340 }, scroll = 17053, train = 300, rep = { 59, 6 }, sq = 3, r = { { 11371, 16 }, { 17010, 4 }, { 17011, 5 } }, tool = 162, out = { 16988, 1 }, oq = 4 },
    [20874] = { name = "Dark Iron Bracers", t = { 1, 290, 300, 310 }, scroll = 17051, train = 270, rep = { 59, 4 }, sq = 3, r = { { 11371, 4 }, { 17010, 2 }, { 17011, 2 } }, tool = 162, out = { 17014, 1 }, oq = 4 },
    [20876] = { name = "Dark Iron Leggings", t = { 1, 320, 330, 340 }, scroll = 17052, train = 300, rep = { 59, 6 }, sq = 3, r = { { 11371, 16 }, { 17010, 4 }, { 17011, 6 } }, tool = 162, out = { 17013, 1 }, oq = 4 },
    [20890] = { name = "Dark Iron Reaver", t = { 1, 320, 330, 340 }, scroll = 17059, train = 300, rep = { 59, 5 }, sq = 3, r = { { 11371, 16 }, { 17010, 12 }, { 11382, 2 }, { 12810, 2 } }, tool = 162, out = { 17015, 1 }, oq = 3 },
    [20897] = { name = "Dark Iron Destroyer", t = { 1, 320, 330, 340 }, scroll = 17060, train = 300, rep = { 59, 5 }, sq = 3, r = { { 11371, 18 }, { 17011, 12 }, { 11382, 2 }, { 12810, 2 } }, tool = 162, out = { 17016, 1 }, oq = 3 },
    [21161] = { name = "Sulfuron Hammer", t = { 1, 325, 337, 350 }, scroll = 18592, train = 300, sq = 4, r = { { 17203, 8 }, { 11371, 20 }, { 12360, 50 }, { 7078, 25 }, { 11382, 10 }, { 17011, 10 }, { 17010, 10 } }, tool = 162, out = { 17193, 1 }, oq = 4 },
    [21913] = { name = "Edge of Winter", t = { 1, 190, 202, 215 }, scroll = 17706, train = 165, sq = 2, r = { { 3859, 10 }, { 3829, 1 }, { 7070, 2 }, { 7069, 2 }, { 4234, 2 } }, tool = 162, out = { 17704, 1 }, oq = 2 },
    [22757] = { name = "Elemental Sharpening Stone", t = { 1, 275, 285, 295 }, scroll = 18264, train = 300, sq = 3, r = { { 7067, 2 }, { 12365, 3 } }, out = { 18262, 1 }, oq = 2 },
    [23632] = { name = "Girdle of the Dawn", t = { 1, 285, 295, 305 }, scroll = 19203, train = 265, scrollPrice = 22000, rep = { 529, 5 }, sq = 1, r = { { 12359, 8 }, { 6037, 6 }, { 12811, 1 } }, tool = 162, out = { 19051, 1 }, oq = 3 },
    [23633] = { name = "Gloves of the Dawn", t = { 1, 320, 330, 340 }, scroll = 19205, train = 300, scrollPrice = 40000, rep = { 529, 6 }, sq = 1, r = { { 12360, 2 }, { 6037, 10 }, { 12811, 1 } }, tool = 162, out = { 19057, 1 }, oq = 3 },
    [23636] = { name = "Dark Iron Helm", t = { 1, 320, 330, 340 }, scroll = 19206, train = 300, rep = { 59, 5 }, sq = 1, r = { { 17011, 4 }, { 17010, 2 }, { 11371, 4 } }, tool = 162, out = { 19148, 1 }, oq = 4 },
    [23637] = { name = "Dark Iron Gauntlets", t = { 1, 320, 330, 340 }, scroll = 19207, train = 300, rep = { 59, 6 }, sq = 1, r = { { 17011, 3 }, { 17010, 5 }, { 17012, 4 }, { 11371, 4 }, { 11382, 2 } }, tool = 162, out = { 19164, 1 }, oq = 4 },
    [23638] = { name = "Black Amnesty", t = { 1, 320, 330, 340 }, scroll = 19208, train = 300, rep = { 59, 6 }, sq = 1, r = { { 17011, 3 }, { 17010, 6 }, { 12360, 12 }, { 11382, 1 }, { 11371, 4 } }, tool = 162, out = { 19166, 1 }, oq = 4 },
    [23639] = { name = "Blackfury", t = { 1, 320, 330, 340 }, scroll = 19209, train = 300, rep = { 59, 6 }, sq = 1, r = { { 17011, 5 }, { 17010, 2 }, { 12360, 16 }, { 11371, 6 } }, tool = 162, out = { 19167, 1 }, oq = 4 },
    [23650] = { name = "Ebon Hand", t = { 1, 295, 305, 315 }, scroll = 19210, train = 300, rep = { 59, 7 }, sq = 1, r = { { 17011, 4 }, { 17010, 7 }, { 12360, 12 }, { 11371, 8 }, { 12800, 4 } }, tool = 162, out = { 19170, 1 }, oq = 4 },
    [23652] = { name = "Blackguard", t = { 1, 295, 305, 315 }, scroll = 19211, train = 300, rep = { 59, 7 }, sq = 1, r = { { 17011, 6 }, { 17010, 6 }, { 12360, 10 }, { 11371, 6 }, { 12809, 12 } }, tool = 162, out = { 19168, 1 }, oq = 4 },
    [23653] = { name = "Nightfall", t = { 1, 295, 305, 315 }, scroll = 19212, train = 300, rep = { 59, 7 }, sq = 1, r = { { 17011, 8 }, { 17010, 5 }, { 12360, 10 }, { 11371, 12 }, { 12364, 4 } }, tool = 162, out = { 19169, 1 }, oq = 4 },
    [24136] = { name = "Bloodsoul Breastplate", t = { 1, 320, 330, 340 }, scroll = 19776, train = 300, scrollPrice = 50000, rep = { 270, 6 }, sq = 1, r = { { 12359, 20 }, { 19774, 10 }, { 19726, 2 }, { 7910, 2 } }, tool = 162, out = { 19690, 1 }, oq = 3 },
    [24137] = { name = "Bloodsoul Shoulders", t = { 1, 320, 330, 340 }, scroll = 19777, train = 300, scrollPrice = 50000, rep = { 270, 5 }, sq = 1, r = { { 12359, 16 }, { 19774, 8 }, { 19726, 2 }, { 7910, 1 } }, tool = 162, out = { 19691, 1 }, oq = 3 },
    [24138] = { name = "Bloodsoul Gauntlets", t = { 1, 320, 330, 340 }, scroll = 19778, train = 300, scrollPrice = 50000, rep = { 270, 4 }, sq = 1, r = { { 12359, 12 }, { 19774, 6 }, { 19726, 2 }, { 12810, 4 } }, tool = 162, out = { 19692, 1 }, oq = 3 },
    [24139] = { name = "Darksoul Breastplate", t = { 1, 320, 330, 340 }, scroll = 19779, train = 300, scrollPrice = 50000, rep = { 270, 6 }, sq = 1, r = { { 12359, 20 }, { 19774, 14 }, { 12799, 2 } }, tool = 162, out = { 19693, 1 }, oq = 3 },
    [24140] = { name = "Darksoul Leggings", t = { 1, 320, 330, 340 }, scroll = 19780, train = 300, scrollPrice = 50000, rep = { 270, 5 }, sq = 1, r = { { 12359, 18 }, { 19774, 12 }, { 12799, 2 } }, tool = 162, out = { 19694, 1 }, oq = 3 },
    [24141] = { name = "Darksoul Shoulders", t = { 1, 320, 330, 340 }, scroll = 19781, train = 300, scrollPrice = 50000, rep = { 270, 4 }, sq = 1, r = { { 12359, 16 }, { 19774, 10 }, { 12799, 1 } }, tool = 162, out = { 19695, 1 }, oq = 3 },
    [24399] = { name = "Dark Iron Boots", t = { 1, 320, 330, 340 }, scroll = 20040, train = 300, rep = { 59, 7 }, sq = 1, r = { { 17011, 3 }, { 17010, 3 }, { 17012, 4 }, { 11371, 6 } }, tool = 162, out = { 20039, 1 }, oq = 4 },
    [24912] = { name = "Darkrune Gauntlets", t = { 1, 320, 330, 340 }, scroll = 20553, train = 300, sq = 3, r = { { 12359, 12 }, { 20520, 6 }, { 6037, 6 }, { 12810, 2 } }, tool = 162, out = { 20549, 1 }, oq = 3 },
    [24913] = { name = "Darkrune Helm", t = { 1, 320, 330, 340 }, scroll = 20555, train = 300, sq = 3, r = { { 12359, 16 }, { 20520, 8 }, { 6037, 8 }, { 11754, 1 } }, tool = 162, out = { 20551, 1 }, oq = 3 },
    [24914] = { name = "Darkrune Breastplate", t = { 1, 320, 330, 340 }, scroll = 20554, train = 300, sq = 3, r = { { 12359, 20 }, { 20520, 10 }, { 6037, 10 } }, tool = 162, out = { 20550, 1 }, oq = 3 },
    [27585] = { name = "Heavy Obsidian Belt", t = { 1, 320, 330, 340 }, scroll = 22209, train = 310, sq = 1, r = { { 22202, 14 }, { 12655, 4 }, { 7076, 2 } }, tool = 162, out = { 22197, 1 }, oq = 3 },
    [27586] = { name = "Jagged Obsidian Shield", t = { 1, 320, 330, 340 }, scroll = 22219, train = 300, rep = { 609, 6 }, sq = 1, r = { { 22203, 8 }, { 22202, 24 }, { 12655, 8 }, { 7076, 4 } }, tool = 162, out = { 22198, 1 }, oq = 4 },
    [27587] = { name = "Thick Obsidian Breastplate", t = { 1, 320, 330, 340 }, scroll = 22222, train = 300, sq = 3, r = { { 22203, 18 }, { 22202, 40 }, { 12655, 12 }, { 7076, 10 }, { 12364, 4 } }, tool = 162, out = { 22196, 1 }, oq = 4 },
    [27588] = { name = "Light Obsidian Belt", t = { 1, 320, 330, 340 }, scroll = 22214, train = 310, sq = 1, r = { { 22202, 14 }, { 12810, 4 } }, tool = 162, out = { 22195, 1 }, oq = 3 },
    [27589] = { name = "Black Grasp of the Destroyer", t = { 1, 320, 330, 340 }, scroll = 22220, train = 300, sq = 3, r = { { 22203, 8 }, { 22202, 24 }, { 12810, 8 }, { 13512, 1 } }, tool = 162, out = { 22194, 1 }, oq = 4 },
    [27590] = { name = "Obsidian Mail Tunic", t = { 1, 320, 330, 340 }, scroll = 22221, train = 300, rep = { 609, 7 }, sq = 1, r = { { 22203, 15 }, { 22202, 36 }, { 12810, 12 }, { 12809, 10 }, { 12800, 4 } }, tool = 162, out = { 22191, 1 }, oq = 4 },
    [27829] = { name = "Titanic Leggings", t = { 1, 320, 330, 340 }, scroll = 22388, train = 300, sq = 4, r = { { 12360, 12 }, { 12655, 20 }, { 7076, 10 }, { 13510, 2 } }, tool = 162, out = { 22385, 1 }, oq = 4 },
    [27830] = { name = "Persuader", t = { 1, 320, 330, 340 }, scroll = 22390, train = 300, sq = 4, r = { { 12360, 15 }, { 11371, 10 }, { 12808, 20 }, { 20520, 20 }, { 15417, 10 }, { 12753, 2 } }, tool = 162, out = { 22384, 1 }, oq = 4 },
    [27832] = { name = "Sageblade", t = { 1, 320, 330, 340 }, scroll = 22389, train = 300, sq = 4, r = { { 12360, 12 }, { 20725, 2 }, { 13512, 2 }, { 12810, 4 } }, tool = 162, out = { 22383, 1 }, oq = 4 },
    [28242] = { name = "Icebane Breastplate", t = { 1, 320, 330, 340 }, scroll = 22703, train = 300, rep = { 529, 7 }, sq = 1, r = { { 22682, 7 }, { 12359, 16 }, { 12360, 2 }, { 7080, 4 } }, tool = 162, out = { 22669, 1 }, oq = 4 },
    [28243] = { name = "Icebane Gauntlets", t = { 1, 320, 330, 340 }, scroll = 22704, train = 300, rep = { 529, 6 }, sq = 1, r = { { 22682, 5 }, { 12359, 12 }, { 12360, 2 }, { 7080, 2 } }, tool = 162, out = { 22670, 1 }, oq = 4 },
    [28244] = { name = "Icebane Bracers", t = { 1, 320, 330, 340 }, scroll = 22705, train = 300, rep = { 749, 6 }, sq = 1, r = { { 22682, 4 }, { 12359, 12 }, { 12360, 2 }, { 7080, 2 } }, tool = 162, out = { 22671, 1 }, oq = 4 },
    [28461] = { name = "Ironvine Breastplate", t = { 1, 320, 330, 340 }, scroll = 22766, train = 310, sq = 1, r = { { 12655, 12 }, { 19726, 2 }, { 12360, 2 }, { 12803, 2 } }, tool = 162, out = { 22762, 1 }, oq = 1 },
    [28462] = { name = "Ironvine Gloves", t = { 1, 320, 330, 340 }, scroll = 22767, train = 310, sq = 1, r = { { 12655, 8 }, { 19726, 1 }, { 12803, 2 } }, tool = 162, out = { 22763, 1 }, oq = 1 },
    [28463] = { name = "Ironvine Belt", t = { 1, 320, 330, 340 }, scroll = 22768, train = 310, sq = 1, r = { { 12655, 6 }, { 12803, 2 } }, tool = 162, out = { 22764, 1 }, oq = 1 },
    [427061] = { name = "Mantle of the Second War", t = { 1, 140, 150, 160 }, scroll = 210779, train = 150, sq = 2, r = { { 2841, 20 }, { 1206, 2 }, { 1705, 2 }, { 5500, 2 }, { 2842, 4 } }, tool = 162, out = { 210773, 1 }, oq = 1 },
    [430397] = { name = "Blackfathom Sharpening Stone", t = { 1, 100, 110, 120 }, scroll = 211846, train = 90, sq = 1, r = { { 2863, 1 }, { 10938, 1 } }, out = { 211845, 1 }, oq = 2 },
    [435906] = { name = "Reflective Truesilver Braincage", t = { 1, 225, 230, 235 }, scroll = 215383, train = 225, sq = 4, r = { { 3860, 25 }, { 213376, 4 }, { 213379, 2 }, { 213383, 1 } }, tool = 162, out = { 215167, 1 }, oq = 1 },
    [435908] = { name = "Tempered Interference-Negating Helmet", t = { 1, 225, 230, 235 }, scroll = 215155, train = 225, sq = 4, r = { { 3860, 25 }, { 213376, 4 }, { 213379, 1 }, { 213369, 2 } }, tool = 162, out = { 215161, 1 }, oq = 1 },
    [435910] = { name = "Low-Background Truesilver Plates", t = { 1, 200, 210, 220 }, scroll = 215384, train = 200, sq = 3, r = { { 6037, 1 }, { 213373, 5 } }, tool = 162, out = { 213376, 1 }, oq = 3 },
    [461647] = { name = "Skyrider's Masterwork Stormhammer", t = { 1, 320, 330, 340 }, scroll = 227905, train = 300, sq = 3, r = { { 12794, 1 }, { 18262, 10 }, { 12360, 15 } }, tool = 162, out = { 227886, 1 }, oq = 1 },
    [461651] = { name = "Fiery Plate Gauntlets of the Hidden Technique", t = { 1, 310, 320, 330 }, scroll = 227909, train = 290, sq = 3, r = { { 12359, 20 }, { 12655, 6 }, { 7078, 2 }, { 7910, 4 } }, tool = 162, out = { 227865, 1 }, oq = 1 },
    [461667] = { name = "Tempered Dark Iron Plate", t = { 1, 305, 315, 325 }, scroll = 227901, train = 285, sq = 3, r = { { 11371, 20 }, { 7077, 8 } }, tool = 162, out = { 227871, 1 }, oq = 1 },
    [461669] = { name = "Refined Arcanite Champion", t = { 1, 320, 330, 340 }, scroll = 228117, train = 300, sq = 3, r = { { 12790, 1 }, { 18262, 10 } }, tool = 162, out = { 228125, 1 }, oq = 1 },
    [461671] = { name = "Stronger-hold Gauntlets", t = { 1, 320, 330, 340 }, scroll = 228250, train = 300, sq = 4, r = { { 12360, 15 }, { 12655, 20 }, { 7076, 10 }, { 12361, 4 }, { 12799, 4 } }, tool = 162, out = { 227885, 1 }, oq = 1 },
    [461675] = { name = "Refined Arcanite Reaper", t = { 1, 320, 330, 340 }, scroll = 228114, train = 300, sq = 3, r = { { 12784, 1 }, { 18262, 10 } }, tool = 162, out = { 227845, 1 }, oq = 1 },
    [461712] = { name = "Refined Hammer of the Titans", t = { 1, 320, 330, 340 }, scroll = 228305, train = 310, sq = 1, r = { { 12796, 1 }, { 18262, 10 } }, tool = 162, out = { 228230, 1 }, oq = 1 },
    [461714] = { name = "Desecration", t = { 1, 315, 327, 340 }, scroll = 228306, train = 305, sq = 1, r = { { 12359, 40 }, { 12360, 2 }, { 12662, 16 }, { 12808, 8 }, { 12361, 2 }, { 12644, 2 }, { 8170, 4 } }, tool = 162, out = { 227857, 1 }, oq = 1 },
    [461716] = { name = "Deadly Heartseeker", t = { 1, 320, 330, 340 }, scroll = 228307, train = 310, sq = 1, r = { { 12360, 10 }, { 12655, 10 }, { 12810, 2 }, { 7910, 6 }, { 12800, 6 }, { 12799, 6 }, { 12644, 4 } }, tool = 162, out = { 227884, 1 }, oq = 1 },
    [461718] = { name = "Tranquility", t = { 1, 310, 322, 335 }, scroll = 228308, train = 300, sq = 1, r = { { 12655, 6 }, { 12360, 2 }, { 12804, 4 }, { 12799, 2 }, { 12361, 2 }, { 12364, 1 } }, tool = 162, out = { 227881, 1 }, oq = 1 },
    [461730] = { name = "Hardened Frostguard", t = { 1, 320, 330, 340 }, scroll = 228310, train = 300, sq = 3, r = { { 12797, 1 }, { 18262, 10 } }, tool = 162, out = { 227887, 1 }, oq = 1 },
    [461733] = { name = "Finely-Enchanted Battlehammer", t = { 1, 305, 317, 330 }, scroll = 228311, train = 280, sq = 2, r = { { 12359, 20 }, { 12655, 6 }, { 12364, 2 }, { 12804, 4 }, { 8170, 4 } }, tool = 162, out = { 227880, 1 }, oq = 1 },
    [461735] = { name = "Invincible Mail", t = { 1, 320, 330, 340 }, scroll = 228312, train = 300, sq = 4, r = { { 12360, 30 }, { 12655, 30 }, { 12364, 6 }, { 12800, 6 } }, tool = 162, out = { 227876, 1 }, oq = 1 },
    [461737] = { name = "Tempest Gauntlets", t = { 1, 315, 325, 335 }, scroll = 228313, train = 295, sq = 3, r = { { 12359, 20 }, { 12655, 4 }, { 7080, 4 }, { 12361, 4 } }, tool = 162, out = { 227870, 1 }, oq = 1 },
    [461739] = { name = "Warcrest of the Great Chief", t = { 1, 320, 330, 340 }, scroll = 228314, train = 300, sq = 3, r = { { 12359, 40 }, { 12655, 4 }, { 8168, 60 }, { 12799, 6 }, { 12364, 2 } }, tool = 162, out = { 227872, 1 }, oq = 1 },
    [461743] = { name = "Sageblade of the Archmagus", t = { 1, 320, 330, 340 }, scroll = 228315, train = 300, sq = 4, r = { { 12360, 12 }, { 20725, 2 }, { 13512, 2 }, { 12810, 4 } }, tool = 162, out = { 227850, 1 }, oq = 1 },
    [1213643] = { name = "Obsidian Grinding Stone", t = { 1, 315, 322, 330 }, scroll = 234279, train = 305, sq = 1, r = { { 22202, 5 } }, tool = 162, out = { 234004, 1 }, oq = 1 },
    [1214309] = { name = "Dreamscale Visor", t = { 1, 320, 330, 340 }, scroll = 234488, train = 310, sq = 1, r = { { 12360, 20 }, { 12810, 4 }, { 8146, 8 }, { 20381, 8 }, { 12803, 4 } }, tool = 162, out = { 234487, 1 }, oq = 1 },
    [1224631] = { name = "Scarlet Soldier's Helmet", t = { 1, 285, 295, 305 }, scroll = 238322, train = 280, sq = 3, r = { { 12938, 1 }, { 12811, 2 }, { 12359, 24 } }, tool = 162, out = { 238288, 1 }, oq = 1 },
    [1224632] = { name = "Scarlet Soldier's Spaulders", t = { 1, 285, 295, 305 }, scroll = 238323, train = 280, sq = 3, r = { { 12811, 1 }, { 12359, 20 } }, tool = 162, out = { 238289, 1 }, oq = 1 },
    [1224633] = { name = "Scarlet Soldier's Chestplate", t = { 1, 285, 295, 305 }, scroll = 238324, train = 280, sq = 3, r = { { 12938, 1 }, { 12811, 1 }, { 12359, 24 } }, tool = 162, out = { 238290, 1 }, oq = 1 },
    [1224635] = { name = "Scarlet Soldier's Protectors", t = { 1, 260, 282, 305 }, scroll = 238325, train = 250, sq = 3, r = { { 12359, 16 } }, tool = 162, out = { 238291, 1 }, oq = 1 },
    [1224636] = { name = "Scarlet Soldier's Grips", t = { 1, 270, 287, 305 }, scroll = 238326, train = 260, sq = 3, r = { { 12811, 1 }, { 12359, 20 } }, tool = 162, out = { 238292, 1 }, oq = 1 },
    [1224637] = { name = "Scarlet Soldier's Waistguard", t = { 1, 260, 282, 305 }, scroll = 238327, train = 250, sq = 3, r = { { 12811, 1 }, { 12359, 20 } }, tool = 162, out = { 238293, 1 }, oq = 1 },
    [1224638] = { name = "Scarlet Soldier's Legplates", t = { 1, 280, 292, 305 }, scroll = 238328, train = 270, sq = 3, r = { { 12938, 1 }, { 12811, 1 }, { 12359, 20 } }, tool = 162, out = { 238294, 1 }, oq = 1 },
    [1224639] = { name = "Scarlet Soldier's Stompers", t = { 1, 270, 287, 305 }, scroll = 238329, train = 260, sq = 3, r = { { 12811, 1 }, { 12359, 20 } }, tool = 162, out = { 238295, 1 }, oq = 1 },
    [1230171] = { name = "Sharpening Wheel", t = { 1, 20, 22, 25 }, fee = 0, train = 20, r = { { 2835, 1 }, { 2840, 1 } }, out = { 279944, 1 }, oq = 1 },
    [1245287] = { name = "Copper Rod", t = { 1, 10, 12, 15 }, basic = true, r = { { 2840, 1 } }, tool = 162, out = { 6217, 1 }, oq = 1 },
    [1252232] = { name = "Sterling Silver Boots", t = { 1, 130, 145, 160 }, scroll = 251335, train = 100, sq = 2, r = { { 2842, 6 }, { 2840, 2 }, { 3478, 2 }, { 2319, 2 } }, tool = 162, out = { 250483, 1 }, oq = 2 },
    [1252233] = { name = "Sterling Silver Leggings", t = { 1, 135, 150, 165 }, scroll = 251336, train = 105, sq = 2, r = { { 2842, 10 }, { 2840, 3 }, { 3478, 3 } }, tool = 162, out = { 250484, 1 }, oq = 2 },
    [1252234] = { name = "Sterling Silver Gauntlet", t = { 1, 135, 150, 165 }, scroll = 251337, train = 105, sq = 2, r = { { 2842, 6 }, { 2840, 2 }, { 3478, 2 } }, tool = 162, out = { 250485, 1 }, oq = 2 },
    [1252235] = { name = "Sterling Silver Shoulders", t = { 1, 140, 155, 170 }, scroll = 251338, train = 110, sq = 2, r = { { 2842, 6 }, { 2840, 2 }, { 3478, 2 } }, tool = 162, out = { 250486, 1 }, oq = 2 },
    [1252236] = { name = "Sterling Silver Breastplate", t = { 1, 155, 170, 185 }, scroll = 251339, train = 125, sq = 2, r = { { 2842, 12 }, { 2840, 4 }, { 3478, 3 } }, tool = 162, out = { 250487, 1 }, oq = 2 },
    [1252252] = { name = "Veteran's Boots", t = { 1, 115, 130, 145 }, scroll = 251355, train = 85, sq = 3, favor = 30, r = { { 2841, 12 }, { 3478, 2 }, { 249427, 4 }, { 5498, 5 } }, tool = 162, out = { 250503, 1 }, oq = 3, bop = true },
    [1252253] = { name = "Guard's Boots", t = { 1, 115, 130, 145 }, scroll = 251356, train = 85, sq = 3, favor = 30, r = { { 2841, 12 }, { 3478, 2 }, { 249427, 4 }, { 1210, 5 } }, tool = 162, out = { 250504, 1 }, oq = 3, bop = true },
    [1252254] = { name = "Protector's Boots", t = { 1, 115, 130, 145 }, scroll = 251357, train = 85, sq = 3, favor = 30, r = { { 2841, 12 }, { 3478, 2 }, { 249427, 4 }, { 818, 5 } }, tool = 162, out = { 250505, 1 }, oq = 3, bop = true },
    [1252255] = { name = "Acolyte's Boots", t = { 1, 115, 130, 145 }, scroll = 251358, train = 85, sq = 3, favor = 30, r = { { 2841, 12 }, { 3478, 2 }, { 249427, 4 }, { 10940, 5 } }, tool = 162, out = { 250506, 1 }, oq = 3, bop = true },
    [1252256] = { name = "Crusader's Boots", t = { 1, 115, 130, 145 }, scroll = 251359, train = 85, sq = 3, favor = 30, r = { { 2841, 12 }, { 3478, 2 }, { 249427, 4 }, { 10938, 5 } }, tool = 162, out = { 250507, 1 }, oq = 3, bop = true },
    [1252257] = { name = "Veteran's Gloves", t = { 1, 110, 125, 140 }, scroll = 251360, train = 80, sq = 3, favor = 30, r = { { 2841, 10 }, { 3470, 4 }, { 249410, 2 }, { 5498, 3 } }, tool = 162, out = { 250508, 1 }, oq = 3, bop = true },
    [1252258] = { name = "Guard's Gloves", t = { 1, 110, 125, 140 }, scroll = 251361, train = 80, sq = 3, favor = 30, r = { { 2841, 10 }, { 3470, 4 }, { 249410, 2 }, { 1210, 3 } }, tool = 162, out = { 250509, 1 }, oq = 3, bop = true },
    [1252259] = { name = "Protector's Gloves", t = { 1, 110, 125, 140 }, scroll = 251362, train = 80, sq = 3, favor = 30, r = { { 2841, 10 }, { 3470, 4 }, { 249410, 2 }, { 818, 3 } }, tool = 162, out = { 250510, 1 }, oq = 3, bop = true },
    [1252260] = { name = "Acolyte's Gloves", t = { 1, 110, 125, 140 }, scroll = 251363, train = 80, sq = 3, favor = 30, r = { { 2841, 10 }, { 3470, 4 }, { 249410, 2 }, { 10940, 3 } }, tool = 162, out = { 250511, 1 }, oq = 3, bop = true },
    [1252261] = { name = "Crusader's Gloves", t = { 1, 110, 125, 140 }, scroll = 251364, train = 80, sq = 3, favor = 30, r = { { 2841, 10 }, { 3470, 4 }, { 249410, 2 }, { 10938, 3 } }, tool = 162, out = { 250512, 1 }, oq = 3, bop = true },
    [1252262] = { name = "Veteran's Chain Belt", t = { 1, 85, 105, 125 }, scroll = 251365, train = 45, sq = 3, favor = 30, r = { { 2840, 12 }, { 3470, 4 }, { 249427, 2 }, { 5498, 2 } }, tool = 162, out = { 250513, 1 }, oq = 3, bop = true },
    [1252263] = { name = "Guard's Chain Belt", t = { 1, 85, 105, 125 }, scroll = 251366, train = 45, sq = 3, favor = 30, r = { { 2840, 12 }, { 3470, 4 }, { 249427, 2 }, { 1210, 2 } }, tool = 162, out = { 250514, 1 }, oq = 3, bop = true },
    [1252264] = { name = "Protector's Chain Belt", t = { 1, 85, 105, 125 }, scroll = 251367, train = 45, sq = 3, favor = 30, r = { { 2840, 12 }, { 3470, 4 }, { 249427, 2 }, { 818, 2 } }, tool = 162, out = { 250515, 1 }, oq = 3, bop = true },
    [1252265] = { name = "Acolyte's Chain Belt", t = { 1, 85, 105, 125 }, scroll = 251368, train = 45, sq = 3, favor = 30, r = { { 2840, 12 }, { 3470, 4 }, { 249427, 2 }, { 10940, 2 } }, tool = 162, out = { 250516, 1 }, oq = 3, bop = true },
    [1252266] = { name = "Crusader's Chain Belt", t = { 1, 85, 105, 125 }, scroll = 251369, train = 45, sq = 3, favor = 30, r = { { 2840, 12 }, { 3470, 4 }, { 249427, 2 }, { 10938, 2 } }, tool = 162, out = { 250517, 1 }, oq = 3, bop = true },
    [1252267] = { name = "Veteran's Silvered Chain Shirt", t = { 1, 140, 155, 170 }, scroll = 251370, train = 110, sq = 3, favor = 30, r = { { 2841, 20 }, { 3478, 6 }, { 2842, 5 }, { 249427, 6 }, { 5498, 8 } }, tool = 162, out = { 250518, 1 }, oq = 3, bop = true },
    [1252268] = { name = "Guard's Silvered Chain Shirt", t = { 1, 140, 155, 170 }, scroll = 251371, train = 110, sq = 3, favor = 30, r = { { 2841, 20 }, { 3478, 6 }, { 2842, 5 }, { 249427, 6 }, { 1210, 8 } }, tool = 162, out = { 250519, 1 }, oq = 3, bop = true },
    [1252269] = { name = "Protector's Silvered Chain Shirt", t = { 1, 140, 155, 170 }, scroll = 251372, train = 110, sq = 3, favor = 30, r = { { 2841, 20 }, { 3478, 6 }, { 2842, 5 }, { 249427, 6 }, { 818, 8 } }, tool = 162, out = { 250520, 1 }, oq = 3, bop = true },
    [1252270] = { name = "Acolyte's Silvered Chain Shirt", t = { 1, 140, 155, 170 }, scroll = 251373, train = 110, sq = 3, favor = 30, r = { { 2841, 20 }, { 3478, 6 }, { 2842, 5 }, { 249427, 6 }, { 10940, 8 } }, tool = 162, out = { 250521, 1 }, oq = 3, bop = true },
    [1252271] = { name = "Crusader's Silvered Chain Shirt", t = { 1, 140, 155, 170 }, scroll = 251374, train = 110, sq = 3, favor = 30, r = { { 2841, 20 }, { 3478, 6 }, { 2842, 5 }, { 249427, 6 }, { 10938, 8 } }, tool = 162, out = { 250522, 1 }, oq = 3, bop = true },
    [1252272] = { name = "Veteran's Silvered Chain Leggings", t = { 1, 155, 170, 185 }, scroll = 251375, train = 125, sq = 3, favor = 30, r = { { 2841, 20 }, { 3478, 8 }, { 2842, 6 }, { 249427, 6 }, { 5498, 8 } }, tool = 162, out = { 250523, 1 }, oq = 3, bop = true },
    [1252273] = { name = "Guard's Silvered Chain Leggings", t = { 1, 155, 170, 185 }, scroll = 251376, train = 125, sq = 3, favor = 30, r = { { 2841, 20 }, { 3478, 8 }, { 2842, 6 }, { 249427, 6 }, { 1210, 8 } }, tool = 162, out = { 250524, 1 }, oq = 3, bop = true },
    [1252274] = { name = "Protector's Silvered Chain Leggings", t = { 1, 155, 170, 185 }, scroll = 251377, train = 125, sq = 3, favor = 30, r = { { 2841, 20 }, { 3478, 8 }, { 2842, 6 }, { 249427, 6 }, { 818, 8 } }, tool = 162, out = { 250525, 1 }, oq = 3, bop = true },
    [1252275] = { name = "Acolyte's Silvered Chain Leggings", t = { 1, 155, 170, 185 }, scroll = 251378, train = 125, sq = 3, favor = 30, r = { { 2841, 20 }, { 3478, 8 }, { 2842, 6 }, { 249427, 6 }, { 10940, 8 } }, tool = 162, out = { 250526, 1 }, oq = 3, bop = true },
    [1252276] = { name = "Crusader's Silvered Chain Leggings", t = { 1, 155, 170, 185 }, scroll = 251379, train = 125, sq = 3, favor = 30, r = { { 2841, 20 }, { 3478, 8 }, { 2842, 6 }, { 249427, 6 }, { 10938, 8 } }, tool = 162, out = { 250527, 1 }, oq = 3, bop = true },
    [1252277] = { name = "Veteran's Silvered Chain Helm", t = { 1, 125, 140, 155 }, scroll = 251380, train = 95, sq = 3, favor = 30, r = { { 2841, 15 }, { 3478, 6 }, { 2842, 4 }, { 249427, 4 }, { 5498, 6 } }, tool = 162, out = { 250528, 1 }, oq = 3, bop = true },
    [1252278] = { name = "Guard's Silvered Chain Helm", t = { 1, 125, 140, 155 }, scroll = 251381, train = 95, sq = 3, favor = 30, r = { { 2841, 15 }, { 3478, 6 }, { 2842, 4 }, { 249427, 4 }, { 1210, 6 } }, tool = 162, out = { 250529, 1 }, oq = 3, bop = true },
    [1252279] = { name = "Protector's Silvered Chain Helm", t = { 1, 125, 140, 155 }, scroll = 251382, train = 95, sq = 3, favor = 30, r = { { 2841, 15 }, { 3478, 6 }, { 2842, 4 }, { 249427, 4 }, { 818, 6 } }, tool = 162, out = { 250530, 1 }, oq = 3, bop = true },
    [1252280] = { name = "Acolyte's Silvered Chain Helm", t = { 1, 125, 140, 155 }, scroll = 251383, train = 95, sq = 3, favor = 30, r = { { 2841, 15 }, { 3478, 6 }, { 2842, 4 }, { 249427, 4 }, { 10940, 6 } }, tool = 162, out = { 250531, 1 }, oq = 3, bop = true },
    [1252281] = { name = "Crusader's Silvered Chain Helm", t = { 1, 125, 140, 155 }, scroll = 251384, train = 95, sq = 3, favor = 30, r = { { 2841, 15 }, { 3478, 6 }, { 2842, 4 }, { 249427, 4 }, { 10938, 6 } }, tool = 162, out = { 250532, 1 }, oq = 3, bop = true },
    [1252282] = { name = "Hard Gold Cuirass", t = { 1, 170, 182, 195 }, scroll = 251385, train = 145, sq = 2, r = { { 3577, 12 }, { 3859, 3 }, { 3486, 2 } }, tool = 162, out = { 250533, 1 }, oq = 2 },
    [1252283] = { name = "Hard Gold Boots", t = { 1, 175, 187, 200 }, scroll = 251386, train = 150, sq = 2, r = { { 3577, 6 }, { 3859, 2 }, { 3486, 2 }, { 4234, 2 } }, tool = 162, out = { 250534, 1 }, oq = 2 },
    [1252284] = { name = "Hard Gold Bracers", t = { 1, 185, 197, 210 }, scroll = 251387, train = 160, sq = 2, r = { { 3577, 6 }, { 3859, 1 }, { 3486, 2 } }, tool = 162, out = { 250535, 1 }, oq = 2 },
    [1252285] = { name = "Hard Gold Leggings", t = { 1, 190, 202, 215 }, scroll = 251388, train = 165, sq = 2, r = { { 3577, 10 }, { 3859, 2 }, { 3486, 2 } }, tool = 162, out = { 250536, 1 }, oq = 2 },
    [1252286] = { name = "Hard Gold Coif", t = { 1, 195, 207, 220 }, scroll = 251389, train = 170, sq = 2, r = { { 3577, 10 }, { 3859, 2 }, { 3486, 2 } }, tool = 162, out = { 250537, 1 }, oq = 2 },
    [1252287] = { name = "Hard Gold Gauntlet", t = { 1, 200, 212, 225 }, scroll = 251390, train = 175, scrollPrice = 6250, sq = 2, r = { { 3577, 8 }, { 3859, 2 }, { 3486, 2 } }, tool = 162, out = { 250538, 1 }, oq = 2 },
    [1252288] = { name = "Hard Gold Pauldrons", t = { 1, 200, 212, 225 }, scroll = 251391, train = 175, sq = 2, r = { { 3577, 8 }, { 3859, 2 }, { 3486, 2 } }, tool = 162, out = { 250539, 1 }, oq = 2 },
    [1252289] = { name = "Shining Mithril Breastplate", t = { 1, 215, 225, 235 }, scroll = 251392, train = 195, sq = 2, r = { { 3860, 8 }, { 6037, 9 }, { 3486, 2 }, { 7971, 2 } }, tool = 162, out = { 250540, 1 }, oq = 2 },
    [1252290] = { name = "Shining Mithril Pauldrons", t = { 1, 215, 225, 235 }, scroll = 251393, train = 195, sq = 2, r = { { 3860, 6 }, { 6037, 3 }, { 3486, 2 }, { 4304, 2 } }, tool = 162, out = { 250541, 1 }, oq = 2 },
    [1252291] = { name = "Shining Mithril Boots", t = { 1, 220, 230, 240 }, scroll = 251394, train = 200, sq = 2, r = { { 3860, 4 }, { 6037, 3 }, { 3486, 2 }, { 4304, 4 } }, tool = 162, out = { 250542, 1 }, oq = 2 },
    [1252292] = { name = "Shining Mithril Helm", t = { 1, 235, 245, 255 }, scroll = 251395, train = 215, sq = 3, r = { { 3860, 8 }, { 6037, 9 }, { 3486, 2 }, { 7075, 1 } }, tool = 162, out = { 250543, 1 }, oq = 2 },
    [1252293] = { name = "Shining Mithril Pants", t = { 1, 240, 250, 260 }, scroll = 251396, train = 220, sq = 2, r = { { 3860, 6 }, { 6037, 9 }, { 3486, 2 }, { 7075, 1 } }, tool = 162, out = { 250544, 1 }, oq = 2 },
    [1252294] = { name = "Shining Mithril Gauntlet", t = { 1, 240, 250, 260 }, scroll = 251397, train = 220, sq = 2, r = { { 3860, 5 }, { 6037, 6 }, { 3486, 2 }, { 7909, 2 } }, tool = 162, out = { 250545, 1 }, oq = 2 },
    [1252310] = { name = "Officer's Sabatons", t = { 1, 260, 270, 280 }, scroll = 251413, train = 240, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 20 }, { 7966, 3 }, { 249432, 4 }, { 249410, 4 }, { 1529, 6 }, { 249427, 4 } }, tool = 162, out = { 250561, 1 }, oq = 3, bop = true },
    [1252311] = { name = "Sentinel's Sabatons", t = { 1, 260, 270, 280 }, scroll = 251414, train = 240, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 20 }, { 7966, 3 }, { 249432, 4 }, { 249410, 4 }, { 8831, 6 }, { 249427, 4 } }, tool = 162, out = { 250562, 1 }, oq = 3, bop = true },
    [1252312] = { name = "Warder's Sabatons", t = { 1, 260, 270, 280 }, scroll = 251415, train = 240, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 20 }, { 7966, 3 }, { 249432, 4 }, { 249410, 4 }, { 7971, 6 }, { 249427, 4 } }, tool = 162, out = { 250563, 1 }, oq = 3, bop = true },
    [1252313] = { name = "Prefect's Sabatons", t = { 1, 260, 270, 280 }, scroll = 251416, train = 240, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 20 }, { 7966, 3 }, { 249432, 4 }, { 249410, 4 }, { 13926, 6 }, { 249427, 4 } }, tool = 162, out = { 250564, 1 }, oq = 3, bop = true },
    [1252314] = { name = "Justicar's Sabatons", t = { 1, 260, 270, 280 }, scroll = 251417, train = 240, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 20 }, { 7966, 3 }, { 249432, 4 }, { 249410, 4 }, { 7079, 6 }, { 249427, 4 } }, tool = 162, out = { 250565, 1 }, oq = 3, bop = true },
    [1252315] = { name = "Officer's Gauntlet", t = { 1, 200, 212, 225 }, scroll = 251418, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 3859, 10 }, { 3486, 4 }, { 249432, 4 }, { 249410, 2 }, { 1529, 4 } }, tool = 162, out = { 250566, 1 }, oq = 3, bop = true },
    [1252316] = { name = "Sentinel's Gauntlet", t = { 1, 200, 212, 225 }, scroll = 251419, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 3859, 10 }, { 3486, 4 }, { 249432, 4 }, { 249410, 2 }, { 8831, 4 } }, tool = 162, out = { 250567, 1 }, oq = 3, bop = true },
    [1252317] = { name = "Warder's Gauntlet", t = { 1, 200, 212, 225 }, scroll = 251420, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 3859, 10 }, { 3486, 4 }, { 249432, 4 }, { 249410, 2 }, { 7971, 4 } }, tool = 162, out = { 250568, 1 }, oq = 3, bop = true },
    [1252318] = { name = "Prefect's Gauntlet", t = { 1, 200, 212, 225 }, scroll = 251421, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 3859, 10 }, { 3486, 4 }, { 249432, 4 }, { 249410, 2 }, { 13926, 4 } }, tool = 162, out = { 250569, 1 }, oq = 3, bop = true },
    [1252319] = { name = "Justicar's Gauntlet", t = { 1, 200, 212, 225 }, scroll = 251422, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 3859, 10 }, { 3486, 4 }, { 249432, 4 }, { 249410, 2 }, { 7079, 4 } }, tool = 162, out = { 250570, 1 }, oq = 3, bop = true },
    [1252320] = { name = "Officer's Waistguard", t = { 1, 270, 280, 290 }, scroll = 251423, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 24 }, { 7966, 4 }, { 249432, 6 }, { 249410, 6 }, { 1529, 10 } }, tool = 162, out = { 250571, 1 }, oq = 3, bop = true },
    [1252321] = { name = "Sentinel's Waistguard", t = { 1, 270, 280, 290 }, scroll = 251424, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 24 }, { 7966, 4 }, { 249432, 6 }, { 249410, 6 }, { 8831, 10 } }, tool = 162, out = { 250572, 1 }, oq = 3, bop = true },
    [1252322] = { name = "Warder's Waistguard", t = { 1, 270, 280, 290 }, scroll = 251425, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 24 }, { 7966, 4 }, { 249432, 6 }, { 249410, 6 }, { 7971, 10 } }, tool = 162, out = { 250573, 1 }, oq = 3, bop = true },
    [1252323] = { name = "Prefect's Waistguard", t = { 1, 270, 280, 290 }, scroll = 251426, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 24 }, { 7966, 4 }, { 249432, 6 }, { 249410, 6 }, { 13926, 10 } }, tool = 162, out = { 250574, 1 }, oq = 3, bop = true },
    [1252324] = { name = "Justicar's Waistguard", t = { 1, 270, 280, 290 }, scroll = 251427, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 24 }, { 7966, 4 }, { 249432, 6 }, { 249410, 6 }, { 7079, 10 } }, tool = 162, out = { 250575, 1 }, oq = 3, bop = true },
    [1252325] = { name = "Officer's Pauldrons", t = { 1, 230, 240, 250 }, scroll = 251428, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 3860, 20 }, { 7966, 2 }, { 249432, 6 }, { 249410, 4 }, { 1529, 8 }, { 11139, 1 } }, tool = 162, out = { 250576, 1 }, oq = 3, bop = true },
    [1252326] = { name = "Sentinel's Pauldrons", t = { 1, 230, 240, 250 }, scroll = 251429, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 3860, 20 }, { 7966, 2 }, { 249432, 6 }, { 249410, 4 }, { 8831, 8 }, { 11139, 1 } }, tool = 162, out = { 250577, 1 }, oq = 3, bop = true },
    [1252327] = { name = "Warder's Pauldrons", t = { 1, 230, 240, 250 }, scroll = 251430, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 3860, 20 }, { 7966, 2 }, { 249432, 6 }, { 249410, 4 }, { 7971, 8 }, { 11139, 1 } }, tool = 162, out = { 250578, 1 }, oq = 3, bop = true },
    [1252328] = { name = "Prefect's Pauldrons", t = { 1, 230, 240, 250 }, scroll = 251431, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 3860, 20 }, { 7966, 2 }, { 249432, 6 }, { 249410, 4 }, { 13926, 8 }, { 11139, 1 } }, tool = 162, out = { 250579, 1 }, oq = 3, bop = true },
    [1252329] = { name = "Justicar's Pauldrons", t = { 1, 230, 240, 250 }, scroll = 251432, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 3860, 20 }, { 7966, 2 }, { 249432, 6 }, { 249410, 4 }, { 7079, 8 }, { 11139, 1 } }, tool = 162, out = { 250580, 1 }, oq = 3, bop = true },
    [1252330] = { name = "Officer's Wristguards", t = { 1, 250, 262, 275 }, scroll = 251433, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 16 }, { 7966, 2 }, { 249432, 6 }, { 249410, 4 }, { 1529, 6 }, { 11139, 1 } }, tool = 162, out = { 250581, 1 }, oq = 3, bop = true },
    [1252331] = { name = "Sentinel's Wristguards", t = { 1, 250, 262, 275 }, scroll = 251434, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 16 }, { 7966, 2 }, { 249432, 6 }, { 249410, 4 }, { 8831, 6 }, { 11139, 1 } }, tool = 162, out = { 250582, 1 }, oq = 3, bop = true },
    [1252332] = { name = "Warder's Wristguards", t = { 1, 250, 262, 275 }, scroll = 251435, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 16 }, { 7966, 2 }, { 249432, 6 }, { 249410, 4 }, { 7971, 6 }, { 11139, 1 } }, tool = 162, out = { 250583, 1 }, oq = 3, bop = true },
    [1252333] = { name = "Prefect's Wristguards", t = { 1, 250, 262, 275 }, scroll = 251436, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 16 }, { 7966, 2 }, { 249432, 6 }, { 249410, 4 }, { 13926, 6 }, { 11139, 1 } }, tool = 162, out = { 250584, 1 }, oq = 3, bop = true },
    [1252334] = { name = "Justicar's Wristguards", t = { 1, 250, 262, 275 }, scroll = 251437, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 16 }, { 7966, 2 }, { 249432, 6 }, { 249410, 4 }, { 7079, 6 }, { 11139, 1 } }, tool = 162, out = { 250585, 1 }, oq = 3, bop = true },
    [1252335] = { name = "Blessed Plate Pauldrons", t = { 1, 260, 270, 280 }, scroll = 251438, train = 240, sq = 2, r = { { 12359, 20 }, { 12361, 1 }, { 8170, 6 } }, tool = 162, out = { 250586, 1 }, oq = 2 },
    [1252336] = { name = "Blessed Plate Boots", t = { 1, 260, 270, 280 }, scroll = 251439, train = 240, sq = 2, r = { { 12359, 24 }, { 12361, 1 }, { 8170, 6 } }, tool = 162, out = { 250587, 1 }, oq = 2 },
    [1252337] = { name = "Blessed Plate Gauntlet", t = { 1, 265, 275, 285 }, scroll = 251440, train = 245, sq = 2, r = { { 12359, 20 }, { 12361, 2 } }, tool = 162, out = { 250588, 1 }, oq = 2 },
    [1252338] = { name = "Imperial Plate Gauntlets", t = { 1, 275, 285, 295 }, scroll = 251441, train = 255, sq = 2, r = { { 12359, 24 }, { 7910, 1 } }, tool = 162, out = { 250589, 1 }, oq = 2 },
    [1252339] = { name = "Blessed Plate Bracers", t = { 1, 275, 285, 295 }, scroll = 251442, train = 255, sq = 2, r = { { 12359, 16 }, { 12361, 1 } }, tool = 162, out = { 250590, 1 }, oq = 2 },
    [1252340] = { name = "Blessed Plate Leggings", t = { 1, 290, 300, 310 }, scroll = 251443, train = 270, sq = 2, r = { { 12359, 40 }, { 12361, 2 } }, tool = 162, out = { 250591, 1 }, oq = 2 },
    [1252341] = { name = "Blessed Plate Belt", t = { 1, 290, 300, 310 }, scroll = 251444, train = 270, sq = 2, r = { { 12359, 18 }, { 12361, 1 }, { 7071, 1 }, { 8170, 6 } }, tool = 162, out = { 250592, 1 }, oq = 2 },
    [1252342] = { name = "Blessed Plate Helm", t = { 1, 295, 305, 315 }, scroll = 251445, train = 275, sq = 2, r = { { 12359, 30 }, { 12361, 2 } }, tool = 162, out = { 250593, 1 }, oq = 2 },
    [1252343] = { name = "Blessed Plate Chest", t = { 1, 300, 310, 320 }, scroll = 251446, train = 280, sq = 2, r = { { 12359, 36 }, { 12361, 2 } }, tool = 162, out = { 250594, 1 }, oq = 2 },
    [1252344] = { name = "Enriched Thorium Breastplate", t = { 1, 320, 330, 340 }, scroll = 251447, train = 300, sq = 3, favor = 120, favorRep = 6, r = { { 251290, 8 }, { 251291, 24 }, { 7082, 4 }, { 7078, 4 }, { 249726, 4 } }, tool = 162, out = { 250595, 1 }, oq = 3, bop = true },
    [1252345] = { name = "Enriched Thorium Leggings", t = { 1, 320, 330, 340 }, scroll = 251448, train = 300, sq = 3, favor = 120, favorRep = 6, r = { { 251290, 10 }, { 251291, 20 }, { 7082, 6 }, { 249726, 3 } }, tool = 162, out = { 250596, 1 }, oq = 3, bop = true },
    [1252346] = { name = "Enriched Thorium Helm", t = { 1, 320, 330, 340 }, scroll = 251449, train = 300, sq = 3, favor = 120, favorRep = 6, r = { { 251290, 6 }, { 251291, 16 }, { 7078, 6 }, { 249726, 3 } }, tool = 162, out = { 250597, 1 }, oq = 3, bop = true },
    [1252347] = { name = "Champion's Legplates", t = { 1, 320, 330, 340 }, scroll = 251450, train = 300, sq = 4, r = { { 251290, 12 }, { 251291, 20 }, { 7082, 10 }, { 13512, 2 } }, tool = 162, out = { 250598, 1 }, oq = 4 },
    [1252348] = { name = "Stalwart Helm", t = { 1, 320, 330, 340 }, scroll = 251451, train = 300, sq = 4, r = { { 251290, 12 }, { 12359, 80 }, { 7910, 10 }, { 12800, 4 }, { 7971, 20 } }, tool = 162, out = { 250599, 1 }, oq = 4 },
    [1252349] = { name = "Martyr's Legplates", t = { 1, 320, 330, 340 }, scroll = 251452, train = 300, sq = 4, r = { { 251290, 12 }, { 251291, 20 }, { 7078, 10 }, { 13511, 2 } }, tool = 162, out = { 250600, 1 }, oq = 4 },
    [1252350] = { name = "Breastplate of Salvation", t = { 1, 320, 330, 340 }, scroll = 251453, train = 300, sq = 4, r = { { 251290, 12 }, { 12359, 80 }, { 12361, 10 }, { 12800, 4 }, { 12662, 20 } }, tool = 162, out = { 250601, 1 }, oq = 4 },
    [1252351] = { name = "Brass Knuckles", t = { 1, 110, 125, 140 }, scroll = 251454, train = 80, sq = 2, r = { { 2841, 6 }, { 2880, 4 }, { 3470, 2 }, { 1210, 2 }, { 2319, 1 } }, tool = 162, out = { 250602, 1 }, oq = 2 },
    [1252352] = { name = "Bronze Dory", t = { 1, 125, 140, 155 }, scroll = 251455, train = 95, sq = 2, r = { { 2841, 8 }, { 2880, 4 }, { 2319, 1 } }, tool = 162, out = { 250603, 1 }, oq = 2 },
    [1252353] = { name = "Iron Fists", t = { 1, 155, 167, 180 }, scroll = 251456, train = 130, sq = 2, r = { { 3575, 6 }, { 3466, 2 }, { 3486, 1 }, { 2842, 2 }, { 4234, 2 } }, tool = 162, out = { 250604, 1 }, oq = 2 },
    [1252354] = { name = "Steel Spear", t = { 1, 185, 197, 210 }, scroll = 251457, train = 160, sq = 2, r = { { 3859, 10 }, { 3466, 2 }, { 7069, 1 }, { 3486, 4 }, { 4234, 1 } }, tool = 162, out = { 250605, 1 }, oq = 2 },
    [1252355] = { name = "Iron Morningstar", t = { 1, 190, 202, 215 }, scroll = 251458, train = 165, scrollPrice = 6000, sq = 2, r = { { 3575, 14 }, { 3466, 2 }, { 3486, 2 }, { 3864, 4 }, { 4234, 2 } }, tool = 162, out = { 250606, 1 }, oq = 2 },
    [1252356] = { name = "Mithril Shortsword", t = { 1, 200, 210, 220 }, scroll = 251459, train = 180, sq = 2, r = { { 3860, 8 }, { 3466, 2 }, { 3486, 2 }, { 1705, 4 }, { 4234, 2 } }, tool = 162, out = { 250607, 1 }, oq = 2 },
    [1252357] = { name = "Mithril Warhammer", t = { 1, 210, 220, 230 }, scroll = 251460, train = 190, scrollPrice = 7500, sq = 2, r = { { 3860, 12 }, { 3864, 2 }, { 7966, 1 }, { 4234, 4 } }, tool = 162, out = { 250608, 1 }, oq = 2 },
    [1252358] = { name = "Mithril Claws", t = { 1, 215, 225, 235 }, scroll = 251461, train = 195, sq = 2, r = { { 3860, 8 }, { 1529, 1 }, { 7966, 1 }, { 4234, 2 } }, tool = 162, out = { 250609, 1 }, oq = 2 },
    [1252359] = { name = "Mithril Claymore", t = { 1, 215, 225, 235 }, scroll = 251462, train = 195, sq = 2, r = { { 3860, 16 }, { 3577, 6 }, { 7966, 2 }, { 4234, 4 } }, tool = 162, out = { 250610, 1 }, oq = 2 },
    [1252360] = { name = "Mithril Stiletto", t = { 1, 230, 240, 250 }, scroll = 251463, train = 210, sq = 2, r = { { 3860, 16 }, { 1210, 6 }, { 3577, 2 }, { 7966, 1 } }, tool = 162, out = { 250611, 1 }, oq = 2 },
    [1252361] = { name = "Charged Mithril Battleaxe", t = { 1, 235, 245, 255 }, scroll = 251464, train = 215, sq = 2, r = { { 3860, 20 }, { 7082, 6 }, { 7966, 4 }, { 4234, 4 } }, tool = 162, out = { 250612, 1 }, oq = 2 },
    [1252362] = { name = "Thorium Greatmace", t = { 1, 270, 280, 290 }, scroll = 251465, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 30 }, { 251291, 4 }, { 7076, 4 }, { 249726, 10 }, { 12644, 2 } }, tool = 162, out = { 250613, 1 }, oq = 3, bop = true },
    [1252363] = { name = "Thorium Cestus", t = { 1, 270, 280, 290 }, scroll = 251466, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 12359, 20 }, { 251291, 8 }, { 7082, 4 }, { 249726, 10 }, { 12644, 1 } }, tool = 162, out = { 250614, 1 }, oq = 3, bop = true },
    [1252364] = { name = "Thorium Poleaxe", t = { 1, 280, 292, 305 }, scroll = 251467, train = 260, sq = 3, r = { { 12359, 20 }, { 251291, 6 }, { 249726, 10 }, { 12803, 4 }, { 8170, 4 } }, tool = 162, out = { 250615, 1 }, oq = 3 },
    [1252365] = { name = "Bold Dirk", t = { 1, 290, 300, 310 }, scroll = 251468, train = 270, scrollPrice = 100000, sq = 3, r = { { 12359, 30 }, { 7082, 4 }, { 249726, 10 }, { 8170, 4 } }, tool = 162, out = { 250616, 1 }, oq = 2 },
    [1252366] = { name = "Stormcarver", t = { 1, 320, 330, 340 }, scroll = 251469, train = 300, rep = { 576, 6 }, sq = 3, r = { { 251290, 20 }, { 249726, 10 }, { 12644, 2 } }, tool = 162, out = { 250617, 1 }, oq = 3 },
    [1252367] = { name = "Bagh Nakh", t = { 1, 320, 330, 340 }, scroll = 251470, train = 300, rep = { 576, 6 }, sq = 3, r = { { 251290, 10 }, { 251291, 10 }, { 249726, 10 }, { 7910, 4 }, { 12361, 4 } }, tool = 162, out = { 250618, 1 }, oq = 3 },
    [1252368] = { name = "Legionite Glaive", t = { 1, 320, 330, 340 }, scroll = 251471, train = 300, sq = 3, favor = 120, favorRep = 6, r = { { 251290, 15 }, { 251291, 8 }, { 249726, 10 }, { 248820, 4 }, { 248822, 1 } }, tool = 162, out = { 250619, 1 }, oq = 3, bop = true },
    [1263041] = { name = "Anvil", t = { 1, 140, 142, 145 }, scroll = 273086, train = 140, sq = 2, r = { { 2841, 5 }, { 3478, 2 }, { 2319, 2 } }, out = { 279988, 1 }, oq = 1 },
    [1292945] = { name = "Justice Leggings", t = { 1, 320, 325, 330 }, scroll = 273976, train = 300, sq = 4, r = { { 274030, 5 }, { 12360, 4 }, { 251291, 18 }, { 18567, 1 } }, tool = 162, out = { 273908, 1 }, oq = 1 },
    [1292946] = { name = "Justice Gauntlets", t = { 1, 320, 325, 330 }, scroll = 273977, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273909, 1 }, oq = 1 },
    [1292947] = { name = "Justice Spaulders", t = { 1, 320, 325, 330 }, scroll = 273978, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273910, 1 }, oq = 1 },
    [1292948] = { name = "Justice Greaves", t = { 1, 320, 325, 330 }, scroll = 273979, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273911, 1 }, oq = 1 },
    [1292949] = { name = "Justice Legplates", t = { 1, 320, 325, 330 }, scroll = 273980, train = 300, sq = 4, r = { { 274030, 5 }, { 12360, 4 }, { 251291, 18 }, { 18567, 1 } }, tool = 162, out = { 273912, 1 }, oq = 1 },
    [1292950] = { name = "Justice Gloves", t = { 1, 320, 325, 330 }, scroll = 273981, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273913, 1 }, oq = 1 },
    [1292951] = { name = "Justice Epaulets", t = { 1, 320, 325, 330 }, scroll = 273982, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273914, 1 }, oq = 1 },
    [1292952] = { name = "Justice Treads", t = { 1, 320, 325, 330 }, scroll = 273983, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273915, 1 }, oq = 1 },
    [1292953] = { name = "Justice Legguards", t = { 1, 320, 325, 330 }, scroll = 273984, train = 300, sq = 4, r = { { 274030, 5 }, { 12360, 4 }, { 251291, 18 }, { 18567, 1 } }, tool = 162, out = { 273916, 1 }, oq = 1 },
    [1292954] = { name = "Justice Handguards", t = { 1, 320, 325, 330 }, scroll = 273985, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273917, 1 }, oq = 1 },
    [1292955] = { name = "Justice Pauldrons", t = { 1, 320, 325, 330 }, scroll = 273986, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273918, 1 }, oq = 1 },
    [1292956] = { name = "Justice Sabatons", t = { 1, 320, 325, 330 }, scroll = 273987, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273919, 1 }, oq = 1 },
    [1292981] = { name = "Legplates of Glory", t = { 1, 320, 325, 330 }, scroll = 274012, train = 300, sq = 4, r = { { 274030, 5 }, { 12360, 4 }, { 251291, 18 }, { 18567, 1 } }, tool = 162, out = { 273944, 1 }, oq = 1 },
    [1292982] = { name = "Gauntlets of Glory", t = { 1, 320, 325, 330 }, scroll = 274013, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273945, 1 }, oq = 1 },
    [1292983] = { name = "Shoulders of Glory", t = { 1, 320, 325, 330 }, scroll = 274014, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273946, 1 }, oq = 1 },
    [1292984] = { name = "Greaves of Glory", t = { 1, 320, 325, 330 }, scroll = 274015, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273947, 1 }, oq = 1 },
    [1292985] = { name = "Legguards of Glory", t = { 1, 320, 325, 330 }, scroll = 274016, train = 300, sq = 4, r = { { 274030, 5 }, { 12360, 4 }, { 251291, 18 }, { 18567, 1 } }, tool = 162, out = { 273948, 1 }, oq = 1 },
    [1292986] = { name = "Handguards of Glory", t = { 1, 320, 325, 330 }, scroll = 274017, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273949, 1 }, oq = 1 },
    [1292987] = { name = "Pauldrons of Glory", t = { 1, 320, 325, 330 }, scroll = 274018, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273950, 1 }, oq = 1 },
    [1292988] = { name = "Sabatons of Glory", t = { 1, 320, 325, 330 }, scroll = 274019, train = 300, sq = 4, r = { { 274030, 3 }, { 12360, 2 }, { 251291, 12 }, { 18567, 1 } }, tool = 162, out = { 273951, 1 }, oq = 1 },
    [1297138] = { name = "Goregasher Grips", t = { 1, 290, 292, 295 }, scroll = 275598, train = 285, scrollPrice = 75000, rep = { 609, 4 }, sq = 3, r = { { 12359, 7 }, { 12655, 5 }, { 7078, 3 }, { 18567, 1 } }, tool = 162, out = { 275622, 1 }, oq = 3 },
    [1297139] = { name = "Goregasher Support", t = { 1, 295, 297, 300 }, scroll = 275599, train = 290, scrollPrice = 75000, rep = { 609, 5 }, sq = 3, r = { { 12359, 11 }, { 12655, 5 }, { 7078, 3 }, { 18567, 1 } }, tool = 162, out = { 275623, 1 }, oq = 3 },
    [1297140] = { name = "Goregasher Stompers", t = { 1, 295, 297, 300 }, scroll = 275600, train = 295, scrollPrice = 75000, rep = { 609, 5 }, sq = 3, r = { { 12359, 9 }, { 12655, 5 }, { 7078, 3 }, { 18567, 1 } }, tool = 162, out = { 275624, 1 }, oq = 3 },
    [1297141] = { name = "Clutchlord's Grips", t = { 1, 290, 292, 295 }, scroll = 275601, train = 285, scrollPrice = 75000, rep = { 609, 4 }, sq = 3, r = { { 12359, 7 }, { 12655, 5 }, { 7076, 3 }, { 18567, 1 } }, tool = 162, out = { 275625, 1 }, oq = 3 },
    [1297142] = { name = "Clutchlord's Support", t = { 1, 295, 297, 300 }, scroll = 275602, train = 290, scrollPrice = 75000, rep = { 609, 5 }, sq = 3, r = { { 12359, 11 }, { 12655, 5 }, { 7076, 3 }, { 18567, 1 } }, tool = 162, out = { 275626, 1 }, oq = 3 },
    [1297143] = { name = "Clutchlord's Stompers", t = { 1, 295, 297, 300 }, scroll = 275603, train = 295, scrollPrice = 75000, rep = { 609, 5 }, sq = 3, r = { { 12359, 9 }, { 12655, 5 }, { 7076, 3 }, { 18567, 1 } }, tool = 162, out = { 275627, 1 }, oq = 3 },
    [1301421] = { name = "Cloudy Skyforged Chainmail", t = { 1, 65, 67, 70 }, scroll = 276928, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2840, 8 }, { 2880, 1 } }, out = { 276992, 1 }, oq = 2 },
    [1301422] = { name = "Cloudy Skyforged Wristguards", t = { 1, 55, 57, 60 }, scroll = 276929, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2840, 5 } }, tool = 162, out = { 276993, 1 }, oq = 2 },
    [1301423] = { name = "Cloudy Skyforged Gauntlets", t = { 1, 60, 62, 65 }, scroll = 276930, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2840, 7 } }, tool = 162, out = { 276994, 1 }, oq = 2 },
    [1301424] = { name = "Cloudy Skyforged Chain", t = { 1, 55, 57, 60 }, scroll = 276931, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2840, 6 } }, tool = 162, out = { 276995, 1 }, oq = 2 },
    [1301425] = { name = "Cloudy Skyforged Legguards", t = { 1, 65, 67, 70 }, scroll = 276932, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2840, 8 }, { 2880, 1 } }, tool = 162, out = { 276996, 1 }, oq = 2 },
    [1301426] = { name = "Cloudy Skyforged Greaves", t = { 1, 60, 62, 65 }, scroll = 276933, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2840, 7 } }, tool = 162, out = { 276997, 1 }, oq = 2 },
    [1301445] = { name = "Azure Skyforged Chainmail", t = { 1, 65, 67, 70 }, scroll = 276952, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2840, 8 }, { 2880, 1 } }, tool = 162, out = { 277016, 1 }, oq = 2 },
    [1301446] = { name = "Azure Skyforged Wristguards", t = { 1, 55, 57, 60 }, scroll = 276953, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2840, 5 } }, tool = 162, out = { 277017, 1 }, oq = 2 },
    [1301447] = { name = "Azure Skyforged Gauntlets", t = { 1, 60, 62, 65 }, scroll = 276954, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2840, 7 } }, tool = 162, out = { 277018, 1 }, oq = 2 },
    [1301448] = { name = "Azure Skyforged Chain", t = { 1, 55, 57, 60 }, scroll = 276955, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2840, 6 } }, tool = 162, out = { 277019, 1 }, oq = 2 },
    [1301449] = { name = "Azure Skyforged Legguards", t = { 1, 65, 67, 70 }, scroll = 276956, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2840, 8 }, { 2880, 1 } }, tool = 162, out = { 277020, 1 }, oq = 2 },
    [1301450] = { name = "Azure Skyforged Greaves", t = { 1, 60, 62, 65 }, scroll = 276957, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2840, 7 } }, tool = 162, out = { 277021, 1 }, oq = 2 },
    [1301526] = { name = "Cloudy Skyforged Helm", t = { 1, 185, 187, 190 }, scroll = 276976, train = 175, scrollPrice = 100000, rep = { 2787, 4 }, sq = 2, r = { { 3575, 18 }, { 3486, 5 }, { 5498, 1 } }, tool = 162, out = { 277040, 1 }, oq = 2 },
    [1301527] = { name = "Cloudy Skyforged Pauldrons", t = { 1, 185, 187, 190 }, scroll = 276977, train = 175, scrollPrice = 100000, rep = { 2787, 4 }, sq = 2, r = { { 3575, 14 }, { 3486, 3 }, { 5498, 1 } }, tool = 162, out = { 277041, 1 }, oq = 2 },
    [1301534] = { name = "Azure Skyforged Helm", t = { 1, 185, 187, 190 }, scroll = 276984, train = 175, scrollPrice = 100000, rep = { 2740, 4 }, sq = 2, r = { { 3575, 18 }, { 3486, 5 }, { 7909, 1 } }, tool = 162, out = { 277048, 1 }, oq = 2 },
    [1301535] = { name = "Azure Skyforged Pauldrons", t = { 1, 185, 187, 190 }, scroll = 276985, train = 175, scrollPrice = 100000, rep = { 2740, 4 }, sq = 2, r = { { 3575, 14 }, { 3486, 3 }, { 7909, 1 } }, tool = 162, out = { 277049, 1 }, oq = 2 },
    [1302598] = { name = "Rough Copper Chain Boots", t = { 1, 60, 65, 70 }, scroll = 277673, train = 50, sq = 2, r = { { 2840, 9 } }, tool = 162, out = { 277672, 1 }, oq = 2 },
    [1306533] = { name = "Ironwood Blade", t = { 1, 310, 317, 325 }, scroll = 279308, train = 300, sq = 4, r = { { 274030, 2 }, { 251290, 1 }, { 251291, 14 } }, tool = 162, out = { 279259, 1 }, oq = 4 },
    [1306534] = { name = "Forest Defender's Axe", t = { 1, 310, 317, 325 }, scroll = 279309, train = 300, sq = 4, r = { { 274030, 4 }, { 251290, 1 }, { 251291, 20 } }, tool = 162, out = { 279260, 1 }, oq = 4 },
    [1306535] = { name = "Greenhammer", t = { 1, 310, 317, 325 }, scroll = 279310, train = 300, sq = 4, r = { { 274030, 2 }, { 251290, 1 }, { 251291, 16 } }, tool = 162, out = { 279261, 1 }, oq = 4 },
    [1306536] = { name = "Evergreen Shield", t = { 1, 310, 317, 325 }, scroll = 279311, train = 300, sq = 4, r = { { 274030, 2 }, { 251290, 1 }, { 251291, 10 } }, tool = 162, out = { 279262, 1 }, oq = 4 },
    [1306537] = { name = "Depleted Thorium Sabatons", t = { 1, 310, 317, 325 }, scroll = 279312, train = 300, sq = 4, r = { { 274030, 2 }, { 251290, 1 }, { 251291, 12 } }, tool = 162, out = { 279263, 1 }, oq = 4 },
    [1306538] = { name = "Heavy Thorium Gauntlets", t = { 1, 310, 317, 325 }, scroll = 279313, train = 300, sq = 4, r = { { 274030, 2 }, { 251290, 1 }, { 251291, 14 } }, tool = 162, out = { 279264, 1 }, oq = 4 },
    [1306539] = { name = "Azerothium Legplates", t = { 1, 310, 317, 325 }, scroll = 279314, train = 300, sq = 4, r = { { 274030, 3 }, { 251290, 1 }, { 251291, 18 } }, tool = 162, out = { 279265, 1 }, oq = 4 },
    [1317962] = { name = "Cracked Blacksmith Hammer", t = { 1, 115, 117, 120 }, scroll = 285289, train = 110, scrollPrice = 5000, sq = 2, r = { { 2841, 18 }, { 2842, 2 }, { 818, 1 } }, out = { 285279, 1 }, oq = 2, bop = true },
    [1317963] = { name = "Mithril Blacksmith Hammer", t = { 1, 200, 202, 205 }, scroll = 285290, train = 195, scrollPrice = 5000, sq = 2, r = { { 3860, 10 }, { 3577, 2 }, { 7910, 1 } }, out = { 285280, 1 }, oq = 2, bop = true },
    [1317964] = { name = "Arcanite Blacksmith Hammer", t = { 1, 275, 277, 280 }, scroll = 285291, train = 270, scrollPrice = 5000, sq = 3, r = { { 11371, 4 }, { 12360, 1 }, { 12361, 1 } }, out = { 285281, 1 }, oq = 3, bop = true },
    [2662] = { name = "Copper Chain Pants", t = { 40, 50, 70, 90 }, fee = 50, train = 15, r = { { 2840, 4 } }, tool = 162, out = { 2852, 1 }, oq = 2 },
    [2739] = { name = "Copper Shortsword", t = { 40, 65, 85, 105 }, fee = 50, train = 25, r = { { 2840, 6 }, { 2880, 1 }, { 2589, 2 } }, tool = 162, out = { 2847, 1 }, oq = 2 },
    [2665] = { name = "Coarse Sharpening Stone", t = { 75, 40, 47, 55 }, fee = 100, train = 40, r = { { 2836, 1 } }, out = { 2863, 1 }, oq = 1 },
    [2740] = { name = "Bronze Mace", t = { 75, 115, 130, 145 }, fee = 200, train = 85, r = { { 2841, 6 }, { 2880, 4 }, { 2319, 1 } }, tool = 162, out = { 2848, 1 }, oq = 2 },
    [2666] = { name = "Runed Copper Belt", t = { 80, 85, 105, 125 }, fee = 200, train = 45, r = { { 2840, 10 } }, tool = 162, out = { 2857, 1 }, oq = 2 },
    [2741] = { name = "Bronze Axe", t = { 85, 120, 135, 150 }, fee = 200, train = 90, r = { { 2841, 7 }, { 2880, 4 }, { 2319, 1 } }, tool = 162, out = { 2849, 1 }, oq = 2 },
    [2667] = { name = "Runed Copper Breastplate", t = { 90, 95, 115, 135 }, scroll = 2881, train = 55, sq = 2, r = { { 2840, 12 }, { 1210, 1 }, { 3470, 2 } }, tool = 162, out = { 2864, 1 }, oq = 2 },
    [2668] = { name = "Rough Bronze Leggings", t = { 95, 120, 135, 150 }, fee = 300, train = 80, r = { { 2841, 6 } }, tool = 162, out = { 2865, 1 }, oq = 2 },
    [2742] = { name = "Bronze Shortsword", t = { 95, 125, 140, 155 }, fee = 200, train = 95, r = { { 2841, 5 }, { 2880, 4 }, { 2319, 2 } }, tool = 162, out = { 2850, 1 }, oq = 2 },
    [2670] = { name = "Rough Bronze Cuirass", t = { 105, 120, 135, 150 }, fee = 500, train = 80, r = { { 2841, 7 } }, tool = 162, out = { 2866, 1 }, oq = 2 },
    [2672] = { name = "Patterned Bronze Bracers", t = { 120, 125, 140, 155 }, fee = 500, train = 95, r = { { 2841, 5 }, { 3478, 2 } }, tool = 162, out = { 2868, 1 }, oq = 2 },
    [2674] = { name = "Heavy Sharpening Stone", t = { 125, 100, 107, 115 }, fee = 1000, train = 100, r = { { 2838, 1 } }, out = { 2871, 1 }, oq = 1 },
    [2675] = { name = "Shining Silver Breastplate", t = { 135, 150, 165, 180 }, fee = 1000, train = 120, r = { { 2841, 20 }, { 1206, 2 }, { 1705, 2 }, { 5500, 2 }, { 2842, 4 } }, tool = 162, out = { 2870, 1 }, oq = 3 },
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
ES.Data.VendorPrices[2320] = 10
ES.Data.VendorPrices[2605] = 100
ES.Data.VendorPrices[2880] = 100
ES.Data.VendorPrices[3466] = 2000
ES.Data.VendorPrices[5956] = 18
ES.Data.VendorPrices[6217] = 124
ES.Data.VendorPrices[10938] = 800
ES.Data.VendorPrices[10940] = 800
ES.Data.VendorPrices[18567] = 150000
ES.Data.SellPrices[774] = 15
ES.Data.SellPrices[818] = 100
ES.Data.SellPrices[1206] = 400
ES.Data.SellPrices[1210] = 250
ES.Data.SellPrices[1529] = 700
ES.Data.SellPrices[1705] = 600
ES.Data.SellPrices[2318] = 15
ES.Data.SellPrices[2319] = 50
ES.Data.SellPrices[2320] = 2
ES.Data.SellPrices[2459] = 25
ES.Data.SellPrices[2589] = 13
ES.Data.SellPrices[2605] = 25
ES.Data.SellPrices[2835] = 2
ES.Data.SellPrices[2836] = 15
ES.Data.SellPrices[2838] = 60
ES.Data.SellPrices[2840] = 10
ES.Data.SellPrices[2841] = 50
ES.Data.SellPrices[2842] = 100
ES.Data.SellPrices[2844] = 106
ES.Data.SellPrices[2845] = 109
ES.Data.SellPrices[2847] = 110
ES.Data.SellPrices[2848] = 898
ES.Data.SellPrices[2849] = 917
ES.Data.SellPrices[2850] = 1136
ES.Data.SellPrices[2851] = 56
ES.Data.SellPrices[2852] = 67
ES.Data.SellPrices[2853] = 17
ES.Data.SellPrices[2854] = 225
ES.Data.SellPrices[2857] = 198
ES.Data.SellPrices[2862] = 3
ES.Data.SellPrices[2863] = 10
ES.Data.SellPrices[2864] = 630
ES.Data.SellPrices[2865] = 577
ES.Data.SellPrices[2866] = 601
ES.Data.SellPrices[2867] = 317
ES.Data.SellPrices[2868] = 507
ES.Data.SellPrices[2869] = 1831
ES.Data.SellPrices[2870] = 2935
ES.Data.SellPrices[2871] = 40
ES.Data.SellPrices[2880] = 25
ES.Data.SellPrices[3239] = 3
ES.Data.SellPrices[3240] = 10
ES.Data.SellPrices[3241] = 40
ES.Data.SellPrices[3391] = 20
ES.Data.SellPrices[3466] = 500
ES.Data.SellPrices[3469] = 49
ES.Data.SellPrices[3470] = 5
ES.Data.SellPrices[3471] = 142
ES.Data.SellPrices[3472] = 71
ES.Data.SellPrices[3473] = 299
ES.Data.SellPrices[3474] = 216
ES.Data.SellPrices[3478] = 10
ES.Data.SellPrices[3480] = 532
ES.Data.SellPrices[3481] = 916
ES.Data.SellPrices[3482] = 918
ES.Data.SellPrices[3483] = 965
ES.Data.SellPrices[3484] = 1767
ES.Data.SellPrices[3485] = 1295
ES.Data.SellPrices[3486] = 100
ES.Data.SellPrices[3487] = 1135
ES.Data.SellPrices[3488] = 480
ES.Data.SellPrices[3489] = 715
ES.Data.SellPrices[3490] = 2044
ES.Data.SellPrices[3491] = 2741
ES.Data.SellPrices[3492] = 4552
ES.Data.SellPrices[3575] = 200
ES.Data.SellPrices[3577] = 600
ES.Data.SellPrices[3823] = 100
ES.Data.SellPrices[3824] = 150
ES.Data.SellPrices[3829] = 150
ES.Data.SellPrices[3835] = 1106
ES.Data.SellPrices[3836] = 3053
ES.Data.SellPrices[3837] = 3084
ES.Data.SellPrices[3840] = 2571
ES.Data.SellPrices[3841] = 3106
ES.Data.SellPrices[3842] = 2906
ES.Data.SellPrices[3843] = 3882
ES.Data.SellPrices[3844] = 5658
ES.Data.SellPrices[3845] = 6558
ES.Data.SellPrices[3846] = 3937
ES.Data.SellPrices[3847] = 4977
ES.Data.SellPrices[3848] = 915
ES.Data.SellPrices[3849] = 5468
ES.Data.SellPrices[3850] = 7304
ES.Data.SellPrices[3851] = 6258
ES.Data.SellPrices[3852] = 8360
ES.Data.SellPrices[3853] = 8615
ES.Data.SellPrices[3854] = 8860
ES.Data.SellPrices[3855] = 11248
ES.Data.SellPrices[3856] = 10386
ES.Data.SellPrices[3859] = 60
ES.Data.SellPrices[3860] = 400
ES.Data.SellPrices[3864] = 800
ES.Data.SellPrices[4234] = 150
ES.Data.SellPrices[4255] = 2366
ES.Data.SellPrices[4304] = 300
ES.Data.SellPrices[4338] = 250
ES.Data.SellPrices[5498] = 200
ES.Data.SellPrices[5500] = 750
ES.Data.SellPrices[5540] = 2107
ES.Data.SellPrices[5541] = 3693
ES.Data.SellPrices[5635] = 45
ES.Data.SellPrices[5637] = 75
ES.Data.SellPrices[5956] = 3
ES.Data.SellPrices[5966] = 1374
ES.Data.SellPrices[6037] = 1250
ES.Data.SellPrices[6040] = 1315
ES.Data.SellPrices[6041] = 1500
ES.Data.SellPrices[6042] = 250
ES.Data.SellPrices[6043] = 500
ES.Data.SellPrices[6214] = 466
ES.Data.SellPrices[6217] = 24
ES.Data.SellPrices[6338] = 125
ES.Data.SellPrices[6350] = 295
ES.Data.SellPrices[6730] = 298
ES.Data.SellPrices[6731] = 690
ES.Data.SellPrices[6733] = 1145
ES.Data.SellPrices[7067] = 400
ES.Data.SellPrices[7068] = 400
ES.Data.SellPrices[7069] = 400
ES.Data.SellPrices[7070] = 400
ES.Data.SellPrices[7071] = 100
ES.Data.SellPrices[7075] = 400
ES.Data.SellPrices[7076] = 400
ES.Data.SellPrices[7077] = 400
ES.Data.SellPrices[7078] = 400
ES.Data.SellPrices[7079] = 400
ES.Data.SellPrices[7080] = 400
ES.Data.SellPrices[7081] = 400
ES.Data.SellPrices[7082] = 400
ES.Data.SellPrices[7166] = 194
ES.Data.SellPrices[7909] = 1000
ES.Data.SellPrices[7910] = 5000
ES.Data.SellPrices[7912] = 100
ES.Data.SellPrices[7913] = 2500
ES.Data.SellPrices[7914] = 3330
ES.Data.SellPrices[7915] = 3337
ES.Data.SellPrices[7916] = 3700
ES.Data.SellPrices[7917] = 2711
ES.Data.SellPrices[7918] = 3701
ES.Data.SellPrices[7919] = 2476
ES.Data.SellPrices[7920] = 8053
ES.Data.SellPrices[7921] = 5387
ES.Data.SellPrices[7922] = 1944
ES.Data.SellPrices[7924] = 4103
ES.Data.SellPrices[7925] = 4447
ES.Data.SellPrices[7926] = 5952
ES.Data.SellPrices[7927] = 2987
ES.Data.SellPrices[7928] = 4857
ES.Data.SellPrices[7929] = 7739
ES.Data.SellPrices[7930] = 7045
ES.Data.SellPrices[7931] = 7955
ES.Data.SellPrices[7932] = 8661
ES.Data.SellPrices[7933] = 5769
ES.Data.SellPrices[7934] = 5790
ES.Data.SellPrices[7935] = 8368
ES.Data.SellPrices[7936] = 6739
ES.Data.SellPrices[7937] = 6763
ES.Data.SellPrices[7938] = 4028
ES.Data.SellPrices[7939] = 10899
ES.Data.SellPrices[7941] = 12520
ES.Data.SellPrices[7942] = 14659
ES.Data.SellPrices[7943] = 15891
ES.Data.SellPrices[7944] = 14671
ES.Data.SellPrices[7945] = 17291
ES.Data.SellPrices[7946] = 14460
ES.Data.SellPrices[7947] = 24892
ES.Data.SellPrices[7954] = 23159
ES.Data.SellPrices[7955] = 241
ES.Data.SellPrices[7956] = 1544
ES.Data.SellPrices[7957] = 2205
ES.Data.SellPrices[7958] = 2435
ES.Data.SellPrices[7959] = 33857
ES.Data.SellPrices[7960] = 38548
ES.Data.SellPrices[7961] = 25508
ES.Data.SellPrices[7963] = 5615
ES.Data.SellPrices[7964] = 40
ES.Data.SellPrices[7965] = 40
ES.Data.SellPrices[7966] = 200
ES.Data.SellPrices[7967] = 250
ES.Data.SellPrices[7969] = 250
ES.Data.SellPrices[7971] = 1000
ES.Data.SellPrices[7972] = 400
ES.Data.SellPrices[8146] = 500
ES.Data.SellPrices[8153] = 5
ES.Data.SellPrices[8168] = 100
ES.Data.SellPrices[8170] = 500
ES.Data.SellPrices[8831] = 300
ES.Data.SellPrices[9060] = 1000
ES.Data.SellPrices[9366] = 3689
ES.Data.SellPrices[10421] = 32
ES.Data.SellPrices[10423] = 2366
ES.Data.SellPrices[10938] = 1
ES.Data.SellPrices[10940] = 1
ES.Data.SellPrices[11128] = 500
ES.Data.SellPrices[11139] = 1
ES.Data.SellPrices[11144] = 1000
ES.Data.SellPrices[11371] = 600
ES.Data.SellPrices[11382] = 750
ES.Data.SellPrices[11604] = 19428
ES.Data.SellPrices[11605] = 10776
ES.Data.SellPrices[11606] = 19255
ES.Data.SellPrices[11607] = 51225
ES.Data.SellPrices[11608] = 45760
ES.Data.SellPrices[12259] = 8072
ES.Data.SellPrices[12260] = 8165
ES.Data.SellPrices[12359] = 600
ES.Data.SellPrices[12360] = 5000
ES.Data.SellPrices[12361] = 7000
ES.Data.SellPrices[12364] = 10000
ES.Data.SellPrices[12365] = 250
ES.Data.SellPrices[12404] = 75
ES.Data.SellPrices[12405] = 9239
ES.Data.SellPrices[12406] = 4636
ES.Data.SellPrices[12408] = 4998
ES.Data.SellPrices[12409] = 10336
ES.Data.SellPrices[12410] = 10372
ES.Data.SellPrices[12414] = 17376
ES.Data.SellPrices[12415] = 17003
ES.Data.SellPrices[12416] = 7595
ES.Data.SellPrices[12417] = 17034
ES.Data.SellPrices[12418] = 10242
ES.Data.SellPrices[12419] = 16421
ES.Data.SellPrices[12420] = 25330
ES.Data.SellPrices[12422] = 16204
ES.Data.SellPrices[12424] = 5533
ES.Data.SellPrices[12425] = 6044
ES.Data.SellPrices[12426] = 12062
ES.Data.SellPrices[12427] = 12106
ES.Data.SellPrices[12428] = 8646
ES.Data.SellPrices[12429] = 17923
ES.Data.SellPrices[12610] = 12247
ES.Data.SellPrices[12611] = 12293
ES.Data.SellPrices[12612] = 12956
ES.Data.SellPrices[12613] = 18205
ES.Data.SellPrices[12614] = 18272
ES.Data.SellPrices[12618] = 23972
ES.Data.SellPrices[12619] = 24058
ES.Data.SellPrices[12620] = 17245
ES.Data.SellPrices[12625] = 13080
ES.Data.SellPrices[12631] = 8919
ES.Data.SellPrices[12633] = 14859
ES.Data.SellPrices[12639] = 15271
ES.Data.SellPrices[12640] = 21894
ES.Data.SellPrices[12643] = 75
ES.Data.SellPrices[12644] = 200
ES.Data.SellPrices[12645] = 500
ES.Data.SellPrices[12655] = 500
ES.Data.SellPrices[12662] = 600
ES.Data.SellPrices[12764] = 23534
ES.Data.SellPrices[12769] = 46154
ES.Data.SellPrices[12772] = 38871
ES.Data.SellPrices[12773] = 33079
ES.Data.SellPrices[12774] = 36044
ES.Data.SellPrices[12775] = 39949
ES.Data.SellPrices[12776] = 48124
ES.Data.SellPrices[12777] = 38648
ES.Data.SellPrices[12781] = 42721
ES.Data.SellPrices[12782] = 56808
ES.Data.SellPrices[12783] = 58215
ES.Data.SellPrices[12784] = 73036
ES.Data.SellPrices[12790] = 74619
ES.Data.SellPrices[12792] = 39255
ES.Data.SellPrices[12794] = 56304
ES.Data.SellPrices[12795] = 48821
ES.Data.SellPrices[12796] = 70912
ES.Data.SellPrices[12797] = 56943
ES.Data.SellPrices[12798] = 57150
ES.Data.SellPrices[12799] = 7000
ES.Data.SellPrices[12800] = 10000
ES.Data.SellPrices[12802] = 62625
ES.Data.SellPrices[12803] = 500
ES.Data.SellPrices[12804] = 2000
ES.Data.SellPrices[12808] = 1000
ES.Data.SellPrices[12809] = 10000
ES.Data.SellPrices[12810] = 500
ES.Data.SellPrices[12811] = 20000
ES.Data.SellPrices[13510] = 5000
ES.Data.SellPrices[13511] = 5000
ES.Data.SellPrices[13512] = 5000
ES.Data.SellPrices[13926] = 10000
ES.Data.SellPrices[15417] = 500
ES.Data.SellPrices[15869] = 50
ES.Data.SellPrices[15870] = 300
ES.Data.SellPrices[15871] = 625
ES.Data.SellPrices[15872] = 625
ES.Data.SellPrices[16206] = 1000
ES.Data.SellPrices[16988] = 31460
ES.Data.SellPrices[16989] = 18610
ES.Data.SellPrices[17010] = 2000
ES.Data.SellPrices[17011] = 2000
ES.Data.SellPrices[17012] = 1000
ES.Data.SellPrices[17013] = 26441
ES.Data.SellPrices[17014] = 12637
ES.Data.SellPrices[17015] = 63738
ES.Data.SellPrices[17016] = 63973
ES.Data.SellPrices[17193] = 122311
ES.Data.SellPrices[17203] = 100000
ES.Data.SellPrices[17704] = 9178
ES.Data.SellPrices[18262] = 1250
ES.Data.SellPrices[18567] = 37500
ES.Data.SellPrices[19051] = 9365
ES.Data.SellPrices[19057] = 11606
ES.Data.SellPrices[19148] = 25399
ES.Data.SellPrices[19164] = 22425
ES.Data.SellPrices[19166] = 92896
ES.Data.SellPrices[19167] = 116531
ES.Data.SellPrices[19168] = 102890
ES.Data.SellPrices[19169] = 129112
ES.Data.SellPrices[19170] = 103689
ES.Data.SellPrices[19690] = 39683
ES.Data.SellPrices[19691] = 30000
ES.Data.SellPrices[19692] = 19980
ES.Data.SellPrices[19693] = 24192
ES.Data.SellPrices[19694] = 24286
ES.Data.SellPrices[19695] = 18285
ES.Data.SellPrices[19726] = 500
ES.Data.SellPrices[19774] = 5000
ES.Data.SellPrices[20039] = 31709
ES.Data.SellPrices[20381] = 5000
ES.Data.SellPrices[20520] = 2000
ES.Data.SellPrices[20549] = 11484
ES.Data.SellPrices[20550] = 23051
ES.Data.SellPrices[20551] = 17352
ES.Data.SellPrices[20725] = 1
ES.Data.SellPrices[22191] = 73128
ES.Data.SellPrices[22194] = 33521
ES.Data.SellPrices[22195] = 22885
ES.Data.SellPrices[22196] = 49624
ES.Data.SellPrices[22197] = 14282
ES.Data.SellPrices[22198] = 67440
ES.Data.SellPrices[22202] = 2500
ES.Data.SellPrices[22203] = 5000
ES.Data.SellPrices[22383] = 84291
ES.Data.SellPrices[22384] = 80554
ES.Data.SellPrices[22385] = 25276
ES.Data.SellPrices[22669] = 68390
ES.Data.SellPrices[22670] = 34321
ES.Data.SellPrices[22671] = 34452
ES.Data.SellPrices[22682] = 20000
ES.Data.SellPrices[211845] = 125
ES.Data.SellPrices[213369] = 280
ES.Data.SellPrices[213379] = 280
ES.Data.SellPrices[248820] = 15000
ES.Data.SellPrices[248822] = 1500
ES.Data.SellPrices[249410] = 125
ES.Data.SellPrices[249427] = 125
ES.Data.SellPrices[249432] = 250
ES.Data.SellPrices[249726] = 3000
ES.Data.SellPrices[250483] = 1267
ES.Data.SellPrices[250484] = 1908
ES.Data.SellPrices[250485] = 957
ES.Data.SellPrices[250486] = 490
ES.Data.SellPrices[250487] = 485
ES.Data.SellPrices[250503] = 1054
ES.Data.SellPrices[250504] = 1057
ES.Data.SellPrices[250505] = 1061
ES.Data.SellPrices[250506] = 1065
ES.Data.SellPrices[250507] = 1069
ES.Data.SellPrices[250508] = 487
ES.Data.SellPrices[250509] = 489
ES.Data.SellPrices[250510] = 504
ES.Data.SellPrices[250511] = 506
ES.Data.SellPrices[250512] = 508
ES.Data.SellPrices[250513] = 335
ES.Data.SellPrices[250514] = 336
ES.Data.SellPrices[250515] = 337
ES.Data.SellPrices[250516] = 339
ES.Data.SellPrices[250517] = 340
ES.Data.SellPrices[250518] = 2464
ES.Data.SellPrices[250519] = 2473
ES.Data.SellPrices[250520] = 2482
ES.Data.SellPrices[250521] = 2491
ES.Data.SellPrices[250522] = 2500
ES.Data.SellPrices[250523] = 3340
ES.Data.SellPrices[250524] = 3352
ES.Data.SellPrices[250525] = 3363
ES.Data.SellPrices[250526] = 3137
ES.Data.SellPrices[250527] = 3149
ES.Data.SellPrices[250528] = 1439
ES.Data.SellPrices[250529] = 1444
ES.Data.SellPrices[250530] = 1450
ES.Data.SellPrices[250531] = 1455
ES.Data.SellPrices[250532] = 1460
ES.Data.SellPrices[250533] = 3929
ES.Data.SellPrices[250534] = 3268
ES.Data.SellPrices[250535] = 2634
ES.Data.SellPrices[250536] = 5711
ES.Data.SellPrices[250537] = 5036
ES.Data.SellPrices[250538] = 3354
ES.Data.SellPrices[250539] = 5073
ES.Data.SellPrices[250540] = 11586
ES.Data.SellPrices[250541] = 8704
ES.Data.SellPrices[250542] = 8110
ES.Data.SellPrices[250543] = 10255
ES.Data.SellPrices[250544] = 14716
ES.Data.SellPrices[250545] = 7428
ES.Data.SellPrices[250561] = 15856
ES.Data.SellPrices[250562] = 15918
ES.Data.SellPrices[250563] = 15979
ES.Data.SellPrices[250564] = 16041
ES.Data.SellPrices[250565] = 16101
ES.Data.SellPrices[250566] = 3850
ES.Data.SellPrices[250567] = 3864
ES.Data.SellPrices[250568] = 3878
ES.Data.SellPrices[250569] = 3893
ES.Data.SellPrices[250570] = 3908
ES.Data.SellPrices[250571] = 13177
ES.Data.SellPrices[250572] = 13225
ES.Data.SellPrices[250573] = 13274
ES.Data.SellPrices[250574] = 13677
ES.Data.SellPrices[250575] = 13726
ES.Data.SellPrices[250576] = 12276
ES.Data.SellPrices[250577] = 12320
ES.Data.SellPrices[250578] = 12364
ES.Data.SellPrices[250579] = 12408
ES.Data.SellPrices[250580] = 12450
ES.Data.SellPrices[250581] = 9390
ES.Data.SellPrices[250582] = 9426
ES.Data.SellPrices[250583] = 9462
ES.Data.SellPrices[250584] = 9498
ES.Data.SellPrices[250585] = 9535
ES.Data.SellPrices[250586] = 13467
ES.Data.SellPrices[250587] = 13517
ES.Data.SellPrices[250588] = 10241
ES.Data.SellPrices[250589] = 12244
ES.Data.SellPrices[250590] = 12621
ES.Data.SellPrices[250591] = 28034
ES.Data.SellPrices[250592] = 14148
ES.Data.SellPrices[250593] = 22196
ES.Data.SellPrices[250594] = 31247
ES.Data.SellPrices[250595] = 39509
ES.Data.SellPrices[250596] = 41634
ES.Data.SellPrices[250597] = 31277
ES.Data.SellPrices[250598] = 50706
ES.Data.SellPrices[250599] = 38092
ES.Data.SellPrices[250600] = 51067
ES.Data.SellPrices[250601] = 46368
ES.Data.SellPrices[250602] = 1562
ES.Data.SellPrices[250603] = 488
ES.Data.SellPrices[250604] = 4754
ES.Data.SellPrices[250605] = 2501
ES.Data.SellPrices[250606] = 9416
ES.Data.SellPrices[250607] = 11906
ES.Data.SellPrices[250608] = 4356
ES.Data.SellPrices[250609] = 4079
ES.Data.SellPrices[250610] = 20470
ES.Data.SellPrices[250611] = 4133
ES.Data.SellPrices[250612] = 10273
ES.Data.SellPrices[250613] = 48384
ES.Data.SellPrices[250614] = 38843
ES.Data.SellPrices[250615] = 54752
ES.Data.SellPrices[250616] = 40772
ES.Data.SellPrices[250617] = 74598
ES.Data.SellPrices[250618] = 59891
ES.Data.SellPrices[250619] = 75130
ES.Data.SellPrices[251290] = 5000
ES.Data.SellPrices[251291] = 1500
ES.Data.SellPrices[275622] = 15752
ES.Data.SellPrices[275623] = 15809
ES.Data.SellPrices[275624] = 23622
ES.Data.SellPrices[275625] = 15927
ES.Data.SellPrices[275626] = 15986
ES.Data.SellPrices[275627] = 23882
ES.Data.SellPrices[277672] = 49
ES.Data.SellPrices[279259] = 10484
ES.Data.SellPrices[279260] = 5062
ES.Data.SellPrices[279261] = 53222
ES.Data.SellPrices[279262] = 19893
ES.Data.SellPrices[279263] = 13732
ES.Data.SellPrices[279264] = 13149
ES.Data.SellPrices[279265] = 13732
ES.Data.SellPrices[285279] = 1411
ES.Data.SellPrices[285280] = 7658
ES.Data.SellPrices[285281] = 26186

-- Nombre de cada objeto (inglés, del cliente): se muestra mientras el juego no lo ha cargado
ES.Data.ItemNames = ES.Data.ItemNames or {}
ES.Data.ItemNames[774] = "Malachite"
ES.Data.ItemNames[818] = "Tigerseye"
ES.Data.ItemNames[1206] = "Moss Agate"
ES.Data.ItemNames[1210] = "Shadowgem"
ES.Data.ItemNames[1529] = "Jade"
ES.Data.ItemNames[1705] = "Lesser Moonstone"
ES.Data.ItemNames[2318] = "Light Leather"
ES.Data.ItemNames[2319] = "Medium Leather"
ES.Data.ItemNames[2320] = "Coarse Thread"
ES.Data.ItemNames[2459] = "Swiftness Potion"
ES.Data.ItemNames[2589] = "Linen Cloth"
ES.Data.ItemNames[2605] = "Green Dye"
ES.Data.ItemNames[2835] = "Rough Stone"
ES.Data.ItemNames[2836] = "Coarse Stone"
ES.Data.ItemNames[2838] = "Heavy Stone"
ES.Data.ItemNames[2840] = "Copper Bar"
ES.Data.ItemNames[2841] = "Bronze Bar"
ES.Data.ItemNames[2842] = "Silver Bar"
ES.Data.ItemNames[2844] = "Copper Mace"
ES.Data.ItemNames[2845] = "Copper Axe"
ES.Data.ItemNames[2847] = "Copper Shortsword"
ES.Data.ItemNames[2848] = "Bronze Mace"
ES.Data.ItemNames[2849] = "Bronze Axe"
ES.Data.ItemNames[2850] = "Bronze Shortsword"
ES.Data.ItemNames[2851] = "Copper Chain Belt"
ES.Data.ItemNames[2852] = "Copper Chain Pants"
ES.Data.ItemNames[2853] = "Copper Bracers"
ES.Data.ItemNames[2854] = "Runed Copper Bracers"
ES.Data.ItemNames[2857] = "Runed Copper Belt"
ES.Data.ItemNames[2862] = "Rough Sharpening Stone"
ES.Data.ItemNames[2863] = "Coarse Sharpening Stone"
ES.Data.ItemNames[2864] = "Runed Copper Breastplate"
ES.Data.ItemNames[2865] = "Rough Bronze Leggings"
ES.Data.ItemNames[2866] = "Rough Bronze Cuirass"
ES.Data.ItemNames[2867] = "Rough Bronze Bracers"
ES.Data.ItemNames[2868] = "Patterned Bronze Bracers"
ES.Data.ItemNames[2869] = "Silvered Bronze Breastplate"
ES.Data.ItemNames[2870] = "Shining Silver Breastplate"
ES.Data.ItemNames[2871] = "Heavy Sharpening Stone"
ES.Data.ItemNames[2880] = "Weak Flux"
ES.Data.ItemNames[3239] = "Rough Weightstone"
ES.Data.ItemNames[3240] = "Coarse Weightstone"
ES.Data.ItemNames[3241] = "Heavy Weightstone"
ES.Data.ItemNames[3391] = "Elixir of Ogre Strength"
ES.Data.ItemNames[3466] = "Strong Flux"
ES.Data.ItemNames[3469] = "Copper Chain Boots"
ES.Data.ItemNames[3470] = "Rough Grinding Stone"
ES.Data.ItemNames[3471] = "Copper Chain Vest"
ES.Data.ItemNames[3472] = "Runed Copper Gauntlets"
ES.Data.ItemNames[3473] = "Runed Copper Pants"
ES.Data.ItemNames[3474] = "Gemmed Copper Gauntlets"
ES.Data.ItemNames[3478] = "Coarse Grinding Stone"
ES.Data.ItemNames[3480] = "Rough Bronze Shoulders"
ES.Data.ItemNames[3481] = "Silvered Bronze Shoulders"
ES.Data.ItemNames[3482] = "Silvered Bronze Boots"
ES.Data.ItemNames[3483] = "Silvered Bronze Gauntlets"
ES.Data.ItemNames[3484] = "Green Iron Boots"
ES.Data.ItemNames[3485] = "Green Iron Gauntlets"
ES.Data.ItemNames[3486] = "Heavy Grinding Stone"
ES.Data.ItemNames[3487] = "Heavy Copper Broadsword"
ES.Data.ItemNames[3488] = "Copper Battle Axe"
ES.Data.ItemNames[3489] = "Thick War Axe"
ES.Data.ItemNames[3490] = "Deadly Bronze Poniard"
ES.Data.ItemNames[3491] = "Heavy Bronze Mace"
ES.Data.ItemNames[3492] = "Mighty Iron Hammer"
ES.Data.ItemNames[3575] = "Iron Bar"
ES.Data.ItemNames[3577] = "Gold Bar"
ES.Data.ItemNames[3823] = "Lesser Invisibility Potion"
ES.Data.ItemNames[3824] = "Shadow Oil"
ES.Data.ItemNames[3829] = "Frost Oil"
ES.Data.ItemNames[3835] = "Green Iron Bracers"
ES.Data.ItemNames[3836] = "Green Iron Helm"
ES.Data.ItemNames[3837] = "Golden Scale Coif"
ES.Data.ItemNames[3840] = "Green Iron Shoulders"
ES.Data.ItemNames[3841] = "Golden Scale Shoulders"
ES.Data.ItemNames[3842] = "Green Iron Leggings"
ES.Data.ItemNames[3843] = "Golden Scale Leggings"
ES.Data.ItemNames[3844] = "Green Iron Hauberk"
ES.Data.ItemNames[3845] = "Golden Scale Cuirass"
ES.Data.ItemNames[3846] = "Polished Steel Boots"
ES.Data.ItemNames[3847] = "Golden Scale Boots"
ES.Data.ItemNames[3848] = "Big Bronze Knife"
ES.Data.ItemNames[3849] = "Hardened Iron Shortsword"
ES.Data.ItemNames[3850] = "Jade Serpentblade"
ES.Data.ItemNames[3851] = "Solid Iron Maul"
ES.Data.ItemNames[3852] = "Golden Iron Destroyer"
ES.Data.ItemNames[3853] = "Moonsteel Broadsword"
ES.Data.ItemNames[3854] = "Frost Tiger Blade"
ES.Data.ItemNames[3855] = "Massive Iron Axe"
ES.Data.ItemNames[3856] = "Shadow Crescent Axe"
ES.Data.ItemNames[3859] = "Steel Bar"
ES.Data.ItemNames[3860] = "Mithril Bar"
ES.Data.ItemNames[3864] = "Citrine"
ES.Data.ItemNames[4234] = "Heavy Leather"
ES.Data.ItemNames[4255] = "Green Leather Armor"
ES.Data.ItemNames[4304] = "Thick Leather"
ES.Data.ItemNames[4338] = "Mageweave Cloth"
ES.Data.ItemNames[5498] = "Small Lustrous Pearl"
ES.Data.ItemNames[5500] = "Iridescent Pearl"
ES.Data.ItemNames[5540] = "Pearl-handled Dagger"
ES.Data.ItemNames[5541] = "Iridescent Hammer"
ES.Data.ItemNames[5635] = "Sharp Claw"
ES.Data.ItemNames[5637] = "Large Fang"
ES.Data.ItemNames[5956] = "Blacksmith Hammer"
ES.Data.ItemNames[5966] = "Guardian Gloves"
ES.Data.ItemNames[6037] = "Truesilver Bar"
ES.Data.ItemNames[6040] = "Golden Scale Bracers"
ES.Data.ItemNames[6041] = "Steel Weapon Chain"
ES.Data.ItemNames[6042] = "Iron Shield Spike"
ES.Data.ItemNames[6043] = "Iron Counterweight"
ES.Data.ItemNames[6214] = "Heavy Copper Maul"
ES.Data.ItemNames[6217] = "Copper Rod"
ES.Data.ItemNames[6338] = "Silver Rod"
ES.Data.ItemNames[6350] = "Rough Bronze Boots"
ES.Data.ItemNames[6730] = "Ironforge Chain"
ES.Data.ItemNames[6731] = "Ironforge Breastplate"
ES.Data.ItemNames[6733] = "Ironforge Gauntlets"
ES.Data.ItemNames[7067] = "Elemental Earth"
ES.Data.ItemNames[7068] = "Elemental Fire"
ES.Data.ItemNames[7069] = "Elemental Air"
ES.Data.ItemNames[7070] = "Elemental Water"
ES.Data.ItemNames[7071] = "Iron Buckle"
ES.Data.ItemNames[7075] = "Core of Earth"
ES.Data.ItemNames[7076] = "Essence of Earth"
ES.Data.ItemNames[7077] = "Heart of Fire"
ES.Data.ItemNames[7078] = "Essence of Fire"
ES.Data.ItemNames[7079] = "Globe of Water"
ES.Data.ItemNames[7080] = "Essence of Water"
ES.Data.ItemNames[7081] = "Breath of Wind"
ES.Data.ItemNames[7082] = "Essence of Air"
ES.Data.ItemNames[7166] = "Copper Dagger"
ES.Data.ItemNames[7909] = "Aquamarine"
ES.Data.ItemNames[7910] = "Star Ruby"
ES.Data.ItemNames[7912] = "Solid Stone"
ES.Data.ItemNames[7913] = "Barbaric Iron Shoulders"
ES.Data.ItemNames[7914] = "Barbaric Iron Breastplate"
ES.Data.ItemNames[7915] = "Barbaric Iron Helm"
ES.Data.ItemNames[7916] = "Barbaric Iron Boots"
ES.Data.ItemNames[7917] = "Barbaric Iron Gloves"
ES.Data.ItemNames[7918] = "Heavy Mithril Shoulder"
ES.Data.ItemNames[7919] = "Heavy Mithril Gauntlet"
ES.Data.ItemNames[7920] = "Mithril Plate Pants"
ES.Data.ItemNames[7921] = "Heavy Mithril Pants"
ES.Data.ItemNames[7922] = "Steel Plate Helm"
ES.Data.ItemNames[7924] = "Mithril Plate Bracers"
ES.Data.ItemNames[7925] = "Mithril Plate Gloves"
ES.Data.ItemNames[7926] = "Ornate Mithril Pants"
ES.Data.ItemNames[7927] = "Ornate Mithril Gloves"
ES.Data.ItemNames[7928] = "Ornate Mithril Shoulders"
ES.Data.ItemNames[7929] = "Orcish War Leggings"
ES.Data.ItemNames[7930] = "Heavy Mithril Breastplate"
ES.Data.ItemNames[7931] = "Mithril Coif"
ES.Data.ItemNames[7932] = "Mithril Plate Shoulders"
ES.Data.ItemNames[7933] = "Heavy Mithril Boots"
ES.Data.ItemNames[7934] = "Heavy Mithril Helm"
ES.Data.ItemNames[7935] = "Ornate Mithril Breastplate"
ES.Data.ItemNames[7936] = "Ornate Mithril Boots"
ES.Data.ItemNames[7937] = "Ornate Mithril Helm"
ES.Data.ItemNames[7938] = "Truesilver Gauntlets"
ES.Data.ItemNames[7939] = "Truesilver Breastplate"
ES.Data.ItemNames[7941] = "Heavy Mithril Axe"
ES.Data.ItemNames[7942] = "Blue Glittering Axe"
ES.Data.ItemNames[7943] = "Wicked Mithril Blade"
ES.Data.ItemNames[7944] = "Dazzling Mithril Rapier"
ES.Data.ItemNames[7945] = "Big Black Mace"
ES.Data.ItemNames[7946] = "Runed Mithril Hammer"
ES.Data.ItemNames[7947] = "Ebon Shiv"
ES.Data.ItemNames[7954] = "The Shatterer"
ES.Data.ItemNames[7955] = "Copper Claymore"
ES.Data.ItemNames[7956] = "Bronze Warhammer"
ES.Data.ItemNames[7957] = "Bronze Greatsword"
ES.Data.ItemNames[7958] = "Bronze Battle Axe"
ES.Data.ItemNames[7959] = "Blight"
ES.Data.ItemNames[7960] = "Truesilver Champion"
ES.Data.ItemNames[7961] = "Phantom Blade"
ES.Data.ItemNames[7963] = "Steel Breastplate"
ES.Data.ItemNames[7964] = "Solid Sharpening Stone"
ES.Data.ItemNames[7965] = "Solid Weightstone"
ES.Data.ItemNames[7966] = "Solid Grinding Stone"
ES.Data.ItemNames[7967] = "Mithril Shield Spike"
ES.Data.ItemNames[7969] = "Mithril Spurs"
ES.Data.ItemNames[7971] = "Black Pearl"
ES.Data.ItemNames[7972] = "Ichor of Undeath"
ES.Data.ItemNames[8146] = "Wicked Claw"
ES.Data.ItemNames[8153] = "Wildvine"
ES.Data.ItemNames[8168] = "Jet Black Feather"
ES.Data.ItemNames[8170] = "Rugged Leather"
ES.Data.ItemNames[8831] = "Purple Lotus"
ES.Data.ItemNames[9060] = "Inlaid Mithril Cylinder"
ES.Data.ItemNames[9366] = "Golden Scale Gauntlets"
ES.Data.ItemNames[10421] = "Rough Copper Vest"
ES.Data.ItemNames[10423] = "Silvered Bronze Leggings"
ES.Data.ItemNames[10938] = "Lesser Magic Essence"
ES.Data.ItemNames[10940] = "Strange Dust"
ES.Data.ItemNames[11128] = "Golden Rod"
ES.Data.ItemNames[11139] = "Large Glowing Shard"
ES.Data.ItemNames[11144] = "Truesilver Rod"
ES.Data.ItemNames[11184] = "Blue Power Crystal"
ES.Data.ItemNames[11185] = "Green Power Crystal"
ES.Data.ItemNames[11186] = "Red Power Crystal"
ES.Data.ItemNames[11188] = "Yellow Power Crystal"
ES.Data.ItemNames[11371] = "Dark Iron Bar"
ES.Data.ItemNames[11382] = "Blood of the Mountain"
ES.Data.ItemNames[11604] = "Dark Iron Plate"
ES.Data.ItemNames[11605] = "Dark Iron Shoulders"
ES.Data.ItemNames[11606] = "Dark Iron Mail"
ES.Data.ItemNames[11607] = "Dark Iron Sunderer"
ES.Data.ItemNames[11608] = "Dark Iron Pulverizer"
ES.Data.ItemNames[11754] = "Black Diamond"
ES.Data.ItemNames[12259] = "Glinting Steel Dagger"
ES.Data.ItemNames[12260] = "Searing Golden Blade"
ES.Data.ItemNames[12359] = "Thorium Bar"
ES.Data.ItemNames[12360] = "Arcanite Bar"
ES.Data.ItemNames[12361] = "Blue Sapphire"
ES.Data.ItemNames[12364] = "Huge Emerald"
ES.Data.ItemNames[12365] = "Dense Stone"
ES.Data.ItemNames[12404] = "Dense Sharpening Stone"
ES.Data.ItemNames[12405] = "Thorium Armor"
ES.Data.ItemNames[12406] = "Thorium Belt"
ES.Data.ItemNames[12408] = "Thorium Bracers"
ES.Data.ItemNames[12409] = "Thorium Boots"
ES.Data.ItemNames[12410] = "Thorium Helm"
ES.Data.ItemNames[12414] = "Thorium Leggings"
ES.Data.ItemNames[12415] = "Radiant Breastplate"
ES.Data.ItemNames[12416] = "Radiant Belt"
ES.Data.ItemNames[12417] = "Radiant Circlet"
ES.Data.ItemNames[12418] = "Radiant Gloves"
ES.Data.ItemNames[12419] = "Radiant Boots"
ES.Data.ItemNames[12420] = "Radiant Leggings"
ES.Data.ItemNames[12422] = "Imperial Plate Chest"
ES.Data.ItemNames[12424] = "Imperial Plate Belt"
ES.Data.ItemNames[12425] = "Imperial Plate Bracers"
ES.Data.ItemNames[12426] = "Imperial Plate Boots"
ES.Data.ItemNames[12427] = "Imperial Plate Helm"
ES.Data.ItemNames[12428] = "Imperial Plate Shoulders"
ES.Data.ItemNames[12429] = "Imperial Plate Leggings"
ES.Data.ItemNames[12610] = "Runic Plate Shoulders"
ES.Data.ItemNames[12611] = "Runic Plate Boots"
ES.Data.ItemNames[12612] = "Runic Plate Helm"
ES.Data.ItemNames[12613] = "Runic Breastplate"
ES.Data.ItemNames[12614] = "Runic Plate Leggings"
ES.Data.ItemNames[12618] = "Enchanted Thorium Breastplate"
ES.Data.ItemNames[12619] = "Enchanted Thorium Leggings"
ES.Data.ItemNames[12620] = "Enchanted Thorium Helm"
ES.Data.ItemNames[12625] = "Dawnbringer Shoulders"
ES.Data.ItemNames[12631] = "Fiery Plate Gauntlets"
ES.Data.ItemNames[12633] = "Whitesoul Helm"
ES.Data.ItemNames[12639] = "Stronghold Gauntlets"
ES.Data.ItemNames[12640] = "Lionheart Helm"
ES.Data.ItemNames[12643] = "Dense Weightstone"
ES.Data.ItemNames[12644] = "Dense Grinding Stone"
ES.Data.ItemNames[12645] = "Thorium Shield Spike"
ES.Data.ItemNames[12655] = "Enchanted Thorium Bar"
ES.Data.ItemNames[12662] = "Demonic Rune"
ES.Data.ItemNames[12753] = "Skin of Shadow"
ES.Data.ItemNames[12764] = "Thorium Greatsword"
ES.Data.ItemNames[12769] = "Bleakwood Hew"
ES.Data.ItemNames[12772] = "Inlaid Thorium Hammer"
ES.Data.ItemNames[12773] = "Ornate Thorium Handaxe"
ES.Data.ItemNames[12774] = "Dawn's Edge"
ES.Data.ItemNames[12775] = "Huge Thorium Battleaxe"
ES.Data.ItemNames[12776] = "Enchanted Battlehammer"
ES.Data.ItemNames[12777] = "Blazing Rapier"
ES.Data.ItemNames[12781] = "Serenity"
ES.Data.ItemNames[12782] = "Corruption"
ES.Data.ItemNames[12783] = "Heartseeker"
ES.Data.ItemNames[12784] = "Arcanite Reaper"
ES.Data.ItemNames[12790] = "Arcanite Champion"
ES.Data.ItemNames[12792] = "Volcanic Hammer"
ES.Data.ItemNames[12794] = "Masterwork Stormhammer"
ES.Data.ItemNames[12795] = "Blood Talon"
ES.Data.ItemNames[12796] = "Hammer of the Titans"
ES.Data.ItemNames[12797] = "Frostguard"
ES.Data.ItemNames[12798] = "Annihilator"
ES.Data.ItemNames[12799] = "Large Opal"
ES.Data.ItemNames[12800] = "Azerothian Diamond"
ES.Data.ItemNames[12802] = "Darkspear"
ES.Data.ItemNames[12803] = "Living Essence"
ES.Data.ItemNames[12804] = "Powerful Mojo"
ES.Data.ItemNames[12808] = "Essence of Undeath"
ES.Data.ItemNames[12809] = "Guardian Stone"
ES.Data.ItemNames[12810] = "Enchanted Leather"
ES.Data.ItemNames[12811] = "Righteous Orb"
ES.Data.ItemNames[12938] = "Blood of Heroes"
ES.Data.ItemNames[13510] = "Flask of the Titans"
ES.Data.ItemNames[13511] = "Flask of Distilled Wisdom"
ES.Data.ItemNames[13512] = "Flask of Supreme Power"
ES.Data.ItemNames[13926] = "Golden Pearl"
ES.Data.ItemNames[15417] = "Devilsaur Leather"
ES.Data.ItemNames[15869] = "Silver Skeleton Key"
ES.Data.ItemNames[15870] = "Golden Skeleton Key"
ES.Data.ItemNames[15871] = "Truesilver Skeleton Key"
ES.Data.ItemNames[15872] = "Arcanite Skeleton Key"
ES.Data.ItemNames[16206] = "Arcanite Rod"
ES.Data.ItemNames[16988] = "Fiery Chain Shoulders"
ES.Data.ItemNames[16989] = "Fiery Chain Girdle"
ES.Data.ItemNames[17010] = "Fiery Core"
ES.Data.ItemNames[17011] = "Lava Core"
ES.Data.ItemNames[17012] = "Core Leather"
ES.Data.ItemNames[17013] = "Dark Iron Leggings"
ES.Data.ItemNames[17014] = "Dark Iron Bracers"
ES.Data.ItemNames[17015] = "Dark Iron Reaver"
ES.Data.ItemNames[17016] = "Dark Iron Destroyer"
ES.Data.ItemNames[17193] = "Sulfuron Hammer"
ES.Data.ItemNames[17203] = "Sulfuron Ingot"
ES.Data.ItemNames[17704] = "Edge of Winter"
ES.Data.ItemNames[18262] = "Elemental Sharpening Stone"
ES.Data.ItemNames[18567] = "Elemental Flux"
ES.Data.ItemNames[19051] = "Girdle of the Dawn"
ES.Data.ItemNames[19057] = "Gloves of the Dawn"
ES.Data.ItemNames[19148] = "Dark Iron Helm"
ES.Data.ItemNames[19164] = "Dark Iron Gauntlets"
ES.Data.ItemNames[19166] = "Black Amnesty"
ES.Data.ItemNames[19167] = "Blackfury"
ES.Data.ItemNames[19168] = "Blackguard"
ES.Data.ItemNames[19169] = "Nightfall"
ES.Data.ItemNames[19170] = "Ebon Hand"
ES.Data.ItemNames[19690] = "Bloodsoul Breastplate"
ES.Data.ItemNames[19691] = "Bloodsoul Shoulders"
ES.Data.ItemNames[19692] = "Bloodsoul Gauntlets"
ES.Data.ItemNames[19693] = "Darksoul Breastplate"
ES.Data.ItemNames[19694] = "Darksoul Leggings"
ES.Data.ItemNames[19695] = "Darksoul Shoulders"
ES.Data.ItemNames[19726] = "Bloodvine"
ES.Data.ItemNames[19774] = "Souldarite"
ES.Data.ItemNames[20039] = "Dark Iron Boots"
ES.Data.ItemNames[20381] = "Dreamscale"
ES.Data.ItemNames[20520] = "Dark Rune"
ES.Data.ItemNames[20549] = "Darkrune Gauntlets"
ES.Data.ItemNames[20550] = "Darkrune Breastplate"
ES.Data.ItemNames[20551] = "Darkrune Helm"
ES.Data.ItemNames[20725] = "Nexus Crystal"
ES.Data.ItemNames[22191] = "Obsidian Mail Tunic"
ES.Data.ItemNames[22194] = "Black Grasp of the Destroyer"
ES.Data.ItemNames[22195] = "Light Obsidian Belt"
ES.Data.ItemNames[22196] = "Thick Obsidian Breastplate"
ES.Data.ItemNames[22197] = "Heavy Obsidian Belt"
ES.Data.ItemNames[22198] = "Jagged Obsidian Shield"
ES.Data.ItemNames[22202] = "Small Obsidian Shard"
ES.Data.ItemNames[22203] = "Large Obsidian Shard"
ES.Data.ItemNames[22383] = "Sageblade"
ES.Data.ItemNames[22384] = "Persuader"
ES.Data.ItemNames[22385] = "Titanic Leggings"
ES.Data.ItemNames[22669] = "Icebane Breastplate"
ES.Data.ItemNames[22670] = "Icebane Gauntlets"
ES.Data.ItemNames[22671] = "Icebane Bracers"
ES.Data.ItemNames[22682] = "Frozen Rune"
ES.Data.ItemNames[211845] = "Blackfathom Sharpening Stone"
ES.Data.ItemNames[213369] = "Faintly Glowing Leather"
ES.Data.ItemNames[213373] = "Reflective Scrapmetal"
ES.Data.ItemNames[213376] = "Low-Background Truesilver Plates"
ES.Data.ItemNames[213379] = "Hyperconductive Arcano-Filament"
ES.Data.ItemNames[213383] = "Polished Truesilver Gears"
ES.Data.ItemNames[248820] = "Torbernite"
ES.Data.ItemNames[248822] = "Death Lotus"
ES.Data.ItemNames[249410] = "Sulfuric Acid"
ES.Data.ItemNames[249427] = "Pristine Leather"
ES.Data.ItemNames[249432] = "Sandpaper"
ES.Data.ItemNames[249726] = "Azerothium Bar"
ES.Data.ItemNames[250483] = "Sterling Silver Boots"
ES.Data.ItemNames[250484] = "Sterling Silver Leggings"
ES.Data.ItemNames[250485] = "Sterling Silver Gauntlet"
ES.Data.ItemNames[250486] = "Sterling Silver Shoulders"
ES.Data.ItemNames[250487] = "Sterling Silver Breastplate"
ES.Data.ItemNames[250503] = "Veteran's Boots"
ES.Data.ItemNames[250504] = "Guard's Boots"
ES.Data.ItemNames[250505] = "Protector's Boots"
ES.Data.ItemNames[250506] = "Acolyte's Boots"
ES.Data.ItemNames[250507] = "Crusader's Boots"
ES.Data.ItemNames[250508] = "Veteran's Gloves"
ES.Data.ItemNames[250509] = "Guard's Gloves"
ES.Data.ItemNames[250510] = "Protector's Gloves"
ES.Data.ItemNames[250511] = "Acolyte's Gloves"
ES.Data.ItemNames[250512] = "Crusader's Gloves"
ES.Data.ItemNames[250513] = "Veteran's Chain Belt"
ES.Data.ItemNames[250514] = "Guard's Chain Belt"
ES.Data.ItemNames[250515] = "Protector's Chain Belt"
ES.Data.ItemNames[250516] = "Acolyte's Chain Belt"
ES.Data.ItemNames[250517] = "Crusader's Chain Belt"
ES.Data.ItemNames[250518] = "Veteran's Silvered Chain Shirt"
ES.Data.ItemNames[250519] = "Guard's Silvered Chain Shirt"
ES.Data.ItemNames[250520] = "Protector's Silvered Chain Shirt"
ES.Data.ItemNames[250521] = "Acolyte's Silvered Chain Shirt"
ES.Data.ItemNames[250522] = "Crusader's Silvered Chain Shirt"
ES.Data.ItemNames[250523] = "Veteran's Silvered Chain Leggings"
ES.Data.ItemNames[250524] = "Guard's Silvered Chain Leggings"
ES.Data.ItemNames[250525] = "Protector's Silvered Chain Leggings"
ES.Data.ItemNames[250526] = "Acolyte's Silvered Chain Leggings"
ES.Data.ItemNames[250527] = "Crusader's Silvered Chain Leggings"
ES.Data.ItemNames[250528] = "Veteran's Silvered Chain Helm"
ES.Data.ItemNames[250529] = "Guard's Silvered Chain Helm"
ES.Data.ItemNames[250530] = "Protector's Silvered Chain Helm"
ES.Data.ItemNames[250531] = "Acolyte's Silvered Chain Helm"
ES.Data.ItemNames[250532] = "Crusader's Silvered Chain Helm"
ES.Data.ItemNames[250533] = "Hard Gold Cuirass"
ES.Data.ItemNames[250534] = "Hard Gold Boots"
ES.Data.ItemNames[250535] = "Hard Gold Bracers"
ES.Data.ItemNames[250536] = "Hard Gold Leggings"
ES.Data.ItemNames[250537] = "Hard Gold Coif"
ES.Data.ItemNames[250538] = "Hard Gold Gauntlet"
ES.Data.ItemNames[250539] = "Hard Gold Pauldrons"
ES.Data.ItemNames[250540] = "Shining Mithril Breastplate"
ES.Data.ItemNames[250541] = "Shining Mithril Pauldrons"
ES.Data.ItemNames[250542] = "Shining Mithril Boots"
ES.Data.ItemNames[250543] = "Shining Mithril Helm"
ES.Data.ItemNames[250544] = "Shining Mithril Pants"
ES.Data.ItemNames[250545] = "Shining Mithril Gauntlet"
ES.Data.ItemNames[250561] = "Officer's Sabatons"
ES.Data.ItemNames[250562] = "Sentinel's Sabatons"
ES.Data.ItemNames[250563] = "Warder's Sabatons"
ES.Data.ItemNames[250564] = "Prefect's Sabatons"
ES.Data.ItemNames[250565] = "Justicar's Sabatons"
ES.Data.ItemNames[250566] = "Officer's Gauntlet"
ES.Data.ItemNames[250567] = "Sentinel's Gauntlet"
ES.Data.ItemNames[250568] = "Warder's Gauntlet"
ES.Data.ItemNames[250569] = "Prefect's Gauntlet"
ES.Data.ItemNames[250570] = "Justicar's Gauntlet"
ES.Data.ItemNames[250571] = "Officer's Waistguard"
ES.Data.ItemNames[250572] = "Sentinel's Waistguard"
ES.Data.ItemNames[250573] = "Warder's Waistguard"
ES.Data.ItemNames[250574] = "Prefect's Waistguard"
ES.Data.ItemNames[250575] = "Justicar's Waistguard"
ES.Data.ItemNames[250576] = "Officer's Pauldrons"
ES.Data.ItemNames[250577] = "Sentinel's Pauldrons"
ES.Data.ItemNames[250578] = "Warder's Pauldrons"
ES.Data.ItemNames[250579] = "Prefect's Pauldrons"
ES.Data.ItemNames[250580] = "Justicar's Pauldrons"
ES.Data.ItemNames[250581] = "Officer's Wristguards"
ES.Data.ItemNames[250582] = "Sentinel's Wristguards"
ES.Data.ItemNames[250583] = "Warder's Wristguards"
ES.Data.ItemNames[250584] = "Prefect's Wristguards"
ES.Data.ItemNames[250585] = "Justicar's Wristguards"
ES.Data.ItemNames[250586] = "Blessed Plate Pauldrons"
ES.Data.ItemNames[250587] = "Blessed Plate Boots"
ES.Data.ItemNames[250588] = "Blessed Plate Gauntlet"
ES.Data.ItemNames[250589] = "Imperial Plate Gauntlets"
ES.Data.ItemNames[250590] = "Blessed Plate Bracers"
ES.Data.ItemNames[250591] = "Blessed Plate Leggings"
ES.Data.ItemNames[250592] = "Blessed Plate Belt"
ES.Data.ItemNames[250593] = "Blessed Plate Helm"
ES.Data.ItemNames[250594] = "Blessed Plate Chest"
ES.Data.ItemNames[250595] = "Enriched Thorium Breastplate"
ES.Data.ItemNames[250596] = "Enriched Thorium Leggings"
ES.Data.ItemNames[250597] = "Enriched Thorium Helm"
ES.Data.ItemNames[250598] = "Champion's Legplates"
ES.Data.ItemNames[250599] = "Stalwart Helm"
ES.Data.ItemNames[250600] = "Martyr's Legplates"
ES.Data.ItemNames[250601] = "Breastplate of Salvation"
ES.Data.ItemNames[250602] = "Brass Knuckles"
ES.Data.ItemNames[250603] = "Bronze Dory"
ES.Data.ItemNames[250604] = "Iron Fists"
ES.Data.ItemNames[250605] = "Steel Spear"
ES.Data.ItemNames[250606] = "Iron Morningstar"
ES.Data.ItemNames[250607] = "Mithril Shortsword"
ES.Data.ItemNames[250608] = "Mithril Warhammer"
ES.Data.ItemNames[250609] = "Mithril Claws"
ES.Data.ItemNames[250610] = "Mithril Claymore"
ES.Data.ItemNames[250611] = "Mithril Stiletto"
ES.Data.ItemNames[250612] = "Charged Mithril Battleaxe"
ES.Data.ItemNames[250613] = "Thorium Greatmace"
ES.Data.ItemNames[250614] = "Thorium Cestus"
ES.Data.ItemNames[250615] = "Thorium Poleaxe"
ES.Data.ItemNames[250616] = "Bold Dirk"
ES.Data.ItemNames[250617] = "Stormcarver"
ES.Data.ItemNames[250618] = "Bagh Nakh"
ES.Data.ItemNames[250619] = "Legionite Glaive"
ES.Data.ItemNames[251290] = "Legionite Bar"
ES.Data.ItemNames[251291] = "Heavy Thorium Bar"
ES.Data.ItemNames[274030] = "Malleable Essence of Nature"
ES.Data.ItemNames[275622] = "Goregasher Grips"
ES.Data.ItemNames[275623] = "Goregasher Support"
ES.Data.ItemNames[275624] = "Goregasher Stompers"
ES.Data.ItemNames[275625] = "Clutchlord's Grips"
ES.Data.ItemNames[275626] = "Clutchlord's Support"
ES.Data.ItemNames[275627] = "Clutchlord's Stompers"
ES.Data.ItemNames[276992] = "Cloudy Skyforged Chainmail"
ES.Data.ItemNames[276993] = "Cloudy Skyforged Wristguards"
ES.Data.ItemNames[276994] = "Cloudy Skyforged Gauntlets"
ES.Data.ItemNames[276995] = "Cloudy Skyforged Chain"
ES.Data.ItemNames[276996] = "Cloudy Skyforged Legguards"
ES.Data.ItemNames[276997] = "Cloudy Skyforged Greaves"
ES.Data.ItemNames[277016] = "Azure Skyforged Chainmail"
ES.Data.ItemNames[277017] = "Azure Skyforged Wristguards"
ES.Data.ItemNames[277018] = "Azure Skyforged Gauntlets"
ES.Data.ItemNames[277019] = "Azure Skyforged Chain"
ES.Data.ItemNames[277020] = "Azure Skyforged Legguards"
ES.Data.ItemNames[277021] = "Azure Skyforged Greaves"
ES.Data.ItemNames[277040] = "Cloudy Skyforged Helm"
ES.Data.ItemNames[277041] = "Cloudy Skyforged Pauldrons"
ES.Data.ItemNames[277048] = "Azure Skyforged Helm"
ES.Data.ItemNames[277049] = "Azure Skyforged Pauldrons"
ES.Data.ItemNames[277672] = "Rough Copper Chain Boots"
ES.Data.ItemNames[279259] = "Ironwood Blade"
ES.Data.ItemNames[279260] = "Forest Defender's Axe"
ES.Data.ItemNames[279261] = "Greenhammer"
ES.Data.ItemNames[279262] = "Evergreen Shield"
ES.Data.ItemNames[279263] = "Depleted Thorium Sabatons"
ES.Data.ItemNames[279264] = "Heavy Thorium Gauntlets"
ES.Data.ItemNames[279265] = "Azerothium Legplates"
ES.Data.ItemNames[279944] = "Sharpening Wheel"
ES.Data.ItemNames[279988] = "Anvil"
ES.Data.ItemNames[285279] = "Cracked Blacksmith Hammer"
ES.Data.ItemNames[285280] = "Mithril Blacksmith Hammer"
ES.Data.ItemNames[285281] = "Arcanite Blacksmith Hammer"

-- Material -> profesión de recolección que lo consigue (393 Desuello, 182 Herboristería, 186 Minería).
-- Sin uso por ahora: reservado para la vía "Vender en bruto" de Ganar dinero (docs/PLAN.md, G1).
ES.Data.GatheredBy = ES.Data.GatheredBy or {}
ES.Data.GatheredBy[2318] = 393
ES.Data.GatheredBy[2319] = 393
ES.Data.GatheredBy[2835] = 186
ES.Data.GatheredBy[2836] = 186
ES.Data.GatheredBy[2838] = 186
ES.Data.GatheredBy[2840] = 186
ES.Data.GatheredBy[2841] = 186
ES.Data.GatheredBy[2842] = 186
ES.Data.GatheredBy[3575] = 186
ES.Data.GatheredBy[3859] = 186
ES.Data.GatheredBy[3860] = 186
ES.Data.GatheredBy[4234] = 393
ES.Data.GatheredBy[4304] = 393
ES.Data.GatheredBy[7912] = 186
ES.Data.GatheredBy[8153] = 182
ES.Data.GatheredBy[8168] = 393
ES.Data.GatheredBy[8170] = 393
ES.Data.GatheredBy[8831] = 182
ES.Data.GatheredBy[11371] = 186
ES.Data.GatheredBy[12359] = 186
ES.Data.GatheredBy[12365] = 186
ES.Data.GatheredBy[12809] = 186
ES.Data.GatheredBy[15417] = 393
ES.Data.GatheredBy[17012] = 393
ES.Data.GatheredBy[17203] = 186
ES.Data.GatheredBy[19726] = 182
ES.Data.GatheredBy[20381] = 393
ES.Data.GatheredBy[22202] = 186
ES.Data.GatheredBy[22203] = 186
ES.Data.GatheredBy[213373] = 186
ES.Data.GatheredBy[248822] = 182
ES.Data.GatheredBy[249427] = 393
ES.Data.GatheredBy[249726] = 186
ES.Data.GatheredBy[251291] = 186

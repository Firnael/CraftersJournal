-- Generado por tools/gen_profession.py (Enchanting). No editar a mano.
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
ES.Data.Enchanting = {
  skillLine = 333,
  ranks = { -- { tope, precio, habilidad requerida, nivel de personaje }
    { 150, 500, 50, 10 },
    { 225, 5000, 125, 20 },
    { 300, 50000, 200, 35 },
  },
  -- { PNJ instructor, rangos que enseña: 1 aprendiz (75), 2 oficial (150), 4 experto (225), 8 artesano (300) }
  trainers = { { 1317, 2 }, { 3011, 2 }, { 3345, 2 }, { 3606, 1 }, { 4213, 2 }, { 4616, 2 }, { 5157, 2 }, { 5695, 1 }, { 7949, 2 }, { 11065, 1 }, { 11066, 1 }, { 11067, 1 }, { 11068, 1 }, { 11070, 1 }, { 11071, 1 }, { 11072, 4 }, { 11073, 8 }, { 11074, 4 }, { 251978, 3 }, { 257004, 3 }, { 257020, 3 }, { 266881, 1 } },
  recipes = {
    [7418] = { name = "Enchant Bracer - Inferior Stamina", t = { 1, 20, 22, 25 }, basic = true, r = { { 247786, 1 } }, tool = 373 },
    [7420] = { name = "Enchant Chest - Inferior Stamina", t = { 1, 70, 90, 110 }, fee = 50, train = 15, r = { { 10940, 1 } }, tool = 373 },
    [7421] = { name = "Runed Copper Rod", t = { 1, 5, 7, 10 }, basic = true, r = { { 6217, 1 }, { 247786, 1 } }, out = { 6218, 1 }, oq = 1, bop = true },
    [7426] = { name = "Enchant Chest - Minor Absorption", t = { 1, 90, 110, 130 }, fee = 100, train = 40, r = { { 10938, 1 } }, tool = 373 },
    [7428] = { name = "Enchant Bracer - Minor Deflect", t = { 1, 80, 100, 120 }, basic = true, r = { { 10938, 1 } }, tool = 373 },
    [7443] = { name = "Enchant Chest - Minor Intellect", t = { 1, 80, 100, 120 }, scroll = 6342, train = 20, scrollPrice = 300, sq = 2, r = { { 10938, 1 } }, tool = 373 },
    [7454] = { name = "Enchant Cloak - Minor Resistance", t = { 1, 95, 115, 135 }, fee = 100, train = 45, r = { { 10940, 1 }, { 10938, 1 } }, tool = 373 },
    [7457] = { name = "Enchant Bracer - Minor Stamina", t = { 1, 100, 120, 140 }, fee = 250, train = 50, r = { { 10940, 2 } }, tool = 373 },
    [7745] = { name = "Enchant 2H Weapon - Minor Impact", t = { 1, 130, 150, 170 }, fee = 500, train = 100, r = { { 10940, 1 }, { 10978, 1 } }, tool = 373 },
    [7748] = { name = "Enchant Chest - Lesser Stamina", t = { 1, 105, 125, 145 }, fee = 250, train = 60, r = { { 10940, 1 }, { 10938, 1 } }, tool = 373 },
    [7766] = { name = "Enchant Bracer - Minor Spirit", t = { 1, 105, 125, 145 }, scroll = 6344, train = 60, sq = 2, r = { { 10938, 1 } }, tool = 373 },
    [7771] = { name = "Enchant Cloak - Minor Protection", t = { 1, 110, 130, 150 }, fee = 200, train = 70, r = { { 10940, 2 } }, tool = 373 },
    [7776] = { name = "Enchant Chest - Lesser Intellect", t = { 1, 115, 135, 155 }, scroll = 6346, train = 80, scrollPrice = 400, sq = 2, r = { { 10938, 2 } }, tool = 373 },
    [7779] = { name = "Enchant Bracer - Minor Agility", t = { 1, 115, 135, 155 }, fee = 400, train = 80, r = { { 10940, 1 }, { 10938, 2 } }, tool = 373 },
    [7782] = { name = "Enchant Bracer - Minor Strength", t = { 1, 115, 135, 155 }, scroll = 6347, train = 80, sq = 2, r = { { 10940, 3 } }, tool = 373 },
    [7786] = { name = "Enchant Weapon - Minor Beastslayer", t = { 1, 120, 140, 160 }, scroll = 6348, train = 90, sq = 2, r = { { 10940, 2 }, { 10939, 1 } }, tool = 373 },
    [7788] = { name = "Enchant Weapon - Minor Striking", t = { 1, 120, 140, 160 }, fee = 500, train = 90, r = { { 10940, 1 }, { 10938, 1 }, { 10978, 1 } }, tool = 373 },
    [7793] = { name = "Enchant 2H Weapon - Lesser Intellect", t = { 1, 130, 150, 170 }, scroll = 6349, train = 100, scrollPrice = 500, sq = 1, r = { { 10938, 4 } }, tool = 373 },
    [7795] = { name = "Runed Silver Rod", t = { 1, 130, 150, 170 }, fee = 1000, train = 100, r = { { 6338, 1 }, { 10940, 3 }, { 10938, 4 }, { 1210, 1 } }, out = { 6339, 1 }, oq = 1, bop = true },
    [7857] = { name = "Enchant Chest - Stamina", t = { 1, 145, 165, 185 }, fee = 1000, train = 120, r = { { 10940, 2 }, { 10998, 1 } }, tool = 374 },
    [7859] = { name = "Enchant Bracer - Lesser Spirit", t = { 1, 145, 165, 185 }, scroll = 6375, train = 120, sq = 2, r = { { 10998, 1 } }, tool = 374 },
    [7861] = { name = "Enchant Cloak - Lesser Fire Resistance", t = { 1, 150, 170, 190 }, fee = 1250, train = 125, r = { { 6371, 1 }, { 10998, 1 } }, tool = 374 },
    [7863] = { name = "Enchant Boots - Minor Stamina", t = { 1, 150, 170, 190 }, fee = 1400, train = 125, r = { { 10940, 4 } }, tool = 374 },
    [7867] = { name = "Enchant Boots - Minor Agility", t = { 1, 150, 170, 190 }, scroll = 6377, train = 125, scrollPrice = 1000, sq = 2, r = { { 10940, 3 }, { 10998, 1 } }, tool = 374 },
    [13378] = { name = "Enchant Shield - Minor Stamina", t = { 1, 130, 150, 170 }, fee = 600, train = 105, r = { { 10998, 1 }, { 10940, 1 } }, tool = 373 },
    [13380] = { name = "Enchant 2H Weapon - Lesser Spirit", t = { 1, 135, 155, 175 }, scroll = 11038, train = 110, sq = 2, r = { { 10998, 1 }, { 10940, 3 } }, tool = 373 },
    [13419] = { name = "Enchant Cloak - Minor Agility", t = { 1, 135, 155, 175 }, scroll = 11039, train = 110, scrollPrice = 800, sq = 2, r = { { 10998, 1 } }, tool = 374 },
    [13421] = { name = "Enchant Cloak - Lesser Protection", t = { 1, 140, 160, 180 }, fee = 800, train = 115, r = { { 10940, 3 }, { 10978, 1 } }, tool = 373 },
    [13464] = { name = "Enchant Shield - Lesser Protection", t = { 1, 140, 160, 180 }, scroll = 11081, train = 115, sq = 2, r = { { 10940, 1 }, { 10978, 1 } }, tool = 374 },
    [13485] = { name = "Enchant Shield - Lesser Spirit", t = { 1, 155, 175, 195 }, fee = 1500, train = 130, r = { { 10998, 1 }, { 10940, 2 } }, tool = 374 },
    [13501] = { name = "Enchant Bracer - Lesser Stamina", t = { 1, 155, 175, 195 }, fee = 1500, train = 130, r = { { 11083, 1 } }, tool = 374 },
    [13503] = { name = "Enchant Weapon - Lesser Striking", t = { 1, 165, 185, 205 }, fee = 2000, train = 140, r = { { 11083, 1 }, { 11084, 1 } }, tool = 374 },
    [13522] = { name = "Enchant Cloak - Lesser Shadow Resistance", t = { 1, 160, 180, 200 }, scroll = 11098, train = 135, sq = 2, r = { { 10998, 1 }, { 6048, 1 } }, tool = 374 },
    [13529] = { name = "Enchant 2H Weapon - Lesser Impact", t = { 1, 170, 190, 210 }, fee = 2400, train = 145, r = { { 11083, 1 }, { 11084, 1 } }, tool = 374 },
    [13536] = { name = "Enchant Bracer - Lesser Strength", t = { 1, 165, 185, 205 }, scroll = 11101, train = 140, scrollPrice = 2500, sq = 2, r = { { 11083, 1 } }, tool = 374 },
    [13538] = { name = "Enchant Chest - Lesser Absorption", t = { 1, 165, 185, 205 }, fee = 2500, train = 140, r = { { 10940, 1 }, { 10998, 1 }, { 11084, 1 } }, tool = 374 },
    [13607] = { name = "Enchant Chest - Intellect", t = { 1, 170, 190, 210 }, fee = 2400, train = 145, r = { { 11082, 1 } }, tool = 374 },
    [13612] = { name = "Enchant Gloves - Mining", t = { 1, 170, 190, 210 }, scroll = 11150, train = 145, sq = 2, r = { { 11083, 1 }, { 2772, 1 } }, tool = 374 },
    [13617] = { name = "Enchant Gloves - Herbalism", t = { 1, 170, 190, 210 }, scroll = 11151, train = 145, sq = 2, r = { { 11083, 1 }, { 3356, 1 } }, tool = 374 },
    [13620] = { name = "Enchant Gloves - Fishing", t = { 1, 170, 190, 210 }, scroll = 11152, train = 145, sq = 2, r = { { 11083, 1 }, { 6370, 1 } }, tool = 374 },
    [13622] = { name = "Enchant Bracer - Lesser Intellect", t = { 1, 175, 195, 215 }, fee = 2500, train = 150, r = { { 11082, 1 } }, tool = 374 },
    [13626] = { name = "Enchant Chest - Minor Stats", t = { 1, 175, 195, 215 }, fee = 2500, train = 150, r = { { 10998, 1 }, { 11083, 1 }, { 11084, 1 } }, tool = 374 },
    [13628] = { name = "Runed Golden Rod", t = { 1, 175, 195, 215 }, fee = 2500, train = 150, r = { { 11128, 1 }, { 5500, 1 }, { 11082, 1 }, { 11083, 1 } }, out = { 11130, 1 }, oq = 1, bop = true },
    [13631] = { name = "Enchant Shield - Lesser Stamina", t = { 1, 175, 195, 215 }, fee = 2600, train = 155, r = { { 11134, 1 } }, tool = 375 },
    [13635] = { name = "Enchant Cloak - Defense", t = { 1, 175, 195, 215 }, fee = 2600, train = 155, r = { { 11138, 1 }, { 11083, 1 } }, tool = 375 },
    [13637] = { name = "Enchant Boots - Lesser Agility", t = { 1, 180, 200, 220 }, fee = 2800, train = 160, r = { { 11083, 1 } }, tool = 375 },
    [13640] = { name = "Enchant Chest - Greater Stamina", t = { 1, 180, 200, 220 }, fee = 2700, train = 160, r = { { 11083, 2 } }, tool = 375 },
    [13642] = { name = "Enchant Bracer - Spirit", t = { 1, 185, 205, 225 }, fee = 2800, train = 165, r = { { 11134, 1 } }, tool = 375 },
    [13644] = { name = "Enchant Boots - Lesser Stamina", t = { 1, 190, 210, 230 }, fee = 2800, train = 170, r = { { 11083, 2 } }, tool = 375 },
    [13646] = { name = "Enchant Bracer - Lesser Deflection", t = { 1, 190, 210, 230 }, scroll = 11163, train = 170, scrollPrice = 3000, sq = 2, r = { { 11134, 1 }, { 11083, 1 } }, tool = 375 },
    [13648] = { name = "Enchant Bracer - Stamina", t = { 1, 190, 210, 230 }, fee = 2800, train = 170, r = { { 11083, 3 } }, tool = 375 },
    [13653] = { name = "Enchant Weapon - Lesser Beastslayer", t = { 1, 195, 215, 235 }, scroll = 11164, train = 175, sq = 2, r = { { 5637, 1 }, { 11138, 1 } }, tool = 375 },
    [13655] = { name = "Enchant Weapon - Lesser Elemental Slayer", t = { 1, 195, 215, 235 }, scroll = 11165, train = 175, sq = 2, r = { { 7067, 1 }, { 11138, 1 } }, tool = 375 },
    [13657] = { name = "Enchant Cloak - Fire Resistance", t = { 1, 195, 215, 235 }, fee = 3000, train = 175, r = { { 11134, 1 }, { 7068, 1 } }, tool = 375 },
    [13659] = { name = "Enchant Shield - Spirit", t = { 1, 200, 220, 240 }, fee = 3200, train = 180, r = { { 11134, 1 }, { 11137, 1 } }, tool = 375 },
    [13661] = { name = "Enchant Bracer - Strength", t = { 1, 200, 220, 240 }, fee = 3600, train = 180, r = { { 11137, 1 } }, tool = 375 },
    [13663] = { name = "Enchant Chest - Greater Intellect", t = { 1, 205, 225, 245 }, fee = 3800, train = 185, r = { { 11134, 1 } }, tool = 375 },
    [13687] = { name = "Enchant Boots - Lesser Spirit", t = { 1, 210, 230, 250 }, scroll = 11167, train = 190, sq = 2, r = { { 11134, 2 } }, tool = 375 },
    [13689] = { name = "Enchant Shield - Lesser Block", t = { 1, 215, 235, 255 }, scroll = 11168, train = 195, sq = 2, r = { { 11135, 1 }, { 11137, 1 }, { 11139, 1 } }, tool = 375 },
    [13693] = { name = "Enchant Weapon - Striking", t = { 1, 215, 235, 255 }, fee = 4000, train = 195, r = { { 11135, 1 }, { 11139, 1 } }, tool = 375 },
    [13695] = { name = "Enchant 2H Weapon - Impact", t = { 1, 220, 240, 260 }, fee = 4000, train = 200, r = { { 11137, 2 }, { 11139, 1 } }, tool = 375 },
    [13698] = { name = "Enchant Gloves - Skinning", t = { 1, 220, 240, 260 }, scroll = 11166, train = 200, sq = 2, r = { { 11137, 1 }, { 7392, 1 } }, tool = 375 },
    [13700] = { name = "Enchant Chest - Lesser Stats", t = { 1, 220, 240, 260 }, fee = 4000, train = 200, r = { { 11135, 1 }, { 11137, 1 }, { 11139, 1 } }, tool = 375 },
    [13702] = { name = "Runed Truesilver Rod", t = { 1, 220, 240, 260 }, fee = 4000, train = 200, r = { { 11144, 1 }, { 7971, 1 }, { 11135, 1 }, { 11137, 1 } }, out = { 11145, 1 }, oq = 1, bop = true },
    [13746] = { name = "Enchant Cloak - Greater Defense", t = { 1, 225, 245, 265 }, fee = 4200, train = 205, r = { { 11137, 1 } }, tool = 376 },
    [13794] = { name = "Enchant Cloak - Resistance", t = { 1, 225, 245, 265 }, fee = 4200, train = 205, r = { { 11174, 1 } }, tool = 376 },
    [13815] = { name = "Enchant Gloves - Agility", t = { 1, 230, 250, 270 }, fee = 4400, train = 210, r = { { 11137, 1 } }, tool = 376 },
    [13817] = { name = "Enchant Shield - Stamina", t = { 1, 230, 250, 270 }, scroll = 11202, train = 210, sq = 2, r = { { 11137, 2 } }, tool = 376 },
    [13822] = { name = "Enchant Bracer - Intellect", t = { 1, 230, 250, 270 }, fee = 4400, train = 210, r = { { 11174, 1 } }, tool = 376 },
    [13836] = { name = "Enchant Boots - Stamina", t = { 1, 235, 255, 275 }, fee = 4600, train = 215, r = { { 11137, 2 } }, tool = 376 },
    [13841] = { name = "Enchant Gloves - Advanced Mining", t = { 1, 235, 255, 275 }, scroll = 11203, train = 215, sq = 2, r = { { 11137, 2 }, { 6037, 1 } }, tool = 376 },
    [13846] = { name = "Enchant Bracer - Greater Spirit", t = { 1, 240, 260, 280 }, scroll = 11204, train = 220, sq = 2, r = { { 11174, 1 }, { 11137, 1 } }, tool = 376 },
    [13858] = { name = "Enchant Chest - Superior Stamina", t = { 1, 240, 260, 280 }, fee = 4800, train = 220, r = { { 11137, 3 } }, tool = 376 },
    [13868] = { name = "Enchant Gloves - Advanced Herbalism", t = { 1, 245, 265, 285 }, scroll = 11205, train = 225, sq = 2, r = { { 11137, 2 }, { 8838, 1 } }, tool = 376 },
    [13882] = { name = "Enchant Cloak - Lesser Agility", t = { 1, 245, 265, 285 }, scroll = 11206, train = 225, sq = 2, r = { { 11174, 1 } }, tool = 376 },
    [13887] = { name = "Enchant Gloves - Strength", t = { 1, 245, 265, 285 }, fee = 5000, train = 225, r = { { 11174, 1 }, { 11137, 2 } }, tool = 376 },
    [13890] = { name = "Enchant Boots - Minor Speed", t = { 1, 245, 265, 285 }, fee = 5000, train = 225, r = { { 11177, 1 }, { 7909, 1 }, { 11174, 1 } }, tool = 376 },
    [13898] = { name = "Enchant Weapon - Fiery Weapon", t = { 1, 285, 305, 325 }, scroll = 11207, train = 265, sq = 2, r = { { 11177, 2 }, { 7078, 1 } }, tool = 376 },
    [13905] = { name = "Enchant Shield - Greater Spirit", t = { 1, 250, 270, 290 }, fee = 5400, train = 230, r = { { 11174, 2 }, { 11176, 1 } }, tool = 376 },
    [13915] = { name = "Enchant Weapon - Demonslaying", t = { 1, 250, 270, 290 }, scroll = 11208, train = 230, sq = 2, r = { { 11177, 1 }, { 11176, 1 }, { 9224, 1 } }, tool = 376 },
    [13917] = { name = "Enchant Chest - Superior Intellect", t = { 1, 250, 270, 290 }, fee = 5400, train = 230, r = { { 11175, 1 } }, tool = 376 },
    [13931] = { name = "Enchant Bracer - Deflection", t = { 1, 255, 275, 295 }, scroll = 11223, train = 235, scrollPrice = 5800, sq = 2, r = { { 11174, 2 }, { 11176, 1 } }, tool = 376 },
    [13933] = { name = "Enchant Shield - Frost Resistance", t = { 1, 255, 275, 295 }, scroll = 11224, train = 235, sq = 2, r = { { 11178, 1 }, { 3829, 1 } }, tool = 376 },
    [13935] = { name = "Enchant Boots - Agility", t = { 1, 255, 275, 295 }, fee = 5800, train = 235, r = { { 11175, 1 } }, tool = 376 },
    [13937] = { name = "Enchant 2H Weapon - Greater Impact", t = { 1, 260, 280, 300 }, fee = 6200, train = 240, r = { { 11178, 1 }, { 11176, 1 } }, tool = 376 },
    [13939] = { name = "Enchant Bracer - Greater Strength", t = { 1, 260, 280, 300 }, fee = 6200, train = 240, r = { { 11176, 1 }, { 11174, 2 } }, tool = 376 },
    [13941] = { name = "Enchant Chest - Stats", t = { 1, 265, 285, 305 }, fee = 6200, train = 245, r = { { 11178, 1 }, { 11176, 1 }, { 11175, 1 } }, tool = 376 },
    [13943] = { name = "Enchant Weapon - Greater Striking", t = { 1, 265, 285, 305 }, fee = 6200, train = 245, r = { { 11178, 1 }, { 11175, 1 } }, tool = 376 },
    [13945] = { name = "Enchant Bracer - Greater Stamina", t = { 1, 265, 285, 305 }, scroll = 11225, train = 245, sq = 2, r = { { 11176, 3 } }, tool = 376 },
    [13947] = { name = "Enchant Gloves - Riding Skill", t = { 1, 270, 290, 310 }, scroll = 11226, train = 250, sq = 2, r = { { 11178, 1 }, { 11176, 2 } }, tool = 376 },
    [13948] = { name = "Enchant Gloves - Minor Haste", t = { 1, 270, 290, 310 }, fee = 6500, train = 250, r = { { 11178, 1 }, { 8153, 1 } }, tool = 376 },
    [14293] = { name = "Lesser Magic Wand", t = { 1, 75, 95, 115 }, fee = 50, train = 10, r = { { 4470, 1 }, { 10938, 1 } }, tool = 373, out = { 11287, 1 }, oq = 2 },
    [14807] = { name = "Greater Magic Wand", t = { 1, 110, 130, 150 }, fee = 200, train = 70, r = { { 4470, 1 }, { 10938, 2 } }, tool = 373, out = { 11288, 1 }, oq = 2 },
    [14809] = { name = "Lesser Mystic Wand", t = { 1, 175, 195, 215 }, fee = 2600, train = 155, r = { { 11291, 1 }, { 11134, 1 } }, tool = 375, out = { 11289, 1 }, oq = 2 },
    [14810] = { name = "Greater Mystic Wand", t = { 1, 195, 215, 235 }, fee = 3000, train = 175, r = { { 11291, 1 }, { 11134, 1 }, { 11137, 1 } }, tool = 375, out = { 217287, 1 }, oq = 2 },
    [15596] = { name = "Smoking Heart of the Mountain", t = { 1, 285, 305, 325 }, scroll = 11813, train = 265, sq = 2, r = { { 11382, 1 }, { 7078, 1 }, { 14343, 3 } }, out = { 11811, 1 }, oq = 1 },
    [17180] = { name = "Enchanted Thorium", t = { 1, 250, 255, 260 }, fee = 10000, train = 250, r = { { 12359, 1 }, { 11176, 3 } }, tool = 376, out = { 12655, 1 }, oq = 1 },
    [17181] = { name = "Enchanted Leather", t = { 1, 250, 255, 260 }, fee = 10000, train = 250, r = { { 8170, 1 }, { 16202, 1 } }, tool = 376, out = { 12810, 1 }, oq = 1 },
    [20008] = { name = "Enchant Bracer - Greater Intellect", t = { 1, 275, 295, 315 }, scroll = 16214, train = 255, sq = 2, r = { { 16202, 2 } }, tool = 376 },
    [20009] = { name = "Enchant Bracer - Superior Spirit", t = { 1, 290, 310, 330 }, scroll = 16218, train = 270, sq = 2, r = { { 16202, 2 }, { 11176, 7 } }, tool = 376 },
    [20010] = { name = "Enchant Bracer - Superior Strength", t = { 1, 315, 335, 355 }, scroll = 16246, train = 295, sq = 2, r = { { 16204, 6 }, { 16203, 6 } }, tool = 376 },
    [20011] = { name = "Enchant Bracer - Superior Stamina", t = { 1, 320, 340, 360 }, scroll = 16251, train = 300, sq = 2, r = { { 16204, 15 } }, tool = 376 },
    [20012] = { name = "Enchant Gloves - Greater Agility", t = { 1, 290, 310, 330 }, scroll = 16219, train = 270, sq = 2, r = { { 16202, 2 }, { 16204, 2 } }, tool = 376 },
    [20013] = { name = "Enchant Gloves - Greater Strength", t = { 1, 315, 335, 355 }, scroll = 16244, train = 295, sq = 2, r = { { 16203, 4 }, { 16204, 4 } }, tool = 376 },
    [20014] = { name = "Enchant Cloak - Greater Resistance", t = { 1, 285, 305, 325 }, scroll = 16216, train = 265, sq = 2, r = { { 16202, 1 }, { 7077, 1 }, { 7075, 1 }, { 7079, 1 }, { 7081, 1 }, { 7972, 1 } }, tool = 376 },
    [20015] = { name = "Enchant Cloak - Superior Defense", t = { 1, 305, 325, 345 }, scroll = 16224, train = 285, scrollPrice = 20000, sq = 1, r = { { 16204, 8 } }, tool = 376 },
    [20016] = { name = "Enchant Shield - Superior Spirit", t = { 1, 300, 320, 340 }, scroll = 16222, train = 280, sq = 2, r = { { 16203, 2 }, { 16204, 4 } }, tool = 376 },
    [20017] = { name = "Enchant Shield - Greater Stamina", t = { 1, 285, 305, 325 }, scroll = 16217, train = 265, scrollPrice = 12000, sq = 1, r = { { 11176, 6 } }, tool = 376 },
    [20020] = { name = "Enchant Boots - Greater Stamina", t = { 1, 280, 300, 320 }, scroll = 16215, train = 260, sq = 2, r = { { 11176, 6 } }, tool = 376 },
    [20023] = { name = "Enchant Boots - Greater Agility", t = { 1, 315, 335, 355 }, scroll = 16245, train = 295, sq = 2, r = { { 16203, 8 } }, tool = 376 },
    [20024] = { name = "Enchant Boots - Spirit", t = { 1, 295, 315, 335 }, scroll = 16220, train = 275, sq = 2, r = { { 16203, 2 }, { 16202, 1 } }, tool = 376 },
    [20025] = { name = "Enchant Chest - Greater Stats", t = { 1, 320, 340, 360 }, scroll = 16253, train = 300, sq = 2, r = { { 14344, 4 }, { 16204, 15 }, { 16203, 10 } }, tool = 377 },
    [20026] = { name = "Enchant Chest - Major Stamina", t = { 1, 295, 315, 335 }, scroll = 16221, train = 275, scrollPrice = 16000, sq = 1, r = { { 16204, 6 }, { 14343, 1 } }, tool = 376 },
    [20028] = { name = "Enchant Chest - Major Intellect", t = { 1, 310, 330, 350 }, scroll = 16242, train = 290, sq = 2, r = { { 16203, 3 }, { 14343, 1 } }, tool = 376 },
    [20029] = { name = "Enchant Weapon - Icy Chill", t = { 1, 305, 325, 345 }, scroll = 16223, train = 285, sq = 2, r = { { 14343, 4 }, { 7080, 1 }, { 7082, 1 }, { 13467, 1 } }, tool = 376 },
    [20030] = { name = "Enchant 2H Weapon - Superior Impact", t = { 1, 315, 335, 355 }, scroll = 16247, train = 295, sq = 2, r = { { 14344, 4 }, { 16204, 10 } }, tool = 377 },
    [20031] = { name = "Enchant Weapon - Superior Striking", t = { 1, 320, 340, 360 }, scroll = 16250, train = 300, sq = 2, r = { { 14344, 2 }, { 16203, 10 } }, tool = 377 },
    [20032] = { name = "Enchant Weapon - Lifestealing", t = { 1, 320, 340, 360 }, scroll = 16254, train = 300, sq = 3, r = { { 14344, 6 }, { 12808, 6 }, { 12803, 6 } }, tool = 377 },
    [20033] = { name = "Enchant Weapon - Unholy Weapon", t = { 1, 315, 335, 355 }, scroll = 16248, train = 295, sq = 2, r = { { 14344, 4 }, { 12808, 4 } }, tool = 377 },
    [20034] = { name = "Enchant Weapon - Crusader", t = { 1, 320, 340, 360 }, scroll = 16252, train = 300, sq = 2, r = { { 14344, 4 }, { 12811, 2 } }, tool = 377 },
    [20035] = { name = "Enchant 2H Weapon - Major Spirit", t = { 1, 320, 340, 360 }, scroll = 16255, train = 300, sq = 2, r = { { 16203, 12 }, { 14344, 2 } }, tool = 377 },
    [20036] = { name = "Enchant 2H Weapon - Major Intellect", t = { 1, 320, 340, 360 }, scroll = 16249, train = 300, sq = 2, r = { { 16203, 12 }, { 14344, 2 } }, tool = 377 },
    [20051] = { name = "Runed Arcanite Rod", t = { 1, 310, 330, 350 }, scroll = 16243, train = 290, scrollPrice = 22000, sq = 1, r = { { 16206, 1 }, { 13926, 1 }, { 16204, 10 }, { 16203, 4 }, { 14343, 4 }, { 14344, 2 } }, out = { 16207, 1 }, oq = 1, bop = true },
    [21931] = { name = "Enchant Weapon - Winter's Might", t = { 1, 210, 230, 250 }, scroll = 17725, train = 190, sq = 2, r = { { 11135, 1 }, { 11137, 1 }, { 11139, 1 }, { 3819, 1 } }, tool = 375 },
    [22749] = { name = "Enchant Weapon - Spell Power", t = { 1, 320, 340, 360 }, scroll = 18259, train = 300, sq = 3, r = { { 14344, 4 }, { 16203, 12 }, { 7078, 4 }, { 7080, 4 }, { 7082, 4 }, { 13926, 2 } }, tool = 377 },
    [22750] = { name = "Enchant Weapon - Healing Power", t = { 1, 320, 340, 360 }, scroll = 18260, train = 300, sq = 3, r = { { 14344, 4 }, { 16203, 8 }, { 12803, 6 }, { 7080, 6 }, { 12811, 1 } }, tool = 377 },
    [23799] = { name = "Enchant Weapon - Strength", t = { 1, 310, 330, 350 }, scroll = 19444, train = 290, rep = { 59, 4 }, sq = 1, r = { { 14344, 6 }, { 16203, 6 }, { 16204, 4 }, { 7076, 2 } }, tool = 377 },
    [23800] = { name = "Enchant Weapon - Agility", t = { 1, 310, 330, 350 }, scroll = 19445, train = 290, scrollPrice = 30000, rep = { 576, 5 }, sq = 1, r = { { 14344, 6 }, { 16203, 6 }, { 16204, 4 }, { 7082, 2 } }, tool = 377 },
    [23801] = { name = "Enchant Bracer - Mana Regeneration", t = { 1, 310, 330, 350 }, scroll = 19446, train = 290, scrollPrice = 30000, rep = { 529, 5 }, sq = 1, r = { { 16204, 16 }, { 16203, 4 }, { 7080, 2 } }, tool = 377 },
    [23802] = { name = "Enchant Bracer - Healing Power", t = { 1, 320, 340, 360 }, scroll = 19447, train = 300, scrollPrice = 60000, rep = { 529, 6 }, sq = 1, r = { { 14344, 2 }, { 16204, 20 }, { 16203, 4 }, { 12803, 6 } }, tool = 377 },
    [23803] = { name = "Enchant Weapon - Mighty Spirit", t = { 1, 320, 340, 360 }, scroll = 19448, train = 300, rep = { 59, 5 }, sq = 1, r = { { 14344, 10 }, { 16203, 8 }, { 16204, 15 } }, tool = 377 },
    [23804] = { name = "Enchant Weapon - Mighty Intellect", t = { 1, 320, 340, 360 }, scroll = 19449, train = 300, rep = { 59, 6 }, sq = 1, r = { { 14344, 15 }, { 16203, 12 }, { 16204, 20 } }, tool = 377 },
    [25072] = { name = "Enchant Gloves - Threat", t = { 1, 320, 340, 360 }, scroll = 20726, train = 300, sq = 3, r = { { 20725, 4 }, { 14344, 6 }, { 18512, 8 } }, tool = 377 },
    [25073] = { name = "Enchant Gloves - Shadow Power", t = { 1, 320, 340, 360 }, scroll = 20727, train = 300, sq = 3, r = { { 20725, 3 }, { 14344, 10 }, { 12808, 6 } }, tool = 377 },
    [25074] = { name = "Enchant Gloves - Frost Power", t = { 1, 320, 340, 360 }, scroll = 20728, train = 300, sq = 3, r = { { 20725, 3 }, { 14344, 10 }, { 7080, 4 } }, tool = 377 },
    [25078] = { name = "Enchant Gloves - Fire Power", t = { 1, 320, 340, 360 }, scroll = 20729, train = 300, sq = 3, r = { { 20725, 2 }, { 14344, 10 }, { 7078, 4 } }, tool = 377 },
    [25079] = { name = "Enchant Gloves - Healing Power", t = { 1, 320, 340, 360 }, scroll = 20730, train = 300, sq = 3, r = { { 20725, 3 }, { 14344, 8 }, { 12811, 1 } }, tool = 377 },
    [25080] = { name = "Enchant Gloves - Superior Agility", t = { 1, 320, 340, 360 }, scroll = 20731, train = 300, sq = 3, r = { { 20725, 3 }, { 14344, 8 }, { 7082, 4 } }, tool = 377 },
    [25081] = { name = "Enchant Cloak - Greater Fire Resistance", t = { 1, 320, 340, 360 }, scroll = 229008, train = 300, rep = { 59, 5 }, sq = 1, r = { { 20725, 3 }, { 14344, 8 }, { 7078, 4 } }, tool = 377 },
    [25082] = { name = "Enchant Cloak - Greater Nature Resistance", t = { 1, 320, 340, 360 }, scroll = 229009, train = 300, rep = { 59, 5 }, sq = 1, r = { { 20725, 2 }, { 14344, 8 }, { 12803, 4 } }, tool = 377 },
    [25083] = { name = "Enchant Cloak - Stealth", t = { 1, 320, 340, 360 }, scroll = 20734, train = 300, sq = 3, r = { { 20725, 3 }, { 14344, 8 }, { 13468, 2 } }, tool = 377 },
    [25084] = { name = "Enchant Cloak - Subtlety", t = { 1, 320, 340, 360 }, scroll = 20735, train = 300, sq = 3, r = { { 20725, 4 }, { 14344, 6 }, { 11754, 2 } }, tool = 377 },
    [25086] = { name = "Enchant Cloak - Dodge", t = { 1, 320, 340, 360 }, scroll = 20736, train = 300, sq = 3, r = { { 20725, 3 }, { 14344, 8 }, { 12809, 8 } }, tool = 377 },
    [25124] = { name = "Minor Wizard Oil", t = { 1, 30, 47, 65 }, scroll = 20758, train = 5, scrollPrice = 500, sq = 1, r = { { 10940, 1 }, { 17034, 1 }, { 3371, 1 } }, tool = 373, out = { 20744, 1 }, oq = 1 },
    [25125] = { name = "Minor Mana Oil", t = { 1, 160, 170, 180 }, scroll = 20752, train = 150, scrollPrice = 3000, sq = 1, r = { { 11083, 1 }, { 17034, 2 }, { 3372, 1 } }, tool = 374, out = { 20745, 1 }, oq = 1 },
    [25126] = { name = "Lesser Wizard Oil", t = { 1, 210, 220, 230 }, scroll = 20753, train = 200, scrollPrice = 4000, sq = 1, r = { { 11137, 1 }, { 17035, 2 }, { 3372, 1 } }, tool = 375, out = { 20746, 1 }, oq = 1 },
    [25127] = { name = "Lesser Mana Oil", t = { 1, 260, 270, 280 }, scroll = 20754, train = 250, scrollPrice = 10000, sq = 1, r = { { 11176, 1 }, { 8831, 1 }, { 8925, 1 } }, tool = 376, out = { 20747, 1 }, oq = 1 },
    [25128] = { name = "Wizard Oil", t = { 1, 285, 295, 305 }, scroll = 20755, train = 275, scrollPrice = 20000, sq = 1, r = { { 16204, 3 }, { 4625, 2 }, { 8925, 1 } }, tool = 376, out = { 20750, 1 }, oq = 1 },
    [25129] = { name = "Brilliant Wizard Oil", t = { 1, 310, 320, 330 }, scroll = 20756, train = 300, scrollPrice = 40000, rep = { 270, 5 }, sq = 1, r = { { 14344, 2 }, { 4625, 3 }, { 18256, 1 } }, tool = 377, out = { 20749, 1 }, oq = 1 },
    [25130] = { name = "Brilliant Mana Oil", t = { 1, 310, 320, 330 }, scroll = 20757, train = 300, scrollPrice = 40000, rep = { 270, 4 }, sq = 1, r = { { 14344, 2 }, { 8831, 3 }, { 18256, 1 } }, tool = 377, out = { 20748, 1 }, oq = 1 },
    [27837] = { name = "Enchant 2H Weapon - Agility", t = { 1, 310, 330, 350 }, scroll = 22392, train = 290, scrollPrice = 25000, rep = { 576, 4 }, sq = 1, r = { { 14344, 10 }, { 16203, 6 }, { 16204, 14 }, { 7082, 4 } }, tool = 377 },
    [430409] = { name = "Blackfathom Mana Oil", t = { 1, 100, 110, 120 }, scroll = 211849, train = 90, sq = 1, r = { { 3372, 1 }, { 10939, 1 }, { 10940, 5 } }, tool = 374, out = { 211848, 1 }, oq = 1 },
    [435481] = { name = "Enchant Weapon - Dismantle", t = { 1, 200, 217, 235 }, scroll = 215129, train = 225, sq = 4, r = { { 11174, 4 }, { 5637, 2 }, { 11177, 2 } }, tool = 375 },
    [435903] = { name = "Enchant Chest - Retricutioner", t = { 1, 200, 220, 240 }, scroll = 215138, train = 225, sq = 4, r = { { 11177, 1 }, { 11176, 2 } }, tool = 375 },
    [439156] = { name = "Sigil of Innovation", t = { 1, 225, 227, 230 }, scroll = 215141, train = 225, sq = 4, r = { { 11137, 5 } }, tool = 375, out = { 217308, 1 }, oq = 2, bop = true },
    [446243] = { name = "Sigil of Living Dreams", t = { 1, 250, 255, 260 }, r = { { 11176, 5 } }, tool = 376, out = { 221028, 1 }, oq = 1 },
    [448624] = { name = "Scroll of Spatial Mending", t = { 1, 120, 140, 160 }, scroll = 223163, train = 120, sq = 2, r = { { 4470, 1 }, { 10940, 4 } }, tool = 374, out = { 220792, 1 }, oq = 2 },
    [463866] = { name = "Sigil of Flowing Waters", t = { 1, 305, 312, 320 }, scroll = 228979, train = 290, rep = { 749, 6 }, sq = 4, r = { { 16204, 1 } }, tool = 376, out = { 228978, 1 }, oq = 3, bop = true },
    [463869] = { name = "Conductive Shield Coating", t = { 1, 285, 295, 305 }, scroll = 228981, train = 275, sq = 1, r = { { 16204, 2 }, { 4625, 1 }, { 8925, 1 } }, tool = 376, out = { 228980, 1 }, oq = 1 },
    [463871] = { name = "Enchant Shield - Law of Nature", t = { 1, 320, 340, 360 }, scroll = 228982, train = 300, rep = { 576, 6 }, sq = 3, r = { { 14344, 4 }, { 16203, 12 }, { 7078, 4 }, { 7080, 4 }, { 7076, 1 }, { 12811, 1 } }, tool = 377 },
    [471400] = { name = "Magnificent Trollshine", t = { 1, 310, 320, 330 }, scroll = 232610, train = 300, rep = { 270, 5 }, sq = 1, r = { { 8151, 3 }, { 8152, 3 }, { 14344, 2 }, { 18256, 1 } }, tool = 377, out = { 232611, 1 }, oq = 1 },
    [1213607] = { name = "Scroll: Wrath of the Swarm", t = { 1, 320, 340, 360 }, scroll = 234271, train = 310, sq = 1, r = { { 16203, 1 }, { 14047, 1 } }, tool = 377, out = { 233995, 1 }, oq = 1 },
    [1213622] = { name = "Enchant Gloves - Holy Power", t = { 1, 320, 340, 360 }, scroll = 249536, train = 300, sq = 2, favor = 240, favorRep = 6, r = { { 20725, 2 }, { 14344, 5 }, { 13180, 5 }, { 12735, 2 } }, tool = 377 },
    [1213626] = { name = "Enchant Gloves - Arcane Power", t = { 1, 320, 340, 360 }, scroll = 249534, train = 300, sq = 2, favor = 240, favorRep = 6, r = { { 20725, 2 }, { 14344, 5 }, { 12753, 2 } }, tool = 377 },
    [1217189] = { name = "Enchant Bracer - Spell Power", t = { 1, 320, 340, 360 }, scroll = 235526, train = 310, sq = 1, r = { { 14344, 2 }, { 16204, 20 }, { 16203, 4 }, { 7080, 2 }, { 7078, 2 }, { 7082, 2 } }, tool = 377 },
    [1219577] = { name = "Enchant Off-Hand - Superior Intellect", t = { 1, 320, 340, 360 }, scroll = 274391, train = 300, sq = 3, r = { { 20725, 2 }, { 16204, 18 }, { 7082, 2 } }, tool = 377 },
    [1219578] = { name = "Enchant Off-Hand - Excellent Spirit", t = { 1, 320, 340, 360 }, scroll = 274392, train = 300, sq = 3, r = { { 20725, 2 }, { 16204, 18 }, { 7080, 2 } }, tool = 377 },
    [1219579] = { name = "Enchant Off-Hand - Wisdom", t = { 1, 320, 340, 360 }, scroll = 274393, train = 300, sq = 3, favor = 240, favorRep = 6, r = { { 14344, 6 }, { 16204, 18 }, { 7082, 1 }, { 7080, 1 } }, tool = 377 },
    [1219580] = { name = "Enchant 2H Weapon - Spellblasting", t = { 1, 320, 340, 360 }, scroll = 274394, train = 300, sq = 3, favor = 240, favorRep = 6, r = { { 20725, 3 }, { 16204, 24 }, { 12938, 1 }, { 8831, 6 } }, tool = 377 },
    [1219581] = { name = "Enchant Shield - Excellent Stamina", t = { 1, 320, 340, 360 }, scroll = 274395, train = 300, sq = 3, r = { { 14344, 6 }, { 16204, 18 }, { 7076, 2 } }, tool = 377 },
    [1219587] = { name = "Enchant Cloak - Agility", t = { 1, 320, 340, 360 }, scroll = 274399, train = 300, sq = 3, favor = 240, favorRep = 6, r = { { 16203, 3 }, { 16204, 9 }, { 7078, 1 } }, tool = 377 },
    [1220623] = { name = "Enchant Shield - Critical Strike", t = { 1, 320, 340, 360 }, scroll = 274400, train = 300, sq = 3, r = { { 14344, 5 }, { 16204, 15 }, { 12938, 1 } }, tool = 377 },
    [1220624] = { name = "Enchant Bracer - Greater Spellpower", t = { 1, 320, 340, 360 }, scroll = 274401, train = 300, sq = 3, favor = 240, favorRep = 6, r = { { 16203, 3 }, { 16204, 9 }, { 12808, 12 }, { 8831, 2 } }, tool = 377 },
    [1230643] = { name = "Enchanted Lute", t = { 1, 20, 22, 25 }, fee = 0, train = 20, r = { { 4470, 1 }, { 10940, 1 } }, out = { 279976, 1 }, oq = 1 },
    [1231128] = { name = "Enchant Weapon - Grand Crusader", t = { 1, 305, 307, 310 }, scroll = 241191, train = 280, sq = 3, r = { { 14344, 5 }, { 12811, 2 }, { 20725, 2 }, { 12938, 1 } }, tool = 377 },
    [1231139] = { name = "Enchant 2H Weapon - Grand Arcanist", t = { 1, 305, 307, 310 }, scroll = 241195, train = 280, sq = 3, r = { { 14344, 10 }, { 12811, 4 }, { 20725, 4 }, { 12938, 1 } }, tool = 377 },
    [1231164] = { name = "Enchant Weapon - Grand Sorcerer", t = { 1, 305, 307, 310 }, scroll = 241201, train = 280, sq = 3, r = { { 14344, 6 }, { 12811, 3 }, { 20725, 2 }, { 12938, 1 } }, tool = 377 },
    [1232172] = { name = "Enchant 2H Weapon - Grand Inquisitor", t = { 1, 305, 307, 310 }, scroll = 242361, train = 280, sq = 3, r = { { 14344, 10 }, { 12811, 6 }, { 20725, 4 }, { 12938, 1 } }, tool = 377 },
    [1245320] = { name = "Dust to Motes", t = { 1, 10, 12, 15 }, basic = true, r = { { 10940, 1 } }, tool = 373, out = { 247786, 3 }, oq = 1 },
    [1245321] = { name = "Novice's Practice Wand", t = { 1, 10, 12, 15 }, basic = true, r = { { 4470, 1 }, { 247786, 1 } }, tool = 373, out = { 247789, 1 }, oq = 1 },
    [1248458] = { name = "Enchant Bracer - Minor Intellect", t = { 1, 110, 130, 150 }, scroll = 249474, train = 70, sq = 2, r = { { 10938, 1 } }, tool = 373 },
    [1248459] = { name = "Enchant Bracer - Minor Healing Power", t = { 1, 120, 140, 160 }, scroll = 249475, train = 90, sq = 2, r = { { 10938, 2 } }, tool = 373 },
    [1248460] = { name = "Enchant Bracer - Lesser Agility", t = { 1, 165, 185, 205 }, scroll = 249486, train = 140, scrollPrice = 10000, sq = 2, r = { { 11134, 1 } }, tool = 374 },
    [1248461] = { name = "Twisted Nether Wand", t = { 1, 205, 225, 245 }, scroll = 249487, train = 185, sq = 2, r = { { 11174, 1 }, { 11176, 1 }, { 11291, 1 } }, tool = 375, out = { 249144, 1 }, oq = 2 },
    [1248497] = { name = "Enchant Bracer - Agility", t = { 1, 225, 245, 265 }, scroll = 249488, train = 190, sq = 2, r = { { 11137, 1 } }, tool = 375 },
    [1248498] = { name = "Enchant Bracer - Lesser Healing Power", t = { 1, 225, 245, 265 }, scroll = 249489, train = 205, scrollPrice = 10000, sq = 2, r = { { 11134, 2 } }, tool = 376 },
    [1248500] = { name = "Enchant Bracer - Greater Agility", t = { 1, 260, 280, 300 }, scroll = 249514, train = 240, sq = 2, r = { { 11176, 3 }, { 11174, 1 } }, tool = 376 },
    [1248505] = { name = "Lesser Eternal Wand", t = { 1, 265, 285, 305 }, scroll = 249515, train = 245, sq = 2, r = { { 16202, 1 }, { 11176, 1 }, { 11291, 1 } }, tool = 376, out = { 249232, 1 }, oq = 2 },
    [1248509] = { name = "Dreambough Wand", t = { 1, 235, 255, 275 }, scroll = 249512, train = 215, sq = 2, r = { { 11174, 2 }, { 11137, 1 }, { 11291, 1 } }, tool = 376, out = { 249234, 1 }, oq = 2 },
    [1248510] = { name = "Enchant 2H Weapon - Lesser Agility", t = { 1, 230, 250, 270 }, scroll = 249511, train = 210, sq = 2, r = { { 11137, 2 }, { 11139, 1 }, { 11174, 1 } }, tool = 376 },
    [1248511] = { name = "Enchant 2H Weapon - Lesser Strength", t = { 1, 240, 260, 280 }, scroll = 249513, train = 220, sq = 2, r = { { 11137, 1 }, { 11139, 1 }, { 11174, 2 } }, tool = 376 },
    [1248515] = { name = "Greater Eternal Wand", t = { 1, 285, 295, 305 }, scroll = 249522, train = 275, sq = 2, r = { { 16203, 2 }, { 16204, 1 }, { 11291, 1 } }, tool = 376, out = { 249237, 1 }, oq = 2 },
    [1248528] = { name = "Enchant Gloves - Advanced Skinning", t = { 1, 270, 290, 310 }, scroll = 249516, train = 250, sq = 2, r = { { 11176, 2 }, { 15407, 1 } }, tool = 376 },
    [1248599] = { name = "Enchant Bracer - Superior Agility", t = { 1, 315, 335, 355 }, scroll = 249524, train = 295, sq = 2, r = { { 16204, 3 }, { 16203, 3 }, { 14344, 1 } }, tool = 376 },
    [1248607] = { name = "Enchant 2H Weapon - Mighty Spell Power", t = { 1, 320, 340, 360 }, scroll = 249525, train = 300, sq = 2, favor = 240, favorRep = 6, r = { { 248819, 4 }, { 16203, 6 }, { 7076, 4 }, { 12808, 4 }, { 20725, 4 }, { 248820, 2 } }, tool = 377 },
    [1248636] = { name = "Enchant 2H Weapon - Mighty Healing Power", t = { 1, 320, 340, 360 }, scroll = 249526, train = 300, sq = 2, favor = 240, favorRep = 6, r = { { 248819, 4 }, { 16203, 6 }, { 249726, 4 }, { 249274, 4 }, { 20725, 4 }, { 248820, 4 } }, tool = 377 },
    [1248640] = { name = "Enchant Gloves - Superior Strength", t = { 1, 320, 340, 360 }, scroll = 274398, train = 300, sq = 3, favor = 240, favorRep = 6, r = { { 20725, 4 }, { 16203, 8 }, { 7076, 4 } }, tool = 377 },
    [1248645] = { name = "Enchant Gloves - Natural Power", t = { 1, 320, 340, 360 }, scroll = 249535, train = 300, sq = 2, favor = 240, favorRep = 6, r = { { 20725, 2 }, { 14344, 5 }, { 248822, 4 } }, tool = 377 },
    [1248650] = { name = "Brilliant Wand", t = { 1, 320, 340, 360 }, scroll = 249537, train = 275, sq = 3, favor = 180, favorRep = 6, r = { { 16203, 1 }, { 16204, 3 }, { 14344, 2 }, { 11291, 1 } }, tool = 377, out = { 249385, 1 }, oq = 3, bop = true },
    [1248661] = { name = "Enchant Bracer - Superior Intellect", t = { 1, 320, 340, 360 }, scroll = 249538, train = 300, sq = 2, favor = 240, favorRep = 6, r = { { 16203, 10 } }, tool = 376 },
    [1248665] = { name = "Enchant Bracer - Superior Deflection", t = { 1, 320, 340, 360 }, scroll = 249539, train = 300, sq = 2, favor = 240, favorRep = 6, r = { { 14344, 3 } }, tool = 376 },
    [1248668] = { name = "Enchant 2H Weapon - Strength", t = { 1, 295, 297, 300 }, scroll = 249523, train = 290, sq = 2, r = { { 14344, 8 }, { 16203, 10 }, { 16204, 8 }, { 12363, 4 } }, tool = 377 },
    [1248703] = { name = "Glimmering Staff", t = { 1, 140, 160, 180 }, scroll = 249482, train = 140, sq = 3, favor = 45, r = { { 11084, 4 }, { 10978, 2 }, { 11291, 4 }, { 11082, 1 }, { 10940, 5 }, { 249391, 3 } }, tool = 374, out = { 249392, 1 }, oq = 3, bop = true },
    [1248739] = { name = "Soulstaff", t = { 1, 140, 160, 180 }, scroll = 249483, train = 140, sq = 3, favor = 45, r = { { 11084, 2 }, { 10978, 1 }, { 11291, 4 }, { 11082, 1 }, { 11083, 6 }, { 1210, 2 } }, tool = 374, out = { 249393, 1 }, oq = 3, bop = true },
    [1248745] = { name = "Orb of Mystic Insight", t = { 1, 140, 160, 180 }, scroll = 249484, train = 140, sq = 3, favor = 45, r = { { 10978, 2 }, { 11082, 2 }, { 10940, 5 } }, tool = 374, out = { 249394, 1 }, oq = 3, bop = true },
    [1248748] = { name = "Orb of Souls", t = { 1, 140, 160, 180 }, scroll = 249485, train = 140, sq = 3, favor = 45, r = { { 10978, 2 }, { 11082, 2 }, { 11083, 2 } }, tool = 374, out = { 249395, 1 }, oq = 3, bop = true },
    [1248752] = { name = "Mystic Mushroom", t = { 1, 140, 160, 180 }, scroll = 249476, train = 130, sq = 3, favor = 45, r = { { 10978, 1 }, { 10939, 2 }, { 10940, 5 }, { 4605, 1 } }, tool = 374, out = { 249396, 1 }, oq = 3, bop = true },
    [1248754] = { name = "Tenets of the Silver Hand", t = { 1, 140, 160, 180 }, scroll = 249477, train = 130, sq = 3, favor = 45, r = { { 11084, 1 }, { 10939, 1 }, { 10940, 2 }, { 3013, 5 } }, tool = 374, out = { 249397, 1 }, oq = 3, bop = true },
    [1248755] = { name = "Polished Driftwood Icon", t = { 1, 140, 160, 180 }, scroll = 249478, train = 130, sq = 3, favor = 45, r = { { 11084, 1 }, { 10939, 2 }, { 10940, 3 }, { 4470, 1 } }, tool = 374, out = { 249398, 1 }, oq = 3, bop = true },
    [1248757] = { name = "Enchant Weapon - Insight", t = { 1, 140, 160, 180 }, scroll = 249479, train = 140, sq = 2, favor = 45, r = { { 10940, 10 }, { 11084, 4 }, { 11082, 4 }, { 249391, 4 }, { 249399, 4 } }, tool = 374 },
    [1248760] = { name = "Enchant Weapon - Recovery", t = { 1, 140, 160, 180 }, scroll = 249480, train = 140, sq = 2, favor = 45, r = { { 11083, 6 }, { 11084, 4 }, { 11082, 6 }, { 249391, 4 }, { 2775, 4 } }, tool = 374 },
    [1248805] = { name = "Enchant Weapon - Revelation", t = { 1, 140, 160, 180 }, scroll = 249481, train = 140, sq = 2, favor = 45, r = { { 11083, 8 }, { 11084, 6 }, { 11082, 2 }, { 249409, 4 }, { 249410, 4 } }, tool = 374 },
    [1248974] = { name = "Talons of Wrath", t = { 1, 225, 245, 265 }, scroll = 249493, train = 210, sq = 3, favor = 120, favorRep = 5, r = { { 11178, 2 }, { 11175, 4 }, { 11176, 6 }, { 249430, 2 }, { 249409, 1 }, { 11291, 1 } }, tool = 374, out = { 249441, 1 }, oq = 3, bop = true },
    [1249006] = { name = "Libram of Invocation", t = { 1, 225, 245, 265 }, scroll = 249494, train = 210, sq = 3, favor = 120, favorRep = 5, r = { { 11178, 3 }, { 11175, 3 }, { 11176, 4 }, { 249430, 2 }, { 249409, 1 }, { 2289, 4 } }, tool = 374, out = { 249442, 1 }, oq = 3, bop = true },
    [1249015] = { name = "Totem of Ancestral Protection", t = { 1, 225, 245, 265 }, scroll = 249495, train = 210, sq = 3, favor = 120, favorRep = 5, r = { { 11178, 4 }, { 11175, 2 }, { 11176, 2 }, { 249432, 4 }, { 249410, 2 }, { 11291, 2 } }, tool = 374, out = { 249443, 1 }, oq = 3, bop = true },
    [1249019] = { name = "Enchant Necklace - Strength", t = { 1, 225, 245, 265 }, scroll = 249496, train = 210, sq = 2, favor = 120, favorRep = 5, r = { { 11175, 4 }, { 11178, 4 }, { 11176, 10 }, { 249410, 4 }, { 249425, 4 } }, tool = 376 },
    [1249057] = { name = "Enchant Necklace - Spell Power", t = { 1, 225, 245, 265 }, scroll = 249502, train = 210, sq = 2, favor = 120, favorRep = 5, r = { { 11175, 5 }, { 11178, 3 }, { 11176, 8 }, { 249409, 4 }, { 249430, 4 } }, tool = 376 },
    [1249058] = { name = "Enchant Necklace - Healing Power", t = { 1, 225, 245, 265 }, scroll = 249503, train = 210, sq = 2, favor = 120, favorRep = 5, r = { { 11175, 3 }, { 11178, 5 }, { 11176, 4 }, { 249391, 4 }, { 249424, 4 } }, tool = 376 },
    [1249059] = { name = "Enchant Necklace - Agility", t = { 1, 225, 245, 265 }, scroll = 249504, train = 210, sq = 2, favor = 120, favorRep = 5, r = { { 11175, 2 }, { 11178, 8 }, { 11176, 6 }, { 249410, 4 }, { 249430, 4 } }, tool = 376 },
    [1249060] = { name = "Enchant Necklace - Deflection", t = { 1, 225, 245, 265 }, scroll = 249505, train = 210, sq = 2, favor = 120, favorRep = 5, r = { { 11175, 8 }, { 11178, 2 }, { 11176, 2 }, { 249409, 4 }, { 249430, 4 } }, tool = 376 },
    [1249061] = { name = "Radiant Staff", t = { 1, 225, 245, 265 }, scroll = 249506, train = 220, sq = 3, favor = 120, favorRep = 5, r = { { 11178, 6 }, { 11177, 2 }, { 11291, 4 }, { 11175, 4 }, { 11176, 6 }, { 249409, 2 }, { 249430, 4 } }, tool = 374, out = { 249453, 1 }, oq = 3, bop = true },
    [1249064] = { name = "Dreamstaff", t = { 1, 225, 245, 265 }, scroll = 249507, train = 220, sq = 3, favor = 120, favorRep = 5, r = { { 11178, 4 }, { 11177, 4 }, { 11291, 4 }, { 11175, 6 }, { 11176, 8 }, { 249409, 2 }, { 249430, 4 } }, tool = 374, out = { 249454, 1 }, oq = 3, bop = true },
    [1249069] = { name = "Truesilver Conduit", t = { 1, 225, 245, 265 }, scroll = 249508, train = 220, sq = 3, favor = 120, favorRep = 5, r = { { 11178, 3 }, { 11177, 1 }, { 11291, 2 }, { 11175, 2 }, { 11176, 3 }, { 249409, 1 }, { 249430, 2 } }, tool = 374, out = { 249455, 1 }, oq = 3, bop = true },
    [1249070] = { name = "Twisting Essence Jar", t = { 1, 225, 245, 265 }, scroll = 249509, train = 220, sq = 3, favor = 120, favorRep = 5, r = { { 6037, 4 }, { 11175, 12 }, { 11135, 12 }, { 249409, 1 }, { 249430, 2 } }, tool = 374, out = { 249456, 1 }, oq = 3, bop = true },
    [1249071] = { name = "Enchant Chest - Absorption", t = { 1, 225, 245, 265 }, scroll = 249510, train = 220, sq = 2, favor = 120, favorRep = 5, r = { { 11176, 10 }, { 11175, 4 }, { 11178, 2 } }, tool = 374 },
    [1249107] = { name = "Frozen Heart of the Mountain", t = { 1, 285, 305, 325 }, scroll = 249519, train = 265, sq = 3, r = { { 11382, 1 }, { 12808, 1 }, { 14343, 3 } }, out = { 249469, 1 }, oq = 3, bop = true },
    [1249112] = { name = "Molten Heart of the Mountain", t = { 1, 285, 305, 325 }, scroll = 249520, train = 265, sq = 3, r = { { 11382, 1 }, { 7076, 1 }, { 14343, 3 } }, out = { 249470, 1 }, oq = 3, bop = true },
    [1249114] = { name = "Dormant Heart of the Mountain", t = { 1, 285, 305, 325 }, scroll = 249521, train = 265, sq = 3, r = { { 11382, 1 }, { 7080, 1 }, { 14343, 3 } }, out = { 249473, 1 }, oq = 3, bop = true },
    [1249128] = { name = "Idol of the Dream", t = { 1, 320, 340, 360 }, scroll = 249529, train = 300, sq = 3, favor = 240, favorRep = 6, r = { { 14344, 2 }, { 16203, 4 }, { 16204, 6 }, { 249431, 8 }, { 249430, 4 }, { 249409, 2 }, { 11291, 4 } }, tool = 377, out = { 220606, 1 }, oq = 3, bop = true },
    [1249152] = { name = "Libram of Holy Alacrity", t = { 1, 320, 340, 360 }, scroll = 249530, train = 300, sq = 3, favor = 240, favorRep = 6, r = { { 14344, 4 }, { 16203, 3 }, { 16204, 4 }, { 249431, 8 }, { 249430, 4 }, { 249409, 2 }, { 10308, 4 } }, tool = 377, out = { 228175, 1 }, oq = 3, bop = true },
    [1249154] = { name = "Totem of Thunder", t = { 1, 320, 340, 360 }, scroll = 249532, train = 300, sq = 3, favor = 240, favorRep = 6, r = { { 14344, 1 }, { 16203, 8 }, { 16204, 10 }, { 249431, 8 }, { 249430, 4 }, { 249409, 2 }, { 11291, 4 } }, tool = 377, out = { 228176, 1 }, oq = 3, bop = true },
    [1263056] = { name = "Arcane Salvager", t = { 1, 140, 142, 145 }, scroll = 273103, train = 140, sq = 2, r = { { 11137, 2 }, { 11174, 1 } }, tool = 376, out = { 279985, 1 }, oq = 1 },
    [1294054] = { name = "Enchant Gloves - Lotus Claw", t = { 1, 295, 297, 300 }, scroll = 274424, train = 295, scrollPrice = 5000, sq = 2, r = { { 248822, 1 }, { 14343, 2 }, { 16204, 12 }, { 16202, 4 } }, tool = 377 },
    [1306520] = { name = "Torch of Light", t = { 1, 310, 317, 325 }, scroll = 279295, train = 300, sq = 4, r = { { 274030, 2 }, { 20725, 1 }, { 14344, 6 }, { 16202, 5 } }, out = { 279246, 1 }, oq = 4 },
    [1306521] = { name = "Steadfast Libram", t = { 1, 310, 317, 325 }, scroll = 279296, train = 300, sq = 4, r = { { 274030, 1 }, { 20725, 1 }, { 16203, 2 }, { 16204, 12 } }, out = { 279247, 1 }, oq = 4 },
    [1306522] = { name = "Libram of Infusion", t = { 1, 310, 317, 325 }, scroll = 279297, train = 300, sq = 4, r = { { 274030, 1 }, { 20725, 1 }, { 16203, 2 }, { 16204, 12 } }, out = { 279248, 1 }, oq = 4 },
    [1306523] = { name = "Totem of Urgency", t = { 1, 310, 317, 325 }, scroll = 279298, train = 300, sq = 4, r = { { 274030, 1 }, { 20725, 1 }, { 16203, 2 }, { 16204, 12 } }, out = { 279249, 1 }, oq = 4 },
    [1306524] = { name = "Idol of Swiftness", t = { 1, 310, 317, 325 }, scroll = 279299, train = 300, sq = 4, r = { { 274030, 1 }, { 20725, 1 }, { 16203, 2 }, { 16204, 12 } }, out = { 279250, 1 }, oq = 4 },
    [1306525] = { name = "Idol of the Ursine Twins", t = { 1, 310, 317, 325 }, scroll = 279300, train = 300, sq = 4, r = { { 274030, 1 }, { 20725, 1 }, { 16203, 2 }, { 16204, 12 } }, out = { 279251, 1 }, oq = 4 },
    [1328948] = { name = "Enchant Boots - Speed", t = { 1, 280, 290, 300 }, scroll = 289560, train = 280, scrollPrice = 6200, sq = 2, r = { { 11178, 2 }, { 11176, 8 }, { 11175, 2 }, { 12361, 1 } }, tool = 376 },
    -- Conversión de esencias (clic derecho en la bolsa): no es receta ni da puntos
    [-1] = { name = "Convertir 3 en 1 mayor", intermediate = true, conversion = true, t = { 1, 1, 1, 1 }, train = 1, r = { { 10938, 3 } }, out = { 10939, 1 } },
    [-2] = { name = "Convertir 1 en 3 menores", intermediate = true, conversion = true, t = { 1, 1, 1, 1 }, train = 1, r = { { 10939, 1 } }, out = { 10938, 3 } },
    [-3] = { name = "Convertir 3 en 1 mayor", intermediate = true, conversion = true, t = { 1, 1, 1, 1 }, train = 1, r = { { 10998, 3 } }, out = { 11082, 1 } },
    [-4] = { name = "Convertir 1 en 3 menores", intermediate = true, conversion = true, t = { 1, 1, 1, 1 }, train = 1, r = { { 11082, 1 } }, out = { 10998, 3 } },
    [-5] = { name = "Convertir 3 en 1 mayor", intermediate = true, conversion = true, t = { 1, 1, 1, 1 }, train = 1, r = { { 11134, 3 } }, out = { 11135, 1 } },
    [-6] = { name = "Convertir 1 en 3 menores", intermediate = true, conversion = true, t = { 1, 1, 1, 1 }, train = 1, r = { { 11135, 1 } }, out = { 11134, 3 } },
    [-7] = { name = "Convertir 3 en 1 mayor", intermediate = true, conversion = true, t = { 1, 1, 1, 1 }, train = 1, r = { { 11174, 3 } }, out = { 11175, 1 } },
    [-8] = { name = "Convertir 1 en 3 menores", intermediate = true, conversion = true, t = { 1, 1, 1, 1 }, train = 1, r = { { 11175, 1 } }, out = { 11174, 3 } },
    [-9] = { name = "Convertir 3 en 1 mayor", intermediate = true, conversion = true, t = { 1, 1, 1, 1 }, train = 1, r = { { 16202, 3 } }, out = { 16203, 1 } },
    [-10] = { name = "Convertir 1 en 3 menores", intermediate = true, conversion = true, t = { 1, 1, 1, 1 }, train = 1, r = { { 16203, 1 } }, out = { 16202, 3 } },
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
ES.Data.VendorPrices[4470] = 38
ES.Data.VendorPrices[4605] = 25
ES.Data.VendorPrices[6217] = 124
ES.Data.VendorPrices[8925] = 500
ES.Data.VendorPrices[10938] = 800
ES.Data.VendorPrices[10940] = 800
ES.Data.VendorPrices[11291] = 4500
ES.Data.VendorPrices[17034] = 200
ES.Data.VendorPrices[17035] = 400
ES.Data.VendorPrices[18256] = 6000
ES.Data.VendorPrices[247786] = 10
ES.Data.SellPrices[1210] = 250
ES.Data.SellPrices[2289] = 87
ES.Data.SellPrices[2772] = 150
ES.Data.SellPrices[2775] = 75
ES.Data.SellPrices[3013] = 25
ES.Data.SellPrices[3356] = 30
ES.Data.SellPrices[3371] = 1
ES.Data.SellPrices[3372] = 10
ES.Data.SellPrices[3819] = 100
ES.Data.SellPrices[3829] = 150
ES.Data.SellPrices[4470] = 9
ES.Data.SellPrices[4605] = 6
ES.Data.SellPrices[4625] = 250
ES.Data.SellPrices[5500] = 750
ES.Data.SellPrices[5637] = 75
ES.Data.SellPrices[6037] = 1250
ES.Data.SellPrices[6048] = 100
ES.Data.SellPrices[6217] = 24
ES.Data.SellPrices[6218] = 24
ES.Data.SellPrices[6338] = 125
ES.Data.SellPrices[6339] = 24
ES.Data.SellPrices[6370] = 10
ES.Data.SellPrices[6371] = 12
ES.Data.SellPrices[7067] = 400
ES.Data.SellPrices[7068] = 400
ES.Data.SellPrices[7075] = 400
ES.Data.SellPrices[7076] = 400
ES.Data.SellPrices[7077] = 400
ES.Data.SellPrices[7078] = 400
ES.Data.SellPrices[7079] = 400
ES.Data.SellPrices[7080] = 400
ES.Data.SellPrices[7081] = 400
ES.Data.SellPrices[7082] = 400
ES.Data.SellPrices[7392] = 200
ES.Data.SellPrices[7909] = 1000
ES.Data.SellPrices[7971] = 1000
ES.Data.SellPrices[7972] = 400
ES.Data.SellPrices[8151] = 250
ES.Data.SellPrices[8152] = 500
ES.Data.SellPrices[8153] = 5
ES.Data.SellPrices[8170] = 500
ES.Data.SellPrices[8831] = 300
ES.Data.SellPrices[8838] = 60
ES.Data.SellPrices[8925] = 125
ES.Data.SellPrices[9224] = 700
ES.Data.SellPrices[10308] = 112
ES.Data.SellPrices[10938] = 1
ES.Data.SellPrices[10939] = 1
ES.Data.SellPrices[10940] = 1
ES.Data.SellPrices[10978] = 1
ES.Data.SellPrices[10998] = 1
ES.Data.SellPrices[11082] = 1
ES.Data.SellPrices[11083] = 1
ES.Data.SellPrices[11084] = 1
ES.Data.SellPrices[11128] = 500
ES.Data.SellPrices[11130] = 500
ES.Data.SellPrices[11134] = 1
ES.Data.SellPrices[11135] = 1
ES.Data.SellPrices[11137] = 1
ES.Data.SellPrices[11138] = 1
ES.Data.SellPrices[11139] = 1
ES.Data.SellPrices[11144] = 1000
ES.Data.SellPrices[11145] = 1250
ES.Data.SellPrices[11174] = 1
ES.Data.SellPrices[11175] = 1
ES.Data.SellPrices[11176] = 1
ES.Data.SellPrices[11177] = 1
ES.Data.SellPrices[11178] = 1
ES.Data.SellPrices[11287] = 110
ES.Data.SellPrices[11288] = 200
ES.Data.SellPrices[11289] = 450
ES.Data.SellPrices[11291] = 1125
ES.Data.SellPrices[11382] = 750
ES.Data.SellPrices[12359] = 600
ES.Data.SellPrices[12361] = 7000
ES.Data.SellPrices[12363] = 2000
ES.Data.SellPrices[12655] = 500
ES.Data.SellPrices[12803] = 500
ES.Data.SellPrices[12808] = 1000
ES.Data.SellPrices[12809] = 10000
ES.Data.SellPrices[12810] = 500
ES.Data.SellPrices[12811] = 20000
ES.Data.SellPrices[13467] = 250
ES.Data.SellPrices[13468] = 1000
ES.Data.SellPrices[13926] = 10000
ES.Data.SellPrices[14047] = 400
ES.Data.SellPrices[14343] = 1
ES.Data.SellPrices[14344] = 1
ES.Data.SellPrices[15407] = 500
ES.Data.SellPrices[16202] = 1
ES.Data.SellPrices[16203] = 1
ES.Data.SellPrices[16204] = 1
ES.Data.SellPrices[16206] = 1000
ES.Data.SellPrices[16207] = 1250
ES.Data.SellPrices[17034] = 50
ES.Data.SellPrices[17035] = 100
ES.Data.SellPrices[18256] = 1500
ES.Data.SellPrices[18512] = 4000
ES.Data.SellPrices[20725] = 1
ES.Data.SellPrices[20744] = 100
ES.Data.SellPrices[20745] = 500
ES.Data.SellPrices[20746] = 1000
ES.Data.SellPrices[20747] = 1000
ES.Data.SellPrices[20748] = 1000
ES.Data.SellPrices[20749] = 1000
ES.Data.SellPrices[20750] = 1000
ES.Data.SellPrices[217287] = 600
ES.Data.SellPrices[220606] = 11850
ES.Data.SellPrices[220792] = 150
ES.Data.SellPrices[228980] = 400
ES.Data.SellPrices[232611] = 1000
ES.Data.SellPrices[247786] = 1
ES.Data.SellPrices[247789] = 5
ES.Data.SellPrices[248819] = 3000
ES.Data.SellPrices[248820] = 15000
ES.Data.SellPrices[248822] = 1500
ES.Data.SellPrices[249144] = 1000
ES.Data.SellPrices[249232] = 2000
ES.Data.SellPrices[249234] = 1500
ES.Data.SellPrices[249237] = 2500
ES.Data.SellPrices[249274] = 250
ES.Data.SellPrices[249385] = 5263
ES.Data.SellPrices[249391] = 100
ES.Data.SellPrices[249392] = 601
ES.Data.SellPrices[249393] = 601
ES.Data.SellPrices[249394] = 499
ES.Data.SellPrices[249395] = 496
ES.Data.SellPrices[249396] = 499
ES.Data.SellPrices[249397] = 450
ES.Data.SellPrices[249398] = 499
ES.Data.SellPrices[249399] = 30
ES.Data.SellPrices[249409] = 75
ES.Data.SellPrices[249410] = 125
ES.Data.SellPrices[249424] = 95
ES.Data.SellPrices[249425] = 250
ES.Data.SellPrices[249430] = 250
ES.Data.SellPrices[249431] = 375
ES.Data.SellPrices[249432] = 250
ES.Data.SellPrices[249441] = 2001
ES.Data.SellPrices[249442] = 2655
ES.Data.SellPrices[249443] = 4752
ES.Data.SellPrices[249453] = 601
ES.Data.SellPrices[249454] = 601
ES.Data.SellPrices[249455] = 2156
ES.Data.SellPrices[249456] = 2156
ES.Data.SellPrices[249469] = 1500
ES.Data.SellPrices[249470] = 1500
ES.Data.SellPrices[249473] = 1500
ES.Data.SellPrices[249726] = 3000
ES.Data.SellPrices[279246] = 13687
ES.Data.SellPrices[279247] = 18929
ES.Data.SellPrices[279248] = 18929
ES.Data.SellPrices[279249] = 18929
ES.Data.SellPrices[279250] = 18929
ES.Data.SellPrices[279251] = 18929

-- Nombre de cada objeto (inglés, del cliente): se muestra mientras el juego no lo ha cargado
ES.Data.ItemNames = ES.Data.ItemNames or {}
ES.Data.ItemNames[1210] = "Shadowgem"
ES.Data.ItemNames[2289] = "Scroll of Strength II"
ES.Data.ItemNames[2772] = "Iron Ore"
ES.Data.ItemNames[2775] = "Silver Ore"
ES.Data.ItemNames[3013] = "Scroll of Protection"
ES.Data.ItemNames[3356] = "Kingsblood"
ES.Data.ItemNames[3371] = "Empty Vial"
ES.Data.ItemNames[3372] = "Leaded Vial"
ES.Data.ItemNames[3819] = "Wintersbite"
ES.Data.ItemNames[3829] = "Frost Oil"
ES.Data.ItemNames[4470] = "Simple Wood"
ES.Data.ItemNames[4605] = "Red-speckled Mushroom"
ES.Data.ItemNames[4625] = "Firebloom"
ES.Data.ItemNames[5500] = "Iridescent Pearl"
ES.Data.ItemNames[5637] = "Large Fang"
ES.Data.ItemNames[6037] = "Truesilver Bar"
ES.Data.ItemNames[6048] = "Shadow Protection Potion"
ES.Data.ItemNames[6217] = "Copper Rod"
ES.Data.ItemNames[6218] = "Runed Copper Rod"
ES.Data.ItemNames[6338] = "Silver Rod"
ES.Data.ItemNames[6339] = "Runed Silver Rod"
ES.Data.ItemNames[6370] = "Blackmouth Oil"
ES.Data.ItemNames[6371] = "Fire Oil"
ES.Data.ItemNames[7067] = "Elemental Earth"
ES.Data.ItemNames[7068] = "Elemental Fire"
ES.Data.ItemNames[7075] = "Core of Earth"
ES.Data.ItemNames[7076] = "Essence of Earth"
ES.Data.ItemNames[7077] = "Heart of Fire"
ES.Data.ItemNames[7078] = "Essence of Fire"
ES.Data.ItemNames[7079] = "Globe of Water"
ES.Data.ItemNames[7080] = "Essence of Water"
ES.Data.ItemNames[7081] = "Breath of Wind"
ES.Data.ItemNames[7082] = "Essence of Air"
ES.Data.ItemNames[7392] = "Green Whelp Scale"
ES.Data.ItemNames[7909] = "Aquamarine"
ES.Data.ItemNames[7971] = "Black Pearl"
ES.Data.ItemNames[7972] = "Ichor of Undeath"
ES.Data.ItemNames[8151] = "Flask of Mojo"
ES.Data.ItemNames[8152] = "Flask of Big Mojo"
ES.Data.ItemNames[8153] = "Wildvine"
ES.Data.ItemNames[8170] = "Rugged Leather"
ES.Data.ItemNames[8831] = "Purple Lotus"
ES.Data.ItemNames[8838] = "Sungrass"
ES.Data.ItemNames[8925] = "Crystal Vial"
ES.Data.ItemNames[9224] = "Potion of Demon Slaying"
ES.Data.ItemNames[10308] = "Scroll of Intellect IV"
ES.Data.ItemNames[10938] = "Lesser Magic Essence"
ES.Data.ItemNames[10939] = "Greater Magic Essence"
ES.Data.ItemNames[10940] = "Strange Dust"
ES.Data.ItemNames[10978] = "Small Glimmering Shard"
ES.Data.ItemNames[10998] = "Lesser Astral Essence"
ES.Data.ItemNames[11082] = "Greater Astral Essence"
ES.Data.ItemNames[11083] = "Soul Dust"
ES.Data.ItemNames[11084] = "Large Glimmering Shard"
ES.Data.ItemNames[11128] = "Golden Rod"
ES.Data.ItemNames[11130] = "Runed Golden Rod"
ES.Data.ItemNames[11134] = "Lesser Mystic Essence"
ES.Data.ItemNames[11135] = "Greater Mystic Essence"
ES.Data.ItemNames[11137] = "Vision Dust"
ES.Data.ItemNames[11138] = "Small Glowing Shard"
ES.Data.ItemNames[11139] = "Large Glowing Shard"
ES.Data.ItemNames[11144] = "Truesilver Rod"
ES.Data.ItemNames[11145] = "Runed Truesilver Rod"
ES.Data.ItemNames[11174] = "Lesser Nether Essence"
ES.Data.ItemNames[11175] = "Greater Nether Essence"
ES.Data.ItemNames[11176] = "Dream Dust"
ES.Data.ItemNames[11177] = "Small Radiant Shard"
ES.Data.ItemNames[11178] = "Large Radiant Shard"
ES.Data.ItemNames[11287] = "Lesser Magic Wand"
ES.Data.ItemNames[11288] = "Greater Magic Wand"
ES.Data.ItemNames[11289] = "Lesser Mystic Wand"
ES.Data.ItemNames[11291] = "Star Wood"
ES.Data.ItemNames[11382] = "Blood of the Mountain"
ES.Data.ItemNames[11754] = "Black Diamond"
ES.Data.ItemNames[12359] = "Thorium Bar"
ES.Data.ItemNames[12361] = "Blue Sapphire"
ES.Data.ItemNames[12363] = "Arcane Crystal"
ES.Data.ItemNames[12655] = "Enchanted Thorium Bar"
ES.Data.ItemNames[12735] = "Frayed Abomination Stitching"
ES.Data.ItemNames[12753] = "Skin of Shadow"
ES.Data.ItemNames[12803] = "Living Essence"
ES.Data.ItemNames[12808] = "Essence of Undeath"
ES.Data.ItemNames[12809] = "Guardian Stone"
ES.Data.ItemNames[12810] = "Enchanted Leather"
ES.Data.ItemNames[12811] = "Righteous Orb"
ES.Data.ItemNames[12938] = "Blood of Heroes"
ES.Data.ItemNames[13180] = "Stratholme Holy Water"
ES.Data.ItemNames[13467] = "Icecap"
ES.Data.ItemNames[13468] = "Black Lotus"
ES.Data.ItemNames[13926] = "Golden Pearl"
ES.Data.ItemNames[14047] = "Runecloth"
ES.Data.ItemNames[14343] = "Small Brilliant Shard"
ES.Data.ItemNames[14344] = "Large Brilliant Shard"
ES.Data.ItemNames[15407] = "Cured Rugged Hide"
ES.Data.ItemNames[16202] = "Lesser Eternal Essence"
ES.Data.ItemNames[16203] = "Greater Eternal Essence"
ES.Data.ItemNames[16204] = "Illusion Dust"
ES.Data.ItemNames[16206] = "Arcanite Rod"
ES.Data.ItemNames[16207] = "Runed Arcanite Rod"
ES.Data.ItemNames[17034] = "Maple Seed"
ES.Data.ItemNames[17035] = "Stranglethorn Seed"
ES.Data.ItemNames[18256] = "Imbued Vial"
ES.Data.ItemNames[18512] = "Larval Acid"
ES.Data.ItemNames[20725] = "Nexus Crystal"
ES.Data.ItemNames[20744] = "Minor Wizard Oil"
ES.Data.ItemNames[20745] = "Minor Mana Oil"
ES.Data.ItemNames[20746] = "Lesser Wizard Oil"
ES.Data.ItemNames[20747] = "Lesser Mana Oil"
ES.Data.ItemNames[20748] = "Brilliant Mana Oil"
ES.Data.ItemNames[20749] = "Brilliant Wizard Oil"
ES.Data.ItemNames[20750] = "Wizard Oil"
ES.Data.ItemNames[217287] = "Greater Mystic Wand"
ES.Data.ItemNames[217308] = "Enchanted Sigil: Innovation"
ES.Data.ItemNames[220606] = "Idol of the Dream"
ES.Data.ItemNames[220792] = "Scroll of Spatial Mending"
ES.Data.ItemNames[228175] = "Libram of Holy Alacrity"
ES.Data.ItemNames[228176] = "Totem of Thunder"
ES.Data.ItemNames[228978] = "Enchanted Sigil: Flowing Waters"
ES.Data.ItemNames[228980] = "Conductive Shield Coating"
ES.Data.ItemNames[232611] = "Magnificent Trollshine"
ES.Data.ItemNames[247786] = "Mote of Magic"
ES.Data.ItemNames[247789] = "Novice's Practice Wand"
ES.Data.ItemNames[248819] = "Fel Crystal"
ES.Data.ItemNames[248820] = "Torbernite"
ES.Data.ItemNames[248822] = "Death Lotus"
ES.Data.ItemNames[249144] = "Twisted Nether Wand"
ES.Data.ItemNames[249232] = "Lesser Eternal Wand"
ES.Data.ItemNames[249234] = "Dreambough Wand"
ES.Data.ItemNames[249237] = "Greater Eternal Wand"
ES.Data.ItemNames[249274] = "Stranglevine"
ES.Data.ItemNames[249385] = "Brilliant Wand"
ES.Data.ItemNames[249391] = "Pyrite"
ES.Data.ItemNames[249392] = "Glimmering Staff"
ES.Data.ItemNames[249393] = "Soulstaff"
ES.Data.ItemNames[249394] = "Orb of Mystic Insight"
ES.Data.ItemNames[249395] = "Orb of Souls"
ES.Data.ItemNames[249396] = "Mystic Mushroom"
ES.Data.ItemNames[249397] = "Tenets of the Silver Hand"
ES.Data.ItemNames[249398] = "Polished Driftwood Icon"
ES.Data.ItemNames[249399] = "Frilled Lichen"
ES.Data.ItemNames[249409] = "Cerulean Dye"
ES.Data.ItemNames[249410] = "Sulfuric Acid"
ES.Data.ItemNames[249424] = "Rosecap"
ES.Data.ItemNames[249425] = "Bauxite"
ES.Data.ItemNames[249430] = "Magenta Dye"
ES.Data.ItemNames[249431] = "Viridian Dye"
ES.Data.ItemNames[249432] = "Sandpaper"
ES.Data.ItemNames[249441] = "Talons of Wrath"
ES.Data.ItemNames[249442] = "Libram of Invocation"
ES.Data.ItemNames[249443] = "Totem of Ancestral Protection"
ES.Data.ItemNames[249453] = "Radiant Staff"
ES.Data.ItemNames[249454] = "Dreamstaff"
ES.Data.ItemNames[249455] = "Truesilver Conduit"
ES.Data.ItemNames[249456] = "Twisting Essence Jar"
ES.Data.ItemNames[249469] = "Frozen Heart of the Mountain"
ES.Data.ItemNames[249470] = "Molten Heart of the Mountain"
ES.Data.ItemNames[249473] = "Dormant Heart of the Mountain"
ES.Data.ItemNames[249726] = "Azerothium Bar"
ES.Data.ItemNames[274030] = "Malleable Essence of Nature"
ES.Data.ItemNames[279246] = "Torch of Light"
ES.Data.ItemNames[279247] = "Steadfast Libram"
ES.Data.ItemNames[279248] = "Libram of Infusion"
ES.Data.ItemNames[279249] = "Totem of Urgency"
ES.Data.ItemNames[279250] = "Idol of Swiftness"
ES.Data.ItemNames[279251] = "Idol of the Ursine Twins"
ES.Data.ItemNames[279976] = "Enchanted Lute"
ES.Data.ItemNames[279985] = "Arcane Salvager"

-- Material -> profesión de recolección que lo consigue (393 Desuello, 182 Herboristería, 186 Minería).
-- Sin uso por ahora: reservado para la vía "Vender en bruto" de Ganar dinero (docs/PLAN.md, G1).
ES.Data.GatheredBy = ES.Data.GatheredBy or {}
ES.Data.GatheredBy[2772] = 186
ES.Data.GatheredBy[2775] = 186
ES.Data.GatheredBy[3356] = 182
ES.Data.GatheredBy[3819] = 182
ES.Data.GatheredBy[4625] = 182
ES.Data.GatheredBy[7392] = 393
ES.Data.GatheredBy[8153] = 182
ES.Data.GatheredBy[8170] = 393
ES.Data.GatheredBy[8831] = 182
ES.Data.GatheredBy[8838] = 182
ES.Data.GatheredBy[12359] = 186
ES.Data.GatheredBy[12809] = 186
ES.Data.GatheredBy[13467] = 182
ES.Data.GatheredBy[13468] = 182
ES.Data.GatheredBy[248822] = 182
ES.Data.GatheredBy[249274] = 182
ES.Data.GatheredBy[249391] = 186
ES.Data.GatheredBy[249399] = 182
ES.Data.GatheredBy[249424] = 182
ES.Data.GatheredBy[249425] = 186
ES.Data.GatheredBy[249726] = 186

-- Generado por tools/gen_profession.py (Cooking). No editar a mano.
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
ES.Data.Cooking = {
  skillLine = 185,
  ranks = { -- { tope, precio, habilidad requerida, nivel de personaje }
    { 150, 500, 50, 10 },
    { 225, 10000, 125, 35 },
    { 300, 0, 225, 35 },
  },
  -- { PNJ instructor, rangos que enseña: 1 aprendiz (75), 2 oficial (150), 4 experto (225), 8 artesano (300) }
  trainers = { { 1355, 3 }, { 1382, 3 }, { 1430, 3 }, { 1699, 3 }, { 3026, 3 }, { 3067, 3 }, { 3087, 3 }, { 3399, 3 }, { 4210, 3 }, { 4552, 3 }, { 5159, 3 }, { 5482, 3 }, { 6286, 3 }, { 8306, 3 }, { 251905, 3 }, { 252084, 3 }, { 256655, 3 }, { 257006, 3 }, { 265944, 3 } },
  recipes = {
    [818] = { name = "Basic Campfire", t = { 1, 25, 50, 75 }, basic = true, r = { { 4470, 1 } } },
    [2538] = { name = "Charred Wolf Meat", t = { 1, 45, 65, 85 }, basic = true, r = { { 2672, 1 } }, out = { 2679, 1 }, oq = 1 },
    [2539] = { name = "Spiced Wolf Meat", t = { 1, 50, 70, 90 }, fee = 50, train = 10, r = { { 2672, 1 }, { 2678, 1 } }, out = { 2680, 1 }, oq = 1 },
    [2540] = { name = "Roasted Boar Meat", t = { 1, 45, 65, 85 }, basic = true, r = { { 769, 1 } }, out = { 2681, 1 }, oq = 1 },
    [2541] = { name = "Coyote Steak", t = { 1, 90, 110, 130 }, fee = 100, train = 50, r = { { 2673, 1 } }, out = { 2684, 1 }, oq = 1 },
    [2542] = { name = "Goretusk Liver Pie", t = { 1, 90, 110, 130 }, scroll = 2697, train = 50, scrollPrice = 400, sq = 1, r = { { 723, 1 }, { 2678, 1 } }, out = { 724, 1 }, oq = 1 },
    [2543] = { name = "Westfall Stew", t = { 1, 115, 135, 155 }, scroll = 728, train = 75, scrollPrice = 200, sq = 1, r = { { 729, 1 }, { 730, 1 }, { 731, 1 } }, out = { 733, 1 }, oq = 1 },
    [2544] = { name = "Crab Cake", t = { 1, 115, 135, 155 }, fee = 200, train = 75, r = { { 2674, 1 }, { 2678, 1 } }, out = { 2683, 1 }, oq = 1 },
    [2545] = { name = "Cooked Crab Claw", t = { 1, 125, 145, 165 }, scroll = 2698, train = 85, scrollPrice = 400, sq = 1, r = { { 2675, 1 }, { 2678, 1 } }, out = { 2682, 1 }, oq = 1 },
    [2546] = { name = "Dry Pork Ribs", t = { 1, 120, 140, 160 }, fee = 150, train = 80, r = { { 2677, 1 }, { 2678, 1 } }, out = { 2687, 1 }, oq = 1 },
    [2547] = { name = "Redridge Goulash", t = { 1, 135, 155, 175 }, scroll = 2699, train = 100, scrollPrice = 800, sq = 1, r = { { 1081, 1 }, { 1080, 1 } }, out = { 1082, 1 }, oq = 1 },
    [2548] = { name = "Succulent Pork Ribs", t = { 1, 130, 150, 170 }, scroll = 2700, train = 110, scrollPrice = 400, sq = 1, r = { { 2677, 2 }, { 2692, 1 } }, out = { 2685, 1 }, oq = 1 },
    [2549] = { name = "Seasoned Wolf Kabob", t = { 1, 140, 160, 180 }, scroll = 2701, train = 100, scrollPrice = 1600, sq = 1, r = { { 1015, 2 }, { 2678, 1 } }, out = { 1017, 3 }, oq = 1 },
    [2795] = { name = "Beer Basted Boar Ribs", t = { 1, 60, 80, 100 }, scroll = 2889, train = 25, scrollPrice = 240, sq = 1, r = { { 2886, 1 }, { 2894, 1 } }, out = { 2888, 1 }, oq = 1 },
    [3370] = { name = "Crocolisk Steak", t = { 1, 120, 140, 160 }, scroll = 3678, train = 80, scrollPrice = 400, sq = 1, r = { { 2924, 1 }, { 2678, 1 } }, out = { 3662, 1 }, oq = 1 },
    [3371] = { name = "Blood Sausage", t = { 1, 100, 120, 140 }, scroll = 3679, train = 60, scrollPrice = 400, sq = 1, r = { { 3173, 1 }, { 3172, 1 }, { 3174, 1 } }, out = { 3220, 2 }, oq = 1 },
    [3372] = { name = "Murloc Fin Soup", t = { 1, 130, 150, 170 }, scroll = 3680, train = 90, scrollPrice = 1600, sq = 1, r = { { 1468, 2 }, { 2692, 1 } }, out = { 3663, 1 }, oq = 1 },
    [3373] = { name = "Crocolisk Gumbo", t = { 1, 160, 180, 200 }, scroll = 3681, train = 120, scrollPrice = 1600, sq = 1, r = { { 3667, 1 }, { 2692, 1 } }, out = { 3664, 1 }, oq = 1 },
    [3376] = { name = "Curiously Tasty Omelet", t = { 1, 170, 190, 210 }, scroll = 3682, train = 130, scrollPrice = 1600, sq = 1, r = { { 3685, 1 }, { 2692, 1 } }, out = { 3665, 1 }, oq = 1 },
    [3377] = { name = "Gooey Spider Cake", t = { 1, 150, 170, 190 }, scroll = 3683, train = 110, scrollPrice = 1600, sq = 1, r = { { 2251, 2 }, { 2692, 1 } }, out = { 3666, 1 }, oq = 1 },
    [3397] = { name = "Big Bear Steak", t = { 1, 150, 170, 190 }, scroll = 3734, train = 110, scrollPrice = 1600, sq = 1, r = { { 3730, 1 }, { 2692, 1 } }, out = { 3726, 1 }, oq = 1 },
    [3398] = { name = "Hot Lion Chops", t = { 1, 175, 195, 215 }, scroll = 3735, train = 125, scrollPrice = 1800, sq = 1, r = { { 3731, 1 }, { 2692, 1 } }, out = { 3727, 1 }, oq = 1 },
    [3399] = { name = "Tasty Lion Steak", t = { 1, 190, 210, 230 }, scroll = 3736, train = 150, sq = 1, r = { { 3731, 2 }, { 3713, 1 } }, out = { 3728, 1 }, oq = 1 },
    [3400] = { name = "Soothing Turtle Bisque", t = { 1, 215, 235, 255 }, scroll = 3737, train = 175, sq = 1, r = { { 3712, 1 }, { 3713, 1 } }, out = { 3729, 1 }, oq = 1 },
    [4094] = { name = "Barbecued Buzzard Wing", t = { 1, 215, 235, 255 }, fee = 500, train = 175, tr = { 2818 }, r = { { 3404, 1 }, { 2692, 1 } }, out = { 4457, 1 }, oq = 1 },
    [6412] = { name = "Kaldorei Spider Kabob", t = { 1, 50, 70, 90 }, scroll = 5482, train = 10, sq = 1, r = { { 5465, 1 } }, out = { 5472, 1 }, oq = 1 },
    [6413] = { name = "Scorpid Surprise", t = { 1, 60, 80, 100 }, scroll = 5483, train = 20, scrollPrice = 140, sq = 1, r = { { 5466, 1 } }, out = { 5473, 1 }, oq = 1 },
    [6414] = { name = "Roasted Kodo Meat", t = { 1, 75, 95, 115 }, scroll = 5484, train = 35, scrollPrice = 240, sq = 1, r = { { 5467, 1 }, { 2678, 1 } }, out = { 5474, 2 }, oq = 1 },
    [6415] = { name = "Fillet of Frenzy", t = { 1, 90, 110, 130 }, scroll = 5485, train = 50, scrollPrice = 400, sq = 1, r = { { 5468, 1 }, { 2678, 1 } }, out = { 5476, 2 }, oq = 1 },
    [6416] = { name = "Strider Stew", t = { 1, 90, 110, 130 }, scroll = 5486, train = 50, scrollPrice = 440, sq = 1, r = { { 5469, 1 }, { 4536, 1 } }, out = { 5477, 2 }, oq = 1 },
    [6417] = { name = "Dig Rat Stew", t = { 1, 130, 150, 170 }, scroll = 5487, train = 90, sq = 1, r = { { 5051, 1 } }, out = { 5478, 2 }, oq = 1 },
    [6418] = { name = "Crispy Lizard Tail", t = { 1, 140, 160, 180 }, scroll = 5488, train = 100, scrollPrice = 400, sq = 1, r = { { 5470, 1 }, { 2692, 1 } }, out = { 5479, 2 }, oq = 1 },
    [6419] = { name = "Lean Venison", t = { 1, 150, 170, 190 }, scroll = 5489, train = 110, scrollPrice = 1200, sq = 1, r = { { 5471, 1 }, { 2678, 4 } }, out = { 5480, 2 }, oq = 1 },
    [6499] = { name = "Boiled Clams", t = { 1, 90, 110, 130 }, fee = 100, train = 50, r = { { 5503, 1 }, { 159, 1 } }, out = { 5525, 1 }, oq = 1 },
    [6500] = { name = "Goblin Deviled Clams", t = { 1, 165, 185, 205 }, fee = 300, train = 125, r = { { 5504, 1 }, { 2692, 1 } }, out = { 5527, 1 }, oq = 1 },
    [6501] = { name = "Clam Chowder", t = { 1, 130, 150, 170 }, scroll = 5528, train = 90, scrollPrice = 800, sq = 1, r = { { 5503, 1 }, { 1179, 1 }, { 2678, 1 } }, out = { 5526, 1 }, oq = 1 },
    [7213] = { name = "Giant Clam Scorcho", t = { 1, 215, 235, 255 }, scroll = 6039, train = 175, scrollPrice = 5000, sq = 1, r = { { 4655, 1 }, { 2692, 1 } }, out = { 6038, 1 }, oq = 1 },
    [7751] = { name = "Brilliant Smallfish", t = { 1, 45, 65, 85 }, scroll = 6325, train = 1, scrollPrice = 40, sq = 1, r = { { 6291, 1 } }, out = { 6290, 1 }, oq = 1 },
    [7752] = { name = "Slitherskin Mackerel", t = { 1, 45, 65, 85 }, scroll = 6326, train = 1, scrollPrice = 40, sq = 1, r = { { 6303, 1 } }, out = { 787, 1 }, oq = 1 },
    [7753] = { name = "Longjaw Mud Snapper", t = { 1, 90, 110, 130 }, scroll = 6328, train = 50, scrollPrice = 400, sq = 1, r = { { 6289, 1 } }, out = { 4592, 1 }, oq = 1 },
    [7754] = { name = "Loch Frenzy Delight", t = { 1, 90, 110, 130 }, scroll = 6329, train = 50, scrollPrice = 400, sq = 1, r = { { 6317, 1 }, { 2678, 1 } }, out = { 6316, 1 }, oq = 1 },
    [7755] = { name = "Bristle Whisker Catfish", t = { 1, 140, 160, 180 }, scroll = 6330, train = 100, scrollPrice = 1200, sq = 1, r = { { 6308, 1 } }, out = { 4593, 1 }, oq = 1 },
    [7827] = { name = "Rainbow Fin Albacore", t = { 1, 90, 110, 130 }, scroll = 6368, train = 50, scrollPrice = 400, sq = 1, r = { { 6361, 1 } }, out = { 5095, 1 }, oq = 1 },
    [7828] = { name = "Rockscale Cod", t = { 1, 190, 210, 230 }, scroll = 6369, train = 175, scrollPrice = 2200, sq = 1, r = { { 6362, 1 } }, out = { 4594, 1 }, oq = 1 },
    [8238] = { name = "Savory Deviate Delight", t = { 1, 125, 145, 165 }, scroll = 6661, train = 85, sq = 2, r = { { 6522, 1 }, { 2678, 1 } }, out = { 6657, 1 }, oq = 1 },
    [8604] = { name = "Herb Baked Egg", t = { 1, 45, 65, 85 }, basic = true, r = { { 6889, 1 }, { 2678, 1 } }, out = { 6888, 1 }, oq = 1 },
    [8607] = { name = "Smoked Bear Meat", t = { 1, 80, 100, 120 }, scroll = 6892, train = 40, scrollPrice = 250, sq = 1, r = { { 3173, 1 } }, out = { 6890, 1 }, oq = 1 },
    [9513] = { name = "Thistle Tea", t = { 1, 100, 120, 140 }, scroll = 18160, train = 60, scrollPrice = 200, sq = 2, r = { { 2452, 1 }, { 159, 1 } }, out = { 7676, 1 }, oq = 1 },
    [13028] = { name = "Goldthorn Tea", t = { 1, 215, 235, 255 }, gone = true, r = { { 3821, 1 }, { 159, 1 } }, out = { 10841, 4 }, oq = 1 },
    [15853] = { name = "Lean Wolf Steak", t = { 1, 165, 185, 205 }, scroll = 12227, train = 125, scrollPrice = 1600, sq = 1, r = { { 1015, 1 }, { 2678, 1 } }, out = { 12209, 1 }, oq = 1 },
    [15855] = { name = "Roast Raptor", t = { 1, 215, 235, 255 }, scroll = 12228, train = 175, scrollPrice = 5000, sq = 1, r = { { 12184, 1 }, { 2692, 1 } }, out = { 12210, 1 }, oq = 1 },
    [15856] = { name = "Hot Wolf Ribs", t = { 1, 215, 235, 255 }, scroll = 12229, train = 175, scrollPrice = 5000, sq = 1, r = { { 12203, 1 }, { 2692, 1 } }, out = { 13851, 1 }, oq = 1 },
    [15861] = { name = "Jungle Stew", t = { 1, 215, 235, 255 }, scroll = 12231, train = 175, scrollPrice = 3000, sq = 1, r = { { 12202, 1 }, { 159, 1 }, { 4536, 2 } }, out = { 12212, 2 }, oq = 1 },
    [15863] = { name = "Carrion Surprise", t = { 1, 215, 235, 255 }, scroll = 12232, train = 175, scrollPrice = 5000, sq = 1, r = { { 12037, 1 }, { 2692, 1 } }, out = { 12213, 1 }, oq = 1 },
    [15865] = { name = "Mystery Stew", t = { 1, 215, 235, 255 }, scroll = 12233, train = 175, scrollPrice = 3000, sq = 1, r = { { 12037, 1 }, { 2596, 1 } }, out = { 12214, 1 }, oq = 1 },
    [15906] = { name = "Dragonbreath Chili", t = { 1, 240, 260, 280 }, scroll = 12239, train = 200, scrollPrice = 7000, sq = 1, r = { { 12037, 1 }, { 4402, 1 }, { 2692, 1 } }, out = { 12217, 1 }, oq = 1 },
    [15910] = { name = "Heavy Kodo Stew", t = { 1, 240, 260, 280 }, scroll = 12240, train = 200, scrollPrice = 7000, sq = 1, r = { { 12204, 2 }, { 3713, 1 }, { 159, 1 } }, out = { 12215, 2 }, oq = 1 },
    [15915] = { name = "Spiced Chili Crab", t = { 1, 265, 285, 305 }, scroll = 16111, train = 225, scrollPrice = 12000, sq = 1, r = { { 12206, 1 }, { 2692, 2 } }, out = { 12216, 1 }, oq = 1 },
    [15933] = { name = "Monster Omelet", t = { 1, 265, 285, 305 }, scroll = 16110, train = 225, scrollPrice = 12000, sq = 1, r = { { 12207, 1 }, { 3713, 2 } }, out = { 12218, 1 }, oq = 1 },
    [15935] = { name = "Crispy Bat Wing", t = { 1, 45, 65, 85 }, scroll = 12226, train = 1, scrollPrice = 25, sq = 1, r = { { 12223, 1 }, { 2678, 1 } }, out = { 12224, 1 }, oq = 1 },
    [18238] = { name = "Spotted Yellowtail", t = { 1, 265, 285, 305 }, scroll = 13939, train = 225, scrollPrice = 16000, sq = 1, r = { { 4603, 1 } }, out = { 6887, 1 }, oq = 1 },
    [18239] = { name = "Cooked Glossy Mightfish", t = { 1, 265, 285, 305 }, scroll = 13940, train = 225, scrollPrice = 16000, sq = 1, r = { { 13754, 1 }, { 3713, 1 } }, out = { 13927, 1 }, oq = 1 },
    [18240] = { name = "Grilled Squid", t = { 1, 280, 300, 320 }, scroll = 13942, train = 240, scrollPrice = 16000, sq = 1, r = { { 13755, 1 }, { 3713, 1 } }, out = { 13928, 1 }, oq = 1 },
    [18241] = { name = "Filet of Redgill", t = { 1, 265, 285, 305 }, scroll = 13941, train = 225, scrollPrice = 16000, sq = 1, r = { { 13758, 1 } }, out = { 13930, 1 }, oq = 1 },
    [18242] = { name = "Hot Smoked Bass", t = { 1, 280, 300, 320 }, scroll = 13943, train = 240, scrollPrice = 16000, sq = 1, r = { { 13756, 1 }, { 2692, 2 } }, out = { 13929, 1 }, oq = 1 },
    [18243] = { name = "Nightfin Soup", t = { 1, 290, 310, 330 }, scroll = 13945, train = 250, scrollPrice = 20000, sq = 1, r = { { 13759, 1 }, { 159, 1 } }, out = { 13931, 1 }, oq = 1 },
    [18244] = { name = "Poached Sunscale Salmon", t = { 1, 290, 310, 330 }, scroll = 13946, train = 250, scrollPrice = 20000, sq = 1, r = { { 13760, 1 } }, out = { 13932, 1 }, oq = 1 },
    [18245] = { name = "Lobster Stew", t = { 1, 315, 335, 355 }, scroll = 13947, train = 275, scrollPrice = 20000, sq = 1, r = { { 13888, 1 }, { 159, 1 } }, out = { 13933, 1 }, oq = 1 },
    [18246] = { name = "Mightfish Steak", t = { 1, 315, 335, 355 }, scroll = 13948, train = 275, scrollPrice = 20000, sq = 1, r = { { 13893, 1 }, { 2692, 1 }, { 3713, 1 } }, out = { 13934, 1 }, oq = 1 },
    [18247] = { name = "Baked Salmon", t = { 1, 315, 335, 355 }, scroll = 13949, train = 275, scrollPrice = 20000, sq = 1, r = { { 13889, 1 }, { 3713, 1 } }, out = { 13935, 1 }, oq = 1 },
    [20626] = { name = "Undermine Clam Chowder", t = { 1, 265, 285, 305 }, scroll = 16767, train = 225, scrollPrice = 3000, sq = 1, r = { { 7974, 2 }, { 2692, 1 }, { 1179, 1 } }, out = { 16766, 2 }, oq = 1 },
    [20916] = { name = "Mithril Headed Trout", t = { 1, 215, 235, 255 }, scroll = 17062, train = 175, scrollPrice = 2200, sq = 1, r = { { 8365, 1 } }, out = { 8364, 1 }, oq = 1 },
    [21143] = { name = "Gingerbread Cookie", t = { 1, 45, 65, 85 }, scroll = 17200, train = 1, scrollPrice = 25, sq = 1, r = { { 6889, 1 }, { 17194, 1 } }, out = { 17197, 1 }, oq = 1 },
    [21144] = { name = "Egg Nog", t = { 1, 75, 95, 115 }, scroll = 17201, train = 35, scrollPrice = 240, sq = 1, r = { { 6889, 1 }, { 1179, 1 }, { 17196, 1 }, { 17194, 1 } }, out = { 17198, 1 }, oq = 1 },
    [21175] = { name = "Spider Sausage", t = { 1, 240, 260, 280 }, fee = 4000, train = 200, tr = { 1355, 1382, 1430, 1699, 3026, 3067, 3087, 3399, 4210, 4552, 5159, 5482, 6286, 8306, 251905, 252084, 256655, 257006, 265944 }, r = { { 12205, 2 } }, out = { 17222, 1 }, oq = 1 },
    [22480] = { name = "Tender Wolf Steak", t = { 1, 265, 285, 305 }, scroll = 18046, train = 225, scrollPrice = 12000, sq = 1, r = { { 12208, 1 }, { 3713, 1 } }, out = { 18045, 1 }, oq = 1 },
    [22761] = { name = "Runn Tum Tuber Surprise", t = { 1, 315, 335, 355 }, scroll = 18267, train = 275, sq = 2, r = { { 18255, 1 }, { 3713, 1 } }, out = { 18254, 1 }, oq = 1 },
    [24418] = { name = "Heavy Crocolisk Stew", t = { 1, 160, 180, 200 }, scroll = 20075, train = 150, scrollPrice = 2000, sq = 1, r = { { 3667, 2 }, { 3713, 1 } }, out = { 20074, 1 }, oq = 1 },
    [24801] = { name = "Smoked Desert Dumplings", t = { 1, 325, 345, 365 }, r = { { 20424, 1 }, { 3713, 1 } }, out = { 20452, 1 }, oq = 1 },
    [25659] = { name = "Dirge's Kickin' Chimaerok Chops", t = { 1, 325, 345, 365 }, scroll = 21025, train = 300, sq = 4, r = { { 2692, 1 }, { 9061, 1 }, { 8150, 1 }, { 21024, 1 } }, out = { 21023, 5 }, oq = 1 },
    [25704] = { name = "Smoked Sagefish", t = { 1, 120, 140, 160 }, scroll = 21099, train = 80, scrollPrice = 500, sq = 1, r = { { 21071, 1 }, { 2678, 1 } }, out = { 21072, 1 }, oq = 1 },
    [25954] = { name = "Sagefish Delight", t = { 1, 215, 235, 255 }, scroll = 21219, train = 175, scrollPrice = 5000, sq = 1, r = { { 21153, 1 }, { 2692, 1 } }, out = { 21217, 1 }, oq = 1 },
    [470370] = { name = "Smoked Redgill", t = { 1, 325, 345, 365 }, scroll = 232443, train = 300, gone = true, sq = 1, r = { { 13758, 1 } }, out = { 232438, 1 }, oq = 1 },
    [1225758] = { name = "Prowler Steak", t = { 1, 260, 270, 280 }, scroll = 238645, train = 250, sq = 1, r = { { 12202, 2 }, { 239016, 1 } }, out = { 238637, 2 }, oq = 1 },
    [1225759] = { name = "Filet o' Flank", t = { 1, 260, 270, 280 }, scroll = 238646, train = 250, sq = 1, r = { { 12203, 2 }, { 239016, 1 } }, out = { 238638, 2 }, oq = 1 },
    [1225760] = { name = "Sunrise Omelette", t = { 1, 260, 270, 280 }, scroll = 238647, train = 250, sq = 1, r = { { 12207, 2 }, { 239016, 1 } }, out = { 238639, 2 }, oq = 1 },
    [1225762] = { name = "Specklefin Feast", t = { 1, 290, 300, 310 }, scroll = 238649, train = 280, sq = 1, r = { { 4603, 12 }, { 12184, 4 }, { 6362, 3 }, { 239017, 1 } }, out = { 238641, 1 }, oq = 2 },
    [1225763] = { name = "Grand Lobster Banquet", t = { 1, 290, 300, 310 }, scroll = 239021, train = 280, sq = 1, r = { { 13888, 12 }, { 3712, 4 }, { 3404, 3 }, { 239017, 1 } }, out = { 238642, 1 }, oq = 2 },
    [1229737] = { name = "Basic Campfire", t = { 1, 1, 3, 5 }, basic = true, r = { { 4470, 1 } }, out = { 279981, 1 }, oq = 1 },
    [1247741] = { name = "Spinefin Halibut", t = { 1, 210, 215, 220 }, r = { { 8959, 1 } }, out = { 8957, 1 }, oq = 1 },
    [1249957] = { name = "Peace Tea", t = { 1, 30, 37, 45 }, scroll = 249879, train = 25, sq = 1, r = { { 159, 1 }, { 2447, 2 } }, out = { 249865, 1 }, oq = 1 },
    [1249958] = { name = "Royal Tea", t = { 1, 105, 115, 125 }, scroll = 249880, train = 100, sq = 1, r = { { 1179, 1 }, { 785, 2 } }, out = { 249866, 1 }, oq = 1 },
    [1249959] = { name = "Root Tea", t = { 1, 155, 170, 185 }, scroll = 249881, train = 125, sq = 1, r = { { 1205, 1 }, { 3357, 2 } }, out = { 249867, 1 }, oq = 1 },
    [1249960] = { name = "Triage Tea", t = { 1, 195, 215, 235 }, scroll = 249882, train = 180, sq = 1, r = { { 1708, 1 }, { 3818, 2 } }, out = { 249868, 1 }, oq = 1 },
    [1249961] = { name = "Sunny Tea", t = { 1, 220, 235, 250 }, scroll = 249883, train = 200, sq = 1, r = { { 1645, 1 }, { 8838, 2 } }, out = { 249869, 1 }, oq = 1 },
    [1249962] = { name = "Sage's Tea", t = { 1, 260, 275, 290 }, scroll = 249884, train = 250, sq = 1, r = { { 8766, 1 }, { 13465, 2 } }, out = { 249870, 1 }, oq = 1 },
    [1249963] = { name = "Venomous Smoothie", t = { 1, 30, 37, 45 }, scroll = 249885, train = 25, sq = 1, favor = 30, r = { { 159, 1 }, { 2678, 1 }, { 1475, 1 } }, out = { 249871, 1 }, oq = 1 },
    [1249964] = { name = "Slimy Smoothie", t = { 1, 105, 112, 120 }, scroll = 249886, train = 100, sq = 1, favor = 30, r = { { 1179, 1 }, { 2678, 2 }, { 3174, 1 } }, out = { 249872, 1 }, oq = 1 },
    [1249965] = { name = "Mrrggl Smrrthle", t = { 1, 135, 140, 145 }, scroll = 249887, train = 125, sq = 1, favor = 30, r = { { 1205, 1 }, { 2692, 2 }, { 1468, 1 } }, out = { 249873, 1 }, oq = 1 },
    [1249966] = { name = "Calcified Smoothie", t = { 1, 185, 190, 195 }, scroll = 249888, train = 180, sq = 1, favor = 60, favorRep = 5, r = { { 1708, 1 }, { 2692, 3 }, { 5637, 1 } }, out = { 249874, 1 }, oq = 1 },
    [1249967] = { name = "Spicy Smoothie", t = { 1, 215, 220, 225 }, scroll = 249889, train = 200, sq = 1, favor = 60, favorRep = 5, r = { { 1645, 1 }, { 3713, 3 }, { 4402, 1 } }, out = { 249875, 1 }, oq = 1 },
    [1249968] = { name = "Wicked Smoothie", t = { 1, 255, 262, 270 }, scroll = 249890, train = 250, sq = 1, favor = 90, favorRep = 6, r = { { 8766, 1 }, { 3713, 4 }, { 8146, 1 } }, out = { 249876, 1 }, oq = 1 },
    [1250142] = { name = "Savory Stag Sliders", t = { 1, 230, 237, 245 }, scroll = 250173, train = 225, sq = 1, r = { { 5471, 2 }, { 2692, 3 } }, out = { 250065, 1 }, oq = 1 },
    [1250143] = { name = "Soaring Pamplona", t = { 1, 280, 295, 310 }, scroll = 250174, train = 275, sq = 1, r = { { 3404, 3 }, { 3713, 3 } }, out = { 250066, 1 }, oq = 1 },
    [1250144] = { name = "Bat Hachee", t = { 1, 280, 295, 310 }, scroll = 250175, train = 275, sq = 1, r = { { 12223, 3 }, { 3713, 2 } }, out = { 250067, 1 }, oq = 1 },
    [1250145] = { name = "Savory Turtle Stew", t = { 1, 280, 295, 310 }, scroll = 250176, train = 275, sq = 1, r = { { 3712, 3 }, { 3713, 3 } }, out = { 250068, 1 }, oq = 1 },
    [1250146] = { name = "Flank au Poivre", t = { 1, 285, 300, 315 }, scroll = 250177, train = 275, sq = 1, r = { { 12203, 3 }, { 3713, 3 } }, out = { 250069, 1 }, oq = 1 },
    [1250147] = { name = "Bear Bruscitti", t = { 1, 280, 295, 310 }, scroll = 250178, train = 275, sq = 1, r = { { 3730, 3 }, { 3713, 3 } }, out = { 250070, 1 }, oq = 1 },
    [1250148] = { name = "Steaming Stag Steak", t = { 1, 280, 295, 310 }, scroll = 250179, train = 275, sq = 1, r = { { 5471, 3 }, { 3713, 4 } }, out = { 250071, 1 }, oq = 1 },
    [1250149] = { name = "Swiftstrike Steak", t = { 1, 280, 295, 310 }, scroll = 250180, train = 275, sq = 1, r = { { 12202, 3 }, { 3713, 2 } }, out = { 250072, 1 }, oq = 1 },
    [1250150] = { name = "Raging Raptor Ribs", t = { 1, 280, 295, 310 }, scroll = 250181, train = 180, sq = 1, r = { { 12184, 2 }, { 2692, 3 } }, out = { 250073, 1 }, oq = 1 },
    [1250151] = { name = "Bear Brisket", t = { 1, 200, 210, 220 }, scroll = 250182, train = 175, sq = 1, r = { { 3730, 2 }, { 2692, 3 } }, out = { 250074, 1 }, oq = 1 },
    [1250152] = { name = "Prehistoric Pulled Raptor", t = { 1, 280, 295, 310 }, scroll = 250183, train = 275, sq = 1, r = { { 12184, 3 }, { 3713, 4 } }, out = { 250075, 1 }, oq = 1 },
    [1250153] = { name = "Raptor Rouladen", t = { 1, 230, 237, 245 }, scroll = 250184, train = 225, sq = 1, r = { { 12184, 2 }, { 2692, 4 } }, out = { 250076, 1 }, oq = 1 },
    [1250154] = { name = "Twice-Spiced Raptor Slice", t = { 1, 115, 132, 150 }, scroll = 250185, train = 75, sq = 1, r = { { 12184, 1 }, { 2678, 2 } }, out = { 250077, 1 }, oq = 1 },
    [1250155] = { name = "Giant Scrambled Eggs", t = { 1, 195, 207, 220 }, scroll = 250186, train = 175, sq = 1, r = { { 12207, 2 }, { 2692, 4 } }, out = { 250078, 1 }, oq = 1 },
    [1250156] = { name = "Tasty Raptor Bites", t = { 1, 35, 55, 75 }, scroll = 250187, train = 25, sq = 1, r = { { 3685, 1 }, { 2678, 4 } }, out = { 250079, 1 }, oq = 1 },
    [1250157] = { name = "Breakfast Omelette", t = { 1, 80, 87, 95 }, scroll = 250188, train = 75, sq = 1, r = { { 6889, 1 }, { 2678, 4 } }, out = { 250080, 1 }, oq = 1 },
    [1250158] = { name = "Clam Linguine", t = { 1, 280, 295, 310 }, scroll = 250189, train = 275, sq = 1, r = { { 7974, 3 }, { 3713, 4 } }, out = { 250081, 1 }, oq = 1 },
    [1252566] = { name = "Savory Whimsyfin Delight", t = { 1, 125, 145, 165 }, scroll = 251526, train = 85, sq = 2, r = { { 251524, 1 }, { 2678, 1 } }, out = { 251525, 1 }, oq = 1 },
    [1262978] = { name = "Cookie's Feast", t = { 1, 145, 147, 150 }, scroll = 273102, train = 140, sq = 2, r = { { 12037, 2 }, { 12204, 1 }, { 3713, 1 } }, out = { 279957, 1 }, oq = 1 },
    [1270632] = { name = "Critter Cookie", t = { 1, 80, 82, 85 }, scroll = 263505, train = 70, sq = 1, r = { { 10284, 5 } }, out = { 263507, 1 }, oq = 1 },
    [1270633] = { name = "Skywall Souffle", t = { 1, 30, 37, 45 }, scroll = 263511, train = 25, sq = 1, r = { { 6889, 2 }, { 10284, 1 } }, out = { 263509, 1 }, oq = 1 },
    [1270635] = { name = "Pincer Bites", t = { 1, 40, 47, 55 }, scroll = 263513, train = 35, sq = 1, r = { { 2675, 1 }, { 10284, 1 } }, out = { 263512, 1 }, oq = 1 },
    [1283400] = { name = "Journeyman Campfire", t = { 1, 95, 100, 105 }, scroll = 273087, train = 90, sq = 2, r = { { 11291, 1 } }, out = { 279961, 1 }, oq = 1 },
    [1291341] = { name = "Expert Campfire", t = { 1, 205, 212, 220 }, scroll = 273101, train = 200, sq = 2, r = { { 272941, 1 } }, out = { 279974, 1 }, oq = 1 },
    [1294014] = { name = "Sweetpaw Jam", t = { 1, 280, 282, 285 }, scroll = 274415, train = 275, scrollPrice = 5000, sq = 1, r = { { 249796, 3 }, { 3713, 1 } }, out = { 267341, 1 }, oq = 1 },
    [1295805] = { name = "Briny Seafood Stew", t = { 1, 220, 230, 240 }, scroll = 274972, train = 200, sq = 1, r = { { 730, 2 }, { 12206, 1 }, { 2692, 1 } }, out = { 274971, 1 }, oq = 1 },
    [1295834] = { name = "Plain Ol' Paletusk", t = { 1, 200, 215, 230 }, scroll = 274977, train = 185, scrollPrice = 2000, sq = 1, r = { { 769, 2 }, { 2678, 1 } }, out = { 274976, 1 }, oq = 1 },
    [1319313] = { name = "Plated Armorfish", t = { 1, 245, 250, 255 }, scroll = 286153, train = 225, sq = 1, r = { { 13890, 1 }, { 3713, 1 } }, out = { 286152, 1 }, oq = 1 },
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
ES.Data.VendorPrices[159] = 5
ES.Data.VendorPrices[1179] = 25
ES.Data.VendorPrices[1205] = 100
ES.Data.VendorPrices[1645] = 400
ES.Data.VendorPrices[1708] = 200
ES.Data.VendorPrices[2596] = 120
ES.Data.VendorPrices[2678] = 2
ES.Data.VendorPrices[2692] = 40
ES.Data.VendorPrices[2894] = 50
ES.Data.VendorPrices[3713] = 160
ES.Data.VendorPrices[4470] = 38
ES.Data.VendorPrices[4536] = 5
ES.Data.VendorPrices[8766] = 800
ES.Data.VendorPrices[10284] = 200
ES.Data.VendorPrices[11291] = 4500
ES.Data.VendorPrices[17196] = 50
ES.Data.VendorPrices[272941] = 200000
ES.Data.SellPrices[159] = 1
ES.Data.SellPrices[723] = 15
ES.Data.SellPrices[724] = 25
ES.Data.SellPrices[729] = 17
ES.Data.SellPrices[730] = 16
ES.Data.SellPrices[731] = 27
ES.Data.SellPrices[733] = 100
ES.Data.SellPrices[769] = 3
ES.Data.SellPrices[785] = 20
ES.Data.SellPrices[787] = 1
ES.Data.SellPrices[1015] = 24
ES.Data.SellPrices[1017] = 100
ES.Data.SellPrices[1080] = 78
ES.Data.SellPrices[1081] = 50
ES.Data.SellPrices[1082] = 150
ES.Data.SellPrices[1179] = 6
ES.Data.SellPrices[1205] = 25
ES.Data.SellPrices[1468] = 28
ES.Data.SellPrices[1475] = 82
ES.Data.SellPrices[1645] = 100
ES.Data.SellPrices[1708] = 50
ES.Data.SellPrices[2251] = 12
ES.Data.SellPrices[2447] = 10
ES.Data.SellPrices[2452] = 15
ES.Data.SellPrices[2596] = 30
ES.Data.SellPrices[2672] = 4
ES.Data.SellPrices[2673] = 10
ES.Data.SellPrices[2674] = 12
ES.Data.SellPrices[2675] = 11
ES.Data.SellPrices[2677] = 15
ES.Data.SellPrices[2678] = 1
ES.Data.SellPrices[2679] = 5
ES.Data.SellPrices[2680] = 10
ES.Data.SellPrices[2681] = 6
ES.Data.SellPrices[2682] = 25
ES.Data.SellPrices[2683] = 25
ES.Data.SellPrices[2684] = 20
ES.Data.SellPrices[2685] = 75
ES.Data.SellPrices[2687] = 25
ES.Data.SellPrices[2692] = 10
ES.Data.SellPrices[2886] = 5
ES.Data.SellPrices[2888] = 10
ES.Data.SellPrices[2894] = 12
ES.Data.SellPrices[2924] = 16
ES.Data.SellPrices[3172] = 18
ES.Data.SellPrices[3173] = 15
ES.Data.SellPrices[3174] = 16
ES.Data.SellPrices[3220] = 40
ES.Data.SellPrices[3357] = 75
ES.Data.SellPrices[3404] = 181
ES.Data.SellPrices[3662] = 25
ES.Data.SellPrices[3663] = 125
ES.Data.SellPrices[3664] = 100
ES.Data.SellPrices[3665] = 150
ES.Data.SellPrices[3666] = 100
ES.Data.SellPrices[3667] = 25
ES.Data.SellPrices[3685] = 71
ES.Data.SellPrices[3712] = 87
ES.Data.SellPrices[3713] = 40
ES.Data.SellPrices[3726] = 125
ES.Data.SellPrices[3727] = 125
ES.Data.SellPrices[3728] = 300
ES.Data.SellPrices[3729] = 300
ES.Data.SellPrices[3730] = 45
ES.Data.SellPrices[3731] = 55
ES.Data.SellPrices[3818] = 125
ES.Data.SellPrices[3821] = 150
ES.Data.SellPrices[4402] = 250
ES.Data.SellPrices[4457] = 300
ES.Data.SellPrices[4470] = 9
ES.Data.SellPrices[4536] = 1
ES.Data.SellPrices[4592] = 1
ES.Data.SellPrices[4593] = 4
ES.Data.SellPrices[4594] = 6
ES.Data.SellPrices[4603] = 4
ES.Data.SellPrices[4655] = 71
ES.Data.SellPrices[5051] = 1
ES.Data.SellPrices[5095] = 3
ES.Data.SellPrices[5465] = 3
ES.Data.SellPrices[5466] = 8
ES.Data.SellPrices[5467] = 7
ES.Data.SellPrices[5468] = 12
ES.Data.SellPrices[5469] = 9
ES.Data.SellPrices[5470] = 28
ES.Data.SellPrices[5471] = 30
ES.Data.SellPrices[5472] = 10
ES.Data.SellPrices[5473] = 10
ES.Data.SellPrices[5474] = 9
ES.Data.SellPrices[5476] = 3
ES.Data.SellPrices[5477] = 18
ES.Data.SellPrices[5478] = 70
ES.Data.SellPrices[5479] = 125
ES.Data.SellPrices[5480] = 95
ES.Data.SellPrices[5503] = 16
ES.Data.SellPrices[5504] = 22
ES.Data.SellPrices[5525] = 20
ES.Data.SellPrices[5526] = 75
ES.Data.SellPrices[5527] = 95
ES.Data.SellPrices[5637] = 75
ES.Data.SellPrices[6038] = 312
ES.Data.SellPrices[6289] = 1
ES.Data.SellPrices[6290] = 1
ES.Data.SellPrices[6291] = 1
ES.Data.SellPrices[6303] = 1
ES.Data.SellPrices[6308] = 2
ES.Data.SellPrices[6316] = 3
ES.Data.SellPrices[6317] = 2
ES.Data.SellPrices[6361] = 2
ES.Data.SellPrices[6362] = 4
ES.Data.SellPrices[6522] = 4
ES.Data.SellPrices[6657] = 5
ES.Data.SellPrices[6887] = 5
ES.Data.SellPrices[6888] = 10
ES.Data.SellPrices[6889] = 4
ES.Data.SellPrices[6890] = 6
ES.Data.SellPrices[7676] = 30
ES.Data.SellPrices[7974] = 50
ES.Data.SellPrices[8146] = 500
ES.Data.SellPrices[8150] = 250
ES.Data.SellPrices[8364] = 6
ES.Data.SellPrices[8365] = 4
ES.Data.SellPrices[8766] = 200
ES.Data.SellPrices[8838] = 60
ES.Data.SellPrices[8957] = 200
ES.Data.SellPrices[8959] = 160
ES.Data.SellPrices[9061] = 250
ES.Data.SellPrices[10284] = 50
ES.Data.SellPrices[10841] = 85
ES.Data.SellPrices[11291] = 1125
ES.Data.SellPrices[12037] = 87
ES.Data.SellPrices[12184] = 87
ES.Data.SellPrices[12202] = 87
ES.Data.SellPrices[12203] = 87
ES.Data.SellPrices[12204] = 112
ES.Data.SellPrices[12205] = 112
ES.Data.SellPrices[12206] = 112
ES.Data.SellPrices[12207] = 150
ES.Data.SellPrices[12208] = 150
ES.Data.SellPrices[12209] = 95
ES.Data.SellPrices[12210] = 300
ES.Data.SellPrices[12212] = 300
ES.Data.SellPrices[12213] = 300
ES.Data.SellPrices[12214] = 300
ES.Data.SellPrices[12215] = 300
ES.Data.SellPrices[12216] = 300
ES.Data.SellPrices[12217] = 300
ES.Data.SellPrices[12218] = 300
ES.Data.SellPrices[12223] = 4
ES.Data.SellPrices[12224] = 10
ES.Data.SellPrices[13465] = 150
ES.Data.SellPrices[13754] = 6
ES.Data.SellPrices[13755] = 7
ES.Data.SellPrices[13756] = 9
ES.Data.SellPrices[13758] = 4
ES.Data.SellPrices[13759] = 10
ES.Data.SellPrices[13760] = 10
ES.Data.SellPrices[13851] = 312
ES.Data.SellPrices[13888] = 12
ES.Data.SellPrices[13889] = 5
ES.Data.SellPrices[13890] = 70
ES.Data.SellPrices[13893] = 15
ES.Data.SellPrices[13927] = 8
ES.Data.SellPrices[13928] = 8
ES.Data.SellPrices[13929] = 10
ES.Data.SellPrices[13930] = 5
ES.Data.SellPrices[13931] = 12
ES.Data.SellPrices[13932] = 12
ES.Data.SellPrices[13933] = 14
ES.Data.SellPrices[13934] = 18
ES.Data.SellPrices[13935] = 10
ES.Data.SellPrices[16766] = 100
ES.Data.SellPrices[17196] = 12
ES.Data.SellPrices[17197] = 10
ES.Data.SellPrices[17198] = 9
ES.Data.SellPrices[17222] = 300
ES.Data.SellPrices[18045] = 300
ES.Data.SellPrices[18254] = 18
ES.Data.SellPrices[18255] = 15
ES.Data.SellPrices[20074] = 300
ES.Data.SellPrices[20424] = 175
ES.Data.SellPrices[20452] = 250
ES.Data.SellPrices[21023] = 250
ES.Data.SellPrices[21071] = 25
ES.Data.SellPrices[21072] = 40
ES.Data.SellPrices[21153] = 125
ES.Data.SellPrices[21217] = 125
ES.Data.SellPrices[232438] = 5
ES.Data.SellPrices[238637] = 250
ES.Data.SellPrices[238638] = 250
ES.Data.SellPrices[238639] = 250
ES.Data.SellPrices[238641] = 250
ES.Data.SellPrices[238642] = 250
ES.Data.SellPrices[249796] = 150
ES.Data.SellPrices[249865] = 1
ES.Data.SellPrices[249866] = 1
ES.Data.SellPrices[249867] = 1
ES.Data.SellPrices[249868] = 1
ES.Data.SellPrices[249869] = 1
ES.Data.SellPrices[249870] = 1
ES.Data.SellPrices[249871] = 1
ES.Data.SellPrices[249872] = 1
ES.Data.SellPrices[249873] = 1
ES.Data.SellPrices[249874] = 1
ES.Data.SellPrices[249875] = 1
ES.Data.SellPrices[249876] = 1
ES.Data.SellPrices[250065] = 150
ES.Data.SellPrices[250066] = 5
ES.Data.SellPrices[250067] = 10
ES.Data.SellPrices[250068] = 6
ES.Data.SellPrices[250069] = 25
ES.Data.SellPrices[250070] = 25
ES.Data.SellPrices[250071] = 10
ES.Data.SellPrices[250072] = 40
ES.Data.SellPrices[250073] = 125
ES.Data.SellPrices[250074] = 125
ES.Data.SellPrices[250075] = 10
ES.Data.SellPrices[250076] = 10
ES.Data.SellPrices[250077] = 9
ES.Data.SellPrices[250078] = 18
ES.Data.SellPrices[250079] = 10
ES.Data.SellPrices[250080] = 6
ES.Data.SellPrices[250081] = 10
ES.Data.SellPrices[251524] = 4
ES.Data.SellPrices[251525] = 5
ES.Data.SellPrices[263509] = 100
ES.Data.SellPrices[263512] = 100
ES.Data.SellPrices[267341] = 200
ES.Data.SellPrices[272941] = 50000
ES.Data.SellPrices[274971] = 12
ES.Data.SellPrices[274976] = 75
ES.Data.SellPrices[286152] = 8

-- Nombre de cada objeto (inglés, del cliente): se muestra mientras el juego no lo ha cargado
ES.Data.ItemNames = ES.Data.ItemNames or {}
ES.Data.ItemNames[159] = "Refreshing Spring Water"
ES.Data.ItemNames[723] = "Goretusk Liver"
ES.Data.ItemNames[724] = "Goretusk Liver Pie"
ES.Data.ItemNames[729] = "Stringy Vulture Meat"
ES.Data.ItemNames[730] = "Murloc Eye"
ES.Data.ItemNames[731] = "Goretusk Snout"
ES.Data.ItemNames[733] = "Westfall Stew"
ES.Data.ItemNames[769] = "Chunk of Boar Meat"
ES.Data.ItemNames[785] = "Mageroyal"
ES.Data.ItemNames[787] = "Slitherskin Mackerel"
ES.Data.ItemNames[1015] = "Lean Wolf Flank"
ES.Data.ItemNames[1017] = "Seasoned Wolf Kabob"
ES.Data.ItemNames[1080] = "Tough Condor Meat"
ES.Data.ItemNames[1081] = "Crisp Spider Meat"
ES.Data.ItemNames[1082] = "Redridge Goulash"
ES.Data.ItemNames[1179] = "Ice Cold Milk"
ES.Data.ItemNames[1205] = "Melon Juice"
ES.Data.ItemNames[1468] = "Murloc Fin"
ES.Data.ItemNames[1475] = "Small Venom Sac"
ES.Data.ItemNames[1645] = "Moonberry Juice"
ES.Data.ItemNames[1708] = "Sweet Nectar"
ES.Data.ItemNames[2251] = "Gooey Spider Leg"
ES.Data.ItemNames[2447] = "Peacebloom"
ES.Data.ItemNames[2452] = "Swiftthistle"
ES.Data.ItemNames[2596] = "Skin of Dwarven Stout"
ES.Data.ItemNames[2672] = "Stringy Wolf Meat"
ES.Data.ItemNames[2673] = "Coyote Meat"
ES.Data.ItemNames[2674] = "Crawler Meat"
ES.Data.ItemNames[2675] = "Crawler Claw"
ES.Data.ItemNames[2677] = "Boar Ribs"
ES.Data.ItemNames[2678] = "Mild Spices"
ES.Data.ItemNames[2679] = "Charred Wolf Meat"
ES.Data.ItemNames[2680] = "Spiced Wolf Meat"
ES.Data.ItemNames[2681] = "Roasted Boar Meat"
ES.Data.ItemNames[2682] = "Cooked Crab Claw"
ES.Data.ItemNames[2683] = "Crab Cake"
ES.Data.ItemNames[2684] = "Coyote Steak"
ES.Data.ItemNames[2685] = "Succulent Pork Ribs"
ES.Data.ItemNames[2687] = "Dry Pork Ribs"
ES.Data.ItemNames[2692] = "Hot Spices"
ES.Data.ItemNames[2886] = "Crag Boar Rib"
ES.Data.ItemNames[2888] = "Beer Basted Boar Ribs"
ES.Data.ItemNames[2894] = "Rhapsody Malt"
ES.Data.ItemNames[2924] = "Crocolisk Meat"
ES.Data.ItemNames[3172] = "Boar Intestines"
ES.Data.ItemNames[3173] = "Bear Meat"
ES.Data.ItemNames[3174] = "Spider Ichor"
ES.Data.ItemNames[3220] = "Blood Sausage"
ES.Data.ItemNames[3357] = "Liferoot"
ES.Data.ItemNames[3404] = "Buzzard Wing"
ES.Data.ItemNames[3662] = "Crocolisk Steak"
ES.Data.ItemNames[3663] = "Murloc Fin Soup"
ES.Data.ItemNames[3664] = "Crocolisk Gumbo"
ES.Data.ItemNames[3665] = "Curiously Tasty Omelet"
ES.Data.ItemNames[3666] = "Gooey Spider Cake"
ES.Data.ItemNames[3667] = "Tender Crocolisk Meat"
ES.Data.ItemNames[3685] = "Raptor Egg"
ES.Data.ItemNames[3712] = "Turtle Meat"
ES.Data.ItemNames[3713] = "Soothing Spices"
ES.Data.ItemNames[3726] = "Big Bear Steak"
ES.Data.ItemNames[3727] = "Hot Lion Chops"
ES.Data.ItemNames[3728] = "Tasty Lion Steak"
ES.Data.ItemNames[3729] = "Soothing Turtle Bisque"
ES.Data.ItemNames[3730] = "Big Bear Meat"
ES.Data.ItemNames[3731] = "Lion Meat"
ES.Data.ItemNames[3818] = "Fadeleaf"
ES.Data.ItemNames[3821] = "Goldthorn"
ES.Data.ItemNames[4402] = "Small Flame Sac"
ES.Data.ItemNames[4457] = "Barbecued Buzzard Wing"
ES.Data.ItemNames[4470] = "Simple Wood"
ES.Data.ItemNames[4536] = "Shiny Red Apple"
ES.Data.ItemNames[4592] = "Longjaw Mud Snapper"
ES.Data.ItemNames[4593] = "Bristle Whisker Catfish"
ES.Data.ItemNames[4594] = "Rockscale Cod"
ES.Data.ItemNames[4603] = "Raw Spotted Yellowtail"
ES.Data.ItemNames[4655] = "Giant Clam Meat"
ES.Data.ItemNames[5051] = "Dig Rat"
ES.Data.ItemNames[5095] = "Rainbow Fin Albacore"
ES.Data.ItemNames[5465] = "Small Spider Leg"
ES.Data.ItemNames[5466] = "Scorpid Stinger"
ES.Data.ItemNames[5467] = "Kodo Meat"
ES.Data.ItemNames[5468] = "Soft Frenzy Flesh"
ES.Data.ItemNames[5469] = "Strider Meat"
ES.Data.ItemNames[5470] = "Thunder Lizard Tail"
ES.Data.ItemNames[5471] = "Stag Meat"
ES.Data.ItemNames[5472] = "Kaldorei Spider Kabob"
ES.Data.ItemNames[5473] = "Scorpid Surprise"
ES.Data.ItemNames[5474] = "Roasted Kodo Meat"
ES.Data.ItemNames[5476] = "Fillet of Frenzy"
ES.Data.ItemNames[5477] = "Strider Stew"
ES.Data.ItemNames[5478] = "Dig Rat Stew"
ES.Data.ItemNames[5479] = "Crispy Lizard Tail"
ES.Data.ItemNames[5480] = "Lean Venison"
ES.Data.ItemNames[5503] = "Clam Meat"
ES.Data.ItemNames[5504] = "Tangy Clam Meat"
ES.Data.ItemNames[5525] = "Boiled Clams"
ES.Data.ItemNames[5526] = "Clam Chowder"
ES.Data.ItemNames[5527] = "Goblin Deviled Clams"
ES.Data.ItemNames[5637] = "Large Fang"
ES.Data.ItemNames[6038] = "Giant Clam Scorcho"
ES.Data.ItemNames[6289] = "Raw Longjaw Mud Snapper"
ES.Data.ItemNames[6290] = "Brilliant Smallfish"
ES.Data.ItemNames[6291] = "Raw Brilliant Smallfish"
ES.Data.ItemNames[6303] = "Raw Slitherskin Mackerel"
ES.Data.ItemNames[6308] = "Raw Bristle Whisker Catfish"
ES.Data.ItemNames[6316] = "Loch Frenzy Delight"
ES.Data.ItemNames[6317] = "Raw Loch Frenzy"
ES.Data.ItemNames[6361] = "Raw Rainbow Fin Albacore"
ES.Data.ItemNames[6362] = "Raw Rockscale Cod"
ES.Data.ItemNames[6522] = "Deviate Fish"
ES.Data.ItemNames[6657] = "Savory Deviate Delight"
ES.Data.ItemNames[6887] = "Spotted Yellowtail"
ES.Data.ItemNames[6888] = "Herb Baked Egg"
ES.Data.ItemNames[6889] = "Small Egg"
ES.Data.ItemNames[6890] = "Smoked Bear Meat"
ES.Data.ItemNames[7676] = "Thistle Tea"
ES.Data.ItemNames[7974] = "Zesty Clam Meat"
ES.Data.ItemNames[8146] = "Wicked Claw"
ES.Data.ItemNames[8150] = "Deeprock Salt"
ES.Data.ItemNames[8364] = "Mithril Head Trout"
ES.Data.ItemNames[8365] = "Raw Mithril Head Trout"
ES.Data.ItemNames[8766] = "Morning Glory Dew"
ES.Data.ItemNames[8838] = "Sungrass"
ES.Data.ItemNames[8957] = "Spinefin Halibut"
ES.Data.ItemNames[8959] = "Raw Spinefin Halibut"
ES.Data.ItemNames[9061] = "Goblin Rocket Fuel"
ES.Data.ItemNames[10284] = "Simple Flour"
ES.Data.ItemNames[10841] = "Goldthorn Tea"
ES.Data.ItemNames[11291] = "Star Wood"
ES.Data.ItemNames[12037] = "Mystery Meat"
ES.Data.ItemNames[12184] = "Raptor Flesh"
ES.Data.ItemNames[12202] = "Tiger Meat"
ES.Data.ItemNames[12203] = "Red Wolf Meat"
ES.Data.ItemNames[12204] = "Heavy Kodo Meat"
ES.Data.ItemNames[12205] = "White Spider Meat"
ES.Data.ItemNames[12206] = "Tender Crab Meat"
ES.Data.ItemNames[12207] = "Giant Egg"
ES.Data.ItemNames[12208] = "Tender Wolf Meat"
ES.Data.ItemNames[12209] = "Lean Wolf Steak"
ES.Data.ItemNames[12210] = "Roast Raptor"
ES.Data.ItemNames[12212] = "Jungle Stew"
ES.Data.ItemNames[12213] = "Carrion Surprise"
ES.Data.ItemNames[12214] = "Mystery Stew"
ES.Data.ItemNames[12215] = "Heavy Kodo Stew"
ES.Data.ItemNames[12216] = "Spiced Chili Crab"
ES.Data.ItemNames[12217] = "Dragonbreath Chili"
ES.Data.ItemNames[12218] = "Monster Omelet"
ES.Data.ItemNames[12223] = "Meaty Bat Wing"
ES.Data.ItemNames[12224] = "Crispy Bat Wing"
ES.Data.ItemNames[13465] = "Mountain Silversage"
ES.Data.ItemNames[13754] = "Raw Glossy Mightfish"
ES.Data.ItemNames[13755] = "Raw Winter Squid"
ES.Data.ItemNames[13756] = "Raw Summer Bass"
ES.Data.ItemNames[13758] = "Raw Redgill"
ES.Data.ItemNames[13759] = "Raw Nightfin Snapper"
ES.Data.ItemNames[13760] = "Raw Sunscale Salmon"
ES.Data.ItemNames[13851] = "Hot Wolf Ribs"
ES.Data.ItemNames[13888] = "Darkclaw Lobster"
ES.Data.ItemNames[13889] = "Raw Whitescale Salmon"
ES.Data.ItemNames[13890] = "Raw Plated Armorfish"
ES.Data.ItemNames[13893] = "Large Raw Mightfish"
ES.Data.ItemNames[13927] = "Cooked Glossy Mightfish"
ES.Data.ItemNames[13928] = "Grilled Squid"
ES.Data.ItemNames[13929] = "Hot Smoked Bass"
ES.Data.ItemNames[13930] = "Filet of Redgill"
ES.Data.ItemNames[13931] = "Nightfin Soup"
ES.Data.ItemNames[13932] = "Poached Sunscale Salmon"
ES.Data.ItemNames[13933] = "Lobster Stew"
ES.Data.ItemNames[13934] = "Mightfish Steak"
ES.Data.ItemNames[13935] = "Baked Salmon"
ES.Data.ItemNames[16766] = "Undermine Clam Chowder"
ES.Data.ItemNames[17194] = "Holiday Spices"
ES.Data.ItemNames[17196] = "Holiday Spirits"
ES.Data.ItemNames[17197] = "Gingerbread Cookie"
ES.Data.ItemNames[17198] = "Egg Nog"
ES.Data.ItemNames[17222] = "Spider Sausage"
ES.Data.ItemNames[18045] = "Tender Wolf Steak"
ES.Data.ItemNames[18254] = "Runn Tum Tuber Surprise"
ES.Data.ItemNames[18255] = "Runn Tum Tuber"
ES.Data.ItemNames[20074] = "Heavy Crocolisk Stew"
ES.Data.ItemNames[20424] = "Sandworm Meat"
ES.Data.ItemNames[20452] = "Smoked Desert Dumplings"
ES.Data.ItemNames[21023] = "Dirge's Kickin' Chimaerok Chops"
ES.Data.ItemNames[21024] = "Chimaerok Tenderloin"
ES.Data.ItemNames[21071] = "Raw Sagefish"
ES.Data.ItemNames[21072] = "Smoked Sagefish"
ES.Data.ItemNames[21153] = "Raw Greater Sagefish"
ES.Data.ItemNames[21217] = "Sagefish Delight"
ES.Data.ItemNames[232438] = "Smoked Redgill"
ES.Data.ItemNames[238637] = "Prowler Steak"
ES.Data.ItemNames[238638] = "Filet o' Flank"
ES.Data.ItemNames[238639] = "Sunrise Omelette"
ES.Data.ItemNames[238641] = "Specklefin Feast"
ES.Data.ItemNames[238642] = "Grand Lobster Banquet"
ES.Data.ItemNames[239016] = "Holy Salts"
ES.Data.ItemNames[239017] = "Exquisite Spices"
ES.Data.ItemNames[249796] = "Hyjal Berries"
ES.Data.ItemNames[249865] = "Peace Tea"
ES.Data.ItemNames[249866] = "Royal Tea"
ES.Data.ItemNames[249867] = "Root Tea"
ES.Data.ItemNames[249868] = "Triage Tea"
ES.Data.ItemNames[249869] = "Sunny Tea"
ES.Data.ItemNames[249870] = "Sage's Tea"
ES.Data.ItemNames[249871] = "Venomous Smoothie"
ES.Data.ItemNames[249872] = "Slimy Smoothie"
ES.Data.ItemNames[249873] = "Mrrggl Smrrthle"
ES.Data.ItemNames[249874] = "Calcified Smoothie"
ES.Data.ItemNames[249875] = "Spicy Smoothie"
ES.Data.ItemNames[249876] = "Wicked Smoothie"
ES.Data.ItemNames[250065] = "Savory Stag Sliders"
ES.Data.ItemNames[250066] = "Soaring Pamplona"
ES.Data.ItemNames[250067] = "Bat Hachee"
ES.Data.ItemNames[250068] = "Savory Turtle Stew"
ES.Data.ItemNames[250069] = "Flank au Poivre"
ES.Data.ItemNames[250070] = "Bear Bruscitti"
ES.Data.ItemNames[250071] = "Steaming Stag Steak"
ES.Data.ItemNames[250072] = "Swiftstrike Steak"
ES.Data.ItemNames[250073] = "Raging Raptor Ribs"
ES.Data.ItemNames[250074] = "Bear Brisket"
ES.Data.ItemNames[250075] = "Prehistoric Pulled Raptor"
ES.Data.ItemNames[250076] = "Raptor Rouladen"
ES.Data.ItemNames[250077] = "Twice-Spiced Raptor Slice"
ES.Data.ItemNames[250078] = "Giant Scrambled Eggs"
ES.Data.ItemNames[250079] = "Tasty Raptor Bites"
ES.Data.ItemNames[250080] = "Breakfast Omelette"
ES.Data.ItemNames[250081] = "Clam Linguine"
ES.Data.ItemNames[251524] = "Whimsyfin"
ES.Data.ItemNames[251525] = "Savory Whimsyfin Delight"
ES.Data.ItemNames[263509] = "Skywall Souffle"
ES.Data.ItemNames[263512] = "Pincer Bites"
ES.Data.ItemNames[267341] = "Sweetpaw Jam"
ES.Data.ItemNames[272941] = "Thick Logs"
ES.Data.ItemNames[274971] = "Briny Seafood Stew"
ES.Data.ItemNames[274976] = "Plain Ol' Paletusk"
ES.Data.ItemNames[279957] = "Cookie's Feast"
ES.Data.ItemNames[279961] = "Journeyman Campfire Kit"
ES.Data.ItemNames[279974] = "Expert Campfire Kit"
ES.Data.ItemNames[279981] = "Basic Campfire Kit"
ES.Data.ItemNames[286152] = "Plated Armorfish"

-- Material -> profesión de recolección que lo consigue (393 Desuello, 182 Herboristería, 186 Minería).
-- Sin uso por ahora: reservado para la vía "Vender en bruto" de Ganar dinero (docs/PLAN.md, G1).
ES.Data.GatheredBy = ES.Data.GatheredBy or {}
ES.Data.GatheredBy[785] = 182
ES.Data.GatheredBy[2447] = 182
ES.Data.GatheredBy[2452] = 182
ES.Data.GatheredBy[3357] = 182
ES.Data.GatheredBy[3818] = 182
ES.Data.GatheredBy[3821] = 182
ES.Data.GatheredBy[8150] = 186
ES.Data.GatheredBy[8838] = 182
ES.Data.GatheredBy[13465] = 182

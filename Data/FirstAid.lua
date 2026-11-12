-- Generado por tools/gen_profession.py (FirstAid). No editar a mano.
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
ES.Data.FirstAid = {
  skillLine = 129,
  ranks = { -- { tope, precio, habilidad requerida, nivel de personaje }
    { 150, 500, 50, 0 },
    { 225, 10000, 125, 35 },
    { 300, 0, 225, 35 },
  },
  -- { PNJ instructor, rangos que enseña: 1 aprendiz (75), 2 oficial (150), 4 experto (225), 8 artesano (300) }
  trainers = { { 2326, 3 }, { 2327, 3 }, { 2329, 3 }, { 2798, 3 }, { 3181, 3 }, { 3373, 3 }, { 4211, 3 }, { 4591, 3 }, { 5150, 3 }, { 5759, 3 }, { 5939, 3 }, { 5943, 3 }, { 6094, 3 }, { 251977, 3 } },
  recipes = {
    [3275] = { name = "Linen Bandage", t = { 1, 30, 45, 60 }, basic = true, r = { { 2589, 1 } }, out = { 1251, 1 }, oq = 1 },
    [3276] = { name = "Heavy Linen Bandage", t = { 1, 50, 75, 100 }, fee = 100, train = 40, r = { { 2589, 2 } }, out = { 2581, 1 }, oq = 1 },
    [3277] = { name = "Wool Bandage", t = { 1, 80, 115, 150 }, fee = 250, train = 80, r = { { 2592, 1 } }, out = { 3530, 1 }, oq = 1 },
    [3278] = { name = "Heavy Wool Bandage", t = { 1, 115, 150, 185 }, fee = 1000, train = 115, r = { { 2592, 2 } }, out = { 3531, 1 }, oq = 1 },
    [7928] = { name = "Silk Bandage", t = { 1, 150, 180, 210 }, fee = 5000, train = 150, r = { { 4306, 1 } }, out = { 6450, 1 }, oq = 1 },
    [7929] = { name = "Heavy Silk Bandage", t = { 1, 180, 210, 240 }, scroll = 16112, train = 180, scrollPrice = 2200, sq = 1, r = { { 4306, 2 } }, out = { 6451, 1 }, oq = 1 },
    [7934] = { name = "Anti-Venom", t = { 1, 80, 115, 150 }, fee = 250, train = 80, r = { { 1475, 1 } }, out = { 6452, 3 }, oq = 1 },
    [7935] = { name = "Strong Anti-Venom", t = { 1, 130, 165, 200 }, scroll = 6454, train = 130, sq = 2, r = { { 1288, 1 } }, out = { 6453, 3 }, oq = 1 },
    [10840] = { name = "Mageweave Bandage", t = { 1, 210, 240, 270 }, scroll = 16113, train = 210, scrollPrice = 5000, sq = 1, r = { { 4338, 1 } }, out = { 8544, 1 }, oq = 1 },
    [10841] = { name = "Heavy Mageweave Bandage", t = { 1, 240, 270, 300 }, gone = true, r = { { 4338, 2 } }, out = { 8545, 1 }, oq = 1 },
    [18629] = { name = "Runecloth Bandage", t = { 1, 260, 290, 320 }, gone = true, r = { { 14047, 1 } }, out = { 14529, 1 }, oq = 1 },
    [18630] = { name = "Heavy Runecloth Bandage", t = { 1, 290, 320, 350 }, gone = true, r = { { 14047, 2 } }, out = { 14530, 1 }, oq = 1 },
    [23787] = { name = "Powerful Anti-Venom", t = { 1, 300, 330, 360 }, scroll = 19442, train = 300, scrollPrice = 100000, rep = { 529, 5 }, sq = 1, r = { { 19441, 1 } }, out = { 19440, 3 }, oq = 1 },
    [30021] = { name = "Crystal Infused Bandage", t = { 1, 300, 330, 360 }, scroll = 23689, train = 290, sq = 1, r = { { 23567, 1 }, { 14047, 10 } }, out = { 23684, 4 }, oq = 1 },
    [470349] = { name = "Dense Runecloth Bandage", t = { 1, 315, 327, 340 }, scroll = 232434, train = 300, sq = 1, r = { { 14530, 2 } }, out = { 232433, 1 }, oq = 1 },
    [1230117] = { name = "First Aid Kit", t = { 1, 20, 22, 25 }, fee = 100, train = 20, r = { { 1251, 3 }, { 159, 1 } }, out = { 279968, 1 }, oq = 1 },
    [1244431] = { name = "Minor Healing Potion", t = { 1, 55, 75, 95 }, fee = 100, train = 1, r = { { 3371, 1 }, { 2678, 1 }, { 2447, 1 } }, out = { 118, 1 }, oq = 1 },
    [1244432] = { name = "Lesser Healing Potion", t = { 1, 85, 105, 125 }, fee = 150, train = 55, r = { { 3371, 1 }, { 2678, 2 }, { 2450, 1 } }, out = { 858, 1 }, oq = 1 },
    [1244433] = { name = "Healing Potion", t = { 1, 135, 155, 175 }, fee = 800, train = 110, r = { { 3372, 1 }, { 2692, 1 }, { 2453, 1 } }, out = { 929, 1 }, oq = 1 },
    [1244434] = { name = "Greater Healing Potion", t = { 1, 175, 195, 215 }, scroll = 255723, train = 155, sq = 2, r = { { 3372, 1 }, { 2692, 3 }, { 3357, 1 } }, out = { 1710, 1 }, oq = 1 },
    [1244435] = { name = "Superior Healing Potion", t = { 1, 230, 250, 270 }, scroll = 255725, train = 215, sq = 2, r = { { 8925, 1 }, { 3713, 1 }, { 8838, 1 } }, out = { 3928, 1 }, oq = 1 },
    [1244436] = { name = "Major Healing Potion", t = { 1, 290, 310, 330 }, scroll = 255729, train = 275, scrollPrice = 80000, sq = 2, r = { { 8925, 1 }, { 3713, 3 }, { 13464, 1 } }, out = { 13446, 1 }, oq = 1 },
    [1259341] = { name = "Potent Anti-Venom", t = { 1, 230, 260, 290 }, scroll = 255728, train = 215, sq = 2, r = { { 255645, 1 } }, out = { 255715, 3 }, oq = 1 },
    [1259342] = { name = "Simple Poultice", t = { 1, 90, 125, 160 }, fee = 250, train = 90, r = { { 3174, 1 }, { 2678, 1 }, { 2723, 1 } }, out = { 255716, 3 }, oq = 1 },
    [1259343] = { name = "Clever Poultice", t = { 1, 160, 190, 220 }, scroll = 255724, train = 140, sq = 2, r = { { 1468, 1 }, { 3713, 1 }, { 2686, 1 } }, out = { 255717, 3 }, oq = 1 },
    [1259344] = { name = "Superior Poultice", t = { 1, 225, 255, 285 }, scroll = 255727, train = 210, sq = 2, r = { { 7070, 1 }, { 2692, 1 }, { 2596, 1 } }, out = { 255718, 3 }, oq = 1 },
    [1259345] = { name = "Powerful Poultice", t = { 1, 295, 325, 355 }, scroll = 255731, train = 280, sq = 2, r = { { 7080, 1 }, { 2692, 1 }, { 2594, 1 } }, out = { 255719, 3 }, oq = 1 },
    [1259347] = { name = "Woolen Tourniquet", t = { 1, 120, 155, 190 }, fee = 1200, train = 120, r = { { 2592, 2 }, { 2321, 2 } }, out = { 255720, 1 }, oq = 1 },
    [1259348] = { name = "Leather Tourniquet", t = { 1, 220, 250, 280 }, scroll = 255726, train = 200, sq = 2, r = { { 4304, 2 }, { 4291, 2 } }, out = { 255721, 1 }, oq = 1 },
    [1259349] = { name = "Surgical Tourniquet", t = { 1, 280, 310, 340 }, scroll = 255730, train = 265, sq = 2, r = { { 8170, 2 }, { 14047, 2 }, { 8343, 2 } }, out = { 255722, 1 }, oq = 1 },
    [1262996] = { name = "Toxin Study", t = { 1, 140, 142, 145 }, scroll = 273105, train = 140, sq = 2, r = { { 6452, 1 }, { 8544, 2 }, { 4470, 2 } }, out = { 279940, 1 }, oq = 1 },
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
ES.Data.VendorPrices[2321] = 100
ES.Data.VendorPrices[2594] = 1500
ES.Data.VendorPrices[2596] = 120
ES.Data.VendorPrices[2678] = 2
ES.Data.VendorPrices[2686] = 50
ES.Data.VendorPrices[2692] = 40
ES.Data.VendorPrices[2723] = 50
ES.Data.VendorPrices[3371] = 4
ES.Data.VendorPrices[3372] = 40
ES.Data.VendorPrices[3713] = 160
ES.Data.VendorPrices[4291] = 500
ES.Data.VendorPrices[4470] = 38
ES.Data.VendorPrices[8343] = 2000
ES.Data.VendorPrices[8925] = 500
ES.Data.SellPrices[118] = 5
ES.Data.SellPrices[159] = 1
ES.Data.SellPrices[858] = 25
ES.Data.SellPrices[929] = 75
ES.Data.SellPrices[1251] = 10
ES.Data.SellPrices[1288] = 185
ES.Data.SellPrices[1468] = 28
ES.Data.SellPrices[1475] = 82
ES.Data.SellPrices[1710] = 125
ES.Data.SellPrices[2321] = 25
ES.Data.SellPrices[2447] = 10
ES.Data.SellPrices[2450] = 25
ES.Data.SellPrices[2453] = 25
ES.Data.SellPrices[2581] = 20
ES.Data.SellPrices[2589] = 13
ES.Data.SellPrices[2592] = 33
ES.Data.SellPrices[2594] = 375
ES.Data.SellPrices[2596] = 30
ES.Data.SellPrices[2678] = 1
ES.Data.SellPrices[2686] = 12
ES.Data.SellPrices[2692] = 10
ES.Data.SellPrices[2723] = 12
ES.Data.SellPrices[3174] = 16
ES.Data.SellPrices[3357] = 75
ES.Data.SellPrices[3371] = 1
ES.Data.SellPrices[3372] = 10
ES.Data.SellPrices[3530] = 28
ES.Data.SellPrices[3531] = 57
ES.Data.SellPrices[3713] = 40
ES.Data.SellPrices[3928] = 250
ES.Data.SellPrices[4291] = 125
ES.Data.SellPrices[4304] = 300
ES.Data.SellPrices[4306] = 150
ES.Data.SellPrices[4338] = 250
ES.Data.SellPrices[4470] = 9
ES.Data.SellPrices[6450] = 200
ES.Data.SellPrices[6451] = 400
ES.Data.SellPrices[6452] = 28
ES.Data.SellPrices[6453] = 62
ES.Data.SellPrices[7070] = 400
ES.Data.SellPrices[7080] = 400
ES.Data.SellPrices[8170] = 500
ES.Data.SellPrices[8343] = 500
ES.Data.SellPrices[8544] = 400
ES.Data.SellPrices[8545] = 600
ES.Data.SellPrices[8838] = 60
ES.Data.SellPrices[8925] = 125
ES.Data.SellPrices[13446] = 1000
ES.Data.SellPrices[13464] = 100
ES.Data.SellPrices[14047] = 400
ES.Data.SellPrices[14529] = 500
ES.Data.SellPrices[14530] = 1000
ES.Data.SellPrices[19440] = 500
ES.Data.SellPrices[19441] = 1500
ES.Data.SellPrices[23684] = 1500
ES.Data.SellPrices[232433] = 2000
ES.Data.SellPrices[255645] = 370
ES.Data.SellPrices[255715] = 125
ES.Data.SellPrices[255716] = 28
ES.Data.SellPrices[255717] = 62
ES.Data.SellPrices[255718] = 125
ES.Data.SellPrices[255719] = 500
ES.Data.SellPrices[255720] = 50
ES.Data.SellPrices[255721] = 125
ES.Data.SellPrices[255722] = 500

-- Nombre de cada objeto (inglés, del cliente): se muestra mientras el juego no lo ha cargado
ES.Data.ItemNames = ES.Data.ItemNames or {}
ES.Data.ItemNames[118] = "Minor Healing Potion"
ES.Data.ItemNames[159] = "Refreshing Spring Water"
ES.Data.ItemNames[858] = "Lesser Healing Potion"
ES.Data.ItemNames[929] = "Healing Potion"
ES.Data.ItemNames[1251] = "Linen Bandage"
ES.Data.ItemNames[1288] = "Large Venom Sac"
ES.Data.ItemNames[1468] = "Murloc Fin"
ES.Data.ItemNames[1475] = "Small Venom Sac"
ES.Data.ItemNames[1710] = "Greater Healing Potion"
ES.Data.ItemNames[2321] = "Fine Thread"
ES.Data.ItemNames[2447] = "Peacebloom"
ES.Data.ItemNames[2450] = "Briarthorn"
ES.Data.ItemNames[2453] = "Bruiseweed"
ES.Data.ItemNames[2581] = "Heavy Linen Bandage"
ES.Data.ItemNames[2589] = "Linen Cloth"
ES.Data.ItemNames[2592] = "Wool Cloth"
ES.Data.ItemNames[2594] = "Flagon of Dwarven Honeymead"
ES.Data.ItemNames[2596] = "Skin of Dwarven Stout"
ES.Data.ItemNames[2678] = "Mild Spices"
ES.Data.ItemNames[2686] = "Thunder Ale"
ES.Data.ItemNames[2692] = "Hot Spices"
ES.Data.ItemNames[2723] = "Bottle of Dalaran Noir"
ES.Data.ItemNames[3174] = "Spider Ichor"
ES.Data.ItemNames[3357] = "Liferoot"
ES.Data.ItemNames[3371] = "Empty Vial"
ES.Data.ItemNames[3372] = "Leaded Vial"
ES.Data.ItemNames[3530] = "Wool Bandage"
ES.Data.ItemNames[3531] = "Heavy Wool Bandage"
ES.Data.ItemNames[3713] = "Soothing Spices"
ES.Data.ItemNames[3928] = "Superior Healing Potion"
ES.Data.ItemNames[4291] = "Silken Thread"
ES.Data.ItemNames[4304] = "Thick Leather"
ES.Data.ItemNames[4306] = "Silk Cloth"
ES.Data.ItemNames[4338] = "Mageweave Cloth"
ES.Data.ItemNames[4470] = "Simple Wood"
ES.Data.ItemNames[6450] = "Silk Bandage"
ES.Data.ItemNames[6451] = "Heavy Silk Bandage"
ES.Data.ItemNames[6452] = "Anti-Venom"
ES.Data.ItemNames[6453] = "Strong Anti-Venom"
ES.Data.ItemNames[7070] = "Elemental Water"
ES.Data.ItemNames[7080] = "Essence of Water"
ES.Data.ItemNames[8170] = "Rugged Leather"
ES.Data.ItemNames[8343] = "Heavy Silken Thread"
ES.Data.ItemNames[8544] = "Mageweave Bandage"
ES.Data.ItemNames[8545] = "Heavy Mageweave Bandage"
ES.Data.ItemNames[8838] = "Sungrass"
ES.Data.ItemNames[8925] = "Crystal Vial"
ES.Data.ItemNames[13446] = "Major Healing Potion"
ES.Data.ItemNames[13464] = "Golden Sansam"
ES.Data.ItemNames[14047] = "Runecloth"
ES.Data.ItemNames[14529] = "Runecloth Bandage"
ES.Data.ItemNames[14530] = "Heavy Runecloth Bandage"
ES.Data.ItemNames[19440] = "Powerful Anti-Venom"
ES.Data.ItemNames[19441] = "Huge Venom Sac"
ES.Data.ItemNames[23567] = "DEPRECATED ITEM"
ES.Data.ItemNames[23684] = "Crystal Infused Bandage"
ES.Data.ItemNames[232433] = "Dense Runecloth Bandage"
ES.Data.ItemNames[255645] = "Swollen Venom Sac"
ES.Data.ItemNames[255715] = "Potent Anti-Venom"
ES.Data.ItemNames[255716] = "Simple Poultice"
ES.Data.ItemNames[255717] = "Clever Poultice"
ES.Data.ItemNames[255718] = "Superior Poultice"
ES.Data.ItemNames[255719] = "Powerful Poultice"
ES.Data.ItemNames[255720] = "Woolen Tourniquet"
ES.Data.ItemNames[255721] = "Leather Tourniquet"
ES.Data.ItemNames[255722] = "Surgical Tourniquet"
ES.Data.ItemNames[279940] = "Toxin Study"
ES.Data.ItemNames[279968] = "First Aid Kit"

-- Material -> profesión de recolección que lo consigue (393 Desuello, 182 Herboristería, 186 Minería).
-- Sin uso por ahora: reservado para la vía "Vender en bruto" de Ganar dinero (docs/PLAN.md, G1).
ES.Data.GatheredBy = ES.Data.GatheredBy or {}
ES.Data.GatheredBy[2447] = 182
ES.Data.GatheredBy[2450] = 182
ES.Data.GatheredBy[2453] = 182
ES.Data.GatheredBy[3357] = 182
ES.Data.GatheredBy[4304] = 393
ES.Data.GatheredBy[8170] = 393
ES.Data.GatheredBy[8838] = 182
ES.Data.GatheredBy[13464] = 182

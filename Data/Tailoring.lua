-- Generado por tools/gen_profession.py (Tailoring). No editar a mano.
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
ES.Data.Tailoring = {
  skillLine = 197,
  ranks = { -- { tope, precio, habilidad requerida, nivel de personaje }
    { 150, 450, 50, 10 },
    { 225, 4500, 125, 20 },
    { 300, 50000, 200, 0 },
  },
  -- { PNJ instructor, rangos que enseña: 1 aprendiz (75), 2 oficial (150), 4 experto (225), 8 artesano (300) }
  trainers = { { 1103, 1 }, { 1300, 1 }, { 1346, 4 }, { 1703, 1 }, { 2399, 8 }, { 2627, 2 }, { 2855, 1 }, { 3004, 2 }, { 3363, 2 }, { 3484, 1 }, { 3523, 1 }, { 3704, 2 }, { 4159, 2 }, { 4193, 1 }, { 4576, 4 }, { 5153, 2 }, { 5567, 2 }, { 11048, 1 }, { 11049, 2 }, { 11050, 1 }, { 11051, 1 }, { 11052, 8 }, { 251972, 2 }, { 251991, 3 }, { 252380, 3 } },
  recipes = {
    [2385] = { name = "Brown Linen Vest", t = { 1, 45, 57, 70 }, fee = 45, train = 10, r = { { 2996, 1 }, { 2320, 1 } }, out = { 2568, 1 }, oq = 1 },
    [2386] = { name = "Linen Boots", t = { 1, 65, 82, 100 }, fee = 180, train = 40, r = { { 2996, 3 }, { 2320, 1 }, { 2318, 1 } }, out = { 2569, 1 }, oq = 2 },
    [2387] = { name = "Linen Cloak", t = { 1, 35, 47, 60 }, basic = true, r = { { 2996, 1 }, { 2320, 1 } }, out = { 2570, 1 }, oq = 1 },
    [2389] = { name = "Red Linen Robe", t = { 1, 50, 67, 85 }, scroll = 2598, train = 25, sq = 2, r = { { 2996, 3 }, { 2320, 2 }, { 2604, 2 } }, out = { 2572, 1 }, oq = 2 },
    [2392] = { name = "Red Linen Shirt", t = { 1, 50, 67, 85 }, fee = 45, train = 25, r = { { 2996, 2 }, { 2320, 1 }, { 2604, 1 } }, out = { 2575, 1 }, oq = 1 },
    [2393] = { name = "White Linen Shirt", t = { 1, 35, 47, 60 }, fee = 22, train = 1, r = { { 2996, 1 }, { 2320, 1 }, { 2324, 1 } }, out = { 2576, 1 }, oq = 1 },
    [2394] = { name = "Blue Linen Shirt", t = { 1, 50, 67, 85 }, fee = 45, train = 25, r = { { 2996, 2 }, { 2320, 1 }, { 6260, 1 } }, out = { 2577, 1 }, oq = 1 },
    [2395] = { name = "Barbaric Linen Vest", t = { 1, 65, 82, 100 }, fee = 270, train = 40, r = { { 2996, 4 }, { 2318, 1 }, { 2321, 1 } }, out = { 2578, 1 }, oq = 2 },
    [2396] = { name = "Green Linen Shirt", t = { 1, 65, 82, 100 }, fee = 180, train = 40, r = { { 2996, 3 }, { 2321, 1 }, { 2605, 1 } }, out = { 2579, 1 }, oq = 1 },
    [2397] = { name = "Reinforced Linen Cape", t = { 1, 60, 77, 95 }, fee = 180, train = 35, r = { { 2996, 2 }, { 2320, 3 } }, out = { 2580, 1 }, oq = 2 },
    [2399] = { name = "Green Woolen Vest", t = { 1, 85, 102, 120 }, fee = 270, train = 60, r = { { 2997, 2 }, { 2321, 2 }, { 2605, 1 } }, out = { 2582, 1 }, oq = 2 },
    [2401] = { name = "Woolen Boots", t = { 1, 95, 112, 130 }, fee = 270, train = 70, r = { { 2997, 4 }, { 2321, 2 }, { 2318, 2 } }, out = { 2583, 1 }, oq = 2 },
    [2402] = { name = "Woolen Cape", t = { 1, 80, 97, 115 }, fee = 225, train = 55, r = { { 2997, 1 }, { 2321, 1 } }, out = { 2584, 1 }, oq = 2 },
    [2403] = { name = "Gray Woolen Robe", t = { 1, 105, 122, 140 }, scroll = 2601, train = 80, sq = 2, r = { { 2997, 4 }, { 2321, 3 }, { 4340, 1 } }, out = { 2585, 1 }, oq = 2 },
    [2406] = { name = "Gray Woolen Shirt", t = { 1, 90, 100, 110 }, fee = 180, train = 80, r = { { 2997, 2 }, { 2321, 1 }, { 4340, 1 } }, out = { 2587, 1 }, oq = 1 },
    [2963] = { name = "Bolt of Linen Cloth", t = { 1, 25, 37, 50 }, basic = true, r = { { 2589, 2 } }, out = { 2996, 1 }, oq = 1 },
    [2964] = { name = "Bolt of Woolen Cloth", t = { 1, 70, 77, 85 }, fee = 90, train = 55, r = { { 2592, 3 } }, out = { 2997, 1 }, oq = 1 },
    [3755] = { name = "Linen Bag", t = { 1, 30, 47, 65 }, basic = true, r = { { 2996, 3 }, { 2320, 3 } }, out = { 4238, 1 }, oq = 1 },
    [3757] = { name = "Woolen Bag", t = { 1, 75, 92, 110 }, fee = 180, train = 50, r = { { 2997, 3 }, { 2321, 1 } }, out = { 4240, 1 }, oq = 1 },
    [3758] = { name = "Green Woolen Bag", t = { 1, 100, 117, 135 }, scroll = 4292, train = 75, sq = 2, r = { { 2997, 4 }, { 2605, 1 }, { 2321, 1 } }, out = { 4241, 1 }, oq = 1 },
    [3813] = { name = "Small Silk Pack", t = { 1, 145, 160, 175 }, fee = 720, train = 125, r = { { 4305, 3 }, { 4234, 2 }, { 2321, 3 } }, out = { 4245, 1 }, oq = 1 },
    [3839] = { name = "Bolt of Silk Cloth", t = { 1, 110, 115, 120 }, fee = 450, train = 100, r = { { 4306, 4 } }, out = { 4305, 1 }, oq = 1 },
    [3840] = { name = "Heavy Linen Gloves", t = { 1, 50, 67, 85 }, fee = 90, train = 25, r = { { 2996, 2 }, { 2320, 1 } }, out = { 4307, 1 }, oq = 2 },
    [3841] = { name = "Green Linen Bracers", t = { 1, 60, 77, 95 }, fee = 180, train = 35, r = { { 2996, 3 }, { 2320, 2 }, { 2605, 1 } }, out = { 4308, 1 }, oq = 2 },
    [3842] = { name = "Handstitched Linen Britches", t = { 1, 70, 87, 105 }, fee = 270, train = 45, r = { { 2996, 4 }, { 2321, 2 } }, out = { 4309, 1 }, oq = 2 },
    [3843] = { name = "Heavy Woolen Gloves", t = { 1, 85, 102, 120 }, fee = 360, train = 60, r = { { 2997, 3 }, { 2321, 1 } }, out = { 4310, 1 }, oq = 2 },
    [3844] = { name = "Heavy Woolen Cloak", t = { 1, 105, 122, 140 }, scroll = 4346, train = 80, sq = 2, r = { { 2997, 3 }, { 2321, 2 }, { 5498, 2 } }, out = { 4311, 1 }, oq = 2 },
    [3845] = { name = "Soft-soled Linen Boots", t = { 1, 80, 97, 115 }, fee = 270, train = 55, r = { { 2996, 5 }, { 2318, 2 }, { 2321, 1 } }, out = { 4312, 1 }, oq = 2 },
    [3847] = { name = "Red Woolen Boots", t = { 1, 80, 97, 115 }, scroll = 4345, train = 75, sq = 2, r = { { 2997, 4 }, { 2318, 2 }, { 2321, 1 }, { 2604, 2 } }, out = { 4313, 1 }, oq = 2 },
    [3848] = { name = "Double-stitched Woolen Shoulders", t = { 1, 110, 127, 145 }, fee = 450, train = 85, r = { { 2997, 3 }, { 2321, 2 } }, out = { 4314, 1 }, oq = 2 },
    [3849] = { name = "Reinforced Woolen Shoulders", t = { 1, 120, 137, 155 }, scroll = 4347, train = 95, sq = 2, r = { { 2997, 6 }, { 2319, 2 }, { 2321, 2 } }, out = { 4315, 1 }, oq = 2 },
    [3850] = { name = "Heavy Woolen Pants", t = { 1, 110, 127, 145 }, fee = 450, train = 85, r = { { 2997, 5 }, { 2321, 4 } }, out = { 4316, 1 }, oq = 2 },
    [3851] = { name = "Phoenix Pants", t = { 1, 125, 142, 160 }, scroll = 4349, train = 100, sq = 2, r = { { 2997, 6 }, { 5500, 1 }, { 2321, 3 } }, out = { 4317, 1 }, oq = 2 },
    [3852] = { name = "Gloves of Meditation", t = { 1, 125, 140, 155 }, fee = 675, train = 105, r = { { 2997, 4 }, { 2321, 3 }, { 3383, 1 } }, out = { 4318, 1 }, oq = 2 },
    [3854] = { name = "Azure Silk Gloves", t = { 1, 140, 155, 170 }, scroll = 7114, train = 120, scrollPrice = 1000, sq = 1, r = { { 4305, 3 }, { 4234, 2 }, { 6260, 2 }, { 2321, 2 } }, out = { 4319, 1 }, oq = 2 },
    [3855] = { name = "Spidersilk Boots", t = { 1, 125, 142, 160 }, fee = 675, train = 100, r = { { 4305, 2 }, { 2319, 4 }, { 3182, 4 }, { 5500, 1 } }, out = { 4320, 1 }, oq = 3 },
    [3856] = { name = "Spider Silk Slippers", t = { 1, 135, 147, 160 }, scroll = 4350, train = 115, sq = 2, r = { { 4305, 3 }, { 3182, 1 }, { 2321, 2 } }, out = { 4321, 1 }, oq = 2 },
    [3857] = { name = "Enchanter's Cowl", t = { 1, 150, 165, 180 }, scroll = 14630, train = 130, scrollPrice = 1000, sq = 1, r = { { 4305, 3 }, { 2321, 2 }, { 4337, 2 } }, out = { 4322, 1 }, oq = 2 },
    [3858] = { name = "Shadow Hood", t = { 1, 155, 170, 185 }, scroll = 4351, train = 135, sq = 2, r = { { 4305, 4 }, { 4291, 1 }, { 3824, 1 } }, out = { 4323, 1 }, oq = 2 },
    [3859] = { name = "Azure Silk Vest", t = { 1, 145, 160, 175 }, fee = 675, train = 125, r = { { 4305, 5 }, { 6260, 4 } }, out = { 4324, 1 }, oq = 2 },
    [3860] = { name = "Boots of the Enchanter", t = { 1, 160, 175, 190 }, scroll = 4352, train = 140, sq = 2, r = { { 4305, 4 }, { 4291, 1 }, { 4337, 2 } }, out = { 4325, 1 }, oq = 2 },
    [3861] = { name = "Long Silken Cloak", t = { 1, 170, 185, 200 }, fee = 900, train = 150, r = { { 4305, 4 }, { 3827, 1 }, { 4291, 1 } }, out = { 4326, 1 }, oq = 2 },
    [3862] = { name = "Icy Cloak", t = { 1, 185, 200, 215 }, scroll = 4355, train = 165, scrollPrice = 1500, sq = 1, r = { { 4339, 3 }, { 4291, 2 }, { 3829, 1 }, { 4337, 2 } }, out = { 4327, 1 }, oq = 3 },
    [3863] = { name = "Spider Belt", t = { 1, 165, 180, 195 }, scroll = 4353, train = 145, sq = 2, r = { { 4305, 4 }, { 4337, 2 }, { 7071, 1 } }, out = { 4328, 1 }, oq = 2 },
    [3864] = { name = "Star Belt", t = { 1, 185, 200, 215 }, scroll = 4356, train = 165, sq = 2, r = { { 4339, 4 }, { 4234, 4 }, { 3864, 1 }, { 7071, 1 }, { 4291, 1 } }, out = { 4329, 1 }, oq = 2 },
    [3865] = { name = "Bolt of Mageweave", t = { 1, 145, 147, 150 }, fee = 900, train = 140, r = { { 4338, 5 } }, out = { 4339, 1 }, oq = 1 },
    [3866] = { name = "Stylish Red Shirt", t = { 1, 110, 127, 145 }, fee = 225, train = 85, r = { { 2997, 3 }, { 2604, 2 }, { 2321, 1 } }, out = { 4330, 1 }, oq = 1 },
    [3868] = { name = "Phoenix Gloves", t = { 1, 125, 142, 160 }, scroll = 4348, train = 100, sq = 2, r = { { 2997, 4 }, { 5500, 1 }, { 2321, 4 }, { 2324, 2 } }, out = { 4331, 1 }, oq = 2 },
    [3869] = { name = "Bright Yellow Shirt", t = { 1, 120, 125, 130 }, scroll = 14627, train = 110, scrollPrice = 800, sq = 1, r = { { 4305, 1 }, { 4341, 1 }, { 2321, 1 } }, out = { 4332, 1 }, oq = 1 },
    [3870] = { name = "Dark Silk Shirt", t = { 1, 130, 135, 140 }, scroll = 6401, train = 120, scrollPrice = 1100, sq = 1, r = { { 4305, 2 }, { 4340, 2 }, { 2321, 1 } }, out = { 4333, 1 }, oq = 1 },
    [3871] = { name = "Formal White Shirt", t = { 1, 145, 150, 155 }, fee = 450, train = 135, r = { { 4305, 3 }, { 2324, 2 }, { 2321, 1 } }, out = { 4334, 1 }, oq = 1 },
    [3872] = { name = "Rich Purple Silk Shirt", t = { 1, 160, 165, 170 }, scroll = 4354, train = 150, sq = 3, r = { { 4305, 4 }, { 4342, 1 }, { 4291, 1 } }, out = { 4335, 1 }, oq = 1 },
    [3873] = { name = "Black Swashbuckler's Shirt", t = { 1, 175, 180, 185 }, scroll = 10728, train = 165, scrollPrice = 1500, sq = 1, r = { { 4305, 5 }, { 2325, 1 }, { 4291, 1 } }, out = { 4336, 1 }, oq = 1 },
    [3914] = { name = "Brown Linen Pants", t = { 1, 50, 67, 85 }, fee = 45, train = 25, r = { { 2996, 2 }, { 2320, 1 } }, out = { 4343, 1 }, oq = 2 },
    [3915] = { name = "Brown Linen Shirt", t = { 1, 35, 47, 60 }, basic = true, r = { { 2996, 1 }, { 2320, 1 } }, out = { 4344, 1 }, oq = 1 },
    [6521] = { name = "Pearl-clasped Cloak", t = { 1, 95, 112, 130 }, fee = 360, train = 70, r = { { 2997, 3 }, { 2321, 2 }, { 5498, 1 } }, out = { 5542, 1 }, oq = 2 },
    [6686] = { name = "Red Linen Bag", t = { 1, 75, 92, 110 }, scroll = 5771, train = 50, scrollPrice = 200, sq = 1, r = { { 2996, 4 }, { 2321, 1 }, { 2604, 1 } }, out = { 5762, 1 }, oq = 1 },
    [6688] = { name = "Red Woolen Bag", t = { 1, 115, 132, 150 }, scroll = 5772, train = 90, scrollPrice = 500, sq = 1, r = { { 2997, 4 }, { 2604, 1 }, { 2321, 1 } }, out = { 5763, 1 }, oq = 1 },
    [6690] = { name = "Lesser Wizard's Robe", t = { 1, 130, 145, 160 }, fee = 900, train = 110, r = { { 4305, 2 }, { 2321, 2 }, { 3182, 2 } }, out = { 5766, 1 }, oq = 2 },
    [6692] = { name = "Robes of Arcana", t = { 1, 145, 160, 175 }, scroll = 5773, train = 125, sq = 2, r = { { 4305, 4 }, { 2321, 2 }, { 3182, 2 } }, out = { 5770, 1 }, oq = 2 },
    [6693] = { name = "Green Silk Pack", t = { 1, 160, 175, 190 }, scroll = 5774, train = 140, sq = 2, r = { { 4305, 4 }, { 4234, 3 }, { 2321, 3 }, { 2605, 1 } }, out = { 5764, 1 }, oq = 1 },
    [6695] = { name = "Black Silk Pack", t = { 1, 170, 185, 200 }, scroll = 5775, train = 150, sq = 2, r = { { 4305, 5 }, { 2325, 1 }, { 2321, 4 } }, out = { 5765, 1 }, oq = 1 },
    [7623] = { name = "Brown Linen Robe", t = { 1, 50, 67, 85 }, fee = 45, train = 25, r = { { 2996, 3 }, { 2320, 1 } }, out = { 6238, 1 }, oq = 2 },
    [7624] = { name = "White Linen Robe", t = { 1, 50, 67, 85 }, fee = 45, train = 25, r = { { 2996, 3 }, { 2320, 1 }, { 2324, 1 } }, out = { 6241, 1 }, oq = 2 },
    [7629] = { name = "Red Linen Vest", t = { 1, 60, 77, 95 }, scroll = 6271, train = 35, sq = 2, r = { { 2996, 3 }, { 2320, 1 }, { 2604, 1 } }, out = { 6239, 1 }, oq = 2 },
    [7630] = { name = "Blue Linen Vest", t = { 1, 60, 77, 95 }, scroll = 6270, train = 35, scrollPrice = 200, sq = 1, r = { { 2996, 3 }, { 2320, 1 }, { 6260, 1 } }, out = { 6240, 1 }, oq = 2 },
    [7633] = { name = "Blue Linen Robe", t = { 1, 70, 87, 105 }, scroll = 6272, train = 45, scrollPrice = 300, sq = 1, r = { { 2996, 4 }, { 2320, 2 }, { 6260, 2 } }, out = { 6242, 1 }, oq = 2 },
    [7636] = { name = "Green Woolen Robe", t = { 1, 90, 107, 125 }, scroll = 6273, train = 80, sq = 1, r = { { 2997, 3 }, { 2321, 2 }, { 2605, 1 } }, out = { 6243, 1 }, oq = 2 },
    [7639] = { name = "Blue Overalls", t = { 1, 100, 117, 135 }, scroll = 6274, train = 75, scrollPrice = 400, sq = 1, r = { { 2997, 4 }, { 2321, 2 }, { 6260, 2 } }, out = { 6263, 1 }, oq = 2 },
    [7643] = { name = "Greater Adept's Robe", t = { 1, 115, 132, 150 }, scroll = 6275, train = 90, scrollPrice = 800, sq = 1, r = { { 2997, 5 }, { 2321, 3 }, { 2604, 3 } }, out = { 6264, 1 }, oq = 2 },
    [7892] = { name = "Stylish Blue Shirt", t = { 1, 120, 137, 155 }, scroll = 6390, train = 95, sq = 2, r = { { 2997, 4 }, { 6260, 2 }, { 4340, 1 }, { 2321, 1 } }, out = { 6384, 1 }, oq = 1 },
    [7893] = { name = "Stylish Green Shirt", t = { 1, 120, 137, 155 }, scroll = 6391, train = 95, sq = 2, r = { { 2997, 4 }, { 2605, 2 }, { 4340, 1 }, { 2321, 1 } }, out = { 6385, 1 }, oq = 1 },
    [8465] = { name = "Simple Dress", t = { 1, 50, 67, 85 }, fee = 45, train = 25, r = { { 2996, 2 }, { 2320, 1 }, { 6260, 1 }, { 2324, 1 } }, out = { 6786, 1 }, oq = 1 },
    [8467] = { name = "White Woolen Dress", t = { 1, 110, 127, 145 }, fee = 225, train = 85, r = { { 2997, 3 }, { 2324, 4 }, { 2321, 1 } }, out = { 6787, 1 }, oq = 2 },
    [8483] = { name = "White Swashbuckler's Shirt", t = { 1, 135, 140, 145 }, fee = 450, train = 125, r = { { 4305, 3 }, { 2324, 2 }, { 4291, 1 } }, out = { 6795, 1 }, oq = 1 },
    [8489] = { name = "Red Swashbuckler's Shirt", t = { 1, 150, 155, 160 }, fee = 675, train = 140, r = { { 4305, 3 }, { 2604, 2 }, { 4291, 1 } }, out = { 6796, 1 }, oq = 1 },
    [8758] = { name = "Azure Silk Pants", t = { 1, 135, 150, 165 }, fee = 540, train = 115, r = { { 4305, 4 }, { 6260, 2 }, { 2321, 3 } }, out = { 7046, 1 }, oq = 2 },
    [8760] = { name = "Azure Silk Hood", t = { 1, 130, 135, 140 }, fee = 540, train = 120, r = { { 4305, 2 }, { 6260, 2 }, { 2321, 1 } }, out = { 7048, 1 }, oq = 2 },
    [8762] = { name = "Silk Headband", t = { 1, 135, 140, 145 }, fee = 675, train = 125, r = { { 4305, 3 }, { 2321, 2 } }, out = { 7050, 1 }, oq = 2 },
    [8764] = { name = "Earthen Vest", t = { 1, 155, 170, 185 }, fee = 810, train = 135, r = { { 4305, 3 }, { 7067, 1 }, { 2321, 2 } }, out = { 7051, 1 }, oq = 2 },
    [8766] = { name = "Azure Silk Belt", t = { 1, 160, 175, 190 }, fee = 900, train = 140, r = { { 4305, 4 }, { 7070, 1 }, { 6260, 2 }, { 2321, 2 }, { 7071, 1 } }, out = { 7052, 1 }, oq = 2 },
    [8770] = { name = "Robe of Power", t = { 1, 175, 190, 205 }, fee = 900, train = 155, r = { { 4339, 2 }, { 7067, 2 }, { 7070, 2 }, { 7068, 2 }, { 7069, 2 }, { 4291, 2 } }, out = { 7054, 1 }, oq = 3, bop = true },
    [8772] = { name = "Crimson Silk Belt", t = { 1, 160, 175, 190 }, fee = 900, train = 140, r = { { 4305, 4 }, { 7071, 1 }, { 2604, 2 }, { 4291, 1 } }, out = { 7055, 1 }, oq = 2 },
    [8774] = { name = "Green Silken Shoulders", t = { 1, 165, 180, 195 }, fee = 900, train = 145, r = { { 4305, 5 }, { 4291, 2 } }, out = { 7057, 1 }, oq = 2 },
    [8776] = { name = "Linen Belt", t = { 1, 50, 67, 85 }, fee = 45, train = 10, r = { { 2996, 1 }, { 2320, 1 } }, out = { 7026, 1 }, oq = 1 },
    [8778] = { name = "Boots of Darkness", t = { 1, 135, 150, 165 }, scroll = 7093, train = 125, sq = 1, r = { { 4305, 3 }, { 2319, 2 }, { 6048, 1 }, { 2321, 2 } }, out = { 7027, 1 }, oq = 2 },
    [8780] = { name = "Hands of Darkness", t = { 1, 140, 155, 170 }, scroll = 7092, train = 120, sq = 2, r = { { 4305, 3 }, { 4234, 2 }, { 6048, 2 }, { 2321, 2 } }, out = { 7047, 1 }, oq = 2 },
    [8782] = { name = "Truefaith Gloves", t = { 1, 145, 160, 175 }, scroll = 7091, train = 125, sq = 2, r = { { 4305, 3 }, { 4234, 2 }, { 929, 4 }, { 2321, 1 } }, out = { 7049, 1 }, oq = 2 },
    [8784] = { name = "Green Silk Armor", t = { 1, 150, 165, 180 }, scroll = 7090, train = 130, sq = 2, r = { { 4305, 5 }, { 2605, 2 }, { 4291, 1 } }, out = { 7065, 1 }, oq = 2 },
    [8786] = { name = "Azure Silk Cloak", t = { 1, 160, 175, 190 }, scroll = 7089, train = 140, scrollPrice = 1500, sq = 1, r = { { 4305, 3 }, { 6260, 2 }, { 2321, 2 } }, out = { 7053, 1 }, oq = 2 },
    [8789] = { name = "Crimson Silk Cloak", t = { 1, 165, 180, 195 }, scroll = 7087, train = 145, scrollPrice = 1200, sq = 1, r = { { 4305, 5 }, { 2604, 2 }, { 6371, 2 }, { 4291, 1 } }, out = { 7056, 1 }, oq = 2 },
    [8791] = { name = "Crimson Silk Vest", t = { 1, 170, 180, 190 }, fee = 2250, train = 150, r = { { 4305, 4 }, { 2604, 2 }, { 2321, 2 } }, out = { 7058, 1 }, oq = 2 },
    [8793] = { name = "Crimson Silk Shoulders", t = { 1, 175, 190, 205 }, scroll = 7084, train = 155, sq = 2, r = { { 4305, 5 }, { 6371, 2 }, { 2604, 2 }, { 4291, 2 } }, out = { 7059, 1 }, oq = 2 },
    [8795] = { name = "Azure Shoulders", t = { 1, 175, 190, 205 }, scroll = 7085, train = 155, sq = 2, r = { { 4305, 6 }, { 7072, 2 }, { 6260, 2 }, { 4291, 2 } }, out = { 7060, 1 }, oq = 2 },
    [8797] = { name = "Earthen Silk Belt", t = { 1, 180, 195, 210 }, scroll = 7086, train = 160, sq = 2, r = { { 4305, 5 }, { 7067, 4 }, { 4234, 4 }, { 7071, 1 }, { 4291, 2 } }, out = { 7061, 1 }, oq = 2 },
    [8799] = { name = "Crimson Silk Pantaloons", t = { 1, 180, 190, 200 }, fee = 2700, train = 160, r = { { 4305, 4 }, { 2604, 2 }, { 4291, 2 } }, out = { 7062, 1 }, oq = 2 },
    [8802] = { name = "Crimson Silk Robe", t = { 1, 185, 200, 215 }, scroll = 7088, train = 170, scrollPrice = 5000, sq = 1, r = { { 4305, 8 }, { 7068, 4 }, { 3827, 2 }, { 2604, 4 }, { 4291, 1 } }, out = { 7063, 1 }, oq = 2 },
    [8804] = { name = "Crimson Silk Gloves", t = { 1, 190, 205, 220 }, fee = 4500, train = 175, r = { { 4305, 6 }, { 7068, 2 }, { 6371, 2 }, { 4304, 2 }, { 2604, 4 }, { 4291, 2 } }, out = { 7064, 1 }, oq = 2 },
    [12044] = { name = "Simple Linen Pants", t = { 1, 40, 50, 60 }, basic = true, r = { { 2996, 1 }, { 2320, 1 } }, out = { 10045, 1 }, oq = 1 },
    [12045] = { name = "Simple Linen Boots", t = { 1, 50, 67, 85 }, fee = 45, train = 20, r = { { 2996, 2 }, { 2318, 1 }, { 2320, 1 } }, out = { 10046, 1 }, oq = 1 },
    [12046] = { name = "Simple Kilt", t = { 1, 75, 92, 110 }, fee = 270, train = 50, r = { { 2996, 4 }, { 2321, 1 } }, out = { 10047, 1 }, oq = 2 },
    [12047] = { name = "Colorful Kilt", t = { 1, 95, 112, 130 }, scroll = 10316, train = 70, sq = 2, r = { { 2997, 5 }, { 2604, 3 }, { 2321, 1 } }, out = { 10048, 1 }, oq = 2 },
    [12048] = { name = "Black Mageweave Vest", t = { 1, 185, 200, 215 }, fee = 3600, train = 170, r = { { 4339, 2 }, { 4291, 3 } }, out = { 9998, 1 }, oq = 2 },
    [12049] = { name = "Black Mageweave Leggings", t = { 1, 185, 200, 215 }, fee = 3600, train = 170, r = { { 4339, 2 }, { 4291, 3 } }, out = { 9999, 1 }, oq = 2 },
    [12050] = { name = "Black Mageweave Robe", t = { 1, 190, 205, 220 }, fee = 3600, train = 175, r = { { 4339, 3 }, { 8343, 1 } }, out = { 10001, 1 }, oq = 2 },
    [12052] = { name = "Shadoweave Pants", t = { 1, 190, 205, 220 }, fee = 4500, train = 175, r = { { 4339, 3 }, { 10285, 2 }, { 8343, 1 } }, out = { 10002, 1 }, oq = 2 },
    [12053] = { name = "Black Mageweave Gloves", t = { 1, 195, 210, 225 }, fee = 4500, train = 180, r = { { 4339, 2 }, { 8343, 2 } }, out = { 10003, 1 }, oq = 2 },
    [12055] = { name = "Shadoweave Robe", t = { 1, 195, 210, 225 }, fee = 4950, train = 180, r = { { 4339, 3 }, { 10285, 2 }, { 8343, 1 } }, out = { 10004, 1 }, oq = 2 },
    [12056] = { name = "Red Mageweave Vest", t = { 1, 195, 210, 225 }, scroll = 10300, train = 180, sq = 2, r = { { 4339, 3 }, { 2604, 2 }, { 8343, 1 } }, out = { 10007, 1 }, oq = 2 },
    [12059] = { name = "White Bandit Mask", t = { 1, 185, 190, 195 }, scroll = 10301, train = 180, sq = 2, r = { { 4339, 1 }, { 2324, 1 }, { 8343, 1 } }, out = { 10008, 1 }, oq = 2 },
    [12060] = { name = "Red Mageweave Pants", t = { 1, 195, 210, 225 }, scroll = 10302, train = 180, sq = 2, r = { { 4339, 3 }, { 2604, 2 }, { 8343, 1 } }, out = { 10009, 1 }, oq = 2 },
    [12061] = { name = "Orange Mageweave Shirt", t = { 1, 185, 190, 195 }, fee = 2250, train = 180, r = { { 4339, 1 }, { 6261, 1 }, { 8343, 1 } }, out = { 10056, 1 }, oq = 1 },
    [12062] = { name = "Stormcloth Pants", t = { 1, 200, 215, 230 }, scroll = 254681, train = 185, sq = 2, r = { { 4339, 4 }, { 7079, 2 }, { 8343, 2 } }, out = { 10010, 1 }, oq = 2 },
    [12063] = { name = "Stormcloth Gloves", t = { 1, 200, 215, 230 }, scroll = 254682, train = 185, scrollPrice = 6875, sq = 2, r = { { 4339, 3 }, { 7079, 2 }, { 8343, 2 } }, out = { 10011, 1 }, oq = 2 },
    [12064] = { name = "Orange Martial Shirt", t = { 1, 190, 195, 200 }, scroll = 10311, train = 185, scrollPrice = 3000, sq = 1, r = { { 4339, 2 }, { 6261, 2 }, { 8343, 1 } }, out = { 10052, 1 }, oq = 1 },
    [12065] = { name = "Mageweave Bag", t = { 1, 205, 220, 235 }, fee = 4500, train = 190, r = { { 4339, 4 }, { 4291, 2 } }, out = { 10050, 1 }, oq = 1 },
    [12066] = { name = "Red Mageweave Gloves", t = { 1, 205, 220, 235 }, scroll = 10312, train = 190, sq = 2, r = { { 4339, 3 }, { 2604, 2 }, { 8343, 2 } }, out = { 10018, 1 }, oq = 2 },
    [12067] = { name = "Dreamweave Gloves", t = { 1, 205, 220, 235 }, fee = 4500, train = 190, r = { { 4339, 4 }, { 8153, 4 }, { 10286, 2 }, { 8343, 2 } }, out = { 10019, 1 }, oq = 3 },
    [12068] = { name = "Stormcloth Vest", t = { 1, 205, 220, 235 }, scroll = 254683, train = 190, sq = 2, r = { { 4339, 5 }, { 7079, 3 }, { 8343, 2 } }, out = { 10020, 1 }, oq = 2 },
    [12069] = { name = "Cindercloth Robe", t = { 1, 205, 220, 235 }, fee = 4500, train = 190, r = { { 4339, 5 }, { 7077, 2 }, { 8343, 2 } }, out = { 10042, 1 }, oq = 2 },
    [12070] = { name = "Dreamweave Vest", t = { 1, 205, 220, 235 }, fee = 4500, train = 190, r = { { 4339, 6 }, { 8153, 6 }, { 10286, 2 }, { 8343, 2 } }, out = { 10021, 1 }, oq = 3 },
    [12071] = { name = "Shadoweave Gloves", t = { 1, 205, 220, 235 }, fee = 5400, train = 190, r = { { 4339, 5 }, { 10285, 5 }, { 8343, 2 } }, out = { 10023, 1 }, oq = 2 },
    [12072] = { name = "Black Mageweave Headband", t = { 1, 205, 220, 235 }, fee = 6000, train = 190, r = { { 4339, 3 }, { 8343, 2 } }, out = { 10024, 1 }, oq = 2 },
    [12073] = { name = "Black Mageweave Boots", t = { 1, 205, 220, 235 }, fee = 5400, train = 190, r = { { 4339, 3 }, { 8343, 2 }, { 4304, 2 } }, out = { 10026, 1 }, oq = 2 },
    [12074] = { name = "Black Mageweave Shoulders", t = { 1, 205, 220, 235 }, fee = 2400, train = 190, r = { { 4339, 3 }, { 8343, 2 } }, out = { 10027, 1 }, oq = 2 },
    [12075] = { name = "Lavender Mageweave Shirt", t = { 1, 195, 200, 205 }, scroll = 10314, train = 190, scrollPrice = 4000, sq = 1, r = { { 4339, 2 }, { 4342, 2 }, { 8343, 2 } }, out = { 10054, 1 }, oq = 1 },
    [12076] = { name = "Shadoweave Shoulders", t = { 1, 210, 225, 240 }, fee = 5850, train = 195, r = { { 4339, 5 }, { 10285, 4 }, { 8343, 2 } }, out = { 10028, 1 }, oq = 2 },
    [12077] = { name = "Simple Black Dress", t = { 1, 200, 205, 210 }, fee = 4500, train = 195, r = { { 4339, 3 }, { 2325, 1 }, { 8343, 1 }, { 2324, 1 } }, out = { 10053, 1 }, oq = 1 },
    [12078] = { name = "Red Mageweave Shoulders", t = { 1, 210, 225, 240 }, scroll = 10315, train = 195, sq = 2, r = { { 4339, 4 }, { 2604, 2 }, { 8343, 3 } }, out = { 10029, 1 }, oq = 2 },
    [12079] = { name = "Red Mageweave Bag", t = { 1, 210, 225, 240 }, fee = 5850, train = 195, r = { { 4339, 4 }, { 2604, 2 }, { 8343, 2 } }, out = { 10051, 1 }, oq = 1 },
    [12080] = { name = "Pink Mageweave Shirt", t = { 1, 200, 205, 210 }, scroll = 10317, train = 195, scrollPrice = 4000, sq = 1, r = { { 4339, 3 }, { 10290, 1 }, { 8343, 1 } }, out = { 10055, 1 }, oq = 1 },
    [12081] = { name = "Admiral's Hat", t = { 1, 215, 230, 245 }, scroll = 10318, train = 200, scrollPrice = 7000, sq = 1, r = { { 4339, 3 }, { 4589, 6 }, { 8343, 2 } }, out = { 10030, 1 }, oq = 2 },
    [12082] = { name = "Shadoweave Boots", t = { 1, 215, 230, 245 }, fee = 6300, train = 200, r = { { 4339, 6 }, { 10285, 6 }, { 8343, 3 }, { 4304, 2 } }, out = { 10031, 1 }, oq = 2 },
    [12083] = { name = "Stormcloth Headband", t = { 1, 215, 230, 245 }, scroll = 254684, train = 200, sq = 2, r = { { 4339, 4 }, { 7079, 4 }, { 8343, 2 } }, out = { 10032, 1 }, oq = 2 },
    [12084] = { name = "Red Mageweave Headband", t = { 1, 215, 230, 245 }, scroll = 10320, train = 200, sq = 2, r = { { 4339, 4 }, { 2604, 2 }, { 8343, 2 } }, out = { 10033, 1 }, oq = 2 },
    [12085] = { name = "Tuxedo Shirt", t = { 1, 205, 210, 215 }, scroll = 10321, train = 200, scrollPrice = 4500, sq = 1, r = { { 4339, 4 }, { 8343, 2 } }, out = { 10034, 1 }, oq = 1 },
    [12086] = { name = "Shadoweave Mask", t = { 1, 215, 230, 245 }, scroll = 10463, train = 200, sq = 2, r = { { 4339, 2 }, { 10285, 8 }, { 8343, 2 } }, out = { 10025, 1 }, oq = 2 },
    [12087] = { name = "Stormcloth Shoulders", t = { 1, 215, 230, 245 }, scroll = 254685, train = 200, sq = 2, r = { { 4339, 5 }, { 7079, 6 }, { 8343, 3 } }, out = { 10038, 1 }, oq = 2 },
    [12088] = { name = "Cindercloth Boots", t = { 1, 215, 230, 245 }, fee = 6750, train = 200, r = { { 4339, 5 }, { 7077, 1 }, { 8343, 3 }, { 4304, 2 } }, out = { 10044, 1 }, oq = 2 },
    [12089] = { name = "Tuxedo Pants", t = { 1, 205, 210, 215 }, scroll = 10323, train = 140, scrollPrice = 4500, sq = 1, r = { { 4339, 4 }, { 8343, 3 } }, out = { 10035, 1 }, oq = 1 },
    [12090] = { name = "Stormcloth Boots", t = { 1, 220, 235, 250 }, scroll = 254686, train = 205, sq = 2, r = { { 4339, 6 }, { 7079, 6 }, { 8343, 3 }, { 4304, 2 } }, out = { 10039, 1 }, oq = 2 },
    [12091] = { name = "White Wedding Dress", t = { 1, 145, 150, 155 }, scroll = 10325, train = 140, scrollPrice = 10000, sq = 1, r = { { 4339, 5 }, { 8343, 3 }, { 2324, 1 } }, out = { 10040, 1 }, oq = 1 },
    [12092] = { name = "Dreamweave Circlet", t = { 1, 220, 235, 250 }, fee = 6750, train = 205, r = { { 4339, 8 }, { 8153, 4 }, { 10286, 2 }, { 8343, 3 }, { 6037, 1 }, { 1529, 1 } }, out = { 10041, 1 }, oq = 3 },
    [12093] = { name = "Tuxedo Jacket", t = { 1, 155, 170, 185 }, scroll = 10326, train = 140, scrollPrice = 5000, sq = 1, r = { { 4339, 5 }, { 8343, 3 } }, out = { 10036, 1 }, oq = 1 },
    [18401] = { name = "Bolt of Runecloth", t = { 1, 210, 212, 215 }, fee = 10000, train = 205, r = { { 14047, 5 } }, out = { 14048, 1 }, oq = 1 },
    [18402] = { name = "Runecloth Belt", t = { 1, 225, 240, 255 }, fee = 10000, train = 210, r = { { 14048, 3 }, { 14341, 1 } }, out = { 13856, 1 }, oq = 2 },
    [18403] = { name = "Frostweave Tunic", t = { 1, 225, 240, 255 }, scroll = 14466, train = 210, sq = 2, r = { { 14048, 5 }, { 7079, 2 }, { 14341, 1 } }, out = { 13869, 1 }, oq = 2 },
    [18404] = { name = "Frostweave Robe", t = { 1, 225, 240, 255 }, scroll = 14467, train = 210, sq = 2, r = { { 14048, 5 }, { 7079, 2 }, { 14341, 1 } }, out = { 13868, 1 }, oq = 2 },
    [18405] = { name = "Runecloth Bag", t = { 1, 230, 245, 260 }, scroll = 14468, train = 215, scrollPrice = 12000, sq = 1, r = { { 14048, 5 }, { 8170, 2 }, { 14341, 1 }, { 249430, 4 }, { 249409, 2 } }, out = { 14046, 1 }, oq = 1 },
    [18406] = { name = "Runecloth Robe", t = { 1, 230, 245, 260 }, scroll = 14469, train = 215, scrollPrice = 12000, sq = 1, r = { { 14048, 5 }, { 14227, 1 }, { 14341, 1 } }, out = { 13858, 1 }, oq = 2 },
    [18407] = { name = "Runecloth Tunic", t = { 1, 230, 245, 260 }, scroll = 14470, train = 215, sq = 2, r = { { 14048, 5 }, { 14227, 1 }, { 14341, 1 } }, out = { 13857, 1 }, oq = 2 },
    [18408] = { name = "Cindercloth Vest", t = { 1, 230, 245, 260 }, scroll = 14471, train = 215, sq = 2, r = { { 14048, 5 }, { 7077, 3 }, { 14341, 1 } }, out = { 14042, 1 }, oq = 2 },
    [18409] = { name = "Runecloth Cloak", t = { 1, 240, 255, 270 }, scroll = 14472, train = 220, scrollPrice = 12000, sq = 1, r = { { 14048, 4 }, { 14227, 1 }, { 14341, 1 } }, out = { 13860, 1 }, oq = 2 },
    [18410] = { name = "Ghostweave Belt", t = { 1, 235, 250, 265 }, scroll = 14473, train = 220, sq = 2, r = { { 14048, 3 }, { 9210, 2 }, { 14227, 1 }, { 14341, 1 } }, out = { 14143, 1 }, oq = 2 },
    [18411] = { name = "Frostweave Gloves", t = { 1, 230, 245, 260 }, scroll = 14474, train = 215, sq = 2, r = { { 14048, 3 }, { 7080, 1 }, { 14341, 1 } }, out = { 13870, 1 }, oq = 2 },
    [18412] = { name = "Cindercloth Gloves", t = { 1, 240, 255, 270 }, scroll = 14476, train = 225, sq = 2, r = { { 14048, 4 }, { 7077, 3 }, { 14341, 1 } }, out = { 14043, 1 }, oq = 2 },
    [18413] = { name = "Ghostweave Gloves", t = { 1, 240, 255, 270 }, scroll = 14477, train = 225, sq = 2, r = { { 14048, 4 }, { 9210, 2 }, { 14227, 1 }, { 14341, 1 } }, out = { 14142, 1 }, oq = 2 },
    [18414] = { name = "Brightcloth Robe", t = { 1, 240, 255, 270 }, scroll = 14478, train = 225, sq = 2, r = { { 14048, 5 }, { 3577, 2 }, { 14341, 1 } }, out = { 14100, 1 }, oq = 2 },
    [18415] = { name = "Brightcloth Gloves", t = { 1, 240, 255, 270 }, scroll = 14479, train = 225, sq = 2, r = { { 14048, 4 }, { 3577, 2 }, { 14341, 1 } }, out = { 14101, 1 }, oq = 2 },
    [18416] = { name = "Ghostweave Vest", t = { 1, 240, 255, 270 }, scroll = 14480, train = 225, sq = 2, r = { { 14048, 6 }, { 9210, 4 }, { 14227, 1 }, { 14341, 1 } }, out = { 14141, 1 }, oq = 2 },
    [18417] = { name = "Runecloth Gloves", t = { 1, 245, 260, 275 }, scroll = 14481, train = 230, scrollPrice = 16000, sq = 1, r = { { 14048, 4 }, { 8170, 4 }, { 14341, 1 } }, out = { 13863, 1 }, oq = 2 },
    [18418] = { name = "Cindercloth Cloak", t = { 1, 245, 260, 275 }, scroll = 14482, train = 230, sq = 2, r = { { 14048, 5 }, { 7078, 1 }, { 14341, 1 } }, out = { 14044, 1 }, oq = 2 },
    [18419] = { name = "Felcloth Pants", t = { 1, 245, 260, 275 }, scroll = 14483, train = 230, scrollPrice = 16000, sq = 1, r = { { 14048, 5 }, { 14256, 4 }, { 14341, 1 } }, out = { 14107, 1 }, oq = 2 },
    [18420] = { name = "Brightcloth Cloak", t = { 1, 245, 260, 275 }, scroll = 14484, train = 230, sq = 2, r = { { 14048, 4 }, { 3577, 2 }, { 14341, 1 } }, out = { 14103, 1 }, oq = 2 },
    [18421] = { name = "Wizardweave Leggings", t = { 1, 245, 260, 275 }, scroll = 14485, train = 230, sq = 2, r = { { 14048, 6 }, { 11176, 1 }, { 14341, 1 } }, out = { 14132, 1 }, oq = 2 },
    [18422] = { name = "Cloak of Fire", t = { 1, 250, 265, 280 }, scroll = 14486, train = 235, sq = 3, r = { { 14048, 6 }, { 7078, 4 }, { 7077, 4 }, { 7068, 4 }, { 14341, 1 } }, out = { 14134, 1 }, oq = 3 },
    [18423] = { name = "Runecloth Boots", t = { 1, 250, 265, 280 }, scroll = 14488, train = 235, scrollPrice = 20000, sq = 1, r = { { 14048, 4 }, { 14227, 2 }, { 8170, 4 }, { 14341, 1 } }, out = { 13864, 1 }, oq = 2 },
    [18424] = { name = "Frostweave Pants", t = { 1, 250, 265, 280 }, scroll = 14489, train = 235, sq = 2, r = { { 14048, 6 }, { 7080, 1 }, { 14341, 1 } }, out = { 13871, 1 }, oq = 2 },
    [18434] = { name = "Cindercloth Pants", t = { 1, 250, 265, 280 }, scroll = 14490, train = 235, sq = 2, r = { { 14048, 6 }, { 7078, 1 }, { 14341, 1 } }, out = { 14045, 1 }, oq = 2 },
    [18436] = { name = "Robe of Winter Night", t = { 1, 260, 275, 290 }, scroll = 14493, train = 245, sq = 3, r = { { 14048, 10 }, { 14256, 12 }, { 12808, 4 }, { 7080, 4 }, { 14341, 1 } }, out = { 14136, 1 }, oq = 3 },
    [18437] = { name = "Felcloth Boots", t = { 1, 255, 270, 285 }, scroll = 14492, train = 240, sq = 2, r = { { 14048, 6 }, { 14256, 4 }, { 8170, 4 }, { 14341, 1 } }, out = { 14108, 1 }, oq = 2 },
    [18438] = { name = "Runecloth Pants", t = { 1, 255, 270, 285 }, scroll = 14491, train = 240, sq = 2, r = { { 14048, 6 }, { 14227, 2 }, { 14341, 1 } }, out = { 13865, 1 }, oq = 2 },
    [18439] = { name = "Brightcloth Pants", t = { 1, 260, 275, 290 }, scroll = 14494, train = 245, sq = 2, r = { { 14048, 6 }, { 3577, 4 }, { 14227, 1 }, { 14341, 1 } }, out = { 14104, 1 }, oq = 2 },
    [18440] = { name = "Mooncloth Leggings", t = { 1, 270, 285, 300 }, scroll = 14497, train = 245, sq = 3, r = { { 14048, 6 }, { 14342, 4 }, { 14341, 1 } }, out = { 14137, 1 }, oq = 3 },
    [18441] = { name = "Ghostweave Pants", t = { 1, 260, 275, 290 }, scroll = 14495, train = 245, sq = 2, r = { { 14048, 6 }, { 9210, 4 }, { 14341, 1 } }, out = { 14144, 1 }, oq = 2 },
    [18442] = { name = "Felcloth Hood", t = { 1, 260, 275, 290 }, scroll = 14496, train = 245, sq = 2, r = { { 14048, 5 }, { 14256, 4 }, { 14341, 1 } }, out = { 14111, 1 }, oq = 2 },
    [18444] = { name = "Runecloth Headband", t = { 1, 265, 280, 295 }, scroll = 14498, train = 250, sq = 2, r = { { 14048, 4 }, { 14227, 2 }, { 14341, 1 } }, out = { 13866, 1 }, oq = 2 },
    [18445] = { name = "Mooncloth Bag", t = { 1, 270, 285, 300 }, scroll = 14499, train = 255, sq = 2, r = { { 14048, 4 }, { 14342, 1 }, { 14341, 1 }, { 249431, 10 }, { 249430, 2 }, { 249409, 4 } }, out = { 14155, 1 }, oq = 2 },
    [18446] = { name = "Wizardweave Robe", t = { 1, 270, 285, 300 }, scroll = 14500, train = 255, sq = 2, r = { { 14048, 8 }, { 11176, 2 }, { 14341, 1 } }, out = { 14128, 1 }, oq = 2 },
    [18447] = { name = "Mooncloth Vest", t = { 1, 285, 300, 315 }, scroll = 14501, train = 270, sq = 3, r = { { 14048, 6 }, { 14342, 4 }, { 14341, 1 } }, out = { 14138, 1 }, oq = 3 },
    [18448] = { name = "Mooncloth Shoulders", t = { 1, 290, 305, 320 }, scroll = 14507, train = 275, sq = 3, r = { { 14048, 5 }, { 14342, 5 }, { 14341, 1 } }, out = { 14139, 1 }, oq = 3 },
    [18449] = { name = "Runecloth Shoulders", t = { 1, 275, 290, 305 }, scroll = 14504, train = 260, sq = 2, r = { { 14048, 7 }, { 14227, 2 }, { 8170, 4 }, { 14341, 1 } }, out = { 13867, 1 }, oq = 2 },
    [18450] = { name = "Wizardweave Turban", t = { 1, 275, 290, 305 }, scroll = 14505, train = 260, sq = 2, r = { { 14048, 6 }, { 11176, 4 }, { 7910, 1 }, { 14341, 1 } }, out = { 14130, 1 }, oq = 2 },
    [18451] = { name = "Felcloth Robe", t = { 1, 275, 290, 305 }, scroll = 14506, train = 260, sq = 2, r = { { 14048, 8 }, { 14256, 8 }, { 12662, 4 }, { 14341, 2 } }, out = { 14106, 1 }, oq = 2 },
    [18452] = { name = "Mooncloth Circlet", t = { 1, 295, 310, 325 }, scroll = 14509, train = 280, sq = 3, r = { { 14048, 4 }, { 14342, 6 }, { 12800, 1 }, { 12810, 2 }, { 14341, 2 } }, out = { 14140, 1 }, oq = 3 },
    [18453] = { name = "Felcloth Shoulders", t = { 1, 280, 295, 310 }, scroll = 14508, train = 265, sq = 2, r = { { 14048, 7 }, { 14256, 6 }, { 12662, 4 }, { 8170, 4 }, { 14341, 2 } }, out = { 14112, 1 }, oq = 2 },
    [18454] = { name = "Gloves of Spell Mastery", t = { 1, 310, 325, 340 }, scroll = 14511, train = 295, sq = 4, r = { { 14048, 10 }, { 14342, 8 }, { 9210, 8 }, { 13926, 4 }, { 12364, 4 }, { 12810, 6 }, { 14341, 2 }, { 249431, 10 } }, out = { 14146, 1 }, oq = 4 },
    [18455] = { name = "Bottomless Bag", t = { 1, 315, 330, 345 }, scroll = 14510, train = 300, sq = 3, r = { { 14048, 8 }, { 14342, 12 }, { 14344, 2 }, { 249429, 5 }, { 249428, 5 }, { 249431, 8 }, { 14341, 2 } }, out = { 14156, 1 }, oq = 3 },
    [18456] = { name = "Truefaith Vestments", t = { 1, 310, 325, 340 }, scroll = 14512, train = 295, sq = 4, r = { { 14048, 12 }, { 14342, 8 }, { 12811, 2 }, { 13926, 2 }, { 9210, 8 }, { 14341, 2 }, { 249431, 10 } }, out = { 14154, 1 }, oq = 4, bop = true },
    [18457] = { name = "Robe of the Archmage", t = { 1, 310, 325, 340 }, scroll = 14513, train = 295, sq = 4, r = { { 14048, 12 }, { 7078, 8 }, { 7082, 8 }, { 7076, 8 }, { 7080, 8 }, { 14341, 2 }, { 249431, 10 } }, out = { 14152, 1 }, oq = 4, bop = true },
    [18458] = { name = "Robe of the Void", t = { 1, 310, 325, 340 }, scroll = 14514, train = 295, sq = 4, r = { { 14048, 12 }, { 12662, 20 }, { 14256, 40 }, { 7078, 8 }, { 12808, 8 }, { 14341, 2 }, { 249431, 10 } }, out = { 14153, 1 }, oq = 4, bop = true },
    [18560] = { name = "Mooncloth", t = { 1, 270, 285, 300 }, scroll = 14526, train = 230, scrollPrice = 20000, sq = 1, r = { { 14256, 2 } }, out = { 14342, 1 }, oq = 1 },
    [19435] = { name = "Mooncloth Boots", t = { 1, 285, 300, 315 }, r = { { 14048, 6 }, { 14342, 4 }, { 7971, 2 }, { 14341, 1 } }, out = { 15802, 1 }, oq = 3 },
    [20848] = { name = "Flarecore Mantle", t = { 1, 315, 330, 345 }, scroll = 17017, train = 300, scrollPrice = 180000, rep = { 59, 5 }, sq = 1, r = { { 14048, 12 }, { 17010, 4 }, { 17011, 4 }, { 12810, 6 }, { 14341, 2 } }, out = { 16980, 1 }, oq = 4 },
    [20849] = { name = "Flarecore Gloves", t = { 1, 315, 330, 345 }, scroll = 17018, train = 300, scrollPrice = 80000, rep = { 59, 4 }, sq = 1, r = { { 14048, 8 }, { 17010, 6 }, { 7078, 4 }, { 12810, 2 }, { 14341, 2 } }, out = { 16979, 1 }, oq = 4 },
    [21945] = { name = "Green Holiday Shirt", t = { 1, 165, 170, 175 }, scroll = 17724, train = 155, sq = 1, r = { { 4305, 5 }, { 2605, 4 }, { 4291, 1 } }, out = { 17723, 1 }, oq = 1 },
    [22759] = { name = "Flarecore Wraps", t = { 1, 320, 335, 350 }, scroll = 18265, train = 300, sq = 3, r = { { 14342, 6 }, { 17010, 8 }, { 7078, 2 }, { 12810, 6 }, { 14341, 4 } }, out = { 18263, 1 }, oq = 4 },
    [22813] = { name = "Gordok Ogre Suit", t = { 1, 285, 290, 295 }, r = { { 14048, 2 }, { 8170, 4 }, { 18240, 1 }, { 14341, 1 } }, out = { 18258, 1 }, oq = 2 },
    [22866] = { name = "Belt of the Archmage", t = { 1, 310, 325, 340 }, scroll = 18414, train = 295, sq = 4, r = { { 14048, 16 }, { 9210, 8 }, { 14342, 8 }, { 7080, 10 }, { 7078, 10 }, { 14344, 4 }, { 14341, 6 }, { 249431, 10 } }, out = { 18405, 1 }, oq = 4 },
    [22867] = { name = "Felcloth Gloves", t = { 1, 295, 310, 325 }, scroll = 18415, train = 280, sq = 3, r = { { 14048, 12 }, { 14256, 20 }, { 12662, 6 }, { 12808, 8 }, { 14341, 2 } }, out = { 18407, 1 }, oq = 3 },
    [22868] = { name = "Inferno Gloves", t = { 1, 295, 310, 325 }, scroll = 18416, train = 280, sq = 3, r = { { 14048, 12 }, { 7078, 10 }, { 7910, 2 }, { 14341, 2 } }, out = { 18408, 1 }, oq = 3 },
    [22869] = { name = "Mooncloth Gloves", t = { 1, 295, 310, 325 }, scroll = 18417, train = 280, sq = 3, r = { { 14048, 12 }, { 14342, 6 }, { 13926, 2 }, { 14341, 2 } }, out = { 18409, 1 }, oq = 3 },
    [22870] = { name = "Cloak of Warding", t = { 1, 295, 310, 325 }, scroll = 18418, train = 280, sq = 3, r = { { 14048, 12 }, { 12809, 4 }, { 12360, 1 }, { 14341, 2 } }, out = { 18413, 1 }, oq = 3 },
    [22902] = { name = "Mooncloth Robe", t = { 1, 290, 305, 320 }, scroll = 18487, train = 275, scrollPrice = 40000, sq = 1, r = { { 14048, 6 }, { 14342, 4 }, { 13926, 2 }, { 14341, 2 } }, out = { 18486, 1 }, oq = 3 },
    [23662] = { name = "Wisdom of the Timbermaw", t = { 1, 270, 285, 300 }, scroll = 19215, train = 255, scrollPrice = 22000, rep = { 576, 5 }, sq = 1, r = { { 14048, 8 }, { 7076, 3 }, { 12803, 3 }, { 14227, 2 } }, out = { 19047, 1 }, oq = 3 },
    [23663] = { name = "Mantle of the Timbermaw", t = { 1, 305, 319, 334 }, scroll = 19218, train = 290, scrollPrice = 40000, rep = { 576, 6 }, sq = 3, r = { { 14342, 5 }, { 7076, 5 }, { 12803, 5 }, { 14227, 2 } }, out = { 19050, 1 }, oq = 3 },
    [23664] = { name = "Argent Boots", t = { 1, 270, 285, 300 }, scroll = 227896, train = 290, rep = { 529, 5 }, sq = 1, r = { { 14048, 6 }, { 12810, 4 }, { 13926, 2 }, { 12809, 2 }, { 14227, 2 } }, out = { 19056, 1 }, oq = 3 },
    [23665] = { name = "Argent Shoulders", t = { 1, 305, 320, 335 }, scroll = 227897, train = 300, rep = { 529, 6 }, sq = 1, r = { { 14342, 5 }, { 12809, 2 }, { 14227, 2 } }, out = { 19059, 1 }, oq = 3 },
    [23666] = { name = "Flarecore Robe", t = { 1, 315, 330, 345 }, scroll = 19219, train = 300, scrollPrice = 60000, rep = { 59, 5 }, sq = 1, r = { { 14342, 10 }, { 17010, 2 }, { 17011, 3 }, { 7078, 6 }, { 14227, 4 } }, out = { 19156, 1 }, oq = 4 },
    [23667] = { name = "Flarecore Leggings", t = { 1, 315, 330, 345 }, scroll = 19220, train = 300, scrollPrice = 90000, rep = { 59, 6 }, sq = 1, r = { { 14342, 8 }, { 17010, 5 }, { 17011, 3 }, { 7078, 10 }, { 14227, 4 } }, out = { 19165, 1 }, oq = 4 },
    [24091] = { name = "Bloodvine Vest", t = { 1, 315, 330, 345 }, scroll = 19764, train = 300, scrollPrice = 50000, rep = { 270, 6 }, sq = 1, r = { { 14342, 3 }, { 19726, 5 }, { 12804, 4 }, { 14048, 4 }, { 14227, 2 } }, out = { 19682, 1 }, oq = 3 },
    [24092] = { name = "Bloodvine Leggings", t = { 1, 315, 330, 345 }, scroll = 19765, train = 300, scrollPrice = 50000, rep = { 270, 5 }, sq = 1, r = { { 14342, 4 }, { 19726, 4 }, { 12804, 4 }, { 14048, 4 }, { 14227, 2 } }, out = { 19683, 1 }, oq = 3 },
    [24093] = { name = "Bloodvine Boots", t = { 1, 315, 330, 345 }, scroll = 19766, train = 300, scrollPrice = 50000, rep = { 270, 4 }, sq = 1, r = { { 14342, 3 }, { 19726, 3 }, { 12810, 4 }, { 14048, 4 }, { 14227, 4 } }, out = { 19684, 1 }, oq = 3 },
    [24901] = { name = "Runed Stygian Leggings", t = { 1, 300, 315, 330 }, scroll = 20546, train = 285, sq = 3, r = { { 14048, 6 }, { 20520, 8 }, { 14256, 6 }, { 14227, 2 } }, out = { 20538, 1 }, oq = 3 },
    [24902] = { name = "Runed Stygian Belt", t = { 1, 300, 315, 330 }, scroll = 20548, train = 285, sq = 3, r = { { 14048, 2 }, { 20520, 6 }, { 14256, 2 }, { 12810, 2 }, { 14227, 2 } }, out = { 20539, 1 }, oq = 3 },
    [24903] = { name = "Runed Stygian Boots", t = { 1, 300, 315, 330 }, scroll = 20547, train = 285, sq = 3, r = { { 14048, 4 }, { 20520, 6 }, { 14256, 4 }, { 12810, 2 }, { 14227, 2 } }, out = { 20537, 1 }, oq = 3 },
    [26085] = { name = "Soul Pouch", t = { 1, 230, 245, 260 }, scroll = 21358, train = 215, scrollPrice = 12000, sq = 1, r = { { 14048, 6 }, { 8170, 4 }, { 7972, 2 }, { 14341, 1 } }, out = { 21340, 1 }, oq = 2 },
    [26086] = { name = "Felcloth Bag", t = { 1, 260, 275, 290 }, scroll = 21369, train = 250, sq = 1, r = { { 14256, 12 }, { 12810, 6 }, { 20520, 2 }, { 14227, 4 } }, out = { 21341, 1 }, oq = 3 },
    [26087] = { name = "Core Felcloth Bag", t = { 1, 315, 330, 345 }, scroll = 21371, train = 300, sq = 3, r = { { 14256, 20 }, { 17012, 16 }, { 19726, 8 }, { 7078, 4 }, { 14227, 4 } }, out = { 21342, 1 }, oq = 4 },
    [26403] = { name = "Festival Dress", t = { 1, 220, 235, 250 }, scroll = 21722, train = 205, sq = 2, r = { { 14048, 4 }, { 4625, 2 }, { 2604, 2 }, { 14341, 1 } }, out = { 21154, 1 }, oq = 1 },
    [26407] = { name = "Festival Suit", t = { 1, 220, 235, 250 }, scroll = 21723, train = 205, sq = 2, r = { { 14048, 4 }, { 4625, 2 }, { 2604, 2 }, { 14341, 1 } }, out = { 21542, 1 }, oq = 1 },
    [27658] = { name = "Enchanted Mageweave Pouch", t = { 1, 205, 220, 235 }, scroll = 22307, train = 190, scrollPrice = 6000, sq = 1, r = { { 4339, 4 }, { 11137, 4 }, { 8343, 2 } }, out = { 22246, 1 }, oq = 2 },
    [27659] = { name = "Enchanted Runecloth Bag", t = { 1, 245, 260, 275 }, scroll = 22308, train = 230, scrollPrice = 20000, sq = 1, r = { { 14048, 5 }, { 16203, 2 }, { 14341, 2 } }, out = { 22248, 1 }, oq = 2 },
    [27660] = { name = "Big Bag of Enchantment", t = { 1, 270, 285, 300 }, scroll = 22309, train = 255, sq = 2, r = { { 14048, 6 }, { 14344, 4 }, { 12810, 4 }, { 14227, 4 } }, out = { 22249, 1 }, oq = 2 },
    [27724] = { name = "Cenarion Herb Bag", t = { 1, 245, 260, 275 }, scroll = 22310, train = 230, scrollPrice = 20000, rep = { 609, 4 }, sq = 1, r = { { 14048, 5 }, { 8831, 10 }, { 11040, 8 }, { 14341, 2 } }, out = { 22251, 1 }, oq = 2 },
    [27725] = { name = "Satchel of Cenarius", t = { 1, 270, 285, 300 }, scroll = 22312, train = 255, scrollPrice = 50000, rep = { 609, 6 }, sq = 1, r = { { 14048, 6 }, { 14342, 2 }, { 13468, 1 }, { 14227, 4 } }, out = { 22252, 1 }, oq = 2 },
    [28205] = { name = "Glacial Gloves", t = { 1, 315, 330, 345 }, scroll = 22684, train = 305, sq = 1, r = { { 22682, 5 }, { 14048, 4 }, { 7080, 4 }, { 14227, 4 } }, out = { 22654, 1 }, oq = 4 },
    [28207] = { name = "Glacial Vest", t = { 1, 315, 330, 345 }, scroll = 22686, train = 305, sq = 1, r = { { 22682, 7 }, { 14048, 8 }, { 7080, 6 }, { 14227, 8 } }, out = { 22652, 1 }, oq = 4 },
    [28208] = { name = "Glacial Cloak", t = { 1, 315, 330, 345 }, scroll = 236691, train = 305, sq = 1, r = { { 22682, 5 }, { 14048, 4 }, { 7080, 2 }, { 14227, 4 } }, out = { 22658, 1 }, oq = 4 },
    [28209] = { name = "Glacial Wrists", t = { 1, 315, 330, 345 }, scroll = 22687, train = 305, sq = 1, r = { { 22682, 4 }, { 14048, 2 }, { 7080, 2 }, { 14227, 4 } }, out = { 22655, 1 }, oq = 4 },
    [28210] = { name = "Gaea's Embrace", t = { 1, 315, 330, 345 }, scroll = 22683, train = 300, scrollPrice = 90000, rep = { 609, 6 }, sq = 1, r = { { 19726, 1 }, { 14342, 2 }, { 12803, 4 }, { 14227, 4 } }, out = { 22660, 1 }, oq = 3 },
    [28480] = { name = "Sylvan Vest", t = { 1, 315, 330, 345 }, scroll = 22774, train = 300, scrollPrice = 50000, rep = { 609, 6 }, sq = 1, r = { { 14048, 4 }, { 19726, 2 }, { 12803, 2 }, { 14227, 2 } }, out = { 22756, 1 }, oq = 3 },
    [28481] = { name = "Sylvan Crown", t = { 1, 315, 330, 345 }, scroll = 22773, train = 300, scrollPrice = 50000, rep = { 609, 5 }, sq = 1, r = { { 14048, 4 }, { 14342, 2 }, { 12803, 2 }, { 14227, 2 } }, out = { 22757, 1 }, oq = 3 },
    [28482] = { name = "Sylvan Shoulders", t = { 1, 315, 330, 345 }, scroll = 22772, train = 300, scrollPrice = 50000, rep = { 609, 4 }, sq = 1, r = { { 14048, 2 }, { 12803, 4 }, { 14227, 2 } }, out = { 22758, 1 }, oq = 3 },
    [44950] = { name = "Green Winter Clothes", t = { 1, 250, 252, 255 }, scroll = 34261, train = 250, sq = 2, r = { { 14048, 4 }, { 2997, 1 }, { 2605, 2 }, { 14341, 1 } }, out = { 34087, 1 }, oq = 1 },
    [44958] = { name = "Red Winter Clothes", t = { 1, 250, 252, 255 }, scroll = 34319, train = 250, sq = 2, r = { { 14048, 4 }, { 2997, 1 }, { 2604, 2 }, { 14341, 1 } }, out = { 34085, 1 }, oq = 1 },
    [428424] = { name = "Phoenix Bindings", t = { 1, 125, 137, 150 }, scroll = 211247, train = 125, scrollPrice = 75000, sq = 2, r = { { 2997, 6 }, { 814, 2 }, { 2321, 2 } }, out = { 210781, 1 }, oq = 3 },
    [435827] = { name = "Hyperconductive Arcano-Filament", t = { 1, 200, 210, 220 }, scroll = 215368, train = 200, sq = 3, r = { { 4339, 2 }, { 213378, 5 }, { 8343, 5 } }, out = { 213379, 1 }, oq = 3 },
    [435841] = { name = "Invoker's Cord", t = { 1, 170, 185, 200 }, scroll = 215369, train = 150, sq = 2, r = { { 4305, 3 }, { 1210, 1 }, { 2321, 1 }, { 4340, 1 } }, out = { 215366, 1 }, oq = 2 },
    [435848] = { name = "Invoker's Mantle", t = { 1, 170, 185, 200 }, scroll = 215370, train = 150, sq = 2, r = { { 4305, 4 }, { 4340, 4 }, { 2321, 1 }, { 6260, 4 } }, out = { 215365, 1 }, oq = 2 },
    [461692] = { name = "Synthetic Gordok Ogre Suit", t = { 1, 285, 290, 295 }, scroll = 228115, train = 275, sq = 1, r = { { 8170, 4 }, { 14048, 2 }, { 18240, 1 }, { 14341, 1 } }, out = { 227855, 1 }, oq = 1 },
    [461708] = { name = "Incandescent Mooncloth Robe", t = { 1, 315, 330, 345 }, scroll = 228303, train = 300, sq = 1, r = { { 14048, 6 }, { 14342, 4 }, { 13926, 2 }, { 14341, 2 } }, out = { 227861, 1 }, oq = 1 },
    [461727] = { name = "Leather-Reinforced Runecloth Bag", t = { 1, 315, 330, 345 }, scroll = 228121, train = 300, sq = 2, r = { { 14048, 5 }, { 8170, 2 }, { 14341, 1 }, { 15407, 1 } }, out = { 227844, 1 }, oq = 3 },
    [461747] = { name = "Incandescent Mooncloth Vest", t = { 1, 315, 330, 345 }, scroll = 228316, train = 300, sq = 3, r = { { 14048, 6 }, { 14342, 4 }, { 14341, 1 } }, out = { 227860, 1 }, oq = 1 },
    [461750] = { name = "Incandescent Mooncloth Circlet", t = { 1, 315, 330, 345 }, scroll = 228317, train = 300, sq = 3, r = { { 14048, 4 }, { 14342, 6 }, { 12800, 1 }, { 12810, 2 }, { 14341, 2 } }, out = { 227863, 1 }, oq = 1 },
    [461752] = { name = "Incandescent Mooncloth Leggings", t = { 1, 305, 320, 335 }, scroll = 228318, train = 290, sq = 3, r = { { 14048, 6 }, { 14342, 4 }, { 14341, 1 } }, out = { 227864, 1 }, oq = 1 },
    [462282] = { name = "Embroidered Belt of the Archmage", t = { 1, 315, 330, 345 }, scroll = 228477, train = 300, sq = 4, r = { { 14048, 16 }, { 9210, 10 }, { 14342, 10 }, { 7080, 12 }, { 7078, 12 }, { 14344, 6 }, { 14341, 6 } }, out = { 228476, 1 }, oq = 1 },
    [1214306] = { name = "Dreamscale Bracers", t = { 1, 320, 330, 340 }, scroll = 234483, train = 310, sq = 1, r = { { 14048, 30 }, { 20381, 4 }, { 12803, 4 }, { 14342, 4 }, { 14227, 6 } }, out = { 234484, 1 }, oq = 1 },
    [1214307] = { name = "Dreamscale Mitts", t = { 1, 320, 330, 340 }, scroll = 234486, train = 310, sq = 1, r = { { 14048, 30 }, { 20381, 5 }, { 12803, 4 }, { 14342, 4 }, { 14227, 6 } }, out = { 234485, 1 }, oq = 1 },
    [1224607] = { name = "Scarlet Augur's Hood", t = { 1, 285, 295, 305 }, scroll = 238298, train = 280, sq = 3, r = { { 12938, 1 }, { 12811, 2 }, { 14048, 12 } }, out = { 238264, 1 }, oq = 1 },
    [1224608] = { name = "Scarlet Augur's Mantle", t = { 1, 285, 295, 305 }, scroll = 238299, train = 280, sq = 3, r = { { 12811, 1 }, { 14048, 10 } }, out = { 238265, 1 }, oq = 1 },
    [1224609] = { name = "Scarlet Augur's Vestments", t = { 1, 285, 295, 305 }, scroll = 238300, train = 280, sq = 3, r = { { 12938, 1 }, { 12811, 1 }, { 14048, 12 } }, out = { 238266, 1 }, oq = 1 },
    [1224610] = { name = "Scarlet Augur's Cuffs", t = { 1, 260, 282, 305 }, scroll = 238301, train = 250, sq = 3, r = { { 14048, 8 } }, out = { 238267, 1 }, oq = 1 },
    [1224611] = { name = "Scarlet Augur's Mitts", t = { 1, 270, 287, 305 }, scroll = 238302, train = 260, sq = 3, r = { { 12811, 1 }, { 14048, 10 } }, out = { 238268, 1 }, oq = 1 },
    [1224612] = { name = "Scarlet Augur's Strap", t = { 1, 260, 282, 305 }, scroll = 238303, train = 250, sq = 3, r = { { 12811, 1 }, { 14048, 10 } }, out = { 238269, 1 }, oq = 1 },
    [1224613] = { name = "Scarlet Augur's Leggings", t = { 1, 280, 292, 305 }, scroll = 238304, train = 270, sq = 3, r = { { 12938, 1 }, { 12811, 1 }, { 14048, 12 } }, out = { 238270, 1 }, oq = 1 },
    [1224614] = { name = "Scarlet Augur's Soles", t = { 1, 270, 287, 305 }, scroll = 238305, train = 260, sq = 3, r = { { 12811, 1 }, { 14048, 10 } }, out = { 238271, 1 }, oq = 1 },
    [1227723] = { name = "Crusader's Knapsack", t = { 1, 260, 262, 265 }, scroll = 239149, train = 250, sq = 3, r = { { 12811, 1 }, { 14048, 14 }, { 2604, 8 }, { 14227, 3 } }, out = { 239147, 1 }, oq = 3 },
    [1227724] = { name = "Crimson Dawnwoven Bag", t = { 1, 300, 302, 305 }, scroll = 239150, train = 290, sq = 4, r = { { 12938, 1 }, { 14048, 24 }, { 2604, 4 }, { 12808, 2 }, { 12811, 2 } }, out = { 239148, 1 }, oq = 4 },
    [1229504] = { name = "Faction Banner", t = { 1, 20, 22, 25 }, fee = 0, train = 20, faction = "Horde", r = { { 2996, 1 }, { 2320, 1 } }, out = { 279972, 1 }, oq = 1 },
    [1257013] = { name = "Linen Reagent Bag", t = { 1, 30, 47, 65 }, scroll = 253665, train = 5, scrollPrice = 150, sq = 2, r = { { 2996, 6 }, { 2320, 6 } }, out = { 253664, 1 }, oq = 1 },
    [1257017] = { name = "Woolen Reagent Bag", t = { 1, 75, 92, 110 }, scroll = 253668, train = 70, scrollPrice = 250, sq = 2, r = { { 2997, 3 }, { 2321, 1 }, { 249409, 1 } }, out = { 253667, 1 }, oq = 1 },
    [1257370] = { name = "Pristine Boots", t = { 1, 85, 102, 120 }, scroll = 253890, train = 60, sq = 3, favor = 30, r = { { 2997, 8 }, { 2321, 2 }, { 249409, 2 }, { 249427, 1 } }, out = { 253889, 1 }, oq = 3, bop = true },
    [1257371] = { name = "Silky Boots", t = { 1, 85, 102, 120 }, scroll = 253892, train = 60, sq = 3, favor = 30, r = { { 2997, 8 }, { 2321, 2 }, { 249409, 2 }, { 3182, 1 } }, out = { 253891, 1 }, oq = 3, bop = true },
    [1257372] = { name = "Flame Boots", t = { 1, 85, 102, 120 }, scroll = 253894, train = 60, sq = 3, favor = 30, r = { { 2997, 8 }, { 2321, 2 }, { 249409, 2 }, { 6371, 1 } }, out = { 253893, 1 }, oq = 3, bop = true },
    [1257373] = { name = "Shadow Boots", t = { 1, 85, 102, 120 }, scroll = 253896, train = 60, sq = 3, favor = 30, r = { { 2997, 8 }, { 2321, 2 }, { 249409, 2 }, { 1210, 1 } }, out = { 253895, 1 }, oq = 3, bop = true },
    [1257374] = { name = "Pearly Boots", t = { 1, 85, 102, 120 }, scroll = 253898, train = 60, sq = 3, favor = 30, r = { { 2997, 8 }, { 2321, 2 }, { 249409, 2 }, { 5498, 1 } }, out = { 253897, 1 }, oq = 3, bop = true },
    [1257375] = { name = "Shining Boots", t = { 1, 85, 102, 120 }, scroll = 253900, train = 60, sq = 3, favor = 30, r = { { 2997, 8 }, { 2321, 2 }, { 249409, 2 }, { 249391, 1 } }, out = { 253899, 1 }, oq = 3, bop = true },
    [1257382] = { name = "Pristine Gloves", t = { 1, 100, 117, 135 }, scroll = 253914, train = 75, sq = 3, favor = 30, r = { { 2997, 6 }, { 2321, 4 }, { 249409, 3 }, { 249427, 2 } }, out = { 253913, 1 }, oq = 3, bop = true },
    [1257383] = { name = "Silky Gloves", t = { 1, 100, 117, 135 }, scroll = 253916, train = 75, sq = 3, favor = 30, r = { { 2997, 6 }, { 2321, 4 }, { 249409, 3 }, { 3182, 2 } }, out = { 253915, 1 }, oq = 3, bop = true },
    [1257384] = { name = "Flame Gloves", t = { 1, 100, 117, 135 }, scroll = 253918, train = 75, sq = 3, favor = 30, r = { { 2997, 6 }, { 2321, 4 }, { 249409, 3 }, { 6371, 2 } }, out = { 253917, 1 }, oq = 3, bop = true },
    [1257385] = { name = "Shadow Gloves", t = { 1, 100, 117, 135 }, scroll = 253920, train = 75, sq = 3, favor = 30, r = { { 2997, 6 }, { 2321, 4 }, { 249409, 3 }, { 1210, 2 } }, out = { 253919, 1 }, oq = 3, bop = true },
    [1257386] = { name = "Pearly Gloves", t = { 1, 100, 117, 135 }, scroll = 253922, train = 75, sq = 3, favor = 30, r = { { 2997, 6 }, { 2321, 4 }, { 249409, 3 }, { 5498, 2 } }, out = { 253921, 1 }, oq = 3, bop = true },
    [1257387] = { name = "Shining Gloves", t = { 1, 100, 117, 135 }, scroll = 253924, train = 75, sq = 3, favor = 30, r = { { 2997, 6 }, { 2321, 4 }, { 249409, 3 }, { 249391, 2 } }, out = { 253923, 1 }, oq = 3, bop = true },
    [1257388] = { name = "Pristine Sash", t = { 1, 110, 127, 145 }, scroll = 253926, train = 85, sq = 3, favor = 30, r = { { 4305, 8 }, { 2321, 4 }, { 249409, 3 }, { 249427, 3 } }, out = { 253925, 1 }, oq = 3, bop = true },
    [1257389] = { name = "Silky Sash", t = { 1, 110, 127, 145 }, scroll = 253928, train = 85, sq = 3, favor = 30, r = { { 4305, 8 }, { 2321, 4 }, { 249409, 3 }, { 3182, 3 } }, out = { 253927, 1 }, oq = 3, bop = true },
    [1257390] = { name = "Flame Sash", t = { 1, 110, 127, 145 }, scroll = 253930, train = 85, sq = 3, favor = 30, r = { { 4305, 8 }, { 2321, 4 }, { 249409, 3 }, { 6371, 3 } }, out = { 253929, 1 }, oq = 3, bop = true },
    [1257391] = { name = "Shadow Sash", t = { 1, 110, 127, 145 }, scroll = 253932, train = 85, sq = 3, favor = 30, r = { { 4305, 8 }, { 2321, 4 }, { 249409, 3 }, { 1210, 3 } }, out = { 253931, 1 }, oq = 3, bop = true },
    [1257392] = { name = "Pearly Sash", t = { 1, 110, 127, 145 }, scroll = 253934, train = 85, sq = 3, favor = 30, r = { { 4305, 8 }, { 2321, 4 }, { 249409, 3 }, { 5498, 3 } }, out = { 253933, 1 }, oq = 3, bop = true },
    [1257393] = { name = "Shining Sash", t = { 1, 110, 127, 145 }, scroll = 253936, train = 85, sq = 3, favor = 30, r = { { 4305, 8 }, { 2321, 4 }, { 249409, 3 }, { 249391, 3 } }, out = { 253935, 1 }, oq = 3, bop = true },
    [1257400] = { name = "Pristine Circlet", t = { 1, 125, 142, 160 }, scroll = 253950, train = 100, sq = 3, favor = 30, r = { { 4305, 10 }, { 4291, 2 }, { 249409, 4 }, { 249427, 4 }, { 2842, 1 }, { 11082, 2 } }, out = { 253949, 1 }, oq = 3, bop = true },
    [1257401] = { name = "Silky Circlet", t = { 1, 125, 142, 160 }, scroll = 253952, train = 100, sq = 3, favor = 30, r = { { 4305, 10 }, { 4291, 2 }, { 249409, 4 }, { 3182, 4 }, { 2842, 1 }, { 11082, 2 } }, out = { 253951, 1 }, oq = 3, bop = true },
    [1257402] = { name = "Flame Circlet", t = { 1, 125, 142, 160 }, scroll = 253954, train = 100, sq = 3, favor = 30, r = { { 4305, 10 }, { 4291, 2 }, { 249409, 4 }, { 6371, 4 }, { 2842, 1 }, { 11082, 2 } }, out = { 253953, 1 }, oq = 3, bop = true },
    [1257403] = { name = "Shadow Circlet", t = { 1, 125, 142, 160 }, scroll = 253956, train = 100, sq = 3, favor = 30, r = { { 4305, 10 }, { 4291, 2 }, { 249409, 4 }, { 1210, 4 }, { 2842, 1 }, { 11082, 2 } }, out = { 253955, 1 }, oq = 3, bop = true },
    [1257404] = { name = "Pearly Circlet", t = { 1, 125, 142, 160 }, scroll = 253958, train = 100, sq = 3, favor = 30, r = { { 4305, 10 }, { 4291, 2 }, { 249409, 4 }, { 5498, 4 }, { 2842, 1 }, { 11082, 2 } }, out = { 253957, 1 }, oq = 3, bop = true },
    [1257405] = { name = "Shining Circlet", t = { 1, 125, 142, 160 }, scroll = 253960, train = 100, sq = 3, favor = 30, r = { { 4305, 10 }, { 4291, 2 }, { 249409, 4 }, { 249391, 4 }, { 2842, 1 }, { 11082, 2 } }, out = { 253959, 1 }, oq = 3, bop = true },
    [1257406] = { name = "Pristine Gown", t = { 1, 130, 145, 160 }, scroll = 253962, train = 110, sq = 3, favor = 30, r = { { 4305, 12 }, { 4291, 2 }, { 249409, 6 }, { 249427, 6 }, { 2842, 2 }, { 11082, 2 } }, out = { 253961, 1 }, oq = 3, bop = true },
    [1257407] = { name = "Silky Gown", t = { 1, 130, 145, 160 }, scroll = 253964, train = 110, sq = 3, favor = 30, r = { { 4305, 12 }, { 4291, 2 }, { 249409, 6 }, { 3182, 6 }, { 2842, 2 }, { 11082, 2 } }, out = { 253963, 1 }, oq = 3, bop = true },
    [1257408] = { name = "Flame Gown", t = { 1, 130, 145, 160 }, scroll = 253966, train = 110, sq = 3, favor = 30, r = { { 4305, 12 }, { 4291, 2 }, { 249409, 6 }, { 6371, 6 }, { 2842, 2 }, { 11082, 2 } }, out = { 253965, 1 }, oq = 3, bop = true },
    [1257409] = { name = "Shadow Gown", t = { 1, 130, 145, 160 }, scroll = 253968, train = 110, sq = 3, favor = 30, r = { { 4305, 12 }, { 4291, 2 }, { 249409, 6 }, { 1210, 6 }, { 2842, 2 }, { 11082, 2 } }, out = { 253967, 1 }, oq = 3, bop = true },
    [1257410] = { name = "Pearly Gown", t = { 1, 130, 145, 160 }, scroll = 253970, train = 110, sq = 3, favor = 30, r = { { 4305, 12 }, { 4291, 2 }, { 249409, 6 }, { 5498, 6 }, { 2842, 2 }, { 11082, 2 } }, out = { 253969, 1 }, oq = 3, bop = true },
    [1257411] = { name = "Shining Gown", t = { 1, 130, 145, 160 }, scroll = 253972, train = 110, sq = 3, favor = 30, r = { { 4305, 12 }, { 4291, 2 }, { 249409, 6 }, { 249391, 6 }, { 2842, 2 }, { 11082, 2 } }, out = { 253971, 1 }, oq = 3, bop = true },
    [1257412] = { name = "Silk Reagent Bag", t = { 1, 135, 137, 140 }, scroll = 253974, train = 125, scrollPrice = 1000, sq = 2, r = { { 4305, 3 }, { 4234, 2 }, { 2321, 3 }, { 249409, 3 } }, out = { 253973, 1 }, oq = 1 },
    [1257419] = { name = "Pristine Leggings", t = { 1, 145, 160, 175 }, scroll = 253988, train = 125, sq = 3, favor = 30, r = { { 4305, 14 }, { 2321, 3 }, { 249409, 8 }, { 249427, 8 }, { 2842, 2 }, { 11082, 3 } }, out = { 253987, 1 }, oq = 3, bop = true },
    [1257420] = { name = "Silky Leggings", t = { 1, 145, 160, 175 }, scroll = 253990, train = 125, sq = 3, favor = 30, r = { { 4305, 14 }, { 2321, 3 }, { 249409, 8 }, { 3182, 8 }, { 2842, 2 }, { 11082, 3 } }, out = { 253989, 1 }, oq = 3, bop = true },
    [1257421] = { name = "Flame Leggings", t = { 1, 145, 160, 175 }, scroll = 253992, train = 125, sq = 3, favor = 30, r = { { 4305, 14 }, { 2321, 3 }, { 249409, 8 }, { 6371, 8 }, { 2842, 2 }, { 11082, 3 } }, out = { 253991, 1 }, oq = 3, bop = true },
    [1257422] = { name = "Shadow Leggings", t = { 1, 145, 160, 175 }, scroll = 253994, train = 125, sq = 3, favor = 30, r = { { 4305, 14 }, { 2321, 3 }, { 249409, 8 }, { 1210, 8 }, { 2842, 2 }, { 11082, 3 } }, out = { 253993, 1 }, oq = 3, bop = true },
    [1257423] = { name = "Pearly Leggings", t = { 1, 145, 160, 175 }, scroll = 253996, train = 125, sq = 3, favor = 30, r = { { 4305, 14 }, { 2321, 3 }, { 249409, 8 }, { 5498, 8 }, { 2842, 2 }, { 11082, 3 } }, out = { 253995, 1 }, oq = 3, bop = true },
    [1257424] = { name = "Shining Leggings", t = { 1, 145, 160, 175 }, scroll = 253998, train = 125, sq = 3, favor = 30, r = { { 4305, 14 }, { 2321, 3 }, { 249409, 8 }, { 249391, 8 }, { 2842, 2 }, { 11082, 3 } }, out = { 253997, 1 }, oq = 3, bop = true },
    [1257425] = { name = "Earthen Leggings", t = { 1, 160, 175, 190 }, scroll = 254000, train = 140, sq = 2, r = { { 4305, 4 }, { 7067, 1 }, { 2321, 2 } }, out = { 253999, 1 }, oq = 2 },
    [1257432] = { name = "Earthen Silk Slippers", t = { 1, 165, 180, 195 }, scroll = 254014, train = 145, sq = 2, r = { { 4305, 4 }, { 7067, 1 }, { 2321, 2 }, { 4234, 2 } }, out = { 254013, 1 }, oq = 2 },
    [1257433] = { name = "Earthen Silk Hood", t = { 1, 170, 185, 200 }, scroll = 254016, train = 150, sq = 2, r = { { 4305, 4 }, { 7067, 2 }, { 2321, 2 } }, out = { 254015, 1 }, oq = 2 },
    [1257434] = { name = "Earthen Silk Gloves", t = { 1, 180, 195, 210 }, scroll = 254018, train = 160, sq = 2, r = { { 4305, 5 }, { 7067, 2 }, { 4291, 2 } }, out = { 254017, 1 }, oq = 2 },
    [1257435] = { name = "Earthen Silk Cuffs", t = { 1, 185, 200, 215 }, scroll = 254020, train = 165, sq = 2, r = { { 4305, 4 }, { 7067, 1 }, { 4291, 1 } }, out = { 254019, 1 }, oq = 2 },
    [1257436] = { name = "Gilded Handwraps", t = { 1, 185, 200, 215 }, scroll = 254022, train = 165, sq = 3, r = { { 4339, 12 }, { 8343, 4 }, { 249430, 2 }, { 249409, 1 }, { 3577, 4 } }, out = { 254021, 1 }, oq = 3 },
    [1257437] = { name = "Frothing Handwraps", t = { 1, 185, 200, 215 }, scroll = 254024, train = 165, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 12 }, { 8343, 4 }, { 249430, 2 }, { 249409, 1 }, { 7079, 4 } }, out = { 254023, 1 }, oq = 3, bop = true },
    [1257438] = { name = "Fiery Handwraps", t = { 1, 185, 200, 215 }, scroll = 254026, train = 165, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 12 }, { 8343, 4 }, { 249430, 2 }, { 249409, 1 }, { 7077, 4 } }, out = { 254025, 1 }, oq = 3, bop = true },
    [1257439] = { name = "Black Handwraps", t = { 1, 185, 200, 215 }, scroll = 254028, train = 165, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 12 }, { 8343, 4 }, { 249430, 2 }, { 249409, 1 }, { 7971, 4 } }, out = { 254027, 1 }, oq = 3, bop = true },
    [1257440] = { name = "Golden Handwraps", t = { 1, 185, 200, 215 }, scroll = 254030, train = 165, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 12 }, { 8343, 4 }, { 249430, 2 }, { 249409, 1 }, { 13926, 4 } }, out = { 254029, 1 }, oq = 3, bop = true },
    [1257441] = { name = "Radiant Handwraps", t = { 1, 185, 200, 215 }, scroll = 254032, train = 165, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 12 }, { 8343, 4 }, { 249430, 2 }, { 249409, 1 }, { 11178, 4 } }, out = { 254031, 1 }, oq = 3, bop = true },
    [1257442] = { name = "Earthen Silk Shoulders", t = { 1, 185, 200, 215 }, scroll = 254034, train = 170, sq = 2, r = { { 4305, 6 }, { 7067, 2 }, { 4291, 3 } }, out = { 254033, 1 }, oq = 2 },
    [1257443] = { name = "Mageweave Reagent Bag", t = { 1, 205, 210, 215 }, scroll = 254036, train = 190, sq = 2, favor = 60, favorRep = 5, r = { { 4339, 4 }, { 8343, 2 }, { 249430, 1 }, { 249409, 1 } }, out = { 254035, 1 }, oq = 1 },
    [1257450] = { name = "Nethergeld Shoulders", t = { 1, 210, 225, 240 }, scroll = 254050, train = 195, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 16 }, { 8343, 3 }, { 249430, 4 }, { 249409, 3 }, { 3577, 8 }, { 11175, 2 } }, out = { 254049, 1 }, oq = 3, bop = true },
    [1257451] = { name = "Netherfroth Shoulders", t = { 1, 210, 225, 240 }, scroll = 254052, train = 195, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 16 }, { 8343, 3 }, { 249430, 4 }, { 249409, 3 }, { 7079, 8 }, { 11175, 2 } }, out = { 254051, 1 }, oq = 3, bop = true },
    [1257452] = { name = "Netherflame Shoulders", t = { 1, 210, 225, 240 }, scroll = 254054, train = 195, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 16 }, { 8343, 3 }, { 249430, 4 }, { 249409, 3 }, { 7077, 8 }, { 11175, 2 } }, out = { 254053, 1 }, oq = 3, bop = true },
    [1257453] = { name = "Netherpearl Shoulders", t = { 1, 210, 225, 240 }, scroll = 254056, train = 195, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 16 }, { 8343, 3 }, { 249430, 4 }, { 249409, 3 }, { 7971, 8 }, { 11175, 2 } }, out = { 254055, 1 }, oq = 3, bop = true },
    [1257454] = { name = "Nethershine Shoulders", t = { 1, 210, 225, 240 }, scroll = 254058, train = 195, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 16 }, { 8343, 3 }, { 249430, 4 }, { 249409, 3 }, { 13926, 8 }, { 11175, 2 } }, out = { 254057, 1 }, oq = 3, bop = true },
    [1257455] = { name = "Netherlight Shoulders", t = { 1, 210, 225, 240 }, scroll = 254060, train = 195, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 16 }, { 8343, 3 }, { 249430, 4 }, { 249409, 3 }, { 11178, 8 }, { 11175, 2 } }, out = { 254059, 1 }, oq = 3, bop = true },
    [1257456] = { name = "Nethergeld Cuffs", t = { 1, 220, 235, 250 }, scroll = 254062, train = 205, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 18 }, { 8343, 3 }, { 249430, 6 }, { 249409, 4 }, { 3577, 10 }, { 11175, 4 } }, out = { 254061, 1 }, oq = 3, bop = true },
    [1257457] = { name = "Netherfroth Cuffs", t = { 1, 220, 235, 250 }, scroll = 254064, train = 205, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 18 }, { 8343, 3 }, { 249430, 6 }, { 249409, 4 }, { 7079, 10 }, { 11175, 4 } }, out = { 254063, 1 }, oq = 3, bop = true },
    [1257458] = { name = "Netherflame Cuffs", t = { 1, 220, 235, 250 }, scroll = 254066, train = 205, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 18 }, { 8343, 3 }, { 249430, 6 }, { 249409, 4 }, { 7077, 10 }, { 11175, 4 } }, out = { 254065, 1 }, oq = 3, bop = true },
    [1257459] = { name = "Netherpearl Cuffs", t = { 1, 220, 235, 250 }, scroll = 254068, train = 205, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 18 }, { 8343, 3 }, { 249430, 6 }, { 249409, 4 }, { 7971, 10 }, { 11175, 4 } }, out = { 254067, 1 }, oq = 3, bop = true },
    [1257460] = { name = "Nethershine Cuffs", t = { 1, 220, 235, 250 }, scroll = 254070, train = 205, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 18 }, { 8343, 3 }, { 249430, 6 }, { 249409, 4 }, { 13926, 10 }, { 11175, 4 } }, out = { 254069, 1 }, oq = 3, bop = true },
    [1257461] = { name = "Netherlight Cuffs", t = { 1, 220, 235, 250 }, scroll = 254072, train = 205, sq = 3, favor = 60, favorRep = 5, r = { { 4339, 18 }, { 8343, 3 }, { 249430, 6 }, { 249409, 4 }, { 11178, 10 }, { 11175, 4 } }, out = { 254071, 1 }, oq = 3, bop = true },
    [1257462] = { name = "Ghostweave Cord", t = { 1, 230, 245, 260 }, scroll = 254074, train = 215, sq = 2, r = { { 14048, 4 }, { 9210, 1 }, { 14227, 1 }, { 14341, 1 } }, out = { 254073, 1 }, oq = 2 },
    [1257463] = { name = "Earthenweave Gloves", t = { 1, 230, 245, 260 }, scroll = 254076, train = 215, sq = 2, r = { { 14048, 6 }, { 7076, 1 }, { 14341, 1 } }, out = { 254075, 1 }, oq = 2 },
    [1257464] = { name = "Earthenweave Cord", t = { 1, 230, 245, 260 }, scroll = 254078, train = 215, sq = 2, r = { { 14048, 4 }, { 7076, 2 }, { 14341, 1 } }, out = { 254077, 1 }, oq = 2 },
    [1257465] = { name = "Runecloth Reagent Bag", t = { 1, 230, 245, 260 }, scroll = 254080, train = 215, sq = 2, favor = 60, favorRep = 5, r = { { 14048, 5 }, { 8170, 2 }, { 14341, 1 }, { 249431, 1 } }, out = { 254079, 1 }, oq = 1 },
    [1257466] = { name = "Gilded Waistcord", t = { 1, 230, 245, 260 }, scroll = 254082, train = 215, sq = 3, favor = 60, favorRep = 5, r = { { 14048, 8 }, { 8343, 4 }, { 249430, 8 }, { 249409, 5 }, { 3577, 12 } }, out = { 254081, 1 }, oq = 3, bop = true },
    [1257467] = { name = "Frothing Waistcord", t = { 1, 230, 245, 260 }, scroll = 254084, train = 215, sq = 3, favor = 60, favorRep = 5, r = { { 14048, 8 }, { 8343, 4 }, { 249430, 8 }, { 249409, 5 }, { 7079, 12 } }, out = { 254083, 1 }, oq = 3, bop = true },
    [1257468] = { name = "Fiery Waistcord", t = { 1, 230, 245, 260 }, scroll = 254086, train = 215, sq = 3, favor = 60, favorRep = 5, r = { { 14048, 8 }, { 8343, 4 }, { 249430, 8 }, { 249409, 5 }, { 7077, 12 } }, out = { 254085, 1 }, oq = 3, bop = true },
    [1257469] = { name = "Black Waistcord", t = { 1, 230, 245, 260 }, scroll = 254088, train = 215, sq = 3, favor = 60, favorRep = 5, r = { { 14048, 8 }, { 8343, 4 }, { 249430, 8 }, { 249409, 5 }, { 7971, 12 } }, out = { 254087, 1 }, oq = 3, bop = true },
    [1257470] = { name = "Golden Waistcord", t = { 1, 230, 245, 260 }, scroll = 254090, train = 215, sq = 3, favor = 60, favorRep = 5, r = { { 14048, 8 }, { 8343, 4 }, { 249430, 8 }, { 249409, 5 }, { 13926, 12 } }, out = { 254089, 1 }, oq = 3, bop = true },
    [1257471] = { name = "Radiant Waistcord", t = { 1, 230, 245, 260 }, scroll = 254092, train = 215, sq = 3, favor = 60, favorRep = 5, r = { { 14048, 8 }, { 8343, 4 }, { 249430, 8 }, { 249409, 5 }, { 11178, 12 } }, out = { 254091, 1 }, oq = 3, bop = true },
    [1257472] = { name = "Earthenweave Boots", t = { 1, 240, 255, 270 }, scroll = 254094, train = 225, sq = 2, r = { { 14048, 4 }, { 7076, 2 }, { 8170, 2 }, { 14341, 1 } }, out = { 254093, 1 }, oq = 2 },
    [1257479] = { name = "Gilded Sandals", t = { 1, 250, 265, 280 }, scroll = 254108, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 14048, 10 }, { 8343, 4 }, { 249430, 10 }, { 249409, 6 }, { 3577, 14 }, { 249427, 4 } }, out = { 254107, 1 }, oq = 3, bop = true },
    [1257480] = { name = "Frothing Sandals", t = { 1, 250, 265, 280 }, scroll = 254110, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 14048, 10 }, { 8343, 4 }, { 249430, 10 }, { 249409, 6 }, { 7079, 14 }, { 249427, 4 } }, out = { 254109, 1 }, oq = 3, bop = true },
    [1257481] = { name = "Fiery Sandals", t = { 1, 250, 265, 280 }, scroll = 254112, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 14048, 10 }, { 8343, 4 }, { 249430, 10 }, { 249409, 6 }, { 7077, 14 }, { 249427, 4 } }, out = { 254111, 1 }, oq = 3, bop = true },
    [1257482] = { name = "Black Sandals", t = { 1, 250, 265, 280 }, scroll = 254114, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 14048, 10 }, { 8343, 4 }, { 249430, 10 }, { 249409, 6 }, { 7971, 14 }, { 249427, 4 } }, out = { 254113, 1 }, oq = 3, bop = true },
    [1257483] = { name = "Golden Sandals", t = { 1, 250, 265, 280 }, scroll = 254116, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 14048, 10 }, { 8343, 4 }, { 249430, 10 }, { 249409, 6 }, { 13926, 14 }, { 249427, 4 } }, out = { 254115, 1 }, oq = 3, bop = true },
    [1257484] = { name = "Radiant Sandals", t = { 1, 250, 265, 280 }, scroll = 254118, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 14048, 10 }, { 8343, 4 }, { 249430, 10 }, { 249409, 6 }, { 11178, 14 }, { 249427, 4 } }, out = { 254117, 1 }, oq = 3, bop = true },
    [1257485] = { name = "Earthenweave Mantle", t = { 1, 255, 270, 285 }, scroll = 254120, train = 240, sq = 2, r = { { 14048, 6 }, { 7076, 1 }, { 14341, 1 } }, out = { 254119, 1 }, oq = 2 },
    [1257486] = { name = "Earthenweave Vest", t = { 1, 265, 280, 295 }, scroll = 254122, train = 250, sq = 2, r = { { 14048, 8 }, { 7076, 1 }, { 14341, 1 } }, out = { 254121, 1 }, oq = 2 },
    [1257487] = { name = "Runecloth Cuffs", t = { 1, 265, 280, 295 }, scroll = 254124, train = 250, scrollPrice = 100000, sq = 2, r = { { 14048, 5 }, { 14227, 1 }, { 14341, 1 } }, out = { 254123, 1 }, oq = 2 },
    [1257488] = { name = "Earthenweave Leggings", t = { 1, 260, 275, 290 }, scroll = 254126, train = 245, sq = 2, r = { { 14048, 6 }, { 7076, 2 }, { 14341, 1 } }, out = { 254125, 1 }, oq = 2 },
    [1257489] = { name = "Ghostweave Mantle", t = { 1, 265, 280, 295 }, scroll = 254128, train = 250, sq = 2, r = { { 14048, 5 }, { 9210, 3 }, { 14227, 1 }, { 14341, 1 } }, out = { 254127, 1 }, oq = 2 },
    [1257490] = { name = "Ghostweave Boots", t = { 1, 265, 280, 295 }, scroll = 254130, train = 255, sq = 2, r = { { 14048, 4 }, { 9210, 2 }, { 14227, 1 }, { 8170, 2 }, { 14341, 1 } }, out = { 254129, 1 }, oq = 2 },
    [1257491] = { name = "Earthenweave Cuffs", t = { 1, 270, 285, 300 }, scroll = 254132, train = 255, sq = 2, r = { { 14048, 5 }, { 7076, 1 }, { 14341, 1 } }, out = { 254131, 1 }, oq = 2 },
    [1257492] = { name = "Mooncloth Reagent Bag", t = { 1, 270, 285, 300 }, scroll = 254134, train = 255, sq = 2, r = { { 14048, 4 }, { 14342, 1 }, { 14341, 1 }, { 249431, 10 }, { 249430, 1 }, { 249409, 1 } }, out = { 254133, 1 }, oq = 1 },
    [1257493] = { name = "Ghostweave Hood", t = { 1, 275, 290, 305 }, scroll = 254136, train = 260, sq = 2, r = { { 14048, 6 }, { 9210, 3 }, { 14227, 2 }, { 14341, 1 } }, out = { 254135, 1 }, oq = 2 },
    [1257494] = { name = "Earthenweave Crown", t = { 1, 275, 290, 305 }, scroll = 254138, train = 260, sq = 2, r = { { 14048, 6 }, { 7076, 3 }, { 14341, 1 } }, out = { 254137, 1 }, oq = 2 },
    [1257495] = { name = "Bottomless Reagent Bag", t = { 1, 315, 330, 345 }, scroll = 254140, train = 300, sq = 2, r = { { 14048, 8 }, { 14342, 12 }, { 14344, 2 }, { 249427, 5 }, { 14341, 2 }, { 249428, 5 }, { 249429, 5 } }, out = { 254139, 1 }, oq = 1 },
    [1263032] = { name = "Spinning Wheel", t = { 1, 140, 142, 145 }, scroll = 273099, train = 140, sq = 2, r = { { 4470, 2 }, { 4305, 5 }, { 2321, 3 } }, out = { 279943, 1 }, oq = 1 },
    [1263425] = { name = "Faction Banner", t = { 1, 20, 22, 25 }, fee = 0, train = 20, faction = "Alliance", r = { { 2996, 1 }, { 2320, 1 } }, out = { 279973, 1 }, oq = 1 },
    [1292941] = { name = "Manaflare Pants", t = { 1, 320, 325, 330 }, scroll = 273972, train = 300, sq = 4, r = { { 274030, 5 }, { 14342, 3 }, { 14048, 22 }, { 14341, 8 } }, out = { 273904, 1 }, oq = 1 },
    [1292942] = { name = "Manaflare Gloves", t = { 1, 320, 325, 330 }, scroll = 273973, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273905, 1 }, oq = 1 },
    [1292943] = { name = "Manaflare Mantle", t = { 1, 320, 325, 330 }, scroll = 273974, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273906, 1 }, oq = 1 },
    [1292944] = { name = "Manaflare Boots", t = { 1, 320, 325, 330 }, scroll = 273975, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273907, 1 }, oq = 1 },
    [1292957] = { name = "Pants of Conviction", t = { 1, 320, 325, 330 }, scroll = 273988, train = 300, sq = 4, r = { { 274030, 5 }, { 14342, 3 }, { 14048, 22 }, { 14341, 8 } }, out = { 273920, 1 }, oq = 1 },
    [1292958] = { name = "Gloves of Conviction", t = { 1, 320, 325, 330 }, scroll = 273989, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273921, 1 }, oq = 1 },
    [1292959] = { name = "Mantle of Conviction", t = { 1, 320, 325, 330 }, scroll = 273990, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273922, 1 }, oq = 1 },
    [1292960] = { name = "Treads of Conviction", t = { 1, 320, 325, 330 }, scroll = 273991, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273923, 1 }, oq = 1 },
    [1292961] = { name = "Leggings of Conviction", t = { 1, 320, 325, 330 }, scroll = 273992, train = 300, sq = 4, r = { { 274030, 5 }, { 14342, 3 }, { 14048, 22 }, { 14341, 8 } }, out = { 273924, 1 }, oq = 1 },
    [1292962] = { name = "Handguards of Conviction", t = { 1, 320, 325, 330 }, scroll = 273993, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273925, 1 }, oq = 1 },
    [1292963] = { name = "Pauldrons of Conviction", t = { 1, 320, 325, 330 }, scroll = 273994, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273926, 1 }, oq = 1 },
    [1292964] = { name = "Boots of Conviction", t = { 1, 320, 325, 330 }, scroll = 273995, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273927, 1 }, oq = 1 },
    [1292977] = { name = "Demonheart Leggings", t = { 1, 320, 325, 330 }, scroll = 274008, train = 300, sq = 4, r = { { 274030, 5 }, { 14342, 3 }, { 14048, 22 }, { 14341, 8 } }, out = { 273940, 1 }, oq = 1 },
    [1292978] = { name = "Demonheart Gloves", t = { 1, 320, 325, 330 }, scroll = 274009, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273941, 1 }, oq = 1 },
    [1292979] = { name = "Demonheart Spaulders", t = { 1, 320, 325, 330 }, scroll = 274010, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273942, 1 }, oq = 1 },
    [1292980] = { name = "Demonheart Boots", t = { 1, 320, 325, 330 }, scroll = 274011, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 2 }, { 14048, 16 }, { 14341, 8 } }, out = { 273943, 1 }, oq = 1 },
    [1297120] = { name = "Venomspew Gloves", t = { 1, 290, 292, 295 }, scroll = 275580, train = 285, scrollPrice = 75000, rep = { 609, 4 }, sq = 3, r = { { 14048, 4 }, { 14343, 1 }, { 7082, 3 }, { 14341, 6 } }, out = { 275604, 1 }, oq = 3 },
    [1297121] = { name = "Venomspew Cord", t = { 1, 295, 297, 300 }, scroll = 275581, train = 290, scrollPrice = 75000, rep = { 609, 5 }, sq = 3, r = { { 14048, 6 }, { 14343, 1 }, { 7082, 3 }, { 14341, 6 } }, out = { 275605, 1 }, oq = 3 },
    [1297122] = { name = "Venomspew Footpads", t = { 1, 295, 297, 300 }, scroll = 275582, train = 295, scrollPrice = 75000, rep = { 609, 5 }, sq = 3, r = { { 14048, 5 }, { 14343, 1 }, { 7082, 3 }, { 14341, 6 } }, out = { 275606, 1 }, oq = 3 },
    [1297123] = { name = "Swarmtender's Gloves", t = { 1, 290, 292, 295 }, scroll = 275583, train = 285, scrollPrice = 75000, rep = { 609, 4 }, sq = 3, r = { { 14048, 4 }, { 14343, 1 }, { 7080, 3 }, { 14341, 6 } }, out = { 275607, 1 }, oq = 3 },
    [1297124] = { name = "Swarmtender's Cord", t = { 1, 295, 297, 300 }, scroll = 275584, train = 290, scrollPrice = 75000, rep = { 609, 5 }, sq = 3, r = { { 14048, 6 }, { 14343, 1 }, { 7080, 3 }, { 14341, 6 } }, out = { 275608, 1 }, oq = 3 },
    [1297125] = { name = "Swarmtender's Footpads", t = { 1, 295, 297, 300 }, scroll = 275585, train = 295, scrollPrice = 75000, rep = { 609, 5 }, sq = 3, r = { { 14048, 5 }, { 14343, 1 }, { 7080, 3 }, { 14341, 6 } }, out = { 275609, 1 }, oq = 3 },
    [1301439] = { name = "Cloudy Stormsewn Vest", t = { 1, 65, 67, 70 }, scroll = 276946, train = 60, rep = { 2758, 5 }, sq = 2, r = { { 2996, 5 }, { 2320, 2 } }, out = { 277010, 1 }, oq = 2 },
    [1301440] = { name = "Cloudy Stormsewn Cuffs", t = { 1, 55, 57, 60 }, scroll = 276947, train = 50, rep = { 2758, 4 }, sq = 2, r = { { 2996, 3 }, { 2320, 3 } }, out = { 277011, 1 }, oq = 2 },
    [1301441] = { name = "Cloudy Stormsewn Handwraps", t = { 1, 60, 62, 65 }, scroll = 276948, train = 55, rep = { 2758, 4 }, sq = 2, r = { { 2996, 4 }, { 2320, 4 } }, out = { 277012, 1 }, oq = 2 },
    [1301442] = { name = "Cloudy Stormsewn Cord", t = { 1, 55, 57, 60 }, scroll = 276949, train = 50, rep = { 2758, 4 }, sq = 2, r = { { 2996, 3 }, { 2320, 3 } }, out = { 277013, 1 }, oq = 2 },
    [1301443] = { name = "Cloudy Stormsewn Leggings", t = { 1, 65, 67, 70 }, scroll = 276950, train = 60, rep = { 2758, 5 }, sq = 2, r = { { 2996, 5 }, { 2320, 2 } }, out = { 277014, 1 }, oq = 2 },
    [1301444] = { name = "Cloudy Stormsewn Shoes", t = { 1, 60, 62, 65 }, scroll = 276951, train = 55, rep = { 2758, 4 }, sq = 2, r = { { 2996, 4 }, { 2320, 3 } }, out = { 277015, 1 }, oq = 2 },
    [1301463] = { name = "Azure Stormsewn Vest", t = { 1, 65, 67, 70 }, scroll = 276970, train = 60, rep = { 2758, 5 }, sq = 2, r = { { 2996, 5 }, { 2320, 2 } }, out = { 277034, 1 }, oq = 2 },
    [1301464] = { name = "Azure Stormsewn Cuffs", t = { 1, 55, 57, 60 }, scroll = 276971, train = 50, rep = { 2758, 4 }, sq = 2, r = { { 2996, 3 }, { 2320, 3 } }, out = { 277035, 1 }, oq = 2 },
    [1301465] = { name = "Azure Stormsewn Handwraps", t = { 1, 60, 62, 65 }, scroll = 276972, train = 55, rep = { 2758, 4 }, sq = 2, r = { { 2996, 4 }, { 2320, 4 } }, out = { 277036, 1 }, oq = 2 },
    [1301466] = { name = "Azure Stormsewn Cord", t = { 1, 55, 57, 60 }, scroll = 276973, train = 50, rep = { 2758, 4 }, sq = 2, r = { { 2996, 3 }, { 2320, 3 } }, out = { 277037, 1 }, oq = 2 },
    [1301468] = { name = "Azure Stormsewn Leggings", t = { 1, 65, 67, 70 }, scroll = 276974, train = 60, rep = { 2758, 5 }, sq = 2, r = { { 2996, 5 }, { 2320, 2 } }, out = { 277038, 1 }, oq = 2 },
    [1301469] = { name = "Azure Stormsewn Shoes", t = { 1, 60, 62, 65 }, scroll = 276975, train = 55, rep = { 2758, 4 }, sq = 2, r = { { 2996, 4 }, { 2320, 3 } }, out = { 277039, 1 }, oq = 2 },
    [1301532] = { name = "Cloudy Stormsewn Cowl", t = { 1, 185, 187, 190 }, scroll = 276982, train = 175, scrollPrice = 100000, rep = { 2787, 4 }, sq = 2, r = { { 4305, 7 }, { 11134, 2 }, { 8343, 1 }, { 2324, 8 } }, out = { 277046, 1 }, oq = 2 },
    [1301533] = { name = "Cloudy Stormsewn Epaulets", t = { 1, 185, 187, 190 }, scroll = 276983, train = 175, scrollPrice = 100000, rep = { 2787, 4 }, sq = 2, r = { { 4305, 5 }, { 11134, 1 }, { 8343, 1 }, { 2324, 6 } }, out = { 277047, 1 }, oq = 2 },
    [1301540] = { name = "Azure Stormsewn Cowl", t = { 1, 185, 187, 190 }, scroll = 276990, train = 175, scrollPrice = 100000, rep = { 2740, 4 }, sq = 2, r = { { 4305, 7 }, { 11134, 2 }, { 8343, 1 }, { 6260, 4 } }, out = { 277054, 1 }, oq = 2 },
    [1301541] = { name = "Azure Stormsewn Epaulets", t = { 1, 185, 187, 190 }, scroll = 276991, train = 175, scrollPrice = 100000, rep = { 2740, 4 }, sq = 2, r = { { 4305, 5 }, { 11134, 1 }, { 8343, 1 }, { 6260, 3 } }, out = { 277055, 1 }, oq = 2 },
    [1306540] = { name = "Robes of Fiery Devastation", t = { 1, 310, 317, 325 }, scroll = 279315, train = 300, sq = 4, r = { { 274030, 3 }, { 14342, 3 }, { 14048, 9 } }, out = { 279266, 1 }, oq = 4 },
    [1306541] = { name = "Mana-infused Cord", t = { 1, 310, 317, 325 }, scroll = 279316, train = 300, sq = 4, r = { { 274030, 2 }, { 14342, 2 }, { 14048, 7 } }, out = { 279267, 1 }, oq = 4 },
    [1306542] = { name = "Rime-encrusted Boots", t = { 1, 310, 317, 325 }, scroll = 279317, train = 300, sq = 4, r = { { 274030, 2 }, { 14342, 2 }, { 14048, 7 } }, out = { 279268, 1 }, oq = 4 },
    [1306543] = { name = "Fel Cape", t = { 1, 310, 317, 325 }, scroll = 279318, train = 300, sq = 4, r = { { 274030, 1 }, { 14342, 1 }, { 14048, 5 } }, out = { 279269, 1 }, oq = 4 },
    [1306544] = { name = "Cloak of Earth and Sky", t = { 1, 310, 317, 325 }, scroll = 279319, train = 300, sq = 4, r = { { 274030, 1 }, { 14342, 1 }, { 14048, 5 } }, out = { 279270, 1 }, oq = 4 },
    [1306545] = { name = "Felblood Soul Bag", t = { 1, 310, 317, 325 }, scroll = 279320, train = 300, sq = 4, r = { { 14256, 8 }, { 14048, 6 } }, out = { 279271, 1 }, oq = 4 },
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
ES.Data.VendorPrices[929] = 300
ES.Data.VendorPrices[2320] = 10
ES.Data.VendorPrices[2321] = 100
ES.Data.VendorPrices[2324] = 25
ES.Data.VendorPrices[2325] = 1000
ES.Data.VendorPrices[2604] = 50
ES.Data.VendorPrices[2605] = 100
ES.Data.VendorPrices[4291] = 500
ES.Data.VendorPrices[4340] = 350
ES.Data.VendorPrices[4341] = 500
ES.Data.VendorPrices[4342] = 2500
ES.Data.VendorPrices[4470] = 38
ES.Data.VendorPrices[6260] = 50
ES.Data.VendorPrices[6261] = 1000
ES.Data.VendorPrices[8343] = 2000
ES.Data.VendorPrices[10290] = 2500
ES.Data.VendorPrices[14341] = 5000
ES.Data.SellPrices[814] = 25
ES.Data.SellPrices[929] = 75
ES.Data.SellPrices[1210] = 250
ES.Data.SellPrices[1529] = 700
ES.Data.SellPrices[2318] = 15
ES.Data.SellPrices[2319] = 50
ES.Data.SellPrices[2320] = 2
ES.Data.SellPrices[2321] = 25
ES.Data.SellPrices[2324] = 6
ES.Data.SellPrices[2325] = 250
ES.Data.SellPrices[2568] = 31
ES.Data.SellPrices[2569] = 87
ES.Data.SellPrices[2570] = 11
ES.Data.SellPrices[2572] = 99
ES.Data.SellPrices[2575] = 25
ES.Data.SellPrices[2576] = 75
ES.Data.SellPrices[2577] = 75
ES.Data.SellPrices[2578] = 224
ES.Data.SellPrices[2579] = 37
ES.Data.SellPrices[2580] = 67
ES.Data.SellPrices[2582] = 216
ES.Data.SellPrices[2583] = 359
ES.Data.SellPrices[2584] = 142
ES.Data.SellPrices[2585] = 638
ES.Data.SellPrices[2587] = 200
ES.Data.SellPrices[2589] = 13
ES.Data.SellPrices[2592] = 33
ES.Data.SellPrices[2604] = 12
ES.Data.SellPrices[2605] = 25
ES.Data.SellPrices[2842] = 100
ES.Data.SellPrices[2996] = 40
ES.Data.SellPrices[2997] = 100
ES.Data.SellPrices[3182] = 387
ES.Data.SellPrices[3383] = 100
ES.Data.SellPrices[3577] = 600
ES.Data.SellPrices[3824] = 150
ES.Data.SellPrices[3827] = 120
ES.Data.SellPrices[3829] = 150
ES.Data.SellPrices[3864] = 800
ES.Data.SellPrices[4234] = 150
ES.Data.SellPrices[4238] = 200
ES.Data.SellPrices[4240] = 300
ES.Data.SellPrices[4241] = 450
ES.Data.SellPrices[4245] = 2000
ES.Data.SellPrices[4291] = 125
ES.Data.SellPrices[4304] = 300
ES.Data.SellPrices[4305] = 600
ES.Data.SellPrices[4306] = 150
ES.Data.SellPrices[4307] = 29
ES.Data.SellPrices[4308] = 45
ES.Data.SellPrices[4309] = 226
ES.Data.SellPrices[4310] = 180
ES.Data.SellPrices[4311] = 475
ES.Data.SellPrices[4312] = 237
ES.Data.SellPrices[4313] = 416
ES.Data.SellPrices[4314] = 331
ES.Data.SellPrices[4315] = 425
ES.Data.SellPrices[4316] = 743
ES.Data.SellPrices[4317] = 1076
ES.Data.SellPrices[4318] = 610
ES.Data.SellPrices[4319] = 815
ES.Data.SellPrices[4320] = 979
ES.Data.SellPrices[4321] = 1120
ES.Data.SellPrices[4322] = 1810
ES.Data.SellPrices[4323] = 1999
ES.Data.SellPrices[4324] = 1874
ES.Data.SellPrices[4325] = 2272
ES.Data.SellPrices[4326] = 2496
ES.Data.SellPrices[4327] = 3788
ES.Data.SellPrices[4328] = 1524
ES.Data.SellPrices[4329] = 2120
ES.Data.SellPrices[4330] = 250
ES.Data.SellPrices[4331] = 526
ES.Data.SellPrices[4332] = 500
ES.Data.SellPrices[4333] = 1200
ES.Data.SellPrices[4334] = 550
ES.Data.SellPrices[4335] = 1500
ES.Data.SellPrices[4336] = 1500
ES.Data.SellPrices[4337] = 750
ES.Data.SellPrices[4338] = 250
ES.Data.SellPrices[4339] = 1250
ES.Data.SellPrices[4340] = 87
ES.Data.SellPrices[4341] = 125
ES.Data.SellPrices[4342] = 625
ES.Data.SellPrices[4343] = 60
ES.Data.SellPrices[4344] = 11
ES.Data.SellPrices[4470] = 9
ES.Data.SellPrices[4589] = 530
ES.Data.SellPrices[4625] = 250
ES.Data.SellPrices[5498] = 200
ES.Data.SellPrices[5500] = 750
ES.Data.SellPrices[5542] = 370
ES.Data.SellPrices[5762] = 250
ES.Data.SellPrices[5763] = 700
ES.Data.SellPrices[5764] = 3000
ES.Data.SellPrices[5765] = 4000
ES.Data.SellPrices[5766] = 1338
ES.Data.SellPrices[5770] = 1807
ES.Data.SellPrices[6037] = 1250
ES.Data.SellPrices[6048] = 100
ES.Data.SellPrices[6238] = 98
ES.Data.SellPrices[6239] = 160
ES.Data.SellPrices[6240] = 161
ES.Data.SellPrices[6241] = 99
ES.Data.SellPrices[6242] = 243
ES.Data.SellPrices[6243] = 445
ES.Data.SellPrices[6260] = 12
ES.Data.SellPrices[6261] = 250
ES.Data.SellPrices[6263] = 589
ES.Data.SellPrices[6264] = 884
ES.Data.SellPrices[6371] = 12
ES.Data.SellPrices[6384] = 250
ES.Data.SellPrices[6385] = 250
ES.Data.SellPrices[6786] = 59
ES.Data.SellPrices[6787] = 466
ES.Data.SellPrices[6795] = 500
ES.Data.SellPrices[6796] = 750
ES.Data.SellPrices[7026] = 22
ES.Data.SellPrices[7027] = 1125
ES.Data.SellPrices[7046] = 1494
ES.Data.SellPrices[7047] = 824
ES.Data.SellPrices[7048] = 745
ES.Data.SellPrices[7049] = 914
ES.Data.SellPrices[7050] = 999
ES.Data.SellPrices[7051] = 2696
ES.Data.SellPrices[7052] = 1488
ES.Data.SellPrices[7053] = 2240
ES.Data.SellPrices[7054] = 4700
ES.Data.SellPrices[7055] = 1503
ES.Data.SellPrices[7056] = 2314
ES.Data.SellPrices[7057] = 2323
ES.Data.SellPrices[7058] = 2052
ES.Data.SellPrices[7059] = 2781
ES.Data.SellPrices[7060] = 2791
ES.Data.SellPrices[7061] = 2017
ES.Data.SellPrices[7062] = 2430
ES.Data.SellPrices[7063] = 4741
ES.Data.SellPrices[7064] = 2569
ES.Data.SellPrices[7065] = 2398
ES.Data.SellPrices[7067] = 400
ES.Data.SellPrices[7068] = 400
ES.Data.SellPrices[7069] = 400
ES.Data.SellPrices[7070] = 400
ES.Data.SellPrices[7071] = 100
ES.Data.SellPrices[7072] = 150
ES.Data.SellPrices[7076] = 400
ES.Data.SellPrices[7077] = 400
ES.Data.SellPrices[7078] = 400
ES.Data.SellPrices[7079] = 400
ES.Data.SellPrices[7080] = 400
ES.Data.SellPrices[7082] = 400
ES.Data.SellPrices[7910] = 5000
ES.Data.SellPrices[7971] = 1000
ES.Data.SellPrices[7972] = 400
ES.Data.SellPrices[8153] = 5
ES.Data.SellPrices[8170] = 500
ES.Data.SellPrices[8343] = 500
ES.Data.SellPrices[8831] = 300
ES.Data.SellPrices[9210] = 750
ES.Data.SellPrices[9998] = 4815
ES.Data.SellPrices[9999] = 4832
ES.Data.SellPrices[10001] = 5257
ES.Data.SellPrices[10002] = 5276
ES.Data.SellPrices[10003] = 2859
ES.Data.SellPrices[10004] = 5738
ES.Data.SellPrices[10007] = 5799
ES.Data.SellPrices[10008] = 3492
ES.Data.SellPrices[10009] = 5284
ES.Data.SellPrices[10010] = 5729
ES.Data.SellPrices[10011] = 2875
ES.Data.SellPrices[10018] = 3275
ES.Data.SellPrices[10019] = 3944
ES.Data.SellPrices[10020] = 6597
ES.Data.SellPrices[10021] = 7946
ES.Data.SellPrices[10023] = 3334
ES.Data.SellPrices[10024] = 5421
ES.Data.SellPrices[10025] = 6790
ES.Data.SellPrices[10026] = 5459
ES.Data.SellPrices[10027] = 5479
ES.Data.SellPrices[10028] = 5938
ES.Data.SellPrices[10029] = 5391
ES.Data.SellPrices[10030] = 6007
ES.Data.SellPrices[10031] = 6030
ES.Data.SellPrices[10032] = 6052
ES.Data.SellPrices[10033] = 6075
ES.Data.SellPrices[10034] = 2000
ES.Data.SellPrices[10035] = 1735
ES.Data.SellPrices[10036] = 1741
ES.Data.SellPrices[10038] = 6620
ES.Data.SellPrices[10039] = 7110
ES.Data.SellPrices[10040] = 1767
ES.Data.SellPrices[10041] = 8593
ES.Data.SellPrices[10042] = 6644
ES.Data.SellPrices[10044] = 6765
ES.Data.SellPrices[10045] = 23
ES.Data.SellPrices[10046] = 32
ES.Data.SellPrices[10047] = 164
ES.Data.SellPrices[10048] = 935
ES.Data.SellPrices[10050] = 2500
ES.Data.SellPrices[10051] = 2500
ES.Data.SellPrices[10052] = 1500
ES.Data.SellPrices[10053] = 4499
ES.Data.SellPrices[10054] = 3000
ES.Data.SellPrices[10055] = 3000
ES.Data.SellPrices[10056] = 1500
ES.Data.SellPrices[10285] = 1000
ES.Data.SellPrices[10286] = 400
ES.Data.SellPrices[10290] = 625
ES.Data.SellPrices[11040] = 1
ES.Data.SellPrices[11082] = 1
ES.Data.SellPrices[11134] = 1
ES.Data.SellPrices[11137] = 1
ES.Data.SellPrices[11175] = 1
ES.Data.SellPrices[11176] = 1
ES.Data.SellPrices[11178] = 1
ES.Data.SellPrices[12360] = 5000
ES.Data.SellPrices[12364] = 10000
ES.Data.SellPrices[12662] = 600
ES.Data.SellPrices[12800] = 10000
ES.Data.SellPrices[12803] = 500
ES.Data.SellPrices[12804] = 2000
ES.Data.SellPrices[12808] = 1000
ES.Data.SellPrices[12809] = 10000
ES.Data.SellPrices[12810] = 500
ES.Data.SellPrices[12811] = 20000
ES.Data.SellPrices[13468] = 1000
ES.Data.SellPrices[13856] = 5112
ES.Data.SellPrices[13857] = 10878
ES.Data.SellPrices[13858] = 10917
ES.Data.SellPrices[13860] = 8741
ES.Data.SellPrices[13863] = 6617
ES.Data.SellPrices[13864] = 9553
ES.Data.SellPrices[13865] = 13555
ES.Data.SellPrices[13866] = 11358
ES.Data.SellPrices[13867] = 12570
ES.Data.SellPrices[13868] = 9665
ES.Data.SellPrices[13869] = 9702
ES.Data.SellPrices[13870] = 5471
ES.Data.SellPrices[13871] = 13436
ES.Data.SellPrices[13926] = 10000
ES.Data.SellPrices[14042] = 10561
ES.Data.SellPrices[14043] = 5955
ES.Data.SellPrices[14044] = 9503
ES.Data.SellPrices[14045] = 13480
ES.Data.SellPrices[14046] = 5000
ES.Data.SellPrices[14047] = 400
ES.Data.SellPrices[14048] = 2000
ES.Data.SellPrices[14100] = 12089
ES.Data.SellPrices[14101] = 6066
ES.Data.SellPrices[14103] = 9716
ES.Data.SellPrices[14104] = 15484
ES.Data.SellPrices[14106] = 18053
ES.Data.SellPrices[14107] = 13140
ES.Data.SellPrices[14108] = 11112
ES.Data.SellPrices[14111] = 10775
ES.Data.SellPrices[14112] = 13509
ES.Data.SellPrices[14128] = 16093
ES.Data.SellPrices[14130] = 12768
ES.Data.SellPrices[14132] = 12441
ES.Data.SellPrices[14134] = 11280
ES.Data.SellPrices[14136] = 17025
ES.Data.SellPrices[14137] = 18113
ES.Data.SellPrices[14138] = 20042
ES.Data.SellPrices[14139] = 15840
ES.Data.SellPrices[14140] = 16693
ES.Data.SellPrices[14141] = 12859
ES.Data.SellPrices[14142] = 6087
ES.Data.SellPrices[14143] = 5763
ES.Data.SellPrices[14144] = 14374
ES.Data.SellPrices[14146] = 14084
ES.Data.SellPrices[14152] = 28815
ES.Data.SellPrices[14153] = 28920
ES.Data.SellPrices[14154] = 29028
ES.Data.SellPrices[14155] = 20000
ES.Data.SellPrices[14156] = 40000
ES.Data.SellPrices[14227] = 2500
ES.Data.SellPrices[14256] = 2000
ES.Data.SellPrices[14341] = 1250
ES.Data.SellPrices[14342] = 4000
ES.Data.SellPrices[14343] = 1
ES.Data.SellPrices[14344] = 1
ES.Data.SellPrices[15407] = 500
ES.Data.SellPrices[15802] = 11648
ES.Data.SellPrices[16203] = 1
ES.Data.SellPrices[16979] = 14902
ES.Data.SellPrices[16980] = 21365
ES.Data.SellPrices[17010] = 2000
ES.Data.SellPrices[17011] = 2000
ES.Data.SellPrices[17012] = 1000
ES.Data.SellPrices[17723] = 750
ES.Data.SellPrices[18263] = 16911
ES.Data.SellPrices[18405] = 14744
ES.Data.SellPrices[18407] = 11139
ES.Data.SellPrices[18408] = 11178
ES.Data.SellPrices[18409] = 11219
ES.Data.SellPrices[18413] = 17070
ES.Data.SellPrices[18486] = 21683
ES.Data.SellPrices[19047] = 9232
ES.Data.SellPrices[19050] = 18758
ES.Data.SellPrices[19056] = 12941
ES.Data.SellPrices[19059] = 17541
ES.Data.SellPrices[19156] = 34911
ES.Data.SellPrices[19165] = 45006
ES.Data.SellPrices[19682] = 25035
ES.Data.SellPrices[19683] = 25129
ES.Data.SellPrices[19684] = 18915
ES.Data.SellPrices[19726] = 500
ES.Data.SellPrices[20381] = 5000
ES.Data.SellPrices[20520] = 2000
ES.Data.SellPrices[20537] = 17736
ES.Data.SellPrices[20538] = 23733
ES.Data.SellPrices[20539] = 11908
ES.Data.SellPrices[21154] = 1
ES.Data.SellPrices[21340] = 5000
ES.Data.SellPrices[21341] = 20000
ES.Data.SellPrices[21342] = 80000
ES.Data.SellPrices[21542] = 1
ES.Data.SellPrices[22246] = 2500
ES.Data.SellPrices[22248] = 10000
ES.Data.SellPrices[22249] = 30000
ES.Data.SellPrices[22251] = 10000
ES.Data.SellPrices[22252] = 30000
ES.Data.SellPrices[22652] = 69171
ES.Data.SellPrices[22654] = 34846
ES.Data.SellPrices[22655] = 34973
ES.Data.SellPrices[22658] = 53045
ES.Data.SellPrices[22660] = 24601
ES.Data.SellPrices[22682] = 20000
ES.Data.SellPrices[22756] = 33164
ES.Data.SellPrices[22757] = 24961
ES.Data.SellPrices[22758] = 25051
ES.Data.SellPrices[34085] = 7
ES.Data.SellPrices[34087] = 7
ES.Data.SellPrices[210781] = 744
ES.Data.SellPrices[213379] = 280
ES.Data.SellPrices[215365] = 1371
ES.Data.SellPrices[215366] = 864
ES.Data.SellPrices[227844] = 40000
ES.Data.SellPrices[249391] = 100
ES.Data.SellPrices[249409] = 75
ES.Data.SellPrices[249427] = 125
ES.Data.SellPrices[249428] = 250
ES.Data.SellPrices[249429] = 375
ES.Data.SellPrices[249430] = 250
ES.Data.SellPrices[249431] = 375
ES.Data.SellPrices[253664] = 200
ES.Data.SellPrices[253667] = 1250
ES.Data.SellPrices[253889] = 351
ES.Data.SellPrices[253891] = 320
ES.Data.SellPrices[253893] = 323
ES.Data.SellPrices[253895] = 325
ES.Data.SellPrices[253897] = 328
ES.Data.SellPrices[253899] = 330
ES.Data.SellPrices[253913] = 327
ES.Data.SellPrices[253915] = 330
ES.Data.SellPrices[253917] = 341
ES.Data.SellPrices[253919] = 344
ES.Data.SellPrices[253921] = 346
ES.Data.SellPrices[253923] = 349
ES.Data.SellPrices[253925] = 465
ES.Data.SellPrices[253927] = 468
ES.Data.SellPrices[253929] = 471
ES.Data.SellPrices[253931] = 429
ES.Data.SellPrices[253933] = 445
ES.Data.SellPrices[253935] = 448
ES.Data.SellPrices[253949] = 948
ES.Data.SellPrices[253951] = 955
ES.Data.SellPrices[253953] = 962
ES.Data.SellPrices[253955] = 970
ES.Data.SellPrices[253957] = 977
ES.Data.SellPrices[253959] = 984
ES.Data.SellPrices[253961] = 1643
ES.Data.SellPrices[253963] = 1655
ES.Data.SellPrices[253965] = 1548
ES.Data.SellPrices[253967] = 1560
ES.Data.SellPrices[253969] = 1572
ES.Data.SellPrices[253971] = 1584
ES.Data.SellPrices[253973] = 200
ES.Data.SellPrices[253987] = 2076
ES.Data.SellPrices[253989] = 2092
ES.Data.SellPrices[253991] = 2108
ES.Data.SellPrices[253993] = 2124
ES.Data.SellPrices[253995] = 2139
ES.Data.SellPrices[253997] = 2155
ES.Data.SellPrices[253999] = 2990
ES.Data.SellPrices[254013] = 2351
ES.Data.SellPrices[254015] = 2675
ES.Data.SellPrices[254017] = 2095
ES.Data.SellPrices[254019] = 2279
ES.Data.SellPrices[254021] = 2754
ES.Data.SellPrices[254023] = 2773
ES.Data.SellPrices[254025] = 2528
ES.Data.SellPrices[254029] = 2567
ES.Data.SellPrices[254031] = 2656
ES.Data.SellPrices[254033] = 3613
ES.Data.SellPrices[254035] = 200
ES.Data.SellPrices[254049] = 6779
ES.Data.SellPrices[254051] = 6828
ES.Data.SellPrices[254053] = 6879
ES.Data.SellPrices[254055] = 6928
ES.Data.SellPrices[254057] = 6979
ES.Data.SellPrices[254059] = 7028
ES.Data.SellPrices[254061] = 5835
ES.Data.SellPrices[254063] = 5463
ES.Data.SellPrices[254065] = 5505
ES.Data.SellPrices[254067] = 5546
ES.Data.SellPrices[254069] = 5587
ES.Data.SellPrices[254071] = 5628
ES.Data.SellPrices[254073] = 5359
ES.Data.SellPrices[254075] = 5398
ES.Data.SellPrices[254077] = 5437
ES.Data.SellPrices[254079] = 200
ES.Data.SellPrices[254081] = 6149
ES.Data.SellPrices[254083] = 6196
ES.Data.SellPrices[254085] = 6242
ES.Data.SellPrices[254087] = 6289
ES.Data.SellPrices[254089] = 6336
ES.Data.SellPrices[254091] = 6383
ES.Data.SellPrices[254093] = 9030
ES.Data.SellPrices[254107] = 11236
ES.Data.SellPrices[254109] = 11319
ES.Data.SellPrices[254111] = 11704
ES.Data.SellPrices[254113] = 11787
ES.Data.SellPrices[254115] = 11870
ES.Data.SellPrices[254117] = 10816
ES.Data.SellPrices[254119] = 10205
ES.Data.SellPrices[254121] = 15262
ES.Data.SellPrices[254123] = 7688
ES.Data.SellPrices[254125] = 14756
ES.Data.SellPrices[254127] = 12020
ES.Data.SellPrices[254129] = 12714
ES.Data.SellPrices[254131] = 8536
ES.Data.SellPrices[254133] = 200
ES.Data.SellPrices[254135] = 13637
ES.Data.SellPrices[254137] = 12426
ES.Data.SellPrices[254139] = 200
ES.Data.SellPrices[275604] = 9017
ES.Data.SellPrices[275605] = 9050
ES.Data.SellPrices[275606] = 13626
ES.Data.SellPrices[275607] = 9117
ES.Data.SellPrices[275608] = 9149
ES.Data.SellPrices[275609] = 13774
ES.Data.SellPrices[279266] = 21117
ES.Data.SellPrices[279267] = 3262
ES.Data.SellPrices[279268] = 17158
ES.Data.SellPrices[279269] = 9999
ES.Data.SellPrices[279270] = 9999
ES.Data.SellPrices[279271] = 80000

-- Nombre de cada objeto (inglés, del cliente): se muestra mientras el juego no lo ha cargado
ES.Data.ItemNames = ES.Data.ItemNames or {}
ES.Data.ItemNames[814] = "Flask of Oil"
ES.Data.ItemNames[929] = "Healing Potion"
ES.Data.ItemNames[1210] = "Shadowgem"
ES.Data.ItemNames[1529] = "Jade"
ES.Data.ItemNames[2318] = "Light Leather"
ES.Data.ItemNames[2319] = "Medium Leather"
ES.Data.ItemNames[2320] = "Coarse Thread"
ES.Data.ItemNames[2321] = "Fine Thread"
ES.Data.ItemNames[2324] = "Bleach"
ES.Data.ItemNames[2325] = "Black Dye"
ES.Data.ItemNames[2568] = "Brown Linen Vest"
ES.Data.ItemNames[2569] = "Linen Boots"
ES.Data.ItemNames[2570] = "Linen Cloak"
ES.Data.ItemNames[2572] = "Red Linen Robe"
ES.Data.ItemNames[2575] = "Red Linen Shirt"
ES.Data.ItemNames[2576] = "White Linen Shirt"
ES.Data.ItemNames[2577] = "Blue Linen Shirt"
ES.Data.ItemNames[2578] = "Barbaric Linen Vest"
ES.Data.ItemNames[2579] = "Green Linen Shirt"
ES.Data.ItemNames[2580] = "Reinforced Linen Cape"
ES.Data.ItemNames[2582] = "Green Woolen Vest"
ES.Data.ItemNames[2583] = "Woolen Boots"
ES.Data.ItemNames[2584] = "Woolen Cape"
ES.Data.ItemNames[2585] = "Gray Woolen Robe"
ES.Data.ItemNames[2587] = "Gray Woolen Shirt"
ES.Data.ItemNames[2589] = "Linen Cloth"
ES.Data.ItemNames[2592] = "Wool Cloth"
ES.Data.ItemNames[2604] = "Red Dye"
ES.Data.ItemNames[2605] = "Green Dye"
ES.Data.ItemNames[2842] = "Silver Bar"
ES.Data.ItemNames[2996] = "Bolt of Linen Cloth"
ES.Data.ItemNames[2997] = "Bolt of Woolen Cloth"
ES.Data.ItemNames[3182] = "Spider's Silk"
ES.Data.ItemNames[3383] = "Elixir of Wisdom"
ES.Data.ItemNames[3577] = "Gold Bar"
ES.Data.ItemNames[3824] = "Shadow Oil"
ES.Data.ItemNames[3827] = "Mana Potion"
ES.Data.ItemNames[3829] = "Frost Oil"
ES.Data.ItemNames[3864] = "Citrine"
ES.Data.ItemNames[4234] = "Heavy Leather"
ES.Data.ItemNames[4238] = "Linen Bag"
ES.Data.ItemNames[4240] = "Woolen Bag"
ES.Data.ItemNames[4241] = "Green Woolen Bag"
ES.Data.ItemNames[4245] = "Small Silk Pack"
ES.Data.ItemNames[4291] = "Silken Thread"
ES.Data.ItemNames[4304] = "Thick Leather"
ES.Data.ItemNames[4305] = "Bolt of Silk Cloth"
ES.Data.ItemNames[4306] = "Silk Cloth"
ES.Data.ItemNames[4307] = "Heavy Linen Gloves"
ES.Data.ItemNames[4308] = "Green Linen Bracers"
ES.Data.ItemNames[4309] = "Handstitched Linen Britches"
ES.Data.ItemNames[4310] = "Heavy Woolen Gloves"
ES.Data.ItemNames[4311] = "Heavy Woolen Cloak"
ES.Data.ItemNames[4312] = "Soft-soled Linen Boots"
ES.Data.ItemNames[4313] = "Red Woolen Boots"
ES.Data.ItemNames[4314] = "Double-Stitched Woolen Shoulders"
ES.Data.ItemNames[4315] = "Reinforced Woolen Shoulders"
ES.Data.ItemNames[4316] = "Heavy Woolen Pants"
ES.Data.ItemNames[4317] = "Phoenix Pants"
ES.Data.ItemNames[4318] = "Gloves of Meditation"
ES.Data.ItemNames[4319] = "Azure Silk Gloves"
ES.Data.ItemNames[4320] = "Spidersilk Boots"
ES.Data.ItemNames[4321] = "Spider Silk Slippers"
ES.Data.ItemNames[4322] = "Enchanter's Cowl"
ES.Data.ItemNames[4323] = "Shadow Hood"
ES.Data.ItemNames[4324] = "Azure Silk Vest"
ES.Data.ItemNames[4325] = "Boots of the Enchanter"
ES.Data.ItemNames[4326] = "Long Silken Cloak"
ES.Data.ItemNames[4327] = "Icy Cloak"
ES.Data.ItemNames[4328] = "Spider Belt"
ES.Data.ItemNames[4329] = "Star Belt"
ES.Data.ItemNames[4330] = "Stylish Red Shirt"
ES.Data.ItemNames[4331] = "Phoenix Gloves"
ES.Data.ItemNames[4332] = "Bright Yellow Shirt"
ES.Data.ItemNames[4333] = "Dark Silk Shirt"
ES.Data.ItemNames[4334] = "Formal White Shirt"
ES.Data.ItemNames[4335] = "Rich Purple Silk Shirt"
ES.Data.ItemNames[4336] = "Black Swashbuckler's Shirt"
ES.Data.ItemNames[4337] = "Thick Spider's Silk"
ES.Data.ItemNames[4338] = "Mageweave Cloth"
ES.Data.ItemNames[4339] = "Bolt of Mageweave"
ES.Data.ItemNames[4340] = "Gray Dye"
ES.Data.ItemNames[4341] = "Yellow Dye"
ES.Data.ItemNames[4342] = "Purple Dye"
ES.Data.ItemNames[4343] = "Brown Linen Pants"
ES.Data.ItemNames[4344] = "Brown Linen Shirt"
ES.Data.ItemNames[4470] = "Simple Wood"
ES.Data.ItemNames[4589] = "Long Elegant Feather"
ES.Data.ItemNames[4625] = "Firebloom"
ES.Data.ItemNames[5498] = "Small Lustrous Pearl"
ES.Data.ItemNames[5500] = "Iridescent Pearl"
ES.Data.ItemNames[5542] = "Pearl-clasped Cloak"
ES.Data.ItemNames[5762] = "Red Linen Bag"
ES.Data.ItemNames[5763] = "Red Woolen Bag"
ES.Data.ItemNames[5764] = "Green Silk Pack"
ES.Data.ItemNames[5765] = "Black Silk Pack"
ES.Data.ItemNames[5766] = "Lesser Wizard's Robe"
ES.Data.ItemNames[5770] = "Robes of Arcana"
ES.Data.ItemNames[6037] = "Truesilver Bar"
ES.Data.ItemNames[6048] = "Shadow Protection Potion"
ES.Data.ItemNames[6238] = "Brown Linen Robe"
ES.Data.ItemNames[6239] = "Red Linen Vest"
ES.Data.ItemNames[6240] = "Blue Linen Vest"
ES.Data.ItemNames[6241] = "White Linen Robe"
ES.Data.ItemNames[6242] = "Blue Linen Robe"
ES.Data.ItemNames[6243] = "Green Woolen Robe"
ES.Data.ItemNames[6260] = "Blue Dye"
ES.Data.ItemNames[6261] = "Orange Dye"
ES.Data.ItemNames[6263] = "Blue Overalls"
ES.Data.ItemNames[6264] = "Greater Adept's Robe"
ES.Data.ItemNames[6371] = "Fire Oil"
ES.Data.ItemNames[6384] = "Stylish Blue Shirt"
ES.Data.ItemNames[6385] = "Stylish Green Shirt"
ES.Data.ItemNames[6786] = "Simple Dress"
ES.Data.ItemNames[6787] = "White Woolen Dress"
ES.Data.ItemNames[6795] = "White Swashbuckler's Shirt"
ES.Data.ItemNames[6796] = "Red Swashbuckler's Shirt"
ES.Data.ItemNames[7026] = "Linen Belt"
ES.Data.ItemNames[7027] = "Boots of Darkness"
ES.Data.ItemNames[7046] = "Azure Silk Pants"
ES.Data.ItemNames[7047] = "Hands of Darkness"
ES.Data.ItemNames[7048] = "Azure Silk Hood"
ES.Data.ItemNames[7049] = "Truefaith Gloves"
ES.Data.ItemNames[7050] = "Silk Headband"
ES.Data.ItemNames[7051] = "Earthen Vest"
ES.Data.ItemNames[7052] = "Azure Silk Belt"
ES.Data.ItemNames[7053] = "Azure Silk Cloak"
ES.Data.ItemNames[7054] = "Robe of Power"
ES.Data.ItemNames[7055] = "Crimson Silk Belt"
ES.Data.ItemNames[7056] = "Crimson Silk Cloak"
ES.Data.ItemNames[7057] = "Green Silken Shoulders"
ES.Data.ItemNames[7058] = "Crimson Silk Vest"
ES.Data.ItemNames[7059] = "Crimson Silk Shoulders"
ES.Data.ItemNames[7060] = "Azure Shoulders"
ES.Data.ItemNames[7061] = "Earthen Silk Belt"
ES.Data.ItemNames[7062] = "Crimson Silk Pantaloons"
ES.Data.ItemNames[7063] = "Crimson Silk Robe"
ES.Data.ItemNames[7064] = "Crimson Silk Gloves"
ES.Data.ItemNames[7065] = "Green Silk Armor"
ES.Data.ItemNames[7067] = "Elemental Earth"
ES.Data.ItemNames[7068] = "Elemental Fire"
ES.Data.ItemNames[7069] = "Elemental Air"
ES.Data.ItemNames[7070] = "Elemental Water"
ES.Data.ItemNames[7071] = "Iron Buckle"
ES.Data.ItemNames[7072] = "Naga Scale"
ES.Data.ItemNames[7076] = "Essence of Earth"
ES.Data.ItemNames[7077] = "Heart of Fire"
ES.Data.ItemNames[7078] = "Essence of Fire"
ES.Data.ItemNames[7079] = "Globe of Water"
ES.Data.ItemNames[7080] = "Essence of Water"
ES.Data.ItemNames[7082] = "Essence of Air"
ES.Data.ItemNames[7910] = "Star Ruby"
ES.Data.ItemNames[7971] = "Black Pearl"
ES.Data.ItemNames[7972] = "Ichor of Undeath"
ES.Data.ItemNames[8153] = "Wildvine"
ES.Data.ItemNames[8170] = "Rugged Leather"
ES.Data.ItemNames[8343] = "Heavy Silken Thread"
ES.Data.ItemNames[8831] = "Purple Lotus"
ES.Data.ItemNames[9210] = "Ghost Dye"
ES.Data.ItemNames[9998] = "Black Mageweave Vest"
ES.Data.ItemNames[9999] = "Black Mageweave Leggings"
ES.Data.ItemNames[10001] = "Black Mageweave Robe"
ES.Data.ItemNames[10002] = "Shadoweave Pants"
ES.Data.ItemNames[10003] = "Black Mageweave Gloves"
ES.Data.ItemNames[10004] = "Shadoweave Robe"
ES.Data.ItemNames[10007] = "Red Mageweave Vest"
ES.Data.ItemNames[10008] = "White Bandit Mask"
ES.Data.ItemNames[10009] = "Red Mageweave Pants"
ES.Data.ItemNames[10010] = "Stormcloth Pants"
ES.Data.ItemNames[10011] = "Stormcloth Gloves"
ES.Data.ItemNames[10018] = "Red Mageweave Gloves"
ES.Data.ItemNames[10019] = "Dreamweave Gloves"
ES.Data.ItemNames[10020] = "Stormcloth Vest"
ES.Data.ItemNames[10021] = "Dreamweave Vest"
ES.Data.ItemNames[10023] = "Shadoweave Gloves"
ES.Data.ItemNames[10024] = "Black Mageweave Headband"
ES.Data.ItemNames[10025] = "Shadoweave Mask"
ES.Data.ItemNames[10026] = "Black Mageweave Boots"
ES.Data.ItemNames[10027] = "Black Mageweave Shoulders"
ES.Data.ItemNames[10028] = "Shadoweave Shoulders"
ES.Data.ItemNames[10029] = "Red Mageweave Shoulders"
ES.Data.ItemNames[10030] = "Admiral's Hat"
ES.Data.ItemNames[10031] = "Shadoweave Boots"
ES.Data.ItemNames[10032] = "Stormcloth Headband"
ES.Data.ItemNames[10033] = "Red Mageweave Headband"
ES.Data.ItemNames[10034] = "Tuxedo Shirt"
ES.Data.ItemNames[10035] = "Tuxedo Pants"
ES.Data.ItemNames[10036] = "Tuxedo Jacket"
ES.Data.ItemNames[10038] = "Stormcloth Shoulders"
ES.Data.ItemNames[10039] = "Stormcloth Boots"
ES.Data.ItemNames[10040] = "White Wedding Dress"
ES.Data.ItemNames[10041] = "Dreamweave Circlet"
ES.Data.ItemNames[10042] = "Cindercloth Robe"
ES.Data.ItemNames[10044] = "Cindercloth Boots"
ES.Data.ItemNames[10045] = "Simple Linen Pants"
ES.Data.ItemNames[10046] = "Simple Linen Boots"
ES.Data.ItemNames[10047] = "Simple Kilt"
ES.Data.ItemNames[10048] = "Colorful Kilt"
ES.Data.ItemNames[10050] = "Mageweave Bag"
ES.Data.ItemNames[10051] = "Red Mageweave Bag"
ES.Data.ItemNames[10052] = "Orange Martial Shirt"
ES.Data.ItemNames[10053] = "Simple Black Dress"
ES.Data.ItemNames[10054] = "Lavender Mageweave Shirt"
ES.Data.ItemNames[10055] = "Pink Mageweave Shirt"
ES.Data.ItemNames[10056] = "Orange Mageweave Shirt"
ES.Data.ItemNames[10285] = "Shadow Silk"
ES.Data.ItemNames[10286] = "Heart of the Wild"
ES.Data.ItemNames[10290] = "Pink Dye"
ES.Data.ItemNames[11040] = "Morrowgrain"
ES.Data.ItemNames[11082] = "Greater Astral Essence"
ES.Data.ItemNames[11134] = "Lesser Mystic Essence"
ES.Data.ItemNames[11137] = "Vision Dust"
ES.Data.ItemNames[11175] = "Greater Nether Essence"
ES.Data.ItemNames[11176] = "Dream Dust"
ES.Data.ItemNames[11178] = "Large Radiant Shard"
ES.Data.ItemNames[12360] = "Arcanite Bar"
ES.Data.ItemNames[12364] = "Huge Emerald"
ES.Data.ItemNames[12662] = "Demonic Rune"
ES.Data.ItemNames[12800] = "Azerothian Diamond"
ES.Data.ItemNames[12803] = "Living Essence"
ES.Data.ItemNames[12804] = "Powerful Mojo"
ES.Data.ItemNames[12808] = "Essence of Undeath"
ES.Data.ItemNames[12809] = "Guardian Stone"
ES.Data.ItemNames[12810] = "Enchanted Leather"
ES.Data.ItemNames[12811] = "Righteous Orb"
ES.Data.ItemNames[12938] = "Blood of Heroes"
ES.Data.ItemNames[13468] = "Black Lotus"
ES.Data.ItemNames[13856] = "Runecloth Belt"
ES.Data.ItemNames[13857] = "Runecloth Tunic"
ES.Data.ItemNames[13858] = "Runecloth Robe"
ES.Data.ItemNames[13860] = "Runecloth Cloak"
ES.Data.ItemNames[13863] = "Runecloth Gloves"
ES.Data.ItemNames[13864] = "Runecloth Boots"
ES.Data.ItemNames[13865] = "Runecloth Pants"
ES.Data.ItemNames[13866] = "Runecloth Headband"
ES.Data.ItemNames[13867] = "Runecloth Shoulders"
ES.Data.ItemNames[13868] = "Frostweave Robe"
ES.Data.ItemNames[13869] = "Frostweave Tunic"
ES.Data.ItemNames[13870] = "Frostweave Gloves"
ES.Data.ItemNames[13871] = "Frostweave Pants"
ES.Data.ItemNames[13926] = "Golden Pearl"
ES.Data.ItemNames[14042] = "Cindercloth Vest"
ES.Data.ItemNames[14043] = "Cindercloth Gloves"
ES.Data.ItemNames[14044] = "Cindercloth Cloak"
ES.Data.ItemNames[14045] = "Cindercloth Pants"
ES.Data.ItemNames[14046] = "Runecloth Bag"
ES.Data.ItemNames[14047] = "Runecloth"
ES.Data.ItemNames[14048] = "Bolt of Runecloth"
ES.Data.ItemNames[14100] = "Brightcloth Robe"
ES.Data.ItemNames[14101] = "Brightcloth Gloves"
ES.Data.ItemNames[14103] = "Brightcloth Cloak"
ES.Data.ItemNames[14104] = "Brightcloth Pants"
ES.Data.ItemNames[14106] = "Felcloth Robe"
ES.Data.ItemNames[14107] = "Felcloth Pants"
ES.Data.ItemNames[14108] = "Felcloth Boots"
ES.Data.ItemNames[14111] = "Felcloth Hood"
ES.Data.ItemNames[14112] = "Felcloth Shoulders"
ES.Data.ItemNames[14128] = "Wizardweave Robe"
ES.Data.ItemNames[14130] = "Wizardweave Turban"
ES.Data.ItemNames[14132] = "Wizardweave Leggings"
ES.Data.ItemNames[14134] = "Cloak of Fire"
ES.Data.ItemNames[14136] = "Robe of Winter Night"
ES.Data.ItemNames[14137] = "Mooncloth Leggings"
ES.Data.ItemNames[14138] = "Mooncloth Vest"
ES.Data.ItemNames[14139] = "Mooncloth Shoulders"
ES.Data.ItemNames[14140] = "Mooncloth Circlet"
ES.Data.ItemNames[14141] = "Ghostweave Vest"
ES.Data.ItemNames[14142] = "Ghostweave Gloves"
ES.Data.ItemNames[14143] = "Ghostweave Belt"
ES.Data.ItemNames[14144] = "Ghostweave Pants"
ES.Data.ItemNames[14146] = "Gloves of Spell Mastery"
ES.Data.ItemNames[14152] = "Robe of the Archmage"
ES.Data.ItemNames[14153] = "Robe of the Void"
ES.Data.ItemNames[14154] = "Truefaith Vestments"
ES.Data.ItemNames[14155] = "Mooncloth Bag"
ES.Data.ItemNames[14156] = "Bottomless Bag"
ES.Data.ItemNames[14227] = "Ironweb Spider Silk"
ES.Data.ItemNames[14256] = "Felcloth"
ES.Data.ItemNames[14341] = "Rune Thread"
ES.Data.ItemNames[14342] = "Mooncloth"
ES.Data.ItemNames[14343] = "Small Brilliant Shard"
ES.Data.ItemNames[14344] = "Large Brilliant Shard"
ES.Data.ItemNames[15407] = "Cured Rugged Hide"
ES.Data.ItemNames[15802] = "Mooncloth Boots"
ES.Data.ItemNames[16203] = "Greater Eternal Essence"
ES.Data.ItemNames[16979] = "Flarecore Gloves"
ES.Data.ItemNames[16980] = "Flarecore Mantle"
ES.Data.ItemNames[17010] = "Fiery Core"
ES.Data.ItemNames[17011] = "Lava Core"
ES.Data.ItemNames[17012] = "Core Leather"
ES.Data.ItemNames[17723] = "Green Holiday Shirt"
ES.Data.ItemNames[18240] = "Ogre Tannin"
ES.Data.ItemNames[18258] = "Gordok Ogre Suit"
ES.Data.ItemNames[18263] = "Flarecore Wraps"
ES.Data.ItemNames[18405] = "Belt of the Archmage"
ES.Data.ItemNames[18407] = "Felcloth Gloves"
ES.Data.ItemNames[18408] = "Inferno Gloves"
ES.Data.ItemNames[18409] = "Mooncloth Gloves"
ES.Data.ItemNames[18413] = "Cloak of Warding"
ES.Data.ItemNames[18486] = "Mooncloth Robe"
ES.Data.ItemNames[19047] = "Wisdom of the Timbermaw"
ES.Data.ItemNames[19050] = "Mantle of the Timbermaw"
ES.Data.ItemNames[19056] = "Argent Boots"
ES.Data.ItemNames[19059] = "Argent Shoulders"
ES.Data.ItemNames[19156] = "Flarecore Robe"
ES.Data.ItemNames[19165] = "Flarecore Leggings"
ES.Data.ItemNames[19682] = "Bloodvine Vest"
ES.Data.ItemNames[19683] = "Bloodvine Leggings"
ES.Data.ItemNames[19684] = "Bloodvine Boots"
ES.Data.ItemNames[19726] = "Bloodvine"
ES.Data.ItemNames[20381] = "Dreamscale"
ES.Data.ItemNames[20520] = "Dark Rune"
ES.Data.ItemNames[20537] = "Runed Stygian Boots"
ES.Data.ItemNames[20538] = "Runed Stygian Leggings"
ES.Data.ItemNames[20539] = "Runed Stygian Belt"
ES.Data.ItemNames[21154] = "Festival Dress"
ES.Data.ItemNames[21340] = "Soul Pouch"
ES.Data.ItemNames[21341] = "Felcloth Bag"
ES.Data.ItemNames[21342] = "Core Felcloth Bag"
ES.Data.ItemNames[21542] = "Festival Suit"
ES.Data.ItemNames[22246] = "Enchanted Mageweave Pouch"
ES.Data.ItemNames[22248] = "Enchanted Runecloth Bag"
ES.Data.ItemNames[22249] = "Big Bag of Enchantment"
ES.Data.ItemNames[22251] = "Cenarion Herb Bag"
ES.Data.ItemNames[22252] = "Satchel of Cenarius"
ES.Data.ItemNames[22652] = "Glacial Vest"
ES.Data.ItemNames[22654] = "Glacial Gloves"
ES.Data.ItemNames[22655] = "Glacial Wrists"
ES.Data.ItemNames[22658] = "Glacial Cloak"
ES.Data.ItemNames[22660] = "Gaea's Embrace"
ES.Data.ItemNames[22682] = "Frozen Rune"
ES.Data.ItemNames[22756] = "Sylvan Vest"
ES.Data.ItemNames[22757] = "Sylvan Crown"
ES.Data.ItemNames[22758] = "Sylvan Shoulders"
ES.Data.ItemNames[34085] = "Red Winter Clothes"
ES.Data.ItemNames[34087] = "Green Winter Clothes"
ES.Data.ItemNames[210781] = "Phoenix Bindings"
ES.Data.ItemNames[213378] = "Unstable Microfilament"
ES.Data.ItemNames[213379] = "Hyperconductive Arcano-Filament"
ES.Data.ItemNames[215365] = "Invoker's Mantle"
ES.Data.ItemNames[215366] = "Invoker's Cord"
ES.Data.ItemNames[227844] = "Leather-Reinforced Runecloth Bag"
ES.Data.ItemNames[239147] = "Crusader's Knapsack"
ES.Data.ItemNames[239148] = "Crimson Dawnwoven Bag"
ES.Data.ItemNames[249391] = "Pyrite"
ES.Data.ItemNames[249409] = "Cerulean Dye"
ES.Data.ItemNames[249427] = "Pristine Leather"
ES.Data.ItemNames[249428] = "Pristine Hide"
ES.Data.ItemNames[249429] = "Pristine Scale"
ES.Data.ItemNames[249430] = "Magenta Dye"
ES.Data.ItemNames[249431] = "Viridian Dye"
ES.Data.ItemNames[253664] = "Linen Reagent Bag"
ES.Data.ItemNames[253667] = "Woolen Reagent Bag"
ES.Data.ItemNames[253889] = "Pristine Boots"
ES.Data.ItemNames[253891] = "Silky Boots"
ES.Data.ItemNames[253893] = "Flame Boots"
ES.Data.ItemNames[253895] = "Shadow Boots"
ES.Data.ItemNames[253897] = "Pearly Boots"
ES.Data.ItemNames[253899] = "Shining Boots"
ES.Data.ItemNames[253913] = "Pristine Gloves"
ES.Data.ItemNames[253915] = "Silky Gloves"
ES.Data.ItemNames[253917] = "Flame Gloves"
ES.Data.ItemNames[253919] = "Shadow Gloves"
ES.Data.ItemNames[253921] = "Pearly Gloves"
ES.Data.ItemNames[253923] = "Shining Gloves"
ES.Data.ItemNames[253925] = "Pristine Sash"
ES.Data.ItemNames[253927] = "Silky Sash"
ES.Data.ItemNames[253929] = "Flame Sash"
ES.Data.ItemNames[253931] = "Shadow Sash"
ES.Data.ItemNames[253933] = "Pearly Sash"
ES.Data.ItemNames[253935] = "Shining Sash"
ES.Data.ItemNames[253949] = "Pristine Circlet"
ES.Data.ItemNames[253951] = "Silky Circlet"
ES.Data.ItemNames[253953] = "Flame Circlet"
ES.Data.ItemNames[253955] = "Shadow Circlet"
ES.Data.ItemNames[253957] = "Pearly Circlet"
ES.Data.ItemNames[253959] = "Shining Circlet"
ES.Data.ItemNames[253961] = "Pristine Gown"
ES.Data.ItemNames[253963] = "Silky Gown"
ES.Data.ItemNames[253965] = "Flame Gown"
ES.Data.ItemNames[253967] = "Shadow Gown"
ES.Data.ItemNames[253969] = "Pearly Gown"
ES.Data.ItemNames[253971] = "Shining Gown"
ES.Data.ItemNames[253973] = "Silk Reagent Bag"
ES.Data.ItemNames[253987] = "Pristine Leggings"
ES.Data.ItemNames[253989] = "Silky Leggings"
ES.Data.ItemNames[253991] = "Flame Leggings"
ES.Data.ItemNames[253993] = "Shadow Leggings"
ES.Data.ItemNames[253995] = "Pearly Leggings"
ES.Data.ItemNames[253997] = "Shining Leggings"
ES.Data.ItemNames[253999] = "Earthen Leggings"
ES.Data.ItemNames[254013] = "Earthen Silk Slippers"
ES.Data.ItemNames[254015] = "Earthen Silk Hood"
ES.Data.ItemNames[254017] = "Earthen Silk Gloves"
ES.Data.ItemNames[254019] = "Earthen Silk Cuffs"
ES.Data.ItemNames[254021] = "Gilded Handwraps"
ES.Data.ItemNames[254023] = "Frothing Handwraps"
ES.Data.ItemNames[254025] = "Fiery Handwraps"
ES.Data.ItemNames[254027] = "Black Handwraps"
ES.Data.ItemNames[254029] = "Golden Handwraps"
ES.Data.ItemNames[254031] = "Radiant Handwraps"
ES.Data.ItemNames[254033] = "Earthen Silk Shoulders"
ES.Data.ItemNames[254035] = "Mageweave Reagent Bag"
ES.Data.ItemNames[254049] = "Nethergeld Shoulders"
ES.Data.ItemNames[254051] = "Netherfroth Shoulders"
ES.Data.ItemNames[254053] = "Netherflame Shoulders"
ES.Data.ItemNames[254055] = "Netherpearl Shoulders"
ES.Data.ItemNames[254057] = "Nethershine Shoulders"
ES.Data.ItemNames[254059] = "Netherlight Shoulders"
ES.Data.ItemNames[254061] = "Nethergeld Cuffs"
ES.Data.ItemNames[254063] = "Netherfroth Cuffs"
ES.Data.ItemNames[254065] = "Netherflame Cuffs"
ES.Data.ItemNames[254067] = "Netherpearl Cuffs"
ES.Data.ItemNames[254069] = "Nethershine Cuffs"
ES.Data.ItemNames[254071] = "Netherlight Cuffs"
ES.Data.ItemNames[254073] = "Ghostweave Cord"
ES.Data.ItemNames[254075] = "Earthenweave Gloves"
ES.Data.ItemNames[254077] = "Earthenweave Cord"
ES.Data.ItemNames[254079] = "Runecloth Reagent Bag"
ES.Data.ItemNames[254081] = "Gilded Waistcord"
ES.Data.ItemNames[254083] = "Frothing Waistcord"
ES.Data.ItemNames[254085] = "Fiery Waistcord"
ES.Data.ItemNames[254087] = "Black Waistcord"
ES.Data.ItemNames[254089] = "Golden Waistcord"
ES.Data.ItemNames[254091] = "Radiant Waistcord"
ES.Data.ItemNames[254093] = "Earthenweave Boots"
ES.Data.ItemNames[254107] = "Gilded Sandals"
ES.Data.ItemNames[254109] = "Frothing Sandals"
ES.Data.ItemNames[254111] = "Fiery Sandals"
ES.Data.ItemNames[254113] = "Black Sandals"
ES.Data.ItemNames[254115] = "Golden Sandals"
ES.Data.ItemNames[254117] = "Radiant Sandals"
ES.Data.ItemNames[254119] = "Earthenweave Mantle"
ES.Data.ItemNames[254121] = "Earthenweave Vest"
ES.Data.ItemNames[254123] = "Runecloth Cuffs"
ES.Data.ItemNames[254125] = "Earthenweave Leggings"
ES.Data.ItemNames[254127] = "Ghostweave Mantle"
ES.Data.ItemNames[254129] = "Ghostweave Boots"
ES.Data.ItemNames[254131] = "Earthenweave Cuffs"
ES.Data.ItemNames[254133] = "Mooncloth Reagent Bag"
ES.Data.ItemNames[254135] = "Ghostweave Hood"
ES.Data.ItemNames[254137] = "Earthenweave Crown"
ES.Data.ItemNames[254139] = "Bottomless Reagent Bag"
ES.Data.ItemNames[274030] = "Malleable Essence of Nature"
ES.Data.ItemNames[275604] = "Venomspew Gloves"
ES.Data.ItemNames[275605] = "Venomspew Cord"
ES.Data.ItemNames[275606] = "Venomspew Footpads"
ES.Data.ItemNames[275607] = "Swarmtender's Gloves"
ES.Data.ItemNames[275608] = "Swarmtender's Cord"
ES.Data.ItemNames[275609] = "Swarmtender's Footpads"
ES.Data.ItemNames[277010] = "Cloudy Stormsewn Vest"
ES.Data.ItemNames[277011] = "Cloudy Stormsewn Cuffs"
ES.Data.ItemNames[277012] = "Cloudy Stormsewn Handwraps"
ES.Data.ItemNames[277013] = "Cloudy Stormsewn Cord"
ES.Data.ItemNames[277014] = "Cloudy Stormsewn Leggings"
ES.Data.ItemNames[277015] = "Cloudy Stormsewn Shoes"
ES.Data.ItemNames[277034] = "Azure Stormsewn Vest"
ES.Data.ItemNames[277035] = "Azure Stormsewn Cuffs"
ES.Data.ItemNames[277036] = "Azure Stormsewn Handwraps"
ES.Data.ItemNames[277037] = "Azure Stormsewn Cord"
ES.Data.ItemNames[277038] = "Azure Stormsewn Leggings"
ES.Data.ItemNames[277039] = "Azure Stormsewn Shoes"
ES.Data.ItemNames[277046] = "Cloudy Stormsewn Cowl"
ES.Data.ItemNames[277047] = "Cloudy Stormsewn Epaulets"
ES.Data.ItemNames[277054] = "Azure Stormsewn Cowl"
ES.Data.ItemNames[277055] = "Azure Stormsewn Epaulets"
ES.Data.ItemNames[279266] = "Robes of Fiery Devastation"
ES.Data.ItemNames[279267] = "Mana-infused Cord"
ES.Data.ItemNames[279268] = "Rime-encrusted Boots"
ES.Data.ItemNames[279269] = "Fel Cape"
ES.Data.ItemNames[279270] = "Cloak of Earth and Sky"
ES.Data.ItemNames[279271] = "Felblood Soul Bag"
ES.Data.ItemNames[279943] = "Spinning Wheel"
ES.Data.ItemNames[279972] = "Faction Banner"
ES.Data.ItemNames[279973] = "Faction Banner"

-- Material -> profesión de recolección que lo consigue (393 Desuello, 182 Herboristería, 186 Minería).
-- Sin uso por ahora: reservado para la vía "Vender en bruto" de Ganar dinero (docs/PLAN.md, G1).
ES.Data.GatheredBy = ES.Data.GatheredBy or {}
ES.Data.GatheredBy[2318] = 393
ES.Data.GatheredBy[2319] = 393
ES.Data.GatheredBy[2842] = 186
ES.Data.GatheredBy[4234] = 393
ES.Data.GatheredBy[4304] = 393
ES.Data.GatheredBy[4625] = 182
ES.Data.GatheredBy[8153] = 182
ES.Data.GatheredBy[8170] = 393
ES.Data.GatheredBy[8831] = 182
ES.Data.GatheredBy[12809] = 186
ES.Data.GatheredBy[13468] = 182
ES.Data.GatheredBy[17012] = 393
ES.Data.GatheredBy[19726] = 182
ES.Data.GatheredBy[20381] = 393
ES.Data.GatheredBy[249391] = 186
ES.Data.GatheredBy[249427] = 393
ES.Data.GatheredBy[249428] = 393
ES.Data.GatheredBy[249429] = 393

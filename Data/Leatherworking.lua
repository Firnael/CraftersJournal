-- Generado por tools/gen_profession.py (Leatherworking). No editar a mano.
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
ES.Data.Leatherworking = {
  skillLine = 165,
  ranks = { -- { tope, precio, habilidad requerida, nivel de personaje }
    { 150, 500, 50, 10 },
    { 225, 5000, 125, 20 },
    { 300, 50000, 200, 35 },
  },
  -- { PNJ instructor, rangos que enseña: 1 aprendiz (75), 2 oficial (150), 4 experto (225), 8 artesano (300) }
  trainers = { { 223, 1 }, { 1385, 2 }, { 1466, 1 }, { 1632, 1 }, { 3007, 4 }, { 3008, 1 }, { 3069, 1 }, { 3365, 2 }, { 3549, 1 }, { 3605, 1 }, { 3703, 2 }, { 3967, 2 }, { 4212, 4 }, { 4588, 2 }, { 5127, 2 }, { 5564, 2 }, { 5784, 1 }, { 5811, 1 }, { 11081, 2 }, { 11083, 1 }, { 11084, 2 }, { 11096, 1 }, { 11098, 8 }, { 251993, 3 }, { 252376, 3 } },
  recipes = {
    [2149] = { name = "Handstitched Leather Boots", t = { 1, 40, 55, 70 }, basic = true, r = { { 2318, 2 }, { 2320, 1 } }, out = { 2302, 1 }, oq = 1 },
    [2152] = { name = "Light Armor Kit", t = { 1, 30, 45, 60 }, basic = true, r = { { 2318, 1 } }, out = { 2304, 1 }, oq = 1 },
    [2153] = { name = "Handstitched Leather Pants", t = { 1, 45, 60, 75 }, fee = 50, train = 15, r = { { 2318, 4 }, { 2320, 1 } }, out = { 2303, 1 }, oq = 2 },
    [2158] = { name = "Fine Leather Boots", t = { 1, 95, 110, 125 }, scroll = 2406, train = 65, sq = 2, r = { { 2318, 7 }, { 2320, 2 } }, out = { 2307, 1 }, oq = 2 },
    [2159] = { name = "Fine Leather Cloak", t = { 1, 70, 85, 100 }, fee = 250, train = 50, r = { { 2318, 10 }, { 2321, 2 } }, out = { 2308, 1 }, oq = 2 },
    [2160] = { name = "Embossed Leather Vest", t = { 1, 65, 80, 95 }, fee = 100, train = 35, r = { { 2318, 8 }, { 2320, 4 } }, out = { 2300, 1 }, oq = 2 },
    [2161] = { name = "Embossed Leather Boots", t = { 1, 80, 95, 110 }, fee = 100, train = 50, r = { { 2318, 8 }, { 2320, 5 } }, out = { 2309, 1 }, oq = 2 },
    [2162] = { name = "Embossed Leather Cloak", t = { 1, 70, 85, 100 }, fee = 100, train = 40, r = { { 2318, 5 }, { 2320, 2 } }, out = { 2310, 1 }, oq = 2 },
    [2163] = { name = "White Leather Jerkin", t = { 1, 70, 85, 100 }, scroll = 2407, train = 40, sq = 2, r = { { 2318, 8 }, { 2320, 2 }, { 2324, 1 } }, out = { 2311, 1 }, oq = 2 },
    [2164] = { name = "Fine Leather Gloves", t = { 1, 80, 95, 110 }, scroll = 2408, train = 50, sq = 2, r = { { 4231, 1 }, { 2318, 4 }, { 2320, 2 } }, out = { 2312, 1 }, oq = 2 },
    [2165] = { name = "Medium Armor Kit", t = { 1, 90, 97, 105 }, fee = 250, train = 75, r = { { 2319, 4 }, { 2320, 1 } }, out = { 2313, 1 }, oq = 1 },
    [2166] = { name = "Toughened Leather Armor", t = { 1, 120, 132, 145 }, fee = 450, train = 95, r = { { 2319, 10 }, { 4231, 2 }, { 2321, 2 } }, out = { 2314, 1 }, oq = 2 },
    [2167] = { name = "Gray Leather Boots", t = { 1, 100, 112, 125 }, fee = 350, train = 75, r = { { 2319, 4 }, { 2321, 2 }, { 4340, 1 } }, out = { 2315, 1 }, oq = 2 },
    [2168] = { name = "Dark Leather Cloak", t = { 1, 110, 122, 135 }, fee = 350, train = 85, r = { { 2319, 8 }, { 2321, 1 }, { 4340, 1 } }, out = { 2316, 1 }, oq = 2 },
    [2169] = { name = "Dark Leather Tunic", t = { 1, 100, 112, 125 }, scroll = 2409, train = 75, sq = 2, r = { { 2319, 6 }, { 2321, 1 }, { 4340, 1 } }, out = { 2317, 1 }, oq = 2 },
    [2881] = { name = "Light Leather", t = { 1, 20, 30, 40 }, basic = true, r = { { 2934, 3 } }, out = { 2318, 1 }, oq = 1 },
    [3753] = { name = "Handstitched Leather Belt", t = { 1, 55, 70, 85 }, fee = 75, train = 25, r = { { 2318, 6 }, { 2320, 1 } }, out = { 4237, 1 }, oq = 2 },
    [3756] = { name = "Embossed Leather Gloves", t = { 1, 70, 85, 100 }, fee = 150, train = 40, r = { { 2318, 3 }, { 2320, 2 } }, out = { 4239, 1 }, oq = 2 },
    [3759] = { name = "Embossed Leather Pants", t = { 1, 80, 95, 110 }, fee = 200, train = 50, r = { { 4231, 1 }, { 2318, 6 }, { 2320, 2 } }, out = { 4242, 1 }, oq = 2 },
    [3760] = { name = "Hillman's Cloak", t = { 1, 145, 155, 165 }, fee = 600, train = 125, r = { { 4234, 5 }, { 2321, 2 } }, out = { 3719, 1 }, oq = 2 },
    [3761] = { name = "Fine Leather Tunic", t = { 1, 90, 105, 120 }, fee = 350, train = 60, r = { { 4231, 3 }, { 2318, 6 }, { 2320, 4 } }, out = { 4243, 1 }, oq = 2 },
    [3762] = { name = "Hillman's Leather Vest", t = { 1, 100, 112, 125 }, scroll = 4293, train = 75, sq = 2, r = { { 4243, 1 }, { 4231, 2 }, { 2320, 2 } }, out = { 4244, 1 }, oq = 2 },
    [3763] = { name = "Fine Leather Belt", t = { 1, 85, 100, 115 }, fee = 300, train = 55, r = { { 2318, 6 }, { 2320, 2 } }, out = { 4246, 1 }, oq = 2 },
    [3764] = { name = "Hillman's Leather Gloves", t = { 1, 145, 157, 170 }, fee = 500, train = 120, r = { { 2319, 14 }, { 2321, 4 } }, out = { 4247, 1 }, oq = 2 },
    [3765] = { name = "Dark Leather Gloves", t = { 1, 140, 152, 165 }, scroll = 7360, train = 95, sq = 2, r = { { 2312, 1 }, { 4233, 1 }, { 2321, 1 }, { 4340, 1 } }, out = { 4248, 1 }, oq = 2 },
    [3766] = { name = "Dark Leather Belt", t = { 1, 125, 137, 150 }, fee = 400, train = 100, r = { { 4246, 1 }, { 4233, 1 }, { 2321, 2 }, { 4340, 1 } }, out = { 4249, 1 }, oq = 2 },
    [3767] = { name = "Hillman's Belt", t = { 1, 125, 137, 150 }, scroll = 4294, train = 95, sq = 2, r = { { 2319, 8 }, { 3383, 1 }, { 2321, 2 } }, out = { 4250, 1 }, oq = 2 },
    [3768] = { name = "Hillman's Shoulders", t = { 1, 130, 142, 155 }, fee = 500, train = 105, r = { { 4233, 1 }, { 2319, 4 }, { 2321, 1 } }, out = { 4251, 1 }, oq = 2 },
    [3769] = { name = "Dark Leather Shoulders", t = { 1, 140, 152, 165 }, scroll = 4296, train = 115, sq = 2, r = { { 2319, 12 }, { 3390, 1 }, { 4340, 1 }, { 2321, 2 } }, out = { 4252, 1 }, oq = 2 },
    [3770] = { name = "Toughened Leather Gloves", t = { 1, 135, 147, 160 }, fee = 500, train = 110, r = { { 2319, 4 }, { 4233, 2 }, { 3389, 2 }, { 3182, 2 }, { 2321, 2 } }, out = { 4253, 1 }, oq = 3 },
    [3771] = { name = "Barbaric Gloves", t = { 1, 150, 160, 170 }, scroll = 4297, train = 125, sq = 2, r = { { 4234, 6 }, { 5637, 2 }, { 2321, 1 } }, out = { 4254, 1 }, oq = 2 },
    [3772] = { name = "Green Leather Armor", t = { 1, 150, 160, 170 }, scroll = 7613, train = 130, scrollPrice = 2000, sq = 1, r = { { 4234, 9 }, { 2605, 2 }, { 2321, 4 } }, out = { 4255, 1 }, oq = 2 },
    [3773] = { name = "Guardian Armor", t = { 1, 170, 180, 190 }, scroll = 4299, train = 150, sq = 2, r = { { 4236, 2 }, { 4234, 12 }, { 3824, 1 }, { 2321, 2 } }, out = { 4256, 1 }, oq = 2 },
    [3774] = { name = "Green Leather Belt", t = { 1, 155, 165, 175 }, fee = 1000, train = 135, tr = { 3007, 4212, 11098 }, r = { { 4236, 1 }, { 4234, 5 }, { 2321, 1 }, { 2605, 1 }, { 7071, 1 } }, out = { 4257, 1 }, oq = 2 },
    [3775] = { name = "Guardian Belt", t = { 1, 165, 175, 185 }, scroll = 4298, train = 145, sq = 3, r = { { 4236, 2 }, { 4234, 4 }, { 2321, 1 }, { 7071, 1 } }, out = { 4258, 1 }, oq = 2 },
    [3776] = { name = "Green Leather Bracers", t = { 1, 175, 185, 195 }, fee = 1200, train = 155, r = { { 4236, 2 }, { 4234, 6 }, { 2605, 1 }, { 2321, 1 } }, out = { 4259, 1 }, oq = 2 },
    [3777] = { name = "Guardian Leather Bracers", t = { 1, 190, 200, 210 }, scroll = 4300, train = 170, sq = 2, r = { { 4234, 6 }, { 4236, 2 }, { 4291, 1 } }, out = { 4260, 1 }, oq = 2 },
    [3778] = { name = "Gem-studded Leather Belt", t = { 1, 180, 190, 200 }, scroll = 14635, train = 160, scrollPrice = 3000, sq = 1, r = { { 4236, 4 }, { 5500, 2 }, { 1529, 2 }, { 3864, 1 }, { 2321, 1 } }, out = { 4262, 1 }, oq = 3 },
    [3779] = { name = "Barbaric Belt", t = { 1, 195, 205, 215 }, scroll = 4301, train = 175, sq = 3, r = { { 4234, 6 }, { 4236, 2 }, { 4096, 2 }, { 5633, 1 }, { 4291, 1 }, { 7071, 1 } }, out = { 4264, 1 }, oq = 2 },
    [3780] = { name = "Heavy Armor Kit", t = { 1, 145, 155, 165 }, fee = 750, train = 125, r = { { 4234, 5 }, { 2321, 1 } }, out = { 4265, 1 }, oq = 1 },
    [3816] = { name = "Cured Light Hide", t = { 1, 50, 60, 70 }, fee = 50, train = 30, r = { { 783, 1 }, { 4289, 1 } }, out = { 4231, 1 }, oq = 1 },
    [3817] = { name = "Cured Medium Hide", t = { 1, 90, 97, 105 }, fee = 200, train = 75, r = { { 4232, 1 }, { 4289, 1 } }, out = { 4233, 1 }, oq = 1 },
    [3818] = { name = "Cured Heavy Hide", t = { 1, 135, 140, 145 }, fee = 500, train = 125, r = { { 4235, 1 }, { 4289, 3 } }, out = { 4236, 1 }, oq = 1 },
    [4096] = { name = "Raptor Hide Harness", t = { 1, 160, 170, 180 }, scroll = 13287, train = 140, scrollPrice = 2500, sq = 2, r = { { 4461, 6 }, { 4234, 4 }, { 2321, 2 } }, out = { 4455, 1 }, oq = 2 },
    [4097] = { name = "Raptor Hide Belt", t = { 1, 160, 170, 180 }, scroll = 13288, train = 140, scrollPrice = 2500, sq = 2, r = { { 4461, 4 }, { 4234, 4 }, { 2321, 2 } }, out = { 4456, 1 }, oq = 2 },
    [5244] = { name = "Kodo Hide Bag", t = { 1, 65, 80, 95 }, scroll = 5083, train = 35, sq = 2, r = { { 5082, 3 }, { 2318, 4 }, { 2320, 1 } }, out = { 5081, 1 }, oq = 1 },
    [6661] = { name = "Barbaric Harness", t = { 1, 185, 195, 205 }, fee = 1800, train = 165, r = { { 4234, 14 }, { 2321, 2 }, { 7071, 1 } }, out = { 5739, 1 }, oq = 2 },
    [6702] = { name = "Murloc Scale Belt", t = { 1, 95, 110, 125 }, scroll = 5786, train = 65, scrollPrice = 550, sq = 1, r = { { 5784, 8 }, { 2318, 6 }, { 2321, 1 } }, out = { 5780, 1 }, oq = 2 },
    [6703] = { name = "Murloc Scale Breastplate", t = { 1, 100, 115, 130 }, scroll = 5787, train = 70, scrollPrice = 600, sq = 1, r = { { 5784, 12 }, { 4231, 1 }, { 2318, 8 }, { 2321, 1 } }, out = { 5781, 1 }, oq = 2 },
    [6704] = { name = "Thick Murloc Armor", t = { 1, 165, 175, 185 }, scroll = 5788, train = 145, scrollPrice = 650, sq = 2, r = { { 5785, 12 }, { 4236, 1 }, { 4234, 10 }, { 2321, 3 } }, out = { 5782, 1 }, oq = 2 },
    [6705] = { name = "Murloc Scale Bracers", t = { 1, 185, 195, 205 }, scroll = 5789, train = 165, scrollPrice = 2800, sq = 2, r = { { 5785, 16 }, { 4236, 1 }, { 4234, 14 }, { 4291, 1 } }, out = { 5783, 1 }, oq = 2 },
    [7126] = { name = "Handstitched Leather Vest", t = { 1, 40, 55, 70 }, basic = true, r = { { 2318, 3 }, { 2320, 1 } }, out = { 5957, 1 }, oq = 2 },
    [7133] = { name = "Fine Leather Pants", t = { 1, 105, 117, 130 }, scroll = 5972, train = 80, sq = 2, r = { { 2319, 8 }, { 2997, 1 }, { 2321, 1 } }, out = { 5958, 1 }, oq = 2 },
    [7135] = { name = "Dark Leather Pants", t = { 1, 115, 127, 140 }, fee = 400, train = 90, r = { { 2319, 12 }, { 4340, 1 }, { 2321, 1 } }, out = { 5961, 1 }, oq = 2 },
    [7147] = { name = "Guardian Pants", t = { 1, 155, 165, 175 }, fee = 1000, train = 135, tr = { 3007, 4212, 11098 }, r = { { 4234, 12 }, { 4305, 2 }, { 2321, 2 } }, out = { 5962, 1 }, oq = 2 },
    [7149] = { name = "Barbaric Leggings", t = { 1, 165, 175, 185 }, scroll = 5973, train = 145, scrollPrice = 650, sq = 1, r = { { 4234, 10 }, { 2321, 2 }, { 1206, 1 } }, out = { 5963, 1 }, oq = 2 },
    [7151] = { name = "Barbaric Shoulders", t = { 1, 170, 180, 190 }, fee = 1200, train = 150, tr = { 3007, 4212, 11098 }, r = { { 4234, 8 }, { 4236, 1 }, { 2321, 2 } }, out = { 5964, 1 }, oq = 2 },
    [7153] = { name = "Guardian Cloak", t = { 1, 180, 190, 200 }, scroll = 5974, train = 160, sq = 2, r = { { 4234, 14 }, { 4305, 2 }, { 4291, 2 } }, out = { 5965, 1 }, oq = 2 },
    [7156] = { name = "Guardian Gloves", t = { 1, 185, 195, 205 }, fee = 2400, train = 165, r = { { 4234, 4 }, { 4236, 1 }, { 4291, 1 } }, out = { 5966, 1 }, oq = 2 },
    [7953] = { name = "Deviate Scale Cloak", t = { 1, 95, 110, 125 }, scroll = 6474, train = 65, scrollPrice = 550, sq = 1, r = { { 6470, 8 }, { 4231, 1 }, { 2321, 1 } }, out = { 6466, 1 }, oq = 2 },
    [7954] = { name = "Deviate Scale Gloves", t = { 1, 105, 117, 130 }, scroll = 6475, train = 80, scrollPrice = 1500, sq = 1, r = { { 6471, 2 }, { 6470, 6 }, { 2321, 2 } }, out = { 6467, 1 }, oq = 2 },
    [7955] = { name = "Deviate Scale Belt", t = { 1, 115, 127, 140 }, scroll = 6476, train = 90, sq = 2, r = { { 6471, 10 }, { 6470, 10 }, { 2321, 2 } }, out = { 6468, 1 }, oq = 3 },
    [8322] = { name = "Moonglow Vest", t = { 1, 90, 105, 120 }, scroll = 6710, train = 65, sq = 2, r = { { 2318, 6 }, { 4231, 1 }, { 2320, 4 }, { 5498, 1 } }, out = { 6709, 1 }, oq = 2 },
    [9058] = { name = "Handstitched Leather Cloak", t = { 1, 40, 55, 70 }, basic = true, r = { { 2318, 2 }, { 2320, 1 } }, out = { 7276, 1 }, oq = 1 },
    [9059] = { name = "Handstitched Leather Bracers", t = { 1, 40, 55, 70 }, basic = true, r = { { 2318, 2 }, { 2320, 3 } }, out = { 7277, 1 }, oq = 1 },
    [9060] = { name = "Light Leather Quiver", t = { 1, 55, 70, 85 }, fee = 100, train = 25, r = { { 2318, 4 }, { 2320, 2 } }, out = { 7278, 1 }, oq = 1 },
    [9062] = { name = "Small Leather Ammo Pouch", t = { 1, 55, 70, 85 }, fee = 100, train = 25, r = { { 2318, 3 }, { 2320, 4 } }, out = { 7279, 1 }, oq = 1 },
    [9064] = { name = "Rugged Leather Pants", t = { 1, 60, 75, 90 }, scroll = 7288, train = 30, sq = 2, r = { { 2318, 5 }, { 2320, 5 } }, out = { 7280, 1 }, oq = 2 },
    [9065] = { name = "Light Leather Bracers", t = { 1, 75, 90, 105 }, fee = 150, train = 45, r = { { 2318, 6 }, { 2320, 4 } }, out = { 7281, 1 }, oq = 2 },
    [9068] = { name = "Light Leather Pants", t = { 1, 100, 115, 130 }, fee = 400, train = 70, r = { { 2318, 10 }, { 4231, 1 }, { 2321, 1 } }, out = { 7282, 1 }, oq = 2 },
    [9070] = { name = "Black Whelp Cloak", t = { 1, 100, 112, 125 }, scroll = 7289, train = 75, scrollPrice = 650, sq = 1, r = { { 7286, 12 }, { 2319, 4 }, { 2321, 1 } }, out = { 7283, 1 }, oq = 2 },
    [9072] = { name = "Red Whelp Gloves", t = { 1, 120, 132, 145 }, scroll = 7290, train = 95, scrollPrice = 1600, sq = 1, r = { { 7287, 6 }, { 2319, 4 }, { 2321, 1 } }, out = { 7284, 1 }, oq = 2 },
    [9074] = { name = "Nimble Leather Gloves", t = { 1, 120, 132, 145 }, fee = 500, train = 95, r = { { 2457, 1 }, { 2319, 6 }, { 2321, 1 } }, out = { 7285, 1 }, oq = 2 },
    [9145] = { name = "Fletcher's Gloves", t = { 1, 125, 137, 150 }, fee = 500, train = 100, r = { { 2319, 8 }, { 5116, 4 }, { 2321, 2 } }, out = { 7348, 1 }, oq = 2 },
    [9146] = { name = "Herbalist's Gloves", t = { 1, 135, 147, 160 }, scroll = 7361, train = 110, scrollPrice = 1800, sq = 2, r = { { 2319, 8 }, { 3356, 4 }, { 2321, 2 } }, out = { 7349, 1 }, oq = 2 },
    [9147] = { name = "Earthen Leather Shoulders", t = { 1, 135, 147, 160 }, scroll = 7362, train = 110, scrollPrice = 2000, sq = 1, r = { { 2319, 6 }, { 7067, 1 }, { 2321, 2 } }, out = { 7352, 1 }, oq = 2 },
    [9148] = { name = "Pilferer's Gloves", t = { 1, 140, 152, 165 }, scroll = 7363, train = 115, sq = 2, r = { { 2319, 10 }, { 5373, 2 }, { 2321, 2 } }, out = { 7358, 1 }, oq = 2 },
    [9149] = { name = "Heavy Earthen Gloves", t = { 1, 145, 157, 170 }, scroll = 7364, train = 120, sq = 2, r = { { 2319, 12 }, { 7067, 2 }, { 2997, 2 }, { 2321, 2 } }, out = { 7359, 1 }, oq = 2 },
    [9193] = { name = "Heavy Quiver", t = { 1, 145, 155, 165 }, fee = 500, train = 125, r = { { 4234, 8 }, { 2321, 2 } }, out = { 7371, 1 }, oq = 2 },
    [9194] = { name = "Heavy Leather Ammo Pouch", t = { 1, 145, 155, 165 }, fee = 500, train = 125, r = { { 4234, 8 }, { 2321, 2 } }, out = { 7372, 1 }, oq = 2 },
    [9195] = { name = "Dusky Leather Leggings", t = { 1, 160, 170, 180 }, scroll = 7449, train = 140, sq = 2, r = { { 4234, 10 }, { 2325, 1 }, { 2321, 2 } }, out = { 7373, 1 }, oq = 2 },
    [9196] = { name = "Dusky Leather Armor", t = { 1, 170, 180, 190 }, fee = 1500, train = 150, tr = { 3007, 4212, 11098 }, r = { { 4234, 10 }, { 3824, 1 }, { 2321, 2 } }, out = { 7374, 1 }, oq = 2 },
    [9197] = { name = "Green Whelp Armor", t = { 1, 170, 180, 190 }, scroll = 7450, train = 150, sq = 2, r = { { 7392, 4 }, { 4234, 10 }, { 2321, 2 } }, out = { 7375, 1 }, oq = 2 },
    [9198] = { name = "Frost Leather Cloak", t = { 1, 175, 185, 195 }, fee = 2000, train = 155, r = { { 4234, 6 }, { 7067, 2 }, { 7070, 2 }, { 2321, 2 } }, out = { 7377, 1 }, oq = 2 },
    [9201] = { name = "Dusky Bracers", t = { 1, 180, 190, 200 }, fee = 2000, train = 160, r = { { 4234, 16 }, { 2325, 1 }, { 4291, 2 } }, out = { 7378, 1 }, oq = 2 },
    [9202] = { name = "Green Whelp Bracers", t = { 1, 185, 195, 205 }, scroll = 7451, train = 165, scrollPrice = 2800, sq = 2, r = { { 7392, 6 }, { 4234, 8 }, { 4291, 2 } }, out = { 7386, 1 }, oq = 2 },
    [9206] = { name = "Dusky Belt", t = { 1, 190, 200, 210 }, fee = 2500, train = 170, r = { { 4234, 10 }, { 4305, 2 }, { 2325, 2 }, { 7071, 1 } }, out = { 7387, 1 }, oq = 2 },
    [9207] = { name = "Dusky Boots", t = { 1, 195, 205, 215 }, scroll = 7452, train = 175, sq = 3, r = { { 4234, 8 }, { 7428, 2 }, { 3824, 1 }, { 4291, 2 } }, out = { 7390, 1 }, oq = 2 },
    [9208] = { name = "Swift Boots", t = { 1, 195, 205, 215 }, scroll = 7453, train = 175, sq = 2, r = { { 4234, 10 }, { 2459, 2 }, { 4337, 2 }, { 4291, 1 } }, out = { 7391, 1 }, oq = 2 },
    [10487] = { name = "Thick Armor Kit", t = { 1, 195, 205, 215 }, fee = 2000, train = 175, r = { { 4304, 5 }, { 4291, 1 } }, out = { 8173, 1 }, oq = 1 },
    [10490] = { name = "Comfortable Leather Hat", t = { 1, 195, 205, 215 }, scroll = 8384, train = 175, sq = 3, r = { { 4234, 12 }, { 4236, 2 }, { 4291, 2 } }, out = { 8174, 1 }, oq = 2 },
    [10499] = { name = "Nightscape Tunic", t = { 1, 200, 210, 220 }, fee = 3000, train = 180, r = { { 4304, 7 }, { 4291, 2 } }, out = { 8175, 1 }, oq = 2 },
    [10507] = { name = "Nightscape Headband", t = { 1, 200, 210, 220 }, fee = 3000, train = 180, r = { { 4304, 5 }, { 4291, 2 } }, out = { 8176, 1 }, oq = 2 },
    [10509] = { name = "Turtle Scale Gloves", t = { 1, 200, 210, 220 }, scroll = 8385, train = 180, scrollPrice = 3500, sq = 1, r = { { 4304, 6 }, { 8167, 8 }, { 8343, 1 } }, out = { 8187, 1 }, oq = 2 },
    [10511] = { name = "Turtle Scale Breastplate", t = { 1, 205, 215, 225 }, fee = 3000, train = 185, r = { { 4304, 6 }, { 8167, 12 }, { 8343, 1 } }, out = { 8189, 1 }, oq = 2 },
    [10516] = { name = "Nightscape Shoulders", t = { 1, 205, 215, 225 }, scroll = 8409, train = 185, scrollPrice = 4000, sq = 2, r = { { 4304, 8 }, { 4338, 6 }, { 4291, 3 } }, out = { 8192, 1 }, oq = 2 },
    [10518] = { name = "Turtle Scale Bracers", t = { 1, 205, 215, 225 }, fee = 3500, train = 185, r = { { 4304, 8 }, { 8167, 12 }, { 8343, 1 } }, out = { 8198, 1 }, oq = 2 },
    [10520] = { name = "Big Voodoo Robe", t = { 1, 210, 220, 230 }, scroll = 8386, train = 190, sq = 2, r = { { 4304, 10 }, { 8151, 4 }, { 8343, 1 } }, out = { 8200, 1 }, oq = 2 },
    [10525] = { name = "Tough Scorpid Breastplate", t = { 1, 215, 225, 235 }, scroll = 8395, train = 195, sq = 2, r = { { 4304, 12 }, { 8154, 12 }, { 4291, 4 } }, out = { 8203, 1 }, oq = 2 },
    [10529] = { name = "Wild Leather Shoulders", t = { 1, 215, 225, 235 }, scroll = 8403, train = 195, sq = 2, r = { { 4304, 10 }, { 8153, 1 }, { 8172, 1 } }, out = { 8210, 1 }, oq = 2 },
    [10531] = { name = "Big Voodoo Mask", t = { 1, 215, 225, 235 }, scroll = 8387, train = 195, sq = 2, r = { { 4304, 8 }, { 8151, 6 }, { 8343, 1 } }, out = { 8201, 1 }, oq = 2 },
    [10533] = { name = "Tough Scorpid Bracers", t = { 1, 215, 225, 235 }, scroll = 8397, train = 195, sq = 2, r = { { 4304, 10 }, { 8154, 4 }, { 4291, 2 } }, out = { 8205, 1 }, oq = 2 },
    [10542] = { name = "Tough Scorpid Gloves", t = { 1, 220, 230, 240 }, scroll = 8398, train = 200, sq = 2, r = { { 4304, 6 }, { 8154, 8 }, { 4291, 2 } }, out = { 8204, 1 }, oq = 2 },
    [10544] = { name = "Wild Leather Vest", t = { 1, 220, 230, 240 }, scroll = 8404, train = 200, sq = 2, r = { { 4304, 12 }, { 8153, 2 }, { 8172, 1 } }, out = { 8211, 1 }, oq = 2 },
    [10546] = { name = "Wild Leather Helmet", t = { 1, 220, 230, 240 }, scroll = 8405, train = 200, sq = 2, r = { { 4304, 10 }, { 8153, 2 }, { 8172, 1 } }, out = { 8214, 1 }, oq = 2 },
    [10548] = { name = "Nightscape Pants", t = { 1, 225, 235, 245 }, fee = 4000, train = 205, tr = { 11098 }, r = { { 4304, 14 }, { 4291, 4 } }, out = { 8193, 1 }, oq = 2 },
    [10550] = { name = "Nightscape Cloak", t = { 1, 225, 235, 245 }, scroll = 8388, train = 205, sq = 2, r = { { 4304, 12 }, { 4291, 4 } }, out = { 8195, 1 }, oq = 2 },
    [10552] = { name = "Turtle Scale Helm", t = { 1, 225, 235, 245 }, fee = 4000, train = 205, tr = { 11098 }, r = { { 4304, 14 }, { 8167, 24 }, { 8343, 1 } }, out = { 8191, 1 }, oq = 2 },
    [10554] = { name = "Tough Scorpid Boots", t = { 1, 230, 240, 250 }, scroll = 8399, train = 210, sq = 2, r = { { 4304, 12 }, { 8154, 12 }, { 4291, 6 } }, out = { 8209, 1 }, oq = 2 },
    [10556] = { name = "Turtle Scale Leggings", t = { 1, 230, 240, 250 }, fee = 4500, train = 210, tr = { 11098 }, r = { { 4304, 14 }, { 8167, 28 }, { 8343, 1 } }, out = { 8185, 1 }, oq = 2 },
    [10558] = { name = "Nightscape Boots", t = { 1, 230, 240, 250 }, fee = 4500, train = 210, tr = { 11098 }, r = { { 4304, 16 }, { 8343, 2 } }, out = { 8197, 1 }, oq = 2 },
    [10560] = { name = "Big Voodoo Pants", t = { 1, 230, 240, 250 }, scroll = 8389, train = 215, sq = 2, r = { { 4304, 10 }, { 8152, 6 }, { 8343, 2 } }, out = { 8202, 1 }, oq = 2 },
    [10562] = { name = "Big Voodoo Cloak", t = { 1, 235, 245, 255 }, scroll = 8390, train = 215, sq = 2, r = { { 4304, 14 }, { 8152, 4 }, { 8343, 2 } }, out = { 8216, 1 }, oq = 2 },
    [10564] = { name = "Tough Scorpid Shoulders", t = { 1, 235, 245, 255 }, scroll = 8400, train = 215, sq = 2, r = { { 4304, 12 }, { 8154, 16 }, { 8343, 2 } }, out = { 8207, 1 }, oq = 2 },
    [10566] = { name = "Wild Leather Boots", t = { 1, 240, 250, 260 }, scroll = 8406, train = 220, sq = 2, r = { { 4304, 14 }, { 8153, 4 }, { 8172, 2 } }, out = { 8213, 1 }, oq = 2 },
    [10568] = { name = "Tough Scorpid Leggings", t = { 1, 240, 250, 260 }, scroll = 8401, train = 220, sq = 2, r = { { 4304, 14 }, { 8154, 8 }, { 8343, 2 } }, out = { 8206, 1 }, oq = 2 },
    [10570] = { name = "Tough Scorpid Helm", t = { 1, 245, 255, 265 }, scroll = 8402, train = 225, sq = 2, r = { { 4304, 10 }, { 8154, 20 }, { 8343, 2 } }, out = { 8208, 1 }, oq = 2 },
    [10572] = { name = "Wild Leather Leggings", t = { 1, 245, 255, 265 }, scroll = 8407, train = 225, sq = 2, r = { { 4304, 16 }, { 8153, 2 }, { 8172, 2 } }, out = { 8212, 1 }, oq = 2 },
    [10574] = { name = "Wild Leather Cloak", t = { 1, 245, 255, 265 }, scroll = 8408, train = 225, sq = 2, r = { { 4304, 16 }, { 8153, 2 }, { 8172, 2 } }, out = { 8215, 1 }, oq = 2 },
    [10619] = { name = "Dragonscale Gauntlets", t = { 1, 220, 230, 240 }, fee = 9000, train = 225, tr = { 7867 }, r = { { 4304, 24 }, { 8165, 12 }, { 8343, 4 }, { 8172, 2 } }, out = { 8347, 1 }, oq = 3 },
    [10621] = { name = "Wolfshead Helm", t = { 1, 220, 230, 240 }, gone = true, r = { { 4304, 18 }, { 8368, 2 }, { 8146, 8 }, { 8343, 4 }, { 8172, 2 } }, out = { 8345, 1 }, oq = 3 },
    [10630] = { name = "Gauntlets of the Sea", t = { 1, 225, 235, 245 }, gone = true, r = { { 4304, 20 }, { 7079, 8 }, { 7075, 2 }, { 8172, 1 }, { 8343, 4 } }, out = { 8346, 1 }, oq = 3 },
    [10632] = { name = "Helm of Fire", t = { 1, 245, 255, 265 }, gone = true, r = { { 4304, 40 }, { 7077, 8 }, { 7075, 4 }, { 8172, 2 }, { 8343, 4 } }, out = { 8348, 1 }, oq = 3 },
    [10647] = { name = "Feathered Breastplate", t = { 1, 245, 255, 265 }, gone = true, r = { { 4304, 40 }, { 8168, 40 }, { 7971, 2 }, { 8172, 4 }, { 8343, 4 } }, out = { 8349, 1 }, oq = 3 },
    [10650] = { name = "Dragonscale Breastplate", t = { 1, 250, 260, 270 }, fee = 9000, train = 255, tr = { 7867 }, r = { { 4304, 40 }, { 8165, 30 }, { 8343, 4 }, { 8172, 4 } }, out = { 8367, 1 }, oq = 3 },
    [14930] = { name = "Quickdraw Quiver", t = { 1, 220, 230, 240 }, fee = 3600, train = 200, r = { { 4304, 12 }, { 8172, 1 }, { 8949, 1 }, { 4291, 4 } }, out = { 8217, 1 }, oq = 2 },
    [14932] = { name = "Thick Leather Ammo Pouch", t = { 1, 220, 230, 240 }, fee = 3600, train = 200, r = { { 4304, 10 }, { 8172, 1 }, { 8951, 1 }, { 4291, 6 } }, out = { 8218, 1 }, oq = 2 },
    [16650] = { name = "Wildthorn Mail", t = { 1, 265, 275, 285 }, scroll = 12691, train = 245, sq = 2, r = { { 8170, 40 }, { 12810, 2 }, { 12803, 4 }, { 8153, 4 }, { 12364, 1 }, { 14341, 1 } }, out = { 12624, 1 }, oq = 3 },
    [16661] = { name = "Storm Gauntlets", t = { 1, 290, 300, 310 }, scroll = 12703, train = 270, scrollPrice = 40000, sq = 3, r = { { 8170, 20 }, { 12810, 4 }, { 7080, 4 }, { 12361, 4 }, { 14341, 1 } }, out = { 12632, 1 }, oq = 3 },
    [16728] = { name = "Helm of the Great Chief", t = { 1, 290, 300, 310 }, scroll = 12716, train = 290, sq = 3, r = { { 8170, 40 }, { 12810, 4 }, { 8168, 60 }, { 12799, 6 }, { 12364, 2 }, { 14341, 1 } }, out = { 12636, 1 }, oq = 3 },
    [16746] = { name = "Invulnerable Mail", t = { 1, 295, 302, 310 }, scroll = 12728, train = 295, sq = 4, r = { { 249427, 20 }, { 12810, 30 }, { 12364, 6 }, { 12800, 6 }, { 249429, 10 }, { 14341, 2 } }, out = { 12641, 1 }, oq = 4 },
    [19047] = { name = "Cured Rugged Hide", t = { 1, 225, 230, 235 }, fee = 5000, train = 225, tr = { 11098 }, r = { { 8171, 1 }, { 15409, 1 } }, out = { 15407, 2 }, oq = 1 },
    [19048] = { name = "Heavy Scorpid Bracers", t = { 1, 250, 260, 270 }, scroll = 15724, train = 255, scrollPrice = 12000, sq = 1, r = { { 8170, 4 }, { 15408, 4 }, { 14341, 1 } }, out = { 15077, 1 }, oq = 2 },
    [19049] = { name = "Wicked Leather Gauntlets", t = { 1, 255, 265, 275 }, scroll = 15725, train = 235, scrollPrice = 12000, sq = 1, r = { { 8170, 8 }, { 2325, 1 }, { 14341, 1 } }, out = { 15083, 1 }, oq = 2 },
    [19050] = { name = "Green Dragonscale Breastplate", t = { 1, 255, 265, 275 }, scroll = 15726, train = 235, scrollPrice = 12000, sq = 1, r = { { 8170, 20 }, { 15412, 25 }, { 14341, 2 } }, out = { 15045, 1 }, oq = 3 },
    [19051] = { name = "Heavy Scorpid Vest", t = { 1, 260, 270, 280 }, scroll = 15727, train = 240, sq = 2, r = { { 8170, 6 }, { 15408, 6 }, { 14341, 1 } }, out = { 15076, 1 }, oq = 2 },
    [19052] = { name = "Wicked Leather Bracers", t = { 1, 260, 270, 280 }, scroll = 15728, train = 240, sq = 2, r = { { 8170, 8 }, { 2325, 1 }, { 14341, 1 } }, out = { 15084, 1 }, oq = 2 },
    [19053] = { name = "Chimeric Gloves", t = { 1, 260, 270, 280 }, scroll = 15729, train = 240, scrollPrice = 12000, sq = 1, r = { { 8170, 6 }, { 15423, 6 }, { 14341, 1 } }, out = { 15074, 1 }, oq = 2 },
    [19054] = { name = "Red Dragonscale Breastplate", t = { 1, 310, 320, 330 }, scroll = 15730, train = 290, sq = 3, r = { { 8170, 40 }, { 15414, 30 }, { 14341, 1 } }, out = { 15047, 1 }, oq = 3 },
    [19055] = { name = "Runic Leather Gauntlets", t = { 1, 265, 275, 285 }, scroll = 15731, train = 245, sq = 2, r = { { 8170, 10 }, { 14047, 6 }, { 14341, 1 } }, out = { 15091, 1 }, oq = 2 },
    [19058] = { name = "Rugged Armor Kit", t = { 1, 225, 235, 245 }, fee = 5000, train = 225, tr = { 11098 }, r = { { 8170, 5 } }, out = { 15564, 1 }, oq = 1 },
    [19059] = { name = "Volcanic Leggings", t = { 1, 265, 275, 285 }, scroll = 15732, train = 245, sq = 2, r = { { 8170, 6 }, { 7078, 1 }, { 7075, 1 }, { 14341, 1 } }, out = { 15054, 1 }, oq = 2 },
    [19060] = { name = "Green Dragonscale Leggings", t = { 1, 265, 275, 285 }, scroll = 15733, train = 245, sq = 3, r = { { 8170, 20 }, { 15412, 25 }, { 14341, 1 } }, out = { 15046, 1 }, oq = 3 },
    [19061] = { name = "Living Shoulders", t = { 1, 265, 275, 285 }, scroll = 15734, train = 245, scrollPrice = 14000, sq = 1, r = { { 8170, 12 }, { 12803, 4 }, { 14341, 1 } }, out = { 15061, 1 }, oq = 3 },
    [19062] = { name = "Ironfeather Shoulders", t = { 1, 265, 275, 285 }, scroll = 15735, train = 245, scrollPrice = 14000, sq = 1, r = { { 8170, 24 }, { 15420, 80 }, { 1529, 2 }, { 14341, 1 } }, out = { 15067, 1 }, oq = 3 },
    [19063] = { name = "Chimeric Boots", t = { 1, 270, 280, 290 }, scroll = 15737, train = 250, sq = 2, r = { { 8170, 4 }, { 15423, 8 }, { 14341, 1 } }, out = { 15073, 1 }, oq = 2 },
    [19064] = { name = "Heavy Scorpid Gauntlets", t = { 1, 270, 280, 290 }, scroll = 15738, train = 250, sq = 2, r = { { 8170, 6 }, { 15408, 8 }, { 14341, 1 } }, out = { 15078, 1 }, oq = 2 },
    [19065] = { name = "Runic Leather Bracers", t = { 1, 270, 280, 290 }, scroll = 15739, train = 250, sq = 2, r = { { 8170, 6 }, { 7971, 1 }, { 14047, 6 }, { 14341, 1 } }, out = { 15092, 1 }, oq = 2 },
    [19066] = { name = "Frostsaber Boots", t = { 1, 270, 280, 290 }, scroll = 15740, train = 250, scrollPrice = 16000, sq = 1, r = { { 8170, 4 }, { 15422, 6 }, { 14341, 1 } }, out = { 15071, 1 }, oq = 2 },
    [19067] = { name = "Stormshroud Pants", t = { 1, 270, 280, 290 }, scroll = 15741, train = 250, scrollPrice = 16000, sq = 1, r = { { 8170, 16 }, { 7080, 2 }, { 7082, 2 }, { 14341, 1 } }, out = { 15057, 1 }, oq = 3 },
    [19068] = { name = "Warbear Harness", t = { 1, 270, 280, 290 }, scroll = 20253, train = 250, scrollPrice = 16000, rep = { 576, 4 }, sq = 1, r = { { 8170, 28 }, { 15419, 12 }, { 14341, 1 } }, out = { 15064, 1 }, oq = 3 },
    [19070] = { name = "Heavy Scorpid Belt", t = { 1, 275, 285, 295 }, scroll = 15743, train = 255, sq = 2, r = { { 8170, 6 }, { 15408, 8 }, { 14341, 1 } }, out = { 15082, 1 }, oq = 2 },
    [19071] = { name = "Wicked Leather Headband", t = { 1, 275, 285, 295 }, scroll = 15744, train = 255, sq = 2, r = { { 8170, 12 }, { 2325, 1 }, { 14341, 1 } }, out = { 15086, 1 }, oq = 2 },
    [19072] = { name = "Runic Leather Belt", t = { 1, 275, 285, 295 }, scroll = 15745, train = 255, sq = 2, r = { { 8170, 12 }, { 14047, 10 }, { 14341, 1 } }, out = { 15093, 1 }, oq = 2 },
    [19073] = { name = "Chimeric Leggings", t = { 1, 275, 285, 295 }, scroll = 15746, train = 255, sq = 2, r = { { 8170, 8 }, { 15423, 8 }, { 14341, 1 } }, out = { 15072, 1 }, oq = 2 },
    [19074] = { name = "Frostsaber Leggings", t = { 1, 280, 290, 300 }, scroll = 15747, train = 260, sq = 2, r = { { 8170, 6 }, { 15422, 8 }, { 14341, 1 } }, out = { 15069, 1 }, oq = 2 },
    [19075] = { name = "Heavy Scorpid Leggings", t = { 1, 280, 290, 300 }, scroll = 15748, train = 260, sq = 2, r = { { 8170, 8 }, { 15408, 12 }, { 14341, 1 } }, out = { 15079, 1 }, oq = 2 },
    [19076] = { name = "Volcanic Breastplate", t = { 1, 280, 290, 300 }, scroll = 15749, train = 260, sq = 2, r = { { 8170, 8 }, { 7078, 1 }, { 7076, 1 }, { 14341, 1 } }, out = { 15053, 1 }, oq = 2 },
    [19077] = { name = "Blue Dragonscale Breastplate", t = { 1, 280, 290, 300 }, scroll = 15751, train = 260, scrollPrice = 20000, sq = 1, r = { { 8170, 28 }, { 15415, 30 }, { 15407, 1 }, { 14341, 1 } }, out = { 15048, 1 }, oq = 3 },
    [19078] = { name = "Living Leggings", t = { 1, 280, 290, 300 }, scroll = 15752, train = 260, sq = 3, r = { { 8170, 16 }, { 12803, 6 }, { 15407, 1 }, { 14341, 1 } }, out = { 15060, 1 }, oq = 3 },
    [19079] = { name = "Stormshroud Armor", t = { 1, 280, 290, 300 }, scroll = 15753, train = 260, sq = 3, r = { { 8170, 16 }, { 7080, 3 }, { 7082, 3 }, { 15407, 1 }, { 14341, 1 } }, out = { 15056, 1 }, oq = 3 },
    [19080] = { name = "Warbear Woolies", t = { 1, 280, 290, 300 }, scroll = 20254, train = 260, scrollPrice = 20000, rep = { 576, 4 }, sq = 1, r = { { 8170, 24 }, { 15419, 14 }, { 14341, 1 } }, out = { 15065, 1 }, oq = 3 },
    [19081] = { name = "Chimeric Vest", t = { 1, 285, 295, 305 }, scroll = 15755, train = 265, sq = 2, r = { { 8170, 10 }, { 15423, 10 }, { 14341, 1 } }, out = { 15075, 1 }, oq = 2 },
    [19082] = { name = "Runic Leather Headband", t = { 1, 285, 295, 305 }, scroll = 15756, train = 265, scrollPrice = 22000, sq = 1, r = { { 8170, 14 }, { 14047, 10 }, { 14341, 1 } }, out = { 15094, 1 }, oq = 2 },
    [19083] = { name = "Wicked Leather Pants", t = { 1, 285, 295, 305 }, scroll = 15757, train = 265, sq = 2, r = { { 8170, 16 }, { 15407, 1 }, { 2325, 3 }, { 14341, 1 } }, out = { 15087, 1 }, oq = 2 },
    [19084] = { name = "Devilsaur Gauntlets", t = { 1, 285, 295, 305 }, scroll = 15758, train = 265, scrollPrice = 22000, sq = 1, r = { { 8170, 30 }, { 15417, 8 }, { 14341, 1 } }, out = { 15063, 1 }, oq = 3 },
    [19085] = { name = "Black Dragonscale Breastplate", t = { 1, 285, 295, 305 }, scroll = 15759, train = 265, sq = 1, r = { { 8170, 40 }, { 15416, 60 }, { 15407, 1 }, { 14341, 2 } }, out = { 15050, 1 }, oq = 3 },
    [19086] = { name = "Ironfeather Breastplate", t = { 1, 285, 295, 305 }, scroll = 15760, train = 265, sq = 3, r = { { 8170, 40 }, { 15420, 120 }, { 1529, 1 }, { 15407, 1 }, { 14341, 1 } }, out = { 15066, 1 }, oq = 3 },
    [19087] = { name = "Frostsaber Gloves", t = { 1, 290, 300, 310 }, scroll = 15761, train = 270, sq = 2, r = { { 8170, 6 }, { 15422, 10 }, { 14341, 1 } }, out = { 15070, 1 }, oq = 2 },
    [19088] = { name = "Heavy Scorpid Helm", t = { 1, 290, 300, 310 }, scroll = 15762, train = 270, scrollPrice = 25000, sq = 1, r = { { 8170, 8 }, { 15408, 12 }, { 15407, 1 }, { 14341, 1 } }, out = { 15080, 1 }, oq = 2 },
    [19089] = { name = "Blue Dragonscale Shoulders", t = { 1, 290, 300, 310 }, scroll = 15763, train = 270, sq = 3, r = { { 8170, 28 }, { 15415, 30 }, { 12810, 2 }, { 15407, 1 }, { 14341, 1 } }, out = { 15049, 1 }, oq = 3 },
    [19090] = { name = "Stormshroud Shoulders", t = { 1, 290, 300, 310 }, scroll = 15764, train = 270, sq = 3, r = { { 8170, 12 }, { 7080, 3 }, { 7082, 3 }, { 12810, 2 }, { 14341, 1 } }, out = { 15058, 1 }, oq = 3 },
    [19091] = { name = "Runic Leather Pants", t = { 1, 295, 305, 315 }, scroll = 15765, train = 275, sq = 2, r = { { 8170, 18 }, { 14047, 12 }, { 12810, 2 }, { 14341, 1 } }, out = { 15095, 1 }, oq = 2 },
    [19092] = { name = "Wicked Leather Belt", t = { 1, 295, 305, 315 }, scroll = 15768, train = 275, sq = 2, r = { { 8170, 14 }, { 2325, 2 }, { 14341, 2 } }, out = { 15088, 1 }, oq = 2 },
    [19093] = { name = "Onyxia Scale Cloak", t = { 1, 320, 330, 340 }, scroll = 15769, train = 310, sq = 1, r = { { 15410, 1 }, { 14044, 1 }, { 14341, 1 } }, out = { 15138, 1 }, oq = 3 },
    [19094] = { name = "Black Dragonscale Shoulders", t = { 1, 310, 320, 330 }, scroll = 15770, train = 270, sq = 3, r = { { 8170, 44 }, { 15416, 45 }, { 12810, 2 }, { 15407, 1 }, { 14341, 1 } }, out = { 15051, 1 }, oq = 3 },
    [19095] = { name = "Living Breastplate", t = { 1, 310, 320, 330 }, scroll = 15771, train = 290, sq = 3, r = { { 8170, 16 }, { 12803, 8 }, { 14342, 2 }, { 15407, 1 }, { 14341, 2 } }, out = { 15059, 1 }, oq = 3 },
    [19097] = { name = "Devilsaur Leggings", t = { 1, 310, 320, 330 }, scroll = 15772, train = 290, sq = 3, r = { { 8170, 30 }, { 15417, 14 }, { 15407, 1 }, { 14341, 1 } }, out = { 15062, 1 }, oq = 3 },
    [19098] = { name = "Wicked Leather Armor", t = { 1, 300, 310, 320 }, scroll = 15773, train = 280, sq = 2, r = { { 8170, 20 }, { 15407, 2 }, { 14256, 6 }, { 2325, 4 }, { 14341, 2 } }, out = { 15085, 1 }, oq = 2 },
    [19100] = { name = "Heavy Scorpid Shoulders", t = { 1, 300, 310, 320 }, scroll = 15774, train = 280, sq = 2, r = { { 8170, 14 }, { 15408, 14 }, { 15407, 1 }, { 14341, 2 } }, out = { 15081, 1 }, oq = 2 },
    [19101] = { name = "Volcanic Shoulders", t = { 1, 300, 310, 320 }, scroll = 15775, train = 280, sq = 2, r = { { 8170, 10 }, { 7078, 1 }, { 7076, 1 }, { 14341, 2 } }, out = { 15055, 1 }, oq = 2 },
    [19102] = { name = "Runic Leather Armor", t = { 1, 305, 315, 325 }, scroll = 15776, train = 285, sq = 2, r = { { 8170, 22 }, { 12810, 4 }, { 14047, 16 }, { 15407, 1 }, { 14341, 2 } }, out = { 15090, 1 }, oq = 2 },
    [19103] = { name = "Runic Leather Shoulders", t = { 1, 305, 315, 325 }, scroll = 15777, train = 285, sq = 2, r = { { 8170, 16 }, { 12810, 4 }, { 14047, 18 }, { 15407, 1 }, { 14341, 2 } }, out = { 15096, 1 }, oq = 2 },
    [19104] = { name = "Frostsaber Tunic", t = { 1, 310, 320, 330 }, scroll = 15779, train = 290, sq = 2, r = { { 8170, 12 }, { 15422, 12 }, { 15407, 1 }, { 14341, 2 } }, out = { 15068, 1 }, oq = 2 },
    [19106] = { name = "Onyxia Scale Breastplate", t = { 1, 320, 330, 340 }, scroll = 15780, train = 310, sq = 1, r = { { 8170, 40 }, { 15410, 12 }, { 15416, 60 }, { 14341, 2 } }, out = { 15141, 1 }, oq = 4 },
    [19107] = { name = "Black Dragonscale Leggings", t = { 1, 310, 320, 330 }, scroll = 15781, train = 290, sq = 3, r = { { 8170, 40 }, { 15416, 60 }, { 12810, 4 }, { 15407, 1 }, { 14341, 2 } }, out = { 15052, 1 }, oq = 3 },
    [20648] = { name = "Medium Leather", t = { 1, 75, 80, 85 }, fee = 500, train = 75, r = { { 2318, 4 } }, out = { 2319, 1 }, oq = 1 },
    [20649] = { name = "Heavy Leather", t = { 1, 125, 130, 135 }, fee = 1000, train = 125, r = { { 2319, 5 } }, out = { 4234, 1 }, oq = 1 },
    [20650] = { name = "Thick Leather", t = { 1, 175, 177, 180 }, fee = 4000, train = 175, r = { { 4234, 6 } }, out = { 4304, 1 }, oq = 1 },
    [20853] = { name = "Corehound Boots", t = { 1, 315, 325, 335 }, scroll = 17022, train = 295, rep = { 59, 4 }, sq = 1, r = { { 17012, 20 }, { 17010, 6 }, { 17011, 2 }, { 14341, 2 } }, out = { 16982, 1 }, oq = 4 },
    [20854] = { name = "Molten Helm", t = { 1, 320, 330, 340 }, scroll = 17023, train = 300, rep = { 59, 4 }, sq = 1, r = { { 17012, 15 }, { 17010, 3 }, { 17011, 6 }, { 14341, 2 } }, out = { 16983, 1 }, oq = 4 },
    [20855] = { name = "Black Dragonscale Boots", t = { 1, 320, 330, 340 }, scroll = 17025, train = 300, rep = { 59, 5 }, sq = 1, r = { { 12810, 6 }, { 15416, 30 }, { 17010, 4 }, { 17011, 3 }, { 14341, 2 } }, out = { 16984, 1 }, oq = 4 },
    [21943] = { name = "Gloves of the Greatfather", t = { 1, 185, 195, 205 }, scroll = 17722, train = 165, sq = 2, r = { { 4234, 8 }, { 7067, 4 }, { 4291, 1 } }, out = { 17721, 1 }, oq = 2 },
    [22711] = { name = "Shadowskin Gloves", t = { 1, 185, 195, 205 }, scroll = 18239, train = 175, scrollPrice = 3500, sq = 1, r = { { 4304, 6 }, { 7428, 8 }, { 7971, 2 }, { 4236, 2 }, { 1210, 4 }, { 8343, 1 } }, out = { 18238, 1 }, oq = 3 },
    [22727] = { name = "Core Armor Kit", t = { 1, 320, 330, 340 }, scroll = 18252, train = 300, sq = 3, r = { { 17012, 3 }, { 14341, 2 } }, out = { 18251, 1 }, oq = 3 },
    [22815] = { name = "Gordok Ogre Suit", t = { 1, 285, 290, 295 }, r = { { 8170, 4 }, { 14048, 2 }, { 18240, 1 }, { 14341, 1 } }, out = { 18258, 1 }, oq = 2 },
    [22921] = { name = "Girdle of Insight", t = { 1, 310, 320, 330 }, scroll = 18514, train = 290, sq = 3, r = { { 8170, 12 }, { 12804, 12 }, { 15407, 2 }, { 14341, 4 } }, out = { 18504, 1 }, oq = 3 },
    [22922] = { name = "Mongoose Boots", t = { 1, 310, 320, 330 }, scroll = 18515, train = 290, sq = 3, r = { { 8170, 12 }, { 7082, 6 }, { 11754, 4 }, { 15407, 2 }, { 14341, 4 } }, out = { 18506, 1 }, oq = 3 },
    [22923] = { name = "Swift Flight Bracers", t = { 1, 310, 320, 330 }, scroll = 18516, train = 290, sq = 3, r = { { 8170, 12 }, { 18512, 8 }, { 15420, 60 }, { 15407, 4 }, { 14341, 4 } }, out = { 18508, 1 }, oq = 3 },
    [22926] = { name = "Chromatic Cloak", t = { 1, 320, 330, 340 }, scroll = 18517, train = 300, sq = 4, r = { { 8170, 30 }, { 12607, 12 }, { 15416, 30 }, { 15414, 30 }, { 15407, 5 }, { 14341, 8 } }, out = { 18509, 1 }, oq = 4 },
    [22927] = { name = "Hide of the Wild", t = { 1, 320, 330, 340 }, scroll = 18518, train = 300, sq = 4, r = { { 8170, 30 }, { 12803, 12 }, { 7080, 10 }, { 18512, 8 }, { 15407, 3 }, { 14341, 8 } }, out = { 18510, 1 }, oq = 4 },
    [22928] = { name = "Shifting Cloak", t = { 1, 320, 330, 340 }, scroll = 18519, train = 300, sq = 4, r = { { 8170, 30 }, { 7082, 12 }, { 12753, 4 }, { 12809, 8 }, { 15407, 4 }, { 14341, 8 } }, out = { 18511, 1 }, oq = 4 },
    [23190] = { name = "Heavy Leather Ball", t = { 1, 125, 130, 135 }, scroll = 18731, train = 125, scrollPrice = 2000, sq = 1, r = { { 4234, 2 }, { 2321, 1 } }, out = { 18662, 1 }, oq = 1 },
    [23399] = { name = "Barbaric Bracers", t = { 1, 155, 165, 175 }, scroll = 18949, train = 130, scrollPrice = 2000, sq = 1, r = { { 4234, 8 }, { 4236, 2 }, { 5498, 4 }, { 4461, 1 }, { 5637, 4 } }, out = { 18948, 1 }, oq = 3 },
    [23628] = { name = "Heavy Timbermaw Belt", t = { 1, 285, 295, 305 }, scroll = 19202, train = 265, scrollPrice = 22000, rep = { 576, 5 }, sq = 1, r = { { 8170, 12 }, { 7076, 3 }, { 12803, 3 }, { 14341, 1 } }, out = { 19043, 1 }, oq = 3 },
    [23629] = { name = "Heavy Timbermaw Boots", t = { 1, 300, 310, 320 }, scroll = 19204, train = 295, scrollPrice = 40000, rep = { 576, 6 }, sq = 1, r = { { 8170, 20 }, { 7076, 6 }, { 12803, 6 }, { 14341, 1 } }, out = { 19048, 1 }, oq = 3 },
    [23703] = { name = "Might of the Timbermaw", t = { 1, 285, 295, 305 }, scroll = 19326, train = 265, scrollPrice = 22000, rep = { 576, 5 }, sq = 1, r = { { 8170, 30 }, { 12804, 2 }, { 12803, 4 }, { 15407, 2 }, { 14341, 2 } }, out = { 19044, 1 }, oq = 3 },
    [23704] = { name = "Timbermaw Brawlers", t = { 1, 315, 325, 335 }, scroll = 19327, train = 295, scrollPrice = 40000, rep = { 576, 6 }, sq = 1, r = { { 12810, 8 }, { 12804, 6 }, { 12803, 6 }, { 15407, 2 }, { 14227, 2 } }, out = { 19049, 1 }, oq = 3 },
    [23705] = { name = "Dawn Treaders", t = { 1, 285, 295, 305 }, scroll = 19328, train = 265, scrollPrice = 22000, rep = { 529, 5 }, sq = 1, r = { { 8170, 30 }, { 12809, 2 }, { 7080, 4 }, { 15407, 2 }, { 14341, 2 } }, out = { 19052, 1 }, oq = 3 },
    [23706] = { name = "Golden Mantle of the Dawn", t = { 1, 315, 325, 335 }, scroll = 227895, train = 300, rep = { 529, 6 }, sq = 1, r = { { 12810, 8 }, { 12803, 4 }, { 12809, 4 }, { 15407, 2 }, { 14341, 2 } }, out = { 19058, 1 }, oq = 3 },
    [23707] = { name = "Lava Belt", t = { 1, 320, 330, 340 }, scroll = 19330, train = 300, rep = { 59, 5 }, sq = 1, r = { { 17011, 5 }, { 15407, 4 }, { 14227, 4 } }, out = { 19149, 1 }, oq = 4 },
    [23708] = { name = "Chromatic Gauntlets", t = { 1, 320, 330, 340 }, scroll = 19331, train = 300, rep = { 59, 6 }, sq = 1, r = { { 17010, 5 }, { 17011, 2 }, { 17012, 4 }, { 12607, 4 }, { 15407, 4 }, { 14227, 4 } }, out = { 19157, 1 }, oq = 4 },
    [23709] = { name = "Corehound Belt", t = { 1, 320, 330, 340 }, scroll = 19332, train = 300, rep = { 59, 6 }, sq = 1, r = { { 17010, 8 }, { 17012, 12 }, { 12810, 10 }, { 15407, 4 }, { 14227, 4 } }, out = { 19162, 1 }, oq = 4 },
    [23710] = { name = "Molten Belt", t = { 1, 320, 330, 340 }, scroll = 19333, train = 300, rep = { 59, 6 }, sq = 1, r = { { 17010, 2 }, { 17011, 7 }, { 7076, 6 }, { 15407, 4 }, { 14227, 4 } }, out = { 19163, 1 }, oq = 4 },
    [24121] = { name = "Primal Batskin Jerkin", t = { 1, 320, 330, 340 }, scroll = 19769, train = 300, scrollPrice = 50000, rep = { 270, 6 }, sq = 1, r = { { 19767, 14 }, { 15407, 5 }, { 12803, 4 }, { 14341, 4 } }, out = { 19685, 1 }, oq = 3 },
    [24122] = { name = "Primal Batskin Gloves", t = { 1, 320, 330, 340 }, scroll = 19770, train = 300, scrollPrice = 50000, rep = { 270, 5 }, sq = 1, r = { { 19767, 10 }, { 15407, 4 }, { 12803, 4 }, { 14341, 3 } }, out = { 19686, 1 }, oq = 3 },
    [24123] = { name = "Primal Batskin Bracers", t = { 1, 320, 330, 340 }, scroll = 19771, train = 300, scrollPrice = 50000, rep = { 270, 4 }, sq = 1, r = { { 19767, 8 }, { 15407, 3 }, { 12803, 4 }, { 14341, 3 } }, out = { 19687, 1 }, oq = 3 },
    [24124] = { name = "Blood Tiger Breastplate", t = { 1, 320, 330, 340 }, scroll = 19772, train = 300, scrollPrice = 50000, rep = { 270, 6 }, sq = 1, r = { { 19768, 35 }, { 19726, 2 }, { 15407, 3 }, { 14341, 3 } }, out = { 19688, 1 }, oq = 3 },
    [24125] = { name = "Blood Tiger Shoulders", t = { 1, 320, 330, 340 }, scroll = 19773, train = 300, scrollPrice = 50000, rep = { 270, 5 }, sq = 1, r = { { 19768, 25 }, { 19726, 2 }, { 15407, 3 }, { 14341, 3 } }, out = { 19689, 1 }, oq = 3 },
    [24654] = { name = "Blue Dragonscale Leggings", t = { 1, 310, 320, 330 }, fee = 45000, train = 300, tr = { 7867 }, r = { { 8170, 28 }, { 15415, 36 }, { 15407, 2 }, { 14341, 2 } }, out = { 20295, 1 }, oq = 3 },
    [24655] = { name = "Green Dragonscale Gauntlets", t = { 1, 275, 285, 295 }, fee = 27000, train = 280, tr = { 7867 }, r = { { 8170, 20 }, { 15412, 30 }, { 15407, 1 }, { 14341, 2 } }, out = { 20296, 1 }, oq = 3 },
    [24703] = { name = "Dreamscale Breastplate", t = { 1, 320, 330, 340 }, scroll = 20382, train = 310, sq = 1, r = { { 12810, 12 }, { 20381, 6 }, { 12803, 4 }, { 15407, 4 }, { 14227, 6 } }, out = { 20380, 1 }, oq = 4 },
    [24846] = { name = "Spitfire Bracers", t = { 1, 310, 320, 330 }, scroll = 20506, train = 300, sq = 1, r = { { 20500, 1 }, { 20498, 20 }, { 7078, 2 } }, out = { 20481, 1 }, oq = 3 },
    [24847] = { name = "Spitfire Gauntlets", t = { 1, 305, 315, 325 }, scroll = 20507, train = 295, sq = 1, r = { { 20500, 2 }, { 20498, 30 }, { 7078, 2 }, { 15407, 1 } }, out = { 20480, 1 }, oq = 3 },
    [24848] = { name = "Spitfire Breastplate", t = { 1, 310, 320, 330 }, scroll = 20508, train = 300, sq = 1, r = { { 20500, 3 }, { 20498, 40 }, { 7078, 2 }, { 15407, 2 } }, out = { 20479, 1 }, oq = 3 },
    [24849] = { name = "Sandstalker Bracers", t = { 1, 310, 320, 330 }, scroll = 20509, train = 300, sq = 1, r = { { 20501, 1 }, { 20498, 20 }, { 18512, 2 } }, out = { 20476, 1 }, oq = 3 },
    [24850] = { name = "Sandstalker Gauntlets", t = { 1, 310, 320, 330 }, scroll = 20510, train = 300, sq = 1, r = { { 20501, 2 }, { 20498, 30 }, { 18512, 2 }, { 15407, 1 } }, out = { 20477, 1 }, oq = 3 },
    [24851] = { name = "Sandstalker Breastplate", t = { 1, 310, 320, 330 }, scroll = 20511, train = 300, sq = 1, r = { { 20501, 3 }, { 20498, 40 }, { 18512, 2 }, { 15407, 2 } }, out = { 20478, 1 }, oq = 3 },
    [24940] = { name = "Black Whelp Tunic", t = { 1, 100, 112, 125 }, scroll = 20576, train = 75, scrollPrice = 1400, sq = 1, r = { { 2319, 8 }, { 7286, 8 }, { 4231, 1 }, { 2321, 2 } }, out = { 20575, 1 }, oq = 2 },
    [26279] = { name = "Stormshroud Gloves", t = { 1, 310, 320, 330 }, scroll = 21548, train = 290, sq = 3, r = { { 12810, 6 }, { 7080, 4 }, { 7082, 4 }, { 15407, 2 }, { 14227, 2 } }, out = { 21278, 1 }, oq = 3 },
    [28219] = { name = "Polar Tunic", t = { 1, 320, 330, 340 }, scroll = 22692, train = 310, sq = 1, r = { { 22682, 7 }, { 12810, 16 }, { 7080, 2 }, { 15407, 4 }, { 14227, 4 } }, out = { 22661, 1 }, oq = 4 },
    [28220] = { name = "Polar Gloves", t = { 1, 320, 330, 340 }, scroll = 22694, train = 310, sq = 1, r = { { 22682, 5 }, { 12810, 12 }, { 7080, 2 }, { 15407, 3 }, { 14227, 4 } }, out = { 22662, 1 }, oq = 4 },
    [28221] = { name = "Polar Bracers", t = { 1, 320, 330, 340 }, scroll = 22695, train = 310, sq = 1, r = { { 22682, 4 }, { 12810, 12 }, { 7080, 2 }, { 15407, 2 }, { 14227, 4 } }, out = { 22663, 1 }, oq = 4 },
    [28222] = { name = "Icy Scale Breastplate", t = { 1, 320, 330, 340 }, scroll = 22696, train = 310, sq = 1, r = { { 22682, 7 }, { 15408, 24 }, { 7080, 2 }, { 15407, 4 }, { 14227, 4 } }, out = { 22664, 1 }, oq = 4 },
    [28223] = { name = "Icy Scale Gauntlets", t = { 1, 320, 330, 340 }, scroll = 22697, train = 310, sq = 1, r = { { 22682, 5 }, { 15408, 16 }, { 7080, 2 }, { 15407, 3 }, { 14227, 4 } }, out = { 22666, 1 }, oq = 4 },
    [28224] = { name = "Icy Scale Bracers", t = { 1, 320, 330, 340 }, scroll = 22698, train = 310, sq = 1, r = { { 22682, 4 }, { 15408, 16 }, { 7080, 2 }, { 15407, 2 }, { 14227, 4 } }, out = { 22665, 1 }, oq = 4 },
    [28472] = { name = "Bramblewood Helm", t = { 1, 320, 330, 340 }, scroll = 22771, train = 310, sq = 1, r = { { 12810, 12 }, { 19726, 2 }, { 12803, 2 }, { 15407, 2 } }, out = { 22759, 1 }, oq = 3 },
    [28473] = { name = "Bramblewood Boots", t = { 1, 320, 330, 340 }, scroll = 22770, train = 310, sq = 1, r = { { 12810, 6 }, { 18512, 2 }, { 12803, 2 }, { 15407, 2 } }, out = { 22760, 1 }, oq = 3 },
    [28474] = { name = "Bramblewood Belt", t = { 1, 320, 330, 340 }, scroll = 22769, train = 310, sq = 1, r = { { 12810, 4 }, { 12803, 2 }, { 15407, 1 } }, out = { 22761, 1 }, oq = 3 },
    [435819] = { name = "Faintly Glowing Leather", t = { 1, 200, 210, 220 }, scroll = 215367, train = 200, sq = 3, r = { { 8172, 1 }, { 213370, 5 } }, out = { 213369, 1 }, oq = 3 },
    [435904] = { name = "Glowing Gneuro-Linked Cowl", t = { 1, 225, 230, 235 }, scroll = 215152, train = 225, sq = 4, r = { { 213379, 1 }, { 8172, 5 }, { 4291, 2 }, { 213369, 5 } }, out = { 215166, 1 }, oq = 1 },
    [461645] = { name = "Honed Blue Dragonscale Shoulders", t = { 1, 315, 325, 335 }, scroll = 227899, train = 295, sq = 3, r = { { 8170, 28 }, { 15415, 30 }, { 12810, 2 }, { 15407, 1 }, { 14341, 1 } }, out = { 227873, 1 }, oq = 1 },
    [461649] = { name = "Living Green Dragonscale Leggings", t = { 1, 290, 300, 310 }, scroll = 227900, train = 270, sq = 3, r = { { 8170, 20 }, { 15412, 25 }, { 14341, 1 } }, out = { 227877, 1 }, oq = 1 },
    [461653] = { name = "Brilliant Chromatic Cloak", t = { 1, 320, 330, 340 }, scroll = 227910, train = 300, sq = 4, r = { { 8170, 30 }, { 12607, 12 }, { 15416, 30 }, { 15414, 30 }, { 15407, 5 }, { 14341, 8 } }, out = { 227869, 1 }, oq = 1 },
    [461655] = { name = "Hardened Black Dragonscale Breastplate", t = { 1, 310, 320, 330 }, scroll = 227902, train = 290, sq = 1, r = { { 8170, 40 }, { 15416, 60 }, { 15407, 1 }, { 14341, 2 } }, out = { 227851, 1 }, oq = 1 },
    [461657] = { name = "Hardened Black Dragonscale Leggings", t = { 1, 320, 330, 340 }, scroll = 227903, train = 300, sq = 3, r = { { 8170, 40 }, { 15416, 60 }, { 12810, 4 }, { 15407, 1 }, { 14341, 2 } }, out = { 227852, 1 }, oq = 1 },
    [461659] = { name = "Hardened Black Dragonscale Shoulders", t = { 1, 320, 330, 340 }, scroll = 227904, train = 300, sq = 3, r = { { 8170, 44 }, { 15416, 45 }, { 12810, 2 }, { 15407, 1 }, { 14341, 1 } }, out = { 227853, 1 }, oq = 1 },
    [461661] = { name = "Masterwork Volcanic Breastplate", t = { 1, 305, 315, 325 }, scroll = 227906, train = 285, sq = 2, r = { { 8170, 8 }, { 7078, 1 }, { 7076, 1 }, { 14341, 1 } }, out = { 227868, 1 }, oq = 1 },
    [461663] = { name = "Masterwork Volcanic Shoulders", t = { 1, 320, 330, 340 }, scroll = 227907, train = 300, sq = 2, r = { { 8170, 10 }, { 7078, 1 }, { 7076, 1 }, { 14341, 2 } }, out = { 227866, 1 }, oq = 1 },
    [461665] = { name = "Masterwork Volcanic Leggings", t = { 1, 290, 300, 310 }, scroll = 227908, train = 270, sq = 2, r = { { 8170, 6 }, { 7078, 1 }, { 7075, 1 }, { 14341, 1 } }, out = { 227867, 1 }, oq = 1 },
    [461673] = { name = "Honed Blue Dragonscale Breastplate", t = { 1, 305, 315, 325 }, scroll = 227898, train = 285, sq = 1, r = { { 8170, 28 }, { 15415, 30 }, { 15407, 1 }, { 14341, 1 } }, out = { 227875, 1 }, oq = 1 },
    [461677] = { name = "Living Green Dragonscale Gauntlets", t = { 1, 300, 310, 320 }, scroll = 228251, train = 270, sq = 3, r = { { 8170, 20 }, { 15412, 25 }, { 14341, 1 } }, out = { 227878, 1 }, oq = 1 },
    [461690] = { name = "Mastercrafted Shifting Cloak", t = { 1, 320, 330, 340 }, scroll = 228276, train = 300, sq = 4, r = { { 8170, 30 }, { 7082, 12 }, { 12753, 4 }, { 12809, 8 }, { 15407, 4 }, { 14341, 8 } }, out = { 227854, 1 }, oq = 1 },
    [461692] = { name = "Synthetic Gordok Ogre Suit", t = { 1, 285, 290, 295 }, scroll = 228115, train = 275, sq = 1, r = { { 8170, 4 }, { 14048, 2 }, { 18240, 1 }, { 14341, 1 } }, out = { 227855, 1 }, oq = 1 },
    [461706] = { name = "Swift Flight Vambraces", t = { 1, 320, 330, 340 }, scroll = 228301, train = 300, sq = 3, r = { { 8170, 12 }, { 18512, 8 }, { 15420, 60 }, { 15407, 4 }, { 14341, 4 } }, out = { 227883, 1 }, oq = 1 },
    [461720] = { name = "Living Green Dragonscale Breastplate", t = { 1, 280, 290, 300 }, scroll = 228309, train = 260, sq = 1, r = { { 8170, 20 }, { 15412, 25 }, { 14341, 2 } }, out = { 227879, 1 }, oq = 1 },
    [461722] = { name = "Devilcore Gauntlets", t = { 1, 310, 320, 330 }, scroll = 228119, train = 290, sq = 3, r = { { 8170, 30 }, { 15417, 8 }, { 14341, 1 }, { 7078, 8 } }, out = { 227848, 1 }, oq = 1 },
    [461724] = { name = "Devilcore Leggings", t = { 1, 320, 330, 340 }, scroll = 228120, train = 300, sq = 3, r = { { 8170, 30 }, { 15417, 20 }, { 15407, 1 }, { 14341, 1 }, { 7078, 10 } }, out = { 227847, 1 }, oq = 1 },
    [461754] = { name = "Girdle of Arcane Insight", t = { 1, 320, 330, 340 }, scroll = 228319, train = 300, sq = 3, r = { { 8170, 12 }, { 12804, 12 }, { 15407, 2 }, { 14341, 4 } }, out = { 227882, 1 }, oq = 1 },
    [462227] = { name = "Honed Blue Dragonscale Leggings", t = { 1, 320, 330, 340 }, r = { { 8170, 28 }, { 15415, 36 }, { 15407, 2 }, { 14341, 2 } }, out = { 227874, 1 }, oq = 1 },
    [1214303] = { name = "Dreamscale Kilt", t = { 1, 320, 330, 340 }, scroll = 234481, train = 310, sq = 1, r = { { 12810, 12 }, { 20381, 6 }, { 12803, 4 }, { 15407, 4 }, { 14227, 6 } }, out = { 234482, 1 }, oq = 1 },
    [1224615] = { name = "Scarlet Infiltrator's Bandana", t = { 1, 285, 295, 305 }, scroll = 238306, train = 280, sq = 3, r = { { 12938, 1 }, { 12811, 2 }, { 8170, 12 } }, out = { 238272, 1 }, oq = 1 },
    [1224616] = { name = "Scarlet Infiltrator's Shoulderpads", t = { 1, 285, 295, 305 }, scroll = 238307, train = 280, sq = 3, r = { { 12811, 1 }, { 8170, 10 } }, out = { 238273, 1 }, oq = 1 },
    [1224617] = { name = "Scarlet Infiltrator's Vest", t = { 1, 285, 295, 305 }, scroll = 238308, train = 280, sq = 3, r = { { 12938, 1 }, { 12811, 1 }, { 8170, 12 } }, out = { 238274, 1 }, oq = 1 },
    [1224618] = { name = "Scarlet Infiltrator's Bracers", t = { 1, 260, 282, 305 }, scroll = 238309, train = 250, sq = 3, r = { { 8170, 8 } }, out = { 238275, 1 }, oq = 1 },
    [1224619] = { name = "Scarlet Infiltrator's Gloves", t = { 1, 270, 287, 305 }, scroll = 238310, train = 260, sq = 3, r = { { 12811, 1 }, { 8170, 10 } }, out = { 238276, 1 }, oq = 1 },
    [1224620] = { name = "Scarlet Infiltrator's Belt", t = { 1, 260, 282, 305 }, scroll = 238311, train = 250, sq = 3, r = { { 12811, 1 }, { 8170, 10 } }, out = { 238277, 1 }, oq = 1 },
    [1224621] = { name = "Scarlet Infiltrator's Trousers", t = { 1, 280, 292, 305 }, scroll = 238312, train = 270, sq = 3, r = { { 12938, 1 }, { 12811, 1 }, { 8170, 12 } }, out = { 238278, 1 }, oq = 1 },
    [1224622] = { name = "Scarlet Infiltrator's Shoes", t = { 1, 270, 287, 305 }, scroll = 238313, train = 260, sq = 3, r = { { 12811, 1 }, { 8170, 10 } }, out = { 238279, 1 }, oq = 1 },
    [1224623] = { name = "Scarlet Huntsman's Coif", t = { 1, 285, 295, 305 }, scroll = 238314, train = 280, sq = 3, r = { { 12938, 1 }, { 12811, 2 }, { 15408, 12 } }, out = { 238280, 1 }, oq = 1 },
    [1224624] = { name = "Scarlet Huntsman's Pauldrons", t = { 1, 285, 295, 305 }, scroll = 238315, train = 280, sq = 3, r = { { 12811, 1 }, { 15408, 10 } }, out = { 238281, 1 }, oq = 1 },
    [1224625] = { name = "Scarlet Huntsman's Chain", t = { 1, 285, 295, 305 }, scroll = 238316, train = 280, sq = 3, r = { { 12938, 1 }, { 12811, 1 }, { 15408, 12 } }, out = { 238282, 1 }, oq = 1 },
    [1224626] = { name = "Scarlet Huntsman's Wristguards", t = { 1, 260, 282, 305 }, scroll = 238317, train = 250, sq = 3, r = { { 15408, 8 } }, out = { 238283, 1 }, oq = 1 },
    [1224627] = { name = "Scarlet Huntsman's Handguards", t = { 1, 270, 287, 305 }, scroll = 238318, train = 260, sq = 3, r = { { 12811, 1 }, { 15408, 10 } }, out = { 238284, 1 }, oq = 1 },
    [1224628] = { name = "Scarlet Huntsman's Clasp", t = { 1, 260, 282, 305 }, scroll = 238319, train = 250, sq = 3, r = { { 12811, 1 }, { 15408, 10 } }, out = { 238285, 1 }, oq = 1 },
    [1224629] = { name = "Scarlet Huntsman's Legguards", t = { 1, 280, 292, 305 }, scroll = 238320, train = 270, sq = 3, r = { { 12938, 1 }, { 12811, 1 }, { 15408, 12 } }, out = { 238286, 1 }, oq = 1 },
    [1224630] = { name = "Scarlet Huntsman's Boots", t = { 1, 270, 287, 305 }, scroll = 238321, train = 260, sq = 3, r = { { 12811, 1 }, { 15408, 10 } }, out = { 238287, 1 }, oq = 1 },
    [1226689] = { name = "Scarlet Quiver", t = { 1, 280, 285, 290 }, scroll = 238927, train = 275, sq = 2, r = { { 12811, 1 }, { 8170, 24 }, { 15407, 2 } }, out = { 238925, 1 }, oq = 1 },
    [1226690] = { name = "Scarlet Ammo Pouch", t = { 1, 280, 285, 290 }, scroll = 238928, train = 275, sq = 2, r = { { 12811, 1 }, { 15408, 24 }, { 15407, 2 } }, out = { 238926, 1 }, oq = 1 },
    [1229432] = { name = "Camp Tent", t = { 1, 20, 22, 25 }, fee = 0, train = 20, r = { { 2318, 5 } }, out = { 279978, 1 }, oq = 1 },
    [1254965] = { name = "Forceful Rugged Armor Kit", t = { 1, 235, 245, 255 }, scroll = 252942, train = 235, scrollPrice = 5500, sq = 2, r = { { 15564, 1 }, { 11176, 2 }, { 9206, 2 }, { 249429, 1 }, { 248824, 1 } }, out = { 252488, 1 }, oq = 2 },
    [1254966] = { name = "Mystic Rugged Armor Kit", t = { 1, 235, 245, 255 }, scroll = 252941, train = 235, sq = 2, favor = 90, favorRep = 6, r = { { 15564, 1 }, { 11176, 2 }, { 13444, 2 }, { 249429, 1 }, { 248824, 1 } }, out = { 252487, 1 }, oq = 2 },
    [1254967] = { name = "Pristine Scorpid Leggings", t = { 1, 320, 330, 340 }, scroll = 252940, train = 300, sq = 4, r = { { 8170, 20 }, { 15408, 40 }, { 12810, 12 }, { 15407, 4 }, { 249429, 10 }, { 14341, 2 }, { 248825, 20 } }, out = { 252606, 1 }, oq = 4 },
    [1254968] = { name = "Black Dragonscale Helm", t = { 1, 320, 330, 340 }, scroll = 252939, train = 300, sq = 4, r = { { 8170, 20 }, { 15416, 40 }, { 12810, 12 }, { 15407, 4 }, { 249429, 10 }, { 14341, 2 }, { 248825, 20 } }, out = { 252605, 1 }, oq = 4 },
    [1254969] = { name = "Blue Dragonscale Helm", t = { 1, 320, 330, 340 }, scroll = 252938, train = 300, sq = 4, r = { { 8170, 20 }, { 15415, 40 }, { 12810, 12 }, { 15407, 6 }, { 249429, 10 }, { 14341, 2 }, { 248825, 20 } }, out = { 252604, 1 }, oq = 4 },
    [1254970] = { name = "Red Dragonscale Leggings", t = { 1, 320, 330, 340 }, scroll = 252937, train = 300, sq = 4, r = { { 8170, 20 }, { 15414, 40 }, { 12810, 12 }, { 15407, 4 }, { 249429, 10 }, { 14341, 2 }, { 248825, 20 } }, out = { 252603, 1 }, oq = 4 },
    [1254971] = { name = "Charged Scorpid Boots", t = { 1, 300, 310, 320 }, scroll = 252936, train = 280, sq = 2, r = { { 8170, 12 }, { 15408, 14 }, { 14341, 1 }, { 7069, 2 } }, out = { 252602, 1 }, oq = 2 },
    [1254972] = { name = "Supple Scorpid Sabatons", t = { 1, 300, 310, 320 }, scroll = 252935, train = 280, sq = 2, r = { { 8170, 20 }, { 15408, 10 }, { 14341, 1 } }, out = { 252601, 1 }, oq = 2 },
    [1254973] = { name = "Charged Scorpid Leggings", t = { 1, 290, 300, 310 }, scroll = 252934, train = 270, sq = 2, r = { { 8170, 12 }, { 15408, 14 }, { 14341, 1 }, { 7069, 2 } }, out = { 252600, 1 }, oq = 2 },
    [1254974] = { name = "Supple Scorpid Vest", t = { 1, 290, 300, 310 }, scroll = 252933, train = 270, scrollPrice = 100000, sq = 2, r = { { 8170, 20 }, { 15408, 10 }, { 14341, 1 } }, out = { 252599, 1 }, oq = 2 },
    [1254975] = { name = "Charged Scorpid Vest", t = { 1, 280, 290, 300 }, scroll = 252932, train = 260, sq = 2, r = { { 8170, 6 }, { 15408, 12 }, { 14341, 1 }, { 7069, 2 } }, out = { 252598, 1 }, oq = 2 },
    [1254976] = { name = "Supple Scorpid Helm", t = { 1, 280, 290, 300 }, scroll = 252931, train = 260, sq = 2, r = { { 8170, 11 }, { 15408, 10 }, { 14341, 1 } }, out = { 252597, 1 }, oq = 2 },
    [1254977] = { name = "Charged Scorpid Gauntlets", t = { 1, 275, 285, 295 }, scroll = 252930, train = 255, sq = 2, r = { { 8170, 4 }, { 15408, 8 }, { 14341, 1 }, { 7069, 2 } }, out = { 252596, 1 }, oq = 2 },
    [1254978] = { name = "Supple Scorpid Belt", t = { 1, 275, 285, 295 }, scroll = 252929, train = 255, sq = 2, r = { { 8170, 9 }, { 15408, 6 }, { 14341, 1 } }, out = { 252595, 1 }, oq = 2 },
    [1254979] = { name = "Heavy Scorpid Boots", t = { 1, 275, 285, 295 }, scroll = 252928, train = 255, sq = 2, r = { { 8170, 6 }, { 15408, 8 }, { 14341, 1 } }, out = { 252594, 1 }, oq = 2 },
    [1254980] = { name = "Charged Scorpid Bracers", t = { 1, 275, 285, 295 }, scroll = 252927, train = 255, sq = 2, r = { { 8170, 2 }, { 15408, 4 }, { 14341, 1 }, { 7069, 2 } }, out = { 252593, 1 }, oq = 2 },
    [1254981] = { name = "Supple Scorpid Shoulders", t = { 1, 275, 285, 295 }, scroll = 252926, train = 255, sq = 2, r = { { 8170, 9 }, { 15408, 6 }, { 14341, 1 } }, out = { 252592, 1 }, oq = 2 },
    [1254982] = { name = "Mender's Mail Belt", t = { 1, 270, 280, 290 }, scroll = 252925, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 8170, 12 }, { 8172, 4 }, { 249428, 10 }, { 8343, 2 }, { 5500, 8 }, { 249427, 5 } }, out = { 252591, 1 }, oq = 3, bop = true },
    [1254983] = { name = "Skirmisher's Mail Belt", t = { 1, 270, 280, 290 }, scroll = 252924, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 8170, 12 }, { 8172, 4 }, { 249428, 10 }, { 8343, 2 }, { 3864, 8 }, { 249427, 5 } }, out = { 252590, 1 }, oq = 3, bop = true },
    [1254984] = { name = "Skycaller's Mail Belt", t = { 1, 270, 280, 290 }, scroll = 252923, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 8170, 12 }, { 8172, 4 }, { 249428, 10 }, { 8343, 2 }, { 7070, 8 }, { 249427, 5 } }, out = { 252589, 1 }, oq = 3, bop = true },
    [1254985] = { name = "Stalker's Mail Belt", t = { 1, 270, 280, 290 }, scroll = 252922, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 8170, 12 }, { 8172, 4 }, { 249428, 10 }, { 8343, 2 }, { 7069, 8 }, { 249427, 5 } }, out = { 252588, 1 }, oq = 3, bop = true },
    [1254990] = { name = "Charged Scorpid Shoulders", t = { 1, 270, 280, 290 }, scroll = 252917, train = 250, sq = 2, r = { { 8170, 4 }, { 15408, 8 }, { 14341, 1 }, { 7069, 2 } }, out = { 252583, 1 }, oq = 2 },
    [1254991] = { name = "Supple Scorpid Bracers", t = { 1, 270, 280, 290 }, scroll = 252916, train = 250, sq = 2, r = { { 8170, 7 }, { 15408, 2 }, { 14341, 1 } }, out = { 252582, 1 }, oq = 2 },
    [1254992] = { name = "Charged Scorpid Helm", t = { 1, 260, 270, 280 }, scroll = 252915, train = 240, sq = 2, r = { { 8170, 4 }, { 15408, 6 }, { 14341, 1 }, { 7069, 2 } }, out = { 252581, 1 }, oq = 2 },
    [1254993] = { name = "Supple Scorpid Leggings", t = { 1, 260, 270, 280 }, scroll = 252914, train = 240, sq = 2, r = { { 8170, 9 }, { 15408, 4 }, { 14341, 1 } }, out = { 252580, 1 }, oq = 2 },
    [1254994] = { name = "Mender's Mail Sabatons", t = { 1, 255, 265, 275 }, scroll = 252913, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 16 }, { 8172, 2 }, { 249428, 8 }, { 8343, 2 }, { 5500, 6 }, { 249427, 4 } }, out = { 252579, 1 }, oq = 3, bop = true },
    [1254995] = { name = "Skirmisher's Mail Sabatons", t = { 1, 255, 265, 275 }, scroll = 252912, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 16 }, { 8172, 2 }, { 249428, 8 }, { 8343, 2 }, { 3864, 6 }, { 249427, 4 } }, out = { 252578, 1 }, oq = 3, bop = true },
    [1254996] = { name = "Skycaller's Mail Sabatons", t = { 1, 255, 265, 275 }, scroll = 252911, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 16 }, { 8172, 2 }, { 249428, 8 }, { 8343, 2 }, { 7070, 6 }, { 249427, 4 } }, out = { 252577, 1 }, oq = 3, bop = true },
    [1254997] = { name = "Stalker's Mail Sabatons", t = { 1, 255, 265, 275 }, scroll = 252910, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 16 }, { 8172, 2 }, { 249428, 8 }, { 8343, 2 }, { 7069, 6 }, { 249427, 4 } }, out = { 252576, 1 }, oq = 3, bop = true },
    [1254998] = { name = "Charged Scorpid Belt", t = { 1, 250, 260, 270 }, scroll = 252909, train = 230, sq = 2, r = { { 8170, 6 }, { 15408, 6 }, { 14341, 1 } }, out = { 252575, 1 }, oq = 2 },
    [1254999] = { name = "Supple Scorpid Boots", t = { 1, 250, 260, 270 }, scroll = 252908, train = 230, sq = 2, r = { { 8170, 12 }, { 15408, 4 }, { 14341, 1 } }, out = { 252574, 1 }, oq = 2 },
    [1255000] = { name = "Mender's Mail Bracers", t = { 1, 220, 230, 240 }, scroll = 252907, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 12 }, { 4236, 4 }, { 249428, 6 }, { 8343, 2 }, { 5500, 4 }, { 249427, 3 } }, out = { 252573, 1 }, oq = 3, bop = true },
    [1255001] = { name = "Skirmisher's Mail Bracers", t = { 1, 220, 230, 240 }, scroll = 252906, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 12 }, { 4236, 4 }, { 249428, 6 }, { 8343, 2 }, { 3864, 4 }, { 249427, 3 } }, out = { 252572, 1 }, oq = 3, bop = true },
    [1255002] = { name = "Skycaller's Mail Bracers", t = { 1, 220, 230, 240 }, scroll = 252905, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 12 }, { 4236, 4 }, { 249428, 6 }, { 8343, 2 }, { 7070, 4 }, { 249427, 3 } }, out = { 252571, 1 }, oq = 3, bop = true },
    [1255003] = { name = "Stalker's Mail Bracers", t = { 1, 220, 230, 240 }, scroll = 252904, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 12 }, { 4236, 4 }, { 249428, 6 }, { 8343, 2 }, { 7069, 4 }, { 249427, 3 } }, out = { 252570, 1 }, oq = 3, bop = true },
    [1255004] = { name = "Mender's Mail Shoulders", t = { 1, 220, 230, 240 }, scroll = 252903, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 4304, 10 }, { 4236, 3 }, { 249428, 4 }, { 4291, 2 }, { 5500, 3 }, { 249427, 2 } }, out = { 252569, 1 }, oq = 3, bop = true },
    [1255005] = { name = "Skirmisher's Mail Shoulders", t = { 1, 220, 230, 240 }, scroll = 252902, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 4304, 10 }, { 4236, 3 }, { 249428, 4 }, { 4291, 2 }, { 3864, 3 }, { 249427, 2 } }, out = { 252568, 1 }, oq = 3, bop = true },
    [1255006] = { name = "Skycaller's Mail Shoulders", t = { 1, 220, 230, 240 }, scroll = 252901, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 4304, 10 }, { 4236, 3 }, { 249428, 4 }, { 4291, 2 }, { 7070, 3 }, { 249427, 2 } }, out = { 252567, 1 }, oq = 3, bop = true },
    [1255007] = { name = "Stalker's Mail Shoulders", t = { 1, 220, 230, 240 }, scroll = 252900, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 4304, 10 }, { 4236, 3 }, { 249428, 4 }, { 4291, 2 }, { 7069, 3 }, { 249427, 2 } }, out = { 252566, 1 }, oq = 3, bop = true },
    [1255012] = { name = "Ironfeather Leggings", t = { 1, 320, 330, 340 }, scroll = 252895, train = 300, sq = 4, r = { { 8170, 20 }, { 15420, 120 }, { 1529, 4 }, { 15407, 2 }, { 14341, 4 }, { 249429, 10 }, { 248825, 20 } }, out = { 252486, 1 }, oq = 4 },
    [1255013] = { name = "Warbear Helm", t = { 1, 320, 330, 340 }, scroll = 252894, train = 300, sq = 4, r = { { 8170, 20 }, { 15419, 20 }, { 14341, 4 }, { 15407, 2 }, { 249429, 10 }, { 248825, 20 } }, out = { 252485, 1 }, oq = 4 },
    [1255014] = { name = "Timbermaw Tunic", t = { 1, 320, 330, 340 }, scroll = 252893, train = 300, sq = 4, r = { { 12810, 6 }, { 12804, 20 }, { 12803, 20 }, { 249429, 10 }, { 15407, 4 }, { 14341, 10 }, { 248825, 20 } }, out = { 252484, 1 }, oq = 4 },
    [1255015] = { name = "Dawn Armor", t = { 1, 320, 330, 340 }, scroll = 252892, train = 300, sq = 4, r = { { 12810, 6 }, { 12809, 10 }, { 7080, 20 }, { 249429, 10 }, { 15407, 4 }, { 14341, 10 }, { 248825, 20 } }, out = { 252483, 1 }, oq = 4 },
    [1255016] = { name = "Living Crown", t = { 1, 320, 330, 340 }, scroll = 252891, train = 300, sq = 4, r = { { 8170, 20 }, { 12803, 20 }, { 7080, 20 }, { 249429, 10 }, { 15407, 4 }, { 14341, 10 }, { 248825, 20 } }, out = { 252561, 1 }, oq = 4 },
    [1255017] = { name = "Blue Suede Hat", t = { 1, 300, 310, 320 }, scroll = 252890, train = 280, sq = 2, r = { { 8170, 16 }, { 14341, 1 }, { 6260, 4 } }, out = { 252482, 1 }, oq = 2 },
    [1255018] = { name = "Tooled Leather Pants", t = { 1, 300, 310, 320 }, scroll = 252889, train = 280, sq = 2, r = { { 8170, 18 }, { 14341, 1 }, { 6261, 1 }, { 15407, 1 } }, out = { 252560, 1 }, oq = 2 },
    [1255019] = { name = "Blue Suede Bracers", t = { 1, 295, 305, 315 }, scroll = 252888, train = 275, sq = 2, r = { { 8170, 10 }, { 14341, 1 }, { 6260, 1 } }, out = { 252559, 1 }, oq = 2 },
    [1255020] = { name = "Tooled Leather Epaulets", t = { 1, 295, 305, 315 }, scroll = 252887, train = 275, sq = 2, r = { { 8170, 12 }, { 14341, 1 }, { 6261, 1 }, { 15407, 1 } }, out = { 252558, 1 }, oq = 2 },
    [1255021] = { name = "Blue Suede Belt", t = { 1, 290, 300, 310 }, scroll = 252886, train = 270, sq = 2, r = { { 8170, 14 }, { 14341, 1 }, { 6260, 2 } }, out = { 252481, 1 }, oq = 2 },
    [1255022] = { name = "Tooled Leather Bracers", t = { 1, 290, 300, 310 }, scroll = 252885, train = 270, sq = 2, r = { { 8170, 10 }, { 14341, 1 }, { 6261, 1 } }, out = { 252557, 1 }, oq = 2 },
    [1255023] = { name = "Wicked Leather Shoulders", t = { 1, 290, 300, 310 }, scroll = 252884, train = 270, sq = 2, r = { { 8170, 12 }, { 14341, 1 }, { 2325, 1 }, { 15407, 1 } }, out = { 252556, 1 }, oq = 2 },
    [1255024] = { name = "Blue Suede Armor", t = { 1, 285, 295, 305 }, scroll = 252883, train = 265, sq = 2, r = { { 8170, 14 }, { 15407, 2 }, { 14341, 2 }, { 6260, 4 }, { 15415, 6 } }, out = { 252480, 1 }, oq = 2 },
    [1255025] = { name = "Tooled Leather Crown", t = { 1, 285, 295, 305 }, scroll = 252882, train = 265, sq = 2, r = { { 8170, 14 }, { 14341, 1 }, { 6261, 1 } }, out = { 252555, 1 }, oq = 2 },
    [1255026] = { name = "Blue Suede Shoulders", t = { 1, 280, 290, 300 }, scroll = 252881, train = 260, sq = 2, r = { { 8170, 10 }, { 14341, 1 }, { 6260, 2 } }, out = { 252554, 1 }, oq = 2 },
    [1255027] = { name = "Tooled Leather Gauntlets", t = { 1, 280, 290, 300 }, scroll = 252880, train = 260, sq = 2, r = { { 8170, 10 }, { 14341, 1 }, { 6261, 1 } }, out = { 252553, 1 }, oq = 2 },
    [1255028] = { name = "Wicked Leather Boots", t = { 1, 280, 290, 300 }, scroll = 252879, train = 260, sq = 2, r = { { 8170, 10 }, { 14341, 1 }, { 2325, 1 } }, out = { 252479, 1 }, oq = 2 },
    [1255029] = { name = "Blue Suede Pants", t = { 1, 275, 285, 295 }, scroll = 252878, train = 255, sq = 2, r = { { 8170, 14 }, { 14341, 1 }, { 6260, 3 }, { 15407, 1 } }, out = { 252478, 1 }, oq = 2 },
    [1255030] = { name = "Tooled Leather Armor", t = { 1, 275, 285, 295 }, scroll = 252877, train = 255, scrollPrice = 100000, sq = 2, r = { { 8170, 16 }, { 14341, 1 }, { 6261, 3 }, { 15407, 2 }, { 13423, 6 } }, out = { 252552, 1 }, oq = 2 },
    [1255031] = { name = "Mender's Leather Waistguard", t = { 1, 270, 280, 290 }, scroll = 252876, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 8170, 12 }, { 8172, 4 }, { 249428, 10 }, { 8343, 2 }, { 5500, 8 }, { 249427, 5 } }, out = { 252477, 1 }, oq = 3, bop = true },
    [1255032] = { name = "Skycaller's Leather Waistguard", t = { 1, 270, 280, 290 }, scroll = 252875, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 8170, 12 }, { 8172, 4 }, { 249428, 10 }, { 8343, 2 }, { 7070, 8 }, { 249427, 5 } }, out = { 252476, 1 }, oq = 3, bop = true },
    [1255033] = { name = "Warden's Leather Waistguard", t = { 1, 270, 280, 290 }, scroll = 252874, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 8170, 12 }, { 8172, 4 }, { 249428, 10 }, { 8343, 2 }, { 7067, 8 }, { 249427, 5 } }, out = { 252475, 1 }, oq = 3, bop = true },
    [1255034] = { name = "Skulker's Leather Waistguard", t = { 1, 270, 280, 290 }, scroll = 252873, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 8170, 12 }, { 8172, 4 }, { 249428, 10 }, { 8343, 2 }, { 3182, 8 }, { 249427, 5 } }, out = { 252474, 1 }, oq = 3, bop = true },
    [1255035] = { name = "Prowler's Leather Waistguard", t = { 1, 270, 280, 290 }, scroll = 252872, train = 250, sq = 3, favor = 90, favorRep = 6, r = { { 8170, 12 }, { 8172, 4 }, { 249428, 10 }, { 8343, 2 }, { 1529, 8 }, { 249427, 5 } }, out = { 252473, 1 }, oq = 3, bop = true },
    [1255041] = { name = "Blue Suede Gloves", t = { 1, 260, 270, 280 }, scroll = 252866, train = 240, sq = 2, r = { { 8170, 8 }, { 14341, 1 }, { 6260, 1 } }, out = { 252546, 1 }, oq = 2 },
    [1255042] = { name = "Tooled Leather Boots", t = { 1, 260, 270, 280 }, scroll = 252865, train = 240, sq = 2, r = { { 8170, 8 }, { 14341, 1 }, { 6261, 1 } }, out = { 252545, 1 }, oq = 2 },
    [1255043] = { name = "Mender's Leather Boots", t = { 1, 255, 265, 275 }, scroll = 252864, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 16 }, { 8172, 2 }, { 249428, 8 }, { 8343, 2 }, { 5500, 6 }, { 249427, 4 } }, out = { 252472, 1 }, oq = 3, bop = true },
    [1255044] = { name = "Skycaller's Leather Boots", t = { 1, 255, 265, 275 }, scroll = 252863, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 16 }, { 8172, 2 }, { 249428, 8 }, { 8343, 2 }, { 7070, 6 }, { 249427, 4 } }, out = { 252471, 1 }, oq = 3, bop = true },
    [1255045] = { name = "Warden's Leather Boots", t = { 1, 255, 265, 275 }, scroll = 252862, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 16 }, { 8172, 2 }, { 249428, 8 }, { 8343, 2 }, { 7067, 6 }, { 249427, 4 } }, out = { 252470, 1 }, oq = 3, bop = true },
    [1255046] = { name = "Skulker's Leather Boots", t = { 1, 255, 265, 275 }, scroll = 252861, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 16 }, { 8172, 2 }, { 249428, 8 }, { 8343, 2 }, { 3182, 6 }, { 249427, 4 } }, out = { 252469, 1 }, oq = 3, bop = true },
    [1255047] = { name = "Prowler's Leather Boots", t = { 1, 255, 265, 275 }, scroll = 252860, train = 235, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 16 }, { 8172, 2 }, { 249428, 8 }, { 8343, 2 }, { 1529, 6 }, { 249427, 4 } }, out = { 252468, 1 }, oq = 3, bop = true },
    [1255048] = { name = "Blue Suede Shoes", t = { 1, 255, 265, 275 }, scroll = 252859, train = 235, sq = 2, r = { { 8170, 8 }, { 14341, 1 }, { 6260, 1 } }, out = { 252467, 1 }, oq = 2 },
    [1255049] = { name = "Tooled Leather Belt", t = { 1, 255, 265, 275 }, scroll = 252858, train = 235, sq = 2, r = { { 8170, 8 }, { 14341, 1 }, { 6261, 1 } }, out = { 252544, 1 }, oq = 2 },
    [1255050] = { name = "Mender's Leather Bracers", t = { 1, 245, 255, 265 }, scroll = 252857, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 12 }, { 4236, 4 }, { 249428, 6 }, { 8343, 2 }, { 5500, 4 }, { 249427, 3 } }, out = { 252543, 1 }, oq = 3, bop = true },
    [1255051] = { name = "Skycaller's Leather Bracers", t = { 1, 245, 255, 265 }, scroll = 252856, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 12 }, { 4236, 4 }, { 249428, 6 }, { 8343, 2 }, { 7070, 4 }, { 249427, 3 } }, out = { 252542, 1 }, oq = 3, bop = true },
    [1255052] = { name = "Warden's Leather Bracers", t = { 1, 245, 255, 265 }, scroll = 252855, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 12 }, { 4236, 4 }, { 249428, 6 }, { 8343, 2 }, { 7067, 4 }, { 249427, 3 } }, out = { 252541, 1 }, oq = 3, bop = true },
    [1255053] = { name = "Skulker's Leather Bracers", t = { 1, 245, 255, 265 }, scroll = 252854, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 12 }, { 4236, 4 }, { 249428, 6 }, { 8343, 2 }, { 3182, 4 }, { 249427, 3 } }, out = { 252540, 1 }, oq = 3, bop = true },
    [1255054] = { name = "Prowler's Leather Bracers", t = { 1, 245, 255, 265 }, scroll = 252853, train = 225, sq = 3, favor = 90, favorRep = 6, r = { { 4304, 12 }, { 4236, 4 }, { 249428, 6 }, { 8343, 2 }, { 1529, 4 }, { 249427, 3 } }, out = { 252539, 1 }, oq = 3, bop = true },
    [1255055] = { name = "Mender's Leather Shoulders", t = { 1, 230, 240, 250 }, scroll = 252852, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 4304, 10 }, { 4236, 3 }, { 249428, 4 }, { 4291, 2 }, { 5500, 3 }, { 249427, 2 } }, out = { 252538, 1 }, oq = 3, bop = true },
    [1255056] = { name = "Skycaller's Leather Shoulders", t = { 1, 230, 240, 250 }, scroll = 252851, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 4304, 10 }, { 4236, 3 }, { 249428, 4 }, { 4291, 2 }, { 7070, 3 }, { 249427, 2 } }, out = { 252537, 1 }, oq = 3, bop = true },
    [1255057] = { name = "Warden's Leather Shoulders", t = { 1, 230, 240, 250 }, scroll = 252850, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 4304, 10 }, { 4236, 3 }, { 249428, 4 }, { 4291, 2 }, { 7067, 3 }, { 249427, 2 } }, out = { 252536, 1 }, oq = 3, bop = true },
    [1255058] = { name = "Skulker's Leather Shoulders", t = { 1, 230, 240, 250 }, scroll = 252849, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 4304, 10 }, { 4236, 3 }, { 249428, 4 }, { 4291, 2 }, { 3182, 3 }, { 249427, 2 } }, out = { 252535, 1 }, oq = 3, bop = true },
    [1255059] = { name = "Prowler's Leather Shoulders", t = { 1, 230, 240, 250 }, scroll = 252848, train = 210, sq = 3, favor = 60, favorRep = 5, r = { { 4304, 10 }, { 4236, 3 }, { 249428, 4 }, { 4291, 2 }, { 1529, 3 }, { 249427, 2 } }, out = { 252534, 1 }, oq = 3, bop = true },
    [1255065] = { name = "Mender's Leather Gloves", t = { 1, 195, 205, 215 }, scroll = 252842, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 4234, 16 }, { 4236, 2 }, { 249428, 2 }, { 4291, 2 }, { 5500, 2 }, { 249427, 1 } }, out = { 252530, 1 }, oq = 3, bop = true },
    [1255066] = { name = "Skycaller's Leather Gloves", t = { 1, 195, 205, 215 }, scroll = 252841, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 4234, 16 }, { 4236, 2 }, { 249428, 2 }, { 4291, 2 }, { 7070, 2 }, { 249427, 1 } }, out = { 252529, 1 }, oq = 3, bop = true },
    [1255067] = { name = "Skirmisher's Leather Gloves", t = { 1, 195, 205, 215 }, scroll = 252840, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 4234, 16 }, { 4236, 2 }, { 249428, 2 }, { 4291, 2 }, { 3864, 2 }, { 249427, 1 } }, out = { 252528, 1 }, oq = 3, bop = true },
    [1255068] = { name = "Warden's Leather Gloves", t = { 1, 195, 205, 215 }, scroll = 252839, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 4234, 16 }, { 4236, 2 }, { 249428, 2 }, { 4291, 2 }, { 7067, 2 }, { 249427, 1 } }, out = { 252527, 1 }, oq = 3, bop = true },
    [1255069] = { name = "Stalker's Leather Gloves", t = { 1, 195, 205, 215 }, scroll = 252838, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 4234, 16 }, { 4236, 2 }, { 249428, 2 }, { 4291, 2 }, { 7069, 2 }, { 249427, 1 } }, out = { 252526, 1 }, oq = 3, bop = true },
    [1255070] = { name = "Skulker's Leather Gloves", t = { 1, 195, 205, 215 }, scroll = 252837, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 4234, 16 }, { 4236, 2 }, { 249428, 2 }, { 4291, 2 }, { 3182, 2 }, { 249427, 1 } }, out = { 252525, 1 }, oq = 3, bop = true },
    [1255071] = { name = "Prowler's Leather Gloves", t = { 1, 195, 205, 215 }, scroll = 252836, train = 175, sq = 3, favor = 60, favorRep = 5, r = { { 4234, 16 }, { 4236, 2 }, { 249428, 2 }, { 4291, 2 }, { 1529, 2 }, { 249427, 1 } }, out = { 252524, 1 }, oq = 3, bop = true },
    [1255073] = { name = "Forceful Thick Armor Kit", t = { 1, 205, 215, 225 }, scroll = 252834, train = 185, sq = 2, favor = 60, favorRep = 5, r = { { 8173, 1 }, { 11137, 2 }, { 3391, 2 } }, out = { 252463, 1 }, oq = 2 },
    [1255074] = { name = "Mystic Thick Armor Kit", t = { 1, 205, 215, 225 }, scroll = 252833, train = 185, scrollPrice = 3500, sq = 2, r = { { 8173, 1 }, { 11137, 2 }, { 3827, 2 } }, out = { 252462, 1 }, oq = 2 },
    [1255082] = { name = "Wisdom's Leather Leggings", t = { 1, 150, 160, 170 }, scroll = 252825, train = 125, sq = 3, favor = 30, r = { { 2319, 12 }, { 4233, 4 }, { 249427, 8 }, { 2321, 3 }, { 5498, 8 } }, out = { 252519, 1 }, oq = 3, bop = true },
    [1255083] = { name = "Stormrider's Leather Kilt", t = { 1, 150, 160, 170 }, scroll = 252824, train = 125, sq = 3, favor = 30, r = { { 2319, 12 }, { 4233, 4 }, { 249427, 8 }, { 2321, 3 }, { 249409, 8 } }, out = { 252518, 1 }, oq = 3, bop = true },
    [1255084] = { name = "Totemic Leather Leggings", t = { 1, 150, 160, 170 }, scroll = 252823, train = 125, sq = 3, favor = 30, r = { { 2319, 12 }, { 4233, 4 }, { 249427, 8 }, { 2321, 3 }, { 249410, 8 } }, out = { 252458, 1 }, oq = 3, bop = true },
    [1255085] = { name = "Defender's Leather Kilt", t = { 1, 150, 160, 170 }, scroll = 252822, train = 125, sq = 3, favor = 30, r = { { 2319, 12 }, { 4233, 4 }, { 249427, 8 }, { 2321, 3 }, { 2458, 8 } }, out = { 252457, 1 }, oq = 3, bop = true },
    [1255086] = { name = "Trapper's Leather Legguards", t = { 1, 150, 160, 170 }, scroll = 252821, train = 125, sq = 3, favor = 30, r = { { 2319, 12 }, { 4233, 4 }, { 249427, 8 }, { 2321, 3 }, { 6470, 8 } }, out = { 252517, 1 }, oq = 3, bop = true },
    [1255087] = { name = "Brawler's Leather Legguards", t = { 1, 150, 160, 170 }, scroll = 252820, train = 125, sq = 3, favor = 30, r = { { 2319, 12 }, { 4233, 4 }, { 249427, 8 }, { 2321, 3 }, { 1210, 8 } }, out = { 252516, 1 }, oq = 3, bop = true },
    [1255095] = { name = "Forceful Heavy Armor Kit", t = { 1, 155, 165, 175 }, scroll = 252812, train = 135, scrollPrice = 2000, sq = 2, r = { { 4265, 1 }, { 11083, 2 }, { 6662, 2 } }, out = { 252453, 1 }, oq = 2 },
    [1255096] = { name = "Mystic Heavy Armor Kit", t = { 1, 155, 165, 175 }, scroll = 252811, train = 135, scrollPrice = 2000, sq = 2, r = { { 4265, 1 }, { 11083, 2 }, { 3385, 2 } }, out = { 252452, 1 }, oq = 2 },
    [1255097] = { name = "Wisdom's Leather Tunic", t = { 1, 135, 147, 160 }, scroll = 252810, train = 110, sq = 3, favor = 30, r = { { 2319, 10 }, { 4233, 3 }, { 249427, 6 }, { 2321, 3 }, { 5498, 6 } }, out = { 252511, 1 }, oq = 3, bop = true },
    [1255098] = { name = "Stormrider's Leather Tunic", t = { 1, 135, 147, 160 }, scroll = 252809, train = 110, sq = 3, favor = 30, r = { { 2319, 10 }, { 4233, 3 }, { 249427, 6 }, { 2321, 3 }, { 249409, 6 } }, out = { 252510, 1 }, oq = 3, bop = true },
    [1255099] = { name = "Totemic Leather Tunic", t = { 1, 135, 147, 160 }, scroll = 252808, train = 110, sq = 3, favor = 30, r = { { 2319, 10 }, { 4233, 3 }, { 249427, 6 }, { 2321, 3 }, { 249410, 6 } }, out = { 252451, 1 }, oq = 3, bop = true },
    [1255100] = { name = "Defender's Leather Tunic", t = { 1, 135, 147, 160 }, scroll = 252807, train = 110, sq = 3, favor = 30, r = { { 2319, 10 }, { 4233, 3 }, { 249427, 6 }, { 2321, 3 }, { 2458, 6 } }, out = { 252450, 1 }, oq = 3, bop = true },
    [1255101] = { name = "Trapper's Leather Tunic", t = { 1, 135, 147, 160 }, scroll = 252806, train = 110, sq = 3, favor = 30, r = { { 2319, 10 }, { 4233, 3 }, { 249427, 6 }, { 2321, 3 }, { 6470, 6 } }, out = { 252509, 1 }, oq = 3, bop = true },
    [1255102] = { name = "Brawler's Leather Tunic", t = { 1, 135, 147, 160 }, scroll = 252805, train = 110, sq = 3, favor = 30, r = { { 2319, 10 }, { 4233, 3 }, { 249427, 6 }, { 2321, 3 }, { 1210, 6 } }, out = { 252508, 1 }, oq = 3, bop = true },
    [1255103] = { name = "Hillman's Leather Boots", t = { 1, 135, 147, 160 }, scroll = 252804, train = 110, sq = 2, r = { { 4233, 1 }, { 2319, 6 }, { 2321, 1 } }, out = { 252449, 1 }, oq = 2 },
    [1255104] = { name = "Wisdom's Leather Hood", t = { 1, 125, 137, 150 }, scroll = 252803, train = 100, sq = 3, favor = 30, r = { { 2319, 8 }, { 4233, 2 }, { 249427, 4 }, { 2321, 2 }, { 5498, 4 } }, out = { 252507, 1 }, oq = 3, bop = true },
    [1255105] = { name = "Stormrider's Leather Hood", t = { 1, 125, 137, 150 }, scroll = 252802, train = 100, sq = 3, favor = 30, r = { { 2319, 8 }, { 4233, 2 }, { 249427, 4 }, { 2321, 2 }, { 249409, 4 } }, out = { 252506, 1 }, oq = 3, bop = true },
    [1255106] = { name = "Totemic Leather Hood", t = { 1, 125, 137, 150 }, scroll = 252801, train = 100, sq = 3, favor = 30, r = { { 2319, 8 }, { 4233, 2 }, { 249427, 4 }, { 2321, 2 }, { 249410, 4 } }, out = { 252448, 1 }, oq = 3, bop = true },
    [1255107] = { name = "Defender's Leather Hood", t = { 1, 125, 137, 150 }, scroll = 252800, train = 100, sq = 3, favor = 30, r = { { 2319, 8 }, { 4233, 2 }, { 249427, 4 }, { 2321, 2 }, { 2458, 4 } }, out = { 252447, 1 }, oq = 3, bop = true },
    [1255108] = { name = "Trapper's Leather Hood", t = { 1, 125, 137, 150 }, scroll = 252799, train = 100, sq = 3, favor = 30, r = { { 2319, 8 }, { 4233, 2 }, { 249427, 4 }, { 2321, 2 }, { 6470, 4 } }, out = { 252505, 1 }, oq = 3, bop = true },
    [1255109] = { name = "Brawler's Leather Hood", t = { 1, 125, 137, 150 }, scroll = 252798, train = 100, sq = 3, favor = 30, r = { { 2319, 8 }, { 4233, 2 }, { 249427, 4 }, { 2321, 2 }, { 1210, 4 } }, out = { 252504, 1 }, oq = 3, bop = true },
    [1255116] = { name = "Wisdom's Leather Boots", t = { 1, 110, 122, 135 }, scroll = 252791, train = 85, sq = 3, favor = 30, r = { { 2318, 14 }, { 4231, 4 }, { 249427, 3 }, { 2321, 1 }, { 5498, 3 } }, out = { 252444, 1 }, oq = 3, bop = true },
    [1255117] = { name = "Stormrider's Leather Boots", t = { 1, 110, 122, 135 }, scroll = 252790, train = 85, sq = 3, favor = 30, r = { { 2318, 14 }, { 4231, 4 }, { 249427, 3 }, { 2321, 1 }, { 249409, 3 } }, out = { 252443, 1 }, oq = 3, bop = true },
    [1255118] = { name = "Totemic Leather Boots", t = { 1, 110, 122, 135 }, scroll = 252789, train = 85, sq = 3, favor = 30, r = { { 2318, 14 }, { 4231, 4 }, { 249427, 3 }, { 2321, 1 }, { 249410, 3 } }, out = { 252442, 1 }, oq = 3, bop = true },
    [1255119] = { name = "Defender's Leather Boots", t = { 1, 110, 122, 135 }, scroll = 252788, train = 85, sq = 3, favor = 30, r = { { 2318, 14 }, { 4231, 4 }, { 249427, 3 }, { 2321, 1 }, { 2458, 3 } }, out = { 252441, 1 }, oq = 3, bop = true },
    [1255120] = { name = "Trapper's Leather Boots", t = { 1, 110, 122, 135 }, scroll = 252787, train = 85, sq = 3, favor = 30, r = { { 2318, 14 }, { 4231, 4 }, { 249427, 3 }, { 2321, 1 }, { 6470, 3 } }, out = { 252440, 1 }, oq = 3, bop = true },
    [1255121] = { name = "Brawler's Leather Boots", t = { 1, 110, 122, 135 }, scroll = 252786, train = 85, sq = 3, favor = 30, r = { { 2318, 14 }, { 4231, 4 }, { 249427, 3 }, { 2321, 1 }, { 1210, 3 } }, out = { 252439, 1 }, oq = 3, bop = true },
    [1255123] = { name = "Forceful Medium Armor Kit", t = { 1, 95, 102, 110 }, scroll = 252784, train = 80, scrollPrice = 500, sq = 2, r = { { 2313, 1 }, { 10940, 2 }, { 2454, 2 } }, out = { 252437, 1 }, oq = 2 },
    [1255124] = { name = "Mystic Medium Armor Kit", t = { 1, 95, 102, 110 }, scroll = 252783, train = 80, scrollPrice = 500, sq = 2, r = { { 2313, 1 }, { 10940, 2 }, { 2455, 2 } }, out = { 252436, 1 }, oq = 2 },
    [1255125] = { name = "Wisdom's Leather Gloves", t = { 1, 100, 112, 125 }, scroll = 252782, train = 75, sq = 3, favor = 30, r = { { 2318, 12 }, { 4231, 3 }, { 249427, 2 }, { 2321, 1 }, { 5498, 2 } }, out = { 252499, 1 }, oq = 3, bop = true },
    [1255126] = { name = "Stormrider's Leather Gloves", t = { 1, 100, 112, 125 }, scroll = 252781, train = 75, sq = 3, favor = 30, r = { { 2318, 12 }, { 4231, 3 }, { 249427, 2 }, { 2321, 1 }, { 249409, 2 } }, out = { 252498, 1 }, oq = 3, bop = true },
    [1255127] = { name = "Totemic Leather Gloves", t = { 1, 100, 112, 125 }, scroll = 252780, train = 75, sq = 3, favor = 30, r = { { 2318, 12 }, { 4231, 3 }, { 249427, 2 }, { 2321, 1 }, { 249410, 2 } }, out = { 252497, 1 }, oq = 3, bop = true },
    [1255128] = { name = "Defender's Leather Gloves", t = { 1, 100, 112, 125 }, scroll = 252779, train = 75, sq = 3, favor = 30, r = { { 2318, 12 }, { 4231, 3 }, { 249427, 2 }, { 2321, 1 }, { 2458, 2 } }, out = { 252496, 1 }, oq = 3, bop = true },
    [1255129] = { name = "Trapper's Leather Gloves", t = { 1, 100, 112, 125 }, scroll = 252778, train = 75, sq = 3, favor = 30, r = { { 2318, 12 }, { 4231, 3 }, { 249427, 2 }, { 2321, 1 }, { 6470, 2 } }, out = { 252495, 1 }, oq = 3, bop = true },
    [1255130] = { name = "Brawler's Leather Gloves", t = { 1, 100, 112, 125 }, scroll = 252777, train = 75, sq = 3, favor = 30, r = { { 2318, 12 }, { 4231, 3 }, { 249427, 2 }, { 2321, 1 }, { 1210, 2 } }, out = { 252494, 1 }, oq = 3, bop = true },
    [1255137] = { name = "Wisdom's Leather Belt", t = { 1, 90, 105, 120 }, scroll = 252770, train = 60, sq = 3, favor = 30, r = { { 2318, 10 }, { 4231, 2 }, { 249427, 2 }, { 2320, 1 }, { 5498, 1 } }, out = { 252433, 1 }, oq = 3, bop = true },
    [1255138] = { name = "Stormrider's Leather Belt", t = { 1, 90, 105, 120 }, scroll = 252769, train = 60, sq = 3, favor = 30, r = { { 2318, 10 }, { 4231, 2 }, { 249427, 2 }, { 2320, 1 }, { 249409, 1 } }, out = { 252432, 1 }, oq = 3, bop = true },
    [1255139] = { name = "Totemic Leather Belt", t = { 1, 90, 105, 120 }, scroll = 252768, train = 60, sq = 3, favor = 30, r = { { 2318, 10 }, { 4231, 2 }, { 249427, 2 }, { 2320, 1 }, { 249410, 1 } }, out = { 252431, 1 }, oq = 3, bop = true },
    [1255140] = { name = "Defender's Leather Belt", t = { 1, 90, 105, 120 }, scroll = 252767, train = 60, sq = 3, favor = 30, r = { { 2318, 10 }, { 4231, 2 }, { 249427, 2 }, { 2320, 1 }, { 2458, 1 } }, out = { 252430, 1 }, oq = 3, bop = true },
    [1255141] = { name = "Trapper's Leather Belt", t = { 1, 90, 105, 120 }, scroll = 252766, train = 60, sq = 3, favor = 30, r = { { 2318, 10 }, { 4231, 2 }, { 249427, 2 }, { 2320, 1 }, { 6470, 1 } }, out = { 252429, 1 }, oq = 3, bop = true },
    [1255142] = { name = "Brawler's Leather Belt", t = { 1, 90, 105, 120 }, scroll = 252765, train = 60, sq = 3, favor = 30, r = { { 2318, 10 }, { 4231, 2 }, { 249427, 2 }, { 2320, 1 }, { 1210, 1 } }, out = { 252428, 1 }, oq = 3, bop = true },
    [1263031] = { name = "Tanning Rack", t = { 1, 140, 142, 145 }, scroll = 273096, train = 140, sq = 2, r = { { 2319, 5 }, { 2321, 3 }, { 4470, 2 } }, out = { 279941, 1 }, oq = 1 },
    [1292920] = { name = "Grovekeeper Trousers", t = { 1, 320, 325, 330 }, scroll = 273952, train = 300, sq = 4, r = { { 274030, 5 }, { 15407, 4 }, { 248825, 24 }, { 14341, 8 } }, out = { 273884, 1 }, oq = 1 },
    [1292921] = { name = "Grovekeeper Grips", t = { 1, 320, 325, 330 }, scroll = 273953, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273885, 1 }, oq = 1 },
    [1292923] = { name = "Grovekeeper Shoulderpads", t = { 1, 320, 325, 330 }, scroll = 273954, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273886, 1 }, oq = 1 },
    [1292924] = { name = "Grovekeeper Stompers", t = { 1, 320, 325, 330 }, scroll = 273955, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273887, 1 }, oq = 1 },
    [1292925] = { name = "Grovekeeper Kilt", t = { 1, 320, 325, 330 }, scroll = 273956, train = 300, sq = 4, r = { { 274030, 5 }, { 15407, 4 }, { 248825, 24 }, { 14341, 8 } }, out = { 273888, 1 }, oq = 1 },
    [1292926] = { name = "Grovekeeper Mitts", t = { 1, 320, 325, 330 }, scroll = 273957, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273889, 1 }, oq = 1 },
    [1292927] = { name = "Grovekeeper Mantle", t = { 1, 320, 325, 330 }, scroll = 273958, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273890, 1 }, oq = 1 },
    [1292928] = { name = "Grovekeeper Sandals", t = { 1, 320, 325, 330 }, scroll = 273959, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273891, 1 }, oq = 1 },
    [1292929] = { name = "Grovekeeper Legguards", t = { 1, 320, 325, 330 }, scroll = 273960, train = 300, sq = 4, r = { { 274030, 5 }, { 15407, 4 }, { 248825, 24 }, { 14341, 8 } }, out = { 273892, 1 }, oq = 1 },
    [1292930] = { name = "Grovekeeper Handguards", t = { 1, 320, 325, 330 }, scroll = 273961, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273893, 1 }, oq = 1 },
    [1292931] = { name = "Grovekeeper Pauldrons", t = { 1, 320, 325, 330 }, scroll = 273962, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273894, 1 }, oq = 1 },
    [1292932] = { name = "Grovekeeper Boots", t = { 1, 320, 325, 330 }, scroll = 273963, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273895, 1 }, oq = 1 },
    [1292933] = { name = "Grovekeeper Leggings", t = { 1, 320, 325, 330 }, scroll = 273964, train = 300, sq = 4, r = { { 274030, 5 }, { 15407, 4 }, { 248825, 24 }, { 14341, 8 } }, out = { 273896, 1 }, oq = 1 },
    [1292934] = { name = "Grovekeeper Gauntlets", t = { 1, 320, 325, 330 }, scroll = 273965, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273897, 1 }, oq = 1 },
    [1292935] = { name = "Grovekeeper Spaulders", t = { 1, 320, 325, 330 }, scroll = 273966, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273898, 1 }, oq = 1 },
    [1292936] = { name = "Grovekeeper Treads", t = { 1, 320, 325, 330 }, scroll = 273967, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273899, 1 }, oq = 1 },
    [1292937] = { name = "Wildstalker's Legguards", t = { 1, 320, 325, 330 }, scroll = 273968, train = 300, sq = 4, r = { { 274030, 5 }, { 15407, 4 }, { 248825, 24 }, { 14341, 8 } }, out = { 273900, 1 }, oq = 1 },
    [1292938] = { name = "Wildstalker's Gauntlets", t = { 1, 320, 325, 330 }, scroll = 273969, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273901, 1 }, oq = 1 },
    [1292939] = { name = "Wildstalker's Spaulders", t = { 1, 320, 325, 330 }, scroll = 273970, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273902, 1 }, oq = 1 },
    [1292940] = { name = "Wildstalker's Greaves", t = { 1, 320, 325, 330 }, scroll = 273971, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273903, 1 }, oq = 1 },
    [1292965] = { name = "Grimstitch Pants", t = { 1, 320, 325, 330 }, scroll = 273996, train = 300, sq = 4, r = { { 274030, 5 }, { 15407, 4 }, { 248825, 24 }, { 14341, 8 } }, out = { 273928, 1 }, oq = 1 },
    [1292966] = { name = "Grimstitch Gloves", t = { 1, 320, 325, 330 }, scroll = 273997, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273929, 1 }, oq = 1 },
    [1292967] = { name = "Grimstitch Spaulders", t = { 1, 320, 325, 330 }, scroll = 273998, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273930, 1 }, oq = 1 },
    [1292968] = { name = "Grimstitch Boots", t = { 1, 320, 325, 330 }, scroll = 273999, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273931, 1 }, oq = 1 },
    [1292969] = { name = "Spiritcaller Leggings", t = { 1, 320, 325, 330 }, scroll = 274000, train = 300, sq = 4, r = { { 274030, 5 }, { 15407, 4 }, { 248825, 24 }, { 14341, 8 } }, out = { 273932, 1 }, oq = 1 },
    [1292970] = { name = "Spiritcaller Grips", t = { 1, 320, 325, 330 }, scroll = 274001, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273933, 1 }, oq = 1 },
    [1292971] = { name = "Spiritcaller Spaulders", t = { 1, 320, 325, 330 }, scroll = 274002, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273934, 1 }, oq = 1 },
    [1292972] = { name = "Spiritcaller Treads", t = { 1, 320, 325, 330 }, scroll = 274003, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273935, 1 }, oq = 1 },
    [1292973] = { name = "Spiritcaller Pants", t = { 1, 320, 325, 330 }, scroll = 274004, train = 300, sq = 4, r = { { 274030, 5 }, { 15407, 4 }, { 248825, 24 }, { 14341, 8 } }, out = { 273936, 1 }, oq = 1 },
    [1292974] = { name = "Spiritcaller Gauntlets", t = { 1, 320, 325, 330 }, scroll = 274005, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273937, 1 }, oq = 1 },
    [1292975] = { name = "Spiritcaller Epaulets", t = { 1, 320, 325, 330 }, scroll = 274006, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273938, 1 }, oq = 1 },
    [1292976] = { name = "Spiritcaller Greaves", t = { 1, 320, 325, 330 }, scroll = 274007, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 273939, 1 }, oq = 1 },
    [1297126] = { name = "Bileblister Claws", t = { 1, 290, 292, 295 }, scroll = 275586, train = 285, rep = { 609, 4 }, sq = 3, r = { { 8170, 12 }, { 12810, 3 }, { 7082, 3 }, { 14341, 6 } }, out = { 275610, 1 }, oq = 3 },
    [1297127] = { name = "Bileblister Girdle", t = { 1, 295, 297, 300 }, scroll = 275587, train = 290, rep = { 609, 5 }, sq = 3, r = { { 8170, 18 }, { 12810, 3 }, { 7082, 3 }, { 14341, 6 } }, out = { 275611, 1 }, oq = 3 },
    [1297128] = { name = "Bileblister Boots", t = { 1, 295, 297, 300 }, scroll = 275588, train = 295, rep = { 609, 5 }, sq = 3, r = { { 8170, 15 }, { 12810, 3 }, { 7082, 3 }, { 14341, 6 } }, out = { 275612, 1 }, oq = 3 },
    [1297129] = { name = "Hivethrasher's Claws", t = { 1, 290, 292, 295 }, scroll = 275589, train = 285, rep = { 609, 4 }, sq = 3, r = { { 8170, 12 }, { 12810, 3 }, { 7076, 3 }, { 14341, 6 } }, out = { 275613, 1 }, oq = 3 },
    [1297130] = { name = "Hivethrasher's Girdle", t = { 1, 295, 297, 300 }, scroll = 275590, train = 290, rep = { 609, 5 }, sq = 3, r = { { 8170, 18 }, { 12810, 3 }, { 7076, 3 }, { 14341, 6 } }, out = { 275614, 1 }, oq = 3 },
    [1297131] = { name = "Hivethrasher's Boots", t = { 1, 295, 297, 300 }, scroll = 275591, train = 295, rep = { 609, 5 }, sq = 3, r = { { 8170, 15 }, { 12810, 3 }, { 7076, 3 }, { 14341, 6 } }, out = { 275615, 1 }, oq = 3 },
    [1297132] = { name = "Scalegut Clenchers", t = { 1, 290, 292, 295 }, scroll = 275592, train = 285, rep = { 609, 4 }, sq = 3, r = { { 15408, 5 }, { 12810, 3 }, { 7078, 3 }, { 14341, 6 } }, out = { 275616, 1 }, oq = 3 },
    [1297133] = { name = "Scalegut Belt", t = { 1, 295, 297, 300 }, scroll = 275593, train = 290, rep = { 609, 5 }, sq = 3, r = { { 15408, 7 }, { 12810, 3 }, { 7078, 3 }, { 14341, 6 } }, out = { 275617, 1 }, oq = 3 },
    [1297134] = { name = "Scalegut Treaders", t = { 1, 295, 297, 300 }, scroll = 275594, train = 295, rep = { 609, 5 }, sq = 3, r = { { 15408, 6 }, { 12810, 3 }, { 7078, 3 }, { 14341, 6 } }, out = { 275618, 1 }, oq = 3 },
    [1297135] = { name = "Broodwatcher's Clenchers", t = { 1, 290, 292, 295 }, scroll = 275595, train = 285, rep = { 609, 4 }, sq = 3, r = { { 15408, 5 }, { 12810, 3 }, { 7080, 3 }, { 14341, 6 } }, out = { 275619, 1 }, oq = 3 },
    [1297136] = { name = "Broodwatcher's Belt", t = { 1, 295, 297, 300 }, scroll = 275596, train = 290, rep = { 609, 5 }, sq = 3, r = { { 15408, 7 }, { 12810, 3 }, { 7080, 3 }, { 14341, 6 } }, out = { 275620, 1 }, oq = 3 },
    [1297137] = { name = "Broodwatcher's Treaders", t = { 1, 295, 297, 300 }, scroll = 275597, train = 295, rep = { 609, 5 }, sq = 3, r = { { 15408, 6 }, { 12810, 3 }, { 7080, 3 }, { 14341, 6 } }, out = { 275621, 1 }, oq = 3 },
    [1299914] = { name = "Spiritcaller Kilt", t = { 1, 320, 325, 330 }, scroll = 276542, train = 300, sq = 4, r = { { 274030, 5 }, { 15407, 4 }, { 248825, 24 }, { 14341, 8 } }, out = { 276538, 1 }, oq = 4 },
    [1299915] = { name = "Spiritcaller Gloves", t = { 1, 320, 325, 330 }, scroll = 276543, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 276539, 1 }, oq = 4 },
    [1299916] = { name = "Spiritcaller Mantle", t = { 1, 320, 325, 330 }, scroll = 276544, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 276540, 1 }, oq = 4 },
    [1299917] = { name = "Spiritcaller Boots", t = { 1, 320, 325, 330 }, scroll = 276545, train = 300, sq = 4, r = { { 274030, 3 }, { 15407, 2 }, { 248825, 18 }, { 14341, 8 } }, out = { 276541, 1 }, oq = 4 },
    [1301427] = { name = "Cloudy Gustwoven Harness", t = { 1, 65, 67, 70 }, scroll = 276934, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2318, 7 }, { 4231, 1 }, { 2320, 2 } }, out = { 276998, 1 }, oq = 2 },
    [1301428] = { name = "Cloudy Gustwoven Bracers", t = { 1, 55, 57, 60 }, scroll = 276935, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2318, 4 }, { 2320, 3 } }, out = { 276999, 1 }, oq = 2 },
    [1301429] = { name = "Cloudy Gustwoven Gloves", t = { 1, 60, 62, 65 }, scroll = 276936, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2318, 6 }, { 2320, 4 } }, out = { 277000, 1 }, oq = 2 },
    [1301430] = { name = "Cloudy Gustwoven Belt", t = { 1, 55, 57, 60 }, scroll = 276937, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2318, 5 }, { 2320, 3 } }, out = { 277001, 1 }, oq = 2 },
    [1301431] = { name = "Cloudy Gustwoven Trousers", t = { 1, 65, 67, 70 }, scroll = 276938, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2318, 7 }, { 2320, 2 } }, out = { 277002, 1 }, oq = 2 },
    [1301432] = { name = "Cloudy Gustwoven Boots", t = { 1, 60, 62, 65 }, scroll = 276939, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2318, 6 }, { 2320, 3 } }, out = { 277003, 1 }, oq = 2 },
    [1301433] = { name = "Cloudy Windraveled Jerkin", t = { 1, 65, 67, 70 }, scroll = 276940, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2318, 7 }, { 4231, 1 }, { 2320, 2 } }, out = { 277004, 1 }, oq = 2 },
    [1301434] = { name = "Cloudy Windraveled Armguards", t = { 1, 55, 57, 60 }, scroll = 276941, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2318, 4 }, { 2320, 3 } }, out = { 277005, 1 }, oq = 2 },
    [1301435] = { name = "Cloudy Windraveled Mitts", t = { 1, 60, 62, 65 }, scroll = 276942, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2318, 6 }, { 2320, 4 } }, out = { 277006, 1 }, oq = 2 },
    [1301436] = { name = "Cloudy Windraveled Strap", t = { 1, 55, 57, 60 }, scroll = 276943, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2318, 5 }, { 2320, 3 } }, out = { 277007, 1 }, oq = 2 },
    [1301437] = { name = "Cloudy Windraveled Pants", t = { 1, 65, 67, 70 }, scroll = 276944, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2318, 7 }, { 2320, 2 } }, out = { 277008, 1 }, oq = 2 },
    [1301438] = { name = "Cloudy Windraveled Footwraps", t = { 1, 60, 62, 65 }, scroll = 276945, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2318, 6 }, { 2320, 3 } }, out = { 277009, 1 }, oq = 2 },
    [1301451] = { name = "Azure Gustwoven Harness", t = { 1, 65, 67, 70 }, scroll = 276958, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2318, 7 }, { 4231, 1 }, { 2320, 2 } }, out = { 277022, 1 }, oq = 2 },
    [1301452] = { name = "Azure Gustwoven Bracers", t = { 1, 55, 57, 60 }, scroll = 276959, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2318, 4 }, { 2320, 3 } }, out = { 277023, 1 }, oq = 2 },
    [1301453] = { name = "Azure Gustwoven Gloves", t = { 1, 60, 62, 65 }, scroll = 276960, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2318, 6 }, { 2320, 4 } }, out = { 277024, 1 }, oq = 2 },
    [1301454] = { name = "Azure Gustwoven Belt", t = { 1, 55, 57, 60 }, scroll = 276961, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2318, 5 }, { 2320, 3 } }, out = { 277025, 1 }, oq = 2 },
    [1301455] = { name = "Azure Gustwoven Trousers", t = { 1, 65, 67, 70 }, scroll = 276962, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2318, 7 }, { 2320, 2 } }, out = { 277026, 1 }, oq = 2 },
    [1301456] = { name = "Azure Gustwoven Boots", t = { 1, 60, 62, 65 }, scroll = 276963, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2318, 6 }, { 2320, 3 } }, out = { 277027, 1 }, oq = 2 },
    [1301457] = { name = "Azure Windraveled Jerkin", t = { 1, 65, 67, 70 }, scroll = 276964, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2318, 7 }, { 4231, 1 }, { 2320, 2 } }, out = { 277028, 1 }, oq = 2 },
    [1301458] = { name = "Azure Windraveled Armguards", t = { 1, 55, 57, 60 }, scroll = 276965, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2318, 4 }, { 2320, 3 } }, out = { 277029, 1 }, oq = 2 },
    [1301459] = { name = "Azure Windraveled Mitts", t = { 1, 60, 62, 65 }, scroll = 276966, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2318, 6 }, { 2320, 4 } }, out = { 277030, 1 }, oq = 2 },
    [1301460] = { name = "Azure Windraveled Strap", t = { 1, 55, 57, 60 }, scroll = 276967, train = 50, scrollPrice = 950, rep = { 2758, 4 }, sq = 2, r = { { 2318, 5 }, { 2320, 3 } }, out = { 277031, 1 }, oq = 2 },
    [1301461] = { name = "Azure Windraveled Pants", t = { 1, 65, 67, 70 }, scroll = 276968, train = 60, scrollPrice = 1250, rep = { 2758, 5 }, sq = 2, r = { { 2318, 7 }, { 2320, 2 } }, out = { 277032, 1 }, oq = 2 },
    [1301462] = { name = "Azure Windraveled Footwraps", t = { 1, 60, 62, 65 }, scroll = 276969, train = 55, scrollPrice = 1100, rep = { 2758, 4 }, sq = 2, r = { { 2318, 6 }, { 2320, 3 } }, out = { 277033, 1 }, oq = 2 },
    [1301528] = { name = "Cloudy Gustwoven Hood", t = { 1, 185, 187, 190 }, scroll = 276978, train = 175, scrollPrice = 100000, rep = { 2787, 4 }, sq = 2, r = { { 4234, 15 }, { 4236, 3 }, { 8343, 1 }, { 2324, 8 } }, out = { 277042, 1 }, oq = 2 },
    [1301529] = { name = "Cloudy Gustwoven Spaulders", t = { 1, 185, 187, 190 }, scroll = 276979, train = 175, scrollPrice = 100000, rep = { 2787, 4 }, sq = 2, r = { { 4234, 12 }, { 4236, 2 }, { 8343, 1 }, { 2324, 6 } }, out = { 277043, 1 }, oq = 2 },
    [1301530] = { name = "Cloudy Windraveled Cover", t = { 1, 185, 187, 190 }, scroll = 276980, train = 175, scrollPrice = 100000, rep = { 2787, 4 }, sq = 2, r = { { 4234, 15 }, { 4236, 3 }, { 8343, 1 }, { 2324, 8 } }, out = { 277044, 1 }, oq = 2 },
    [1301531] = { name = "Cloudy Windraveled Drapes", t = { 1, 185, 187, 190 }, scroll = 276981, train = 175, scrollPrice = 100000, rep = { 2787, 4 }, sq = 2, r = { { 4234, 12 }, { 4236, 2 }, { 8343, 1 }, { 2324, 6 } }, out = { 277045, 1 }, oq = 2 },
    [1301536] = { name = "Azure Gustwoven Hood", t = { 1, 185, 187, 190 }, scroll = 276986, train = 175, scrollPrice = 100000, rep = { 2740, 4 }, sq = 2, r = { { 4234, 15 }, { 4236, 3 }, { 8343, 1 }, { 6260, 4 } }, out = { 277050, 1 }, oq = 2 },
    [1301537] = { name = "Azure Gustwoven Spaulders", t = { 1, 185, 187, 190 }, scroll = 276987, train = 175, scrollPrice = 100000, rep = { 2740, 4 }, sq = 2, r = { { 4234, 12 }, { 4236, 2 }, { 8343, 1 }, { 6260, 3 } }, out = { 277051, 1 }, oq = 2 },
    [1301538] = { name = "Azure Windraveled Cover", t = { 1, 185, 187, 190 }, scroll = 276988, train = 175, scrollPrice = 100000, rep = { 2740, 4 }, sq = 2, r = { { 4234, 15 }, { 4236, 3 }, { 8343, 1 }, { 6260, 4 } }, out = { 277052, 1 }, oq = 2 },
    [1301539] = { name = "Azure Windraveled Drapes", t = { 1, 185, 187, 190 }, scroll = 276989, train = 175, scrollPrice = 100000, rep = { 2740, 4 }, sq = 2, r = { { 4234, 12 }, { 4236, 2 }, { 8343, 1 }, { 6260, 3 } }, out = { 277053, 1 }, oq = 2 },
    [1302604] = { name = "Light Leather Reagent Bag", t = { 1, 40, 45, 50 }, scroll = 277716, train = 30, scrollPrice = 150, sq = 2, r = { { 2318, 8 }, { 4231, 1 }, { 2320, 3 } }, out = { 277715, 1 }, oq = 1 },
    [1306526] = { name = "Elderwild Waistcord", t = { 1, 310, 317, 325 }, scroll = 279301, train = 300, sq = 4, r = { { 274030, 2 }, { 248824, 1 }, { 248825, 12 } }, out = { 279252, 1 }, oq = 4 },
    [1306527] = { name = "Outlaw's Collar", t = { 1, 310, 317, 325 }, scroll = 279302, train = 300, sq = 4, r = { { 274030, 3 }, { 248824, 2 }, { 248825, 22 } }, out = { 279253, 1 }, oq = 4 },
    [1306528] = { name = "Elderwild Pants", t = { 1, 310, 317, 325 }, scroll = 279303, train = 300, sq = 4, r = { { 274030, 3 }, { 248824, 2 }, { 248825, 18 } }, out = { 279254, 1 }, oq = 4 },
    [1306529] = { name = "Eternity Pauldrons", t = { 1, 310, 317, 325 }, scroll = 279304, train = 300, sq = 4, r = { { 274030, 2 }, { 248824, 1 }, { 248825, 12 } }, out = { 279255, 1 }, oq = 4 },
    [1306530] = { name = "Tranquil Wristguards", t = { 1, 310, 317, 325 }, scroll = 279305, train = 300, sq = 4, r = { { 274030, 1 }, { 248824, 1 }, { 248825, 10 } }, out = { 279256, 1 }, oq = 4 },
    [1306531] = { name = "Mourning Handguards", t = { 1, 310, 317, 325 }, scroll = 279306, train = 300, sq = 4, r = { { 274030, 2 }, { 248824, 1 }, { 248825, 12 } }, out = { 279257, 1 }, oq = 4 },
    [1306532] = { name = "Wild Leather Armor Kit", t = { 1, 310, 317, 325 }, scroll = 279307, train = 300, sq = 4, r = { { 248825, 22 }, { 14341, 3 } }, out = { 279258, 1 }, oq = 3 },
    [10482] = { name = "Cured Thick Hide", intermediate = true, t = { 1, 175, 175, 175 }, train = 175, r = { { 8169, 1 }, { 8150, 1 } }, out = { 8172, 1 } }, -- no da puntos: solo para fabricar el material
    [22331] = { name = "Rugged Leather", intermediate = true, t = { 1, 225, 225, 225 }, train = 225, r = { { 4304, 6 } }, out = { 8170, 1 } }, -- no da puntos: solo para fabricar el material
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
ES.Data.VendorPrices[2321] = 100
ES.Data.VendorPrices[2324] = 25
ES.Data.VendorPrices[2325] = 1000
ES.Data.VendorPrices[2605] = 100
ES.Data.VendorPrices[3385] = 120
ES.Data.VendorPrices[4289] = 50
ES.Data.VendorPrices[4291] = 500
ES.Data.VendorPrices[4340] = 350
ES.Data.VendorPrices[4470] = 38
ES.Data.VendorPrices[6260] = 50
ES.Data.VendorPrices[6261] = 1000
ES.Data.VendorPrices[8343] = 2000
ES.Data.VendorPrices[10940] = 800
ES.Data.VendorPrices[14341] = 5000
ES.Data.SellPrices[783] = 50
ES.Data.SellPrices[1206] = 400
ES.Data.SellPrices[1210] = 250
ES.Data.SellPrices[1529] = 700
ES.Data.SellPrices[2300] = 192
ES.Data.SellPrices[2302] = 29
ES.Data.SellPrices[2303] = 71
ES.Data.SellPrices[2304] = 15
ES.Data.SellPrices[2307] = 195
ES.Data.SellPrices[2308] = 267
ES.Data.SellPrices[2309] = 217
ES.Data.SellPrices[2310] = 112
ES.Data.SellPrices[2311] = 150
ES.Data.SellPrices[2312] = 181
ES.Data.SellPrices[2313] = 200
ES.Data.SellPrices[2314] = 743
ES.Data.SellPrices[2315] = 307
ES.Data.SellPrices[2316] = 408
ES.Data.SellPrices[2317] = 689
ES.Data.SellPrices[2318] = 15
ES.Data.SellPrices[2319] = 50
ES.Data.SellPrices[2320] = 2
ES.Data.SellPrices[2321] = 25
ES.Data.SellPrices[2324] = 6
ES.Data.SellPrices[2325] = 250
ES.Data.SellPrices[2454] = 20
ES.Data.SellPrices[2455] = 10
ES.Data.SellPrices[2457] = 15
ES.Data.SellPrices[2458] = 15
ES.Data.SellPrices[2459] = 25
ES.Data.SellPrices[2605] = 25
ES.Data.SellPrices[2934] = 7
ES.Data.SellPrices[2997] = 100
ES.Data.SellPrices[3182] = 387
ES.Data.SellPrices[3356] = 30
ES.Data.SellPrices[3383] = 100
ES.Data.SellPrices[3385] = 30
ES.Data.SellPrices[3389] = 40
ES.Data.SellPrices[3390] = 35
ES.Data.SellPrices[3391] = 20
ES.Data.SellPrices[3719] = 1027
ES.Data.SellPrices[3824] = 150
ES.Data.SellPrices[3827] = 120
ES.Data.SellPrices[3864] = 800
ES.Data.SellPrices[4096] = 608
ES.Data.SellPrices[4231] = 110
ES.Data.SellPrices[4232] = 125
ES.Data.SellPrices[4233] = 200
ES.Data.SellPrices[4234] = 150
ES.Data.SellPrices[4235] = 200
ES.Data.SellPrices[4236] = 225
ES.Data.SellPrices[4237] = 34
ES.Data.SellPrices[4239] = 71
ES.Data.SellPrices[4242] = 347
ES.Data.SellPrices[4243] = 461
ES.Data.SellPrices[4244] = 723
ES.Data.SellPrices[4246] = 125
ES.Data.SellPrices[4247] = 1049
ES.Data.SellPrices[4248] = 791
ES.Data.SellPrices[4249] = 703
ES.Data.SellPrices[4250] = 705
ES.Data.SellPrices[4251] = 659
ES.Data.SellPrices[4252] = 1457
ES.Data.SellPrices[4253] = 962
ES.Data.SellPrices[4254] = 1071
ES.Data.SellPrices[4255] = 2366
ES.Data.SellPrices[4256] = 3477
ES.Data.SellPrices[4257] = 1311
ES.Data.SellPrices[4258] = 1592
ES.Data.SellPrices[4259] = 1934
ES.Data.SellPrices[4260] = 2559
ES.Data.SellPrices[4262] = 2652
ES.Data.SellPrices[4264] = 2804
ES.Data.SellPrices[4265] = 650
ES.Data.SellPrices[4289] = 12
ES.Data.SellPrices[4291] = 125
ES.Data.SellPrices[4304] = 300
ES.Data.SellPrices[4305] = 600
ES.Data.SellPrices[4337] = 750
ES.Data.SellPrices[4338] = 250
ES.Data.SellPrices[4340] = 87
ES.Data.SellPrices[4455] = 3096
ES.Data.SellPrices[4456] = 1553
ES.Data.SellPrices[4461] = 208
ES.Data.SellPrices[4470] = 9
ES.Data.SellPrices[5081] = 250
ES.Data.SellPrices[5082] = 25
ES.Data.SellPrices[5116] = 303
ES.Data.SellPrices[5373] = 72
ES.Data.SellPrices[5498] = 200
ES.Data.SellPrices[5500] = 750
ES.Data.SellPrices[5633] = 150
ES.Data.SellPrices[5637] = 75
ES.Data.SellPrices[5739] = 2738
ES.Data.SellPrices[5780] = 260
ES.Data.SellPrices[5781] = 601
ES.Data.SellPrices[5782] = 3211
ES.Data.SellPrices[5783] = 2316
ES.Data.SellPrices[5784] = 75
ES.Data.SellPrices[5785] = 500
ES.Data.SellPrices[5957] = 40
ES.Data.SellPrices[5958] = 829
ES.Data.SellPrices[5961] = 1089
ES.Data.SellPrices[5962] = 2794
ES.Data.SellPrices[5963] = 3151
ES.Data.SellPrices[5964] = 2609
ES.Data.SellPrices[5965] = 2536
ES.Data.SellPrices[5966] = 1374
ES.Data.SellPrices[6260] = 12
ES.Data.SellPrices[6261] = 250
ES.Data.SellPrices[6466] = 413
ES.Data.SellPrices[6467] = 420
ES.Data.SellPrices[6468] = 658
ES.Data.SellPrices[6470] = 20
ES.Data.SellPrices[6471] = 500
ES.Data.SellPrices[6662] = 95
ES.Data.SellPrices[6709] = 545
ES.Data.SellPrices[7067] = 400
ES.Data.SellPrices[7069] = 400
ES.Data.SellPrices[7070] = 400
ES.Data.SellPrices[7071] = 100
ES.Data.SellPrices[7075] = 400
ES.Data.SellPrices[7076] = 400
ES.Data.SellPrices[7077] = 400
ES.Data.SellPrices[7078] = 400
ES.Data.SellPrices[7079] = 400
ES.Data.SellPrices[7080] = 400
ES.Data.SellPrices[7082] = 400
ES.Data.SellPrices[7276] = 34
ES.Data.SellPrices[7277] = 28
ES.Data.SellPrices[7278] = 25
ES.Data.SellPrices[7279] = 25
ES.Data.SellPrices[7280] = 162
ES.Data.SellPrices[7281] = 84
ES.Data.SellPrices[7282] = 599
ES.Data.SellPrices[7283] = 519
ES.Data.SellPrices[7284] = 586
ES.Data.SellPrices[7285] = 588
ES.Data.SellPrices[7286] = 25
ES.Data.SellPrices[7287] = 100
ES.Data.SellPrices[7348] = 690
ES.Data.SellPrices[7349] = 861
ES.Data.SellPrices[7352] = 1306
ES.Data.SellPrices[7358] = 885
ES.Data.SellPrices[7359] = 978
ES.Data.SellPrices[7371] = 500
ES.Data.SellPrices[7372] = 500
ES.Data.SellPrices[7373] = 3097
ES.Data.SellPrices[7374] = 3760
ES.Data.SellPrices[7375] = 3773
ES.Data.SellPrices[7377] = 2269
ES.Data.SellPrices[7378] = 2146
ES.Data.SellPrices[7386] = 2387
ES.Data.SellPrices[7387] = 2587
ES.Data.SellPrices[7390] = 4237
ES.Data.SellPrices[7391] = 4253
ES.Data.SellPrices[7392] = 200
ES.Data.SellPrices[7428] = 250
ES.Data.SellPrices[7971] = 1000
ES.Data.SellPrices[8146] = 500
ES.Data.SellPrices[8150] = 250
ES.Data.SellPrices[8151] = 250
ES.Data.SellPrices[8152] = 500
ES.Data.SellPrices[8153] = 5
ES.Data.SellPrices[8154] = 250
ES.Data.SellPrices[8165] = 500
ES.Data.SellPrices[8167] = 100
ES.Data.SellPrices[8168] = 100
ES.Data.SellPrices[8169] = 500
ES.Data.SellPrices[8170] = 500
ES.Data.SellPrices[8171] = 500
ES.Data.SellPrices[8172] = 500
ES.Data.SellPrices[8173] = 1000
ES.Data.SellPrices[8174] = 4131
ES.Data.SellPrices[8175] = 3881
ES.Data.SellPrices[8176] = 2922
ES.Data.SellPrices[8185] = 10952
ES.Data.SellPrices[8187] = 3477
ES.Data.SellPrices[8189] = 7567
ES.Data.SellPrices[8191] = 7780
ES.Data.SellPrices[8192] = 4782
ES.Data.SellPrices[8193] = 8708
ES.Data.SellPrices[8195] = 5263
ES.Data.SellPrices[8197] = 7158
ES.Data.SellPrices[8198] = 4013
ES.Data.SellPrices[8200] = 7275
ES.Data.SellPrices[8201] = 5350
ES.Data.SellPrices[8202] = 9022
ES.Data.SellPrices[8203] = 8628
ES.Data.SellPrices[8204] = 4676
ES.Data.SellPrices[8205] = 4346
ES.Data.SellPrices[8206] = 12704
ES.Data.SellPrices[8207] = 8978
ES.Data.SellPrices[8208] = 10272
ES.Data.SellPrices[8209] = 8375
ES.Data.SellPrices[8210] = 5537
ES.Data.SellPrices[8211] = 8002
ES.Data.SellPrices[8212] = 11585
ES.Data.SellPrices[8213] = 8150
ES.Data.SellPrices[8214] = 6230
ES.Data.SellPrices[8215] = 9017
ES.Data.SellPrices[8216] = 6323
ES.Data.SellPrices[8217] = 1000
ES.Data.SellPrices[8218] = 1000
ES.Data.SellPrices[8343] = 500
ES.Data.SellPrices[8345] = 7421
ES.Data.SellPrices[8346] = 5363
ES.Data.SellPrices[8347] = 5979
ES.Data.SellPrices[8348] = 10819
ES.Data.SellPrices[8349] = 14478
ES.Data.SellPrices[8367] = 18455
ES.Data.SellPrices[8368] = 1000
ES.Data.SellPrices[8949] = 200
ES.Data.SellPrices[8951] = 200
ES.Data.SellPrices[9206] = 700
ES.Data.SellPrices[10940] = 1
ES.Data.SellPrices[11083] = 1
ES.Data.SellPrices[11137] = 1
ES.Data.SellPrices[11176] = 1
ES.Data.SellPrices[12361] = 7000
ES.Data.SellPrices[12364] = 10000
ES.Data.SellPrices[12607] = 8048
ES.Data.SellPrices[12624] = 20642
ES.Data.SellPrices[12632] = 14099
ES.Data.SellPrices[12636] = 24285
ES.Data.SellPrices[12641] = 43836
ES.Data.SellPrices[12799] = 7000
ES.Data.SellPrices[12800] = 10000
ES.Data.SellPrices[12803] = 500
ES.Data.SellPrices[12804] = 2000
ES.Data.SellPrices[12809] = 10000
ES.Data.SellPrices[12810] = 500
ES.Data.SellPrices[12811] = 20000
ES.Data.SellPrices[13423] = 125
ES.Data.SellPrices[13444] = 1500
ES.Data.SellPrices[14044] = 9503
ES.Data.SellPrices[14047] = 400
ES.Data.SellPrices[14048] = 2000
ES.Data.SellPrices[14227] = 2500
ES.Data.SellPrices[14256] = 2000
ES.Data.SellPrices[14341] = 1250
ES.Data.SellPrices[14342] = 4000
ES.Data.SellPrices[15045] = 19938
ES.Data.SellPrices[15046] = 22482
ES.Data.SellPrices[15047] = 29836
ES.Data.SellPrices[15048] = 24409
ES.Data.SellPrices[15049] = 20543
ES.Data.SellPrices[15050] = 26071
ES.Data.SellPrices[15051] = 21736
ES.Data.SellPrices[15052] = 31933
ES.Data.SellPrices[15053] = 9501
ES.Data.SellPrices[15054] = 8007
ES.Data.SellPrices[15055] = 16019
ES.Data.SellPrices[15056] = 20966
ES.Data.SellPrices[15057] = 18728
ES.Data.SellPrices[15058] = 17631
ES.Data.SellPrices[15059] = 24776
ES.Data.SellPrices[15060] = 21277
ES.Data.SellPrices[15061] = 13803
ES.Data.SellPrices[15062] = 25709
ES.Data.SellPrices[15063] = 11701
ES.Data.SellPrices[15064] = 19717
ES.Data.SellPrices[15065] = 22233
ES.Data.SellPrices[15066] = 23650
ES.Data.SellPrices[15067] = 12758
ES.Data.SellPrices[15068] = 21835
ES.Data.SellPrices[15069] = 17012
ES.Data.SellPrices[15070] = 9504
ES.Data.SellPrices[15071] = 11443
ES.Data.SellPrices[15072] = 16233
ES.Data.SellPrices[15073] = 11530
ES.Data.SellPrices[15074] = 6867
ES.Data.SellPrices[15075] = 18449
ES.Data.SellPrices[15076] = 16604
ES.Data.SellPrices[15077] = 7615
ES.Data.SellPrices[15078] = 9649
ES.Data.SellPrices[15079] = 21760
ES.Data.SellPrices[15080] = 18230
ES.Data.SellPrices[15081] = 20261
ES.Data.SellPrices[15082] = 10375
ES.Data.SellPrices[15083] = 6872
ES.Data.SellPrices[15084] = 7311
ES.Data.SellPrices[15085] = 22732
ES.Data.SellPrices[15086] = 13154
ES.Data.SellPrices[15087] = 17892
ES.Data.SellPrices[15088] = 9901
ES.Data.SellPrices[15090] = 22002
ES.Data.SellPrices[15091] = 7195
ES.Data.SellPrices[15092] = 7656
ES.Data.SellPrices[15093] = 8368
ES.Data.SellPrices[15094] = 14155
ES.Data.SellPrices[15095] = 20885
ES.Data.SellPrices[15096] = 17332
ES.Data.SellPrices[15138] = 15198
ES.Data.SellPrices[15141] = 41937
ES.Data.SellPrices[15407] = 500
ES.Data.SellPrices[15408] = 500
ES.Data.SellPrices[15409] = 1000
ES.Data.SellPrices[15410] = 5000
ES.Data.SellPrices[15412] = 500
ES.Data.SellPrices[15414] = 1500
ES.Data.SellPrices[15415] = 500
ES.Data.SellPrices[15416] = 1000
ES.Data.SellPrices[15417] = 500
ES.Data.SellPrices[15419] = 600
ES.Data.SellPrices[15420] = 100
ES.Data.SellPrices[15422] = 500
ES.Data.SellPrices[15423] = 500
ES.Data.SellPrices[15564] = 1000
ES.Data.SellPrices[16982] = 24397
ES.Data.SellPrices[16983] = 25709
ES.Data.SellPrices[16984] = 32653
ES.Data.SellPrices[17010] = 2000
ES.Data.SellPrices[17011] = 2000
ES.Data.SellPrices[17012] = 1000
ES.Data.SellPrices[17721] = 2268
ES.Data.SellPrices[18238] = 3321
ES.Data.SellPrices[18251] = 5000
ES.Data.SellPrices[18504] = 14126
ES.Data.SellPrices[18506] = 21340
ES.Data.SellPrices[18508] = 17194
ES.Data.SellPrices[18509] = 23006
ES.Data.SellPrices[18510] = 20889
ES.Data.SellPrices[18511] = 20971
ES.Data.SellPrices[18512] = 4000
ES.Data.SellPrices[18662] = 5
ES.Data.SellPrices[18948] = 1589
ES.Data.SellPrices[19043] = 13291
ES.Data.SellPrices[19044] = 11116
ES.Data.SellPrices[19048] = 28061
ES.Data.SellPrices[19049] = 15576
ES.Data.SellPrices[19052] = 17621
ES.Data.SellPrices[19058] = 21845
ES.Data.SellPrices[19149] = 21248
ES.Data.SellPrices[19157] = 31943
ES.Data.SellPrices[19162] = 27831
ES.Data.SellPrices[19163] = 27931
ES.Data.SellPrices[19685] = 31644
ES.Data.SellPrices[19686] = 15880
ES.Data.SellPrices[19687] = 15939
ES.Data.SellPrices[19688] = 31993
ES.Data.SellPrices[19689] = 24082
ES.Data.SellPrices[19726] = 500
ES.Data.SellPrices[19767] = 2000
ES.Data.SellPrices[19768] = 2000
ES.Data.SellPrices[20295] = 31083
ES.Data.SellPrices[20296] = 12590
ES.Data.SellPrices[20380] = 57958
ES.Data.SellPrices[20381] = 5000
ES.Data.SellPrices[20476] = 16401
ES.Data.SellPrices[20477] = 16898
ES.Data.SellPrices[20478] = 33917
ES.Data.SellPrices[20479] = 34036
ES.Data.SellPrices[20480] = 17078
ES.Data.SellPrices[20481] = 17139
ES.Data.SellPrices[20498] = 1000
ES.Data.SellPrices[20500] = 2000
ES.Data.SellPrices[20501] = 2000
ES.Data.SellPrices[20575] = 743
ES.Data.SellPrices[21278] = 13212
ES.Data.SellPrices[22661] = 89377
ES.Data.SellPrices[22662] = 44851
ES.Data.SellPrices[22663] = 46175
ES.Data.SellPrices[22664] = 100642
ES.Data.SellPrices[22665] = 50516
ES.Data.SellPrices[22666] = 50712
ES.Data.SellPrices[22682] = 20000
ES.Data.SellPrices[22759] = 29190
ES.Data.SellPrices[22760] = 29302
ES.Data.SellPrices[22761] = 19607
ES.Data.SellPrices[213369] = 280
ES.Data.SellPrices[213379] = 280
ES.Data.SellPrices[248824] = 750
ES.Data.SellPrices[248825] = 750
ES.Data.SellPrices[249409] = 75
ES.Data.SellPrices[249410] = 125
ES.Data.SellPrices[249427] = 125
ES.Data.SellPrices[249428] = 250
ES.Data.SellPrices[249429] = 375
ES.Data.SellPrices[275610] = 11612
ES.Data.SellPrices[275611] = 11655
ES.Data.SellPrices[275612] = 17451
ES.Data.SellPrices[275613] = 11738
ES.Data.SellPrices[275614] = 11780
ES.Data.SellPrices[275615] = 16390
ES.Data.SellPrices[275616] = 13126
ES.Data.SellPrices[275617] = 13176
ES.Data.SellPrices[275618] = 19928
ES.Data.SellPrices[275619] = 13275
ES.Data.SellPrices[275620] = 13325
ES.Data.SellPrices[275621] = 20152
ES.Data.SellPrices[276538] = 40208
ES.Data.SellPrices[276539] = 20181
ES.Data.SellPrices[276540] = 30523
ES.Data.SellPrices[276541] = 30639
ES.Data.SellPrices[277715] = 100
ES.Data.SellPrices[279252] = 15518
ES.Data.SellPrices[279253] = 21404
ES.Data.SellPrices[279254] = 5252
ES.Data.SellPrices[279255] = 22503
ES.Data.SellPrices[279256] = 840
ES.Data.SellPrices[279257] = 17210
ES.Data.SellPrices[279258] = 5000

-- Nombre de cada objeto (inglés, del cliente): se muestra mientras el juego no lo ha cargado
ES.Data.ItemNames = ES.Data.ItemNames or {}
ES.Data.ItemNames[783] = "Light Hide"
ES.Data.ItemNames[1206] = "Moss Agate"
ES.Data.ItemNames[1210] = "Shadowgem"
ES.Data.ItemNames[1529] = "Jade"
ES.Data.ItemNames[2300] = "Embossed Leather Vest"
ES.Data.ItemNames[2302] = "Handstitched Leather Boots"
ES.Data.ItemNames[2303] = "Handstitched Leather Pants"
ES.Data.ItemNames[2304] = "Light Armor Kit"
ES.Data.ItemNames[2307] = "Fine Leather Boots"
ES.Data.ItemNames[2308] = "Fine Leather Cloak"
ES.Data.ItemNames[2309] = "Embossed Leather Boots"
ES.Data.ItemNames[2310] = "Embossed Leather Cloak"
ES.Data.ItemNames[2311] = "White Leather Jerkin"
ES.Data.ItemNames[2312] = "Fine Leather Gloves"
ES.Data.ItemNames[2313] = "Medium Armor Kit"
ES.Data.ItemNames[2314] = "Toughened Leather Armor"
ES.Data.ItemNames[2315] = "Gray Leather Boots"
ES.Data.ItemNames[2316] = "Dark Leather Cloak"
ES.Data.ItemNames[2317] = "Dark Leather Tunic"
ES.Data.ItemNames[2318] = "Light Leather"
ES.Data.ItemNames[2319] = "Medium Leather"
ES.Data.ItemNames[2320] = "Coarse Thread"
ES.Data.ItemNames[2321] = "Fine Thread"
ES.Data.ItemNames[2324] = "Bleach"
ES.Data.ItemNames[2325] = "Black Dye"
ES.Data.ItemNames[2454] = "Elixir of Minor Strength"
ES.Data.ItemNames[2455] = "Minor Mana Potion"
ES.Data.ItemNames[2457] = "Elixir of Minor Agility"
ES.Data.ItemNames[2458] = "Elixir of Minor Fortitude"
ES.Data.ItemNames[2459] = "Swiftness Potion"
ES.Data.ItemNames[2605] = "Green Dye"
ES.Data.ItemNames[2934] = "Ruined Leather Scraps"
ES.Data.ItemNames[2997] = "Bolt of Woolen Cloth"
ES.Data.ItemNames[3182] = "Spider's Silk"
ES.Data.ItemNames[3356] = "Kingsblood"
ES.Data.ItemNames[3383] = "Elixir of Wisdom"
ES.Data.ItemNames[3385] = "Lesser Mana Potion"
ES.Data.ItemNames[3389] = "Elixir of Lesser Defense"
ES.Data.ItemNames[3390] = "Elixir of Lesser Agility"
ES.Data.ItemNames[3391] = "Elixir of Ogre Strength"
ES.Data.ItemNames[3719] = "Hillman's Cloak"
ES.Data.ItemNames[3824] = "Shadow Oil"
ES.Data.ItemNames[3827] = "Mana Potion"
ES.Data.ItemNames[3864] = "Citrine"
ES.Data.ItemNames[4096] = "Coarse Gorilla Hair"
ES.Data.ItemNames[4231] = "Cured Light Hide"
ES.Data.ItemNames[4232] = "Medium Hide"
ES.Data.ItemNames[4233] = "Cured Medium Hide"
ES.Data.ItemNames[4234] = "Heavy Leather"
ES.Data.ItemNames[4235] = "Heavy Hide"
ES.Data.ItemNames[4236] = "Cured Heavy Hide"
ES.Data.ItemNames[4237] = "Handstitched Leather Belt"
ES.Data.ItemNames[4239] = "Embossed Leather Gloves"
ES.Data.ItemNames[4242] = "Embossed Leather Pants"
ES.Data.ItemNames[4243] = "Fine Leather Tunic"
ES.Data.ItemNames[4244] = "Hillman's Leather Vest"
ES.Data.ItemNames[4246] = "Fine Leather Belt"
ES.Data.ItemNames[4247] = "Hillman's Leather Gloves"
ES.Data.ItemNames[4248] = "Dark Leather Gloves"
ES.Data.ItemNames[4249] = "Dark Leather Belt"
ES.Data.ItemNames[4250] = "Hillman's Belt"
ES.Data.ItemNames[4251] = "Hillman's Shoulders"
ES.Data.ItemNames[4252] = "Dark Leather Shoulders"
ES.Data.ItemNames[4253] = "Toughened Leather Gloves"
ES.Data.ItemNames[4254] = "Barbaric Gloves"
ES.Data.ItemNames[4255] = "Green Leather Armor"
ES.Data.ItemNames[4256] = "Guardian Armor"
ES.Data.ItemNames[4257] = "Green Leather Belt"
ES.Data.ItemNames[4258] = "Guardian Belt"
ES.Data.ItemNames[4259] = "Green Leather Bracers"
ES.Data.ItemNames[4260] = "Guardian Leather Bracers"
ES.Data.ItemNames[4262] = "Gem-studded Leather Belt"
ES.Data.ItemNames[4264] = "Barbaric Belt"
ES.Data.ItemNames[4265] = "Heavy Armor Kit"
ES.Data.ItemNames[4289] = "Salt"
ES.Data.ItemNames[4291] = "Silken Thread"
ES.Data.ItemNames[4304] = "Thick Leather"
ES.Data.ItemNames[4305] = "Bolt of Silk Cloth"
ES.Data.ItemNames[4337] = "Thick Spider's Silk"
ES.Data.ItemNames[4338] = "Mageweave Cloth"
ES.Data.ItemNames[4340] = "Gray Dye"
ES.Data.ItemNames[4455] = "Raptor Hide Harness"
ES.Data.ItemNames[4456] = "Raptor Hide Belt"
ES.Data.ItemNames[4461] = "Raptor Hide"
ES.Data.ItemNames[4470] = "Simple Wood"
ES.Data.ItemNames[5081] = "Kodo Hide Bag"
ES.Data.ItemNames[5082] = "Thin Kodo Leather"
ES.Data.ItemNames[5116] = "Long Tail Feather"
ES.Data.ItemNames[5373] = "Lucky Charm"
ES.Data.ItemNames[5498] = "Small Lustrous Pearl"
ES.Data.ItemNames[5500] = "Iridescent Pearl"
ES.Data.ItemNames[5633] = "Great Rage Potion"
ES.Data.ItemNames[5637] = "Large Fang"
ES.Data.ItemNames[5739] = "Barbaric Harness"
ES.Data.ItemNames[5780] = "Murloc Scale Belt"
ES.Data.ItemNames[5781] = "Murloc Scale Breastplate"
ES.Data.ItemNames[5782] = "Thick Murloc Armor"
ES.Data.ItemNames[5783] = "Murloc Scale Bracers"
ES.Data.ItemNames[5784] = "Slimy Murloc Scale"
ES.Data.ItemNames[5785] = "Thick Murloc Scale"
ES.Data.ItemNames[5957] = "Handstitched Leather Vest"
ES.Data.ItemNames[5958] = "Fine Leather Pants"
ES.Data.ItemNames[5961] = "Dark Leather Pants"
ES.Data.ItemNames[5962] = "Guardian Pants"
ES.Data.ItemNames[5963] = "Barbaric Leggings"
ES.Data.ItemNames[5964] = "Barbaric Shoulders"
ES.Data.ItemNames[5965] = "Guardian Cloak"
ES.Data.ItemNames[5966] = "Guardian Gloves"
ES.Data.ItemNames[6260] = "Blue Dye"
ES.Data.ItemNames[6261] = "Orange Dye"
ES.Data.ItemNames[6466] = "Deviate Scale Cloak"
ES.Data.ItemNames[6467] = "Deviate Scale Gloves"
ES.Data.ItemNames[6468] = "Deviate Scale Belt"
ES.Data.ItemNames[6470] = "Deviate Scale"
ES.Data.ItemNames[6471] = "Perfect Deviate Scale"
ES.Data.ItemNames[6662] = "Elixir of Giant Growth"
ES.Data.ItemNames[6709] = "Moonglow Vest"
ES.Data.ItemNames[7067] = "Elemental Earth"
ES.Data.ItemNames[7069] = "Elemental Air"
ES.Data.ItemNames[7070] = "Elemental Water"
ES.Data.ItemNames[7071] = "Iron Buckle"
ES.Data.ItemNames[7075] = "Core of Earth"
ES.Data.ItemNames[7076] = "Essence of Earth"
ES.Data.ItemNames[7077] = "Heart of Fire"
ES.Data.ItemNames[7078] = "Essence of Fire"
ES.Data.ItemNames[7079] = "Globe of Water"
ES.Data.ItemNames[7080] = "Essence of Water"
ES.Data.ItemNames[7082] = "Essence of Air"
ES.Data.ItemNames[7276] = "Handstitched Leather Cloak"
ES.Data.ItemNames[7277] = "Handstitched Leather Bracers"
ES.Data.ItemNames[7278] = "Light Leather Quiver"
ES.Data.ItemNames[7279] = "Small Leather Ammo Pouch"
ES.Data.ItemNames[7280] = "Rugged Leather Pants"
ES.Data.ItemNames[7281] = "Light Leather Bracers"
ES.Data.ItemNames[7282] = "Light Leather Pants"
ES.Data.ItemNames[7283] = "Black Whelp Cloak"
ES.Data.ItemNames[7284] = "Red Whelp Gloves"
ES.Data.ItemNames[7285] = "Nimble Leather Gloves"
ES.Data.ItemNames[7286] = "Black Whelp Scale"
ES.Data.ItemNames[7287] = "Red Whelp Scale"
ES.Data.ItemNames[7348] = "Fletcher's Gloves"
ES.Data.ItemNames[7349] = "Herbalist's Gloves"
ES.Data.ItemNames[7352] = "Earthen Leather Shoulders"
ES.Data.ItemNames[7358] = "Pilferer's Gloves"
ES.Data.ItemNames[7359] = "Heavy Earthen Gloves"
ES.Data.ItemNames[7371] = "Heavy Quiver"
ES.Data.ItemNames[7372] = "Heavy Leather Ammo Pouch"
ES.Data.ItemNames[7373] = "Dusky Leather Leggings"
ES.Data.ItemNames[7374] = "Dusky Leather Armor"
ES.Data.ItemNames[7375] = "Green Whelp Armor"
ES.Data.ItemNames[7377] = "Frost Leather Cloak"
ES.Data.ItemNames[7378] = "Dusky Bracers"
ES.Data.ItemNames[7386] = "Green Whelp Bracers"
ES.Data.ItemNames[7387] = "Dusky Belt"
ES.Data.ItemNames[7390] = "Dusky Boots"
ES.Data.ItemNames[7391] = "Swift Boots"
ES.Data.ItemNames[7392] = "Green Whelp Scale"
ES.Data.ItemNames[7428] = "Shadowcat Hide"
ES.Data.ItemNames[7971] = "Black Pearl"
ES.Data.ItemNames[8146] = "Wicked Claw"
ES.Data.ItemNames[8150] = "Deeprock Salt"
ES.Data.ItemNames[8151] = "Flask of Mojo"
ES.Data.ItemNames[8152] = "Flask of Big Mojo"
ES.Data.ItemNames[8153] = "Wildvine"
ES.Data.ItemNames[8154] = "Scorpid Scale"
ES.Data.ItemNames[8165] = "Worn Dragonscale"
ES.Data.ItemNames[8167] = "Turtle Scale"
ES.Data.ItemNames[8168] = "Jet Black Feather"
ES.Data.ItemNames[8169] = "Thick Hide"
ES.Data.ItemNames[8170] = "Rugged Leather"
ES.Data.ItemNames[8171] = "Rugged Hide"
ES.Data.ItemNames[8172] = "Cured Thick Hide"
ES.Data.ItemNames[8173] = "Thick Armor Kit"
ES.Data.ItemNames[8174] = "Comfortable Leather Hat"
ES.Data.ItemNames[8175] = "Nightscape Tunic"
ES.Data.ItemNames[8176] = "Nightscape Headband"
ES.Data.ItemNames[8185] = "Turtle Scale Leggings"
ES.Data.ItemNames[8187] = "Turtle Scale Gloves"
ES.Data.ItemNames[8189] = "Turtle Scale Breastplate"
ES.Data.ItemNames[8191] = "Turtle Scale Helm"
ES.Data.ItemNames[8192] = "Nightscape Shoulders"
ES.Data.ItemNames[8193] = "Nightscape Pants"
ES.Data.ItemNames[8195] = "Nightscape Cloak"
ES.Data.ItemNames[8197] = "Nightscape Boots"
ES.Data.ItemNames[8198] = "Turtle Scale Bracers"
ES.Data.ItemNames[8200] = "Big Voodoo Robe"
ES.Data.ItemNames[8201] = "Big Voodoo Mask"
ES.Data.ItemNames[8202] = "Big Voodoo Pants"
ES.Data.ItemNames[8203] = "Tough Scorpid Breastplate"
ES.Data.ItemNames[8204] = "Tough Scorpid Gloves"
ES.Data.ItemNames[8205] = "Tough Scorpid Bracers"
ES.Data.ItemNames[8206] = "Tough Scorpid Leggings"
ES.Data.ItemNames[8207] = "Tough Scorpid Shoulders"
ES.Data.ItemNames[8208] = "Tough Scorpid Helm"
ES.Data.ItemNames[8209] = "Tough Scorpid Boots"
ES.Data.ItemNames[8210] = "Wild Leather Shoulders"
ES.Data.ItemNames[8211] = "Wild Leather Vest"
ES.Data.ItemNames[8212] = "Wild Leather Leggings"
ES.Data.ItemNames[8213] = "Wild Leather Boots"
ES.Data.ItemNames[8214] = "Wild Leather Helmet"
ES.Data.ItemNames[8215] = "Wild Leather Cloak"
ES.Data.ItemNames[8216] = "Big Voodoo Cloak"
ES.Data.ItemNames[8217] = "Quickdraw Quiver"
ES.Data.ItemNames[8218] = "Thick Leather Ammo Pouch"
ES.Data.ItemNames[8343] = "Heavy Silken Thread"
ES.Data.ItemNames[8345] = "Wolfshead Helm"
ES.Data.ItemNames[8346] = "Gauntlets of the Sea"
ES.Data.ItemNames[8347] = "Dragonscale Gauntlets"
ES.Data.ItemNames[8348] = "Helm of Fire"
ES.Data.ItemNames[8349] = "Feathered Breastplate"
ES.Data.ItemNames[8367] = "Dragonscale Breastplate"
ES.Data.ItemNames[8368] = "Thick Wolfhide"
ES.Data.ItemNames[8949] = "Elixir of Agility"
ES.Data.ItemNames[8951] = "Elixir of Defense"
ES.Data.ItemNames[9206] = "Elixir of Greater Strength"
ES.Data.ItemNames[10940] = "Strange Dust"
ES.Data.ItemNames[11083] = "Soul Dust"
ES.Data.ItemNames[11137] = "Vision Dust"
ES.Data.ItemNames[11176] = "Dream Dust"
ES.Data.ItemNames[11754] = "Black Diamond"
ES.Data.ItemNames[12361] = "Blue Sapphire"
ES.Data.ItemNames[12364] = "Huge Emerald"
ES.Data.ItemNames[12607] = "Brilliant Chromatic Scale"
ES.Data.ItemNames[12624] = "Wildthorn Mail"
ES.Data.ItemNames[12632] = "Storm Gauntlets"
ES.Data.ItemNames[12636] = "Helm of the Great Chief"
ES.Data.ItemNames[12641] = "Invulnerable Mail"
ES.Data.ItemNames[12753] = "Skin of Shadow"
ES.Data.ItemNames[12799] = "Large Opal"
ES.Data.ItemNames[12800] = "Azerothian Diamond"
ES.Data.ItemNames[12803] = "Living Essence"
ES.Data.ItemNames[12804] = "Powerful Mojo"
ES.Data.ItemNames[12809] = "Guardian Stone"
ES.Data.ItemNames[12810] = "Enchanted Leather"
ES.Data.ItemNames[12811] = "Righteous Orb"
ES.Data.ItemNames[12938] = "Blood of Heroes"
ES.Data.ItemNames[13423] = "Stonescale Oil"
ES.Data.ItemNames[13444] = "Major Mana Potion"
ES.Data.ItemNames[14044] = "Cindercloth Cloak"
ES.Data.ItemNames[14047] = "Runecloth"
ES.Data.ItemNames[14048] = "Bolt of Runecloth"
ES.Data.ItemNames[14227] = "Ironweb Spider Silk"
ES.Data.ItemNames[14256] = "Felcloth"
ES.Data.ItemNames[14341] = "Rune Thread"
ES.Data.ItemNames[14342] = "Mooncloth"
ES.Data.ItemNames[15045] = "Green Dragonscale Breastplate"
ES.Data.ItemNames[15046] = "Green Dragonscale Leggings"
ES.Data.ItemNames[15047] = "Red Dragonscale Breastplate"
ES.Data.ItemNames[15048] = "Blue Dragonscale Breastplate"
ES.Data.ItemNames[15049] = "Blue Dragonscale Shoulders"
ES.Data.ItemNames[15050] = "Black Dragonscale Breastplate"
ES.Data.ItemNames[15051] = "Black Dragonscale Shoulders"
ES.Data.ItemNames[15052] = "Black Dragonscale Leggings"
ES.Data.ItemNames[15053] = "Volcanic Breastplate"
ES.Data.ItemNames[15054] = "Volcanic Leggings"
ES.Data.ItemNames[15055] = "Volcanic Shoulders"
ES.Data.ItemNames[15056] = "Stormshroud Armor"
ES.Data.ItemNames[15057] = "Stormshroud Pants"
ES.Data.ItemNames[15058] = "Stormshroud Shoulders"
ES.Data.ItemNames[15059] = "Living Breastplate"
ES.Data.ItemNames[15060] = "Living Leggings"
ES.Data.ItemNames[15061] = "Living Shoulders"
ES.Data.ItemNames[15062] = "Devilsaur Leggings"
ES.Data.ItemNames[15063] = "Devilsaur Gauntlets"
ES.Data.ItemNames[15064] = "Warbear Harness"
ES.Data.ItemNames[15065] = "Warbear Woolies"
ES.Data.ItemNames[15066] = "Ironfeather Breastplate"
ES.Data.ItemNames[15067] = "Ironfeather Shoulders"
ES.Data.ItemNames[15068] = "Frostsaber Tunic"
ES.Data.ItemNames[15069] = "Frostsaber Leggings"
ES.Data.ItemNames[15070] = "Frostsaber Gloves"
ES.Data.ItemNames[15071] = "Frostsaber Boots"
ES.Data.ItemNames[15072] = "Chimeric Leggings"
ES.Data.ItemNames[15073] = "Chimeric Boots"
ES.Data.ItemNames[15074] = "Chimeric Gloves"
ES.Data.ItemNames[15075] = "Chimeric Vest"
ES.Data.ItemNames[15076] = "Heavy Scorpid Vest"
ES.Data.ItemNames[15077] = "Heavy Scorpid Bracers"
ES.Data.ItemNames[15078] = "Heavy Scorpid Gauntlet"
ES.Data.ItemNames[15079] = "Heavy Scorpid Leggings"
ES.Data.ItemNames[15080] = "Heavy Scorpid Helm"
ES.Data.ItemNames[15081] = "Heavy Scorpid Shoulders"
ES.Data.ItemNames[15082] = "Heavy Scorpid Belt"
ES.Data.ItemNames[15083] = "Wicked Leather Gauntlets"
ES.Data.ItemNames[15084] = "Wicked Leather Bracers"
ES.Data.ItemNames[15085] = "Wicked Leather Armor"
ES.Data.ItemNames[15086] = "Wicked Leather Headband"
ES.Data.ItemNames[15087] = "Wicked Leather Pants"
ES.Data.ItemNames[15088] = "Wicked Leather Belt"
ES.Data.ItemNames[15090] = "Runic Leather Armor"
ES.Data.ItemNames[15091] = "Runic Leather Gauntlets"
ES.Data.ItemNames[15092] = "Runic Leather Bracers"
ES.Data.ItemNames[15093] = "Runic Leather Belt"
ES.Data.ItemNames[15094] = "Runic Leather Headband"
ES.Data.ItemNames[15095] = "Runic Leather Pants"
ES.Data.ItemNames[15096] = "Runic Leather Shoulders"
ES.Data.ItemNames[15138] = "Onyxia Scale Cloak"
ES.Data.ItemNames[15141] = "Onyxia Scale Breastplate"
ES.Data.ItemNames[15407] = "Cured Rugged Hide"
ES.Data.ItemNames[15408] = "Heavy Scorpid Scale"
ES.Data.ItemNames[15409] = "Refined Deeprock Salt"
ES.Data.ItemNames[15410] = "Scale of Onyxia"
ES.Data.ItemNames[15412] = "Green Dragonscale"
ES.Data.ItemNames[15414] = "Red Dragonscale"
ES.Data.ItemNames[15415] = "Blue Dragonscale"
ES.Data.ItemNames[15416] = "Black Dragonscale"
ES.Data.ItemNames[15417] = "Devilsaur Leather"
ES.Data.ItemNames[15419] = "Warbear Leather"
ES.Data.ItemNames[15420] = "Ironfeather"
ES.Data.ItemNames[15422] = "Frostsaber Leather"
ES.Data.ItemNames[15423] = "Chimera Leather"
ES.Data.ItemNames[15564] = "Rugged Armor Kit"
ES.Data.ItemNames[16982] = "Corehound Boots"
ES.Data.ItemNames[16983] = "Molten Helm"
ES.Data.ItemNames[16984] = "Black Dragonscale Boots"
ES.Data.ItemNames[17010] = "Fiery Core"
ES.Data.ItemNames[17011] = "Lava Core"
ES.Data.ItemNames[17012] = "Core Leather"
ES.Data.ItemNames[17721] = "Gloves of the Greatfather"
ES.Data.ItemNames[18238] = "Shadowskin Gloves"
ES.Data.ItemNames[18240] = "Ogre Tannin"
ES.Data.ItemNames[18251] = "Core Armor Kit"
ES.Data.ItemNames[18258] = "Gordok Ogre Suit"
ES.Data.ItemNames[18504] = "Girdle of Insight"
ES.Data.ItemNames[18506] = "Mongoose Boots"
ES.Data.ItemNames[18508] = "Swift Flight Bracers"
ES.Data.ItemNames[18509] = "Chromatic Cloak"
ES.Data.ItemNames[18510] = "Hide of the Wild"
ES.Data.ItemNames[18511] = "Shifting Cloak"
ES.Data.ItemNames[18512] = "Larval Acid"
ES.Data.ItemNames[18662] = "Heavy Leather Ball"
ES.Data.ItemNames[18948] = "Barbaric Bracers"
ES.Data.ItemNames[19043] = "Heavy Timbermaw Belt"
ES.Data.ItemNames[19044] = "Might of the Timbermaw"
ES.Data.ItemNames[19048] = "Heavy Timbermaw Boots"
ES.Data.ItemNames[19049] = "Timbermaw Brawlers"
ES.Data.ItemNames[19052] = "Dawn Treaders"
ES.Data.ItemNames[19058] = "Golden Mantle of the Dawn"
ES.Data.ItemNames[19149] = "Lava Belt"
ES.Data.ItemNames[19157] = "Chromatic Gauntlets"
ES.Data.ItemNames[19162] = "Corehound Belt"
ES.Data.ItemNames[19163] = "Molten Belt"
ES.Data.ItemNames[19685] = "Primal Batskin Jerkin"
ES.Data.ItemNames[19686] = "Primal Batskin Gloves"
ES.Data.ItemNames[19687] = "Primal Batskin Bracers"
ES.Data.ItemNames[19688] = "Blood Tiger Breastplate"
ES.Data.ItemNames[19689] = "Blood Tiger Shoulders"
ES.Data.ItemNames[19726] = "Bloodvine"
ES.Data.ItemNames[19767] = "Primal Bat Leather"
ES.Data.ItemNames[19768] = "Primal Tiger Leather"
ES.Data.ItemNames[20295] = "Blue Dragonscale Leggings"
ES.Data.ItemNames[20296] = "Green Dragonscale Gauntlets"
ES.Data.ItemNames[20380] = "Dreamscale Breastplate"
ES.Data.ItemNames[20381] = "Dreamscale"
ES.Data.ItemNames[20476] = "Sandstalker Bracers"
ES.Data.ItemNames[20477] = "Sandstalker Gauntlets"
ES.Data.ItemNames[20478] = "Sandstalker Breastplate"
ES.Data.ItemNames[20479] = "Spitfire Breastplate"
ES.Data.ItemNames[20480] = "Spitfire Gauntlets"
ES.Data.ItemNames[20481] = "Spitfire Bracers"
ES.Data.ItemNames[20498] = "Silithid Chitin"
ES.Data.ItemNames[20500] = "Light Silithid Carapace"
ES.Data.ItemNames[20501] = "Heavy Silithid Carapace"
ES.Data.ItemNames[20575] = "Black Whelp Tunic"
ES.Data.ItemNames[21278] = "Stormshroud Gloves"
ES.Data.ItemNames[22661] = "Polar Tunic"
ES.Data.ItemNames[22662] = "Polar Gloves"
ES.Data.ItemNames[22663] = "Polar Bracers"
ES.Data.ItemNames[22664] = "Icy Scale Breastplate"
ES.Data.ItemNames[22665] = "Icy Scale Bracers"
ES.Data.ItemNames[22666] = "Icy Scale Gauntlets"
ES.Data.ItemNames[22682] = "Frozen Rune"
ES.Data.ItemNames[22759] = "Bramblewood Helm"
ES.Data.ItemNames[22760] = "Bramblewood Boots"
ES.Data.ItemNames[22761] = "Bramblewood Belt"
ES.Data.ItemNames[213369] = "Faintly Glowing Leather"
ES.Data.ItemNames[213370] = "Irradiated Leather Scraps"
ES.Data.ItemNames[213379] = "Hyperconductive Arcano-Filament"
ES.Data.ItemNames[248824] = "Fel Hide"
ES.Data.ItemNames[248825] = "Fel Leather"
ES.Data.ItemNames[249409] = "Cerulean Dye"
ES.Data.ItemNames[249410] = "Sulfuric Acid"
ES.Data.ItemNames[249427] = "Pristine Leather"
ES.Data.ItemNames[249428] = "Pristine Hide"
ES.Data.ItemNames[249429] = "Pristine Scale"
ES.Data.ItemNames[252428] = "Brawler's Leather Belt"
ES.Data.ItemNames[252429] = "Trapper's Leather Belt"
ES.Data.ItemNames[252430] = "Defender's Leather Belt"
ES.Data.ItemNames[252431] = "Totemic Leather Belt"
ES.Data.ItemNames[252432] = "Stormrider's Leather Belt"
ES.Data.ItemNames[252433] = "Wisdom's Leather Belt"
ES.Data.ItemNames[252436] = "Mystic Medium Armor Kit"
ES.Data.ItemNames[252437] = "Forceful Medium Armor Kit"
ES.Data.ItemNames[252439] = "Brawler's Leather Boots"
ES.Data.ItemNames[252440] = "Trapper's Leather Boots"
ES.Data.ItemNames[252441] = "Defender's Leather Boots"
ES.Data.ItemNames[252442] = "Totemic Leather Boots"
ES.Data.ItemNames[252443] = "Stormrider's Leather Boots"
ES.Data.ItemNames[252444] = "Wisdom's Leather Boots"
ES.Data.ItemNames[252447] = "Defender's Leather Hood"
ES.Data.ItemNames[252448] = "Totemic Leather Hood"
ES.Data.ItemNames[252449] = "Hillman's Leather Boots"
ES.Data.ItemNames[252450] = "Defender's Leather Tunic"
ES.Data.ItemNames[252451] = "Totemic Leather Tunic"
ES.Data.ItemNames[252452] = "Mystic Heavy Armor Kit"
ES.Data.ItemNames[252453] = "Forceful Heavy Armor Kit"
ES.Data.ItemNames[252457] = "Defender's Leather Kilt"
ES.Data.ItemNames[252458] = "Totemic Leather Leggings"
ES.Data.ItemNames[252462] = "Mystic Thick Armor Kit"
ES.Data.ItemNames[252463] = "Forceful Thick Armor Kit"
ES.Data.ItemNames[252467] = "Blue Suede Shoes"
ES.Data.ItemNames[252468] = "Prowler's Leather Boots"
ES.Data.ItemNames[252469] = "Skulker's Leather Boots"
ES.Data.ItemNames[252470] = "Warden's Leather Boots"
ES.Data.ItemNames[252471] = "Skycaller's Leather Boots"
ES.Data.ItemNames[252472] = "Mender's Leather Boots"
ES.Data.ItemNames[252473] = "Prowler's Leather Waistguard"
ES.Data.ItemNames[252474] = "Skulker's Leather Waistguard"
ES.Data.ItemNames[252475] = "Warden's Leather Waistguard"
ES.Data.ItemNames[252476] = "Skycaller's Leather Waistguard"
ES.Data.ItemNames[252477] = "Mender's Leather Waistguard"
ES.Data.ItemNames[252478] = "Blue Suede Pants"
ES.Data.ItemNames[252479] = "Wicked Leather Boots"
ES.Data.ItemNames[252480] = "Blue Suede Armor"
ES.Data.ItemNames[252481] = "Blue Suede Belt"
ES.Data.ItemNames[252482] = "Blue Suede Hat"
ES.Data.ItemNames[252483] = "Dawn Armor"
ES.Data.ItemNames[252484] = "Timbermaw Tunic"
ES.Data.ItemNames[252485] = "Warbear Helm"
ES.Data.ItemNames[252486] = "Ironfeather Leggings"
ES.Data.ItemNames[252487] = "Mystic Rugged Armor Kit"
ES.Data.ItemNames[252488] = "Forceful Rugged Armor Kit"
ES.Data.ItemNames[252494] = "Brawler's Leather Gloves"
ES.Data.ItemNames[252495] = "Trapper's Leather Gloves"
ES.Data.ItemNames[252496] = "Defender's Leather Gloves"
ES.Data.ItemNames[252497] = "Totemic Leather Gloves"
ES.Data.ItemNames[252498] = "Stormrider's Leather Gloves"
ES.Data.ItemNames[252499] = "Wisdom's Leather Gloves"
ES.Data.ItemNames[252504] = "Brawler's Leather Hood"
ES.Data.ItemNames[252505] = "Trapper's Leather Hood"
ES.Data.ItemNames[252506] = "Stormrider's Leather Hood"
ES.Data.ItemNames[252507] = "Wisdom's Leather Hood"
ES.Data.ItemNames[252508] = "Brawler's Leather Tunic"
ES.Data.ItemNames[252509] = "Trapper's Leather Tunic"
ES.Data.ItemNames[252510] = "Stormrider's Leather Tunic"
ES.Data.ItemNames[252511] = "Wisdom's Leather Tunic"
ES.Data.ItemNames[252516] = "Brawler's Leather Legguards"
ES.Data.ItemNames[252517] = "Trapper's Leather Legguards"
ES.Data.ItemNames[252518] = "Stormrider's Leather Kilt"
ES.Data.ItemNames[252519] = "Wisdom's Leather Leggings"
ES.Data.ItemNames[252524] = "Prowler's Leather Gloves"
ES.Data.ItemNames[252525] = "Skulker's Leather Gloves"
ES.Data.ItemNames[252526] = "Stalker's Leather Gloves"
ES.Data.ItemNames[252527] = "Warden's Leather Gloves"
ES.Data.ItemNames[252528] = "Skirmisher's Leather Gloves"
ES.Data.ItemNames[252529] = "Skycaller's Leather Gloves"
ES.Data.ItemNames[252530] = "Mender's Leather Gloves"
ES.Data.ItemNames[252534] = "Prowler's Leather Shoulders"
ES.Data.ItemNames[252535] = "Skulker's Leather Shoulder"
ES.Data.ItemNames[252536] = "Warden's Leather Shoulders"
ES.Data.ItemNames[252537] = "Skycaller's Leather Shoulders"
ES.Data.ItemNames[252538] = "Mender's Leather Shoulders"
ES.Data.ItemNames[252539] = "Prowler's Leather Bracers"
ES.Data.ItemNames[252540] = "Skulker's Leather Bracers"
ES.Data.ItemNames[252541] = "Warden's Leather Bracers"
ES.Data.ItemNames[252542] = "Skycaller's Leather Bracers"
ES.Data.ItemNames[252543] = "Mender's Leather Bracers"
ES.Data.ItemNames[252544] = "Tooled Leather Belt"
ES.Data.ItemNames[252545] = "Tooled Leather Boots"
ES.Data.ItemNames[252546] = "Blue Suede Gloves"
ES.Data.ItemNames[252552] = "Tooled Leather Armor"
ES.Data.ItemNames[252553] = "Tooled Leather Gauntlets"
ES.Data.ItemNames[252554] = "Blue Suede Shoulders"
ES.Data.ItemNames[252555] = "Tooled Leather Crown"
ES.Data.ItemNames[252556] = "Wicked Leather Shoulders"
ES.Data.ItemNames[252557] = "Tooled Leather Bracers"
ES.Data.ItemNames[252558] = "Tooled Leather Epaulets"
ES.Data.ItemNames[252559] = "Blue Suede Bracers"
ES.Data.ItemNames[252560] = "Tooled Leather Pants"
ES.Data.ItemNames[252561] = "Living Crown"
ES.Data.ItemNames[252566] = "Stalker's Mail Shoulders"
ES.Data.ItemNames[252567] = "Skycaller's Mail Shoulders"
ES.Data.ItemNames[252568] = "Skirmisher's Mail Shoulders"
ES.Data.ItemNames[252569] = "Mender's Mail Shoulders"
ES.Data.ItemNames[252570] = "Stalker's Mail Bracers"
ES.Data.ItemNames[252571] = "Skycaller's Mail Bracers"
ES.Data.ItemNames[252572] = "Skirmisher's Mail Bracers"
ES.Data.ItemNames[252573] = "Mender's Mail Bracers"
ES.Data.ItemNames[252574] = "Supple Scorpid Boots"
ES.Data.ItemNames[252575] = "Charged Scorpid Belt"
ES.Data.ItemNames[252576] = "Stalker's Mail Sabatons"
ES.Data.ItemNames[252577] = "Skycaller's Mail Sabatons"
ES.Data.ItemNames[252578] = "Skirmisher's Mail Sabatons"
ES.Data.ItemNames[252579] = "Mender's Mail Sabatons"
ES.Data.ItemNames[252580] = "Supple Scorpid Leggings"
ES.Data.ItemNames[252581] = "Charged Scorpid Helm"
ES.Data.ItemNames[252582] = "Supple Scorpid Bracers"
ES.Data.ItemNames[252583] = "Charged Scorpid Shoulders"
ES.Data.ItemNames[252588] = "Stalker's Mail Belt"
ES.Data.ItemNames[252589] = "Skycaller's Mail Belt"
ES.Data.ItemNames[252590] = "Skirmisher's Mail Belt"
ES.Data.ItemNames[252591] = "Mender's Mail Belt"
ES.Data.ItemNames[252592] = "Supple Scorpid Shoulders"
ES.Data.ItemNames[252593] = "Charged Scorpid Bracers"
ES.Data.ItemNames[252594] = "Heavy Scorpid Boots"
ES.Data.ItemNames[252595] = "Supple Scorpid Belt"
ES.Data.ItemNames[252596] = "Charged Scorpid Gauntlets"
ES.Data.ItemNames[252597] = "Supple Scorpid Helm"
ES.Data.ItemNames[252598] = "Charged Scorpid Vest"
ES.Data.ItemNames[252599] = "Supple Scorpid Vest"
ES.Data.ItemNames[252600] = "Charged Scorpid Leggings"
ES.Data.ItemNames[252601] = "Supple Scorpid Sabatons"
ES.Data.ItemNames[252602] = "Charged Scorpid Boots"
ES.Data.ItemNames[252603] = "Red Dragonscale Leggings"
ES.Data.ItemNames[252604] = "Blue Dragonscale Helm"
ES.Data.ItemNames[252605] = "Black Dragonscale Helm"
ES.Data.ItemNames[252606] = "Pristine Scorpid Leggings"
ES.Data.ItemNames[274030] = "Malleable Essence of Nature"
ES.Data.ItemNames[275610] = "Bileblister Claws"
ES.Data.ItemNames[275611] = "Bileblister Girdle"
ES.Data.ItemNames[275612] = "Bileblister Boots"
ES.Data.ItemNames[275613] = "Hivethrasher's Claws"
ES.Data.ItemNames[275614] = "Hivethrasher's Girdle"
ES.Data.ItemNames[275615] = "Hivethrasher's Boots"
ES.Data.ItemNames[275616] = "Scalegut Clenchers"
ES.Data.ItemNames[275617] = "Scalegut Belt"
ES.Data.ItemNames[275618] = "Scalegut Treaders"
ES.Data.ItemNames[275619] = "Broodwatcher's Clenchers"
ES.Data.ItemNames[275620] = "Broodwatcher's Belt"
ES.Data.ItemNames[275621] = "Broodwatcher's Treaders"
ES.Data.ItemNames[276538] = "Spiritcaller Kilt"
ES.Data.ItemNames[276539] = "Spiritcaller Gloves"
ES.Data.ItemNames[276540] = "Spiritcaller Mantle"
ES.Data.ItemNames[276541] = "Spiritcaller Boots"
ES.Data.ItemNames[276998] = "Cloudy Gustwoven Harness"
ES.Data.ItemNames[276999] = "Cloudy Gustwoven Bracers"
ES.Data.ItemNames[277000] = "Cloudy Gustwoven Gloves"
ES.Data.ItemNames[277001] = "Cloudy Gustwoven Belt"
ES.Data.ItemNames[277002] = "Cloudy Gustwoven Trousers"
ES.Data.ItemNames[277003] = "Cloudy Gustwoven Boots"
ES.Data.ItemNames[277004] = "Cloudy Windraveled Jerkin"
ES.Data.ItemNames[277005] = "Cloudy Windraveled Armguards"
ES.Data.ItemNames[277006] = "Cloudy Windraveled Mitts"
ES.Data.ItemNames[277007] = "Cloudy Windraveled Strap"
ES.Data.ItemNames[277008] = "Cloudy Windraveled Pants"
ES.Data.ItemNames[277009] = "Cloudy Windraveled Footwraps"
ES.Data.ItemNames[277022] = "Azure Gustwoven Harness"
ES.Data.ItemNames[277023] = "Azure Gustwoven Bracers"
ES.Data.ItemNames[277024] = "Azure Gustwoven Gloves"
ES.Data.ItemNames[277025] = "Azure Gustwoven Belt"
ES.Data.ItemNames[277026] = "Azure Gustwoven Trousers"
ES.Data.ItemNames[277027] = "Azure Gustwoven Boots"
ES.Data.ItemNames[277028] = "Azure Windraveled Jerkin"
ES.Data.ItemNames[277029] = "Azure Windraveled Armguards"
ES.Data.ItemNames[277030] = "Azure Windraveled Mitts"
ES.Data.ItemNames[277031] = "Azure Windraveled Strap"
ES.Data.ItemNames[277032] = "Azure Windraveled Pants"
ES.Data.ItemNames[277033] = "Azure Windraveled Footwraps"
ES.Data.ItemNames[277042] = "Cloudy Gustwoven Hood"
ES.Data.ItemNames[277043] = "Cloudy Gustwoven Spaulders"
ES.Data.ItemNames[277044] = "Cloudy Windraveled Cover"
ES.Data.ItemNames[277045] = "Cloudy Windraveled Drapes"
ES.Data.ItemNames[277050] = "Azure Gustwoven Hood"
ES.Data.ItemNames[277051] = "Azure Gustwoven Spaulders"
ES.Data.ItemNames[277052] = "Azure Windraveled Cover"
ES.Data.ItemNames[277053] = "Azure Windraveled Drapes"
ES.Data.ItemNames[277715] = "Light Leather Reagent Bag"
ES.Data.ItemNames[279252] = "Elderwild Waistcord"
ES.Data.ItemNames[279253] = "Outlaw's Collar"
ES.Data.ItemNames[279254] = "Elderwild Pants"
ES.Data.ItemNames[279255] = "Eternity Pauldrons"
ES.Data.ItemNames[279256] = "Tranquil Wristguards"
ES.Data.ItemNames[279257] = "Mourning Handguards"
ES.Data.ItemNames[279258] = "Wild Leather Armor Kit"
ES.Data.ItemNames[279941] = "Tanning Rack"
ES.Data.ItemNames[279978] = "Camp Tent"

-- Material -> profesión de recolección que lo consigue (393 Desuello, 182 Herboristería, 186 Minería).
-- Sin uso por ahora: reservado para la vía "Vender en bruto" de Ganar dinero (docs/PLAN.md, G1).
ES.Data.GatheredBy = ES.Data.GatheredBy or {}
ES.Data.GatheredBy[783] = 393
ES.Data.GatheredBy[2318] = 393
ES.Data.GatheredBy[2319] = 393
ES.Data.GatheredBy[2934] = 393
ES.Data.GatheredBy[3356] = 182
ES.Data.GatheredBy[4232] = 393
ES.Data.GatheredBy[4234] = 393
ES.Data.GatheredBy[4235] = 393
ES.Data.GatheredBy[4304] = 393
ES.Data.GatheredBy[4461] = 393
ES.Data.GatheredBy[5082] = 393
ES.Data.GatheredBy[5116] = 393
ES.Data.GatheredBy[5784] = 393
ES.Data.GatheredBy[5785] = 393
ES.Data.GatheredBy[6470] = 393
ES.Data.GatheredBy[6471] = 393
ES.Data.GatheredBy[7286] = 393
ES.Data.GatheredBy[7287] = 393
ES.Data.GatheredBy[7392] = 393
ES.Data.GatheredBy[7428] = 393
ES.Data.GatheredBy[8150] = 186
ES.Data.GatheredBy[8153] = 182
ES.Data.GatheredBy[8154] = 393
ES.Data.GatheredBy[8165] = 393
ES.Data.GatheredBy[8167] = 393
ES.Data.GatheredBy[8168] = 393
ES.Data.GatheredBy[8169] = 393
ES.Data.GatheredBy[8170] = 393
ES.Data.GatheredBy[8171] = 393
ES.Data.GatheredBy[8368] = 393
ES.Data.GatheredBy[12607] = 393
ES.Data.GatheredBy[12809] = 186
ES.Data.GatheredBy[15408] = 393
ES.Data.GatheredBy[15409] = 393
ES.Data.GatheredBy[15410] = 393
ES.Data.GatheredBy[15412] = 393
ES.Data.GatheredBy[15414] = 393
ES.Data.GatheredBy[15415] = 393
ES.Data.GatheredBy[15416] = 393
ES.Data.GatheredBy[15417] = 393
ES.Data.GatheredBy[15419] = 393
ES.Data.GatheredBy[15420] = 393
ES.Data.GatheredBy[15422] = 393
ES.Data.GatheredBy[15423] = 393
ES.Data.GatheredBy[17012] = 393
ES.Data.GatheredBy[19726] = 182
ES.Data.GatheredBy[19767] = 393
ES.Data.GatheredBy[19768] = 393
ES.Data.GatheredBy[20381] = 393
ES.Data.GatheredBy[20498] = 393
ES.Data.GatheredBy[20500] = 393
ES.Data.GatheredBy[20501] = 393
ES.Data.GatheredBy[213370] = 393
ES.Data.GatheredBy[248824] = 393
ES.Data.GatheredBy[248825] = 393
ES.Data.GatheredBy[249427] = 393
ES.Data.GatheredBy[249428] = 393
ES.Data.GatheredBy[249429] = 393

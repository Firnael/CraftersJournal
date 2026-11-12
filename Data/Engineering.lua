-- Generado por tools/gen_profession.py (Engineering). No editar a mano.
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
ES.Data.Engineering = {
  skillLine = 202,
  ranks = { -- { tope, precio, habilidad requerida, nivel de personaje }
    { 150, 450, 50, 10 },
    { 225, 4500, 125, 20 },
    { 300, 45000, 200, 35 },
  },
  -- { PNJ instructor, rangos que enseña: 1 aprendiz (75), 2 oficial (150), 4 experto (225), 8 artesano (300) }
  trainers = { { 1676, 2 }, { 1702, 1 }, { 2857, 1 }, { 3290, 1 }, { 3412, 2 }, { 3494, 1 }, { 4586, 1 }, { 5174, 4 }, { 5518, 2 }, { 8736, 8 }, { 10993, 1 }, { 11017, 4 }, { 11025, 1 }, { 11026, 1 }, { 11028, 1 }, { 11029, 2 }, { 11031, 2 }, { 11037, 1 }, { 249235, 8 }, { 251684, 1 } },
  recipes = {
    [3918] = { name = "Rough Blasting Powder", t = { 1, 20, 30, 40 }, basic = true, r = { { 2835, 1 } }, out = { 4357, 1 }, oq = 1 },
    [3919] = { name = "Rough Dynamite", t = { 1, 30, 45, 60 }, basic = true, r = { { 4357, 1 }, { 2589, 1 } }, out = { 4358, 2 }, oq = 1 },
    [3920] = { name = "Crafted Light Shot", t = { 1, 30, 45, 60 }, basic = true, r = { { 4357, 1 }, { 2840, 1 } }, out = { 8067, 200 }, oq = 1 },
    [3922] = { name = "Handful of Copper Bolts", t = { 1, 45, 52, 60 }, fee = 115, train = 30, r = { { 2840, 1 } }, tool = 162, out = { 4359, 1 }, oq = 1 },
    [3923] = { name = "Rough Copper Bomb", t = { 1, 60, 75, 90 }, fee = 130, train = 30, r = { { 2840, 1 }, { 4359, 1 }, { 4357, 2 }, { 2589, 1 } }, tool = 162, out = { 4360, 2 }, oq = 1 },
    [3924] = { name = "Copper Tube", t = { 1, 80, 95, 110 }, fee = 150, train = 50, r = { { 2840, 2 }, { 2880, 1 } }, tool = 162, out = { 4361, 1 }, oq = 1 },
    [3925] = { name = "Rough Boomstick", t = { 1, 80, 95, 110 }, fee = 150, train = 50, r = { { 4361, 1 }, { 4359, 1 }, { 4399, 1 } }, tool = 162, out = { 4362, 1 }, oq = 2 },
    [3926] = { name = "Copper Modulator", t = { 1, 95, 110, 125 }, fee = 225, train = 65, r = { { 4359, 2 }, { 2840, 1 }, { 2589, 2 } }, tool = 162, out = { 4363, 1 }, oq = 1 },
    [3928] = { name = "Mechanical Squirrel", t = { 1, 105, 120, 135 }, scroll = 4408, train = 75, sq = 2, r = { { 4363, 1 }, { 4359, 1 }, { 2840, 1 }, { 774, 2 } }, tool = 162, out = { 4401, 1 }, oq = 1 },
    [3929] = { name = "Coarse Blasting Powder", t = { 1, 85, 90, 95 }, fee = 250, train = 75, r = { { 2836, 1 } }, out = { 4364, 1 }, oq = 1 },
    [3930] = { name = "Crafted Heavy Shot", t = { 1, 85, 90, 95 }, fee = 250, train = 75, r = { { 4364, 1 }, { 2840, 1 } }, out = { 8068, 200 }, oq = 1 },
    [3931] = { name = "Coarse Dynamite", t = { 1, 90, 97, 105 }, fee = 250, train = 75, r = { { 4364, 3 }, { 2589, 1 } }, out = { 4365, 2 }, oq = 1 },
    [3932] = { name = "Target Dummy", t = { 1, 115, 130, 145 }, fee = 300, train = 85, r = { { 4363, 1 }, { 4359, 2 }, { 2841, 1 }, { 2592, 1 } }, tool = 162, out = { 4366, 1 }, oq = 1 },
    [3933] = { name = "Small Seaforium Charge", t = { 1, 130, 145, 160 }, scroll = 4409, train = 100, sq = 2, r = { { 4364, 2 }, { 4363, 1 }, { 2318, 1 }, { 159, 1 } }, out = { 4367, 1 }, oq = 1 },
    [3934] = { name = "Flying Tiger Goggles", t = { 1, 130, 145, 160 }, fee = 400, train = 100, r = { { 2318, 6 }, { 818, 2 } }, out = { 4368, 1 }, oq = 2 },
    [3936] = { name = "Deadly Blunderbuss", t = { 1, 130, 142, 155 }, fee = 420, train = 105, r = { { 4361, 2 }, { 4359, 4 }, { 4399, 1 }, { 2319, 2 } }, tool = 162, out = { 4369, 1 }, oq = 2 },
    [3937] = { name = "Large Copper Bomb", t = { 1, 105, 130, 155 }, fee = 450, train = 105, r = { { 2840, 3 }, { 4364, 4 }, { 4404, 1 } }, tool = 162, out = { 4370, 3 }, oq = 1 },
    [3938] = { name = "Bronze Tube", t = { 1, 105, 130, 155 }, fee = 450, train = 105, r = { { 2841, 2 }, { 2880, 1 } }, tool = 162, out = { 4371, 1 }, oq = 1 },
    [3939] = { name = "Lovingly Crafted Boomstick", t = { 1, 145, 157, 170 }, scroll = 13309, train = 120, scrollPrice = 1000, sq = 1, r = { { 4371, 2 }, { 4359, 2 }, { 4400, 1 }, { 1206, 3 } }, tool = 162, out = { 4372, 1 }, oq = 2 },
    [3940] = { name = "Shadow Goggles", t = { 1, 145, 157, 170 }, scroll = 4410, train = 120, sq = 2, r = { { 2319, 4 }, { 1210, 2 } }, out = { 4373, 1 }, oq = 2 },
    [3941] = { name = "Small Bronze Bomb", t = { 1, 120, 145, 170 }, fee = 500, train = 120, r = { { 4364, 4 }, { 2841, 2 }, { 4404, 1 }, { 2592, 1 } }, tool = 162, out = { 4374, 2 }, oq = 1 },
    [3942] = { name = "Whirring Bronze Gizmo", t = { 1, 125, 150, 175 }, fee = 500, train = 125, r = { { 2841, 2 }, { 2592, 1 } }, tool = 162, out = { 4375, 1 }, oq = 1 },
    [3944] = { name = "Flame Deflector", t = { 1, 125, 150, 175 }, scroll = 4411, train = 125, sq = 2, r = { { 4375, 1 }, { 4402, 1 } }, tool = 162, out = { 4376, 1 }, oq = 1 },
    [3945] = { name = "Heavy Blasting Powder", t = { 1, 125, 135, 145 }, fee = 500, train = 125, r = { { 2838, 1 } }, out = { 4377, 1 }, oq = 1 },
    [3946] = { name = "Heavy Dynamite", t = { 1, 125, 135, 145 }, fee = 500, train = 125, r = { { 4377, 2 }, { 2592, 1 } }, out = { 4378, 3 }, oq = 1 },
    [3947] = { name = "Crafted Solid Shot", t = { 1, 125, 135, 145 }, fee = 300, train = 125, r = { { 4377, 1 }, { 2841, 1 } }, out = { 8069, 200 }, oq = 1 },
    [3949] = { name = "Silver-plated Shotgun", t = { 1, 155, 167, 180 }, fee = 550, train = 130, r = { { 4371, 2 }, { 4375, 2 }, { 4400, 1 }, { 2842, 3 } }, out = { 4379, 1 }, oq = 2 },
    [3950] = { name = "Big Bronze Bomb", t = { 1, 140, 165, 190 }, fee = 600, train = 140, r = { { 4377, 2 }, { 2841, 3 }, { 4404, 1 } }, tool = 162, out = { 4380, 3 }, oq = 1 },
    [3952] = { name = "Minor Recombobulator", t = { 1, 165, 177, 190 }, scroll = 14639, train = 140, scrollPrice = 1500, sq = 1, r = { { 4371, 1 }, { 4375, 2 }, { 2319, 2 }, { 1206, 1 } }, out = { 4381, 1 }, oq = 2 },
    [3953] = { name = "Bronze Framework", t = { 1, 145, 170, 195 }, fee = 600, train = 145, r = { { 2841, 2 }, { 2319, 1 }, { 2592, 1 } }, out = { 4382, 1 }, oq = 1 },
    [3954] = { name = "Moonsight Rifle", t = { 1, 170, 182, 195 }, scroll = 4412, train = 145, sq = 2, r = { { 4371, 3 }, { 4375, 3 }, { 4400, 1 }, { 1705, 2 } }, tool = 162, out = { 4383, 1 }, oq = 2 },
    [3955] = { name = "Explosive Sheep", t = { 1, 175, 187, 200 }, fee = 750, train = 150, r = { { 4382, 1 }, { 4375, 1 }, { 4377, 2 }, { 2592, 2 } }, tool = 162, out = { 4384, 1 }, oq = 1 },
    [3956] = { name = "Green Tinted Goggles", t = { 1, 175, 187, 200 }, fee = 750, train = 150, r = { { 2319, 4 }, { 1206, 2 }, { 4368, 1 } }, out = { 4385, 1 }, oq = 2 },
    [3957] = { name = "Ice Deflector", t = { 1, 175, 185, 195 }, scroll = 13308, train = 155, scrollPrice = 1800, sq = 1, r = { { 4375, 1 }, { 3829, 1 } }, tool = 162, out = { 4386, 1 }, oq = 1 },
    [3958] = { name = "Iron Strut", t = { 1, 160, 170, 180 }, fee = 800, train = 160, r = { { 3575, 2 } }, tool = 162, out = { 4387, 1 }, oq = 1 },
    [3959] = { name = "Discombobulator Ray", t = { 1, 180, 190, 200 }, scroll = 4413, train = 160, sq = 2, r = { { 4375, 3 }, { 4306, 2 }, { 1529, 1 }, { 4371, 1 } }, tool = 162, out = { 4388, 1 }, oq = 1 },
    [3960] = { name = "Portable Bronze Mortar", t = { 1, 185, 195, 205 }, scroll = 4414, train = 165, sq = 2, r = { { 4371, 4 }, { 4387, 1 }, { 4377, 4 }, { 2319, 4 } }, tool = 162, out = { 4403, 1 }, oq = 1 },
    [3961] = { name = "Gyrochronatom", t = { 1, 170, 190, 210 }, fee = 900, train = 170, r = { { 3575, 1 }, { 10558, 1 } }, tool = 162, out = { 4389, 1 }, oq = 1 },
    [3962] = { name = "Iron Grenade", t = { 1, 175, 195, 215 }, fee = 1000, train = 175, r = { { 3575, 1 }, { 4377, 1 }, { 4306, 1 } }, tool = 162, out = { 4390, 3 }, oq = 1 },
    [3963] = { name = "Compact Harvest Reaper Kit", t = { 1, 175, 195, 215 }, fee = 1000, train = 175, r = { { 4387, 2 }, { 4382, 1 }, { 4389, 2 }, { 4234, 4 } }, tool = 162, out = { 4391, 1 }, oq = 1 },
    [3965] = { name = "Advanced Target Dummy", t = { 1, 185, 205, 225 }, fee = 1200, train = 185, r = { { 4387, 1 }, { 4382, 1 }, { 4389, 1 }, { 4234, 4 } }, tool = 162, out = { 4392, 1 }, oq = 1 },
    [3966] = { name = "Craftsman's Monocle", t = { 1, 205, 215, 225 }, scroll = 4415, train = 185, sq = 3, r = { { 4234, 6 }, { 3864, 2 } }, tool = 14, out = { 4393, 1 }, oq = 2 },
    [3967] = { name = "Big Iron Bomb", t = { 1, 190, 210, 230 }, fee = 1400, train = 190, r = { { 3575, 3 }, { 4377, 3 }, { 4404, 1 } }, tool = 162, out = { 4394, 2 }, oq = 1 },
    [3968] = { name = "Goblin Land Mine", t = { 1, 215, 225, 235 }, scroll = 4416, train = 195, sq = 2, r = { { 4377, 3 }, { 3575, 2 }, { 4389, 1 } }, tool = 162, out = { 4395, 1 }, oq = 1 },
    [3969] = { name = "Mechanical Dragonling", t = { 1, 220, 230, 240 }, scroll = 13311, train = 200, scrollPrice = 10000, sq = 1, r = { { 4382, 1 }, { 4387, 4 }, { 4389, 4 }, { 3864, 2 }, { 7191, 1 } }, tool = 162, out = { 4396, 1 }, oq = 1 },
    [3971] = { name = "Gnomish Cloaking Device", t = { 1, 220, 230, 240 }, scroll = 7742, train = 200, scrollPrice = 2400, sq = 1, r = { { 4389, 4 }, { 1529, 2 }, { 1705, 2 }, { 3864, 2 }, { 7191, 1 } }, tool = 162, out = { 4397, 1 }, oq = 1 },
    [3972] = { name = "Large Seaforium Charge", t = { 1, 200, 220, 240 }, scroll = 4417, train = 200, sq = 2, r = { { 10505, 2 }, { 4234, 2 }, { 159, 1 } }, out = { 4398, 1 }, oq = 1 },
    [3973] = { name = "Silver Contact", t = { 1, 110, 125, 140 }, fee = 300, train = 90, r = { { 2842, 1 } }, out = { 4404, 5 }, oq = 1 },
    [3977] = { name = "Crude Scope", t = { 1, 90, 105, 120 }, fee = 200, train = 60, r = { { 4361, 1 }, { 774, 1 }, { 4359, 1 } }, tool = 14, out = { 4405, 1 }, oq = 1 },
    [3978] = { name = "Standard Scope", t = { 1, 135, 147, 160 }, fee = 475, train = 110, r = { { 4371, 1 }, { 1206, 1 } }, tool = 14, out = { 4406, 1 }, oq = 1 },
    [3979] = { name = "Accurate Scope", t = { 1, 200, 210, 220 }, scroll = 13310, train = 180, scrollPrice = 2000, sq = 1, r = { { 4371, 1 }, { 1529, 1 }, { 3864, 1 } }, tool = 14, out = { 4407, 1 }, oq = 1 },
    [6458] = { name = "Ornate Spyglass", t = { 1, 160, 172, 185 }, fee = 400, train = 135, r = { { 4371, 2 }, { 4375, 2 }, { 4363, 1 }, { 1206, 1 } }, out = { 5507, 1 }, oq = 1 },
    [7430] = { name = "Arclight Spanner", t = { 1, 70, 80, 90 }, fee = 150, train = 50, r = { { 2840, 6 } }, tool = 162, out = { 6219, 1 }, oq = 1 },
    [8243] = { name = "Flash Bomb", t = { 1, 185, 205, 225 }, scroll = 6672, train = 185, sq = 2, r = { { 4611, 1 }, { 4377, 1 }, { 4306, 1 } }, out = { 4852, 1 }, oq = 1 },
    [8334] = { name = "Practice Lock", t = { 1, 115, 122, 130 }, fee = 300, train = 100, r = { { 2841, 1 }, { 4359, 2 }, { 2880, 1 } }, tool = 162, out = { 6712, 1 }, oq = 1 },
    [8339] = { name = "EZ-Thro Dynamite", t = { 1, 115, 122, 130 }, scroll = 6716, train = 100, sq = 2, r = { { 4364, 3 }, { 2589, 1 }, { 260794, 1 } }, out = { 6714, 2 }, oq = 1 },
    [8895] = { name = "Goblin Rocket Boots", t = { 1, 245, 255, 265 }, fee = 2200, train = 225, spec = "Goblin", tr = { 8126, 8738, 260562 }, r = { { 10026, 1 }, { 10559, 2 }, { 4234, 4 }, { 9061, 2 }, { 10560, 1 } }, tool = 162, out = { 7189, 1 }, oq = 2 },
    [9269] = { name = "Gnomish Universal Remote", t = { 1, 150, 162, 175 }, scroll = 7560, train = 125, scrollPrice = 1200, sq = 1, r = { { 2841, 6 }, { 4375, 1 }, { 814, 2 }, { 818, 1 }, { 774, 1 } }, tool = 162, out = { 7506, 1 }, oq = 2 },
    [9271] = { name = "Aquadynamic Fish Attractor", t = { 1, 150, 160, 170 }, fee = 500, train = 150, r = { { 2841, 2 }, { 6530, 1 }, { 4364, 1 } }, out = { 6533, 3 }, oq = 1 },
    [9273] = { name = "Goblin Jumper Cables", t = { 1, 160, 180, 200 }, scroll = 7561, train = 165, scrollPrice = 2000, sq = 1, r = { { 3575, 6 }, { 4375, 2 }, { 814, 2 }, { 4306, 2 }, { 1210, 2 }, { 7191, 1 } }, out = { 7148, 1 }, oq = 1 },
    [12584] = { name = "Gold Power Core", t = { 1, 150, 170, 190 }, fee = 1000, train = 150, r = { { 3577, 1 } }, tool = 162, out = { 10558, 3 }, oq = 1 },
    [12585] = { name = "Solid Blasting Powder", t = { 1, 175, 185, 195 }, fee = 1000, train = 175, r = { { 7912, 2 } }, out = { 10505, 1 }, oq = 1 },
    [12586] = { name = "Solid Dynamite", t = { 1, 175, 185, 195 }, fee = 1000, train = 175, r = { { 10505, 1 }, { 4306, 1 } }, out = { 10507, 2 }, oq = 1 },
    [12587] = { name = "Bright-Eye Goggles", t = { 1, 195, 205, 215 }, scroll = 10601, train = 175, sq = 2, r = { { 4234, 6 }, { 3864, 2 } }, tool = 14, out = { 10499, 1 }, oq = 2 },
    [12589] = { name = "Mithril Tube", t = { 1, 195, 215, 235 }, fee = 1300, train = 195, r = { { 3860, 3 } }, tool = 162, out = { 10559, 1 }, oq = 1 },
    [12590] = { name = "Gyromatic Micro-Adjustor", t = { 1, 175, 195, 215 }, fee = 1000, train = 175, r = { { 3859, 4 } }, tool = 162, out = { 10498, 1 }, oq = 1 },
    [12591] = { name = "Unstable Trigger", t = { 1, 200, 220, 240 }, fee = 1500, train = 200, r = { { 3860, 1 }, { 4338, 1 }, { 10505, 1 } }, tool = 162, out = { 10560, 1 }, oq = 1 },
    [12594] = { name = "Fire Goggles", t = { 1, 225, 235, 245 }, fee = 1600, train = 205, r = { { 4385, 1 }, { 3864, 2 }, { 7068, 2 }, { 4234, 4 } }, tool = 14, out = { 10500, 1 }, oq = 2 },
    [12595] = { name = "Mithril Blunderbuss", t = { 1, 225, 235, 245 }, fee = 1600, train = 205, r = { { 10559, 1 }, { 10560, 1 }, { 4400, 1 }, { 3860, 4 }, { 7068, 2 } }, tool = 162, out = { 10508, 1 }, oq = 2 },
    [12596] = { name = "Hi-Impact Mithril Slugs", t = { 1, 210, 230, 250 }, fee = 1700, train = 210, r = { { 3860, 1 }, { 10505, 1 } }, tool = 162, out = { 10512, 200 }, oq = 2 },
    [12597] = { name = "Deadly Scope", t = { 1, 230, 240, 250 }, scroll = 10602, train = 210, scrollPrice = 3000, sq = 1, r = { { 10559, 1 }, { 7909, 2 }, { 4304, 2 } }, tool = 162, out = { 10546, 1 }, oq = 1 },
    [12599] = { name = "Mithril Casing", t = { 1, 215, 235, 255 }, fee = 1800, train = 215, r = { { 3860, 3 } }, tool = 162, out = { 10561, 1 }, oq = 1 },
    [12603] = { name = "Mithril Frag Bomb", t = { 1, 215, 235, 255 }, fee = 1800, train = 215, r = { { 10561, 1 }, { 10560, 1 }, { 10505, 1 } }, tool = 162, out = { 10514, 3 }, oq = 1 },
    [12607] = { name = "Catseye Ultra Goggles", t = { 1, 240, 250, 260 }, scroll = 10603, train = 220, sq = 2, r = { { 4304, 4 }, { 7909, 2 }, { 10592, 1 } }, tool = 14, out = { 10501, 1 }, oq = 2 },
    [12614] = { name = "Mithril Heavy-bore Rifle", t = { 1, 240, 250, 260 }, scroll = 10604, train = 220, sq = 2, r = { { 10559, 2 }, { 10560, 1 }, { 4400, 1 }, { 3860, 6 }, { 3864, 2 } }, tool = 162, out = { 10510, 1 }, oq = 2 },
    [12615] = { name = "Spellpower Goggles Xtreme", t = { 1, 245, 255, 265 }, scroll = 10605, train = 225, sq = 3, r = { { 4304, 4 }, { 7910, 2 } }, tool = 14, out = { 10502, 1 }, oq = 2 },
    [12616] = { name = "Parachute Cloak", t = { 1, 245, 255, 265 }, scroll = 10606, train = 225, sq = 2, r = { { 4339, 4 }, { 10285, 2 }, { 10560, 1 }, { 10505, 4 } }, tool = 14, out = { 10518, 1 }, oq = 2 },
    [12617] = { name = "Deepdive Helmet", t = { 1, 250, 260, 270 }, scroll = 10607, train = 230, scrollPrice = 3600, sq = 1, r = { { 3860, 8 }, { 10561, 1 }, { 6037, 1 }, { 818, 4 }, { 774, 4 } }, tool = 162, out = { 10506, 1 }, oq = 2 },
    [12618] = { name = "Rose Colored Goggles", t = { 1, 250, 260, 270 }, fee = 2200, train = 230, r = { { 4304, 6 }, { 7910, 2 } }, tool = 14, out = { 10503, 1 }, oq = 2 },
    [12619] = { name = "Hi-Explosive Bomb", t = { 1, 235, 255, 275 }, fee = 2400, train = 235, r = { { 10561, 2 }, { 10560, 1 }, { 10505, 2 } }, tool = 162, out = { 10562, 4 }, oq = 1 },
    [12620] = { name = "Sniper Scope", t = { 1, 260, 270, 280 }, scroll = 10608, train = 240, sq = 3, r = { { 10559, 1 }, { 7910, 1 }, { 6037, 2 } }, tool = 162, out = { 10548, 1 }, oq = 1 },
    [12621] = { name = "Mithril Gyro-Shot", t = { 1, 245, 265, 285 }, fee = 2800, train = 245, r = { { 3860, 2 }, { 10505, 2 } }, tool = 162, out = { 10513, 200 }, oq = 2 },
    [12622] = { name = "Green Lens", t = { 1, 265, 275, 285 }, fee = 2800, train = 245, r = { { 4304, 8 }, { 1529, 3 }, { 7909, 3 }, { 10286, 2 }, { 8153, 2 } }, tool = 14, out = { 10504, 1 }, oq = 3 },
    [12624] = { name = "Mithril Mechanical Dragonling", t = { 1, 270, 280, 290 }, scroll = 10609, train = 250, scrollPrice = 4000, sq = 1, r = { { 3860, 14 }, { 7077, 4 }, { 6037, 4 }, { 9060, 2 }, { 9061, 2 }, { 7910, 2 } }, tool = 162, out = { 10576, 1 }, oq = 1 },
    [12716] = { name = "Goblin Mortar", t = { 1, 225, 235, 245 }, r = { { 10559, 2 }, { 3860, 4 }, { 10505, 5 }, { 10558, 1 }, { 7068, 1 } }, tool = 162, out = { 10577, 1 }, oq = 1 },
    [12717] = { name = "Goblin Mining Helmet", t = { 1, 225, 235, 245 }, fee = 1500, train = 205, spec = "Goblin", tr = { 8126, 8738, 260562 }, r = { { 3860, 8 }, { 3864, 1 }, { 7067, 4 } }, tool = 162, out = { 10542, 1 }, oq = 2, bop = true },
    [12718] = { name = "Goblin Construction Helmet", t = { 1, 225, 235, 245 }, fee = 1500, train = 205, spec = "Goblin", tr = { 8126, 8738, 260562 }, r = { { 3860, 8 }, { 3864, 1 }, { 7068, 4 } }, tool = 162, out = { 10543, 1 }, oq = 2, bop = true },
    [12719] = { name = "Explosive Arrow", t = { 1, 210, 230, 250 }, r = { { 3030, 100 }, { 10505, 2 }, { 3860, 2 } }, tool = 14, out = { 10579, 100 }, oq = 3 },
    [12720] = { name = "Goblin \"Boom\" Box", t = { 1, 235, 245, 255 }, r = { { 10561, 1 }, { 10505, 2 }, { 10558, 1 }, { 3860, 2 } }, tool = 162, out = { 10580, 1 }, oq = 1 },
    [12722] = { name = "Goblin Radio", t = { 1, 240, 250, 260 }, r = { { 10561, 1 }, { 3860, 2 }, { 4389, 1 }, { 10560, 1 } }, tool = 162, out = { 10585, 1 }, oq = 1 },
    [12754] = { name = "The Big One", t = { 1, 235, 255, 275 }, fee = 2600, train = 235, spec = "Goblin", tr = { 8126, 8738, 260562 }, r = { { 10561, 1 }, { 9061, 1 }, { 10507, 6 }, { 10560, 1 } }, tool = 162, out = { 10586, 2 }, oq = 1 },
    [12755] = { name = "Goblin Bomb Dispenser", t = { 1, 230, 250, 270 }, fee = 2400, train = 230, spec = "Goblin", tr = { 8126, 8738, 260562 }, r = { { 10561, 2 }, { 10505, 4 }, { 6037, 6 }, { 10560, 1 }, { 4407, 2 } }, tool = 162, out = { 10587, 1 }, oq = 1, bop = true },
    [12758] = { name = "Goblin Rocket Helmet", t = { 1, 265, 275, 285 }, fee = 3000, train = 245, spec = "Goblin", tr = { 8126, 8738, 260562 }, r = { { 10543, 1 }, { 9061, 4 }, { 3860, 4 }, { 10560, 1 } }, tool = 162, out = { 10588, 1 }, oq = 2 },
    [12759] = { name = "Gnomish Death Ray", t = { 1, 260, 270, 280 }, fee = 2800, train = 240, spec = "Gnomish", tr = { 7406, 7944 }, r = { { 10559, 2 }, { 10560, 1 }, { 12808, 1 }, { 7972, 4 }, { 9060, 1 } }, tool = 162, out = { 10645, 1 }, oq = 1, bop = true },
    [12760] = { name = "Goblin Sapper Charge", t = { 1, 205, 225, 245 }, fee = 1500, train = 205, spec = "Goblin", tr = { 8126, 8738, 260562 }, r = { { 4338, 1 }, { 10505, 3 }, { 10560, 1 } }, out = { 10646, 1 }, oq = 1 },
    [12897] = { name = "Gnomish Goggles", t = { 1, 230, 240, 250 }, fee = 1500, train = 210, spec = "Gnomish", tr = { 7406, 7944 }, r = { { 10500, 1 }, { 10559, 1 }, { 10558, 2 }, { 8151, 2 }, { 4234, 2 } }, tool = 14, out = { 10545, 1 }, oq = 2, bop = true },
    [12899] = { name = "Gnomish Shrink Ray", t = { 1, 225, 235, 245 }, fee = 1500, train = 205, spec = "Gnomish", tr = { 7406, 7944 }, r = { { 10559, 1 }, { 10560, 1 }, { 3860, 4 }, { 8151, 4 }, { 1529, 2 } }, tool = 162, out = { 10716, 1 }, oq = 1 },
    [12900] = { name = "Mobile Alarm", t = { 1, 205, 225, 245 }, r = { { 10559, 1 }, { 10560, 1 }, { 3860, 4 } }, tool = 162, out = { 10719, 1 }, oq = 1 },
    [12902] = { name = "Gnomish Net-o-Matic Projector", t = { 1, 230, 240, 250 }, fee = 1800, train = 210, spec = "Gnomish", tr = { 7406, 7944 }, r = { { 10559, 1 }, { 10285, 2 }, { 4337, 4 }, { 10505, 2 }, { 3860, 4 } }, tool = 162, out = { 10720, 1 }, oq = 1 },
    [12903] = { name = "Gnomish Harm Prevention Belt", t = { 1, 235, 245, 255 }, fee = 2000, train = 215, spec = "Gnomish", tr = { 7406, 7944 }, r = { { 7387, 1 }, { 3860, 4 }, { 6037, 2 }, { 10560, 1 }, { 7909, 2 } }, tool = 162, out = { 10721, 1 }, oq = 2 },
    [12904] = { name = "Gnomish Ham Radio", t = { 1, 240, 250, 260 }, r = { { 10561, 1 }, { 3860, 2 }, { 4389, 1 }, { 10560, 1 } }, tool = 162, out = { 10723, 1 }, oq = 1 },
    [12905] = { name = "Gnomish Rocket Boots", t = { 1, 245, 255, 265 }, fee = 2200, train = 225, spec = "Gnomish", tr = { 7406, 7944 }, r = { { 10026, 1 }, { 10559, 2 }, { 4234, 4 }, { 10505, 8 }, { 4389, 4 } }, tool = 162, out = { 10724, 1 }, oq = 2 },
    [12906] = { name = "Gnomish Battle Chicken", t = { 1, 250, 260, 270 }, fee = 2400, train = 230, spec = "Gnomish", tr = { 7406, 7944 }, r = { { 10561, 1 }, { 6037, 6 }, { 3860, 6 }, { 9060, 2 }, { 10558, 1 }, { 1529, 2 } }, tool = 162, out = { 10725, 1 }, oq = 1, bop = true },
    [12907] = { name = "Gnomish Mind Control Cap", t = { 1, 255, 265, 275 }, fee = 2600, train = 235, spec = "Gnomish", tr = { 7406, 7944 }, r = { { 3860, 10 }, { 6037, 4 }, { 10558, 1 }, { 7910, 2 }, { 4338, 4 } }, tool = 162, out = { 10726, 1 }, oq = 2 },
    [12908] = { name = "Goblin Dragon Gun", t = { 1, 260, 270, 280 }, fee = 2800, train = 240, spec = "Goblin", tr = { 8126, 8738, 260562 }, r = { { 10559, 2 }, { 9061, 4 }, { 3860, 6 }, { 6037, 6 }, { 10560, 1 } }, tool = 162, out = { 10727, 1 }, oq = 1, bop = true },
    [15255] = { name = "Mechanical Repair Kit", t = { 1, 200, 220, 240 }, fee = 1500, train = 200, r = { { 3860, 1 }, { 4338, 1 }, { 10505, 1 } }, tool = 162, out = { 11590, 1 }, oq = 1 },
    [15628] = { name = "Pet Bombling", t = { 1, 205, 207, 210 }, scroll = 11828, train = 205, sq = 2, r = { { 4394, 1 }, { 7077, 1 }, { 7191, 1 }, { 3860, 6 } }, tool = 162, out = { 11825, 1 }, oq = 1 },
    [19567] = { name = "Salt Shaker", t = { 1, 270, 280, 290 }, fee = 4000, train = 250, r = { { 10561, 1 }, { 12359, 6 }, { 10558, 1 }, { 10560, 4 } }, tool = 162, out = { 15846, 1 }, oq = 1 },
    [19788] = { name = "Dense Blasting Powder", t = { 1, 250, 255, 260 }, fee = 4000, train = 250, r = { { 12365, 2 } }, out = { 15992, 1 }, oq = 1 },
    [19790] = { name = "Thorium Grenade", t = { 1, 280, 290, 300 }, scroll = 16041, train = 260, scrollPrice = 12000, sq = 1, r = { { 15994, 1 }, { 12359, 3 }, { 15992, 3 }, { 14047, 3 } }, tool = 162, out = { 15993, 3 }, oq = 1 },
    [19791] = { name = "Thorium Widget", t = { 1, 280, 290, 300 }, scroll = 16042, train = 260, scrollPrice = 12000, sq = 1, r = { { 12359, 3 }, { 14047, 1 } }, tool = 162, out = { 15994, 1 }, oq = 1 },
    [19792] = { name = "Thorium Rifle", t = { 1, 280, 290, 300 }, scroll = 16043, train = 260, sq = 2, r = { { 10559, 2 }, { 10561, 2 }, { 15994, 2 }, { 12359, 4 }, { 10546, 1 } }, tool = 162, out = { 15995, 1 }, oq = 2 },
    [19793] = { name = "Lifelike Mechanical Toad", t = { 1, 285, 295, 305 }, scroll = 16044, train = 265, sq = 2, r = { { 12803, 1 }, { 15994, 4 }, { 10558, 1 }, { 8170, 1 } }, tool = 162, out = { 15996, 1 }, oq = 1 },
    [19794] = { name = "Spellpower Goggles Xtreme Plus", t = { 1, 290, 300, 310 }, scroll = 16045, train = 270, sq = 2, r = { { 10502, 1 }, { 7910, 4 }, { 12810, 2 }, { 14047, 8 } }, tool = 14, out = { 15999, 1 }, oq = 2 },
    [19795] = { name = "Thorium Tube", t = { 1, 295, 305, 315 }, scroll = 16047, train = 275, scrollPrice = 16000, sq = 1, r = { { 12359, 6 } }, tool = 162, out = { 16000, 1 }, oq = 1 },
    [19796] = { name = "Dark Iron Rifle", t = { 1, 295, 305, 315 }, scroll = 16048, train = 275, sq = 2, r = { { 16000, 2 }, { 11371, 6 }, { 10546, 2 }, { 12361, 2 }, { 12799, 2 }, { 8170, 4 } }, tool = 162, out = { 16004, 1 }, oq = 3 },
    [19799] = { name = "Dark Iron Bomb", t = { 1, 305, 315, 325 }, scroll = 16049, train = 285, sq = 2, r = { { 15994, 2 }, { 11371, 1 }, { 15992, 3 }, { 14047, 3 } }, tool = 162, out = { 16005, 3 }, oq = 1 },
    [19800] = { name = "Thorium Shells", t = { 1, 305, 315, 325 }, scroll = 16051, train = 285, sq = 2, r = { { 12359, 2 }, { 15992, 1 } }, tool = 162, out = { 15997, 200 }, oq = 2 },
    [19814] = { name = "Masterwork Target Dummy", t = { 1, 295, 305, 315 }, scroll = 16046, train = 275, scrollPrice = 16000, sq = 1, r = { { 10561, 1 }, { 16000, 1 }, { 15994, 2 }, { 6037, 1 }, { 8170, 2 }, { 14047, 4 } }, tool = 162, out = { 16023, 1 }, oq = 1 },
    [19815] = { name = "Delicate Arcanite Converter", t = { 1, 305, 315, 325 }, scroll = 16050, train = 285, scrollPrice = 20000, sq = 1, r = { { 12360, 1 }, { 14227, 1 } }, tool = 162, out = { 16006, 1 }, oq = 1 },
    [19819] = { name = "Voice Amplification Modulator", t = { 1, 310, 320, 330 }, scroll = 16052, train = 290, sq = 2, r = { { 16006, 2 }, { 10558, 1 }, { 15994, 1 }, { 12799, 1 } }, tool = 162, out = { 16009, 1 }, oq = 2 },
    [19825] = { name = "Master Engineer's Goggles", t = { 1, 310, 320, 330 }, scroll = 16053, train = 290, sq = 2, r = { { 10500, 1 }, { 12364, 2 }, { 12810, 4 } }, tool = 14, out = { 16008, 1 }, oq = 2 },
    [19830] = { name = "Arcanite Dragonling", t = { 1, 320, 330, 340 }, scroll = 16054, train = 300, sq = 2, r = { { 10576, 1 }, { 16006, 8 }, { 12655, 10 }, { 15994, 6 }, { 10558, 4 }, { 12810, 6 } }, tool = 162, out = { 16022, 1 }, oq = 3 },
    [19831] = { name = "Arcane Bomb", t = { 1, 320, 330, 340 }, scroll = 16055, train = 300, sq = 2, r = { { 16006, 1 }, { 12359, 3 }, { 14047, 1 } }, tool = 162, out = { 16040, 3 }, oq = 1 },
    [19833] = { name = "Flawless Arcanite Rifle", t = { 1, 320, 330, 340 }, scroll = 16056, train = 300, sq = 2, r = { { 12360, 10 }, { 16000, 2 }, { 7078, 2 }, { 7076, 2 }, { 12800, 2 }, { 12810, 2 } }, tool = 162, out = { 16007, 1 }, oq = 3 },
    [21940] = { name = "Snowmaster 9000", t = { 1, 190, 210, 230 }, scroll = 17720, train = 190, sq = 2, r = { { 3860, 8 }, { 4389, 4 }, { 17202, 4 }, { 3829, 1 } }, tool = 162, out = { 17716, 1 }, oq = 1 },
    [22704] = { name = "Field Repair Bot 74A", t = { 1, 320, 330, 340 }, scroll = 18235, train = 300, sq = 1, r = { { 12359, 12 }, { 8170, 4 }, { 7191, 1 }, { 7067, 2 }, { 7068, 1 } }, tool = 162, out = { 18232, 1 }, oq = 1 },
    [22793] = { name = "Biznicks 247x128 Accurascope", t = { 1, 320, 330, 340 }, scroll = 18290, train = 300, sq = 3, r = { { 17011, 2 }, { 7076, 2 }, { 16006, 4 }, { 11371, 6 }, { 16000, 1 } }, tool = 162, out = { 18283, 1 }, oq = 3 },
    [22795] = { name = "Core Marksman Rifle", t = { 1, 320, 330, 340 }, scroll = 18292, train = 300, sq = 3, r = { { 17010, 4 }, { 17011, 2 }, { 12360, 6 }, { 16006, 2 }, { 16000, 2 } }, tool = 162, out = { 18282, 1 }, oq = 4 },
    [22797] = { name = "Force Reactive Disk", t = { 1, 320, 330, 340 }, scroll = 18291, train = 300, sq = 3, r = { { 12360, 6 }, { 16006, 2 }, { 7082, 8 }, { 12803, 12 }, { 7076, 8 } }, tool = 162, out = { 18168, 1 }, oq = 4 },
    [23066] = { name = "Red Firework", t = { 1, 150, 162, 175 }, scroll = 18647, train = 150, scrollPrice = 1800, sq = 1, r = { { 4377, 1 }, { 4234, 1 } }, out = { 9318, 3 }, oq = 1 },
    [23067] = { name = "Blue Firework", t = { 1, 150, 162, 175 }, scroll = 18649, train = 150, scrollPrice = 1800, sq = 1, r = { { 4377, 1 }, { 4234, 1 } }, out = { 9312, 3 }, oq = 1 },
    [23068] = { name = "Green Firework", t = { 1, 150, 162, 175 }, scroll = 18648, train = 150, scrollPrice = 1800, sq = 1, r = { { 4377, 1 }, { 4234, 1 } }, out = { 9313, 3 }, oq = 1 },
    [23069] = { name = "EZ-Thro Dynamite II", t = { 1, 200, 210, 220 }, scroll = 18650, train = 200, scrollPrice = 5000, sq = 1, r = { { 10505, 1 }, { 4306, 1 }, { 260801, 1 } }, out = { 18588, 1 }, oq = 1 },
    [23070] = { name = "Dense Dynamite", t = { 1, 250, 260, 270 }, fee = 5000, train = 250, r = { { 15992, 2 }, { 14047, 3 } }, out = { 18641, 2 }, oq = 1 },
    [23071] = { name = "Truesilver Transformer", t = { 1, 270, 275, 280 }, scroll = 18651, train = 260, scrollPrice = 12000, sq = 1, r = { { 6037, 2 }, { 7067, 2 }, { 7069, 1 } }, tool = 162, out = { 18631, 1 }, oq = 1 },
    [23077] = { name = "Gyrofreeze Ice Reflector", t = { 1, 280, 290, 300 }, scroll = 18652, train = 260, scrollPrice = 12000, sq = 1, r = { { 15994, 6 }, { 18631, 2 }, { 12361, 2 }, { 7078, 4 }, { 3829, 2 }, { 13467, 4 } }, tool = 162, out = { 18634, 1 }, oq = 3 },
    [23078] = { name = "Goblin Jumper Cables XL", t = { 1, 285, 295, 305 }, scroll = 18653, train = 265, sq = 2, r = { { 15994, 2 }, { 18631, 2 }, { 7191, 2 }, { 14227, 2 }, { 7910, 2 } }, out = { 18587, 1 }, oq = 1 },
    [23079] = { name = "Major Recombobulator", t = { 1, 285, 290, 295 }, scroll = 18655, train = 275, sq = 2, r = { { 16000, 2 }, { 18631, 1 }, { 14047, 2 } }, out = { 18637, 1 }, oq = 2 },
    [23080] = { name = "Powerful Seaforium Charge", t = { 1, 275, 285, 295 }, scroll = 18656, train = 275, scrollPrice = 16000, sq = 1, r = { { 15994, 2 }, { 15992, 3 }, { 8170, 2 }, { 159, 1 } }, out = { 18594, 1 }, oq = 1 },
    [23081] = { name = "Hyper-Radiant Flame Reflector", t = { 1, 310, 320, 330 }, scroll = 18657, train = 290, sq = 2, r = { { 11371, 4 }, { 18631, 3 }, { 7080, 6 }, { 7910, 4 }, { 12800, 2 } }, tool = 162, out = { 18638, 1 }, oq = 3 },
    [23082] = { name = "Ultra-Flash Shadow Reflector", t = { 1, 320, 330, 340 }, scroll = 18658, train = 300, sq = 2, r = { { 11371, 8 }, { 18631, 4 }, { 12803, 6 }, { 12808, 4 }, { 12800, 2 }, { 12799, 2 } }, tool = 162, out = { 18639, 1 }, oq = 3 },
    [23096] = { name = "Alarm-O-Bot", t = { 1, 275, 280, 285 }, scroll = 18654, train = 265, sq = 2, r = { { 12359, 4 }, { 15994, 2 }, { 8170, 4 }, { 7910, 1 }, { 7191, 1 } }, tool = 162, out = { 18645, 1 }, oq = 1 },
    [23129] = { name = "World Enlarger", t = { 1, 260, 265, 270 }, scroll = 18661, train = 260, sq = 2, r = { { 10561, 1 }, { 15994, 2 }, { 10558, 1 }, { 10560, 1 }, { 3864, 1 } }, tool = 162, out = { 18660, 1 }, oq = 2 },
    [23486] = { name = "Dimensional Ripper - Everlook", t = { 1, 285, 295, 305 }, r = { { 3860, 10 }, { 18631, 1 }, { 7077, 4 }, { 7910, 2 }, { 10586, 1 } }, tool = 162, out = { 18984, 1 }, oq = 2 },
    [23489] = { name = "Ultrasafe Transporter - Gadgetzan", t = { 1, 285, 295, 305 }, r = { { 3860, 12 }, { 18631, 2 }, { 7075, 4 }, { 7079, 2 }, { 7909, 4 }, { 9060, 1 } }, tool = 162, out = { 18986, 1 }, oq = 2 },
    [23507] = { name = "Snake Burst Firework", t = { 1, 250, 260, 270 }, scroll = 19027, train = 250, scrollPrice = 5000, sq = 1, r = { { 15992, 2 }, { 14047, 2 }, { 8150, 1 } }, out = { 19026, 4 }, oq = 1 },
    [24356] = { name = "Bloodvine Goggles", t = { 1, 320, 330, 340 }, scroll = 20000, train = 300, scrollPrice = 120000, rep = { 270, 5 }, sq = 1, r = { { 19726, 4 }, { 19774, 5 }, { 16006, 2 }, { 12804, 8 }, { 12810, 4 } }, tool = 15, out = { 19999, 1 }, oq = 3 },
    [24357] = { name = "Bloodvine Lens", t = { 1, 320, 330, 340 }, scroll = 20001, train = 300, scrollPrice = 50000, rep = { 270, 4 }, sq = 1, r = { { 19726, 5 }, { 19774, 5 }, { 16006, 1 }, { 12804, 8 }, { 12810, 4 } }, tool = 15, out = { 19998, 1 }, oq = 3 },
    [26011] = { name = "Tranquil Mechanical Yeti", t = { 1, 320, 330, 340 }, r = { { 15407, 1 }, { 15994, 4 }, { 7079, 2 }, { 18631, 2 }, { 10558, 1 } }, tool = 162, out = { 21277, 1 }, oq = 1 },
    [26416] = { name = "Small Blue Rocket", t = { 1, 125, 137, 150 }, scroll = 21724, train = 125, sq = 2, r = { { 4364, 1 }, { 2319, 1 } }, out = { 21558, 5 }, oq = 1 },
    [26417] = { name = "Small Green Rocket", t = { 1, 125, 137, 150 }, scroll = 21725, train = 125, sq = 2, r = { { 4364, 1 }, { 2319, 1 } }, out = { 21559, 5 }, oq = 1 },
    [26418] = { name = "Small Red Rocket", t = { 1, 125, 137, 150 }, scroll = 21726, train = 125, sq = 2, r = { { 4364, 1 }, { 2319, 1 } }, out = { 21557, 5 }, oq = 1 },
    [26420] = { name = "Large Blue Rocket", t = { 1, 175, 187, 200 }, scroll = 21727, train = 175, sq = 2, r = { { 4377, 1 }, { 4234, 1 } }, out = { 21589, 5 }, oq = 1 },
    [26421] = { name = "Large Green Rocket", t = { 1, 175, 187, 200 }, scroll = 21728, train = 175, sq = 2, r = { { 4377, 1 }, { 4234, 1 } }, out = { 21590, 5 }, oq = 1 },
    [26422] = { name = "Large Red Rocket", t = { 1, 175, 187, 200 }, scroll = 21729, train = 175, sq = 2, r = { { 4377, 1 }, { 4234, 1 } }, out = { 21592, 5 }, oq = 1 },
    [26423] = { name = "Blue Rocket Cluster", t = { 1, 225, 237, 250 }, scroll = 21730, train = 225, sq = 2, r = { { 10505, 1 }, { 4304, 1 } }, out = { 21571, 5 }, oq = 1 },
    [26424] = { name = "Green Rocket Cluster", t = { 1, 225, 237, 250 }, scroll = 21731, train = 225, sq = 2, r = { { 10505, 1 }, { 4304, 1 } }, out = { 21574, 5 }, oq = 1 },
    [26425] = { name = "Red Rocket Cluster", t = { 1, 225, 237, 250 }, scroll = 21732, train = 225, sq = 2, r = { { 10505, 1 }, { 4304, 1 } }, out = { 21576, 5 }, oq = 1 },
    [26426] = { name = "Large Blue Rocket Cluster", t = { 1, 275, 280, 285 }, scroll = 21733, train = 275, sq = 2, r = { { 15992, 1 }, { 8170, 1 } }, out = { 21714, 5 }, oq = 1 },
    [26427] = { name = "Large Green Rocket Cluster", t = { 1, 275, 280, 285 }, scroll = 21734, train = 275, sq = 2, r = { { 15992, 1 }, { 8170, 1 } }, out = { 21716, 5 }, oq = 1 },
    [26428] = { name = "Large Red Rocket Cluster", t = { 1, 275, 280, 285 }, scroll = 21735, train = 275, sq = 2, r = { { 15992, 1 }, { 8170, 1 } }, out = { 21718, 5 }, oq = 1 },
    [26442] = { name = "Firework Launcher", t = { 1, 245, 255, 265 }, scroll = 21738, train = 225, sq = 2, r = { { 9060, 2 }, { 9061, 2 }, { 10560, 2 }, { 10561, 1 } }, out = { 21569, 1 }, oq = 1 },
    [26443] = { name = "Firework Cluster Launcher", t = { 1, 295, 305, 315 }, scroll = 21737, train = 275, sq = 2, r = { { 9060, 3 }, { 9061, 3 }, { 18631, 1 }, { 10561, 1 } }, out = { 21570, 1 }, oq = 1 },
    [28327] = { name = "Steam Tonk Controller", t = { 1, 295, 305, 315 }, scroll = 22729, train = 275, sq = 1, r = { { 15994, 2 }, { 10561, 1 }, { 10558, 1 } }, tool = 162, out = { 22728, 1 }, oq = 2 },
    [424641] = { name = "Shredder Autosalvage Unit", t = { 1, 135, 140, 145 }, scroll = 210178, train = 135, sq = 2, r = { { 4382, 1 }, { 4375, 2 }, { 4234, 1 } }, tool = 162, out = { 210147, 1 }, oq = 1 },
    [431362] = { name = "Soul Vessel", t = { 1, 205, 210, 215 }, scroll = 212230, train = 205, gone = true, sq = 3, r = { { 1210, 4 }, { 9262, 1 }, { 16583, 1 } }, tool = 14, out = { 211427, 1 }, oq = 3 },
    [435956] = { name = "Polished Truesilver Gears", t = { 1, 200, 210, 220 }, scroll = 215429, train = 200, sq = 3, r = { { 6037, 1 }, { 213381, 5 } }, tool = 162, out = { 213383, 1 }, oq = 3 },
    [435958] = { name = "Whirling Truesilver Gearwall", t = { 1, 225, 232, 240 }, scroll = 215153, train = 225, sq = 4, r = { { 213376, 3 }, { 213383, 5 }, { 213369, 2 }, { 10561, 2 }, { 4389, 2 }, { 3860, 15 } }, tool = 162, out = { 213390, 1 }, oq = 1 },
    [435960] = { name = "Hyperconductive Goldwap", t = { 1, 225, 230, 235 }, scroll = 215156, train = 225, sq = 4, r = { { 213383, 3 }, { 213379, 3 }, { 213369, 1 }, { 3577, 10 } }, tool = 14, out = { 215115, 1 }, oq = 1 },
    [435964] = { name = "High-Yield Radiation Bomb", t = { 1, 225, 230, 235 }, scroll = 215431, train = 225, sq = 4, r = { { 10505, 1 }, { 215430, 1 }, { 3860, 2 } }, tool = 162, out = { 215127, 3 }, oq = 1 },
    [435966] = { name = "Ez-Thro Radiation Bomb", t = { 1, 225, 230, 235 }, scroll = 215432, train = 225, sq = 4, r = { { 10505, 2 }, { 215430, 1 }, { 3860, 2 } }, tool = 162, out = { 215168, 3 }, oq = 1 },
    [461710] = { name = "Fiery Core Sharpshooter Rifle", t = { 1, 320, 330, 340 }, scroll = 228304, train = 310, sq = 1, r = { { 17010, 4 }, { 17011, 2 }, { 12360, 6 }, { 16006, 2 }, { 16000, 2 } }, tool = 162, out = { 227849, 1 }, oq = 1 },
    [1213573] = { name = "Arcane Megabomb", t = { 1, 315, 322, 330 }, scroll = 234261, train = 305, sq = 1, r = { { 16006, 1 }, { 20725, 1 }, { 14047, 1 } }, out = { 233984, 5 }, oq = 1 },
    [1213646] = { name = "Obsidian Blasting Powder", t = { 1, 315, 322, 330 }, scroll = 234280, train = 305, sq = 1, r = { { 22202, 2 } }, out = { 234005, 1 }, oq = 1 },
    [1221012] = { name = "Creepy Censor Sensors", t = { 1, 275, 277, 280 }, scroll = 236872, train = 250, sq = 2, r = { { 8170, 8 }, { 12800, 2 } }, tool = 14, out = { 236871, 1 }, oq = 1 },
    [1226206] = { name = "Tinkerbox", t = { 1, 260, 270, 280 }, scroll = 250400, train = 250, sq = 1, r = { { 10561, 1 }, { 10558, 2 } }, tool = 14, out = { 238737, 1 }, oq = 1 },
    [1228088] = { name = "Pop-Up Shrub", t = { 1, 255, 257, 260 }, scroll = 239222, train = 250, sq = 3, r = { { 15994, 1 }, { 10560, 1 }, { 4382, 1 } }, tool = 14, out = { 237023, 1 }, oq = 1 },
    [1230656] = { name = "Reagent Bot", t = { 1, 20, 22, 25 }, fee = 0, train = 20, r = { { 4359, 1 }, { 4361, 1 } }, out = { 279950, 1 }, oq = 1 },
    [1249634] = { name = "Sandpaper", t = { 1, 130, 142, 155 }, fee = 500, train = 120, tr = { 5174, 8736, 11017, 249235 }, r = { { 249425, 2 }, { 2996, 1 } }, out = { 249432, 1 }, oq = 2 },
    [1263034] = { name = "Repair Bot", t = { 1, 140, 142, 145 }, scroll = 273092, train = 140, sq = 2, r = { { 4375, 2 }, { 4371, 1 }, { 4234, 1 } }, out = { 279949, 1 }, oq = 1 },
    [1266893] = { name = "SAF-T Tabs", t = { 1, 25, 27, 30 }, scroll = 264201, train = 25, sq = 1, favor = 45, r = { { 2570, 1 }, { 249409, 1 } }, out = { 260784, 1 }, oq = 1 },
    [1266905] = { name = "SAF-T Dynamite", t = { 1, 25, 30, 35 }, scroll = 264202, train = 25, sq = 1, favor = 45, r = { { 4357, 2 }, { 2589, 1 } }, out = { 260792, 1 }, oq = 1 },
    [1266906] = { name = "SAF-T Copper Bomb", t = { 1, 55, 60, 65 }, scroll = 264203, train = 55, sq = 1, favor = 45, r = { { 2840, 1 }, { 4359, 1 }, { 4357, 2 }, { 2570, 1 }, { 260784, 2 } }, tool = 162, out = { 260793, 1 }, oq = 1 },
    [1266907] = { name = "EZ-Thro Wrap", t = { 1, 100, 102, 105 }, scroll = 264204, train = 100, sq = 1, favor = 45, r = { { 2592, 1 }, { 249410, 1 } }, out = { 260794, 1 }, oq = 1 },
    [1266908] = { name = "EZ-Thro Copper Bomb XL", t = { 1, 130, 155, 180 }, scroll = 264205, train = 130, sq = 1, favor = 45, r = { { 2840, 3 }, { 4364, 4 }, { 4404, 1 }, { 260794, 1 } }, tool = 162, out = { 260795, 1 }, oq = 1 },
    [1266909] = { name = "No Slip SAF-T Padding", t = { 1, 145, 147, 150 }, scroll = 264206, train = 145, sq = 1, favor = 45, r = { { 4234, 1 }, { 249430, 1 } }, out = { 260796, 1 }, oq = 1 },
    [1266910] = { name = "SAF-T Bronze Bomb", t = { 1, 145, 170, 195 }, scroll = 264207, train = 145, sq = 1, r = { { 4364, 4 }, { 2841, 2 }, { 4404, 1 }, { 2592, 1 }, { 260796, 1 } }, tool = 162, out = { 260797, 1 }, oq = 1 },
    [1266911] = { name = "SAF-T Jumbo Dynamite", t = { 1, 150, 160, 170 }, scroll = 264208, train = 150, sq = 1, r = { { 4377, 2 }, { 2592, 1 }, { 260796, 1 } }, out = { 260798, 1 }, oq = 1 },
    [1266912] = { name = "SAF-T Bell", t = { 1, 175, 177, 180 }, scroll = 264209, train = 175, sq = 1, favor = 180, favorRep = 5, r = { { 2841, 2 }, { 249432, 1 } }, tool = 162, out = { 260799, 1 }, oq = 1 },
    [1266913] = { name = "Shafety Sheep", t = { 1, 200, 212, 225 }, scroll = 264210, train = 175, sq = 1, r = { { 4382, 1 }, { 4375, 1 }, { 4377, 2 }, { 2592, 2 }, { 260799, 1 } }, tool = 162, out = { 260800, 1 }, oq = 1 },
    [1266914] = { name = "EZ-Thro Fireproof Fuse", t = { 1, 190, 192, 195 }, scroll = 264211, train = 190, sq = 1, favor = 180, favorRep = 5, r = { { 4404, 1 }, { 249428, 1 } }, tool = 162, out = { 260801, 1 }, oq = 1 },
    [1266915] = { name = "EZ-Thro Bronze Mortar", t = { 1, 210, 220, 230 }, scroll = 264212, train = 190, sq = 1, r = { { 4371, 4 }, { 4387, 1 }, { 4377, 4 }, { 2319, 4 }, { 260801, 1 } }, tool = 162, out = { 260802, 1 }, oq = 1 },
    [1266916] = { name = "EZ-Thro Grenade", t = { 1, 200, 220, 240 }, scroll = 264213, train = 200, sq = 1, r = { { 3575, 1 }, { 4377, 1 }, { 4306, 1 }, { 260801, 1 } }, tool = 162, out = { 260803, 1 }, oq = 1 },
    [1266917] = { name = "SAF-T Casing", t = { 1, 215, 217, 220 }, scroll = 264214, train = 215, sq = 1, r = { { 10561, 1 }, { 4234, 1 } }, tool = 162, out = { 260804, 1 }, oq = 1 },
    [1266918] = { name = "SAF-T Bomb", t = { 1, 215, 230, 245 }, scroll = 264215, train = 215, sq = 1, r = { { 3575, 3 }, { 4377, 3 }, { 4404, 1 }, { 260804, 1 } }, tool = 162, out = { 260805, 1 }, oq = 1 },
    [1266919] = { name = "Emergency Field Cloak", t = { 1, 245, 255, 265 }, scroll = 264216, train = 225, sq = 1, favor = 270, favorRep = 6, r = { { 4397, 1 }, { 260804, 1 } }, tool = 162, out = { 260806, 1 }, oq = 1, bop = true },
    [1266920] = { name = "Compact Critter Carrier", t = { 1, 230, 232, 235 }, scroll = 264217, train = 225, sq = 1, favor = 270, favorRep = 6, r = { { 4234, 10 }, { 10559, 10 }, { 11175, 2 }, { 10558, 1 } }, tool = 162, out = { 260807, 1 }, oq = 1 },
    [1266921] = { name = "EZ-Thro Tru-Trigger", t = { 1, 240, 242, 245 }, scroll = 264218, train = 240, sq = 1, r = { { 6037, 1 }, { 249431, 1 } }, tool = 162, out = { 260808, 1 }, oq = 1 },
    [1266922] = { name = "Tru-Trigger Frag Bomb", t = { 1, 240, 260, 280 }, scroll = 264219, train = 240, sq = 1, r = { { 10561, 1 }, { 10560, 1 }, { 10505, 1 }, { 260808, 1 } }, out = { 260809, 1 }, oq = 1 },
    [1266923] = { name = "SAF-T Disposable Parachute", t = { 1, 270, 280, 290 }, scroll = 264220, train = 250, sq = 1, favor = 270, favorRep = 6, r = { { 10518, 1 }, { 260804, 1 } }, tool = 14, out = { 260810, 1 }, oq = 1 },
    [1266924] = { name = "Gnomish Army Knife", t = { 1, 250, 252, 255 }, scroll = 264221, train = 250, scrollPrice = 6250, sq = 1, r = { { 10561, 1 }, { 10558, 1 }, { 15994, 2 } }, tool = 162, out = { 260811, 1 }, oq = 1 },
    [1266925] = { name = "Loot-A-Rang", t = { 1, 275, 277, 280 }, scroll = 264222, train = 275, scrollPrice = 6875, sq = 1, r = { { 12359, 5 }, { 16203, 5 } }, tool = 14, out = { 260812, 1 }, oq = 3 },
    [1266926] = { name = "SAF-T Tube", t = { 1, 275, 277, 280 }, scroll = 264223, train = 275, sq = 1, r = { { 12359, 1 }, { 249726, 1 } }, tool = 162, out = { 260813, 1 }, oq = 1 },
    [1266927] = { name = "SAF-T Clever Dynamite", t = { 1, 275, 285, 295 }, scroll = 264224, train = 275, sq = 1, r = { { 15992, 2 }, { 14047, 3 }, { 260813, 1 } }, tool = 162, out = { 260814, 1 }, oq = 1 },
    [1266928] = { name = "EZ-Thro Shell", t = { 1, 285, 287, 290 }, scroll = 264225, train = 285, sq = 1, r = { { 12359, 2 }, { 249429, 1 } }, tool = 162, out = { 260815, 1 }, oq = 1 },
    [1266929] = { name = "EZ-Thro Thorium Grenade", t = { 1, 285, 295, 305 }, scroll = 264226, train = 285, sq = 1, r = { { 15994, 1 }, { 12359, 3 }, { 15992, 3 }, { 14047, 3 }, { 260815, 1 } }, tool = 162, out = { 260816, 1 }, oq = 1 },
    [1266930] = { name = "EZ-Thro Dark Bomb", t = { 1, 320, 330, 340 }, scroll = 264227, train = 300, sq = 1, r = { { 15994, 2 }, { 11371, 1 }, { 15992, 3 }, { 14047, 3 }, { 260815, 1 } }, tool = 162, out = { 260817, 1 }, oq = 1 },
    [1266931] = { name = "EZ-Thro Mana Bomb", t = { 1, 320, 330, 340 }, scroll = 264228, train = 300, sq = 1, r = { { 16006, 1 }, { 12359, 3 }, { 14047, 1 }, { 260815, 1 } }, tool = 162, out = { 260818, 1 }, oq = 1 },
    [1266932] = { name = "EZ-Thro Field Transporter: Gadgetzan", t = { 1, 320, 330, 340 }, scroll = 264229, train = 300, sq = 1, r = { { 18986, 1 }, { 260815, 1 } }, tool = 162, out = { 260819, 1 }, oq = 2 },
    [1266933] = { name = "SAF-T Emergency Ripper: Everlook", t = { 1, 320, 330, 340 }, scroll = 264230, train = 300, sq = 1, r = { { 18984, 1 }, { 260813, 2 } }, tool = 162, out = { 260820, 1 }, oq = 2 },
    [1266934] = { name = "EZ and SAF Field Transporter: Mt. Hyjal", t = { 1, 320, 330, 340 }, scroll = 264231, train = 300, sq = 1, r = { { 260823, 1 }, { 260815, 1 }, { 260813, 1 } }, tool = 162, out = { 260821, 1 }, oq = 2 },
    [1266935] = { name = "Ultrasafe Rechargeable Battery", t = { 1, 320, 330, 340 }, scroll = 264232, train = 300, sq = 1, favor = 360, favorRep = 6, r = { { 249410, 2 }, { 249426, 1 }, { 249431, 1 }, { 12359, 3 }, { 3860, 1 }, { 248822, 1 } }, tool = 14, out = { 260822, 1 }, oq = 2 },
    [1266936] = { name = "Dimensional Transporter - Mt. Hyjal", t = { 1, 320, 330, 340 }, scroll = 264233, train = 300, scrollPrice = 100000, sq = 1, r = { { 3860, 10 }, { 18631, 1 }, { 7075, 4 }, { 7082, 4 }, { 251290, 2 } }, tool = 162, out = { 260823, 1 }, oq = 2 },
    [1266937] = { name = "Gnomish Poultryizer", t = { 1, 320, 330, 340 }, scroll = 264234, train = 300, sq = 1, favor = 360, favorRep = 6, r = { { 16204, 10 }, { 14344, 2 }, { 249726, 2 }, { 251290, 2 } }, tool = 14, out = { 260824, 1 }, oq = 3, bop = true },
    [1266938] = { name = "Ultralight Goblin Glider", t = { 1, 320, 330, 340 }, scroll = 264235, train = 300, sq = 1, favor = 360, favorRep = 6, r = { { 249431, 2 }, { 249726, 2 }, { 249429, 8 }, { 12359, 8 } }, tool = 14, out = { 260825, 1 }, oq = 2 },
    [1266939] = { name = "Gnomish Weather Machine", t = { 1, 320, 330, 340 }, scroll = 264236, train = 300, sq = 1, r = { { 7076, 2 }, { 7078, 2 }, { 7082, 2 }, { 7080, 2 }, { 248822, 2 } }, tool = 14, out = { 260826, 1 }, oq = 2 },
    [1266940] = { name = "Stealthman 52", t = { 1, 320, 330, 340 }, scroll = 264237, train = 300, sq = 1, favor = 360, favorRep = 6, r = { { 7082, 6 }, { 16204, 6 }, { 248820, 2 }, { 251290, 2 }, { 248823, 4 } }, tool = 14, out = { 260827, 1 }, oq = 2 },
    [1286792] = { name = "Centaur Banner Deployment Device", t = { 1, 190, 197, 205 }, scroll = 269901, train = 190, scrollPrice = 3000, sq = 2, r = { { 4387, 6 }, { 4389, 2 }, { 10558, 4 }, { 4234, 30 } }, tool = 14, out = { 269900, 1 }, oq = 2 },
    [1286796] = { name = "Hoof-Shaped Foot Pedal", t = { 1, 150, 155, 160 }, scroll = 269903, train = 140, scrollPrice = 3000, sq = 2, r = { { 4387, 3 }, { 4382, 2 }, { 4389, 1 }, { 10558, 1 }, { 4234, 4 } }, tool = 14, out = { 269902, 1 }, oq = 1 },
    [1293088] = { name = "9-60 Battery Pack", t = { 1, 125, 135, 145 }, scroll = 274049, train = 115, sq = 1, r = { { 249409, 1 }, { 249391, 1 }, { 3575, 1 } }, tool = 14, out = { 274048, 1 }, oq = 1 },
    [1293849] = { name = "Swiftfeather Arrow", t = { 1, 310, 315, 320 }, scroll = 274389, train = 300, sq = 4, r = { { 251291, 8 }, { 17056, 5 }, { 7069, 1 } }, out = { 274387, 200 }, oq = 4, bop = true },
    [1293850] = { name = "Swiftstrike Shot", t = { 1, 310, 315, 320 }, scroll = 274390, train = 300, sq = 4, r = { { 251291, 8 }, { 12365, 8 }, { 7067, 1 } }, out = { 274388, 200 }, oq = 4, bop = true },
    [1302161] = { name = "Harvester Override Signalcaster", t = { 1, 65, 72, 80 }, scroll = 277470, train = 65, sq = 1, r = { { 255007, 4 }, { 4363, 2 }, { 4405, 1 } }, tool = 162, out = { 277132, 1 }, oq = 2, bop = true },
    [1306546] = { name = "SAF-T Ultra Precision Scope", t = { 1, 310, 317, 325 }, scroll = 279321, train = 300, sq = 4, r = { { 251290, 1 }, { 251291, 12 } }, tool = 14, out = { 279272, 1 }, oq = 3 },
    [1306547] = { name = "Hyper Deluxe Sniper Rifle Mk XVII", t = { 1, 310, 317, 325 }, scroll = 279322, train = 300, sq = 4, r = { { 274030, 4 }, { 251290, 2 }, { 251291, 10 }, { 12800, 1 } }, tool = 14, out = { 279273, 1 }, oq = 4 },
    [1308178] = { name = "Whimsical Waistwrap", t = { 1, 180, 182, 185 }, scroll = 280321, train = 175, sq = 2, favor = 180, favorRep = 5, r = { { 4382, 2 }, { 4375, 1 }, { 4305, 2 } }, tool = 14, out = { 280306, 1 }, oq = 2, bop = true },
    [1308179] = { name = "Gizmo Girdle", t = { 1, 180, 182, 185 }, scroll = 280322, train = 175, sq = 2, favor = 180, favorRep = 5, r = { { 4375, 2 }, { 4382, 1 }, { 2319, 4 } }, tool = 14, out = { 280307, 1 }, oq = 2, bop = true },
    [1308180] = { name = "Clanking Cord", t = { 1, 180, 182, 185 }, scroll = 280323, train = 175, sq = 2, favor = 180, favorRep = 5, r = { { 4371, 2 }, { 4363, 1 }, { 2319, 4 } }, tool = 14, out = { 280308, 1 }, oq = 2, bop = true },
    [1308182] = { name = "Serrated Strap", t = { 1, 180, 182, 185 }, scroll = 280324, train = 175, sq = 2, r = { { 4363, 2 }, { 4371, 1 }, { 3575, 1 } }, tool = 14, out = { 280309, 1 }, oq = 1 },
    [1308183] = { name = "Floppy Goggles", t = { 1, 205, 207, 210 }, scroll = 280325, train = 200, sq = 2, favor = 180, favorRep = 5, r = { { 5507, 1 }, { 4389, 1 }, { 4339, 4 } }, tool = 14, out = { 280310, 1 }, oq = 2, bop = true },
    [1308184] = { name = "Bent Goggles", t = { 1, 205, 207, 210 }, scroll = 280326, train = 200, sq = 2, favor = 180, favorRep = 5, r = { { 5507, 1 }, { 4389, 1 }, { 4234, 8 } }, tool = 14, out = { 280311, 1 }, oq = 2, bop = true },
    [1308185] = { name = "Stuckbutton Goggles", t = { 1, 205, 207, 210 }, scroll = 280327, train = 200, sq = 2, favor = 180, favorRep = 5, r = { { 5507, 1 }, { 4389, 1 }, { 4234, 8 } }, tool = 14, out = { 280312, 1 }, oq = 2, bop = true },
    [1308186] = { name = "Dented Goggles", t = { 1, 205, 207, 210 }, scroll = 280328, train = 200, sq = 2, favor = 180, favorRep = 5, r = { { 5507, 1 }, { 4389, 1 }, { 3860, 2 } }, tool = 14, out = { 280313, 1 }, oq = 2, bop = true },
    [1317270] = { name = "Unsanctified Grenade", t = { 1, 280, 290, 300 }, scroll = 284870, train = 260, sq = 1, r = { { 18631, 1 }, { 12655, 2 }, { 15992, 3 }, { 14047, 2 } }, tool = 162, out = { 284869, 3 }, oq = 1 },
    [1317958] = { name = "Satchel of Copper Bombs", t = { 1, 90, 92, 95 }, scroll = 285285, train = 85, sq = 2, favor = 45, r = { { 4360, 20 }, { 2318, 6 }, { 4359, 4 } }, out = { 285275, 1 }, oq = 2, bop = true },
    [1317959] = { name = "Satchel of Bronze Bombs", t = { 1, 170, 172, 175 }, scroll = 285286, train = 165, sq = 2, favor = 180, favorRep = 5, r = { { 4380, 20 }, { 2319, 6 }, { 4375, 1 } }, out = { 285276, 1 }, oq = 2, bop = true },
    [1317960] = { name = "Satchel of Iron Bombs", t = { 1, 235, 237, 240 }, scroll = 285287, train = 230, sq = 2, favor = 270, favorRep = 6, r = { { 4394, 20 }, { 4304, 6 }, { 4389, 1 } }, out = { 285277, 1 }, oq = 2, bop = true },
    [1317961] = { name = "Satchel of Dark Iron Bombs", t = { 1, 290, 292, 295 }, scroll = 285288, train = 285, sq = 2, favor = 270, favorRep = 6, r = { { 16005, 20 }, { 8170, 6 }, { 10560, 1 } }, out = { 285278, 1 }, oq = 2, bop = true },
    [1319154] = { name = "Small Purple Rocket", t = { 1, 125, 137, 150 }, scroll = 286076, train = 125, sq = 2, r = { { 4364, 1 }, { 2319, 1 } }, out = { 21560, 5 }, oq = 1 },
    [1319155] = { name = "Small White Rocket", t = { 1, 125, 137, 150 }, scroll = 286077, train = 125, sq = 2, r = { { 4364, 1 }, { 2319, 1 } }, out = { 21561, 5 }, oq = 1 },
    [1319156] = { name = "Small Yellow Rocket", t = { 1, 125, 137, 150 }, scroll = 286078, train = 125, sq = 2, r = { { 4364, 1 }, { 2319, 1 } }, out = { 21562, 5 }, oq = 1 },
    [1319157] = { name = "Large Purple Rocket", t = { 1, 175, 187, 200 }, scroll = 286079, train = 175, sq = 2, r = { { 4377, 1 }, { 4234, 1 } }, out = { 21591, 5 }, oq = 1 },
    [1319158] = { name = "Large White Rocket", t = { 1, 175, 187, 200 }, scroll = 286080, train = 175, sq = 2, r = { { 4377, 1 }, { 4234, 1 } }, out = { 21593, 5 }, oq = 1 },
    [1319159] = { name = "Large Yellow Rocket", t = { 1, 175, 187, 200 }, scroll = 286081, train = 175, sq = 2, r = { { 4377, 1 }, { 4234, 1 } }, out = { 21595, 5 }, oq = 1 },
    [1319160] = { name = "Purple Rocket Cluster", t = { 1, 225, 237, 250 }, scroll = 286082, train = 225, sq = 2, r = { { 10505, 1 }, { 4304, 1 } }, out = { 21575, 5 }, oq = 1 },
    [1319161] = { name = "White Rocket Cluster", t = { 1, 225, 237, 250 }, scroll = 286083, train = 225, sq = 2, r = { { 10505, 1 }, { 4304, 1 } }, out = { 21577, 5 }, oq = 1 },
    [1319162] = { name = "Yellow Rocket Cluster", t = { 1, 225, 237, 250 }, scroll = 286084, train = 225, sq = 2, r = { { 10505, 1 }, { 4304, 1 } }, out = { 21578, 5 }, oq = 1 },
    [1319163] = { name = "Large Purple Rocket Cluster", t = { 1, 275, 280, 285 }, scroll = 286085, train = 275, sq = 2, r = { { 15992, 1 }, { 8170, 1 } }, out = { 21717, 5 }, oq = 1 },
    [1319164] = { name = "Large White Rocket Cluster", t = { 1, 275, 280, 285 }, scroll = 286086, train = 275, sq = 2, r = { { 15992, 1 }, { 8170, 1 } }, out = { 21719, 5 }, oq = 1 },
    [1319165] = { name = "Large Yellow Rocket Cluster", t = { 1, 275, 280, 285 }, scroll = 286087, train = 275, sq = 2, r = { { 15992, 1 }, { 8170, 1 } }, out = { 21720, 5 }, oq = 1 },
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
ES.Data.VendorPrices[2880] = 100
ES.Data.VendorPrices[3030] = 2
ES.Data.VendorPrices[4371] = 800
ES.Data.VendorPrices[4389] = 3000
ES.Data.VendorPrices[4399] = 200
ES.Data.VendorPrices[4400] = 2000
ES.Data.VendorPrices[5956] = 18
ES.Data.VendorPrices[6219] = 721
ES.Data.VendorPrices[6530] = 100
ES.Data.VendorPrices[16583] = 10000
ES.Data.SellPrices[159] = 1
ES.Data.SellPrices[774] = 15
ES.Data.SellPrices[814] = 25
ES.Data.SellPrices[818] = 100
ES.Data.SellPrices[1206] = 400
ES.Data.SellPrices[1210] = 250
ES.Data.SellPrices[1529] = 700
ES.Data.SellPrices[1705] = 600
ES.Data.SellPrices[2318] = 15
ES.Data.SellPrices[2319] = 50
ES.Data.SellPrices[2570] = 11
ES.Data.SellPrices[2589] = 13
ES.Data.SellPrices[2592] = 33
ES.Data.SellPrices[2835] = 2
ES.Data.SellPrices[2836] = 15
ES.Data.SellPrices[2838] = 60
ES.Data.SellPrices[2840] = 10
ES.Data.SellPrices[2841] = 50
ES.Data.SellPrices[2842] = 100
ES.Data.SellPrices[2880] = 25
ES.Data.SellPrices[2996] = 40
ES.Data.SellPrices[3575] = 200
ES.Data.SellPrices[3577] = 600
ES.Data.SellPrices[3829] = 150
ES.Data.SellPrices[3859] = 60
ES.Data.SellPrices[3860] = 400
ES.Data.SellPrices[3864] = 800
ES.Data.SellPrices[4234] = 150
ES.Data.SellPrices[4304] = 300
ES.Data.SellPrices[4305] = 600
ES.Data.SellPrices[4306] = 150
ES.Data.SellPrices[4337] = 750
ES.Data.SellPrices[4338] = 250
ES.Data.SellPrices[4339] = 1250
ES.Data.SellPrices[4357] = 4
ES.Data.SellPrices[4358] = 30
ES.Data.SellPrices[4359] = 12
ES.Data.SellPrices[4360] = 60
ES.Data.SellPrices[4361] = 120
ES.Data.SellPrices[4362] = 187
ES.Data.SellPrices[4363] = 50
ES.Data.SellPrices[4364] = 12
ES.Data.SellPrices[4365] = 75
ES.Data.SellPrices[4366] = 75
ES.Data.SellPrices[4367] = 150
ES.Data.SellPrices[4368] = 408
ES.Data.SellPrices[4369] = 790
ES.Data.SellPrices[4370] = 175
ES.Data.SellPrices[4371] = 200
ES.Data.SellPrices[4372] = 1800
ES.Data.SellPrices[4373] = 722
ES.Data.SellPrices[4374] = 200
ES.Data.SellPrices[4375] = 115
ES.Data.SellPrices[4376] = 200
ES.Data.SellPrices[4377] = 150
ES.Data.SellPrices[4378] = 350
ES.Data.SellPrices[4379] = 2357
ES.Data.SellPrices[4380] = 500
ES.Data.SellPrices[4381] = 600
ES.Data.SellPrices[4382] = 600
ES.Data.SellPrices[4383] = 3183
ES.Data.SellPrices[4384] = 1000
ES.Data.SellPrices[4385] = 1410
ES.Data.SellPrices[4386] = 175
ES.Data.SellPrices[4387] = 400
ES.Data.SellPrices[4388] = 1000
ES.Data.SellPrices[4389] = 750
ES.Data.SellPrices[4390] = 500
ES.Data.SellPrices[4391] = 4000
ES.Data.SellPrices[4392] = 2500
ES.Data.SellPrices[4393] = 2632
ES.Data.SellPrices[4394] = 750
ES.Data.SellPrices[4395] = 1600
ES.Data.SellPrices[4396] = 6000
ES.Data.SellPrices[4397] = 5000
ES.Data.SellPrices[4398] = 900
ES.Data.SellPrices[4399] = 50
ES.Data.SellPrices[4400] = 500
ES.Data.SellPrices[4401] = 100
ES.Data.SellPrices[4402] = 250
ES.Data.SellPrices[4403] = 2000
ES.Data.SellPrices[4404] = 25
ES.Data.SellPrices[4405] = 125
ES.Data.SellPrices[4406] = 600
ES.Data.SellPrices[4407] = 1200
ES.Data.SellPrices[4611] = 50
ES.Data.SellPrices[4852] = 300
ES.Data.SellPrices[5507] = 600
ES.Data.SellPrices[5956] = 3
ES.Data.SellPrices[6037] = 1250
ES.Data.SellPrices[6219] = 144
ES.Data.SellPrices[6530] = 25
ES.Data.SellPrices[6533] = 62
ES.Data.SellPrices[6712] = 12
ES.Data.SellPrices[6714] = 75
ES.Data.SellPrices[7067] = 400
ES.Data.SellPrices[7068] = 400
ES.Data.SellPrices[7069] = 400
ES.Data.SellPrices[7075] = 400
ES.Data.SellPrices[7076] = 400
ES.Data.SellPrices[7077] = 400
ES.Data.SellPrices[7078] = 400
ES.Data.SellPrices[7079] = 400
ES.Data.SellPrices[7080] = 400
ES.Data.SellPrices[7082] = 400
ES.Data.SellPrices[7148] = 21
ES.Data.SellPrices[7189] = 4712
ES.Data.SellPrices[7387] = 2587
ES.Data.SellPrices[7506] = 500
ES.Data.SellPrices[7909] = 1000
ES.Data.SellPrices[7910] = 5000
ES.Data.SellPrices[7912] = 100
ES.Data.SellPrices[7972] = 400
ES.Data.SellPrices[8150] = 250
ES.Data.SellPrices[8151] = 250
ES.Data.SellPrices[8153] = 5
ES.Data.SellPrices[8170] = 500
ES.Data.SellPrices[9060] = 1000
ES.Data.SellPrices[9061] = 250
ES.Data.SellPrices[9262] = 1000
ES.Data.SellPrices[9312] = 5
ES.Data.SellPrices[9313] = 5
ES.Data.SellPrices[9318] = 5
ES.Data.SellPrices[10026] = 5459
ES.Data.SellPrices[10285] = 1000
ES.Data.SellPrices[10286] = 400
ES.Data.SellPrices[10498] = 16
ES.Data.SellPrices[10499] = 2105
ES.Data.SellPrices[10500] = 3478
ES.Data.SellPrices[10501] = 4398
ES.Data.SellPrices[10502] = 4088
ES.Data.SellPrices[10503] = 5169
ES.Data.SellPrices[10504] = 7770
ES.Data.SellPrices[10505] = 250
ES.Data.SellPrices[10506] = 5227
ES.Data.SellPrices[10507] = 350
ES.Data.SellPrices[10508] = 8958
ES.Data.SellPrices[10510] = 11369
ES.Data.SellPrices[10512] = 2
ES.Data.SellPrices[10513] = 5
ES.Data.SellPrices[10514] = 750
ES.Data.SellPrices[10518] = 4696
ES.Data.SellPrices[10542] = 5255
ES.Data.SellPrices[10543] = 3517
ES.Data.SellPrices[10545] = 3929
ES.Data.SellPrices[10546] = 1500
ES.Data.SellPrices[10548] = 2500
ES.Data.SellPrices[10558] = 250
ES.Data.SellPrices[10559] = 750
ES.Data.SellPrices[10560] = 1000
ES.Data.SellPrices[10561] = 1000
ES.Data.SellPrices[10562] = 750
ES.Data.SellPrices[10576] = 6000
ES.Data.SellPrices[10577] = 2000
ES.Data.SellPrices[10586] = 750
ES.Data.SellPrices[10587] = 1500
ES.Data.SellPrices[10588] = 5834
ES.Data.SellPrices[10592] = 150
ES.Data.SellPrices[10645] = 750
ES.Data.SellPrices[10646] = 500
ES.Data.SellPrices[10716] = 750
ES.Data.SellPrices[10719] = 1500
ES.Data.SellPrices[10720] = 750
ES.Data.SellPrices[10721] = 3317
ES.Data.SellPrices[10724] = 4697
ES.Data.SellPrices[10725] = 1500
ES.Data.SellPrices[10726] = 5520
ES.Data.SellPrices[10727] = 2000
ES.Data.SellPrices[11175] = 1
ES.Data.SellPrices[11371] = 600
ES.Data.SellPrices[11590] = 250
ES.Data.SellPrices[11825] = 2500
ES.Data.SellPrices[12359] = 600
ES.Data.SellPrices[12360] = 5000
ES.Data.SellPrices[12361] = 7000
ES.Data.SellPrices[12364] = 10000
ES.Data.SellPrices[12365] = 250
ES.Data.SellPrices[12655] = 500
ES.Data.SellPrices[12799] = 7000
ES.Data.SellPrices[12800] = 10000
ES.Data.SellPrices[12803] = 500
ES.Data.SellPrices[12804] = 2000
ES.Data.SellPrices[12808] = 1000
ES.Data.SellPrices[12810] = 500
ES.Data.SellPrices[13467] = 250
ES.Data.SellPrices[14047] = 400
ES.Data.SellPrices[14227] = 2500
ES.Data.SellPrices[14344] = 1
ES.Data.SellPrices[15407] = 500
ES.Data.SellPrices[15846] = 7500
ES.Data.SellPrices[15992] = 250
ES.Data.SellPrices[15993] = 1500
ES.Data.SellPrices[15994] = 2500
ES.Data.SellPrices[15995] = 19739
ES.Data.SellPrices[15996] = 2500
ES.Data.SellPrices[15997] = 10
ES.Data.SellPrices[15999] = 9002
ES.Data.SellPrices[16000] = 3750
ES.Data.SellPrices[16004] = 29152
ES.Data.SellPrices[16005] = 1250
ES.Data.SellPrices[16006] = 10000
ES.Data.SellPrices[16007] = 40625
ES.Data.SellPrices[16008] = 11739
ES.Data.SellPrices[16009] = 5930
ES.Data.SellPrices[16022] = 40000
ES.Data.SellPrices[16023] = 10000
ES.Data.SellPrices[16040] = 4000
ES.Data.SellPrices[16203] = 1
ES.Data.SellPrices[16204] = 1
ES.Data.SellPrices[16583] = 2500
ES.Data.SellPrices[17010] = 2000
ES.Data.SellPrices[17011] = 2000
ES.Data.SellPrices[17056] = 7
ES.Data.SellPrices[17716] = 7500
ES.Data.SellPrices[18168] = 56416
ES.Data.SellPrices[18232] = 10000
ES.Data.SellPrices[18282] = 66347
ES.Data.SellPrices[18283] = 25000
ES.Data.SellPrices[18587] = 2000
ES.Data.SellPrices[18588] = 200
ES.Data.SellPrices[18594] = 3000
ES.Data.SellPrices[18631] = 3000
ES.Data.SellPrices[18634] = 12500
ES.Data.SellPrices[18637] = 600
ES.Data.SellPrices[18638] = 12500
ES.Data.SellPrices[18639] = 12500
ES.Data.SellPrices[18641] = 500
ES.Data.SellPrices[18645] = 1500
ES.Data.SellPrices[18660] = 7500
ES.Data.SellPrices[18984] = 5000
ES.Data.SellPrices[18986] = 5000
ES.Data.SellPrices[19026] = 250
ES.Data.SellPrices[19726] = 500
ES.Data.SellPrices[19774] = 5000
ES.Data.SellPrices[19998] = 23211
ES.Data.SellPrices[19999] = 18639
ES.Data.SellPrices[20725] = 1
ES.Data.SellPrices[21277] = 1250
ES.Data.SellPrices[21557] = 6
ES.Data.SellPrices[21558] = 6
ES.Data.SellPrices[21559] = 6
ES.Data.SellPrices[21560] = 2
ES.Data.SellPrices[21561] = 6
ES.Data.SellPrices[21562] = 6
ES.Data.SellPrices[21571] = 25
ES.Data.SellPrices[21574] = 25
ES.Data.SellPrices[21575] = 25
ES.Data.SellPrices[21576] = 25
ES.Data.SellPrices[21577] = 25
ES.Data.SellPrices[21578] = 25
ES.Data.SellPrices[21589] = 12
ES.Data.SellPrices[21590] = 12
ES.Data.SellPrices[21591] = 12
ES.Data.SellPrices[21592] = 12
ES.Data.SellPrices[21593] = 12
ES.Data.SellPrices[21595] = 12
ES.Data.SellPrices[21714] = 50
ES.Data.SellPrices[21716] = 50
ES.Data.SellPrices[21717] = 50
ES.Data.SellPrices[21718] = 50
ES.Data.SellPrices[21719] = 50
ES.Data.SellPrices[21720] = 50
ES.Data.SellPrices[22202] = 2500
ES.Data.SellPrices[22728] = 5000
ES.Data.SellPrices[213369] = 280
ES.Data.SellPrices[213379] = 280
ES.Data.SellPrices[215430] = 250
ES.Data.SellPrices[248820] = 15000
ES.Data.SellPrices[248822] = 1500
ES.Data.SellPrices[248823] = 150
ES.Data.SellPrices[249391] = 100
ES.Data.SellPrices[249409] = 75
ES.Data.SellPrices[249410] = 125
ES.Data.SellPrices[249425] = 250
ES.Data.SellPrices[249426] = 375
ES.Data.SellPrices[249428] = 250
ES.Data.SellPrices[249429] = 375
ES.Data.SellPrices[249430] = 250
ES.Data.SellPrices[249431] = 375
ES.Data.SellPrices[249432] = 250
ES.Data.SellPrices[249726] = 3000
ES.Data.SellPrices[251290] = 5000
ES.Data.SellPrices[251291] = 1500
ES.Data.SellPrices[255007] = 22
ES.Data.SellPrices[260784] = 4
ES.Data.SellPrices[260792] = 75
ES.Data.SellPrices[260793] = 60
ES.Data.SellPrices[260794] = 150
ES.Data.SellPrices[260795] = 175
ES.Data.SellPrices[260796] = 200
ES.Data.SellPrices[260797] = 200
ES.Data.SellPrices[260798] = 350
ES.Data.SellPrices[260799] = 250
ES.Data.SellPrices[260800] = 1000
ES.Data.SellPrices[260801] = 300
ES.Data.SellPrices[260802] = 2000
ES.Data.SellPrices[260803] = 350
ES.Data.SellPrices[260804] = 1000
ES.Data.SellPrices[260805] = 750
ES.Data.SellPrices[260806] = 5000
ES.Data.SellPrices[260807] = 200
ES.Data.SellPrices[260808] = 1100
ES.Data.SellPrices[260809] = 750
ES.Data.SellPrices[260810] = 4696
ES.Data.SellPrices[260811] = 1000
ES.Data.SellPrices[260812] = 2000
ES.Data.SellPrices[260813] = 1500
ES.Data.SellPrices[260814] = 500
ES.Data.SellPrices[260815] = 2000
ES.Data.SellPrices[260816] = 1500
ES.Data.SellPrices[260817] = 1250
ES.Data.SellPrices[260818] = 4000
ES.Data.SellPrices[260819] = 5000
ES.Data.SellPrices[260820] = 5000
ES.Data.SellPrices[260821] = 5000
ES.Data.SellPrices[260822] = 2500
ES.Data.SellPrices[260823] = 5000
ES.Data.SellPrices[260824] = 5000
ES.Data.SellPrices[260826] = 5000
ES.Data.SellPrices[260827] = 5000
ES.Data.SellPrices[269900] = 500
ES.Data.SellPrices[269902] = 100
ES.Data.SellPrices[277132] = 200
ES.Data.SellPrices[279272] = 25000
ES.Data.SellPrices[279273] = 66347
ES.Data.SellPrices[280306] = 1710
ES.Data.SellPrices[280307] = 1716
ES.Data.SellPrices[280308] = 1033
ES.Data.SellPrices[280310] = 4987
ES.Data.SellPrices[280311] = 3764
ES.Data.SellPrices[280312] = 3784
ES.Data.SellPrices[280313] = 2201
ES.Data.SellPrices[284869] = 1500
ES.Data.SellPrices[285275] = 821
ES.Data.SellPrices[285276] = 4484
ES.Data.SellPrices[285277] = 13124
ES.Data.SellPrices[285278] = 26602

-- Nombre de cada objeto (inglés, del cliente): se muestra mientras el juego no lo ha cargado
ES.Data.ItemNames = ES.Data.ItemNames or {}
ES.Data.ItemNames[159] = "Refreshing Spring Water"
ES.Data.ItemNames[774] = "Malachite"
ES.Data.ItemNames[814] = "Flask of Oil"
ES.Data.ItemNames[818] = "Tigerseye"
ES.Data.ItemNames[1206] = "Moss Agate"
ES.Data.ItemNames[1210] = "Shadowgem"
ES.Data.ItemNames[1529] = "Jade"
ES.Data.ItemNames[1705] = "Lesser Moonstone"
ES.Data.ItemNames[2318] = "Light Leather"
ES.Data.ItemNames[2319] = "Medium Leather"
ES.Data.ItemNames[2570] = "Linen Cloak"
ES.Data.ItemNames[2589] = "Linen Cloth"
ES.Data.ItemNames[2592] = "Wool Cloth"
ES.Data.ItemNames[2835] = "Rough Stone"
ES.Data.ItemNames[2836] = "Coarse Stone"
ES.Data.ItemNames[2838] = "Heavy Stone"
ES.Data.ItemNames[2840] = "Copper Bar"
ES.Data.ItemNames[2841] = "Bronze Bar"
ES.Data.ItemNames[2842] = "Silver Bar"
ES.Data.ItemNames[2880] = "Weak Flux"
ES.Data.ItemNames[2996] = "Bolt of Linen Cloth"
ES.Data.ItemNames[3030] = "Razor Arrow"
ES.Data.ItemNames[3575] = "Iron Bar"
ES.Data.ItemNames[3577] = "Gold Bar"
ES.Data.ItemNames[3829] = "Frost Oil"
ES.Data.ItemNames[3859] = "Steel Bar"
ES.Data.ItemNames[3860] = "Mithril Bar"
ES.Data.ItemNames[3864] = "Citrine"
ES.Data.ItemNames[4234] = "Heavy Leather"
ES.Data.ItemNames[4304] = "Thick Leather"
ES.Data.ItemNames[4305] = "Bolt of Silk Cloth"
ES.Data.ItemNames[4306] = "Silk Cloth"
ES.Data.ItemNames[4337] = "Thick Spider's Silk"
ES.Data.ItemNames[4338] = "Mageweave Cloth"
ES.Data.ItemNames[4339] = "Bolt of Mageweave"
ES.Data.ItemNames[4357] = "Rough Blasting Powder"
ES.Data.ItemNames[4358] = "Rough Dynamite"
ES.Data.ItemNames[4359] = "Handful of Copper Bolts"
ES.Data.ItemNames[4360] = "Rough Copper Bomb"
ES.Data.ItemNames[4361] = "Copper Tube"
ES.Data.ItemNames[4362] = "Rough Boomstick"
ES.Data.ItemNames[4363] = "Copper Modulator"
ES.Data.ItemNames[4364] = "Coarse Blasting Powder"
ES.Data.ItemNames[4365] = "Coarse Dynamite"
ES.Data.ItemNames[4366] = "Target Dummy"
ES.Data.ItemNames[4367] = "Small Seaforium Charge"
ES.Data.ItemNames[4368] = "Flying Tiger Goggles"
ES.Data.ItemNames[4369] = "Deadly Blunderbuss"
ES.Data.ItemNames[4370] = "Large Copper Bomb"
ES.Data.ItemNames[4371] = "Bronze Tube"
ES.Data.ItemNames[4372] = "Lovingly Crafted Boomstick"
ES.Data.ItemNames[4373] = "Shadow Goggles"
ES.Data.ItemNames[4374] = "Small Bronze Bomb"
ES.Data.ItemNames[4375] = "Whirring Bronze Gizmo"
ES.Data.ItemNames[4376] = "Flame Deflector"
ES.Data.ItemNames[4377] = "Heavy Blasting Powder"
ES.Data.ItemNames[4378] = "Heavy Dynamite"
ES.Data.ItemNames[4379] = "Silver-plated Shotgun"
ES.Data.ItemNames[4380] = "Big Bronze Bomb"
ES.Data.ItemNames[4381] = "Minor Recombobulator"
ES.Data.ItemNames[4382] = "Bronze Framework"
ES.Data.ItemNames[4383] = "Moonsight Rifle"
ES.Data.ItemNames[4384] = "Explosive Sheep"
ES.Data.ItemNames[4385] = "Green Tinted Goggles"
ES.Data.ItemNames[4386] = "Ice Deflector"
ES.Data.ItemNames[4387] = "Iron Strut"
ES.Data.ItemNames[4388] = "Discombobulator Ray"
ES.Data.ItemNames[4389] = "Gyrochronatom"
ES.Data.ItemNames[4390] = "Iron Grenade"
ES.Data.ItemNames[4391] = "Compact Harvest Reaper Kit"
ES.Data.ItemNames[4392] = "Advanced Target Dummy"
ES.Data.ItemNames[4393] = "Craftsman's Monocle"
ES.Data.ItemNames[4394] = "Big Iron Bomb"
ES.Data.ItemNames[4395] = "Goblin Land Mine"
ES.Data.ItemNames[4396] = "Mechanical Dragonling"
ES.Data.ItemNames[4397] = "Gnomish Cloaking Device"
ES.Data.ItemNames[4398] = "Large Seaforium Charge"
ES.Data.ItemNames[4399] = "Wooden Stock"
ES.Data.ItemNames[4400] = "Heavy Stock"
ES.Data.ItemNames[4401] = "Mechanical Squirrel Box"
ES.Data.ItemNames[4402] = "Small Flame Sac"
ES.Data.ItemNames[4403] = "Portable Bronze Mortar"
ES.Data.ItemNames[4404] = "Silver Contact"
ES.Data.ItemNames[4405] = "Crude Scope"
ES.Data.ItemNames[4406] = "Standard Scope"
ES.Data.ItemNames[4407] = "Accurate Scope"
ES.Data.ItemNames[4611] = "Blue Pearl"
ES.Data.ItemNames[4852] = "Flash Bomb"
ES.Data.ItemNames[5507] = "Ornate Spyglass"
ES.Data.ItemNames[5956] = "Blacksmith Hammer"
ES.Data.ItemNames[6037] = "Truesilver Bar"
ES.Data.ItemNames[6219] = "Arclight Spanner"
ES.Data.ItemNames[6530] = "Nightcrawlers"
ES.Data.ItemNames[6533] = "Aquadynamic Fish Attractor"
ES.Data.ItemNames[6712] = "Practice Lock"
ES.Data.ItemNames[6714] = "Ez-Thro Dynamite"
ES.Data.ItemNames[7067] = "Elemental Earth"
ES.Data.ItemNames[7068] = "Elemental Fire"
ES.Data.ItemNames[7069] = "Elemental Air"
ES.Data.ItemNames[7075] = "Core of Earth"
ES.Data.ItemNames[7076] = "Essence of Earth"
ES.Data.ItemNames[7077] = "Heart of Fire"
ES.Data.ItemNames[7078] = "Essence of Fire"
ES.Data.ItemNames[7079] = "Globe of Water"
ES.Data.ItemNames[7080] = "Essence of Water"
ES.Data.ItemNames[7082] = "Essence of Air"
ES.Data.ItemNames[7148] = "Goblin Jumper Cables"
ES.Data.ItemNames[7189] = "Goblin Rocket Boots"
ES.Data.ItemNames[7191] = "Fused Wiring"
ES.Data.ItemNames[7387] = "Dusky Belt"
ES.Data.ItemNames[7506] = "Gnomish Universal Remote"
ES.Data.ItemNames[7909] = "Aquamarine"
ES.Data.ItemNames[7910] = "Star Ruby"
ES.Data.ItemNames[7912] = "Solid Stone"
ES.Data.ItemNames[7972] = "Ichor of Undeath"
ES.Data.ItemNames[8067] = "Crafted Light Shot"
ES.Data.ItemNames[8068] = "Crafted Heavy Shot"
ES.Data.ItemNames[8069] = "Crafted Solid Shot"
ES.Data.ItemNames[8150] = "Deeprock Salt"
ES.Data.ItemNames[8151] = "Flask of Mojo"
ES.Data.ItemNames[8153] = "Wildvine"
ES.Data.ItemNames[8170] = "Rugged Leather"
ES.Data.ItemNames[9060] = "Inlaid Mithril Cylinder"
ES.Data.ItemNames[9061] = "Goblin Rocket Fuel"
ES.Data.ItemNames[9262] = "Black Vitriol"
ES.Data.ItemNames[9312] = "Blue Firework"
ES.Data.ItemNames[9313] = "Green Firework"
ES.Data.ItemNames[9318] = "Red Firework"
ES.Data.ItemNames[10026] = "Black Mageweave Boots"
ES.Data.ItemNames[10285] = "Shadow Silk"
ES.Data.ItemNames[10286] = "Heart of the Wild"
ES.Data.ItemNames[10498] = "Gyromatic Micro-Adjustor"
ES.Data.ItemNames[10499] = "Bright-Eye Goggles"
ES.Data.ItemNames[10500] = "Fire Goggles"
ES.Data.ItemNames[10501] = "Catseye Ultra Goggles"
ES.Data.ItemNames[10502] = "Spellpower Goggles Xtreme"
ES.Data.ItemNames[10503] = "Rose Colored Goggles"
ES.Data.ItemNames[10504] = "Green Lens"
ES.Data.ItemNames[10505] = "Solid Blasting Powder"
ES.Data.ItemNames[10506] = "Deepdive Helmet"
ES.Data.ItemNames[10507] = "Solid Dynamite"
ES.Data.ItemNames[10508] = "Mithril Blunderbuss"
ES.Data.ItemNames[10510] = "Mithril Heavy-bore Rifle"
ES.Data.ItemNames[10512] = "Hi-Impact Mithril Slugs"
ES.Data.ItemNames[10513] = "Mithril Gyro-Shot"
ES.Data.ItemNames[10514] = "Mithril Frag Bomb"
ES.Data.ItemNames[10518] = "Parachute Cloak"
ES.Data.ItemNames[10542] = "Goblin Mining Helmet"
ES.Data.ItemNames[10543] = "Goblin Construction Helmet"
ES.Data.ItemNames[10545] = "Gnomish Goggles"
ES.Data.ItemNames[10546] = "Deadly Scope"
ES.Data.ItemNames[10548] = "Sniper Scope"
ES.Data.ItemNames[10558] = "Gold Power Core"
ES.Data.ItemNames[10559] = "Mithril Tube"
ES.Data.ItemNames[10560] = "Unstable Trigger"
ES.Data.ItemNames[10561] = "Mithril Casing"
ES.Data.ItemNames[10562] = "Hi-Explosive Bomb"
ES.Data.ItemNames[10576] = "Mithril Mechanical Dragonling"
ES.Data.ItemNames[10577] = "Goblin Mortar"
ES.Data.ItemNames[10579] = "Explosive Arrow"
ES.Data.ItemNames[10586] = "The Big One"
ES.Data.ItemNames[10587] = "Goblin Bomb Dispenser"
ES.Data.ItemNames[10588] = "Goblin Rocket Helmet"
ES.Data.ItemNames[10592] = "Catseye Draught"
ES.Data.ItemNames[10645] = "Gnomish Death Ray"
ES.Data.ItemNames[10646] = "Goblin Sapper Charge"
ES.Data.ItemNames[10716] = "Gnomish Shrink Ray"
ES.Data.ItemNames[10719] = "Mobile Alarm"
ES.Data.ItemNames[10720] = "Gnomish Net-o-Matic Projector"
ES.Data.ItemNames[10721] = "Gnomish Harm Prevention Belt"
ES.Data.ItemNames[10724] = "Gnomish Rocket Boots"
ES.Data.ItemNames[10725] = "Gnomish Battle Chicken"
ES.Data.ItemNames[10726] = "Gnomish Mind Control Cap"
ES.Data.ItemNames[10727] = "Goblin Dragon Gun"
ES.Data.ItemNames[11175] = "Greater Nether Essence"
ES.Data.ItemNames[11371] = "Dark Iron Bar"
ES.Data.ItemNames[11590] = "Mechanical Repair Kit"
ES.Data.ItemNames[11825] = "Pet Bombling"
ES.Data.ItemNames[12359] = "Thorium Bar"
ES.Data.ItemNames[12360] = "Arcanite Bar"
ES.Data.ItemNames[12361] = "Blue Sapphire"
ES.Data.ItemNames[12364] = "Huge Emerald"
ES.Data.ItemNames[12365] = "Dense Stone"
ES.Data.ItemNames[12655] = "Enchanted Thorium Bar"
ES.Data.ItemNames[12799] = "Large Opal"
ES.Data.ItemNames[12800] = "Azerothian Diamond"
ES.Data.ItemNames[12803] = "Living Essence"
ES.Data.ItemNames[12804] = "Powerful Mojo"
ES.Data.ItemNames[12808] = "Essence of Undeath"
ES.Data.ItemNames[12810] = "Enchanted Leather"
ES.Data.ItemNames[13467] = "Icecap"
ES.Data.ItemNames[14047] = "Runecloth"
ES.Data.ItemNames[14227] = "Ironweb Spider Silk"
ES.Data.ItemNames[14344] = "Large Brilliant Shard"
ES.Data.ItemNames[15407] = "Cured Rugged Hide"
ES.Data.ItemNames[15846] = "Salt Shaker"
ES.Data.ItemNames[15992] = "Dense Blasting Powder"
ES.Data.ItemNames[15993] = "Thorium Grenade"
ES.Data.ItemNames[15994] = "Thorium Widget"
ES.Data.ItemNames[15995] = "Thorium Rifle"
ES.Data.ItemNames[15996] = "Lifelike Mechanical Toad"
ES.Data.ItemNames[15997] = "Thorium Shells"
ES.Data.ItemNames[15999] = "Spellpower Goggles Xtreme Plus"
ES.Data.ItemNames[16000] = "Thorium Tube"
ES.Data.ItemNames[16004] = "Dark Iron Rifle"
ES.Data.ItemNames[16005] = "Dark Iron Bomb"
ES.Data.ItemNames[16006] = "Delicate Arcanite Converter"
ES.Data.ItemNames[16007] = "Flawless Arcanite Rifle"
ES.Data.ItemNames[16008] = "Master Engineer's Goggles"
ES.Data.ItemNames[16009] = "Voice Amplification Modulator"
ES.Data.ItemNames[16022] = "Arcanite Dragonling"
ES.Data.ItemNames[16023] = "Masterwork Target Dummy"
ES.Data.ItemNames[16040] = "Arcane Bomb"
ES.Data.ItemNames[16203] = "Greater Eternal Essence"
ES.Data.ItemNames[16204] = "Illusion Dust"
ES.Data.ItemNames[16583] = "Demonic Figurine"
ES.Data.ItemNames[17010] = "Fiery Core"
ES.Data.ItemNames[17011] = "Lava Core"
ES.Data.ItemNames[17056] = "Light Feather"
ES.Data.ItemNames[17202] = "Snowball"
ES.Data.ItemNames[17716] = "Snowmaster 9000"
ES.Data.ItemNames[18168] = "Force Reactive Disk"
ES.Data.ItemNames[18232] = "Field Repair Bot 74A"
ES.Data.ItemNames[18282] = "Core Marksman Rifle"
ES.Data.ItemNames[18283] = "Biznicks 247x128 Accurascope"
ES.Data.ItemNames[18587] = "Goblin Jumper Cables XL"
ES.Data.ItemNames[18588] = "Ez-Thro Dynamite II"
ES.Data.ItemNames[18594] = "Powerful Seaforium Charge"
ES.Data.ItemNames[18631] = "Truesilver Transformer"
ES.Data.ItemNames[18634] = "Gyrofreeze Ice Reflector"
ES.Data.ItemNames[18637] = "Major Recombobulator"
ES.Data.ItemNames[18638] = "Hyper-Radiant Flame Reflector"
ES.Data.ItemNames[18639] = "Ultra-Flash Shadow Reflector"
ES.Data.ItemNames[18641] = "Dense Dynamite"
ES.Data.ItemNames[18645] = "Gnomish Alarm-O-Bot"
ES.Data.ItemNames[18660] = "World Enlarger"
ES.Data.ItemNames[18984] = "Dimensional Ripper - Everlook"
ES.Data.ItemNames[18986] = "Ultrasafe Transporter: Gadgetzan"
ES.Data.ItemNames[19026] = "Snake Burst Firework"
ES.Data.ItemNames[19726] = "Bloodvine"
ES.Data.ItemNames[19774] = "Souldarite"
ES.Data.ItemNames[19998] = "Bloodvine Lens"
ES.Data.ItemNames[19999] = "Bloodvine Goggles"
ES.Data.ItemNames[20725] = "Nexus Crystal"
ES.Data.ItemNames[21277] = "Tranquil Mechanical Yeti"
ES.Data.ItemNames[21557] = "Small Red Rocket"
ES.Data.ItemNames[21558] = "Small Blue Rocket"
ES.Data.ItemNames[21559] = "Small Green Rocket"
ES.Data.ItemNames[21560] = "Small Purple Rocket"
ES.Data.ItemNames[21561] = "Small White Rocket"
ES.Data.ItemNames[21562] = "Small Yellow Rocket"
ES.Data.ItemNames[21569] = "Firework Launcher"
ES.Data.ItemNames[21570] = "Cluster Launcher"
ES.Data.ItemNames[21571] = "Blue Rocket Cluster"
ES.Data.ItemNames[21574] = "Green Rocket Cluster"
ES.Data.ItemNames[21575] = "Purple Rocket Cluster"
ES.Data.ItemNames[21576] = "Red Rocket Cluster"
ES.Data.ItemNames[21577] = "White Rocket Cluster"
ES.Data.ItemNames[21578] = "Yellow Rocket Cluster"
ES.Data.ItemNames[21589] = "Large Blue Rocket"
ES.Data.ItemNames[21590] = "Large Green Rocket"
ES.Data.ItemNames[21591] = "Large Purple Rocket"
ES.Data.ItemNames[21592] = "Large Red Rocket"
ES.Data.ItemNames[21593] = "Large White Rocket"
ES.Data.ItemNames[21595] = "Large Yellow Rocket"
ES.Data.ItemNames[21714] = "Large Blue Rocket Cluster"
ES.Data.ItemNames[21716] = "Large Green Rocket Cluster"
ES.Data.ItemNames[21717] = "Large Purple Rocket Cluster"
ES.Data.ItemNames[21718] = "Large Red Rocket Cluster"
ES.Data.ItemNames[21719] = "Large White Rocket Cluster"
ES.Data.ItemNames[21720] = "Large Yellow Rocket Cluster"
ES.Data.ItemNames[22202] = "Small Obsidian Shard"
ES.Data.ItemNames[22728] = "Steam Tonk Controller"
ES.Data.ItemNames[210147] = "Shredder Autosalvage Unit"
ES.Data.ItemNames[211427] = "Soul Vessel"
ES.Data.ItemNames[213369] = "Faintly Glowing Leather"
ES.Data.ItemNames[213376] = "Low-Background Truesilver Plates"
ES.Data.ItemNames[213379] = "Hyperconductive Arcano-Filament"
ES.Data.ItemNames[213381] = "Pile of Tarnished Gears"
ES.Data.ItemNames[213383] = "Polished Truesilver Gears"
ES.Data.ItemNames[215430] = "Gnomeregan Fallout"
ES.Data.ItemNames[237023] = "Pop-Up Shrub"
ES.Data.ItemNames[248820] = "Torbernite"
ES.Data.ItemNames[248822] = "Death Lotus"
ES.Data.ItemNames[248823] = "Marefoil"
ES.Data.ItemNames[249391] = "Pyrite"
ES.Data.ItemNames[249409] = "Cerulean Dye"
ES.Data.ItemNames[249410] = "Sulfuric Acid"
ES.Data.ItemNames[249425] = "Bauxite"
ES.Data.ItemNames[249426] = "Pitchblende"
ES.Data.ItemNames[249428] = "Pristine Hide"
ES.Data.ItemNames[249429] = "Pristine Scale"
ES.Data.ItemNames[249430] = "Magenta Dye"
ES.Data.ItemNames[249431] = "Viridian Dye"
ES.Data.ItemNames[249432] = "Sandpaper"
ES.Data.ItemNames[249726] = "Azerothium Bar"
ES.Data.ItemNames[251290] = "Legionite Bar"
ES.Data.ItemNames[251291] = "Heavy Thorium Bar"
ES.Data.ItemNames[255007] = "Golem Isospring"
ES.Data.ItemNames[260784] = "SAF-T Tabs"
ES.Data.ItemNames[260792] = "SAF-T Dynamite"
ES.Data.ItemNames[260793] = "SAF-T Copper Bomb"
ES.Data.ItemNames[260794] = "EZ-Thro Wrap"
ES.Data.ItemNames[260795] = "EZ-Thro Copper Bomb XL"
ES.Data.ItemNames[260796] = "No Slip SAF-T Padding"
ES.Data.ItemNames[260797] = "SAF-T Bronze Bomb"
ES.Data.ItemNames[260798] = "SAF-T Jumbo Dynamite"
ES.Data.ItemNames[260799] = "SAF-T Bell"
ES.Data.ItemNames[260800] = "Shafety Sheep"
ES.Data.ItemNames[260801] = "EZ-Thro Fireproof Fuse"
ES.Data.ItemNames[260802] = "EZ-Thro Bronze Mortar"
ES.Data.ItemNames[260803] = "EZ-Thro Grenade"
ES.Data.ItemNames[260804] = "SAF-T Casing"
ES.Data.ItemNames[260805] = "SAF-T Bomb"
ES.Data.ItemNames[260806] = "Emergency Field Cloak"
ES.Data.ItemNames[260807] = "Compact Critter Carrier"
ES.Data.ItemNames[260808] = "EZ-Thro Tru-Trigger"
ES.Data.ItemNames[260809] = "Tru-Trigger Frag Bomb"
ES.Data.ItemNames[260810] = "SAF-T Disposable Parachute"
ES.Data.ItemNames[260811] = "Gnomish Army Knife"
ES.Data.ItemNames[260812] = "Loot-A-Rang"
ES.Data.ItemNames[260813] = "SAF-T Tube"
ES.Data.ItemNames[260814] = "SAF-T Clever Dynamite"
ES.Data.ItemNames[260815] = "EZ-Thro Shell"
ES.Data.ItemNames[260816] = "EZ-Thro Thorium Grenade"
ES.Data.ItemNames[260817] = "EZ-Thro Dark Bomb"
ES.Data.ItemNames[260818] = "EZ-Thro Mana Bomb"
ES.Data.ItemNames[260819] = "EZ-Thro Field Transporter: Gadgetzan"
ES.Data.ItemNames[260820] = "SAF-T Emergency Ripper: Everlook"
ES.Data.ItemNames[260821] = "EZ and SAF Field Transporter: Mt. Hyjal"
ES.Data.ItemNames[260822] = "Ultrasafe Rechargeable Battery"
ES.Data.ItemNames[260823] = "Dimensional Transporter - Mt. Hyjal"
ES.Data.ItemNames[260824] = "Gnomish Poultryizer"
ES.Data.ItemNames[260825] = "Ultralight Goblin Glider"
ES.Data.ItemNames[260826] = "Gnomish Weather Machine NYI"
ES.Data.ItemNames[260827] = "Stealthman 52"
ES.Data.ItemNames[269900] = "Centaur Banner Deployment Device"
ES.Data.ItemNames[269902] = "Hoof-Shaped Foot Pedal"
ES.Data.ItemNames[274030] = "Malleable Essence of Nature"
ES.Data.ItemNames[274387] = "Swiftfeather Arrow"
ES.Data.ItemNames[274388] = "Swiftstrike Shot"
ES.Data.ItemNames[277132] = "Harvester Override Signalcaster"
ES.Data.ItemNames[279272] = "SAF-T Ultra Precision Scope"
ES.Data.ItemNames[279273] = "Hyper Deluxe Sniper Rifle Mk XVII"
ES.Data.ItemNames[279949] = "Repair Bot"
ES.Data.ItemNames[279950] = "Reagent Bot"
ES.Data.ItemNames[280306] = "Whimsical Waistwrap"
ES.Data.ItemNames[280307] = "Gizmo Girdle"
ES.Data.ItemNames[280308] = "Clanking Cord"
ES.Data.ItemNames[280310] = "Floppy Goggles"
ES.Data.ItemNames[280311] = "Bent Goggles"
ES.Data.ItemNames[280312] = "Stuckbutton Goggles"
ES.Data.ItemNames[280313] = "Dented Goggles"
ES.Data.ItemNames[284869] = "Unsanctified Grenade"
ES.Data.ItemNames[285275] = "Satchel of Copper Bombs"
ES.Data.ItemNames[285276] = "Satchel of Bronze Bombs"
ES.Data.ItemNames[285277] = "Satchel of Iron Bombs"
ES.Data.ItemNames[285278] = "Satchel of Dark Iron Bombs"

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
ES.Data.GatheredBy[8150] = 186
ES.Data.GatheredBy[8153] = 182
ES.Data.GatheredBy[8170] = 393
ES.Data.GatheredBy[11371] = 186
ES.Data.GatheredBy[12359] = 186
ES.Data.GatheredBy[12365] = 186
ES.Data.GatheredBy[13467] = 182
ES.Data.GatheredBy[19726] = 182
ES.Data.GatheredBy[22202] = 186
ES.Data.GatheredBy[248822] = 182
ES.Data.GatheredBy[248823] = 182
ES.Data.GatheredBy[249391] = 186
ES.Data.GatheredBy[249425] = 186
ES.Data.GatheredBy[249426] = 186
ES.Data.GatheredBy[249428] = 393
ES.Data.GatheredBy[249429] = 393
ES.Data.GatheredBy[249726] = 186
ES.Data.GatheredBy[251291] = 186

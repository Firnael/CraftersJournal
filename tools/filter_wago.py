"""Recorta las tablas de wago.tools (cliente de WoW Forever) a lo que usa Crafter's Journal.

Uso: python filter_wago.py <carpeta con CSV completos> <tools/wago del addon>

En la carpeta de entrada (descargadas de https://wago.tools/db2/<Tabla>/csv?build=<build de Forever>):
  SpellReagents, SpellEffect, SpellTotems, TotemCategory, SpellName, ItemSparse,
  Item, ItemEffect, ItemXItemEffect
En tools/wago ya deben estar SkillLineAbility_forever.csv y SkillLineAbility_era.csv
(qué recetas tiene cada profesión en Forever y en Classic Era).
"""
import csv
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
# Peletería, Encantamiento, Sastrería, Herrería, Alquimia, Ingeniería, Cocina, Primeros auxilios
SKILL_LINES = {"165", "333", "197", "164", "171", "202", "185", "129"}
TOOL_ITEMS = {"6218", "6339", "11130", "11145", "16207", "6217", "6338", "11128", "11144", "16206",
              "5956", "9149", "6219", "10498"}  # + martillo, piedra filosofal, llave inglesa, microajustador
RECIPE_CLASS = "9"  # clase de objeto "Receta"
LEARN_SPELL = "36"  # efecto "aprender hechizo"


def read(name):
    with open(src / f"{name}.csv", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        return list(reader), reader.fieldnames


def write(name, fields, rows):
    with open(dst / f"{name}_forever.csv", "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)
    print(name, len(rows), "filas")


with open(dst / "SkillLineAbility_forever.csv", encoding="utf-8") as f:
    spells = {row["Spell"] for row in csv.DictReader(f) if row["SkillLine"] in SKILL_LINES}

items = set(TOOL_ITEMS)
effects, effect_fields = read("SpellEffect")
for name in ("SpellReagents", "SpellEffect", "SpellTotems"):
    rows, fields = (effects, effect_fields) if name == "SpellEffect" else read(name)
    rows = [row for row in rows if row["SpellID"] in spells]
    write(name, fields, rows)
    for row in rows:
        for k in range(8):
            if row.get(f"Reagent_{k}", "0") not in ("", "0"):
                items.add(row[f"Reagent_{k}"])
        if row.get("Effect") == "24" and row.get("EffectItemType", "0") not in ("", "0"):
            items.add(row["EffectItemType"])

# Pergaminos de receta: objetos de clase "Receta" cuyo efecto enseña (directamente o
# con un hechizo de "aprender") una receta de las profesiones
teaches = {row["SpellID"]: row["EffectTriggerSpell"] for row in effects if row["Effect"] == LEARN_SPELL}
item_rows, item_fields = read("Item")
recipe_items = {row["ID"] for row in item_rows if row["ClassID"] == RECIPE_CLASS}
effect_spell = {row["ID"]: row["SpellID"] for row in read("ItemEffect")[0]}
recipe_scrolls = []
for row in read("ItemXItemEffect")[0]:
    if row["ItemID"] not in recipe_items:
        continue
    spell = effect_spell.get(row["ItemEffectID"])
    target = spell if spell in spells else teaches.get(spell)
    if target in spells:
        recipe_scrolls.append({"ItemID": row["ItemID"], "Spell": target})
        items.add(row["ItemID"])
write("RecipeScrolls", ["ItemID", "Spell"], recipe_scrolls)

# Nombres de las recetas (y de cualquier hechizo de las profesiones)
names, name_fields = read("SpellName")
write("SpellName", name_fields, [row for row in names if row["ID"] in spells])

# Tipo de objeto (para saber qué se recolecta) y precios/reputación de cada objeto
write("Item", ["ID", "ClassID", "SubclassID"], [row for row in item_rows if row["ID"] in items])
keep = ["ID", "Display_lang", "BuyPrice", "SellPrice", "VendorStackCount", "MinFactionID", "MinReputation",
        "RequiredSkill", "RequiredSkillRank", "OverallQualityID", "ItemLevel", "InventoryType", "Bonding"]
sparse, _ = read("ItemSparse")
write("ItemSparse", keep, [row for row in sparse if row["ID"] in items])

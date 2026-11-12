"""Instructores y vendedores de recetas de WoW Forever, de My Forever Recipe Book.

Lee los datos del addon instalado (ForeverRecipeBook_<Profesión>/Data.lua) y guarda solo
los hechos del juego que usa el generador, en archivos nuestros:
  recipebook_trainers.csv  spell, npc, skill, cost   (quién enseña cada receta, a qué nivel y precio)
  recipebook_vendors.csv   item, npc, cost, stock    (quién vende cada pergamino)
  recipebook_npcs.csv      npc, name, map, x, y      (dónde están esos PNJ)
Crafter's Journal no depende de ese addon: estos CSV son la entrada de gen_profession.py.

Uso:  python tools/forever/import_recipebook.py [carpeta de AddOns]
"""
import csv
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ADDONS = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(r"C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns")
PROFS = ["Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "FirstAid", "Leatherworking", "Tailoring"]
SOURCE = "My Forever Recipe Book (datos de Wowhead Forever), con permiso pedido a su autor"

TEACH = re.compile(r"A\.TrainerTeachings\[\d+\]=\{[^}]*?npcID=(\d+),recipeID=(\d+),costCopper=(\d+),trainerSkill=(\d+)")
SALE = re.compile(r"A\.VendorSales\[\d+\]=\{[^}]*?npcID=(\d+),itemID=(\d+),costCopper=(\d+),stock=\"([^\"]*)\"")
NPC = re.compile(r"A\.NPCs\[(\d+)\]=\{id=\d+,name=\"((?:[^\"\\]|\\.)*)\"[^\n]*?mapID=(\d+),coordinates=\{x=([\d.]+),y=([\d.]+)\}")

teach, sales, npcs = set(), set(), {}
for prof in PROFS:
    path = ADDONS / f"ForeverRecipeBook_{prof}" / "Data.lua"
    text = path.read_text(encoding="utf-8", errors="replace")
    for m in TEACH.finditer(text):
        npc, spell, cost, skill = map(int, m.groups())
        teach.add((spell, npc, skill, cost))
    for m in SALE.finditer(text):
        npc, item, cost, stock = int(m.group(1)), int(m.group(2)), int(m.group(3)), m.group(4)
        sales.add((item, npc, cost, stock))
    for m in NPC.finditer(text):
        npcs[int(m.group(1))] = (m.group(2).replace('\\"', '"'), int(m.group(3)), float(m.group(4)) / 100, float(m.group(5)) / 100)

used = {n for _, n, _, _ in teach} | {n for _, n, _, _ in sales}


def write(name, header, rows):
    with open(HERE / name, "w", encoding="utf-8", newline="") as f:
        f.write(f"# Fuente: {SOURCE}. Generado por import_recipebook.py: no editar a mano.\n")
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(sorted(rows))


write("recipebook_trainers.csv", ["spell", "npc", "skill", "cost"], teach)
write("recipebook_vendors.csv", ["item", "npc", "cost", "stock"], sales)
write("recipebook_npcs.csv", ["npc", "name", "map", "x", "y"],
      [(n, *npcs[n]) for n in used if n in npcs])
print(f"instructores: {len(teach)} enseñanzas · vendedores: {len(sales)} ventas · PNJ con sitio: {sum(1 for n in used if n in npcs)} de {len(used)}")

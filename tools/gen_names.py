"""Genera Data/Names_esES.lua: nombres en español de las recetas y objetos del addon.

Lee tools/wago/SpellName_forever_esES.csv e ItemSparse_forever_esES.csv (ver
fetch_names_es.py) y guarda solo los que cambian respecto al inglés. El addon los
usa cuando su idioma es español y el cliente está en otro idioma (y al revés usa
los ingleses de ES.Data.ItemNames y el nombre de cada receta).
Uso: python gen_names.py
"""
import csv
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ADDON = HERE.parent
WAGO = HERE / "wago"
PROFS = ["Leatherworking", "Enchanting", "Tailoring", "Blacksmithing", "Alchemy", "Engineering", "Cooking", "FirstAid"]


def read(name):
    path = WAGO / name
    if not path.exists():
        return {}
    with open(path, encoding="utf-8") as f:
        return {int(r["ID"]): r["Name"] for r in csv.DictReader(f)}


def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    spells_es, items_es = read("SpellName_forever_esES.csv"), read("ItemSparse_forever_esES.csv")
    spells, items = {}, {}
    for prof in PROFS:
        text = (ADDON / "Data" / f"{prof}.lua").read_text(encoding="utf-8")
        for sid, name in re.findall(r'^\s*\[(\d+)\] = \{ name = "((?:[^"\\]|\\.)*)"', text, re.M):
            es = spells_es.get(int(sid))
            if es and es != name:
                spells[int(sid)] = es
        used = {int(x) for x in re.findall(r"\{ (\d+), [\d.]+ \}", text)}  # materiales y lo fabricado
        used |= {int(x) for x in re.findall(r"scroll = (\d+)", text)}
        used |= {int(x) for x in re.findall(r"ES\.Data\.ItemNames\[(\d+)\]", text)}
        en = dict((int(i), n) for i, n in re.findall(r'ES\.Data\.ItemNames\[(\d+)\] = "((?:[^"\\]|\\.)*)"', text))
        for iid in used:
            es = items_es.get(iid)
            if es and es != en.get(iid):
                items[iid] = es
    out = ["-- Generado por tools/gen_names.py (cliente de Forever en esES, wago.tools). No editar a mano.",
           "local _, ES = ...", "ES.Data = ES.Data or {}", "",
           "-- Nombres en español (solo los que cambian respecto al inglés)",
           "ES.Data.NamesES = { spells = {}, items = {} }", "local S, I = ES.Data.NamesES.spells, ES.Data.NamesES.items"]
    out += [f"S[{k}] = {lua_str(v)}" for k, v in sorted(spells.items())]
    out += [f"I[{k}] = {lua_str(v)}" for k, v in sorted(items.items())]
    out.append("")
    dest = ADDON / "Data" / "Names_esES.lua"
    dest.write_text("\n".join(out), encoding="utf-8")
    print(f"{dest}: {len(spells)} recetas y {len(items)} objetos en español, {dest.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()

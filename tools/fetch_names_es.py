"""Nombres en español de recetas y objetos (cliente de WoW Forever en esES).

Descarga SpellName e ItemSparse de wago.tools con locale=esES y los recorta a las
recetas y objetos que usa el addon -> tools/wago/SpellName_forever_esES.csv e
ItemSparse_forever_esES.csv (ID, nombre). Luego gen_names.py genera Data/Names_esES.lua.
Uso: python fetch_names_es.py   (solo hace falta al cambiar de versión del cliente)
"""
import csv
import io
import sys
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
WAGO = HERE / "wago"
BUILD = "1.60.1.70862"


def download(table):
    url = f"https://wago.tools/db2/{table}/csv?build={BUILD}&locale=esES"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    return urllib.request.urlopen(req, timeout=120).read().decode("utf-8")


def ids(name, col):
    with open(WAGO / name, encoding="utf-8") as f:
        return {r[col] for r in csv.DictReader(f)}


def main():
    spells = ids("SpellName_forever.csv", "ID")
    items = ids("ItemSparse_forever.csv", "ID")
    for table, keep, name_col, out in (("SpellName", spells, "Name_lang", "SpellName_forever_esES.csv"),
                                       ("ItemSparse", items, "Display_lang", "ItemSparse_forever_esES.csv")):
        rows = [r for r in csv.DictReader(io.StringIO(download(table))) if r["ID"] in keep]
        with open(WAGO / out, "w", encoding="utf-8", newline="") as f:
            w = csv.writer(f)
            w.writerow(["ID", "Name"])
            for r in rows:
                w.writerow([r["ID"], r[name_col]])
        print(out, len(rows), "filas")


if __name__ == "__main__":
    sys.exit(main())

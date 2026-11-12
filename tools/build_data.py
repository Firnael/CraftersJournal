"""Regenera todos los datos de Crafter's Journal y pasa las pruebas, en un solo comando.

Fuentes (ninguna es otro addon de profesiones):
  - wago.tools: tablas del cliente de WoW Forever (tools/wago, recortadas por filter_wago.py)
  - CMaNGOS classic-db: instructores de Classic (tools/cmangos, extraído por extract_cmangos.py)
  - QuestieDB (addon de datos): vendedores, misiones, botín y posiciones de PNJ

Pasos:
  1. (opcional) filter_wago.py: recorta las tablas completas de wago.tools a lo que usa el addon
  2. (opcional) extract_cmangos.py: instructores desde el volcado de CMaNGOS
  3. gen_profession.py para las 8 profesiones (Data/<Profesion>.lua)
  4. gen_sources.py: vendedores, misiones, botín y PNJ desde QuestieDB (Data/Sources.lua)
     gen_names.py: nombres en español de recetas y objetos (Data/Names_esES.lua; descarga con fetch_names_es.py)
  5. pruebas: test_ui.py, iterate.py y pilot_cooking.py (buscan FAIL / errores)

Uso:
  python build_data.py                              # pasos 3-5
  python build_data.py --wago <carpeta>             # también el paso 1 (CSV completos de wago.tools)
  python build_data.py --cmangos <ClassicDB.sql.gz> # también el paso 2
  python build_data.py --no-tests                   # solo datos

Las pruebas necesitan lupa (Lua 5.1); si no está instalada, indica su carpeta con
la variable de entorno ESLUA.
"""
import argparse
import os
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROFS = ["Leatherworking", "Enchanting", "Tailoring", "Blacksmithing", "Alchemy", "Engineering", "Cooking", "FirstAid"]
TESTS = ["test_ui.py", "iterate.py", "pilot_cooking.py"]


def run(args, check_output=False):
    env = dict(os.environ, PYTHONIOENCODING="utf-8")
    print(">", " ".join(str(a) for a in args), flush=True)
    res = subprocess.run([sys.executable, *map(str, args)], cwd=HERE, env=env,
                         capture_output=check_output, text=True, encoding="utf-8")
    if res.returncode != 0:
        if check_output:
            print(res.stdout[-3000:], res.stderr[-3000:])
        sys.exit(f"Falló: {args[0]} (código {res.returncode})")
    return res.stdout if check_output else ""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--wago", help="carpeta con los CSV completos de wago.tools (ItemSparse.csv, SpellReagents.csv...)")
    ap.add_argument("--cmangos", help="volcado de CMaNGOS classic-db (Full_DB/ClassicDB_*.sql.gz)")
    ap.add_argument("--no-tests", action="store_true")
    a = ap.parse_args()

    if a.wago:
        run([HERE / "filter_wago.py", a.wago, HERE / "wago"])
    if a.cmangos:
        run([HERE / "extract_cmangos.py", a.cmangos])
    for p in PROFS:
        run([HERE / "gen_profession.py", p])
    run([HERE / "gen_sources.py"])
    run([HERE / "gen_names.py"])

    if a.no_tests:
        return
    failed = []
    for t in TESTS:
        out = run([HERE / t], check_output=True)
        bad = [l for l in out.splitlines()
               if l.startswith("FAIL") or l.startswith("[FAIL]") or l.lstrip().startswith("BUG:") or "Traceback" in l]
        print(f"  {t}: {'OK' if not bad else str(len(bad)) + ' fallos'}")
        for l in bad:
            print("    " + l)
        failed += bad
    if failed:
        sys.exit(f"{len(failed)} pruebas fallaron")
    print("Todo regenerado y las pruebas pasan.")


if __name__ == "__main__":
    main()

"""Genera Data/Sources.lua para Crafter's Journal desde QuestieDB (Forever).

De dónde sale cada receta de pergamino (vendedores y misiones), quién vende los
materiales de vendedor y los libros de rango, y dónde está cada PNJ (vendedores,
quien da las misiones e instructores). Así el addon no necesita Questie para
"Conseguir receta" ni para marcar el camino.

QuestieDB guarda sus datos "baked" en su .toc (Base64 + CBOR; los IDs con zlib).
Uso:  python gen_sources.py
"""
import csv
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from questie import (ITEM, NPC, NPC_AUCTIONEER, NPC_INNKEEPER, QUEST, all_ids, at, field, ids,  # noqa: E402
                     load_store, row, seq, zone_tables)

HERE = Path(__file__).resolve().parent
ADDON = HERE.parent
PROFS = ["Leatherworking", "Enchanting", "Tailoring", "Blacksmithing", "Alchemy", "Engineering", "Cooking", "FirstAid"]
RANK_BOOKS = [16072, 16084]  # Expert Cookbook, Expert First Aid - Under Wraps

WORLD_DROP = 12  # más criaturas que esto: botín del mundo (solo se guarda cuántas)
ALLIANCE_RACES, HORDE_RACES = 77, 178
# Capitales por área: un PNJ amistoso con los dos bandos dentro de una solo atiende a ese bando
CAPITALS = {1519: "A", 1537: "A", 1657: "A", 1637: "H", 1497: "H", 1638: "H"}


def main():
    print("Leyendo QuestieDB ...", file=sys.stderr)
    load_store()
    zt = zone_tables()
    area, area_o = zt.get("areaIdToUiMapId", {}), zt.get("areaIdToUiMapIdOverride", {})
    parent, parent_o = zt.get("subZoneToParentZone", {}), zt.get("subZoneToParentZoneOverride", {})

    def ui_map(a):
        m = area_o.get(a) or area.get(a)
        if not m:
            p = parent_o.get(a) or parent.get(a)
            m = p and (area_o.get(p) or area.get(p))
        return m or None

    # Objetos: pergaminos de nuestras recetas, libros de rango y materiales de vendedor
    scrolls, vendor_items, trainers = set(), set(), set()
    for prof in PROFS:
        text = (ADDON / "Data" / f"{prof}.lua").read_text(encoding="utf-8")
        scrolls.update(int(x) for x in re.findall(r"scroll = (\d+)", text))
        vendor_items.update(int(x) for x in re.findall(r"ES\.Data\.VendorPrices\[(\d+)\]", text))
        tm = re.search(r"trainers = \{(.*)\},", text)
        if tm:
            trainers.update(int(a) for a, _ in re.findall(r"\{ (\d+), (\d+) \}", tm.group(1)))
        # Otros PNJ a los que hay que ir (extraNPCs en los datos de la profesión)
        em = re.search(r"extraNPCs = \{([^}]*)\}", text)
        if em:
            trainers.update(int(a) for a in re.findall(r"\d+", em.group(1)))

    def levels(npc_id):
        """(mínimo, máximo) de nivel de una criatura, o None"""
        r = row("Npc", npc_id)
        lo, hi = r and field("Npc", npc_id, NPC["minLevel"], r), r and field("Npc", npc_id, NPC["maxLevel"], r)
        return (int(lo), int(hi or lo)) if isinstance(lo, (int, float)) and lo > 0 else None

    items, quests, npcs_needed = {}, {}, set(trainers)
    drops = {}  # pergamino -> (criaturas o None si es del mundo, cuántas criaturas, cuántos objetos, niveles)
    droppers = set()  # criaturas de las que se guarda el nivel
    for item_id in sorted(scrolls | vendor_items | set(RANK_BOOKS)):
        r = row("Item", item_id)
        if not r:
            continue
        vendors = ids(field("Item", item_id, ITEM["vendors"], r))
        qs = ids(field("Item", item_id, ITEM["questRewards"], r)) if item_id not in vendor_items else []
        if item_id in scrolls:
            mobs = ids(field("Item", item_id, ITEM["npcDrops"], r))
            objs = ids(field("Item", item_id, ITEM["objectDrops"], r))
            if mobs or objs:
                listed = mobs if len(mobs) <= WORLD_DROP else None
                # Botín del mundo: de qué nivel a qué nivel son las criaturas que lo sueltan
                lv = [l for l in (levels(m) for m in mobs) if l] if not listed else []
                span = (min(l[0] for l in lv), max(l[1] for l in lv)) if lv else None
                drops[item_id] = (listed, len(mobs), len(objs), span)
                npcs_needed.update(listed or [])
                droppers.update(listed or [])
        if vendors or qs or item_id in drops:
            items[item_id] = (vendors, qs)
            npcs_needed.update(vendors)
        for q in qs:
            if q in quests:
                continue
            qr = row("Quest", q)
            if not qr:
                continue
            races = field("Quest", q, QUEST["requiredRaces"], qr) or 0
            a, h = (races & ALLIANCE_RACES) != 0, (races & HORDE_RACES) != 0
            starters = ids(at(field("Quest", q, QUEST["startedBy"], qr), 1))
            quests[q] = (field("Quest", q, QUEST["name"], qr), "" if a == h else ("A" if a else "H"),
                         field("Quest", q, QUEST["requiredLevel"], qr) or 0, starters)
            npcs_needed.update(starters)

    # Vendedores de pergaminos de Forever (tools/forever/recipebook_*.csv, ver
    # import_recipebook.py): se suman a los de QuestieDB, solo los que tienen sitio en el
    # mapa. Un pergamino que en Forever no vende nadie (patrones de Spitfire, Ironvine...:
    # no existen en Forever) se queda sin vendedor
    book_npcs, book_vendors = {}, {}
    if (HERE / "forever" / "recipebook_vendors.csv").exists():
        with open(HERE / "forever" / "recipebook_npcs.csv", encoding="utf-8") as f:
            for r in csv.DictReader(l for l in f if not l.startswith("#")):
                book_npcs[int(r["npc"])] = (r["name"], int(r["map"]), float(r["x"]), float(r["y"]))
        with open(HERE / "forever" / "recipebook_vendors.csv", encoding="utf-8") as f:
            for r in csv.DictReader(l for l in f if not l.startswith("#")):
                if int(r["npc"]) in book_npcs:
                    book_vendors.setdefault(int(r["item"]), set()).add(int(r["npc"]))
        for item_id in scrolls:
            book = book_vendors.get(item_id)
            vendors, qs = items.get(item_id, ([], []))
            if book:
                vendors = sorted(set(vendors) | book)
                npcs_needed.update(book)
            elif vendors:
                vendors = []
            if vendors or qs or item_id in drops:
                items[item_id] = (vendors, qs)
            elif item_id in items:
                del items[item_id]
        # (y los instructores que solo conoce el libro: la ruta lleva a ellos, ver tr)
        with open(HERE / "forever" / "recipebook_trainers.csv", encoding="utf-8") as f:
            npcs_needed.update(int(r["npc"]) for r in csv.DictReader(l for l in f if not l.startswith("#"))
                               if int(r["npc"]) in book_npcs)

    # Subastadores (para "poner en la AH" desde la vista Profit) y posaderos: hay
    # uno en cada pueblo y, como cualquier vendedor, compran lo que fabricas
    auctioneers, innkeepers = [], []
    for npc_id in all_ids("Npc"):
        r = row("Npc", npc_id)
        flags = r and field("Npc", npc_id, NPC["npcFlags"], r)
        if not isinstance(flags, int):
            continue
        name = field("Npc", npc_id, NPC["name"], r) or ""
        if flags & NPC_AUCTIONEER and name.startswith("Auctioneer"):  # no los intendentes con la marca puesta
            auctioneers.append(npc_id)
        elif flags & NPC_INNKEEPER:
            innkeepers.append(npc_id)
    sell_vendors = set(innkeepers)
    for item_id in vendor_items:  # quien vende hilo, sal... también compra
        if item_id in items:
            sell_vendors.update(items[item_id][0])
    npcs_needed.update(auctioneers)
    npcs_needed.update(sell_vendors)

    npcs = {}
    for npc_id in sorted(npcs_needed):
        r = row("Npc", npc_id)
        name = r and field("Npc", npc_id, NPC["name"], r)
        if not name:
            continue
        spawns = field("Npc", npc_id, NPC["spawns"], r) or {}
        home = field("Npc", npc_id, NPC["zoneID"], r)
        spawns = {int(k): seq(v) for k, v in (spawns.items() if isinstance(spawns, dict) else enumerate(seq(spawns), 1))}
        zone = home if home in spawns else (min(spawns) if spawns else None)
        spots = [(float(seq(p)[0]), float(seq(p)[1])) for p in spawns.get(zone, [])
                 if len(seq(p)) >= 2 and 0 <= float(seq(p)[0]) <= 100 and 0 <= float(seq(p)[1]) <= 100]
        side = {"A": "A", "H": "H", "AH": ""}.get(field("Npc", npc_id, NPC["friendlyToFaction"], r), "X")
        if side == "" and zone is not None:
            side = CAPITALS.get(zone) or CAPITALS.get(parent_o.get(zone) or parent.get(zone)) or ""
        entry = [name, side]
        if spots and zone is not None and ui_map(zone):
            cx, cy = sum(s[0] for s in spots) / len(spots), sum(s[1] for s in spots) / len(spots)
            x, y = min(spots, key=lambda s: (s[0] - cx) ** 2 + (s[1] - cy) ** 2)
            entry += [ui_map(zone), round(x / 100, 4), round(y / 100, 4)]
        elif zone is not None:
            entry += [0, 0, 0, zone]  # mazmorra: sin mapa, solo la zona (para el nombre)
        npcs[npc_id] = entry

    # PNJ nuevos de Forever que QuestieDB aún no ha situado (sin posición): la sacada
    # de guías y bases de datos, con su fuente, en tools/forever/npc_locations.csv
    fixed = 0
    with open(HERE / "forever" / "npc_locations.csv", encoding="utf-8") as f:
        for loc in csv.DictReader(f):
            npc_id = int(loc["npc"])
            if npc_id in npcs and len(npcs[npc_id]) <= 2:
                npcs[npc_id] = [npcs[npc_id][0], loc["side"], int(loc["map"]),
                                round(float(loc["x"]) / 100, 4), round(float(loc["y"]) / 100, 4)]
                fixed += 1
    # PNJ de Forever que QuestieDB no tiene o no sitúa: los del libro (sin bando: los
    # dos; el libro no lo dice)
    for npc_id in sorted(npcs_needed):
        if npc_id in book_npcs and (npc_id not in npcs or len(npcs[npc_id]) <= 2):
            name, m, x, y = book_npcs[npc_id]
            side = npcs[npc_id][1] if npc_id in npcs else ""
            npcs[npc_id] = [npcs[npc_id][0] if npc_id in npcs else name, side, m, round(x, 4), round(y, 4)]
            fixed += 1

    def lua_str(s):
        return '"' + str(s).replace("\\", "\\\\").replace('"', '\\"') + '"'

    def lua_ids(lst):
        return "{ " + ", ".join(map(str, lst)) + " }"

    out = [
        "-- Generado por tools/gen_sources.py desde QuestieDB (Forever). No editar a mano.",
        "local _, ES = ...",
        "ES.Data = ES.Data or {}",
        "",
        "-- [objeto] = { v = { vendedores }, q = { misiones que lo dan },",
        f"--   d = {{ criaturas que lo sueltan }} (hasta {WORLD_DROP}), w = nº de criaturas si es botín del mundo",
        "--   (wl = { nivel mínimo, máximo } de esas criaturas),",
        "--   o = nº de objetos (cofres...) que lo contienen }",
        "-- (pergaminos de receta, libros de rango y materiales que se compran al vendedor)",
        "ES.Data.ItemSources = {",
    ]
    for item_id, (vendors, qs) in sorted(items.items()):
        parts = []
        if vendors:
            parts.append("v = " + lua_ids(vendors))
        if qs:
            parts.append("q = " + lua_ids(qs))
        if item_id in drops:
            listed, n_mobs, n_objs, span = drops[item_id]
            if listed:
                parts.append("d = " + lua_ids(listed))
            elif n_mobs:
                parts.append(f"w = {n_mobs}")
                if span:
                    parts.append("wl = { %d, %d }" % span)
            if n_objs:
                parts.append(f"o = {n_objs}")
        out.append(f"  [{item_id}] = {{ {', '.join(parts)} }},")
    out += ["}", "", "-- [misión] = { nombre, bando (\"A\", \"H\" o \"\" los dos), nivel mínimo, { quien la da } }", "ES.Data.Quests = {"]
    for q, (name, side, level, starters) in sorted(quests.items()):
        out.append(f"  [{q}] = {{ {lua_str(name)}, \"{side}\", {level}, {lua_ids(starters)} }},")
    out += ["}", "",
            "-- [PNJ] = { nombre, bando (\"A\", \"H\", \"\" los dos, \"X\" ninguno), mapa, x, y } (x, y de 0 a 1;",
            "-- en una mazmorra: mapa 0 y la zona como 6.º campo)", "ES.Data.NPCs = {"]
    for npc_id, e in sorted(npcs.items()):
        rest = "" if len(e) == 2 else ", " + ", ".join(str(v) for v in e[2:])
        out.append(f"  [{npc_id}] = {{ {lua_str(e[0])}, \"{e[1]}\"{rest} }},")
    out += ["}", "", "-- [criatura que suelta un pergamino] = { nivel mínimo, nivel máximo }", "ES.Data.NPCLevels = {"]
    for npc_id in sorted(droppers):
        lv = levels(npc_id)
        if lv and npc_id in npcs:
            out.append("  [%d] = { %d, %d }," % (npc_id, lv[0], lv[1]))
    out += ["}", "",
            "-- Subastadores, y PNJ que compran lo que fabricas (posaderos y vendedores de materiales):",
            "-- el clic de la vista Profit marca el más cercano",
            "ES.Data.Auctioneers = " + lua_ids(sorted(n for n in auctioneers if n in npcs)),
            "ES.Data.SellVendors = " + lua_ids(sorted(n for n in sell_vendors if n in npcs)), ""]
    dest = ADDON / "Data" / "Sources.lua"
    dest.write_text("\n".join(out), encoding="utf-8")
    print(f"{dest}: {len(items)} objetos con fuente, {len(quests)} misiones, {len(npcs)} PNJ "
          f"({sum(1 for e in npcs.values() if len(e) > 2)} con posición, {fixed} de npc_locations.csv), {len(auctioneers)} subastadores, "
          f"{len(sell_vendors)} que compran, {dest.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()

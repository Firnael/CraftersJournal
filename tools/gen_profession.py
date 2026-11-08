"""Genera Data/<Profesion>.lua para Crafter's Journal desde sus fuentes originales:

  tools/wago/     tablas del cliente de WoW Forever (wago.tools, ver filter_wago.py):
                  recetas, umbrales, nombres, materiales, lo que fabrican, pergaminos,
                  herramientas, precios de vendedor y tipo de cada objeto
  tools/cmangos/  instructores de Classic (CMaNGOS classic-db, ver extract_cmangos.py):
                  precio y nivel de cada receta en el instructor, rangos e instructores
  QuestieDB       qué objetos vende algún PNJ (para saber qué materiales son de vendedor)

Uso:  python gen_profession.py [Leatherworking]
"""
import csv
import re
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
ADDON = HERE.parent
WAGO = HERE / "wago"
CMANGOS = HERE / "cmangos" / "trainer_spells.csv"

sys.path.insert(0, str(HERE))
import questie  # noqa: E402

SKILL_LINES = {"Leatherworking": 165, "Enchanting": 333, "Tailoring": 197, "Blacksmithing": 164, "Alchemy": 171,
               "Engineering": 202, "Cooking": 185, "FirstAid": 129}

# Rangos que no da el instructor en las secundarias (CMaNGOS solo trae hasta
# Oficial): Experto = libro del vendedor (1 oro), Artesano = misión (gratis)
EXTRA_RANKS = {
    185: [(225, 10000, 125, 35), (300, 0, 225, 35)],  # Expert Cookbook; misión de Artesano
    129: [(225, 10000, 125, 35), (300, 0, 225, 35)],  # Expert First Aid - Under Wraps; misión "Triage"
}
RANK_CAP = {1: 75, 2: 150, 3: 225, 4: 300}  # paso de rango -> tope de habilidad

# Materiales de vendedor que QuestieDB no conoce (Mote of Magic es nuevo de Forever)
EXTRA_VENDOR = {247786, 6217, 5956, 6219}  # + Copper Rod, Blacksmith Hammer, Arclight Spanner

# Conversión de esencias de encantamiento (clic derecho): 3 menores <-> 1 mayor
ESSENCES = [(10938, 10939), (10998, 11082), (11134, 11135), (11174, 11175), (16202, 16203)]

# Herramientas (categoría de tótem -> objeto) y su familia. Dentro de una
# familia uno superior sirve para lo inferior (bastones rúnicos de Encantamiento).
TOOL_ITEMS = {373: 6218, 374: 6339, 375: 11130, 376: 11145, 377: 16207,
              162: 5956,   # Blacksmith Hammer (Herrería)
              12: 9149,    # Philosopher's Stone (transmutaciones de Alquimia)
              14: 6219,    # Arclight Spanner (Ingeniería)
              15: 10498}   # Gyromatic Micro-Adjustor (Ingeniería, se fabrica)
TOOL_FAMILY = {373: "rod", 374: "rod", 375: "rod", 376: "rod", 377: "rod", 162: "hammer", 12: "stone",
               14: "spanner", 15: "adjustor"}

# Materiales que se recolectan: (clase, subclase) de objeto -> profesión de recolección
# Bienes comerciales (7): 6 cuero -> Desuello (393), 7 metal y piedra -> Minería (186), 9 hierba -> Herboristería (182)
GATHER_SUBCLASS = {(7, 6): 393, (7, 7): 186, (7, 9): 182}
# Excepciones a la regla por tipo de objeto:
#  - cueros que se desuellan aunque alguna receta también los fabrique (Light Leather
#    sale también de Ruined Leather Scraps)
#  - Deeprock Salt: el juego la clasifica como "cuero", pero sale minando
ALSO_GATHERED = {2318: 393, 2319: 393, 4234: 393, 4304: 393, 8170: 393, 8150: 186}

ALL_PROFS = list(SKILL_LINES)

# Instructores (QuestieDB). En Forever cada rango tiene sus instructores, y su
# subtítulo dice el rango SIGUIENTE al que enseña (comprobado con las guías de
# Mobalytics: 61 de 61): "Journeyman Tailor" enseña Aprendiz, "Expert" Oficial,
# "Artisan" Experto (Georgio Bolero) y "Master" Artesano. Los nuevos de Forever con
# subtítulo genérico ("Tailor", "Tailoring Trainer") enseñan Aprendiz y Oficial
# (los de la isla Zephras); las excepciones documentadas, en tools/forever/trainer_overrides.csv.
TRAINER_NOUN = {"Alchemy": "Alchemist", "Blacksmithing": "Blacksmith", "Enchanting": "Enchanter",
                "Engineering": "Engineer", "Leatherworking": "Leatherworker", "Tailoring": "Tailor"}
TRAINER_SECONDARY = {"Cooking": {"Cooking Trainer", "Cook", "Superior Cook"},
                     "FirstAid": {"First Aid Trainer", "Physician"}}
PREFIX_RANK = {"Journeyman": 75, "Expert": 150, "Artisan": 225, "Master": 300}
RANK_BIT = {75: 1, 150: 2, 225: 4, 300: 8}
NPC_FLAG_TRAINER = 16
FOREVER_NPC_IDS = 200000  # los PNJ nuevos de Forever tienen ID altos (p. ej. 251991)
OVERRIDES = HERE / "forever" / "trainer_overrides.csv"
FOREVER_FEES = HERE / "forever" / "trainer_fees.csv"
FOREVER_SELL = HERE / "forever" / "sell_prices.csv"
# Recetas que se compran con Merchant's Favor (tools/forever/fetch_merchants_favor.py)
MERCHANTS_FAVOR = HERE / "forever" / "merchants_favor.csv"


def favor_key(name):
    """Nombre para cruzar con merchants_favor.csv: en minúsculas y sin la "s" final de
    "Shoulders" (el cliente definitivo renombró "Mender's Mail Shoulder" a "...Shoulders")."""
    return re.sub(r"shoulders$", "shoulder", (name or "").lower())


def merchants_favor(prof):
    """{ favor_key(receta): (coste, reputación) } de una profesión."""
    if not MERCHANTS_FAVOR.exists():
        return {}
    with open(MERCHANTS_FAVOR, encoding="utf-8") as f:
        rows = csv.DictReader(line for line in f if not line.startswith("#"))
        return {favor_key(r["recipe"]): (int(r["favor"]), int(r["rep"])) for r in rows if r["profession"] == prof}


def quest_trainers():
    """{profesión: {npc: máscara de rangos (1 aprendiz, 2 oficial, 4 experto, 8 artesano)}}"""
    import re
    questie.load_store()
    out = {p: {} for p in SKILL_LINES}
    for key in questie.store:
        m = re.match(r"X-Npc-(\d+)-S$", key)
        if not m:
            continue
        nid = int(m.group(1))
        r = questie.row("Npc", nid)
        sub = questie.field("Npc", nid, 14, r)
        flags = questie.field("Npc", nid, 15, r) or 0
        if not isinstance(sub, str) or not (int(flags) & NPC_FLAG_TRAINER):
            continue
        for prof, noun in TRAINER_NOUN.items():
            pm = re.match(rf"^(?:(Journeyman|Expert|Artisan|Master) )?{noun}(?: Trainer)?$", sub)
            generic = sub == f"{prof} Trainer"
            prefix = pm and pm.group(1)
            if prefix:
                out[prof][nid] = RANK_BIT[PREFIX_RANK[prefix]]
            elif (pm or generic) and nid >= FOREVER_NPC_IDS:
                # Subtítulo genérico: solo los nuevos de Forever (isla Zephras): aprendiz y oficial.
                # Los genéricos de Classic no se sabe qué enseñan: fuera (si alguno sí, a overrides)
                out[prof][nid] = RANK_BIT[75] | RANK_BIT[150]
        for prof, subs in TRAINER_SECONDARY.items():
            if sub in subs:
                out[prof][nid] = RANK_BIT[75] | RANK_BIT[150]
    with open(OVERRIDES, encoding="utf-8") as f:
        for row in csv.DictReader(f):
            mask = 0
            for rank in row["ranks"].split("|"):
                mask |= RANK_BIT[int(rank)]
            out[row["profession"]][int(row["npc"])] = mask
    return out


def rows(name):
    with open(WAGO / f"{name}.csv", encoding="utf-8") as f:
        yield from csv.DictReader(f)


def load_common():
    """Lo que no depende de la profesión (se usa para todas)."""
    sla = {}
    for r in rows("SkillLineAbility_forever"):
        line = int(r["SkillLine"])
        if line in SKILL_LINES.values():
            sla.setdefault(line, {})[int(r["Spell"])] = r
    era = defaultdict(dict)
    for r in rows("SkillLineAbility_era"):
        era[int(r["SkillLine"])][int(r["Spell"])] = int(r["TrivialSkillLineRankLow"])
    names = {int(r["ID"]): r["Name_lang"] for r in rows("SpellName_forever")}

    reagents = {}
    for r in rows("SpellReagents_forever"):
        lst = [(int(r[f"Reagent_{k}"]), int(r[f"ReagentCount_{k}"])) for k in range(8)
               if int(r[f"Reagent_{k}"] or 0) and int(r[f"ReagentCount_{k}"] or 0)]
        reagents[int(r["SpellID"])] = lst
    creates = {}
    for r in rows("SpellEffect_forever"):
        if r["Effect"] == "24" and r["EffectItemType"] not in ("", "0"):
            qty = float(r["EffectBasePointsF"] or 1)
            creates[int(r["SpellID"])] = (int(r["EffectItemType"]), qty if qty > 0 else 1.0)

    item_info, item_rep, item_skill, item_quality, item_bop = {}, {}, {}, {}, set()
    for r in rows("ItemSparse_forever"):
        iid = int(r["ID"])
        # Calidad: 0 pobre, 1 común, 2 poco común, 3 raro, 4 épico
        item_quality[iid] = int(r.get("OverallQualityID") or 1)
        # Ligado al recogerlo (Bonding 1): lo fabricado no se puede vender en la AH
        if r.get("Bonding") == "1":
            item_bop.add(iid)
        stack = max(1, int(r["VendorStackCount"] or 1))
        item_info[iid] = (r["Display_lang"], int(r["BuyPrice"] or 0) / stack, int(r["SellPrice"] or 0))
        # Reputación para usar el objeto (pergaminos): facción y nivel (4 neutral ... 8 exaltado)
        if r.get("MinFactionID", "0") not in ("", "0"):
            item_rep[iid] = (int(r["MinFactionID"]), int(r["MinReputation"] or 0))
        if r.get("RequiredSkillRank", "0") not in ("", "0"):
            item_skill[iid] = int(r["RequiredSkillRank"])
    item_class = {int(r["ID"]): (int(r["ClassID"]), int(r["SubclassID"])) for r in rows("Item_forever")}

    # Pergamino de cada receta. Si hay varios (Forever reeditó algunos con ID nuevo,
    # a veces copias sin requisitos), el que pide nivel de profesión; luego el más reciente
    scrolls = {}
    for r in rows("RecipeScrolls_forever"):
        spell, item = int(r["Spell"]), int(r["ItemID"])
        best = scrolls.get(spell)
        if best is None or (item in item_skill, item) > (best in item_skill, best):
            scrolls[spell] = item

    tools, tool_masks = {}, {}
    for r in rows("SpellTotems_forever"):
        cat = int(r["RequiredTotemCategoryID_0"] or 0)
        if cat in TOOL_ITEMS:
            tools[int(r["SpellID"])] = cat
    for r in rows("TotemCategory_forever"):
        if int(r["ID"]) in TOOL_ITEMS:
            tool_masks[int(r["ID"])] = int(r["TotemCategoryMask"])

    # Instructores (CMaNGOS): por receta, el más barato; por línea, los rangos y quién enseña qué
    fees, ranks, trainers = {}, defaultdict(dict), defaultdict(dict)
    with open(CMANGOS, encoding="utf-8") as f:
        for r in csv.DictReader(f):
            npc, spell, cost, line = int(r["npc"]), int(r["spell"]), int(r["cost"]), int(r["skill"])
            req, level = int(r["reqskill"]), int(r["reqlevel"])
            if r["rank_step"]:
                step = int(r["rank_step"])
                cap = RANK_CAP[step]
                if step > 1 and (cap not in ranks[line] or cost < ranks[line][cap][1]):
                    ranks[line][cap] = (cap, cost, req, level)
                trainers[line][npc] = max(trainers[line].get(npc, 0), cap)
            else:
                if spell not in fees or cost < fees[spell][0]:
                    fees[spell] = (cost, req, False)
    # Precios y niveles de Forever vistos en el juego o en guías, con su fuente en el
    # CSV (recetas nuevas o que Forever cobra distinto): mandan sobre CMaNGOS, y su
    # nivel ya es el de Forever (True: sin desplazar, ver forever_train)
    with open(FOREVER_FEES, encoding="utf-8") as f:
        for r in csv.DictReader(f):
            fees[int(r["spell"])] = (int(r["cost"]), int(r["reqskill"]), True)
    return dict(sla=sla, era=era, names=names, reagents=reagents, creates=creates, scrolls=scrolls,
                item_info=item_info, item_rep=item_rep, item_skill=item_skill, item_class=item_class,
                item_quality=item_quality, item_bop=item_bop,
                tools=tools, tool_masks=tool_masks, fees=fees, ranks=ranks, trainers=trainers)


ALLIANCE_RACES = 1 | 4 | 8 | 64     # humano, enano, elfo de la noche, gnomo
HORDE_RACES = 2 | 16 | 32 | 128     # orco, no-muerto, tauren, trol


def faction_of(r):
    """Bando de una receta según las razas que pueden aprenderla (SkillLineAbility):
    "Alliance", "Horde" o None si es de los dos (máscara 0 = todas)."""
    mask = (int(r.get("RaceMasks_0") or 0) & 0xFFFFFFFF) | ((int(r.get("RaceMasks_1") or 0) & 0xFFFFFFFF) << 32)
    if mask == 0:
        return None
    ally, horde = mask & ALLIANCE_RACES, mask & HORDE_RACES
    if ally and not horde:
        return "Alliance"
    if horde and not ally:
        return "Horde"
    return None


VENDOR_MIN = 10        # vendedores en QuestieDB para tratarlo como de venta ilimitada
VENDOR_MIN_DRINK = 3   # bebidas y comida (clase 0, subclase 5): bastan menos (cerveceros, posaderos)


def sold_by_vendor(item_id):
    """¿Algún PNJ vende este objeto? (QuestieDB)"""
    questie.load_store()
    r = questie.row("Item", item_id)
    return bool(r and questie.ids(questie.field("Item", item_id, questie.ITEM["vendors"], r)))


def questie_sourced(scrolls):
    """Pergaminos con alguna fuente conocida en QuestieDB (vendedor, misión, botín u objeto)."""
    questie.load_store()
    out = set()
    for item_id in set(scrolls.values()):
        r = questie.row("Item", item_id)
        if r and any(questie.ids(questie.field("Item", item_id, questie.ITEM[k], r))
                     for k in ("vendors", "questRewards", "npcDrops", "objectDrops")):
            out.add(item_id)
    return out


def vendor_items(candidates, item_class):
    """Objetos que se compran sin límite a un vendedor. QuestieDB no distingue los
    vendedores de existencias limitadas (el herbolario que vende 1-2 Silverleaf de
    vez en cuando), pero esos tienen pocos vendedores; lo de venta ilimitada (hilos,
    tintes, viales...) lo tienen decenas."""
    questie.load_store()
    out = set()
    for iid in candidates:
        r = questie.row("Item", iid)
        n = len(questie.ids(questie.field("Item", iid, questie.ITEM["vendors"], r))) if r else 0
        if n >= VENDOR_MIN or (n >= VENDOR_MIN_DRINK and item_class.get(iid) == (0, 5)):
            out.add(iid)
    return out


def main():
    prof = sys.argv[1] if len(sys.argv) > 1 else "Leatherworking"
    skill_line = SKILL_LINES[prof]
    c = load_common()
    sla = c["sla"][skill_line]

    # Recetas: las de la profesión con materiales que dan puntos (amarilla < gris).
    # Umbrales del cliente: naranja = nivel para aprenderla, amarilla, gris; verde a mitad.
    # Fuera las que piden un material que no existe en el cliente de Forever (restos
    # de Season of Discovery: Flask of Madness, Obsidian Reaver...): no se pueden hacer.
    # El resultado no se comprueba: a ItemSparse de wago le faltan muchos objetos que sí
    # existen (Rune Edge, Demon Forged Breastplate: los manda el servidor)
    recipes, thresholds, impossible = {}, {}, []
    for spell, r in sla.items():
        orange, yellow, grey = int(r["MinSkillLineRank"]), int(r["TrivialSkillLineRankLow"]), int(r["TrivialSkillLineRankHigh"])
        if any(i not in c["item_info"] for i, _ in c["reagents"].get(spell, [])):
            impossible.append(spell)
            continue
        if spell in c["reagents"] and c["reagents"][spell] and yellow < grey:
            recipes[spell] = (c["reagents"][spell], c["creates"].get(spell))
            thresholds[spell] = (orange, yellow, (yellow + grey) // 2, grey)

    # Recetas repetidas (mismo nombre): copias de Season of Discovery o reediciones con
    # otro número. Se queda la que tiene más datos: instructor > pergamino con fuente
    # conocida o de Merchant's Favor > pergamino sin fuente > nada; a igualdad, la que
    # no es de los rangos de SoD y luego la de número más bajo (la de Classic).
    # No son repetidas las de bandos distintos ni una que fabrica algo con otra que no.
    favor_names = merchants_favor(prof)
    sourced = questie_sourced(c["scrolls"])

    def score(s):
        sc = c["scrolls"].get(s)
        if s in c["fees"]:
            data = 3
        elif sc and (sc in sourced or favor_key(c["names"].get(s)) in favor_names):
            data = 2
        elif sc:
            data = 1
        else:
            data = 0
        sod = 400000 <= s < 1240000
        return (data, not sod, -s)

    by_name = defaultdict(list)
    for s in recipes:
        by_name[c["names"].get(s, str(s))].append(s)
    dropped_dups = []
    for name, group in by_name.items():
        if len(group) < 2:
            continue
        kinds = {(faction_of(sla[s]), recipes[s][1] is not None) for s in group}
        if len(kinds) > 1:
            continue
        keep = max(group, key=score)
        for s in group:
            if s != keep:
                del recipes[s]
                dropped_dups.append(f"{name} ({s}, se queda {keep})")

    # WoW Forever bajó los umbrales de muchas recetas respecto a Classic (p. ej.
    # Turtle Scale Breastplate: amarilla 230 -> 205), pero el nivel que pide el
    # instructor viene de CMaNGOS (Classic). Desplazamos ese nivel lo mismo que
    # se desplazó la amarilla de cada receta.
    era_y = c["era"].get(skill_line, {})
    shift = {s: era_y[s] - int(r["TrivialSkillLineRankLow"]) for s, r in sla.items()
             if s in era_y and era_y[s] > int(r["TrivialSkillLineRankLow"])}

    ranks = [v for _, v in sorted(c["ranks"][skill_line].items())]
    ranks += [r for r in EXTRA_RANKS.get(skill_line, []) if r[0] > max(x[0] for x in ranks)]
    trainers = sorted(quest_trainers()[prof].items())

    tools = c["tools"]
    used_tools = {TOOL_ITEMS[t] for s, t in tools.items() if s in recipes}

    # Recetas que no dan puntos (amarilla == gris) pero fabrican un material que
    # otra receta necesita, p. ej. Cured Thick Hide (Thick Hide + Deeprock Salt)
    intermediates = {}
    needed = {i for reagents, _ in recipes.values() for i, _ in reagents} | used_tools
    produced = {out[0] for _, out in recipes.values() if out}
    for spell, r in sla.items():
        if spell in recipes or spell not in c["creates"] or not c["reagents"].get(spell):
            continue
        item, qty = c["creates"][spell]
        if item in needed and item not in produced:
            low, high = int(r["TrivialSkillLineRankLow"]), int(r["TrivialSkillLineRankHigh"])
            intermediates[spell] = (c["reagents"][spell], (item, int(qty)), low, high)
            produced.add(item)

    items = set(used_tools)  # herramientas: también necesitan precio de vendedor/AH
    for reagents, _, _, _ in intermediates.values():
        items.update(i for i, _ in reagents)
    for reagents, output in recipes.values():
        items.update(i for i, _ in reagents)
        if output:
            items.add(output[0])

    item_info = c["item_info"]
    sell = {i: info[2] for i, info in item_info.items() if info[2] > 0}
    # Lo que paga de verdad el vendedor de Forever cuando no coincide con el cliente
    # (visto en el juego: tools/forever/sell_prices.csv)
    with open(FOREVER_SELL, encoding="utf-8") as f:
        for r in csv.DictReader(line for line in f if not line.startswith("#")):
            sell[int(r["item"])] = int(r["sell"])
    # Precio de compra al vendedor: de los materiales que vende algún PNJ
    reagent_items = {i for reagents, _ in recipes.values() for i, _ in reagents}
    reagent_items |= {i for reagents, _, _, _ in intermediates.values() for i, _ in reagents} | used_tools
    sold = vendor_items(reagent_items, c["item_class"]) | EXTRA_VENDOR
    vendor = {i: int(round(item_info[i][1])) for i in sold if i in item_info and item_info[i][1] > 0}

    # Lo que se recolecta: hierbas, metal/piedra (y los lingotes, que se funden con
    # Minería) y cuero que no fabrica ninguna receta de las profesiones ni se compra
    # sin límite a un vendedor (la sal es "cuero" para el juego, pero se compra)
    produced_any = set()
    for line in SKILL_LINES.values():
        for spell in c["sla"][line]:
            if spell in c["creates"]:
                produced_any.add(c["creates"][spell][0])
    gathered = {}
    for i in items:
        line = GATHER_SUBCLASS.get(c["item_class"].get(i))
        if i in ALSO_GATHERED:
            gathered[i] = ALSO_GATHERED[i]
        elif line and i not in produced_any and i not in sold:
            gathered[i] = line

    def num(x):
        return str(int(x)) if float(x).is_integer() else repr(x)

    out = [
        f"-- Generado por tools/gen_profession.py ({prof}). No editar a mano.",
        "-- Datos: cliente de WoW Forever (wago.tools DB2), instructores de CMaNGOS classic-db, vendedores de QuestieDB.",
        "local _, ES = ...",
        "ES.Data = ES.Data or {}",
        "",
        "-- t = { naranja, amarilla, verde, gris }; fee/train = precio y habilidad del instructor",
        "-- (sin fee = se aprende de pergamino: de dónde sale, en Data/Sources.lua; scrollPrice = su precio si lo vende un PNJ)",
        "-- rep = { facción, nivel } que pide el pergamino para aprenderla (5 amistoso, 6 honorable, 7 venerado, 8 exaltado)",
        "-- r = { {itemID, cantidad} }; out = { itemID, cantidad }",
        "-- sq / oq = calidad del pergamino / de lo fabricado (0 pobre, 1 común, 2 poco común, 3 raro, 4 épico)",
        "-- faction = bando que puede aprenderla, si solo es de uno",
        "-- bop = lo fabricado se liga al recogerlo: no se puede vender en la AH (sí al vendedor)",
        "-- favor / favorRep = se compra con Merchant's Favor en el campamento de tu bando, y la reputación que pide",
        "-- train ajustado a Forever: nivel de Classic menos lo que Forever bajó la amarilla de esa receta",
        "-- basic = se aprende sola al coger la profesión; trainer = de instructor sin precio conocido",
        "--   (receta nueva de Forever que no está en CMaNGOS: se aprende al ponerse amarilla)",
        f"ES.Data.{prof} = {{",
        f"  skillLine = {skill_line},",
        "  ranks = { -- { tope, precio, habilidad requerida, nivel de personaje }",
    ]
    for r in ranks:
        out.append("    { %d, %d, %d, %d }," % r)
    out.append("  },")
    out.append("  -- { PNJ instructor, rangos que enseña: 1 aprendiz (75), 2 oficial (150), 4 experto (225), 8 artesano (300) }")
    out.append("  trainers = { " + ", ".join("{ %d, %d }" % t for t in trainers) + " },")
    out.append("  recipes = {")
    fees, scrolls = c["fees"], c["scrolls"]
    favor = merchants_favor(prof)
    favor_found = set()
    for sid in sorted(recipes, key=lambda s: (thresholds[s][0], s)):
        reagents, output = recipes[sid]
        t = thresholds[sid]
        name = c["names"].get(sid, str(sid)).replace("\\", "\\\\").replace('"', '\\"')
        parts = [f'name = "{name}"', "t = { %d, %d, %d, %d }" % t]

        def forever_train(classic, is_forever=False):
            # Los niveles de Classic se desplazan a los de Forever; los del CSV de
            # Forever (vistos en el juego) ya lo son
            return classic if is_forever else max(1, classic - shift.get(sid, 0))
        acquire = sla[sid].get("AcquireMethod")
        if acquire == "1":
            # El cliente de Forever dice que se aprende sola al coger la profesión: manda
            # sobre CMaNGOS (Linen Bag era de instructor en Classic y en Forever no)
            parts.append("basic = true")
        elif sid in fees:
            parts.append(f"fee = {fees[sid][0]}, train = {forever_train(fees[sid][1], fees[sid][2])}")
        elif sid in scrolls:
            scroll = scrolls[sid]
            # Nivel que pide el pergamino; si no lo dice, amarilla - 10 (el umbral
            # "naranja" de Forever es 1 en todas: no sirve como nivel de aprender)
            # El nivel del pergamino ya es el de Forever (ItemSparse de Forever): no se
            # le resta el ajuste de Classic (Dark Leather Tunic salía a 50 y pide 75)
            req = c["item_skill"].get(scroll)
            train = req if req else forever_train(max(1, t[1] - 10 + shift.get(sid, 0)))
            parts.append(f"scroll = {scroll}, train = {train}")
            # Todo objeto trae precio de compra en el cliente, lo venda alguien o no: solo
            # vale si algún vendedor lo vende (QuestieDB) y no es de Merchant's Favor (fichas)
            scroll_buy = item_info.get(scroll, (None, 0, 0))[1]
            mf_name = favor_key(c["names"].get(sid)) in favor
            if scroll_buy > 0 and not mf_name and sold_by_vendor(scroll):
                # Lo que cuesta si lo vende un PNJ (quién lo vende se lee de QuestieDB en el juego)
                parts.append(f"scrollPrice = {int(round(scroll_buy))}")
            if scroll in c["item_rep"]:
                parts.append("rep = { %d, %d }" % c["item_rep"][scroll])
            parts.append(f"sq = {c['item_quality'].get(scroll, 1)}")
        elif acquire == "3":
            # Valor propio de Forever: sin instructor ni pergamino (Basic Campfire), básica
            parts.append("basic = true")
        elif t[1] <= 50:
            # De instructor pero no está en CMaNGOS (receta nueva de Forever: Mana Well,
            # Camp Tent...): se aprende al ponerse amarilla y su precio no se sabe.
            # Solo las de nivel bajo: las altas sin instructor ni pergamino son de misión o
            # reputación (Gordok Ogre Suit, Mooncloth Boots...) y no se pueden dar por instructor
            parts.append(f"trainer = true, train = {t[1]}")
        mf = favor.get(favor_key(c["names"].get(sid)))
        if mf:
            favor_found.add(favor_key(c["names"][sid]))
            parts.append(f"favor = {mf[0]}" + (f", favorRep = {mf[1]}" if mf[1] else ""))
        faction = faction_of(sla[sid])
        if faction:
            parts.append(f'faction = "{faction}"')
        parts.append("r = { " + ", ".join("{ %d, %d }" % rq for rq in reagents) + " }")
        if sid in tools:
            parts.append(f"tool = {tools[sid]}")
        if output:
            parts.append(f"out = {{ {output[0]}, {num(output[1])} }}")
            parts.append(f"oq = {c['item_quality'].get(output[0], 1)}")
            if output[0] in c["item_bop"]:
                parts.append("bop = true")
        out.append(f"    [{sid}] = {{ " + ", ".join(parts) + " },")
    if prof == "Enchanting":
        out.append("    -- Conversión de esencias (clic derecho en la bolsa): no es receta ni da puntos")
        for n, (lesser, greater) in enumerate(ESSENCES):
            out.append(f"    [{-(2 * n + 1)}] = {{ name = \"Convertir 3 en 1 mayor\", intermediate = true, conversion = true, "
                       f"t = {{ 1, 1, 1, 1 }}, train = 1, r = {{ {{ {lesser}, 3 }} }}, out = {{ {greater}, 1 }} }},")
            out.append(f"    [{-(2 * n + 2)}] = {{ name = \"Convertir 1 en 3 menores\", intermediate = true, conversion = true, "
                       f"t = {{ 1, 1, 1, 1 }}, train = 1, r = {{ {{ {greater}, 1 }} }}, out = {{ {lesser}, 3 }} }},")
            items.update((lesser, greater))
    for sid in sorted(intermediates):
        reagents, output, low, high = intermediates[sid]
        iname = item_info.get(output[0], (f"Material {output[0]}",))[0].replace('"', '\\"')
        out.append(
            f"    [{sid}] = {{ name = \"{iname}\", intermediate = true, t = {{ 1, {low}, {low}, {high} }}, "
            f"train = {low}, r = {{ " + ", ".join("{ %d, %d }" % rq for rq in reagents) + " }, "
            f"out = {{ {output[0]}, {output[1]} }} }}, -- no da puntos: solo para fabricar el material"
        )
    out.append("  },")
    out.append("}")
    out.append("")
    out.append("-- Herramientas: [categoría] = { objeto, máscara } (un bastón superior cubre a los inferiores)")
    out.append("ES.Data.Tools = ES.Data.Tools or {}")
    tool_masks = c["tool_masks"]
    for cat in sorted(cc for cc in tool_masks if TOOL_ITEMS[cc] in used_tools or any(t == cc for t in tools.values())):
        out.append(f"ES.Data.Tools[{cat}] = {{ item = {TOOL_ITEMS[cat]}, mask = {tool_masks[cat]}, family = \"{TOOL_FAMILY[cat]}\" }}")
    out.append("")
    out.append("ES.Data.VendorPrices = ES.Data.VendorPrices or {}")
    out.append("ES.Data.SellPrices = ES.Data.SellPrices or {}")
    for i in sorted(items):
        if i in vendor:
            out.append(f"ES.Data.VendorPrices[{i}] = {vendor[i]}")
    for i in sorted(items):
        if i in sell:
            out.append(f"ES.Data.SellPrices[{i}] = {sell[i]}")
    out.append("")
    out.append("-- Nombre de cada objeto (inglés, del cliente): se muestra mientras el juego no lo ha cargado")
    out.append("ES.Data.ItemNames = ES.Data.ItemNames or {}")
    for i in sorted(items):
        if i in item_info and item_info[i][0]:
            iname = item_info[i][0].replace("\\", "\\\\").replace('"', '\\"')
            out.append(f'ES.Data.ItemNames[{i}] = "{iname}"')
    out.append("")
    out.append("-- Material -> profesión de recolección que lo consigue (393 Desuello, 182 Herboristería, 186 Minería).")
    out.append("-- Sin uso por ahora: reservado para la vía \"Vender en bruto\" de Ganar dinero (docs/PLAN.md, G1).")
    out.append("ES.Data.GatheredBy = ES.Data.GatheredBy or {}")
    for i in sorted(items):
        if i in gathered:
            out.append(f"ES.Data.GatheredBy[{i}] = {gathered[i]}")
    out.append("")

    dest = ADDON / "Data" / f"{prof}.lua"
    dest.parent.mkdir(exist_ok=True)
    dest.write_text("\n".join(out), encoding="utf-8")
    trained = sum(1 for s in recipes if s in fees)
    print(f"{dest}: {len(recipes)} recetas ({trained} de instructor), {len(intermediates)} intermedias "
          f"{sorted(o[1][0] for o in intermediates.values())}, {len(items)} objetos, rangos {ranks}")
    if dropped_dups:
        print(f"  fuera {len(dropped_dups)} repetidas: " + "; ".join(dropped_dups))
    if favor:
        missing = sorted(set(favor) - favor_found)
        print(f"  Merchant's Favor: {len(favor_found)} de {len(favor)} recetas"
              + (f" (sin encontrar: {', '.join(missing)})" if missing else ""))
    if impossible:
        print(f"  fuera {len(impossible)} con materiales que no existen en Forever: "
              + ", ".join(c["names"].get(s, str(s)) for s in sorted(impossible)))


if __name__ == "__main__":
    main()

"""Lectura de QuestieDB (Forever): sus datos van "baked" en el .toc (Base64 + CBOR;
los IDs con zlib) y las zonas en support/Forever/Zones. Lo usan gen_sources.py y
gen_profession.py.
"""
import base64
import re
import struct
from pathlib import Path

import os

ADDON = Path(__file__).resolve().parent.parent
# QuestieDB está en la carpeta de addons de WoW (el código de este addon vive en el
# repositorio de GitHub y AddOns\CraftersJournal es un enlace a él). Otra carpeta:
# variable de entorno WOW_ADDONS.
_WOW = Path(r"C:\Program Files (x86)\World of Warcraft")
# Forever tiene su propia carpeta (_forever_) desde su lanzamiento; la beta, de reserva
_DEFAULT_ADDONS = next((p for p in (_WOW / "_forever_" / "Interface" / "AddOns",
                                    _WOW / "_classic_beta_" / "Interface" / "AddOns") if (p / "QuestieDB").exists()),
                       _WOW / "_forever_" / "Interface" / "AddOns")
WOW_ADDONS = Path(os.environ.get("WOW_ADDONS", str(_DEFAULT_ADDONS)))
QUESTIE = WOW_ADDONS / "QuestieDB"
TOC = QUESTIE / "QuestieDB_Forever.toc"
ZONES = QUESTIE / "support" / "Forever" / "Zones"

ITEM = {"npcDrops": 2, "objectDrops": 3, "vendors": 14, "questRewards": 6}
NPC = {"name": 1, "minLevel": 4, "maxLevel": 5, "spawns": 7, "zoneID": 9, "friendlyToFaction": 13, "npcFlags": 15}
# npcFlags de Forever (los de Classic, src/corrections/enum/expansions.lua de QuestieDB)
NPC_VENDOR, NPC_INNKEEPER, NPC_AUCTIONEER = 4, 128, 4096
QUEST = {"name": 1, "startedBy": 2, "requiredLevel": 4, "requiredRaces": 6}


def cbor(data):
    def item(i):
        ib = data[i]
        major, info = ib >> 5, ib & 31
        i += 1

        def arg(i):
            if info < 24:
                return info, i
            n = {24: 1, 25: 2, 26: 4, 27: 8}[info]
            return int.from_bytes(data[i:i + n], "big"), i + n

        if major == 7:
            if info == 20: return False, i
            if info == 21: return True, i
            if info in (22, 23): return None, i
            if info == 25: return struct.unpack(">e", data[i:i + 2])[0], i + 2
            if info == 26: return struct.unpack(">f", data[i:i + 4])[0], i + 4
            if info == 27: return struct.unpack(">d", data[i:i + 8])[0], i + 8
            return None, i
        v, i = arg(i)
        if major == 0: return v, i
        if major == 1: return -1 - v, i
        if major == 2: return data[i:i + v], i + v
        if major == 3: return data[i:i + v].decode("utf-8", "replace"), i + v
        if major == 4:
            out = []
            for _ in range(v):
                x, i = item(i)
                out.append(x)
            return out, i
        if major == 5:
            out = {}
            for _ in range(v):
                k, i = item(i)
                x, i = item(i)
                out[k] = x
            return out, i
        if major == 6:
            return item(i)
        raise ValueError(major)
    return item(0)[0]


store = {}


def load_store():
    with open(TOC, encoding="utf-8") as f:
        for line in f:
            if line.startswith("## X-"):
                key, _, value = line[3:].partition(": ")
                store[key] = value.rstrip("\n")


def stored(key):
    v = store.get(key)
    if v is None:
        return None
    m = re.fullmatch(r"~(\d+)~", v)
    if m:
        return "".join(store[f"{key}-{i}"] for i in range(1, int(m.group(1)) + 1))
    return v


def all_ids(prefix):
    """Todos los IDs de un tipo ("Npc", "Item"...) que hay en la base de datos"""
    pat = re.compile(rf"X-{prefix}-(\d+)-")
    return sorted({int(m.group(1)) for k in store for m in [pat.match(k)] if m})


def row(prefix, eid):
    s = stored(f"X-{prefix}-{eid}-S")
    return cbor(base64.b64decode(s)) if s else None


def field(prefix, eid, idx, r):
    if r is None:
        return None
    key = idx if idx in r else str(idx)
    if key in r:
        v = r[key]
    else:
        s = stored(f"X-{prefix}-{eid}-{idx}")
        v = cbor(base64.b64decode(s)) if s else None
    return v.decode("utf-8", "replace") if isinstance(v, bytes) else v


def seq(t):
    """Lista Lua (puede llegar como mapa {1: .., 2: ..} si tenía huecos)."""
    if isinstance(t, dict):
        return [t[k] for k in sorted(t, key=lambda k: int(k))]
    return t if isinstance(t, list) else []


def at(t, i):
    if isinstance(t, list):
        return t[i - 1] if 0 < i <= len(t) else None
    if isinstance(t, dict):
        return t.get(i, t.get(str(i)))
    return None


def ids(t):
    return [x for x in seq(t) if isinstance(x, int)]


def zone_tables():
    tables = {}
    for name in ("areaIdToUiMapId.lua", "subZoneToParentZone.lua"):
        text = (ZONES / name).read_text(encoding="utf-8")
        for key, body in re.findall(r"ZoneDB\.private\.(\w+)\s*=\s*\[\[return \{(.*?)\}\]\]", text, re.S):
            tables[key] = {int(a): int(b) for a, b in re.findall(r"\[(\d+)\]\s*=\s*(-?\d+)", body)}
    return tables

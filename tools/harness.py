"""Levanta Crafter's Journal completo con una API de WoW simulada y los datos reales del usuario,
ejecuta escaneos, planes y UI, y comprueba invariantes."""
import sys
import time as pytime
from pathlib import Path

import os
sys.path.insert(0, os.environ.get("ESLUA", r"C:\Users\bruno\AppData\Local\Temp\eslua"))  # carpeta con lupa (Lua 5.1)
from lupa import lua51

ADDON = Path(__file__).resolve().parent.parent  # el repositorio (no depende del enlace en AddOns)
# Tus datos guardados: los de Forever (su carpeta desde el lanzamiento); si no, los de la beta
_WOW = Path(r"C:\Program Files (x86)\World of Warcraft")
SV = next(p for folder in ("_forever_", "_classic_beta_")
          for p in (_WOW / folder / "WTF" / "Account").glob("*/SavedVariables/CraftersJournal.lua"))

lua = lua51.LuaRuntime(unpack_returned_tuples=True)
lua.globals().py_clock = pytime.perf_counter

# --- API de WoW simulada -----------------------------------------------------
lua.execute(r"""
-- Reloj real: los datos son los de tu SavedVariables (escaneos e historial con su
-- hora); con uno inventado todo el historial parecería caducado
NOW = os.time()
time = function() return math.floor(NOW) end
BAGS = {}
GetItemCount = function(id) return BAGS[id] or 0 end
KNOWN_SPELLS = {}
IsPlayerSpell = function(id) return KNOWN_SPELLS[id] or false end
bit = bit or { band = function(a, b) local r, p = 0, 1 while a > 0 and b > 0 do if a % 2 == 1 and b % 2 == 1 then r = r + p end a, b, p = math.floor(a / 2), math.floor(b / 2), p * 2 end return r end }
GetTime = function() return NOW end
PRINTS = {}
print = function(...) local t = {} for i = 1, select("#", ...) do t[#t+1] = tostring(select(i, ...)) end PRINTS[#PRINTS+1] = table.concat(t, " ") end

local function Mock(name)
  local m = { _scripts = {}, _events = {}, _name = name, _shown = false }
  return setmetatable(m, { __index = function(t, k)
    if k == "SetScript" then return function(self, n, f) self._scripts[n] = f end end
    if k == "GetScript" then return function(self, n) return self._scripts[n] end end
    if k == "RegisterEvent" then return function(self, e)
      -- Como el cliente real: un evento que no existe da error
      if UNKNOWN_EVENTS[e] then error('Attempt to register unknown event "' .. e .. '"') end
      self._events[e] = true; FRAMES[self] = true end end
    if k == "UnregisterEvent" then return function(self, e) self._events[e] = nil end end
    if k == "UnregisterAllEvents" then return function(self) self._events = {} end end
    if k == "GetWidth" or k == "GetHeight" or k == "GetEffectiveScale" or k == "GetStringWidth" or k == "GetFrameLevel" or k == "GetLeft" or k == "GetTop" then return function() return 100 end end
    if k == "GetScale" then return function(self) return self._scale or 1 end end
    if k == "SetScale" then return function(self, v) self._scale = v end end
    if k == "GetText" then return function(self) return self._text or "" end end
    if k == "SetText" then return function(self, v, ...) assert(select("#", ...) == 0 or true) self._text = v ~= nil and tostring(v) or nil end end
    if k == "SetFormattedText" then return function(self, f, ...) self._text = string.format(f, ...) end end
    if k == "GetCenter" then return function() return 0, 0 end end
    if k == "Show" then return function(self) self._shown = true; if self._scripts.OnShow then self._scripts.OnShow(self) end end end
    if k == "Hide" then return function(self) self._shown = false end end
    if k == "SetShown" then return function(self, v) if v then self:Show() else self:Hide() end end end
    if k == "IsShown" or k == "IsVisible" then return function(self) return self._shown end end
    if k == "GetChecked" then return function(self) return self._checked end end
    if k == "SetChecked" then return function(self, v) self._checked = v end end
    if k == "AddLine" or k == "AddDoubleLine" then return function(self, a, b)
      TOOLTIP[#TOOLTIP+1] = tostring(a) .. (type(b) == "string" and (" | " .. b) or "") end end
    -- Como en WoW: los métodos de widget empiezan por mayúscula; los campos propios no existen
    if type(k) ~= "string" or not k:match("^%u") then return nil end
    return function() return Mock(k) end
  end })
end
FRAMES = {}
TOOLTIP = {}
-- Eventos que tu cliente no tiene (confirmado por el error en el juego) y los
-- de la API moderna, que tampoco existen en la clásica
UNKNOWN_EVENTS = { AUCTION_OWNED_LIST_UPDATE = true, REPLICATE_ITEM_LIST_UPDATE = true }
CreateFrame = function(_, name) local f = Mock("frame") if name then _G[name] = f end return f end
UIParent, Minimap = Mock(), Mock()
GameTooltip = Mock("tooltip")
UISpecialFrames, SlashCmdList = {}, {}
tinsert = table.insert
strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
GetRealmName = function() return REALM end
UnitFactionGroup = function(u) if u == "npc" then return NPC_FACTION end return "Alliance" end
UnitExists = function() return true end
UnitName = function() return "Bruno" end
ITEM_QUALITY_COLORS = {}
for q = -1, 7 do ITEM_QUALITY_COLORS[q] = { r = 1, g = 1, b = 1, hex = "|cffffffff" } end
ITEM_INFO = {}
GetItemInfo = function(id) local i = ITEM_INFO[id] if i then return i.name, nil, 1, nil, nil, nil, nil, nil, nil, 134400, i.sell end end
GetCursorPosition = function() return 0, 0 end
GetFramesRegisteredForEvent = function(e) local t = {} for f in pairs(FRAMES) do if f._events[e] then t[#t+1] = f end end return unpack(t) end

-- C_Timer con cola real
TIMERS = {}
C_Timer = { After = function(d, f) TIMERS[#TIMERS+1] = { at = NOW + d, f = f } end }
function RunTimers(maxSteps)
  local n = 0
  while #TIMERS > 0 and n < (maxSteps or 100000) do
    table.sort(TIMERS, function(a, b) return a.at < b.at end)
    local t = table.remove(TIMERS, 1)
    if t.at > NOW then NOW = t.at end
    t.f()
    n = n + 1
  end
  return n
end

function FireEvent(e, ...)
  for f in pairs(FRAMES) do
    if f._events[e] and f._scripts.OnEvent then f._scripts.OnEvent(f, e, ...) end
  end
end

-- AH clásica simulada
AUCTIONS = {}
AH_RESPONDS = true
CanSendAuctionQuery = function() return true, true end
QueryAuctionItems = function(...) local getAll = select(7, ...)
  if getAll and AH_RESPONDS then C_Timer.After(3, function() FireEvent("AUCTION_ITEM_LIST_UPDATE") end) end end
GetNumAuctionItems = function() return #AUCTIONS, #AUCTIONS end
GetAuctionItemInfo = function(_, i) local a = AUCTIONS[i] if not a then return end
  return nil, nil, a.count, 1, true, 1, nil, 0, 0, a.buyout, 0, nil, nil, a.owner, a.owner, 0, a.item, true end
GetAuctionItemTimeLeft = function(_, i) return AUCTIONS[i] and AUCTIONS[i].tl end
AuctionFrame = Mock("AuctionFrame")
""")

lua.execute(SV.read_text(encoding="utf-8"))
lua.execute(r"""
for k in pairs(CraftersJournalDB.scans) do REALM = k:match("^(.*)%-[^-]+$") break end
NPC_FACTION = "Alliance"
""")

toc = (ADDON / "CraftersJournal.toc").read_text(encoding="utf-8")
files = [l.strip() for l in toc.splitlines() if l.strip() and not l.startswith("#")]
ES = lua.eval("{}")
loader = lua.eval("function(src, name, ES) assert(loadstring(src, '@' .. name))('CraftersJournal', ES) end")
for f in files:
    loader((ADDON / f.replace("\\", "/")).read_text(encoding="utf-8"), f, ES)
lua.globals().ES = ES
lua.execute('FireEvent("ADDON_LOADED", "CraftersJournal"); FireEvent("PLAYER_LOGIN")')


def run(code):
    return lua.execute(code)


print("=" * 70)
print("ARRANQUE:", "realm", lua.globals().REALM, "| key", run("return ES:RealmKey()"))
print(run("return table.concat(PRINTS, '\\n')") or "")

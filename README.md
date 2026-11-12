# Crafter's Journal

A World of Warcraft: Forever addon to **level every profession the cheapest way** and keep track of your **recipe collection**.

- Cheapest route from your current skill to the cap, step by step, with real Auction House prices.
- Trainers by rank, with a waypoint to the nearest one.
- Every recipe of each profession: which you know, which you can learn now, and where to get the rest.
- English and Spanish.

Download it from CurseForge (link coming soon).

## Development

- The addon code is this folder. In WoW, `Interface\AddOns\CraftersJournal` can be a directory junction to it.
- Data is generated from the WoW Forever client tables (wago.tools), CMaNGOS and QuestieDB: `python tools/build_data.py` regenerates `Data/` and runs the tests.
- `python tools/package.py` builds the release zip in `dist/` (the same as the CurseForge packager: no `tools/` or `docs/`).
- Releases are published by `.github/workflows/release.yml` when a `v*` tag is pushed.
- Roadmap: `docs/PLAN.md` (in Spanish).

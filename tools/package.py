"""Genera el zip para CurseForge tal como lo haría BigWigsMods/packager.

  - Solo lo que se publica: fuera tools/, docs/, dist/, .github/, *.py, *.md y los
    archivos ocultos (.git, .pkgmeta...), igual que en .pkgmeta.
  - Dentro del zip, la carpeta CraftersJournal/ (lo que se copia a Interface\\AddOns).
  - La versión sale del .toc (## Version).

Uso: python tools/package.py          -> dist/CraftersJournal-<versión>.zip
Pasa las pruebas antes (python tools/build_data.py).
"""
import re
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NAME = "CraftersJournal"
IGNORE_DIRS = {"tools", "docs", "dist", ".github", ".git", "__pycache__"}
IGNORE_EXT = {".py", ".md", ".pyc"}


def published(path):
    rel = path.relative_to(ROOT)
    if any(part in IGNORE_DIRS or part.startswith(".") for part in rel.parts):
        return False
    return path.suffix not in IGNORE_EXT


def main():
    toc = (ROOT / f"{NAME}.toc").read_text(encoding="utf-8")
    version = re.search(r"^## Version:\s*(\S+)", toc, re.M).group(1)
    dest = ROOT / "dist" / f"{NAME}-{version}.zip"
    dest.parent.mkdir(exist_ok=True)
    files = sorted(p for p in ROOT.rglob("*") if p.is_file() and published(p))
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as z:
        for p in files:
            z.write(p, f"{NAME}/{p.relative_to(ROOT).as_posix()}")
        names = z.namelist()
    print(f"{dest} ({dest.stat().st_size // 1024} KB, {len(names)} archivos, versión {version})")


if __name__ == "__main__":
    main()

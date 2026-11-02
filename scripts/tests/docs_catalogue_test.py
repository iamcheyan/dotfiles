#!/usr/bin/env python3
"""Check that the static tool catalogue documents each registered tool."""
import re
import runpy
from pathlib import Path

root = Path(__file__).resolve().parents[2]
namespace = runpy.run_path(str(root / "docs/site/build.py"))
sections = namespace["SECTIONS"]
missing = []
for section, _label, _scope, docs in sections:
    for slug, _title, _summary in docs:
        page = root / "docs/site/pages" / section / f"{slug}.md"
        if not page.is_file():
            missing.append(str(page.relative_to(root)))
if missing:
    raise SystemExit("catalogue pages missing:\n" + "\n".join(missing))
print(f"catalogue pages: OK ({sum(len(s[3]) for s in sections)} entries)")

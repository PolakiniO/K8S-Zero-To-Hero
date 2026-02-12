#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "Checking markdown links for local file references..."

python - <<'PY'
from pathlib import Path
from urllib.parse import unquote
import re
import sys

root = Path('.').resolve()
link_re = re.compile(r'\[[^\]]+\]\(([^()\n]*(?:\([^)]*\)[^()\n]*)*)\)')
missing = []

for md in root.rglob('*.md'):
    text = md.read_text(encoding='utf-8', errors='ignore')
    for match in link_re.finditer(text):
        target = match.group(1).strip().strip('<>')
        if not target:
            continue
        target = target.split('#')[0].strip()
        if not target or target.startswith(('http://', 'https://', 'mailto:', '#')):
            continue

        target_path = (md.parent / unquote(target)).resolve()
        if not target_path.exists():
            missing.append((md.relative_to(root), target))

if missing:
    for md, target in missing:
        print(f"Missing link target in {md} -> {target}")
    print("Link check failed")
    sys.exit(1)

print("Link check passed")
PY

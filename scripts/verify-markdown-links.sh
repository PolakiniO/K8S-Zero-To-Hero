#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "Checking markdown links for local file references..."

fail=0
while IFS= read -r file; do
  while IFS= read -r link; do
    target="${link#*(}"
    target="${target%)}"
    target="${target%%#*}"

    if [[ -z "$target" ]]; then
      continue
    fi

    if [[ "$target" =~ ^https?:// ]]; then
      continue
    fi

    if [[ ! -e "$target" ]]; then
      echo "Missing link target in $file -> $target"
      fail=1
    fi
  done < <(rg -o "\[[^]]+\]\([^)]+\)" "$file")
done < <(rg --files -g '*.md')

if [[ "$fail" -ne 0 ]]; then
  echo "Link check failed"
  exit 1
fi

echo "Link check passed"

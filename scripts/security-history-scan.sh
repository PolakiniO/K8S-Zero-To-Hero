#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[history-scan] Searching git history for forbidden artifacts..."

zip_hits="$(git log --all --name-only --pretty=format: | rg -n '\.zip$' || true)"
notion_hits="$(git log --all --name-only --pretty=format: | rg -ni '(^|/)notion_exports(/|$)|_files/|(^|/)ExportBlock-[0-9a-fA-F-]+' || true)"

if [[ -n "$zip_hits" ]]; then
  echo "[history-scan][WARN] .zip paths found in history:"
  echo "$zip_hits"
else
  echo "[history-scan][OK] No .zip paths found in history"
fi

if [[ -n "$notion_hits" ]]; then
  echo "[history-scan][WARN] Notion-export-like paths found in history:"
  echo "$notion_hits"
else
  echo "[history-scan][OK] No Notion-export-like paths found in history"
fi

if [[ -n "$zip_hits" || -n "$notion_hits" ]]; then
  echo "[history-scan] History rewrite is required to fully remediate legacy artifacts."
  exit 2
fi

echo "[history-scan] PASSED"

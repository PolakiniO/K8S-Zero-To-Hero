#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[security-scan] Checking tracked files for forbidden artifact types..."

fail=0

check_tracked() {
  local pattern="$1"
  local label="$2"
  local matches
  matches="$(git ls-files | rg -n "$pattern" || true)"
  if [[ -n "$matches" ]]; then
    echo "[security-scan][FAIL] Tracked $label found:" >&2
    echo "$matches" >&2
    fail=1
  else
    echo "[security-scan][OK] No tracked $label"
  fi
}

# Hard-block artifacts that should never be in a public repo
check_tracked '\.zip$' '.zip files'
check_tracked '(^|/)\.env($|\\.)|(^|/)[^/]*\.env($|\\.)' '.env files'
check_tracked '\.(pem|key|p12|pfx)$|(^|/)id_rsa$|(^|/)id_ed25519$|kubeconfig' 'credential/key material'
check_tracked '\.(sqlite|db|sql|dump|bak|log)$' 'local data dumps/logs'

# Notion export signatures (folder names and common export patterns)
check_tracked '(^|/)notion_exports(/|$)|_files/|(^|/)ExportBlock-[0-9a-fA-F-]+' 'Notion export artifacts'

# String heuristics for accidental credentials (tracked text files only)
echo "[security-scan] Running secret pattern heuristics in tracked files..."
TRACKED_FILES="$(git ls-files)"
SECRET_HITS="$(rg -n --hidden --no-ignore -S \
  -e 'BEGIN [A-Z ]*PRIVATE KEY' \
  -e 'ghp_[A-Za-z0-9]{36}' \
  -e 'glpat-[A-Za-z0-9_-]{20,}' \
  -e 'AKIA[0-9A-Z]{16}' \
  -e 'ASIA[0-9A-Z]{16}' \
  -e 'AIza[0-9A-Za-z\-_]{35}' \
  -e 'xox[baprs]-[A-Za-z0-9-]{10,}' \
  -e 'sk_live_[0-9a-zA-Z]{24,}' \
  -e 'Authorization:\\s*Bearer\\s+[A-Za-z0-9._~+/=-]+' \
  -- $TRACKED_FILES || true)"

if [[ -n "$SECRET_HITS" ]]; then
  echo "[security-scan][FAIL] High-risk secret patterns found:" >&2
  echo "$SECRET_HITS" >&2
  fail=1
else
  echo "[security-scan][OK] No high-risk secret patterns found"
fi

if [[ "$fail" -ne 0 ]]; then
  echo "[security-scan] FAILED" >&2
  exit 1
fi

echo "[security-scan] PASSED"

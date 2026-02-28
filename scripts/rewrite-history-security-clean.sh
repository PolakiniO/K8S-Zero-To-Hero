#!/usr/bin/env bash
set -euo pipefail

# Rewrites git history to remove sensitive artifact classes detected by security scans.
# Targets include:
# - *.zip archives
# - Notion export bundles (ExportBlock-*, notion_exports/, *_files/)
# - Common secret material and local dump artifacts
#
# Usage (recommended from a fresh mirror clone):
#   ./scripts/rewrite-history-security-clean.sh [--yes]
#
# Notes:
# - Requires `git-filter-repo`.
# - Creates a safety backup tag before rewrite.
# - Must be followed by a force push.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v git-filter-repo >/dev/null 2>&1; then
  echo "[rewrite] ERROR: git-filter-repo is required but not installed." >&2
  echo "[rewrite] Install: https://github.com/newren/git-filter-repo" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "[rewrite] ERROR: working tree is not clean. Commit/stash changes first." >&2
  exit 1
fi

force="${1:-}"
if [[ "$force" != "--yes" ]]; then
  cat <<'PROMPT'
[rewrite] This will PERMANENTLY rewrite local git history to purge risky artifacts.
[rewrite] Ensure teammates are coordinated before proceeding.
[rewrite] Re-run with --yes to continue.
PROMPT
  exit 2
fi

backup_tag="pre-security-rewrite-$(date +%Y%m%d-%H%M%S)"
git tag "$backup_tag"
echo "[rewrite] Created backup tag: $backup_tag"

# Build path globs used by git-filter-repo. Quotes are intentional to preserve globs.
readarray -t path_args <<'ARGS'
--path-glob
*.zip
--path-glob
notion_exports/**
--path-glob
**/*_files/**
--path-glob
**/ExportBlock-*
--path-glob
*.pem
--path-glob
*.key
--path-glob
*.p12
--path-glob
*.pfx
--path
.env
--path-glob
.env.*
--path-glob
**/.env
--path-glob
**/.env.*
--path
id_rsa
--path
id_ed25519
--path-glob
**/id_rsa
--path-glob
**/id_ed25519
--path-glob
*kubeconfig*
--path-glob
*.sqlite
--path-glob
*.db
--path-glob
*.sql
--path-glob
*.dump
--path-glob
*.bak
--path-glob
*.log
ARGS


echo "[rewrite] Running git-filter-repo path purge..."
git filter-repo --force --invert-paths "${path_args[@]}"

echo "[rewrite] Expiring reflogs and triggering aggressive GC..."
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo "[rewrite] Rewrite complete. Next steps:"
echo "  1) Re-run: bash scripts/security-history-scan.sh"
echo "  2) Push rewritten refs: git push --force --all && git push --force --tags"
echo "  3) Invalidate old clones/forks based on previous history"

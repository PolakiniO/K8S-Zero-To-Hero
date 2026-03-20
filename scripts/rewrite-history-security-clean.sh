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
# - Requires `git-filter-repo` (available as a standalone executable, git subcommand,
#   or Python module entrypoint).
# - Creates a safety backup tag before rewrite.
# - Must be followed by a force push.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

resolve_filter_repo_cmd() {
  if command -v git-filter-repo >/dev/null 2>&1; then
    printf 'git-filter-repo\n'
    return 0
  fi

  if git filter-repo --help >/dev/null 2>&1; then
    printf 'git filter-repo\n'
    return 0
  fi

  if command -v python3 >/dev/null 2>&1 && python3 - <<'PY' >/dev/null 2>&1
import importlib.util
raise SystemExit(0 if importlib.util.find_spec("git_filter_repo") else 1)
PY
  then
    printf 'python3 -m git_filter_repo\n'
    return 0
  fi

  return 1
}

print_install_hint() {
  cat >&2 <<'HINT'
[rewrite] ERROR: git-filter-repo is required but was not found.
[rewrite] Install one of the following, then re-run this script:
[rewrite]   macOS (Homebrew): brew install git-filter-repo
[rewrite]   pipx:            pipx install git-filter-repo
[rewrite]   pip (user):      python3 -m pip install --user git-filter-repo
[rewrite]   docs:            https://github.com/newren/git-filter-repo
HINT
}

if ! FILTER_REPO_CMD="$(resolve_filter_repo_cmd)"; then
  print_install_hint
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "[rewrite] ERROR: working tree is not clean. Commit/stash changes first." >&2
  exit 1
fi

PATH_RULES=$(cat <<'RULES'
path-glob|*.zip
path-glob|notion_exports/**
path-glob|**/*_files/**
path-glob|**/ExportBlock-*
path-glob|*.pem
path-glob|*.key
path-glob|*.p12
path-glob|*.pfx
path|.env
path-glob|.env.*
path-glob|**/.env
path-glob|**/.env.*
path|id_rsa
path|id_ed25519
path-glob|**/id_rsa
path-glob|**/id_ed25519
path-glob|*kubeconfig*
path-glob|*.sqlite
path-glob|*.db
path-glob|*.sql
path-glob|*.dump
path-glob|*.bak
path-glob|*.log
RULES
)

print_rewrite_preview() {
  PATH_RULES="$PATH_RULES" python3 - <<'PY'
import fnmatch
import os
import subprocess
import sys

rules = []
for raw in os.environ["PATH_RULES"].splitlines():
    raw = raw.strip()
    if not raw:
        continue
    kind, pattern = raw.split("|", 1)
    rules.append((kind, pattern))

try:
    proc = subprocess.run(
        ["git", "rev-list", "--objects", "--all"],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
except subprocess.CalledProcessError as exc:
    sys.stderr.write(exc.stderr)
    raise

matches = []
seen = set()
for line in proc.stdout.splitlines():
    parts = line.split(" ", 1)
    if len(parts) != 2:
        continue
    path = parts[1].strip()
    if not path or path in seen:
        continue
    for kind, pattern in rules:
        if kind == "path" and path == pattern:
            matches.append(path)
            seen.add(path)
            break
        if kind == "path-glob" and fnmatch.fnmatch(path, pattern):
            matches.append(path)
            seen.add(path)
            break

print("[rewrite] Candidate paths that match purge rules across reachable history:")
if not matches:
    print("[rewrite]   (no matching paths found in current reachable history)")
    print("[rewrite]   The rewrite will still run in case matching objects exist in refs not surfaced above.")
else:
    for idx, path in enumerate(sorted(matches), 1):
        print(f"[rewrite]   {idx:>3}. {path}")
    print(f"[rewrite] Total matching paths: {len(matches)}")
PY
}

build_path_args() {
  local kind pattern
  path_args=()
  while IFS='|' read -r kind pattern; do
    [[ -z "${kind:-}" ]] && continue
    case "$kind" in
      path)
        path_args+=(--path "$pattern")
        ;;
      path-glob)
        path_args+=(--path-glob "$pattern")
        ;;
      *)
        echo "[rewrite] ERROR: unknown path rule kind: $kind" >&2
        exit 1
        ;;
    esac
  done <<<"$PATH_RULES"
}

force="${1:-}"
print_rewrite_preview

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
echo "[rewrite] Using filter command: $FILTER_REPO_CMD"

build_path_args

echo "[rewrite] Running git-filter-repo path purge..."
IFS=' ' read -r -a filter_repo_cmd <<<"$FILTER_REPO_CMD"
"${filter_repo_cmd[@]}" --force --invert-paths "${path_args[@]}"

echo "[rewrite] Expiring reflogs and triggering aggressive GC..."
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo "[rewrite] Rewrite complete. Next steps:"
echo "  1) Re-run: bash scripts/security-history-scan.sh"
echo "  2) Push rewritten refs: git push --force --all && git push --force --tags"
echo "  3) Invalidate old clones/forks based on previous history"

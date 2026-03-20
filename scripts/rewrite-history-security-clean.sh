#!/usr/bin/env bash
set -euo pipefail

# Rewrites git history to remove sensitive artifact classes detected by security scans.
# Targets include forbidden local artifacts and export/document bundles that should not
# remain in publicly reachable history.
#
# Usage (recommended from a fresh mirror clone):
#   ./scripts/rewrite-history-security-clean.sh [--yes]
#
# Environment:
#   SECURITY_EXTRA_PATH_GLOBS=glob1,glob2      # extend file purge rules
#   SECURITY_EXTRA_HISTORY_PATH_GLOBS=glob3    # extend history-only purge rules
#
# Notes:
# - Requires `git-filter-repo` (available as a standalone executable, git subcommand,
#   or Python module entrypoint).
# - Creates a safety backup tag before rewrite.
# - Must be followed by a force push.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# shellcheck source=scripts/security-rules.sh
source "$ROOT_DIR/scripts/security-rules.sh"
security_load_rules

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

build_unique_path_rules() {
  local item
  path_rules=()
  for item in "${SECURITY_PATH_GLOBS[@]}" "${SECURITY_HISTORY_RISK_PATH_GLOBS[@]}"; do
    [[ -z "$item" ]] && continue
    if [[ " ${path_rules[*]} " != *" $item "* ]]; then
      path_rules+=("$item")
    fi
  done
}

print_rewrite_preview() {
  local path
  local matches=()

  build_unique_path_rules

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    for rule in "${path_rules[@]}"; do
      if [[ "$path" == $rule ]]; then
        matches+=("$path")
        break
      fi
    done
  done < <(git rev-list --objects --all | sed 's/^[^ ]* //g' | sed '/^$/d' | sort -u)

  echo "[rewrite] Candidate paths that match purge rules across reachable history:"
  if ((${#matches[@]} == 0)); then
    echo "[rewrite]   (no matching paths found in current reachable history)"
  else
    printf '%s\n' "${matches[@]}" | sort -u | nl -ba | sed 's/^/[rewrite]   /'
    echo "[rewrite] Total matching paths: $(printf '%s\n' "${matches[@]}" | sort -u | wc -l | tr -d ' ')"
  fi

  echo "[rewrite] Matching commits touching candidate paths:"
  if ((${#matches[@]} == 0)); then
    echo "[rewrite]   (no path matches to summarize)"
  else
    git log --all --date=short --format='[rewrite]   %h %ad %s' -- "${matches[@]}" | sed -n '1,80p'
  fi
}

build_path_args() {
  local pattern
  build_unique_path_rules
  path_args=()
  for pattern in "${path_rules[@]}"; do
    path_args+=(--path-glob "$pattern")
  done
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

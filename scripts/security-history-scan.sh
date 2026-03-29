#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# shellcheck source=scripts/security-rules.sh
source "$ROOT_DIR/scripts/security-rules.sh"
security_load_rules

fail=0
warn=0

all_revs=()
while IFS= read -r rev; do
  [[ -n "$rev" ]] && all_revs+=("$rev")
done < <(git rev-list --all)
if (( ${#all_revs[@]} == 0 )); then
  echo "[history-scan] No commits found."
  exit 0
fi

echo "[history-scan] Searching git history for forbidden artifacts and risky content..."

gather_history_path_matches() {
  local label="$1"
  shift
  local -a patterns=("$@")
  local -a history_paths=()
  local hits=()
  local pattern path

  while IFS= read -r path; do
    [[ -n "$path" ]] && history_paths+=("$path")
  done < <(git log --all --name-only --pretty=format: | sed '/^$/d' | sort -u)

  for path in "${history_paths[@]}"; do
    case "$path" in
      .env.example|*/.env.example)
        continue
        ;;
    esac
    for pattern in "${patterns[@]}"; do
      if [[ "$path" == $pattern ]]; then
        hits+=("$path")
        break
      fi
    done
  done

  if ((${#hits[@]})); then
    echo "[history-scan][WARN] $label:" >&2
    printf '%s\n' "${hits[@]}" | sort -u >&2
    warn=1
  else
    echo "[history-scan][OK] No $label"
  fi
}

gather_history_path_matches "history paths matching forbidden file rules" "${SECURITY_PATH_GLOBS[@]}"
gather_history_path_matches "history paths matching export/release-risk rules" "${SECURITY_HISTORY_RISK_PATH_GLOBS[@]}"

echo "[history-scan] Checking deleted files that still look sensitive..."
deleted_hits=()
deleted_paths=()
while IFS= read -r path; do
  [[ -n "$path" ]] && deleted_paths+=("$path")
done < <(git log --all --diff-filter=D --summary --format='' | sed -n 's/^ delete mode [0-9]* //p' | sort -u)
for path in "${deleted_paths[@]}"; do
  case "$path" in
    .env.example|*/.env.example)
      continue
      ;;
  esac
  for pattern in "${SECURITY_PATH_GLOBS[@]}" "${SECURITY_HISTORY_RISK_PATH_GLOBS[@]}"; do
    if [[ "$path" == $pattern ]]; then
      deleted_hits+=("$path")
      break
    fi
  done
done
if ((${#deleted_hits[@]})); then
  echo "[history-scan][WARN] Deleted sensitive-looking files still exist in history:" >&2
  printf '%s\n' "${deleted_hits[@]}" | sort -u >&2
  warn=1
else
  echo "[history-scan][OK] No deleted sensitive-looking files matched history rules"
fi

git_grep_history() {
  local severity="$1"
  local description="$2"
  local only_historical="${3:-false}"
  shift 3
  local -a patterns=("$@")
  local hits=()
  local current_hits=()
  local filtered_hits=()
  local pattern
  local hit normalized_hit
  local -A current_hit_map=()

  for pattern in "${patterns[@]}"; do
    while IFS= read -r hit; do
      [[ -n "$hit" ]] && hits+=("$hit")
    done < <(git grep -n -I -E "$pattern" "${all_revs[@]}" -- || true)

    if [[ "$only_historical" == "true" ]]; then
      while IFS= read -r hit; do
        [[ -n "$hit" ]] && current_hits+=("$hit")
      done < <(git grep -n -I -E "$pattern" HEAD -- || true)
    fi
  done

  if [[ "$only_historical" == "true" ]] && ((${#current_hits[@]})); then
    for hit in "${current_hits[@]}"; do
      current_hit_map["$hit"]=1
    done

    for hit in "${hits[@]}"; do
      normalized_hit="${hit#*:}"
      if [[ -z "${current_hit_map[$normalized_hit]:-}" ]]; then
        filtered_hits+=("$hit")
      fi
    done
  else
    filtered_hits=("${hits[@]}")
  fi

  if ((${#filtered_hits[@]})); then
    printf '[history-scan][%s] %s\n' "$severity" "$description" >&2
    printf '%s\n' "${filtered_hits[@]}" | sort -u >&2
    if [[ "$severity" == "FAIL" ]]; then
      fail=1
    else
      warn=1
    fi
  else
    printf '[history-scan][OK] No %s\n' "$description"
  fi
}

echo "[history-scan] Checking historical blob contents for secret patterns..."
git_grep_history "FAIL" "historical high-risk secret patterns found" "false" "${SECURITY_SECRET_REGEXES[@]}"

echo "[history-scan] Checking historical blob contents for public-release hygiene issues..."
git_grep_history "WARN" "historical-only hygiene matches found" "true" "${SECURITY_HYGIENE_REGEXES[@]}"

if [[ "$fail" -ne 0 ]]; then
  echo "[history-scan] FAILED" >&2
  exit 1
fi

if [[ "$warn" -ne 0 ]]; then
  echo "[history-scan] PASSED with warnings (manual review or history rewrite required)" >&2
  exit 2
fi

echo "[history-scan] PASSED"

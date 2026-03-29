#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# shellcheck source=scripts/security-rules.sh
source "$ROOT_DIR/scripts/security-rules.sh"
security_load_rules

fail=0
warn=0

tracked_files=()
while IFS= read -r path; do
  [[ -n "$path" ]] && tracked_files+=("$path")
done < <(git ls-files)

visible_untracked_files=()
while IFS= read -r path; do
  [[ -n "$path" ]] && visible_untracked_files+=("$path")
done < <(git ls-files --others --exclude-standard)

all_visible_files=("${tracked_files[@]}")
if ((${#visible_untracked_files[@]})); then
  all_visible_files+=("${visible_untracked_files[@]}")
fi

echo "[security-scan] Checking tracked and visible untracked files for forbidden artifact types..."
echo "[security-scan] Tracked files: ${#tracked_files[@]}"
echo "[security-scan] Visible untracked files: ${#visible_untracked_files[@]}"

check_path_globs() {
  local label="$1"
  shift
  local -a files=()
  local pattern file
  local -a matches=()

  if (($#)); then
    files=("$@")
  fi

  if ((${#files[@]})); then
    for file in "${files[@]}"; do
      case "$file" in
        .env.example|*/.env.example)
          continue
          ;;
      esac
      for pattern in "${SECURITY_PATH_GLOBS[@]}"; do
        if [[ "$file" == $pattern ]]; then
          matches+=("$file")
          break
        fi
      done
    done
  fi

  if ((${#matches[@]})); then
    echo "[security-scan][FAIL] $label files matching forbidden path rules:" >&2
    printf '%s\n' "${matches[@]}" | sort -u >&2
    fail=1
  else
    echo "[security-scan][OK] No $label files match forbidden path rules"
  fi
}

check_path_globs "tracked" ${tracked_files[@]+"${tracked_files[@]}"}
check_path_globs "visible untracked" ${visible_untracked_files[@]+"${visible_untracked_files[@]}"}

dependency_manifest_globs=(
  'requirements*.txt'
  'constraints*.txt'
  'pyproject.toml'
  'Pipfile'
  'Pipfile.lock'
  'poetry.lock'
  'setup.py'
  'setup.cfg'
  'package.json'
  'package-lock.json'
  'npm-shrinkwrap.json'
  'pnpm-lock.yaml'
  'yarn.lock'
  'go.mod'
  'go.sum'
  'Cargo.toml'
  'Cargo.lock'
  'Gemfile'
  'Gemfile.lock'
  'composer.json'
  'composer.lock'
)

dependency_manifest_files=()
for file in "${all_visible_files[@]}"; do
  for pattern in "${dependency_manifest_globs[@]}"; do
    if [[ "$file" == $pattern || "$file" == */$pattern ]]; then
      dependency_manifest_files+=("$file")
      break
    fi
  done
done

text_search() {
  local severity="$1"
  local description="$2"
  shift 2
  local -a patterns=("$@")
  local -a files=("${all_visible_files[@]}")
  local hits=()
  local filtered_hits=()
  local pattern
  local hit ignore_pattern ignored

  ((${#files[@]})) || return 0

  for pattern in "${patterns[@]}"; do
    while IFS= read -r hit; do
      [[ -n "$hit" ]] && hits+=("$hit")
    done < <(rg -n -I --with-filename --hidden --no-ignore -S -e "$pattern" -- "${files[@]}" || true)
  done

  if [[ "$severity" != "FAIL" ]] && ((${#SECURITY_HYGIENE_IGNORE_REGEXES[@]})); then
    for hit in "${hits[@]}"; do
      ignored=0
      for ignore_pattern in "${SECURITY_HYGIENE_IGNORE_REGEXES[@]}"; do
        if [[ "$hit" =~ $ignore_pattern ]]; then
          ignored=1
          break
        fi
      done
      if [[ "$ignored" -eq 0 ]]; then
        filtered_hits+=("$hit")
      fi
    done
  else
    filtered_hits=("${hits[@]}")
  fi

  if ((${#filtered_hits[@]})); then
    printf '[security-scan][%s] %s\n' "$severity" "$description" >&2
    printf '%s\n' "${filtered_hits[@]}" | sort -u >&2
    if [[ "$severity" == "FAIL" ]]; then
      fail=1
    else
      warn=1
    fi
  else
    printf '[security-scan][OK] No %s\n' "$description"
  fi
}

text_search_in_files() {
  local severity="$1"
  local description="$2"
  shift 2
  local files_var_name="$1"
  shift
  local -n files_ref="$files_var_name"
  local -a patterns=("$@")
  local hits=()
  local pattern

  ((${#files_ref[@]})) || {
    printf '[security-scan][OK] No files to scan for %s\n' "$description"
    return 0
  }

  for pattern in "${patterns[@]}"; do
    while IFS= read -r hit; do
      [[ -n "$hit" ]] && hits+=("$hit")
    done < <(rg -n -I --with-filename --hidden --no-ignore -S -i -e "$pattern" -- "${files_ref[@]}" || true)
  done

  if ((${#hits[@]})); then
    printf '[security-scan][%s] %s\n' "$severity" "$description" >&2
    printf '%s\n' "${hits[@]}" | sort -u >&2
    if [[ "$severity" == "FAIL" ]]; then
      fail=1
    else
      warn=1
    fi
  else
    printf '[security-scan][OK] No %s\n' "$description"
  fi
}

echo "[security-scan] Running high-signal secret checks in tracked and visible untracked files..."
text_search "FAIL" "high-risk secret patterns found" "${SECURITY_SECRET_REGEXES[@]}"

echo "[security-scan] Running public-release hygiene heuristics..."
text_search "WARN" "review-worthy hygiene matches found" "${SECURITY_HYGIENE_REGEXES[@]}"

echo "[security-scan] Checking dependency manifests for blocked packages..."
text_search_in_files "FAIL" "blocked dependency identifiers found in dependency manifests" dependency_manifest_files "${SECURITY_BLOCKED_DEPENDENCY_REGEXES[@]}"

if [[ "$fail" -ne 0 ]]; then
  echo "[security-scan] FAILED" >&2
  exit 1
fi

if [[ "$warn" -ne 0 ]]; then
  echo "[security-scan] PASSED with warnings (manual review required)" >&2
  exit 2
fi

echo "[security-scan] PASSED"

#!/usr/bin/env bash
set -euo pipefail

# Lists files that are both tracked and currently ignored by .gitignore.
# This is useful for catching sensitive artifacts that were committed before ignore rules existed.

tracked_ignored=$(git ls-files -ci --exclude-standard || true)

if [[ -n "${tracked_ignored}" ]]; then
  echo "Tracked files matching .gitignore patterns were found:" >&2
  echo "${tracked_ignored}" >&2
  echo "\nRemediation: remove from index (git rm --cached <path>) or refine .gitignore." >&2
  exit 1
fi

echo "No tracked files match .gitignore patterns."

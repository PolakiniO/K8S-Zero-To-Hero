#!/usr/bin/env bash
# Shared rules for public-release security scans and history cleanup.
# shellcheck shell=bash

# Files that should not live in a public repo.
SECURITY_PATH_GLOBS=(
  '*.zip'
  'notion_exports/**'
  '**/*_files/**'
  '**/ExportBlock-*'
  '*.pem'
  '*.key'
  '*.p12'
  '*.pfx'
  '.env'
  '.env.*'
  '**/.env'
  '**/.env.*'
  'id_rsa'
  'id_ed25519'
  '**/id_rsa'
  '**/id_ed25519'
  '*kubeconfig*'
  '*.ovpn'
  '*.sqlite'
  '*.db'
  '*.sql'
  '*.dump'
  '*.bak'
  '*.log'
  '*.tmp'
  '*.old'
  '*.orig'
  '*.rej'
  '*.swp'
  '*.psql'
  '*.csv'
)

# Historical export/doc artifacts that are not secrets by themselves but should not remain in public history.
SECURITY_HISTORY_RISK_PATH_GLOBS=(
  '*.zip'
  'notion_exports/**'
  '**/*_files/**'
  '**/ExportBlock-*'
  '*Notion*'
  '*notion*'
  '*Confluence*'
  '*Jira*'
)

# High-signal secret patterns. These should fail the scan.
SECURITY_SECRET_REGEXES=(
  'BEGIN [A-Z ]*PRIVATE KEY'
  'ghp_[A-Za-z0-9]{36}'
  'github_pat_[A-Za-z0-9_]{20,}'
  'glpat-[A-Za-z0-9_-]{20,}'
  'AKIA[0-9A-Z]{16}'
  'ASIA[0-9A-Z]{16}'
  'AIza[0-9A-Za-z\-_]{35}'
  'xox[baprs]-[A-Za-z0-9-]{10,}'
  'sk_live_[0-9A-Za-z]{16,}'
  'Authorization:[[:space:]]*Bearer[[:space:]]+[A-Za-z0-9._~+/=-]+'
)

# Lower-signal public-release hygiene issues. These warn for human review.
SECURITY_HYGIENE_REGEXES=(
  '(10\.([0-9]{1,3}\.){2}[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.([0-9]{1,3}\.)[0-9]{1,3}|192\.168\.([0-9]{1,3}\.)[0-9]{1,3})'
  '[A-Za-z0-9.-]+\.(internal|corp)'
  'user@host:|~/Projects/|/Users/|C:\\Users\\|/home/[A-Za-z0-9._-]+'
  '(POSTGRES_PASSWORD|MYSQL_PASSWORD|MONGO_INITDB_ROOT_PASSWORD|DB_PASSWORD)[[:space:]]*[:=][[:space:]]*["'"'"']?(password|changeme|admin123|secret123)["'"'"']?'
)

# Known-safe educational or policy examples that should not create warning-only noise.
SECURITY_HYGIENE_IGNORE_REGEXES=(
  '^([0-9a-f]{40}:)?SECURITY\.md:[0-9]+:'
  '^([0-9a-f]{40}:)?scripts/security-rules\.sh:[0-9]+:'
  '^([0-9a-f]{40}:)?\.env\.example:[0-9]+:CAPSTONE_HOST=example\.local$'
  '^([0-9a-f]{40}:)?Labs/K8S-Lab-Capstone/.+:[0-9]+:.*(capstone\.local|localhost|127\.0\.0\.1)'
  '^([0-9a-f]{40}:)?Labs/K8S-Lab-Week2/kind-calico\.yaml:[0-9]+:.*192\.168\.0\.0/16'
  '^([0-9a-f]{40}:)?LabPack/week2/lab9/kind-calico\.yaml:[0-9]+:.*192\.168\.0\.0/16'
  '^([0-9a-f]{40}:)?[^:]+\.(md|txt):[0-9]+:.*(user@host:|polakinio@Polakinio:~/Projects/k8s/)'
  '^([0-9a-f]{40}:)?[^:]+\.(md|txt|yaml|yml):[0-9]+:.*10\.(96|244)\.'
)

# Blocked dependency identifiers for supply-chain risk prevention.
# Keep entries lowercase and scoped to package names (not arbitrary text).
SECURITY_BLOCKED_DEPENDENCY_REGEXES=(
  '(^|[^A-Za-z0-9_.-])litellm([^A-Za-z0-9_.-]|$)'
  '(^|[^A-Za-z0-9_.-])event-stream([^A-Za-z0-9_.-]|$)'
  '(^|[^A-Za-z0-9_.-])ua-parser-js([^A-Za-z0-9_.-]|$)'
  '(^|[^A-Za-z0-9_.-])node-ipc([^A-Za-z0-9_.-]|$)'
  '(^|[^A-Za-z0-9_.-])coa([^A-Za-z0-9_.-]|$)'
  '(^|[^A-Za-z0-9_.-])rc([^A-Za-z0-9_.-]|$)'
)


security_extend_array_from_env() {
  local env_name="$1"
  local target_name="$2"
  local value item

  value="${!env_name:-}"
  [[ -z "$value" ]] && return 0

  # comma-separated env vars keep invocation simple in CI.
  IFS=',' read -r -a _security_extra_items <<<"$value"
  for item in "${_security_extra_items[@]}"; do
    item="${item## }"
    item="${item%% }"
    [[ -z "$item" ]] && continue
    eval "$target_name+=(\"\$item\")"
  done
}

security_load_rules() {
  security_extend_array_from_env SECURITY_EXTRA_PATH_GLOBS SECURITY_PATH_GLOBS
  security_extend_array_from_env SECURITY_EXTRA_HISTORY_PATH_GLOBS SECURITY_HISTORY_RISK_PATH_GLOBS
  security_extend_array_from_env SECURITY_EXTRA_SECRET_REGEXES SECURITY_SECRET_REGEXES
  security_extend_array_from_env SECURITY_EXTRA_HYGIENE_REGEXES SECURITY_HYGIENE_REGEXES
  security_extend_array_from_env SECURITY_EXTRA_HYGIENE_IGNORE_REGEXES SECURITY_HYGIENE_IGNORE_REGEXES
  security_extend_array_from_env SECURITY_EXTRA_BLOCKED_DEP_REGEXES SECURITY_BLOCKED_DEPENDENCY_REGEXES
}

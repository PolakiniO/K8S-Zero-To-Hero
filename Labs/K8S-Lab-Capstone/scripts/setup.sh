#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPSTONE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PLATFORM_DIR="$CAPSTONE_DIR/01-platform"
APPS_DIR="$CAPSTONE_DIR/02-apps"
TLS_DIR="$PLATFORM_DIR/tls"
DRY_RUN="${DRY_RUN:-1}"

step() {
  echo "[setup] $*"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[setup] ERROR: required command not found: $1" >&2
    exit 1
  }
}

apply_file() {
  local file="$1"
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[setup] DRY_RUN=1 -> kubectl apply -f $file"
  else
    kubectl apply -f "$file"
  fi
}

step "Validating toolchain"
require_cmd kubectl
require_cmd kind
require_cmd openssl

ctx="$(kubectl config current-context 2>/dev/null || true)"
if [[ "$ctx" != "kind-labnp" ]]; then
  echo "[setup] WARNING: current context is '$ctx' (expected 'kind-labnp')"
fi

step "Ensuring namespaces exist"
for ns in apps ingress-nginx; do
  if ! kubectl get ns "$ns" >/dev/null 2>&1; then
    kubectl create ns "$ns"
  fi
done

step "Preparing TLS directory and certificate files"
mkdir -p "$TLS_DIR"
CRT="$TLS_DIR/tls.crt"
KEY="$TLS_DIR/tls.key"

if [[ ! -f "$CRT" || ! -f "$KEY" ]]; then
  step "Generating self-signed TLS certificate for capstone.local"
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout "$KEY" \
    -out "$CRT" \
    -subj "/C=US/ST=Local/L=Local/O=K8S-Zero-To-Hero/OU=Capstone/CN=capstone.local" \
    -addext "subjectAltName=DNS:capstone.local,DNS:localhost,IP:127.0.0.1"
else
  step "TLS files already exist: $CRT and $KEY"
fi

step "Applying platform manifests"
apply_file "$PLATFORM_DIR/00-metrics-server.yaml"
apply_file "$PLATFORM_DIR/01-ingress-nginx.yaml"
apply_file "$PLATFORM_DIR/02-ingress-class.yaml"

step "Creating or updating TLS secret in apps namespace"
if [[ "$DRY_RUN" == "1" ]]; then
  echo "[setup] DRY_RUN=1 -> kubectl create secret tls capstone-tls --cert=$CRT --key=$KEY -n apps --dry-run=client -o yaml | kubectl apply -f -"
else
  kubectl create secret tls capstone-tls \
    --cert="$CRT" \
    --key="$KEY" \
    -n apps \
    --dry-run=client -o yaml | kubectl apply -f -
fi

step "Applying apps manifests in order"
apply_file "$APPS_DIR/20-postgres.yaml"
apply_file "$APPS_DIR/30-backend.yaml"
apply_file "$APPS_DIR/31-frontend.yaml"
apply_file "$APPS_DIR/40-netpol-default-deny.yaml"
apply_file "$APPS_DIR/41-netpol-allow-dns.yaml"
apply_file "$APPS_DIR/42-netpol-allow-from-ingress-nginx.yaml"
apply_file "$APPS_DIR/43-netpol-allow-backend-to-postgres.yaml"
apply_file "$APPS_DIR/50-ingress.yaml"

step "Completed. Set DRY_RUN=0 to execute applies."

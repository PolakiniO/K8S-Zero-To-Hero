#!/usr/bin/env bash
set -euo pipefail

APPS_NS="apps"
INGRESS_NS="ingress-nginx"
PF_PID=""
TEMP_POD="netpol-smoke"

cleanup() {
  if [[ -n "${PF_PID:-}" ]] && kill -0 "$PF_PID" >/dev/null 2>&1; then
    kill "$PF_PID" >/dev/null 2>&1 || true
    wait "$PF_PID" 2>/dev/null || true
  fi
  kubectl -n "$APPS_NS" delete pod "$TEMP_POD" --ignore-not-found --wait=false >/dev/null 2>&1 || true
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

echo "== Core add-ons =="
kubectl get deployment metrics-server -n kube-system -o wide || true
kubectl get deployment ingress-nginx-controller -n "$INGRESS_NS" -o wide || true
kubectl get svc ingress-nginx-controller -n "$INGRESS_NS" -o wide || true

echo
echo "== Apps namespace objects =="
kubectl get all -n "$APPS_NS"
kubectl get ingress -n "$APPS_NS"

echo
echo "== NetworkPolicies list =="
kubectl get networkpolicy -n "$APPS_NS"

if ! kubectl get ingressclass nginx >/dev/null 2>&1; then
  fail "IngressClass 'nginx' is missing. Create it with Labs/K8S-Lab-Capstone/01-platform/02-ingress-class.yaml"
fi

echo
echo "== NetworkPolicy enforcement smoke test =="
kubectl -n "$APPS_NS" delete pod "$TEMP_POD" --ignore-not-found --wait=false >/dev/null 2>&1 || true
kubectl -n "$APPS_NS" run "$TEMP_POD" --image=busybox:1.36 --restart=Never --command -- sh -c 'sleep 120' >/dev/null
kubectl -n "$APPS_NS" wait --for=condition=Ready pod/"$TEMP_POD" --timeout=60s >/dev/null || fail "smoke pod did not become ready"

set +e
kubectl -n "$APPS_NS" exec "$TEMP_POD" -- sh -c 'wget -qO- --timeout=3 http://backend:8080 >/dev/null 2>&1'
smoke_rc=$?
set -e

if [[ "$smoke_rc" -eq 0 ]]; then
  fail "default-deny enforcement not observed (traffic unexpectedly allowed)"
else
  echo "BLOCKED"
  echo "PASS: default-deny enforcement observed"
fi

echo
echo "== Ingress functional test =="
kubectl -n "$INGRESS_NS" port-forward svc/ingress-nginx-controller 18080:80 18443:443 >/tmp/capstone-verify-portforward.log 2>&1 &
PF_PID=$!
sleep 3

http_code="$(curl -k -s -o /tmp/capstone-http.out -w '%{http_code}' --max-time 8 -H 'Host: capstone.local' http://127.0.0.1:18080/)"
https_front="$(curl -k -s --max-time 8 -H 'Host: capstone.local' https://127.0.0.1:18443/)"
https_api="$(curl -k -s --max-time 8 -H 'Host: capstone.local' https://127.0.0.1:18443/api)"

if [[ "$http_code" == "308" && "$https_front" == "frontend ok" && "$https_api" == "ok" ]]; then
  echo "PASS: Ingress functional test"
else
  echo "HTTP status: $http_code"
  echo "HTTPS / body: $https_front"
  echo "HTTPS /api body: $https_api"
  fail "Ingress functional test failed"
fi

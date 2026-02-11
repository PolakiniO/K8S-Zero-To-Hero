#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Applying manifests in $SCRIPT_DIR"
for f in *.yaml; do
  [ -f "$f" ] || continue
  kubectl apply -f "$f"
done

echo "Suggested validation commands:"
case "$(basename "$SCRIPT_DIR")" in
  lab1)
    echo "kubectl get pod web-app -w"
    echo "kubectl describe pod web-app -n week1" ;;
  lab2)
    echo "kubectl auth can-i list pods --as=system:serviceaccount:development:dev-sa -n development" ;;
  lab3)
    echo "kubectl get pod memhog -w"
    echo "kubectl describe pod memhog -n week1" ;;
  lab4)
    echo "kubectl describe pod probe-demo -n week1"
    echo "kubectl get endpoints probe-svc -w -n week1" ;;
  lab5)
    echo "kubectl get pod cfg-demo -w -n week1"
    echo "kubectl logs cfg-demo -n week1" ;;
esac

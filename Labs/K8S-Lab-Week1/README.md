# K8S Lab Week1

## Overview
Week 1 focuses on Kubernetes core operations and common first-line failure scenarios: image pull failures, namespace and RBAC issues, resource limits, probe misconfiguration, and ConfigMap or Secret wiring mistakes.

## Prerequisites
- A running Kubernetes cluster (kind, minikube, or cloud cluster)
- `kubectl` configured to your target context
- Basic familiarity with `kubectl get`, `kubectl describe`, and `kubectl logs`

## Folder structure
- `yaml-files/` - runnable manifests and fixes for Week 1 labs
- `ExportBlock-17ac90f3-6182-471f-959c-b23bd3c9ddab-Part-1/` - Notion export with full lab write-ups
- `ExportBlock-17ac90f3-6182-471f-959c-b23bd3c9ddab-Part-1.zip` - original archive backup

### Lab write-ups
- [Week 1 index](./ExportBlock-17ac90f3-6182-471f-959c-b23bd3c9ddab-Part-1/Lab%20-%20Week%201%203042556d80ae8065902ee105ec7e7345.md)
- [Lab 1 - Pod creation and image failure](./ExportBlock-17ac90f3-6182-471f-959c-b23bd3c9ddab-Part-1/Lab%20-%20Week%201/Lab%201%20-%20Pod%20creation%20%2B%20image%20failure%203042556d80ae8049b242dc62e7617810.md)
- [Lab 2 - Namespaces and RBAC failure](./ExportBlock-17ac90f3-6182-471f-959c-b23bd3c9ddab-Part-1/Lab%20-%20Week%201/Lab%202%20-%20Namespaces%20%2B%20RBAC%20failure%20%281%29%203042556d80ae80da85c7cc6b84772547.md)
- [Lab 3 - Requests limits and OOMKilled](./ExportBlock-17ac90f3-6182-471f-959c-b23bd3c9ddab-Part-1/Lab%20-%20Week%201/Lab%203%20-%20Requests%20Limits%20%2B%20OOMKilled%203042556d80ae809699aacb36db1f4bf6.md)
- [Lab 4 - Liveness and readiness probes](./ExportBlock-17ac90f3-6182-471f-959c-b23bd3c9ddab-Part-1/Lab%20-%20Week%201/Lab%204%20%E2%80%94%20Liveness%20%2B%20Readiness%20Probes%203042556d80ae808fa65afeeafcdc54e2.md)
- [Lab 5 - ConfigMap and Secret failures](./ExportBlock-17ac90f3-6182-471f-959c-b23bd3c9ddab-Part-1/Lab%20-%20Week%201/Lab%205%20%E2%80%94%20ConfigMap%20and%20Secret%20Failures%203042556d80ae800fbd9ec66a1b0dc849.md)

## How to run
1. Switch to a safe test namespace or create one.
2. Apply a broken manifest first to reproduce the issue.
3. Collect evidence using `kubectl get`, `kubectl describe`, and `kubectl logs`.
4. Apply the matching fix manifest from `yaml-files/`.
5. Verify the workload transitions to Ready.

Example:
```bash
kubectl apply -f yaml-files/lab3-memhog.yaml
kubectl get pods
kubectl describe pod <pod-name>
kubectl apply -f yaml-files/lab3-memhog-fix.yaml
kubectl get pods -w
```

## Verification and troubleshooting
- Use `kubectl describe` first for event-level error context.
- Validate probes and ports match container behavior.
- Validate ConfigMap or Secret keys and env var names exactly.
- Use `kubectl top pod` (if metrics-server is installed) for memory pressure checks.

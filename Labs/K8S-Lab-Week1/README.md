# K8S Lab Week1

## Overview
Week 1 focuses on Kubernetes core operations and common first-line failure scenarios: image pull failures, namespace and RBAC issues, resource limits, probe misconfiguration, and ConfigMap or Secret wiring mistakes.

## Prerequisites
- A running Kubernetes cluster (kind, minikube, or cloud cluster)
- `kubectl` configured to your target context
- Basic familiarity with `kubectl get`, `kubectl describe`, and `kubectl logs`

## Folder structure
- `yaml-files/` - runnable manifests and fixes for Week 1 labs

### Lab write-ups
- Week 1 write-ups are maintained in the curated markdown files in this repository (see `yaml-files/` and top-level week docs).

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

## Dual-purpose usage (Course + Lab + Showcase)
- **Course**: use Week 1 to build strong Kubernetes debugging fundamentals.
- **Lab**: run broken + fixed manifests and keep your command timeline.
- **Showcase**: publish one concise RCA per lab with symptom, proof, fix, and prevention.

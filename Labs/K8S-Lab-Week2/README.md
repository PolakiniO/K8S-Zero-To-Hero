# K8S Lab Week2

## Overview
Week 2 covers service routing failures, rollout incidents, storage provisioning failures, network policy behavior, and multi-component incident simulation.

## Prerequisites
- Kubernetes cluster with at least two worker nodes recommended
- `kubectl` configured and cluster-admin access
- StorageClass available for dynamic provisioning (for PVC labs)
- CNI with NetworkPolicy support (for Lab 9)

## Folder structure
- `lab6-*.yaml` - service selector mismatch scenario and fix
- `lab7-*.yaml` - rolling update failure and rollback scenario
- `lab8-*.yaml` - persistent volume and claim troubleshooting
- `lab9-*.yaml` - network policy deny and test manifests
- `lab10-*.yaml` - incident simulation broken and fixed manifests
- `kind-calico.yaml` - optional kind config for network policy capable setup
- `Lab *.md` files - exported per-lab narrative notes

### Lab write-ups
- [Week 2 index](./Lab%20-%20Week%202%203042556d80ae807f9a21fe60558e2d0e.md)
- [Lab 6 - Label selector mismatch](./Lab%206%20-%20Label%20Selector%20Mismatch%20%28Service%20cannot%20re%203042556d80ae80b3a38dec537f68baad.md)
- [Lab 7 - Rolling update failure](./Lab%207%20-%20Rolling%20Update%20Failure%203042556d80ae807b8be8daa33d6b66f9.md)
- [Lab 8 - Storage failure PVC pending](./Lab%208%20-%20Storage%20Failure%20%28PVC%20stuck%20Pending%29%203042556d80ae8012aac7e35205129de2.md)
- [Lab 9 - Network policy failure](./Lab%209%20-%20Network%20Policy%20Failure%20%28Traffic%20Blocked%29%203042556d80ae802892a9fb41b97e2d5d.md)
- [Lab 10 - Incident simulation](./Lab%2010%20-%20Incident%20Simulation%20%28Pod%20running%20but%20brok%203042556d80ae8065a2c2fb33a629e6c9.md)

## How to run
1. Start with each lab's broken manifest.
2. Reproduce and capture failure symptoms.
3. Apply the corresponding fixed manifest.
4. Re-test traffic, rollout, or storage state.

Example:
```bash
kubectl apply -f lab6-pod.yaml
kubectl apply -f lab6-service-broken.yaml
kubectl get endpoints
kubectl apply -f lab6-service-fix.yaml
kubectl get endpoints
```

## Verification and troubleshooting
- Use `kubectl get endpoints` for service-target validation.
- Use `kubectl rollout status deployment/<name>` during update labs.
- Use `kubectl describe pvc <name>` and `kubectl get pv` for storage issues.
- For network policy labs, test from both allowed and denied sources.

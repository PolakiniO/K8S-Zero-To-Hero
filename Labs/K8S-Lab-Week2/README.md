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
Per-lab narrative exports were removed to keep repository content source-native and avoid imported export artifacts.
Use the manifests in this folder (`lab6-*.yaml` through `lab10-*.yaml`) together with command output you capture locally.

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

## Deliverable structure (candidate + recruiter friendly)
For each lab, include:

1. **Failure narrative** (detection source + user impact)
2. **Investigation path** (ordered commands and findings)
3. **Root cause proof** (what eliminated alternative hypotheses)
4. **Mitigation + permanent correction**
5. **Recovery validation** (service/rollout/storage healthy again)
6. **Prevention follow-up** (runbook/alert/policy/test)
7. **Interview summary** (4 lines: situation, action, result, relevance)

## Dual-purpose usage (Course + Lab + Showcase)
- **Course**: focus on networking, rollout, and storage failure reasoning.
- **Lab**: document before/after states for each manifest fix.
- **Showcase**: highlight how you reduced blast radius, validated recovery objectively, and communicated decisions clearly.

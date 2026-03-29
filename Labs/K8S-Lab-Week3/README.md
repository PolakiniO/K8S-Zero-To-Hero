# K8S Lab Week3

## Overview
Week 3 introduces production-style incident response: node failure, memory pressure and eviction behavior, certificate trust failures, CPU exhaustion, and multi-service debugging under pressure.

## Prerequisites
- Kubernetes cluster with multiple worker nodes
- `kubectl` with permissions to inspect nodes, events, and workloads
- Metrics server installed for resource visibility
- Familiarity with deployments, services, and scheduling basics

## Folder structure
- `lab11-*.yaml` - node failure and recovery scenarios
- `lab12-memory-pressure.yaml` - memory pressure and eviction simulation
- `lab13-badca.example.crt` - certificate trust break simulation asset
- `lab14-*.yaml` - CPU exhaustion and scheduling behavior
- `lab15-stack.yaml` - multi-service troubleshooting stack
- `Lab *.md` files - lab narratives and troubleshooting flows

### Lab write-ups
Per-lab narrative exports were removed to keep repository content source-native and avoid imported export artifacts.
Use the manifests in this folder (`lab11-*.yaml` through `lab15-*.yaml`) together with command output you capture locally.

## How to run
1. Apply baseline manifests first.
2. Inject failure state from the matching lab manifest.
3. Observe scheduler, kubelet, and application-level symptoms.
4. Apply recovery or policy-restore manifest.
5. Verify resiliency and service restoration.

Example:
```bash
kubectl apply -f lab11-steady-state.yaml
kubectl apply -f lab11-baseline-strict-spread.yaml
kubectl get pods -o wide
kubectl apply -f lab11-incident-availability-fix.yaml
kubectl rollout status deployment/<deployment-name>
```

## Verification and troubleshooting
- Correlate `kubectl get events --sort-by=.lastTimestamp` with workload symptoms.
- Use node and pod-level describe output to isolate scheduling vs runtime failures.
- Verify certificate chains and trust sources in TLS scenarios.
- Confirm recovered services using rollout status and endpoint checks.

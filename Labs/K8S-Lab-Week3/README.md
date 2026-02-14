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
- `lab13-badca.crt` - certificate trust break simulation asset
- `lab14-*.yaml` - CPU exhaustion and scheduling behavior
- `lab15-stack.yaml` - multi-service troubleshooting stack
- `Lab *.md` files - lab narratives and troubleshooting flows

### Lab write-ups
- [Week 3 index](./Lab%20-%20Week%203%203052556d80ae803987f4e98706d90b0c.md)
- [Lab 11 - Simulate node failure](./Lab%2011%20-%20Simulate%20Node%20Failure%203052556d80ae80adba81ec722fb3c435.md)
- [Lab 12A - Cluster resource exhaustion](./Lab%2012A%20-%20Cluster%20Resource%20Exhaustion%203052556d80ae8079a095c43fb2b58857.md)
- [Lab 12B - Forced kubelet eviction](./Lab%2012B%20-%20Forced%20Kubelet%20Evictions%20Using%20evictionH%203052556d80ae801f80f4e6a2931b35e9.md)
- [Lab 13 - Certificate expiration scenario](./Lab%2013%20-%20Certificate%20Expiration%20Scenario%20%28Break%20TL%203052556d80ae809aa0bee08cb3251f1f.md)
- [Lab 14 - Cluster CPU exhaustion](./Lab%2014%20-%20Cluster%20Resource%20Exhaustion%20%28CPU%29%20and%20Sch%203052556d80ae80a69136c57daea65b0e.md)
- [Lab 15 - Multi-service debugging](./Lab%2015%20-%20Multi%20service%20debugging%20%28DB%20config%20drift%20%203052556d80ae8066be92d683f1dccaa9.md)

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

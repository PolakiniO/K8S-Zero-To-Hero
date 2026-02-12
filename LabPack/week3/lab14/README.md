# Lab 14 - Cluster Resource Exhaustion (CPU) and Scheduling Failure

## Goal / Scenario
Create sustained CPU pressure with `cpuhog`, then deploy high-CPU-request workloads (`cpureq`) until scheduler reports `Insufficient cpu`, and validate capacity math from node allocation signals.

## Setup / Resources
- Namespace: `week3`
- Deployments:
  - `cpuhog` from `lab14-cpuhog.yaml`
  - `cpureq` from `lab14-cpureq.yaml`
- Signals used:
  - scheduler events
  - `kubectl describe pod` pending reasons
  - node allocated resource percentages

## Steps performed (high level narrative)
1. Established week3 namespace context.
2. Applied initial `cpuhog` and investigated startup/args issue.
3. Rolled out corrected `cpuhog` spec and scaled to increase cluster CPU demand.
4. Applied `cpureq` and scaled replicas until a pod remained Pending.
5. Collected scheduler and node-capacity evidence proving CPU request exhaustion.

## Investigation (signals)
- `kubectl describe pod` on Pending `cpureq` pod.
- Scheduler message: `0/N nodes are available: Insufficient cpu`.
- Node allocated resources indicating worker near request capacity (93%).
- Events timeline confirming scale/create/fail-scheduling sequence.

## Root cause
Requested CPU exceeded schedulable allocatable CPU under current placement and requests, so scheduler could not place additional `cpureq` replicas.

## Fix applied
No permanent fix-forward in this lab; scenario was intentionally reproduced for evidence capture, followed by cleanup guidance.

## Verification (explicit checks and outputs)
```bash
kubectl get pods -n week3 -o wide
kubectl describe pod <pending-cpureq-pod>
kubectl describe node labnp-worker
```

```text
Insufficient cpu
```

## Lessons learned (production framing)
- Pending pods with high requests are often pure capacity math, not runtime crash issues.
- `describe pod` + node allocated resources is the shortest path to root cause.
- Requests should reflect realistic SLO needs to avoid unnecessary fragmentation.

## Full terminal output (verbatim)
```bash
0/3 nodes are available: 1 Insufficient cpu
```

### Missing terminal transcript
Some terminal excerpts in the Week 3 source are summarized inline rather than preserved as full prompt-by-prompt transcript.

## Manifests used
- [`lab14-cpuhog.yaml`](lab14-cpuhog.yaml)
- [`lab14-cpureq.yaml`](lab14-cpureq.yaml)

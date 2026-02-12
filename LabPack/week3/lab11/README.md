# Lab 11 - Simulate Node Failure

## Goal / Scenario
Simulate a production-style node outage where one worker becomes `NotReady`, controller healing starts, and strict topology spread rules block full recovery until an incident-time availability change is applied.

## Setup / Resources
- Namespace: `week3`
- Workload: `deployment/node-failure-demo`
- Scheduling behavior: topology spread across nodes
- Manifests used:
  - `lab11-steady-state.yaml`
  - `lab11-baseline-strict-spread.yaml`
  - `lab11-incident-availability-fix.yaml`
  - `lab11-policy-restore.yaml`

## Steps performed (high level narrative)
1. Created namespace/context and checked baseline nodes/pods.
2. Deployed workload and observed partial scheduling due to strict spread constraints.
3. Adjusted baseline replica count to match available worker capacity.
4. Simulated node failure (`docker kill labnp-worker`).
5. Observed node/pod degradation and controller replacement attempts.
6. Applied incident fix (`ScheduleAnyway`) to prioritize availability.
7. Validated recovery on remaining healthy worker.
8. Restored node and then restored strict scheduling policy.

## Investigation (signals)
- `kubectl get nodes -o wide` showed `labnp-worker NotReady`.
- `kubectl describe pod ...` showed `NodeNotReady` and scheduler spread constraint mismatch.
- Deployment/ReplicaSet checks showed desired replicas unchanged while one replacement remained Pending.
- Events included `TaintManagerEviction` and `SuccessfulCreate` for replacement pods.

## Root cause
Strict topology spread (`DoNotSchedule`) required distribution across distinct worker nodes; once one worker failed, scheduler could not place both replicas on the single remaining worker.

## Fix applied
Applied `lab11-incident-availability-fix.yaml` to relax spread policy (`whenUnsatisfiable: ScheduleAnyway`) during outage; later restored original policy with `lab11-policy-restore.yaml` after node recovery.

## Verification (explicit checks and outputs)
```bash
kubectl get nodes -o wide
kubectl get deploy node-failure-demo -o wide
kubectl get pods -o wide
```

```text
labnp-worker NotReady
Deployment READY1/2, AVAILABLE1
```

## Lessons learned (production framing)
- Capacity policy must match failure-domain reality.
- During incidents, temporary policy relaxation can reduce customer impact.
- Post-incident, restore policy guardrails to avoid long-term risk drift.

## Full terminal output (verbatim)
```bash
namespace/week3 created
Context"kind-labnp" modified.

labnp-control-plane Ready
labnp-worker Ready
labnp-worker2 ReadyNo resourcesfoundin week3 namespace.

0/3 nodes are available:1node(s)haduntoleratedtaint {node-role.kubernetes.io/control-plane: }2node(s)didn'tmatchpodtopologyspreadconstraintsTopology Spread Constraints:kubernetes.io/hostname:DoNotSchedulewhenmaxskew1isexceeded

deployment"node-failure-demo" successfully rolledout

labnp-worker

labnp-worker NotReady
node-failure-demo-...-gg46q Running/NotReady then Terminatingon labnp-worker

Status: RunningReady:False
Warning  NodeNotReady  node-controller  Nodeisnot ready

NodeNotReady
TaintManagerEviction Markingfordeletion Pod ...
SuccessfulCreate Created pod: node-failure-demo-...-849jl

deployment.apps/node-failure-demo configured

Errorfromserver (NotFound): pods "node-failure-demo-6b6bc7d8c-849jl"notfound
```

## Manifests used
- [`lab11-steady-state.yaml`](lab11-steady-state.yaml)
- [`lab11-baseline-strict-spread.yaml`](lab11-baseline-strict-spread.yaml)
- [`lab11-incident-availability-fix.yaml`](lab11-incident-availability-fix.yaml)
- [`lab11-policy-restore.yaml`](lab11-policy-restore.yaml)

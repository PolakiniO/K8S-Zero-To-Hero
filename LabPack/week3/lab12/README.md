# Lab 12 - Cluster Resource Exhaustion and Evictions

## Goal / Scenario
Run controlled memory-pressure incidents to compare OOM restart behavior vs kubelet eviction behavior, including QoS effects and node memory-pressure taints.

## Setup / Resources
- Namespace: `week3`
- Workloads from `lab12-memory-pressure.yaml`:
  - BestEffort memory hog
  - Burstable memory hog
  - Guaranteed memory-constrained pod
- Kubelet configuration change used during Lab 12B: temporary `evictionHard` override on `labnp-worker`

## Steps performed (high level narrative)
1. Measured baseline allocatable memory on worker node.
2. Applied memory stress workloads pinned to one worker.
3. Observed QoS classes and restart behavior under pressure.
4. Forced earlier kubelet evictions by overriding `evictionHard`.
5. Scaled pressure workloads and captured eviction events.
6. Performed cleanup and restored kubelet configuration.

## Investigation (signals)
- `kubectl get pods -o wide` and restarts for pressure pods.
- `kubectl describe pod` for OOMKilled evidence.
- Events stream for `Evicted`, `TaintManagerEviction`, and grace-period warnings.
- Node taints showing `node.kubernetes.io/memory-pressure`.

## Root cause
Two distinct failure paths were demonstrated:
- Container-local OOM (`OOMKilled`) when a container exceeded its memory behavior/limits.
- Node-level eviction when kubelet eviction thresholds were crossed under forced memory pressure.

## Fix applied
- Scaled down/deleted stress workloads.
- Restored original kubelet configuration on worker.
- Returned node to normal scheduling posture after pressure cleared.

## Verification (explicit checks and outputs)
```bash
kubectl get pods -n week3
kubectl get events -n week3 --sort-by=.lastTimestamp
kubectl describe node labnp-worker
```

```text
Evicted
node.kubernetes.io/memory-pressure
ExceededGracePeriod
```

## Lessons learned (production framing)
- Restart loops are not always node pressure; confirm whether it is OOMKill or Eviction.
- QoS class materially affects survivability under pressure.
- Temporary kubelet threshold changes are powerful but high-risk and must be reverted.

## Full terminal output (verbatim)
```bash
Allocatable:cpu:8memory:8069344Ki
```

```bash
qosClass: BestEffort
qosClass: Burstable
qosClass: Guaranteed
```

```bash
Evicted
The node had condition: [MemoryPressure].
```

```bash
node.kubernetes.io/memory-pressure
```

```bash
Warning  ExceededGracePeriod
```


### Missing terminal transcript
Some intermediate command outputs in the Week 3 notes are summarized narratively without full pasted terminal transcript.

## Manifests used
- [`lab12-memory-pressure.yaml`](lab12-memory-pressure.yaml)

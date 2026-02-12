# Lab 12B - Forced Kubelet Evictions Using evictionHard Override

# Lab 12B - Forced Kubelet Evictions Using evictionHard Override

---

## Goal

Force **real kubelet evictions** (Reason: `Evicted`) by overriding the kubelet memory eviction threshold on a worker node.

Unlike Lab 12 (natural pressure + OOM), this lab:

- Modifies kubelet configuration
- Forces memory pressure deterministically
- Produces real `Evicted` pod status
- Demonstrates node taints during memory pressure
- Shows scheduler behavior under eviction

Cluster:

- kind
- 3 nodes
- namespace: week3
- Kubernetes v1.30.0

---

# Phase 1 - Baseline

## Step 1 - Confirm namespace empty

Command:

```bash
kubectl get pods -n week3 -o wide
```

Output:

```
No resourcesfoundin week3 namespace.
```

---

# Phase 2 - Override kubelet eviction threshold

## Step 2 - Backup kubelet config (labnp-worker)

Command:

```bash
dockerexec -it labnp-worker bash -lc'cp /var/lib/kubelet/config.yaml /var/lib/kubelet/config.yaml.bak && ls -l /var/lib/kubelet/config.yaml*'
```

Output:

```
-rw-r--r--1 root root1214Feb1118:48/var/lib/kubelet/config.yaml-rw-r--r--1 root root1214Feb1214:41/var/lib/kubelet/config.yaml.bak
```

---

## Step 3 - Validate existing eviction config

Command:

```bash
dockerexec -it labnp-worker bash -lc'grep -n "evictionHard" -A8 /var/lib/kubelet/config.yaml || true'
```

Output:

```
22:evictionHard:23-  imagefs.available:0%24-  nodefs.available:0%25-  nodefs.inodesFree:0%26-evictionPressureTransitionPeriod:0s
```

No memory-based eviction threshold was configured.

---

## Step 4 - Override evictionHard for memory

We replaced the eviction block with:

```yaml
evictionHard:memory.available:"6Gi"evictionPressureTransitionPeriod:0s
```

Command:

```bash
dockerexec -it labnp-worker bash -lc '
sed -i "/^evictionHard:/,/^evictionPressureTransitionPeriod:/c\
evictionHard:\n  memory.available: \"6Gi\"\n\
evictionPressureTransitionPeriod: 0s" /var/lib/kubelet/config.yaml
'
```

Verify:

```bash
dockerexec -it labnp-worker bash -lc'grep -n "evictionHard" -A5 /var/lib/kubelet/config.yaml'
```

Output:

```
22:evictionHard:
23-  memory.available:"6Gi"24-evictionPressureTransitionPeriod: 0s
```

---

## Step 5 - Restart worker node

Command:

```bash
docker restart labnp-worker
kubectl get nodes -w
```

Output:

```
labnp-worker NotReady
labnp-worker Ready
```

Cluster healthy again with new eviction threshold active.

---

# Phase 3 - Deploy memory hog workloads

## Step 6 - Apply Lab 12 workload

First attempt mistake (missing -f):

```
error: Unexpectedargs: [lab12-memory-pressure.yaml]
```

Correct command:

```bash
kubectl apply -f lab12-memory-pressure.yaml
```

Output:

```
deployment.apps/memhog-besteffort created
deployment.apps/memhog-burstable created
deployment.apps/memhog-guaranteed created
```

Pods scheduled to labnp-worker.

---

## Step 7 - Increase pressure

Command:

```bash
kubectl scale deployment memhog-besteffort -n week3 --replicas=2
kubectl scale deployment memhog-burstable -n week3 --replicas=2
```

Now multiple 1500M memory hogs running on the same worker.

---

# Phase 4 - Observe Real Evictions

## Key Events Captured

From:

```bash
kubectl get events -n week3 --sort-by=.lastTimestamp
```

Critical lines:

```
Warning   Evicted   pod/memhog-besteffort-...
The node was low on resource: memory.
Threshold quantity:6Gi, available:3980540Ki.
Container hog wasusing 1558448Ki, request is 0.

Warning   Evicted   pod/memhog-burstable-...
Threshold quantity:6Gi, available:5614680Ki.
Container hog wasusing 2552472Ki, request is 256Mi.
```

This confirms:

- Eviction triggered by kubelet
- Hard threshold enforcement
- Memory.available below 6Gi
- QoS considered in selection

---

## Step 8 - Confirm Pod Status = Evicted

Command:

```bash
kubectl describe pod -n week3 memhog-burstable-6848694b45-wntsk
```

Output excerpt:

```
Status:   FailedReason:   EvictedMessage:  The node was lowon resource: memory.
Threshold quantity:6Gi, available:5614680Ki.
Container hog wasusing2552472Ki, requestis256Mi.
QoSClass: Burstable
```

This is the primary success criteria of Lab 12B.

Real kubelet eviction occurred.

---

# Phase 5 - Secondary Effects Observed

## 1. Node tainted with memory-pressure

Scheduler errors observed:

```
FailedScheduling ... had untolerated taint {node.kubernetes.io/memory-pressure: }
```

Meaning:

- Kubelet marked node under pressure
- Scheduler avoided placing new pods there
- Replicas remained Pending

---

## 2. ExceededGracePeriod warnings

```
Warning  ExceededGracePeriod
Container runtime didnot kill the podwithin specified grace period.
```

Observed during forced pressure scenario.

This is expected under heavy runtime stress.

---

# Phase 6 - Cleanup

## Step 9 - Scale down and delete workloads

Commands:

```bash
kubectl scale deployment memhog-besteffort -n week3 --replicas=0
kubectl scale deployment memhog-burstable -n week3 --replicas=0
kubectl scale deployment memhog-guaranteed -n week3 --replicas=0

kubectl delete deployment memhog-besteffort memhog-burstable memhog-guaranteed -n week3 --ignore-not-found

kubectl delete pod -n week3 -l app=memhog-besteffort --ignore-not-found
kubectl delete pod -n week3 -l app=memhog-burstable --ignore-not-found
kubectl delete pod -n week3 -l app=memhog-guaranteed --ignore-not-found

kubectl delete rs -n week3 -l app=memhog-besteffort --ignore-not-found
kubectl delete rs -n week3 -l app=memhog-burstable --ignore-not-found
kubectl delete rs -n week3 -l app=memhog-guaranteed --ignore-not-found
```

Verification:

```
No resourcesfoundin week3 namespace.
```

---

# Phase 7 - Restore kubelet configuration

## Step 10 - Restore original config

Command:

```bash
dockerexec -it labnp-worker bash -lc'cp /var/lib/kubelet/config.yaml.bak /var/lib/kubelet/config.yaml'
docker restart labnp-worker
```

Verify:

```bash
kubectl get nodes
```

Output:

```
labnp-control-plane   Ready
labnp-worker          Ready
labnp-worker2         Ready
```

Baseline restored.

---

# Final Results

Lab 12B successfully demonstrated:

- Direct manipulation of kubelet evictionHard
- Deterministic eviction using memory.available threshold
- Real `Evicted` pod status
- QoS-aware eviction behavior
- Automatic node memory-pressure tainting
- Scheduler blocking under pressure
- Safe rollback of kubelet configuration

---

# Real-World Lessons

- Kubelet eviction is threshold-driven, not random
- QoS affects eviction order but does not guarantee survival
- Node taints under pressure protect cluster stability
- Misconfigured eviction thresholds can destabilize nodes
- Always back up kubelet config before modification

This lab reflects real production debugging scenarios where:

- Nodes begin evicting workloads unexpectedly
- Memory pressure taints block scheduling
- SRE teams must analyze eviction thresholds and restore defaults

---

# Interview Phrase

"I forced kubelet evictions by overriding evictionHard to a 6Gi memory threshold, triggered real Evicted pod states, observed memory-pressure taints affecting scheduling, and restored the kubelet configuration to baseline after validating eviction behavior."

---

# Lab Status

Lab 12B complete

Cluster restored to steady state

Namespace clean

All nodes Ready
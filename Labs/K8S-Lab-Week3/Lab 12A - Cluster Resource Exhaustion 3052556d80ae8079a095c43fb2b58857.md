# Lab 12A - Cluster Resource Exhaustion

# Lab 12 - Memory Pressure, QoS Classes and OOM Behavior

## Goal

Simulate memory pressure on a single worker node to observe:

- QoS classification (BestEffort, Burstable, Guaranteed)
- Container-level OOMKill behavior
- Restart patterns under memory stress
- Difference between OOMKill and Eviction
- How kubelet reacts under memory contention

Cluster:

- kind
- 2 workers
- Calico CNI
- namespace: week3

---

# Step 1 - Baseline Node Capacity

Command:

```bash
kubectl describe node labnp-worker | grep -A5"Allocatable"
```

Output:

```
Allocatable:cpu:8memory:8069344Ki
```

Meaning:

- Each worker has ~7.7Gi allocatable memory
- To trigger pressure, we must concentrate load on one node

---

# Step 2 - Deploy Memory Stress Workloads (YAML Driven)

We deployed three deployments pinned to the same worker using nodeSelector:

```yaml
nodeSelector:kubernetes.io/hostname:labnp-worker
```

Workloads:

### 1. BestEffort

- No requests
- No limits
- Tries to allocate 2500M

### 2. Burstable

```yaml
resources:requests:memory:256Micpu:100m
```

- No limits
- Tries to allocate 2500M

### 3. Guaranteed

```yaml
resources:requests:memory:256Micpu:100mlimits:memory:256Micpu:100m
```

- Hard limited to 256Mi
- Tries to allocate 1500M
- Should hit container OOM before pushing node too far

Command:

```bash
kubectl apply -f lab12-memory-pressure.yaml
```

---

# Step 3 - Verify QoS Classification

Command:

```bash
kubectl get pod -n week3 -o jsonpath='{range .items[*]}{.metadata.name}{"  QoS="}{.status.qosClass}{"\n"}{end}'
```

Output:

```
memhog-besteffort-6f58c54d5c-8j995  QoS=BestEffort
memhog-besteffort-6f58c54d5c-tvl6h  QoS=BestEffort
memhog-burstable-6848694b45-54zzj  QoS=Burstable
memhog-burstable-6848694b45-7zllt  QoS=Burstable
memhog-guaranteed-b6b774776-n5zxx  QoS=Guaranteed
```

Confirmed:

- BestEffort → lowest priority
- Burstable → medium priority
- Guaranteed → highest protection

---

# Step 4 - Increase Pressure (Scale Out)

To exceed node capacity (~7.7Gi), we scaled:

```bash
kubectl scale deployment memhog-besteffort -n week3 --replicas=2
kubectl scale deployment memhog-burstable -n week3 --replicas=2
```

Effective memory pressure attempt:

- BestEffort: 2 x 2500M
- Burstable: 2 x 2500M
- Guaranteed: 1 x 1500M (capped at 256Mi)

Total theoretical allocation attempt > 10Gi

All pinned to labnp-worker.

---

# Step 5 - Observed Behavior

Initial steady state:

```
memhog-besteffortRunning
memhog-burstableRunning
memhog-guaranteedRunning
```

After sustained pressure:

Observed:

```
memhog-guaranteed   OOMKilled
memhog-guaranteed   CrashLoopBackOff
memhog-besteffort   Restarted
memhog-burstable    Restarted
```

Example state:

```
memhog-guaranteed-b6b774776-n5zxx0/1   CrashLoopBackOff2
memhog-besteffort-6f58c54d5c-tvl6h1/1Running1
memhog-burstable-6848694b45-7zllt1/1Running1
```

---

# Step 6 - Deep Inspection of Guaranteed Pod

Command:

```bash
kubectl describe pod -n week3 memhog-guaranteed-b6b774776-n5zxx
```

Key Sections:

```
Limits:memory:256MiRequests:memory:256MiQoS Class:Guaranteed
```

Events:

```
Warning  BackOff  kubelet  Back-off restarting failed container hog
```

Restart Count: 3+

What happened:

- stress attempted 1500M allocation
- Container limited to 256Mi
- Kernel OOMKilled the container
- Kubelet restarted it
- CrashLoopBackOff pattern formed

Important:

This is NOT eviction.

This is container-level OOM due to limit.

---

# Step 7 - Why No Eviction Occurred

Despite heavy pressure:

- Node did not cross kubelet eviction threshold
- Instead, container OOM events happened first
- Guaranteed pod was constrained by its own cgroup limit
- BestEffort and Burstable restarted but were not evicted

Eviction requires:

- Node memory.available below evictionHard threshold
- Kubelet to select lowest QoS victims

We reached container OOM before node-level eviction.

---

# Operational Analysis

Memory contention behavior observed:

1. Guaranteed pod:
    - Protected from eviction priority
    - But killed by its own memory limit
    - Highest scheduling class does NOT protect from cgroup OOM
2. Burstable pods:
    - Restarted
    - Could have been eviction candidates if node threshold hit
3. BestEffort:
    - Lowest priority
    - Restarted but not evicted (node never crossed eviction line)

---

# Root Cause of Restarts

- Total memory allocation attempts exceeded physical capacity
- Linux kernel OOM killer acted at container cgroup level
- Kubelet restarted containers
- Node eviction thresholds were not triggered

This demonstrates:

OOMKill ≠ Eviction

---

# Real-World Lessons

1. QoS controls eviction order, not OOM immunity
2. Guaranteed pods are safest from eviction, not from limits
3. Setting limits too low causes CrashLoopBackOff under stress
4. Container OOM events can happen before node-level eviction
5. Requests influence scheduling, limits influence survival

Production implication:

Misconfigured limits can destabilize high-priority workloads even when node is not officially under eviction pressure.

---

# Key Commands Used

```bash
kubectl apply -f lab12-memory-pressure.yaml
kubectl get pods -n week3 -o wide
kubectl scale deployment
kubectl get pod -o jsonpath
kubectl describe pod
kubectl get events
kubectl delete deployment
```

---

# Incident Pattern Simulated

1. Memory-heavy workload deployed
2. Node capacity stressed
3. Guaranteed pod hits cgroup limit
4. OOMKilled events triggered
5. Restart loops observed
6. No node-level eviction occurred
7. Workloads manually scaled down to restore stability

---

# Interview Phrase

"I simulated memory pressure by pinning multiple stress workloads to a single worker and intentionally mixing QoS classes. Under load, the Guaranteed pod repeatedly OOMKilled due to its cgroup limit, while BestEffort and Burstable restarted under pressure. The node never crossed eviction thresholds, demonstrating the distinction between container-level OOM and kubelet eviction behavior."

---

# Lab 12 Status

Completed:

- QoS classification verified
- OOM behavior demonstrated
- Memory pressure reproduced
- Cluster cleaned and restored
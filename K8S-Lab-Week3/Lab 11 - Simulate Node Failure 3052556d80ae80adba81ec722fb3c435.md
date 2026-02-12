# Lab 11 - Simulate Node Failure

# Lab 11 - Simulate Node Failure

## Goal

Simulate a real incident where:

- A worker node becomes NotReady
- Pods on that node lose readiness and get evicted
- Controllers try to heal by creating replacement pods
- Strict scheduling policy can block recovery
- Apply an incident-time availability fix

Cluster used:

- kind
- Calico installed
- namespace: week3

---

# Step 1 - Create Week 3 Namespace and Set Context

Command:

```bash
kubectl create namespace week3
kubectl config set-context --current --namespace=week3
```

Output:

```
namespace/week3 created
Context"kind-labnp" modified.
```

---

# Step 2 - Baseline Cluster State

Command:

```bash
kubectl get nodes -o wide
kubectl get pods -o wide
```

Output:

```
labnp-control-plane Ready
labnp-worker Ready
labnp-worker2 ReadyNo resourcesfoundin week3 namespace.
```

---

# Step 3 - Deploy Workload Using YAML (Initial)

Command:

```bash
kubectl apply -f lab11-deployment.yaml
kubectl rollout status deployment/node-failure-demo
kubectl get pods -o wide
```

Observed:

- Rollout stalled: 2 of 4 updated replicas available
- 2 pods Running, 2 pods Pending (NODE <none>)

---

# Step 4 - Investigate Pending Pods (Scheduler)

Command:

```bash
kubectl describe pod node-failure-demo-6b6bc7d8c-gf7rl
```

Relevant Output:

```
0/3 nodes are available:1node(s)haduntoleratedtaint {node-role.kubernetes.io/control-plane: }2node(s)didn'tmatchpodtopologyspreadconstraintsTopology Spread Constraints:kubernetes.io/hostname:DoNotSchedulewhenmaxskew1isexceeded
```

Root Cause:

- control-plane is tainted (not schedulable)
- only 2 worker nodes exist
- strict topology spread with DoNotSchedule prevents >1 pod per worker
- replicas=4 can never schedule fully

---

# Step 5 - Fix Baseline (Capacity Match)

Action:

- reduce replicas to 2 (keep DoNotSchedule)

Command:

```bash
kubectl apply -f lab11-deployment-fix.yaml
kubectl rollout status deployment/node-failure-demo
kubectl get pods -o wide
```

Output:

```
deployment"node-failure-demo" successfully rolledout
```

Pods:

```
node-failure-demo-...-gg46q Runningon labnp-worker
node-failure-demo-...-x9kdc Runningon labnp-worker2
```

Operational Note:

- Initially edited wrong file and applied it (no change)
- Corrected the fix manifest and rollout completed

---

# Step 6 - Simulate Node Failure (Kill worker)

Command:

```bash
dockerkill labnp-worker
```

Output:

```
labnp-worker
```

---

# Step 7 - Observe Impact (Node and Pod)

Command:

```bash
kubectl get nodes -o wide
kubectl get pods -o wide
```

Output (key):

```
labnp-worker NotReady
node-failure-demo-...-gg46q Running/NotReady then Terminatingon labnp-worker
```

Command:

```bash
kubectl describe pod node-failure-demo-6b6bc7d8c-gg46q
```

Relevant Output:

```
Status: RunningReady:False
Warning  NodeNotReady  node-controller  Nodeisnot ready
```

Observation:

- API still shows pod state as Running (last known)
- readiness flips to False
- node-controller flags it as NodeNotReady

---

# Step 8 - Controller Healing (Eviction and Replacement)

Command:

```bash
kubectl get deployment node-failure-demo -o wide
kubectl get rs -l app=node-failure-demo
kubectl get pods -o wide
```

Output (key):

```
Deployment READY1/2, AVAILABLE1
ReplicaSet desired=2current=2 ready=1
Replacement pod created but PendingOld podon dead node Terminating
```

Events (key lines):

```
NodeNotReady
TaintManagerEviction Markingfordeletion Pod ...
SuccessfulCreate Created pod: node-failure-demo-...-849jl
```

Root Cause (incident phase):

- Strict topology spread DoNotSchedule blocks placing both replicas on the only remaining worker
- So recovery is prevented even though controller tries to heal

---

# Step 9 - Incident Fix (Availability First)

Action:

- Relax topology spread during outage:
    - whenUnsatisfiable: ScheduleAnyway

Command:

```bash
kubectl apply -f lab11-incident-availability-fix.yaml
```

Output:

```
deployment.apps/node-failure-demo configured
```

Observation:

- Deployment rolled out a new ReplicaSet automatically
- Previous Pending pod ID already replaced, so manual delete returned NotFound

Command:

```bash
kubectl delete pod node-failure-demo-6b6bc7d8c-849jl
```

Output:

```
Errorfromserver (NotFound): pods "node-failure-demo-6b6bc7d8c-849jl"notfound
```

---

# Step 10 - Validate Recovery

Command:

```bash
kubectl get pods -o wide
kubectl get deployment node-failure-demo -o wide
kubectl get rs -l app=node-failure-demo
```

Output:

```
Twonew pods Runningon labnp-worker2
Deployment READY2/2 AVAILABLE2Old RS scaledto0,new RS ready2/2
```

Pods (key):

```
node-failure-demo-756f45cff4-7jxxlRunning labnp-worker2
node-failure-demo-756f45cff4-82c5tRunning labnp-worker2
node-failure-demo-6b6bc7d8c-gg46q Terminating labnp-worker
```

Events (key timeline):

```
Scaled upnew RSto1 -> Created pod -> Started
Scaled downold RS
Scaled upnew RSto2 -> Created pod -> Started
Deletedold pending pod
Killedold running podon worker2 (during rollout)
```

---

# Step 11 - Restore Failed Node

Action:

Start the worker node again to simulate infrastructure recovery.

Command:

```bash
docker start labnp-worker
kubectl get nodes -w
```

Observed:

```
labnp-worker Ready
```

Meaning:

- kubelet reconnects to the control plane
- node transitions from NotReady to Ready
- cluster capacity restored

---

# Step 12 - Restore Scheduling Policy (Post-Incident)

Action:

Reapply strict topology spread policy.

Command:

```bash
kubectl apply -f lab11-policy-restore.yaml
```

Observed:

- Deployment performs a rollout
- Pods are redistributed across worker nodes

Validation:

```bash
kubectl get pods -o wide
kubectl get deployment node-failure-demo
```

Expected:

```
READY2/2
Pods spread across labnp-worker and labnp-worker2
```

---

# Step 13 - Validate Final State

Command:

```bash
kubectl get nodes
kubectl get pods -o wide
kubectl get rs -l app=node-failure-demo
```

Expected steady state:

- All nodes Ready
- Deployment 2/2 Available
- Single ReplicaSet active
- Strict scheduling policy restored

---

# Final Operational Timeline

Incident lifecycle simulated:

1. Normal state
2. Node failure
3. Pod eviction
4. Controller healing attempt
5. Scheduling blocked by strict policy
6. Incident mitigation (ScheduleAnyway)
7. Availability restored
8. Node recovered
9. Policy restored
10. Steady state re-established

This reflects a real SRE incident workflow.

---

# Real-World Lessons

This lab demonstrates several production behaviors:

- Node health directly affects scheduling capacity
- Controllers heal workloads but respect policy constraints
- Availability and placement policy sometimes conflict
- Temporary policy relaxation is a valid operational strategy
- Policies must be restored after recovery

This pattern is common in:

- Platform engineering
- SRE operations
- Kubernetes production environments

---

# Final Root Cause

- Node failure removed scheduling capacity (worker NotReady)
- Strict spread policy (DoNotSchedule) prevented rescheduling when only one worker remained
- Controllers tried to heal (eviction + new pod creation) but scheduling blocked
- Incident-time fix was to relax spread to ScheduleAnyway to restore 2/2 availability

---

# Key Commands Learned

```bash
kubectl get nodes -o wide
kubectl get pods -o wide
kubectl describe pod
kubectl get events --sort-by=.lastTimestamp
kubectl get deployment -o wide
kubectl get rs
dockerkill <kind-worker>
kubectl apply -f <incident-fix.yaml>
```

---

# Interview Phrase

"I simulated a worker failure and followed the full control-plane reaction: the node went NotReady, the pod lost readiness and was evicted by the taint manager, the ReplicaSet created a replacement, but strict topology spread rules blocked scheduling with reduced capacity. During the incident I relaxed the spread constraint to restore availability, then would revert the policy after capacity is restored."

---

# Lab Status

Lab 11 complete + fixed (availability restored during node outage).
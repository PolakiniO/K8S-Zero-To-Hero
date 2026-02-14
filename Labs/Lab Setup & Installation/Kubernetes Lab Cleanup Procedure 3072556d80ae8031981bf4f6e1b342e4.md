# Kubernetes Lab Cleanup Procedure

# Kubernetes Lab Cleanup Procedure

Cluster Type: kind

Networking: Calico

Purpose: Return cluster to clean baseline after lab simulations

---

## Goal

Restore the cluster to a clean operational baseline by:

1. Removing all lab namespaces and workloads
2. Verifying no orphaned services or volumes remain
3. Confirming system components are healthy
4. Ensuring cluster steady state before next lab

This procedure assumes kind cluster with Calico.

---

## When To Run This

- After completing a lab sequence
- Before starting a new lab series
- After troubleshooting experiments
- When cluster state becomes unclear

---

# Step 1 - Confirm Cluster Context

Always verify you are on the correct cluster.

```
kubectl config current-context
kubectl get nodes -o wide
kubectl get ns
```

Expected:

- Correct kind cluster
- All nodes Ready
- System namespaces only:
    - kube-system
    - calico-system
    - calico-apiserver
    - tigera-operator
    - local-path-storage
    - default
    - kube-public
    - kube-node-lease

If unexpected namespaces exist - they likely belong to labs.

---

# Step 2 - Inventory Everything

Full workload scan:

```
kubectl get pods -A -o wide
kubectl get deploy,ds,sts,job,cronjob -A
kubectl get svc -A
kubectl get ing -A
kubectl get pvc -A
kubectl get pv
```

Purpose:

- Identify leftover Deployments
- Detect orphaned Services
- Check persistent storage remnants
- Verify no Ingress objects remain

Do not delete blindly.

Always inspect first.

---

# Step 3 - Identify Lab Namespaces

Typical lab namespaces:

- week1
- week2
- week3
- labX
- incidentX

Confirm contents:

```
kubectl get all -n <namespace>
```

If only lab artifacts exist - safe to delete namespace.

---

# Step 4 - Delete Lab Namespaces

Clean removal:

```
kubectldelete ns week2 week3
```

Watch deletion:

```
kubectl get ns
```

If namespace stuck in Terminating:

```
kubectlget ns <ns> -ojson
```

Likely cause:

- Finalizer on custom resource
- Stuck resource

Resolution (only if required):

- Remove finalizers manually
- Or delete blocking resource

Do not force-delete unless necessary.

---

# Step 5 - Post-Deletion Verification

Re-run full scan:

```
kubectl get pods -A
kubectl get svc -A
kubectl get pvc -A
kubectl get pv
```

Expected:

- Only system components running
- No user workloads
- No PVCs
- No PVs

---

# Step 6 - Check for Silent Errors

Events across all namespaces:

```
kubectl config set-context --current --namespace=default
kubectl get events -A --sort-by=.lastTimestamp | tail -n50
```

Look for:

- BackOff
- FailedMount
- FailedCreatePodSandBox
- ImagePullBackOff
- CrashLoopBackOff

If none repeating - cluster is stable.

---

# Step 7 - Non-Running Pods Sanity Check

```
kubectlget pods-A--field-selector=status.phase!=Running,status.phase!=Succeeded
```

Expected:

No output.

If something appears - investigate before proceeding.

---

# Clean Baseline Definition

Cluster is considered clean when:

- No lab namespaces exist
- Only system namespaces present
- No PVC or PV objects
- No repeating error events
- All system pods Ready
- Nodes Ready

---

# Root Causes of Dirty Cluster

Common issues after labs:

1. Forgotten namespace
2. Orphaned Service without Pods
3. PVC not deleted
4. Stuck finalizer
5. Misconfigured context pointing to deleted namespace
6. ImagePullBackOff pods left running

---

# Operational Lesson

In real production:

You never assume cleanup worked.

You verify every control plane surface:

- Workloads
- Services
- Storage
- Events
- Nodes

This is what interviewers look for:

Systematic validation, not just deletion.

---

# Interview Phrase

"I always perform a full cluster surface scan after incident simulations - namespaces, services, storage, and events - to ensure no residual artifacts impact future workloads."
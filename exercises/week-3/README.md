# Week 3 Labs: Advanced Production Thinking

> Objective: Move from Kubernetes user to Kubernetes operator mindset with failure-domain, resource-pressure, TLS, and multi-service incident drills.

## Lab 11 — Node Failure Simulation
- Incident: Worker becomes `NotReady`; strict spread policy prevents full recovery until policy is relaxed.
- Interview phrase: "I used availability-first scheduling during incident response, then restored policy guardrails."
- Guide: [LabPack/week3/lab11/README.md](../../LabPack/week3/lab11/README.md)

## Lab 12 — Resource Exhaustion + Eviction Behavior
- Incident: Memory pressure produced both OOM restart patterns and kubelet-driven evictions under forced thresholds.
- Interview phrase: "I separated container OOM from node eviction using events, pod status, and node pressure signals."
- Guide: [LabPack/week3/lab12/README.md](../../LabPack/week3/lab12/README.md)

## Lab 13 — Certificate / TLS Trust Break and Restore
- Incident: kubeconfig trust path was broken (x509), while control-plane components remained healthy.
- Interview phrase: "I isolated client trust failure from control-plane availability and restored CA trust safely."
- Guide: [LabPack/week3/lab13/README.md](../../LabPack/week3/lab13/README.md)

## Lab 14 — CPU Exhaustion and Scheduling Failure
- Incident: High CPU requests led to Pending pods with scheduler `Insufficient cpu` decisions.
- Interview phrase: "I proved scheduling failure with node request percentages and scheduler events."
- Guide: [LabPack/week3/lab14/README.md](../../LabPack/week3/lab14/README.md)

## Lab 15 — Multi-service Dependency Debugging
- Incident: DB config drift + backend not listening + selector outage combined into layered service failure.
- Interview phrase: "I traced dependency-by-dependency and validated each hop (DNS, endpoint, listener, HTTP)."
- Guide: [LabPack/week3/lab15/README.md](../../LabPack/week3/lab15/README.md)

## Validation Commands

```bash
kubectl get nodes,pods -o wide
kubectl describe pod <name>
kubectl get events --sort-by=.lastTimestamp
kubectl get svc,endpoints -n <ns>
```

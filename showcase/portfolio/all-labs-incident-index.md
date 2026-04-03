# All Labs Incident Index (Portfolio)

This index consolidates incident scenarios from **all completed labs** so recruiters can verify full-scope coverage quickly.

## Week 1 — Core failures

1. **Lab 1: Pod creation + image pull failure (`ImagePullBackOff`)**  
   Source: [`LabPack/week1/lab1/README.md`](../../LabPack/week1/lab1/README.md)
2. **Lab 2: Namespace + RBAC authorization failure (`Forbidden`)**  
   Source: [`LabPack/week1/lab2/README.md`](../../LabPack/week1/lab2/README.md)
3. **Lab 3: Requests/limits mis-sizing (`OOMKilled`)**  
   Source: [`LabPack/week1/lab3/README.md`](../../LabPack/week1/lab3/README.md)
4. **Lab 4: Probe misconfiguration (liveness/readiness failure)**  
   Source: [`LabPack/week1/lab4/README.md`](../../LabPack/week1/lab4/README.md)
5. **Lab 5: ConfigMap/Secret wiring failure**  
   Source: [`LabPack/week1/lab5/README.md`](../../LabPack/week1/lab5/README.md)

## Week 2 — Networking, rollout, storage, policy, and incident flow

6. **Lab 6: Service selector mismatch (no endpoints)**  
   Source: [`LabPack/week2/lab6/README.md`](../../LabPack/week2/lab6/README.md)
7. **Lab 7: Rolling update failure + rollback path**  
   Source: [`LabPack/week2/lab7/README.md`](../../LabPack/week2/lab7/README.md)
8. **Lab 8: PVC/PV binding failure (`Pending`)**  
   Source: [`LabPack/week2/lab8/README.md`](../../LabPack/week2/lab8/README.md)
9. **Lab 9: NetworkPolicy deny path + connectivity debugging**  
   Source: [`LabPack/week2/lab9/README.md`](../../LabPack/week2/lab9/README.md)
10. **Lab 10: End-to-end incident simulation (`logs -> describe -> exec -> fix`)**  
    Source: [`LabPack/week2/lab10/README.md`](../../LabPack/week2/lab10/README.md)

## Week 3 — Production pressure scenarios

11. **Lab 11: Node outage + availability-first scheduling decision**  
    Source: [`LabPack/week3/lab11/README.md`](../../LabPack/week3/lab11/README.md)
12. **Lab 12: Memory pressure, OOM restarts, and evictions**  
    Source: [`LabPack/week3/lab12/README.md`](../../LabPack/week3/lab12/README.md)
13. **Lab 13: Certificate trust failure and recovery**  
    Source: [`LabPack/week3/lab13/README.md`](../../LabPack/week3/lab13/README.md)
14. **Lab 14: CPU exhaustion and scheduler `Insufficient cpu`**  
    Source: [`LabPack/week3/lab14/README.md`](../../LabPack/week3/lab14/README.md)
15. **Lab 15: Multi-service chain outage (frontend/backend/postgres)**  
    Source: [`LabPack/week3/lab15/README.md`](../../LabPack/week3/lab15/README.md)

## Public-safe incident write-up standard

For each incident write-up, include:
- sanitized command timeline,
- sanitized log excerpts,
- RCA (root cause + trigger + corrective action),
- verification + prevention.

Use:
- [`incident-scenarios/README.md`](../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../deliverable-template.md)

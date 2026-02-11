# Week 2 Labs: Networking + Deployment Incidents

> Objective: Diagnose service exposure, traffic flow, and rollout failures.

## Lab 6 — Label/Selector Mismatch
- Deploy pods with `app=api`.
- Create service selecting `app=backend` (intentional mismatch).
- Observe empty endpoints and failed requests.
- Correct labels/selectors.

## Lab 7 — Rolling Update Failure + Rollback
- Create deployment with healthy image.
- Update image to broken version.
- Track rollout failure.
- Perform rollback and validate recovery.

## Lab 8 — Storage Provisioning Failure
- Create PVC with invalid StorageClass.
- Observe pending claim and unschedulable pod.
- Fix class and bind successfully.

## Lab 9 — NetworkPolicy Deny Scenario
- Apply restrictive policy that blocks pod-to-pod traffic.
- Test connectivity failure.
- Open minimal ingress/egress required.

## Lab 10 — Full Incident Simulation
- Keep pod status `Running` while application path fails.
- Diagnose using logs, exec, events, service endpoints.
- Produce an incident report in markdown.

## Validation Commands
```bash
kubectl get svc,endpoints -n <ns>
kubectl rollout status deployment/<name> -n <ns>
kubectl get pvc,pv -n <ns>
kubectl get netpol -n <ns>
```

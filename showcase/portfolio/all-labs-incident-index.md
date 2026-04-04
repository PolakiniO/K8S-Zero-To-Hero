# All Labs Incident Index (Portfolio)

This index is the canonical map for incident coverage across all completed labs.

> Detailed reports are now split into **one file per incident** for clarity.

## Incident reports folder

- [`showcase/portfolio/incidents/README.md`](incidents/README.md)

## Week 1 — Core failures

1. **Lab 1: Pod creation + image pull failure (`ImagePullBackOff`)**  
   Report: [`incidents/lab01-image-pull-backoff.md`](incidents/lab01-image-pull-backoff.md)
2. **Lab 2: Namespace + RBAC authorization failure (`Forbidden`)**  
   Report: [`incidents/lab02-rbac-forbidden.md`](incidents/lab02-rbac-forbidden.md)
3. **Lab 3: Requests/limits mis-sizing (`OOMKilled`)**  
   Report: [`incidents/lab03-oomkilled.md`](incidents/lab03-oomkilled.md)
4. **Lab 4: Probe misconfiguration (liveness/readiness failure)**  
   Report: [`incidents/lab04-probe-misconfiguration.md`](incidents/lab04-probe-misconfiguration.md)
5. **Lab 5: ConfigMap/Secret wiring failure**  
   Report: [`incidents/lab05-config-secret-wiring.md`](incidents/lab05-config-secret-wiring.md)

## Week 2 — Networking, rollout, storage, policy, and incident flow

6. **Lab 6: Service selector mismatch (no endpoints)**  
   Report: [`incidents/lab06-service-selector-mismatch.md`](incidents/lab06-service-selector-mismatch.md)
7. **Lab 7: Rolling update failure + rollback path**  
   Report: [`incidents/lab07-rolling-update-rollback.md`](incidents/lab07-rolling-update-rollback.md)
8. **Lab 8: PVC/PV binding failure (`Pending`)**  
   Report: [`incidents/lab08-pvc-pv-pending.md`](incidents/lab08-pvc-pv-pending.md)
9. **Lab 9: NetworkPolicy deny path + connectivity debugging**  
   Report: [`incidents/lab09-networkpolicy-deny.md`](incidents/lab09-networkpolicy-deny.md)
10. **Lab 10: End-to-end incident simulation (`logs -> describe -> exec -> fix`)**  
    Report: [`incidents/lab10-end-to-end-incident-drill.md`](incidents/lab10-end-to-end-incident-drill.md)

## Week 3 — Production pressure scenarios

11. **Lab 11: Node outage + availability-first scheduling decision**  
    Report: [`incidents/lab11-node-outage-scheduling.md`](incidents/lab11-node-outage-scheduling.md)
12. **Lab 12: Memory pressure, OOM restarts, and evictions**  
    Report: [`incidents/lab12-memory-pressure-evictions.md`](incidents/lab12-memory-pressure-evictions.md)
13. **Lab 13: Certificate trust failure and recovery**  
    Report: [`incidents/lab13-certificate-trust-failure.md`](incidents/lab13-certificate-trust-failure.md)
14. **Lab 14: CPU exhaustion and scheduler `Insufficient cpu`**  
    Report: [`incidents/lab14-cpu-exhaustion.md`](incidents/lab14-cpu-exhaustion.md)
15. **Lab 15: Multi-service chain outage (frontend/backend/postgres)**  
    Report: [`incidents/lab15-multi-service-chain-outage.md`](incidents/lab15-multi-service-chain-outage.md)

## Reporting format used in every incident file

- Detection + impact
- Investigation timeline (sanitized commands)
- Root cause + trigger
- Fixes
- Verification + prevention

Template references:
- [`incident-scenarios/README.md`](../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../deliverable-template.md)

## EKS anonymized interview lab — cloud deployment and security incident chain

EKS-1. **MongoDB package/version mismatch on EC2 database host**  
Report: [`incidents/eks01-mongodb-package-version-mismatch.md`](incidents/eks01-mongodb-package-version-mismatch.md)
EKS-2. **`kubectl` download returned redirect/error payload**  
Report: [`incidents/eks02-kubectl-download-redirect-payload.md`](incidents/eks02-kubectl-download-redirect-payload.md)
EKS-3. **Tasky `CrashLoopBackOff` from secret/URI wiring errors**  
Report: [`incidents/eks03-tasky-crashloopbackoff-secret-uri.md`](incidents/eks03-tasky-crashloopbackoff-secret-uri.md)
EKS-4. **MongoDB `Unauthorized` despite network reachability**  
Report: [`incidents/eks04-mongodb-unauthorized-authsource-role.md`](incidents/eks04-mongodb-unauthorized-authsource-role.md)
EKS-5. **Database EC2 placed in public subnet during initial build**  
Report: [`incidents/eks05-db-public-subnet-exposure-control-gap.md`](incidents/eks05-db-public-subnet-exposure-control-gap.md)


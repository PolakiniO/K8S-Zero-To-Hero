# Incident Reports (Per-Lab)

Each file in this folder contains one detailed incident report, separated for clarity and easier review.

## Week 1

- [01. Lab 1: Pod creation + image pull failure (`ImagePullBackOff`)](lab01-image-pull-backoff.md)
- [02. Lab 2: Namespace + RBAC authorization failure (`Forbidden`)](lab02-rbac-forbidden.md)
- [03. Lab 3: Requests/limits mis-sizing (`OOMKilled`)](lab03-oomkilled.md)
- [04. Lab 4: Probe misconfiguration (liveness/readiness failure)](lab04-probe-misconfiguration.md)
- [05. Lab 5: ConfigMap/Secret wiring failure](lab05-config-secret-wiring.md)

## Week 2

- [06. Lab 6: Service selector mismatch (no endpoints)](lab06-service-selector-mismatch.md)
- [07. Lab 7: Rolling update failure + rollback path](lab07-rolling-update-rollback.md)
- [08. Lab 8: PVC/PV binding failure (`Pending`)](lab08-pvc-pv-pending.md)
- [09. Lab 9: NetworkPolicy deny path + connectivity debugging](lab09-networkpolicy-deny.md)
- [10. Lab 10: End-to-end incident simulation (`logs -> describe -> exec -> fix`)](lab10-end-to-end-incident-drill.md)

## Week 3

- [11. Lab 11: Node outage + availability-first scheduling decision](lab11-node-outage-scheduling.md)
- [12. Lab 12: Memory pressure, OOM restarts, and evictions](lab12-memory-pressure-evictions.md)
- [13. Lab 13: Certificate trust failure and recovery](lab13-certificate-trust-failure.md)
- [14. Lab 14: CPU exhaustion and scheduler `Insufficient cpu`](lab14-cpu-exhaustion.md)
- [15. Lab 15: Multi-service chain outage (frontend/backend/postgres)](lab15-multi-service-chain-outage.md)

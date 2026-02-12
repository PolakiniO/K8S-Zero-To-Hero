# Week 2 Labs: Networking + Deployment Incidents

> Objective: Diagnose service exposure, traffic flow, policy enforcement, storage behavior, and rollout failures.

## Lab 6 — Label/Selector Mismatch
- Incident: Service exists but has `<none>` endpoints because selector does not match pod labels.
- Interview phrase: "Service selector mismatch caused routing failure."
- Guide: [LabPack/week2/lab6/README.md](../../LabPack/week2/lab6/README.md)

## Lab 7 — Rolling Update Failure + Rollback
- Incident: New ReplicaSet cannot pull updated image, rollout stalls while old replicas stay healthy.
- Interview phrase: "I inspected rollout status and isolated failing replicas."
- Guide: [LabPack/week2/lab7/README.md](../../LabPack/week2/lab7/README.md)

## Lab 8 — Storage Provisioning Failure
- Incident: PVC stays Pending until consumer/provisioning path resolves.
- Interview phrase: "Pod was blocked by volume provisioning."
- Guide: [LabPack/week2/lab8/README.md](../../LabPack/week2/lab8/README.md)

## Lab 9 — NetworkPolicy Deny Scenario
- Incident: deny policy initially did not block traffic until cluster was recreated with Calico NP enforcement.
- Interview phrase: "Network policy prevented east-west communication."
- Guide: [LabPack/week2/lab9/README.md](../../LabPack/week2/lab9/README.md)

## Lab 10 — Full Incident Simulation
- Incident: Pod stayed Running while app failed due to missing/misformatted ConfigMap mount.
- Interview phrase: "I treated it as an incident investigation."
- Guide: [LabPack/week2/lab10/README.md](../../LabPack/week2/lab10/README.md)

## Validation Commands

```bash
kubectl get svc,endpoints -n <ns>
kubectl rollout status deployment/<name> -n <ns>
kubectl get pvc,pv -n <ns>
kubectl get netpol -n <ns>
```

# Incident Report: Lab 14: CPU exhaustion and scheduler `Insufficient cpu`

**Lab source**: [`LabPack` reference](../../../LabPack/week3/lab14/README.md)

## 1) Detection + impact
- Pods pending due to scheduler reporting `Insufficient cpu`.
- Existing workloads experienced contention and degraded latency.

## 2) Investigation timeline (sanitized)
- Observed CPU consumption and scheduler event stream.
- Compared requests to allocatable node capacity.

## 3) Root cause + trigger
- CPU request sizing and load profile exceeded cluster budget.

## 4) Fixes
- Tuned CPU requests and reduced pressure from hog workload.

## 5) Verification + prevention
- Pending pods scheduled successfully.
- Added capacity planning checkpoints for request changes.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

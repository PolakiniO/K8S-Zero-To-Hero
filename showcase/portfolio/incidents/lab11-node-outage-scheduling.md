# Incident Report: Lab 11: Node outage + availability-first scheduling decision

**Lab source**: [`LabPack` reference](../../../LabPack/week3/lab11/README.md)

## 1) Detection + impact
- Node outage reduced placement options and threatened availability.

## 2) Investigation timeline (sanitized)
- Inspected node and pod scheduling events.
- Compared strict spread policy behavior vs degraded-cluster reality.

## 3) Root cause + trigger
- Policy rigidity under failure reduced scheduling flexibility.

## 4) Fixes
- Applied availability-first scheduling adjustment during incident.
- Restored stricter policy after cluster health normalized.

## 5) Verification + prevention
- Workloads rescheduled and availability restored.
- Added incident-mode policy toggle strategy.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

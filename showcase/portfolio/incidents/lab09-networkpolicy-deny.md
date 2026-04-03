# Incident Report: Lab 9: NetworkPolicy deny path + connectivity debugging

**Lab source**: [`LabPack` reference](../../../LabPack/week2/lab9/README.md)

## 1) Detection + impact
- Inter-pod communication blocked unexpectedly.

## 2) Investigation timeline (sanitized)
- Tested connectivity from allowed/denied clients.
- Reviewed policy selectors and namespace labels.

## 3) Root cause + trigger
- Default deny behavior without explicit allow for intended path.

## 4) Fixes
- Added least-privilege allow rule for required flow.

## 5) Verification + prevention
- Expected client traffic succeeded; non-allowed paths remained blocked.
- Documented policy intent with test commands in runbook.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

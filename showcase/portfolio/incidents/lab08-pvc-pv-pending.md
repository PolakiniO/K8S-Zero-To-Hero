# Incident Report: Lab 8: PVC/PV binding failure (`Pending`)

**Lab source**: [`LabPack` reference](../../../LabPack/week2/lab8/README.md)

## 1) Detection + impact
- PVC remained `Pending`; pod could not start with required storage.

## 2) Investigation timeline (sanitized)
- Reviewed PVC events, storage class, access mode, and capacity.
- Checked matching PV properties.

## 3) Root cause + trigger
- Incompatible PVC/PV settings (class/mode/size mismatch).

## 4) Fixes
- Corrected claim or volume specs for compatibility.

## 5) Verification + prevention
- PVC bound successfully and pod started.
- Added storage manifest compatibility checklist.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

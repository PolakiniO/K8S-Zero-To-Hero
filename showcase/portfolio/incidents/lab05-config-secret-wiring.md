# Incident Report: Lab 5: ConfigMap/Secret wiring failure

**Lab source**: [`LabPack` reference](../../../LabPack/week1/lab5/README.md)

## 1) Detection + impact
- Application started with wrong or missing configuration values.
- Functional behavior deviated from expected runtime config.

## 2) Investigation timeline (sanitized)
- Inspected env mappings and key references.
- Compared ConfigMap/Secret keys to deployment env declarations.

## 3) Root cause + trigger
- Incorrect key names and mismatched references in env wiring.

## 4) Fixes
- Corrected keys and environment variable references.

## 5) Verification + prevention
- App loaded expected values after rollout.
- Added config contract check (required keys) before deploy.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

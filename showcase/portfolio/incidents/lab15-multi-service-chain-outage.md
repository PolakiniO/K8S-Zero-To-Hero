# Incident Report: Lab 15: Multi-service chain outage (frontend/backend/postgres)

**Lab source**: [`LabPack` reference](../../../LabPack/week3/lab15/README.md)

## 1) Detection + impact
- End-user flow failed across service chain dependencies.

## 2) Investigation timeline (sanitized)
- Traced path frontend -> backend -> database.
- Validated service discovery, env config, and dependency readiness.

## 3) Root cause + trigger
- Downstream dependency/service wiring issue cascaded upstream.

## 4) Fixes
- Restored broken dependency path and corrected configuration.

## 5) Verification + prevention
- Full chain recovered with successful end-to-end response.
- Added dependency health gates and chain-level smoke checks.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

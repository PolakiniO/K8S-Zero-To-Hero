# Incident Report: Lab 6: Service selector mismatch (no endpoints)

**Lab source**: [`LabPack` reference](../../../LabPack/week2/lab6/README.md)

## 1) Detection + impact
- Service reachable but had zero endpoints; requests failed.

## 2) Investigation timeline (sanitized)
- Compared service selector labels with pod labels.
- Verified endpoint object remained empty.

## 3) Root cause + trigger
- Label/selector mismatch after manifest drift.

## 4) Fixes
- Aligned service selectors with pod labels.

## 5) Verification + prevention
- Endpoints populated and traffic succeeded.
- Added label contract review during manifest updates.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

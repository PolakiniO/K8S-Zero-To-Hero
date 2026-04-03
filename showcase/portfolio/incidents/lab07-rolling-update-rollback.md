# Incident Report: Lab 7: Rolling update failure + rollback path

**Lab source**: [`LabPack` reference](../../../LabPack/week2/lab7/README.md)

## 1) Detection + impact
- Deployment rollout stalled with unhealthy new replicas.
- Partial or full service degradation during update window.

## 2) Investigation timeline (sanitized)
- Checked rollout status, ReplicaSet health, and events.
- Reviewed rollout history for last known good revision.

## 3) Root cause + trigger
- Bad deployment revision introduced invalid runtime behavior.

## 4) Fixes
- Rolled back to known healthy revision.
- Reworked change set before retrying rollout.

## 5) Verification + prevention
- Stable replica availability restored.
- Added rollout guardrails and pre-release validation.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

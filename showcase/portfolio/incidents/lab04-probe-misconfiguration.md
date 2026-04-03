# Incident Report: Lab 4: Probe misconfiguration (liveness/readiness failure)

**Lab source**: [`LabPack` reference](../../../LabPack/week1/lab4/README.md)

## 1) Detection + impact
- Pod cycling due to liveness failures and/or not entering ready state.
- Service endpoints unavailable or flapping.

## 2) Investigation timeline (sanitized)
- Inspected probe paths/ports and timings in deployment spec.
- Correlated probe events with container logs.

## 3) Root cause + trigger
- Probe endpoint/port mismatch and overly strict probe timings.

## 4) Fixes
- Corrected probe route/port and tuned thresholds.

## 5) Verification + prevention
- Pod became `Ready` consistently; service endpoints populated.
- Introduced startup/readiness review checklist for new services.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

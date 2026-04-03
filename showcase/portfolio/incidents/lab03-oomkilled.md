# Incident Report: Lab 3: Requests/limits mis-sizing (`OOMKilled`)

**Lab source**: [`LabPack` reference](../../../LabPack/week1/lab3/README.md)

## 1) Detection + impact
- Pod repeatedly restarted with `OOMKilled`.
- Unstable workload behavior and elevated restart count.

## 2) Investigation timeline (sanitized)
- Reviewed container termination reason in `kubectl describe pod`.
- Compared container memory limits with observed usage profile.

## 3) Root cause + trigger
- Memory limit was set below realistic process peak demand.

## 4) Fixes
- Increased memory limits/requests to a safe baseline.
- Re-deployed with corrected resources.

## 5) Verification + prevention
- Restarts stabilized and pod remained healthy under expected load.
- Added resource sizing baseline guidance per workload type.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

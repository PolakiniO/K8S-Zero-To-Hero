# Incident Report: Lab 12: Memory pressure, OOM restarts, and evictions

**Lab source**: [`LabPack` reference](../../../LabPack/week3/lab12/README.md)

## 1) Detection + impact
- Cluster exhibited memory pressure with restarts/evictions.

## 2) Investigation timeline (sanitized)
- Correlated node pressure conditions with pod terminations.
- Reviewed resource requests/limits and QoS behavior.

## 3) Root cause + trigger
- Aggregate memory demand exceeded safe node capacity.

## 4) Fixes
- Rebalanced resource settings and workload pressure profile.

## 5) Verification + prevention
- Memory pressure signals subsided and eviction frequency dropped.
- Added memory headroom and saturation alert guidance.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

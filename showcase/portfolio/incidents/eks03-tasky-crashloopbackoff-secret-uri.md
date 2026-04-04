# Incident Report: EKS Lab 03: Tasky `CrashLoopBackOff` from secret/URI wiring errors

**Lab source**: [`EKS anonymized lab`](../../../docs/eks-anonymized-interview-lab.md)

## 1) Detection + impact
- Tasky application pods entered `CrashLoopBackOff` after deployment.
- Application tier was unavailable and readiness checks failed.

## 2) Investigation timeline (sanitized)
- Collected pod event evidence with `kubectl describe pod`.
- Reviewed container logs including previous crash context.
- Verified Secret key names and MongoDB URI encoding against application expectations.

## 3) Root cause + trigger
- Secret/env wiring drift: encoded credentials and environment variable names were misaligned with what the application expected.

## 4) Fixes
- Corrected URI credential encoding and aligned environment variable key names with app requirements.

## 5) Verification + prevention
- Pods stabilized and readiness checks recovered.
- Added configuration key-name and URI-format validation to deployment checks.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

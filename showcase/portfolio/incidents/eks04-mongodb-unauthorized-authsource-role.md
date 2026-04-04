# Incident Report: EKS Lab 04: MongoDB `Unauthorized` despite network reachability

**Lab source**: [`EKS anonymized lab`](../../../docs/eks-anonymized-interview-lab.md)

## 1) Detection + impact
- Application-to-database network path was reachable, but MongoDB authentication failed with `Unauthorized`.
- Functional connectivity tests passed while application data operations remained blocked.

## 2) Investigation timeline (sanitized)
- Confirmed transport-level reachability from in-cluster validation steps.
- Reviewed database name, user role mappings, and `authSource` parameters in the connection string.

## 3) Root cause + trigger
- Authentication configuration mismatch: role mapping and connection-string authentication parameters were inconsistent with MongoDB user setup.

## 4) Fixes
- Updated role mapping and corrected `authSource`/connection-string parameters.

## 5) Verification + prevention
- Application authentication to MongoDB succeeded post-change.
- Added a dedicated auth parameter review step when troubleshooting DB access issues.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

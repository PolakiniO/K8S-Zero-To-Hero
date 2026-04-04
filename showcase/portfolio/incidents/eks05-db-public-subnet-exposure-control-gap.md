# Incident Report: EKS Lab 05: Database EC2 placed in public subnet during initial build

**Lab source**: [`EKS anonymized lab`](../../../docs/eks-anonymized-interview-lab.md)

## 1) Detection + impact
- Subnet review identified unintended public-subnet placement for the database EC2 instance.
- Misplacement increased potential exposure risk and required immediate access-scope hardening.

## 2) Investigation timeline (sanitized)
- Reviewed subnet and route-table characteristics for the database instance.
- Audited security group ingress scope for database and SSH access.

## 3) Root cause + trigger
- Initial placement and network-control configuration allowed broader exposure than intended for the database tier.

## 4) Fixes
- Restricted MongoDB ingress to EKS worker-node security group only.
- Restricted SSH ingress to trusted admin CIDR only.
- Removed broad ingress rules.

## 5) Verification + prevention
- Database access scope matched intended trust boundaries after SG tightening.
- Added explicit subnet-placement and SG-scope checks to infrastructure validation.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

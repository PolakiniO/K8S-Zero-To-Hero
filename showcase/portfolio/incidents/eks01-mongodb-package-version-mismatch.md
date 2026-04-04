# Incident Report: EKS Lab 01: MongoDB package/version mismatch on EC2 database host

**Lab source**: [`EKS anonymized lab`](../../../docs/eks-anonymized-interview-lab.md)

## 1) Detection + impact
- MongoDB installation on the EC2 database tier failed during build.
- Database tier readiness was blocked, which prevented full three-tier validation.

## 2) Investigation timeline (sanitized)
- Reviewed package manager error output from the EC2 host.
- Compared MongoDB package/repository version against AMI OS library compatibility.

## 3) Root cause + trigger
- Selected MongoDB package/repository did not match the OS family/runtime dependencies on the chosen AMI.

## 4) Fixes
- Switched to a MongoDB version/repository compatible with the AMI family used in the lab.

## 5) Verification + prevention
- MongoDB installation completed successfully after version alignment.
- Added an explicit compatibility check step before database package installation.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

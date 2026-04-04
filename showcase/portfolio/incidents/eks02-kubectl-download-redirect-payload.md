# Incident Report: EKS Lab 02: `kubectl` download returned redirect/error payload

**Lab source**: [`EKS anonymized lab`](../../../docs/eks-anonymized-interview-lab.md)

## 1) Detection + impact
- Downloaded `kubectl` artifact was invalid and contained error/redirect payload content.
- Cluster administration from the workstation was blocked until a valid binary was retrieved.

## 2) Investigation timeline (sanitized)
- Inspected downloaded file content and noticed non-binary response data.
- Re-validated the endpoint path, target region, and requested version URL.

## 3) Root cause + trigger
- Incorrect download source selection (version/path/region mismatch) returned payload content instead of the expected executable binary.

## 4) Fixes
- Replaced the URL with the correct version-specific, region-correct source.

## 5) Verification + prevention
- `kubectl` executed correctly after replacing the source URL.
- Added a post-download validation check to confirm binary integrity before use.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

# Incident Report: Lab 13: Certificate trust failure and recovery

**Lab source**: [`LabPack` reference](../../../LabPack/week3/lab13/README.md)

## 1) Detection + impact
- TLS connections failed because client trust validation broke.

## 2) Investigation timeline (sanitized)
- Verified cert chain/trust material used by workload.
- Confirmed failure tied to bad CA/cert trust input.

## 3) Root cause + trigger
- Invalid or untrusted certificate authority configuration.

## 4) Fixes
- Replaced trust material with valid CA/certificate data.

## 5) Verification + prevention
- TLS handshake succeeded post-remediation.
- Added cert validity and trust-chain checks to release path.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

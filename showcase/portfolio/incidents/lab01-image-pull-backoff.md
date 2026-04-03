# Incident Report: Lab 1: Pod creation + image pull failure (`ImagePullBackOff`)

**Lab source**: [`LabPack` reference](../../../LabPack/week1/lab1/README.md)

## 1) Detection + impact
- `kubectl get pods` showed the workload stuck in `ImagePullBackOff`.
- No running container meant the service could not start and downstream exercises were blocked.

## 2) Investigation timeline (sanitized)
- Checked pod status and events (`kubectl describe pod`).
- Confirmed image pull errors and invalid image reference format.

## 3) Root cause + trigger
- Incorrect container image name/tag in manifest (human configuration error).

## 4) Fixes
- Corrected image reference to a valid public image/tag.
- Re-applied manifest and verified pull succeeded.

## 5) Verification + prevention
- Pod reached `Running/Ready`.
- Added pre-apply manifest review checklist for image references.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)

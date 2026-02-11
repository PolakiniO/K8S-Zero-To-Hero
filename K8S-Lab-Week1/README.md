# K8S Lab Week 1 (Imported + Normalized)

This directory contains the original Notion export and the YAML manifests used to run Week 1 labs.

## What was updated

- Added this index file so the imported content is easier to navigate.
- Normalized Week 1 YAML manifests to consistent formatting and naming.
- Corrected probe file naming from `liveliness` to `liveness`.
- Kept the original Notion export intact for traceability.

## Directory layout

- `ExportBlock-.../`: Raw Notion markdown export.
- `yaml-files/`: Runnable manifests for each lab scenario.

## YAML manifest quick map

### Lab 2 — RBAC
- `yaml-files/lab2-rbac-fix.yaml`

### Lab 3 — OOMKilled
- `yaml-files/lab3-memhog.yaml` (intentionally constrained)
- `yaml-files/lab3-memhog-fix.yaml` (right-sized memory limit)

### Lab 4 — Probes
- `yaml-files/lab4-broken-liveness-probe.yaml` (broken liveness path)
- `yaml-files/lab4-broken-readiness-probe.yaml` (broken readiness path)
- `yaml-files/lab4-fix-liveness-probe.yaml` (healthy liveness/readiness)
- `yaml-files/lab4-readiness-service.yaml` (service for readiness testing)

### Lab 5 — ConfigMap/Secret
- `yaml-files/lab5-configmap-env-vars.yaml` (healthy baseline)
- `yaml-files/lab5-configmap-broken-env-vars.yaml` (intentional secret typo)
- `yaml-files/lab5-configmap-fix-env-vars.yaml` (fixed secret ref)

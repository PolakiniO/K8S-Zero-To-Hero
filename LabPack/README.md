# Kubernetes LabPack

Week 1 focuses on day-1/day-2 operations and troubleshooting workflows: creating workloads, diagnosing failures, applying least-privilege RBAC, handling OOMKills, probe debugging, and ConfigMap/Secret startup issues.

Week 2 extends to networking, rollout, storage, policy enforcement, and full incident debugging under realistic failure conditions.

## Table of Contents

- [Lab 1 - Pod Creation + Image Failure](week1/lab1/README.md)
- [Lab 2 - Namespaces + RBAC Failure](week1/lab2/README.md)
- [Lab 3 - Requests/Limits + OOMKilled](week1/lab3/README.md)
- [Lab 4 - Liveness + Readiness Probes](week1/lab4/README.md)
- [Lab 5 - ConfigMap and Secret Failures](week1/lab5/README.md)
- [Lab 6 - Label Selector Mismatch](week2/lab6/README.md)
- [Lab 7 - Rolling Update Failure](week2/lab7/README.md)
- [Lab 8 - Storage Failure](week2/lab8/README.md)
- [Lab 9 - NetworkPolicy Failure](week2/lab9/README.md)
- [Lab 10 - Incident Simulation](week2/lab10/README.md)

## Prerequisites

- `kubectl` installed and configured.
- Active Kind (or Kubernetes) context.
- Namespace flow used by these labs:
  - `week1` for Labs 1, 3, 4, 5
  - `development` for Lab 2 RBAC
  - `week2` for Labs 6-10

## How to run

- Apply manifests directly from each lab folder (for example `LabPack/week1/lab4/*.yaml`).
- Optional helpers are available per lab: `LabPack/week1/labX/run.sh`.
- Follow each lab README for ordered commands and validation steps.

## Note on terminal logs

All terminal logs in lab READMEs are real captured outputs from the Notion export already committed in this repository. No synthetic output was added.

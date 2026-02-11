# Kubernetes Week 1 Lab Pack

Week 1 focuses on day-1/day-2 operations and troubleshooting workflows: creating workloads, diagnosing failures, applying least-privilege RBAC, handling OOMKills, probe debugging, and ConfigMap/Secret startup issues.

## Table of Contents

- [Lab 1 - Pod Creation + Image Failure](./lab1/README.md)
- [Lab 2 - Namespaces + RBAC Failure](./lab2/README.md)
- [Lab 3 - Requests/Limits + OOMKilled](./lab3/README.md)
- [Lab 4 - Liveness + Readiness Probes](./lab4/README.md)
- [Lab 5 - ConfigMap and Secret Failures](./lab5/README.md)

## Prerequisites

- `kubectl` installed and configured.
- Active Kind (or Kubernetes) context.
- Namespace flow used by these labs:
  - `week1` for Labs 1, 3, 4, 5
  - `development` for Lab 2 RBAC

## How to run

- Apply manifests directly from each lab folder (for example `k8s/week1/lab4/*.yaml`).
- Optional helpers are available per lab: `k8s/week1/labX/run.sh`.
- Follow each lab README for ordered commands and validation steps.

## Note on terminal logs

All terminal logs in lab READMEs are real captured outputs from the Notion export already committed in this repository. No synthetic output was added.

# Observability Baseline (Current Repository Scope)

This guide documents the observability approach that is **already used in this repository**.

## Goal

Validate incidents with runtime signals, not only manifest diffs:
- pod/container health,
- CPU usage,
- memory usage,
- restart behavior,
- recovery confirmation after a fix.

## What is implemented in this repo

- `metrics-server` is part of capstone platform setup:
  - `Labs/K8S-Lab-Capstone/01-platform/00-metrics-server.yaml`
- operational checks during labs:
  - `kubectl top nodes`
  - `kubectl top pods -n apps`
  - `kubectl get events --sort-by=.metadata.creationTimestamp`

## Standard observability checks during incidents

```bash
kubectl top nodes
kubectl top pods -n apps
kubectl get events -n apps --sort-by=.metadata.creationTimestamp
kubectl get pods -n apps -o wide
```

## How to document metrics evidence in each RCA

For each incident write-up, include:
- Which signal moved first (CPU, memory, restarts, readiness)?
- Which command output confirmed the suspected root cause?
- Which signal confirmed recovery after mitigation/fix?

This keeps incident reports evidence-based and production-relevant while staying aligned with the current repository tooling.

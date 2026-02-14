# Capstone exercise - build a production cluster from a design

## Capstone exercise - build a production-ish cluster from a design

### Goal

You will build a Kubernetes platform from scratch based on a target design, validate it with concrete tests, and write an incident-note style report (same vibe as the labs).

### Design (target state)

Build this on your machine using kind (multi-node) and Calico:

- Cluster
    - kind cluster with 1 control-plane + 2 workers
    - Calico CNI installed
    - Metrics Server installed
- Namespaces and workloads
    - namespaces: platform, apps, monitoring
    - apps namespace: a 3-tier demo app
        - frontend Deployment (2 replicas) exposed via Ingress
        - backend Deployment (2 replicas) internal Service
        - postgres StatefulSet (1 replica) with PVC
- Ingress + TLS
    - Ingress NGINX controller installed
    - a self-signed TLS cert stored as a Secret
    - Ingress routes:
        - / -> frontend
        - /api -> backend
- Network policy (Calico)
    - default deny ingress in apps
    - allow:
        - ingress-nginx -> frontend on 80/443
        - frontend -> backend on 8080
        - backend -> postgres on 5432
    - deny everything else cross-pod in apps
- Observability
    - Prometheus + Grafana via Helm (monitoring namespace)
    - basic dashboard and a couple alerts (CPU high, pod restart loop)
- Reliability behaviors
    - Requests/limits on all pods
    - HPA on frontend (cpu)
    - PDB for frontend
    - Pod anti-affinity for frontend and backend
- Delivery workflow
    - Everything is YAML/Helm values in a repo folder: K8S-Lab-Capstone
    - One script: setup.sh to bootstrap everything
    - One script: verify.sh to run checks and print pass/fail

### What makes it an exercise

You will get scored on:

- correctness (design matches reality)
- debugging (how you react to failures)
- evidence (events, describe output, logs)
- operational habits (rollouts, probes, policies, limits)

## 

[Capstone - Phase 1](Capstone%20-%20Phase%201%203072556d80ae80a8a05fdb9fe48b1045.md)
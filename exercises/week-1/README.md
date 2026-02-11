# Week 1 Labs: Core Operations + Failure Handling

> Objective: Build muscle memory for day-1 and day-2 Kubernetes troubleshooting.

Imported source materials for this week live in `K8S-Lab-Week1/`, including the raw Notion export and runnable YAML files.

## Recommended setup

```bash
kubectl create ns week1 --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace=week1
```

## Lab 1 — Pod Creation + Image Failure

### Tasks
1. Create an `nginx` pod.
2. Change image to a non-existent tag.
3. Observe `ImagePullBackOff`.
4. Diagnose and fix.

### Validation commands
```bash
kubectl get pod web-app
kubectl describe pod web-app
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Source materials
- Notion export: `K8S-Lab-Week1/ExportBlock-.../Lab 1 - Pod creation + image failure ...md`

---

## Lab 2 — Namespaces + RBAC Failure

### Tasks
1. Create namespace `development`.
2. Create a service account with insufficient permissions.
3. Trigger a forbidden operation.
4. Apply role and rolebinding remediation.

### Validation commands
```bash
kubectl auth can-i get pods --as=system:serviceaccount:development:dev-sa -n development
kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
```

### Manifest
- `K8S-Lab-Week1/yaml-files/lab2-rbac-fix.yaml`

---

## Lab 3 — Requests/Limits + OOMKilled

### Tasks
1. Deploy memory-constrained workload.
2. Force memory growth.
3. Observe `OOMKilled` reason.
4. Right-size resource profile.

### Validation commands
```bash
kubectl describe pod memhog
kubectl top pod memhog
```

### Manifests
- `K8S-Lab-Week1/yaml-files/lab3-memhog.yaml`
- `K8S-Lab-Week1/yaml-files/lab3-memhog-fix.yaml`

> Note: `kubectl top` requires Metrics Server.

---

## Lab 4 — Liveness + Readiness Probes

### Tasks
1. Apply broken liveness probe and watch restarts.
2. Apply broken readiness probe and verify service endpoint gating.
3. Fix probe paths and timing.

### Validation commands
```bash
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
kubectl get endpoints probe-svc -w
```

### Manifests
- `K8S-Lab-Week1/yaml-files/lab4-broken-liveness-probe.yaml`
- `K8S-Lab-Week1/yaml-files/lab4-broken-readiness-probe.yaml`
- `K8S-Lab-Week1/yaml-files/lab4-fix-liveness-probe.yaml`
- `K8S-Lab-Week1/yaml-files/lab4-readiness-service.yaml`

---

## Lab 5 — ConfigMap and Secret Failures

### Tasks
1. Create ConfigMap and Secret.
2. Inject values as env vars.
3. Break secret reference intentionally.
4. Restore and verify startup.

### Validation commands
```bash
kubectl describe pod cfg-demo
kubectl logs cfg-demo
```

### Manifests
- `K8S-Lab-Week1/yaml-files/lab5-configmap-env-vars.yaml`
- `K8S-Lab-Week1/yaml-files/lab5-configmap-broken-env-vars.yaml`
- `K8S-Lab-Week1/yaml-files/lab5-configmap-fix-env-vars.yaml`

---

## Reflection prompt
For each lab, capture:
- Failure symptom
- First command used and why
- Root cause
- Fix
- Prevention step

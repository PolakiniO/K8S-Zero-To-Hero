# Week 1 Labs: Core Operations + Failure Handling

> Objective: Build muscle memory for day-1 and day-2 Kubernetes troubleshooting.

## Lab 1 — Pod Creation + Image Failure

### Tasks
1. Create an `nginx` pod.
2. Change image to a non-existent tag.
3. Observe `ImagePullBackOff`.
4. Diagnose and fix.

### Validation Commands
```bash
kubectl get pod web-app
kubectl describe pod web-app
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Expected Learning
- Event-driven diagnosis before changing config.

---

## Lab 2 — Namespaces + RBAC Failure

### Tasks
1. Create namespace `development`.
2. Create a service account with insufficient permissions.
3. Trigger forbidden operation.
4. Create Role/RoleBinding to remediate.

### Validation Commands
```bash
kubectl auth can-i get pods --as=system:serviceaccount:development:dev-sa -n development
```

---

## Lab 3 — Requests/Limits + OOMKilled

### Tasks
1. Deploy memory-constrained workload.
2. Force memory growth.
3. Observe `OOMKilled` reason.
4. Right-size resource profile.

### Validation Commands
```bash
kubectl describe pod <pod>
kubectl top pod <pod>
```

---

## Lab 4 — Liveness + Readiness Probes

### Tasks
1. Add liveness probe with broken path.
2. Observe restart loop.
3. Fix probe path and timing.
4. Add readiness probe to gate traffic.

### Validation Commands
```bash
kubectl describe pod <pod>
kubectl get pod <pod> -w
```

---

## Lab 5 — ConfigMap and Secret Failures

### Tasks
1. Create ConfigMap and Secret.
2. Inject as env vars.
3. Break secret reference intentionally.
4. Restore and verify startup.

### Validation Commands
```bash
kubectl describe pod <pod>
kubectl logs <pod>
```

---

## Reflection Prompt
For each lab, write:
- Failure symptom
- First command used and why
- Root cause
- Fix
- Prevention step

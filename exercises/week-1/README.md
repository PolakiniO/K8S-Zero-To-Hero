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

### Walkthrough (example + tips)
**Example flow**
```bash
kubectl run web-app --image=nginx:1.25 --restart=Never
kubectl delete pod web-app --ignore-not-found
kubectl run web-app --image=nginx:1.25-DoNotExist --restart=Never
kubectl describe pod web-app
kubectl set image pod/web-app web-app=nginx:1.25
```

**What to look for**
- In `describe`, confirm `ErrImagePull` / `ImagePullBackOff` and the exact image reference that failed.
- In `events`, sort by timestamp to see the failure timeline instead of guessing.

**Tips**
- Always diagnose from events first; fix only after you can state the exact failing image/tag.
- `kubectl set image` is faster than recreating a pod when you only need to correct the image.

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

### Walkthrough (example + tips)
**Example flow**
```bash
kubectl create ns development
kubectl -n development create sa dev-sa
kubectl auth can-i get pods --as=system:serviceaccount:development:dev-sa -n development
kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
kubectl apply -f K8S-Lab-Week1/yaml-files/lab2-rbac-fix.yaml
kubectl auth can-i list pods --as=system:serviceaccount:development:dev-sa -n development
```

**What to look for**
- `can-i` should move from `no` to `yes` after RoleBinding is applied.
- Forbidden errors should include the exact user + verb + resource; use that tuple to write RBAC rules.

**Tips**
- Run `kubectl auth can-i` before and after RBAC changes as a quick preflight.
- Scope roles narrowly (`get/list/watch` on `pods`) before adding broader access.

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

### Walkthrough (example + tips)
**Example flow**
```bash
kubectl apply -f K8S-Lab-Week1/yaml-files/lab3-memhog.yaml
kubectl get pod memhog -w
kubectl describe pod memhog
kubectl delete pod memhog
kubectl apply -f K8S-Lab-Week1/yaml-files/lab3-memhog-fix.yaml
kubectl get pod memhog
```

**What to look for**
- `describe` should show `Last State: Terminated`, `Reason: OOMKilled`, and exit code `137`.
- If metrics are available, memory should climb toward the limit before restarts.

**Tips**
- Requests affect scheduling; limits are enforcement caps. Tune both, not just one.
- If `kubectl top` is unavailable, rely on `describe` + restart patterns to confirm OOM behavior.

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

### Walkthrough (example + tips)
**Example flow**
```bash
kubectl apply -f K8S-Lab-Week1/yaml-files/lab4-broken-liveness-probe.yaml
kubectl describe pod probe-demo
kubectl delete pod probe-demo
kubectl apply -f K8S-Lab-Week1/yaml-files/lab4-fix-liveness-probe.yaml
kubectl apply -f K8S-Lab-Week1/yaml-files/lab4-readiness-service.yaml
kubectl get endpoints probe-svc -w
```

**What to look for**
- Broken liveness: restart count rises; events show liveness failures and container kills.
- Broken readiness: pod stays `Running` but `READY` becomes `0/1`; service endpoints become empty.

**Tips**
- Pods cannot patch most probe fields in-place; recreate pod (or use Deployments in real workloads).
- Liveness answers "should I restart?"; readiness answers "should I receive traffic?".

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

### Walkthrough (example + tips)
**Example flow**
```bash
kubectl create configmap app-cm --from-literal=APP_MODE=dev
kubectl create secret generic app-secret --from-literal=API_KEY=supersecret
kubectl apply -f K8S-Lab-Week1/yaml-files/lab5-configmap-env-vars.yaml
kubectl logs cfg-demo
kubectl delete pod cfg-demo
kubectl apply -f K8S-Lab-Week1/yaml-files/lab5-configmap-broken-env-vars.yaml
kubectl describe pod cfg-demo
kubectl delete pod cfg-demo
kubectl apply -f K8S-Lab-Week1/yaml-files/lab5-configmap-fix-env-vars.yaml
```

**What to look for**
- Broken secret reference should produce `CreateContainerConfigError` before the app starts.
- `describe` events usually identify the exact missing secret/configmap key or name.

**Tips**
- Validate object names (`kubectl get cm,secret`) before applying pod specs.
- Keep the healthy and broken manifests side-by-side to speed up root-cause comparison.

---

## Reflection prompt
For each lab, capture:
- Failure symptom
- First command used and why
- Root cause
- Fix
- Prevention step

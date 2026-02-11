# K8S Lab Week 1 (Imported + Normalized)

This directory contains the original Notion export and the YAML manifests used to run Week 1 labs.

## What was updated

- Added this index file so the imported content is easier to navigate.
- Normalized Week 1 YAML manifests to consistent formatting and naming.
- Corrected probe file naming from `liveliness` to `liveness`.
- Kept the original Notion export intact for traceability.

## Directory layout

- `ExportBlock-.../`: Raw Notion markdown export.
- `LabPack/week1/`: Canonical runnable manifests for each lab scenario (outside this folder).

## Optional namespace context (used in examples)

```bash
kubectl create ns week1
kubectl config set-context --current --namespace=week1
```

### Example output
```text
namespace/week1 created
Context "kind-kind" modified.
```

---

## YAML manifest quick map

### Lab 2 — RBAC
- `LabPack/week1/lab2/lab2-rbac-fix.yaml`

### Lab 3 — OOMKilled
- `LabPack/week1/lab3/lab3-memhog.yaml` (intentionally constrained)
- `LabPack/week1/lab3/lab3-memhog-fix.yaml` (right-sized memory limit)

### Lab 4 — Probes
- `LabPack/week1/lab4/lab4-broken-liveness-probe.yaml` (broken liveness path)
- `LabPack/week1/lab4/lab4-broken-readiness-probe.yaml` (broken readiness path)
- `LabPack/week1/lab4/lab4-fix-liveness-probe.yaml` (healthy liveness/readiness)
- `LabPack/week1/lab4/lab4-readiness-service.yaml` (service for readiness testing)

### Lab 5 — ConfigMap/Secret
- `LabPack/week1/lab5/lab5-configmap-env-vars.yaml` (healthy baseline and fix manifest)
- `LabPack/week1/lab5/lab5-configmap-broken-env-vars.yaml` (intentional secret typo)

---

## Commands + expected output (based on Notion run logs)

## Lab 1 — Pod creation + image failure

### 1) Create a working pod
```bash
kubectl run web-app --image=nginx:1.25 --restart=Never
kubectl get pod web-app -w
```

### Example output
```text
pod/web-app created
NAME      READY   STATUS              RESTARTS   AGE
web-app   0/1     ContainerCreating   0          6s
web-app   1/1     Running             0          28s
```

### 2) Break it with a non-existing image tag
```bash
kubectl delete pod web-app --ignore-not-found
kubectl run web-app --image=nginx:1.25-DoNotExist --restart=Never
kubectl get pod web-app
kubectl describe pod web-app
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Example output
```text
pod/web-app created
NAME      READY   STATUS         RESTARTS   AGE
web-app   0/1     ErrImagePull   0          32s
...
Warning  Failed   ...   Error: ErrImagePull
Warning  Failed   ...   Error: ImagePullBackOff
```

### 3) Fix and verify
```bash
kubectl set image pod/web-app web-app=nginx:1.25 -n week1
kubectl get pod web-app -w
kubectl describe pod web-app
```

### Example output
```text
pod/web-app image updated
NAME      READY   STATUS    RESTARTS   AGE
web-app   1/1     Running   0          10s
```

---

## Lab 2 — Namespaces + RBAC failure

### 1) Create namespace and service account
```bash
kubectl create ns development
kubectl -n development create sa dev-sa
```

### Example output
```text
namespace/development created
serviceaccount/dev-sa created
```

### 2) Reproduce forbidden error
```bash
kubectl auth can-i get pods --as=system:serviceaccount:development:dev-sa -n development
kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
```

### Example output
```text
no
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:development:dev-sa" cannot list resource "pods" in API group "" in the namespace "development"
```

### 3) Apply fix and validate
```bash
kubectl apply -f LabPack/week1/lab2/lab2-rbac-fix.yaml
kubectl auth can-i list pods --as=system:serviceaccount:development:dev-sa -n development
kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
```

### Example output
```text
role.rbac.authorization.k8s.io/pod-reader created
rolebinding.rbac.authorization.k8s.io/dev-sa-pod-reader created
yes
No resources found in development namespace.
```

---

## Lab 3A — Extra lab: Fix metrics-server (`kubectl top` not working)

> This is one of the extra labs from the Notion files and is required before reliable `kubectl top` checks.

### 1) Install metrics-server
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Example output
```text
serviceaccount/metrics-server created
deployment.apps/metrics-server created
apiservice/apiregistration.k8s.io/v1beta1.metrics.k8s.io created
```

### 2) Diagnose why metrics are still unavailable
```bash
kubectl get pods -n kube-system | grep metrics
kubectl logs -n kube-system deployment/metrics-server
```

### Example output
```text
metrics-server-xxxxx   0/1   Running   ...
...
tls: failed to verify certificate
cannot validate certificate because it doesn't contain any IP SANs
```

### 3) Fix deployment and restart
```bash
kubectl -n kube-system edit deployment metrics-server
# add this arg under container args:
# --kubelet-insecure-tls
kubectl -n kube-system rollout restart deployment metrics-server
kubectl -n kube-system rollout status deployment metrics-server
kubectl get pods -n kube-system | grep metrics
```

### Example output
```text
deployment.apps/metrics-server restarted
deployment "metrics-server" successfully rolled out
metrics-server-xxxxx   1/1   Running   ...
```

### 4) Validate metrics API
```bash
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top nodes
kubectl top pods -n week1
```

### Example output
```text
NAME                     SERVICE                      AVAILABLE   AGE
v1beta1.metrics.k8s.io   kube-system/metrics-server   True        ...

NAME               CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
lab-control-plane  250m         12%    1500Mi          40%
```

---

## Lab 3B — Requests/Limits + OOMKilled

### 1) Deploy constrained workload
```bash
kubectl apply -f LabPack/week1/lab3/lab3-memhog.yaml
kubectl get pod memhog -w
```

### Example output
```text
pod/memhog created
NAME     READY   STATUS              RESTARTS   AGE
memhog   0/1     ContainerCreating   0          9s
memhog   1/1     Running             0          24s
memhog   0/1     OOMKilled           0          28s
memhog   0/1     CrashLoopBackOff    1          45s
```

### 2) Observe memory and confirm OOM
```bash
kubectl top pod memhog -n week1
kubectl describe pod memhog
```

### Example output
```text
NAME     CPU(cores)   MEMORY(bytes)
memhog   14m          4Mi
...
Last State:   Terminated
Reason:       OOMKilled
Exit Code:    137
```

### 3) Apply fixed resources and re-validate
```bash
kubectl delete pod memhog
kubectl apply -f LabPack/week1/lab3/lab3-memhog-fix.yaml
kubectl get pod memhog -w
kubectl top pod memhog -n week1
```

### Example output
```text
pod "memhog" deleted
pod/memhog created
NAME     READY   STATUS    RESTARTS   AGE
memhog   1/1     Running   0          8s
```

---

## Lab 4 — Liveness + Readiness probes

### 1) Break liveness and observe restarts
```bash
kubectl apply -f LabPack/week1/lab4/lab4-broken-liveness-probe.yaml
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
```

### Example output
```text
pod/probe-demo created
NAME         READY   STATUS    RESTARTS   AGE
probe-demo   1/1     Running   2          34s
...
Warning  Unhealthy  ...  Liveness probe failed: HTTP probe failed with statuscode: 404
Normal   Killing    ...  Container nginx failed liveness probe, will be restarted
```

### 2) Fix liveness/readiness and verify
```bash
kubectl delete pod probe-demo
kubectl apply -f LabPack/week1/lab4/lab4-fix-liveness-probe.yaml
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
```

### Example output
```text
pod "probe-demo" deleted
pod/probe-demo created
NAME         READY   STATUS    RESTARTS   AGE
probe-demo   1/1     Running   0          12s
```

### 3) Create service and verify ready endpoints
```bash
kubectl apply -f LabPack/week1/lab4/lab4-readiness-service.yaml
kubectl get endpoints probe-svc -w
```

### Example output
```text
service/probe-svc created
NAME        ENDPOINTS        AGE
probe-svc   10.244.0.18:80   80s
```

### 4) Break readiness only and confirm endpoint removal
```bash
kubectl delete pod probe-demo
kubectl apply -f LabPack/week1/lab4/lab4-broken-readiness-probe.yaml
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
kubectl get endpoints probe-svc -w
```

### Example output
```text
pod/probe-demo created
NAME         READY   STATUS    RESTARTS   AGE
probe-demo   0/1     Running   0          12s
...
Warning  Unhealthy  ...  Readiness probe failed: HTTP probe failed with statuscode: 404
NAME        ENDPOINTS   AGE
probe-svc               7m32s
```

---

## Lab 5 — ConfigMap and Secret failures

### 0) Clean slate
```bash
kubectl delete pod cfg-demo --ignore-not-found
kubectl delete configmap app-cm --ignore-not-found
kubectl delete secret app-secret --ignore-not-found
```

### Example output
```text
pod "cfg-demo" deleted
configmap "app-cm" deleted
secret "app-secret" deleted
```

### 1) Create ConfigMap + Secret
```bash
kubectl create configmap app-cm --from-literal=APP_MODE=dev
kubectl create secret generic app-secret --from-literal=API_KEY=supersecret
kubectl get configmap app-cm -o yaml
kubectl get secret app-secret -o yaml
```

### Example output
```text
configmap/app-cm created
secret/app-secret created
...
data:
  APP_MODE: dev
...
data:
  API_KEY: c3VwZXJzZWNyZXQ=
```

### 2) Healthy env injection
```bash
kubectl apply -f LabPack/week1/lab5/lab5-configmap-env-vars.yaml
kubectl get pod cfg-demo -w
kubectl logs cfg-demo
kubectl describe pod cfg-demo
```

### Example output
```text
pod/cfg-demo created
NAME       READY   STATUS    RESTARTS   AGE
cfg-demo   1/1     Running   0          16s
APP_MODE=dev
API_KEY=supersecret
```

### 3) Break secret reference intentionally
```bash
kubectl delete pod cfg-demo
kubectl apply -f LabPack/week1/lab5/lab5-configmap-broken-env-vars.yaml
kubectl get pod cfg-demo -w
kubectl describe pod cfg-demo
kubectl logs cfg-demo
```

### Example output
```text
pod/cfg-demo created
NAME       READY   STATUS                       RESTARTS   AGE
cfg-demo   0/1     CreateContainerConfigError   0          12s
...
Warning  Failed  ...  Error: secret "app-secret-typo" not found
Error from server (BadRequest): container "app" in pod "cfg-demo" is waiting to start: CreateContainerConfigError
```

### 4) Fix secret reference and verify
```bash
kubectl delete pod cfg-demo
kubectl apply -f LabPack/week1/lab5/lab5-configmap-env-vars.yaml
kubectl get pod cfg-demo -w
kubectl logs cfg-demo
kubectl describe pod cfg-demo
```

### Example output
```text
pod/cfg-demo created
NAME       READY   STATUS    RESTARTS   AGE
cfg-demo   1/1     Running   0          11s
APP_MODE=dev
API_KEY=supersecret
```

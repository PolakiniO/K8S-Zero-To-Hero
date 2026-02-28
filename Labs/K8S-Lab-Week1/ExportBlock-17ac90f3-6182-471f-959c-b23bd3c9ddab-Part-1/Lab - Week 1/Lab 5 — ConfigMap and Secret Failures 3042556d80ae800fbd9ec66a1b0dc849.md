# Lab 5 — ConfigMap and Secret Failures

# Lab 5 - ConfigMap and Secret Failures

### Tasks

1. Create ConfigMap and Secret
2. Inject as env vars
3. Break secret reference intentionally
4. Restore and verify startup

### Validation Commands

```bash
kubectl describe pod <pod>
kubectl logs <pod>
```

---

## Step 0 - Clean slate

```bash
kubectl delete pod cfg-demo --ignore-not-found
kubectl delete configmap app-cm --ignore-not-found
kubectl delete secret app-secret --ignore-not-found
```

### Terminal Log

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl delete pod cfg-demo --ignore-not-found
kubectl delete configmap app-cm --ignore-not-found
kubectl delete secret app-secret --ignore-not-found
```

---

## Step 1 - Create ConfigMap and Secret

```bash
kubectl create configmap app-cm --from-literal=APP_MODE=dev
kubectl create secret generic app-secret --from-literal=API_KEY=EXAMPLE_NOT_A_REAL_SECRET
```

### Validate

```bash
kubectl get configmap app-cm -o yaml
kubectl get secret app-secret -o yaml
```

### Terminal Log

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl create configmap app-cm --from-literal=APP_MODE=dev
configmap/app-cm created

polakinio@Polakinio:~/Projects/k8s/week1$ kubectl create secret generic app-secret --from-literal=API_KEY=EXAMPLE_NOT_A_REAL_SECRET
secret/app-secret created

polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get configmap app-cm -o yaml
apiVersion: v1
data:
  APP_MODE: dev
kind: ConfigMap
metadata:
  creationTimestamp:"2026-02-11T15:43:36Z"
  name: app-cm
  namespace: week1
  resourceVersion:"16032"
  uid: 20d23383-8fcf-4c75-b5a3-1e29254a78e9

polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get secret app-secret -o yaml
apiVersion: v1
data:
  API_KEY: <BASE64_ENCODED_EXAMPLE_PLACEHOLDER>
kind: Secret
metadata:
  creationTimestamp:"2026-02-11T15:44:22Z"
  name: app-secret
  namespace: week1
  resourceVersion:"16093"
  uid: cc39b043-d785-47f6-baa6-78f36a964115type: Opaque
```

---

## Step 2 - Inject as env vars and verify startup

Apply pod manifest:

```bash
kubectl apply -f lab5-configmap-env-vars.yaml
```

Validate:

```bash
kubectl get pod cfg-demo -w
kubectl logs cfg-demo
kubectl describe pod cfg-demo
```

### Terminal Log

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab5-configmap-env-vars.yaml
pod/cfg-demo created

polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pod cfg-demo -w
NAME       READY   STATUS    RESTARTS   AGE
cfg-demo   1/1     Running   0          16s

polakinio@Polakinio:~/Projects/k8s/week1$ kubectl logs cfg-demo
APP_MODE=dev
API_KEY=EXAMPLE_NOT_A_REAL_SECRET
```

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl describe pod cfg-demo
...
State:          Running
Ready:          True
Restart Count:  0
Environment:
  APP_MODE:  <set to the key'APP_MODE' of config map'app-cm'>
  API_KEY:   <set to the key'API_KEY'in secret'app-secret'>
Events:
  Normal  Scheduled
  Normal  Pulled
  Normal  Created
  Normal  Started
```

---

## Step 3 - Break secret reference intentionally

Delete and apply broken manifest:

```bash
kubectl delete pod cfg-demo
kubectl apply -f lab5-configmap-broken-env-vars.yaml
```

Validate:

```bash
kubectl get pod cfg-demo -w
kubectl describe pod cfg-demo
kubectl logs cfg-demo
```

### Terminal Log

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab5-configmap-broken-env-vars.yaml
pod/cfg-demo created

polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pod cfg-demo -w
NAME       READY   STATUS                       RESTARTS   AGE
cfg-demo   0/1     CreateContainerConfigError   0          12s
```

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl describe pod cfg-demo
State: Waiting
Reason: CreateContainerConfigError

Events:
Warning  Failed  Error: secret"app-secret-typo" not found
```

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl logs cfg-demo
Error from server (BadRequest): container"app"in pod"cfg-demo" is waiting to start: CreateContainerConfigError
```

---

## Step 4 - Restore and verify startup

```bash
kubectl delete pod cfg-demo
kubectl apply -f lab5-configmap-fix-env-vars.yaml
```

Validate:

```bash
kubectl get pod cfg-demo -w
kubectl logs cfg-demo
kubectl describe pod cfg-demo
```

### Terminal Log

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab5-configmap-fix-env-vars.yaml
pod/cfg-demo created

polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pod cfg-demo -w
NAME       READY   STATUS    RESTARTS   AGE
cfg-demo   1/1     Running   0          11s
```

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl logs cfg-demo
APP_MODE=dev
API_KEY=EXAMPLE_NOT_A_REAL_SECRET
```

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl describe pod cfg-demo
State: Running
Ready: True
Restart Count: 0
Events:
  Normal  Scheduled
  Normal  Pulled
  Normal  Created
  Normal  Started
```

---

## Reflection (your actual run)

Failure symptom

- Pod stuck in CreateContainerConfigError
- Container never started

First command used and why

- kubectl describe pod cfg-demo to inspect events and environment references

Root cause

- Secret name typo: app-secret-typo

Fix

- Restore correct secret reference

Prevention

- Validate secret and configmap names with kubectl get before applying manifests
- Use Deployment instead of raw Pods to simplify rollbacks
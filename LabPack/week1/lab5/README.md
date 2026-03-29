# Lab 5 - ConfigMap and Secret Failures

## Tasks

1. Create ConfigMap and Secret.
2. Inject env vars and validate logs.
3. Break secret reference intentionally.
4. Restore and verify running state.

## Validation Commands

```bash
kubectl describe pod cfg-demo
kubectl logs cfg-demo
kubectl get pod cfg-demo -w
```

## Step 0 - clean slate

```bash
kubectl delete pod cfg-demo --ignore-not-found
kubectl delete configmap app-cm --ignore-not-found
kubectl delete secret app-secret --ignore-not-found
```

Terminal log:

```bash
$ kubectl delete pod cfg-demo --ignore-not-found
kubectl delete configmap app-cm --ignore-not-found
kubectl delete secret app-secret --ignore-not-found
```

## Step 1 - Create ConfigMap + Secret and validate YAML

```bash
kubectl create configmap app-cm --from-literal=APP_MODE=dev
kubectl create secret generic app-secret --from-literal=API_KEY=EXAMPLE_NOT_A_REAL_SECRET
kubectl get configmap app-cm -o yaml
kubectl get secret app-secret -o yaml
```

Terminal log:

```bash
$ kubectl create configmap app-cm --from-literal=APP_MODE=dev
configmap/app-cm created

$ kubectl create secret generic app-secret --from-literal=API_KEY=EXAMPLE_NOT_A_REAL_SECRET
secret/app-secret created

$ kubectl get configmap app-cm -o yaml
apiVersion: v1
data:
  APP_MODE: dev
kind: ConfigMap
...

$ kubectl get secret app-secret -o yaml
apiVersion: v1
data:
  API_KEY: <BASE64_ENCODED_EXAMPLE_PLACEHOLDER>
kind: Secret
...
```

## Step 2 - Inject env vars and verify logs

```bash
kubectl apply -f lab5-configmap-env-vars.yaml
kubectl get pod cfg-demo -w
kubectl logs cfg-demo
kubectl describe pod cfg-demo
```

Terminal log:

```bash
$ kubectl apply -f lab5-configmap-env-vars.yaml
pod/cfg-demo created

$ kubectl get pod cfg-demo -w
NAME       READY   STATUS    RESTARTS   AGE
cfg-demo   1/1     Running   0          16s

$ kubectl logs cfg-demo
APP_MODE=dev
API_KEY=EXAMPLE_NOT_A_REAL_SECRET
```

## Step 3 - Break secret reference (CreateContainerConfigError)

```bash
kubectl apply -f lab5-configmap-broken-env-vars.yaml
kubectl get pod cfg-demo -w
kubectl describe pod cfg-demo
kubectl logs cfg-demo
```

Terminal log:

```bash
$ kubectl apply -f lab5-configmap-broken-env-vars.yaml
pod/cfg-demo created

$ kubectl get pod cfg-demo -w
NAME       READY   STATUS                       RESTARTS   AGE
cfg-demo   0/1     CreateContainerConfigError   0          12s

$ kubectl describe pod cfg-demo
State: Waiting
Reason: CreateContainerConfigError

Events:
Warning  Failed  Error: secret"app-secret-typo" not found

$ kubectl logs cfg-demo
Error from server (BadRequest): container"app"in pod"cfg-demo" is waiting to start: CreateContainerConfigError
```

## Step 4 - Restore and verify running

```bash
kubectl apply -f lab5-configmap-env-vars.yaml
kubectl get pod cfg-demo -w
kubectl logs cfg-demo
kubectl describe pod cfg-demo
```

Terminal log:

```bash
$ kubectl apply -f lab5-configmap-env-vars.yaml
pod/cfg-demo created

$ kubectl get pod cfg-demo -w
NAME       READY   STATUS    RESTARTS   AGE
cfg-demo   1/1     Running   0          11s

$ kubectl logs cfg-demo
APP_MODE=dev
API_KEY=EXAMPLE_NOT_A_REAL_SECRET
```

## Reflection

- Failure symptom: Pod stuck in `CreateContainerConfigError`.
- First command used and why: `kubectl describe pod cfg-demo` to read failure events for env source references.
- Root cause: Secret name typo (`app-secret-typo`).
- Fix: Restore secret reference via `lab5-configmap-env-vars.yaml`.
- Prevention step: Verify ConfigMap/Secret names with `kubectl get` before applying pod specs.

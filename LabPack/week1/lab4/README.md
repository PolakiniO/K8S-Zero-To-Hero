# Lab 4 - Liveness + Readiness Probes

## Tasks

1. Add liveness probe with broken path.
2. Observe restart loop evidence.
3. Fix liveness + readiness probes.
4. Validate service/endpoints gating.
5. Break readiness only and handle immutable Pod update error.

## Validation Commands

```bash
kubectl describe pod probe-demo
kubectl get pod probe-demo -w
kubectl get endpoints probe-svc -w
```

## Step 0 - clean slate

```bash
kubectl delete pod probe-demo --ignore-not-found -n week1
kubectl delete svc probe-svc --ignore-not-found -n week1
```

Terminal log:

```bash
TODO: No explicit clean-slate output captured for Lab 4.
```

## Step 1 - Broken liveness probe (restart loop)

```bash
kubectl apply -f lab4-broken-liveness-probe.yaml
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
```

Terminal log:

```bash
$ kubectl apply -f lab4-broken-liveness-probe.yaml
pod/probe-demo created
...
Warning  Unhealthy  5s (x2 over 10s)  kubelet  Liveness probe failed: HTTP probe failed with statuscode: 404
Normal   Killing    5s                kubelet  Container nginx failed liveness probe, will be restarted
...
probe-demo   1/1     Running   3 (2s ago)   47s
```

## Step 2 - Fix liveness + readiness

```bash
kubectl delete pod probe-demo
kubectl apply -f lab4-fix-liveness-probe.yaml
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
```

Terminal log:

```bash
$ kubectl delete pod probe-demo
pod "probe-demo" deleted
$ kubectl apply -f lab4-fix-liveness-probe.yaml
pod/probe-demo created
...
probe-demo   1/1     Running   0          12s
...
Liveness:       http-get http://:80/ delay=15s timeout=1s period=10s #success=1 #failure=3
Readiness:      http-get http://:80/ delay=3s timeout=1s period=5s #success=1 #failure=2
```

## Step 3 - Service + endpoints readiness gating

```bash
kubectl apply -f lab4-readiness-service.yaml
kubectl get endpoints probe-svc -w
```

Terminal log:

```bash
$ kubectl apply -f lab4-readiness-service.yaml
service/probe-svc created
$ kubectl get endpoints probe-svc -w
NAME        ENDPOINTS        AGE
probe-svc   10.244.xxx.xxx:80   80s
```

## Step 4 - Broken readiness only + immutable Pod update error

```bash
kubectl apply -f lab4-broken-readiness-probe.yaml
kubectl delete pod probe-demo
kubectl apply -f lab4-broken-readiness-probe.yaml
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
kubectl get endpoints probe-svc -w
```

Terminal log:

```bash
$ kubectl apply -f lab4-broken-readiness-probe.yaml
The Pod "probe-demo" is invalid: spec: Forbidden: pod updates may not change fields other than `spec.containers[*].image`,`spec.initContainers[*].image`,`spec.activeDeadlineSeconds`,`spec.tolerations` (only additions to existing tolerations),`spec.terminationGracePeriodSeconds` (allow it to be set to 1 if it was previously negative)
...
$ kubectl delete pod probe-demo
pod "probe-demo" deleted
$ kubectl apply -f lab4-broken-readiness-probe.yaml
pod/probe-demo created
...
probe-demo   0/1     Running   0          12s
...
Warning  Unhealthy  ...  Readiness probe failed: HTTP probe failed with statuscode: 404
...
probe-svc               7m32s
```

## Reflection

- Failure symptom: Restart loop on bad liveness; `0/1 Running` with empty service endpoints on bad readiness.
- First command used and why: `kubectl describe pod probe-demo` to inspect probe configuration and event failures.
- Root cause: Invalid probe path (`/broken`) and attempted immutable Pod spec update.
- Fix: Delete/recreate pod for probe spec changes; use valid `/` path for healthy probes.
- Prevention step: Use Deployments for safe rollout of probe changes and validate endpoints as readiness signal.

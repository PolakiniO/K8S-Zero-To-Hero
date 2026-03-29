# Lab 3 - Requests/Limits + OOMKilled

## Tasks

1. Deploy memory constrained workload.
2. Observe crash/restart behavior and OOMKilled (`137`).
3. Right-size resources.
4. Verify stabilization.

## Validation Commands

```bash
kubectl get pod memhog -w
kubectl top pod memhog -n week1
kubectl describe pod memhog
```

## Step 0 - clean slate

```bash
kubectl delete pod memhog --ignore-not-found -n week1
```

Terminal log:

```bash
TODO: No explicit Lab 3 clean-slate log in the Notion export.
```

## Step 1 - Deploy constrained pod

```bash
kubectl apply -f lab3-memhog.yaml
kubectl get pod memhog -w
```

Terminal log:

```bash
$ kubectl apply -f lab3-memhog.yaml
pod/memhog created
$ kubectl get pod memhog -w
NAME     READY   STATUS              RESTARTS   AGE
memhog   0/1     ContainerCreating   0          9s
memhog   1/1     Running             0          24s
memhog   0/1     OOMKilled           0          28s
memhog   1/1     Running             1 (1s ago)   29s
memhog   0/1     OOMKilled           1 (5s ago)   33s
memhog   0/1     CrashLoopBackOff    1 (12s ago)   45s
```

## Step 2 - Observe with kubectl top

```bash
while true; do kubectl top pod memhog -n week1; sleep 1; done
```

Terminal log:

```bash
$ while true; do kubectl top pod memhog -n week1; sleep 1; done
Error from server (NotFound): pods "memhog" not found
...
NAME     CPU(cores)   MEMORY(bytes)
memhog   14m          4Mi
...
^C
$
```

## Step 3 - Confirm OOMKilled reason 137

```bash
kubectl describe pod memhog
```

Terminal log:

```bash
$ kubectl describe pod memhog
...
Last State:     Terminated
  Reason:       OOMKilled
  Exit Code:    137
...
$ /path/to/repo
```

## Step 4 - Right-size resources and verify

```bash
kubectl delete pod memhog
kubectl apply -f lab3-memhog-fix.yaml
kubectl get pod memhog -w
while true; do kubectl top pod memhog -n week1; sleep 1; done
```

Terminal log:

```bash
$ kubectl delete pod memhog
pod "memhog" deleted
$ kubectl apply -f lab3-memhog-fix.yaml
pod/memhog created
$ kubectl get pod memhog -w
NAME     READY   STATUS    RESTARTS   AGE
memhog   1/1     Running   0          8s
^C
...
NAME     CPU(cores)   MEMORY(bytes)
memhog   105m         242Mi
```

## Reflection

- Failure symptom: Pod entered `OOMKilled` and `CrashLoopBackOff`.
- First command used and why: `kubectl get pod memhog -w` to see live state transitions and restart behavior.
- Root cause: Memory limit too low for workload growth.
- Fix: Apply `lab3-memhog-fix.yaml` with higher memory limit.
- Prevention step: Set realistic requests/limits and baseline with metrics before production rollout.

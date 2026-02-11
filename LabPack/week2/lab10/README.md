# Lab 10 - Incident Simulation (Pod running but broken)

## Tasks

1. Deploy an app that starts but fails internally.
2. Observe pod is Running but application behavior is broken.
3. Use logs, exec, and describe to find root cause.
4. Fix using ConfigMap and verify.

## Validation Commands

```bash
kubectl logs incident-demo
kubectlexec -it incident-demo -- sh
kubectl describe pod incident-demo
```

## Expected Learning

- Running does not mean healthy.
- Incident workflow: logs -> describe -> exec -> fix -> re-validate.

## Interview Phrase

I treated it as an incident investigation.

## Step 1 - Clean start

```bash
kubectl delete pod incident-demo --ignore-not-found
```

Terminal log:

```bash
(nooutput - pod didnot exist)
```

## Step 2 - Deploy broken application

```bash
kubectl apply -f lab10-broken.yaml
kubectl get pods -w
```

Terminal log:

```bash
pod/incident-demo created

NAME            READY   STATUS              RESTARTS   AGE
client1/1Running018m
incident-demo0/1     ContainerCreating08s
server1/1Running018m
incident-demo1/1Running010s
```

## Step 3 - Investigate logs

```bash
kubectl logs incident-demo
```

Terminal log:

```bash
Starting application...cat: can't open '/app/config.txt': No such file or directory
```

## Step 4 - Describe pod

```bash
kubectl describe pod incident-demo
```

Terminal log:

```bash
Mounts:
  /var/run/secrets/kubernetes.io/serviceaccountfrom kube-api-access-wxn62 (ro)
```

## Step 5 - Verify inside container

```bash
kubectlexec -it incident-demo -- sh
ls /ls /app
```

Terminal log:

```bash
ls: /app: No such file or directory
```

## Step 6 - Create ConfigMap

```bash
kubectl create configmap app-config \
--from-literal=config.txt="APP_MODE=prod"
```

Terminal log:

```bash
configmap/app-config created
```

## Step 7 - Deploy fixed pod

```bash
kubectl delete pod incident-demo
kubectl apply -f lab10-fixed.yaml
```

Terminal log:

```bash
pod"incident-demo" deleted
pod/incident-demo created
```

## Step 8 - Logs do not show config (observed behavior)

```bash
kubectl logs incident-demo
```

Terminal log:

```bash
Starting application...
```

## Step 9 - Validate mount

```bash
kubectl describe pod incident-demo | sed -n'/Mounts:/,/Conditions:/p'
```

Terminal log:

```bash
Mounts:
  /app fromconfig (rw)
  /var/run/secrets/kubernetes.io/serviceaccountfrom kube-api-access-zzbg5 (ro)
```

## Step 10 - Inspect files directly

```bash
kubectlexec -it incident-demo -- sh -c'ls -l /app; echo "----"; cat /app/config.txt || true'
```

Terminal log:

```bash
total0
lrwxrwxrwx1 root     root17 Feb1119:18config.txt -> ..data/config.txt
----
APP_MODE=prod
```

## Step 11 - Fix ConfigMap formatting

```bash
kubectl delete configmap app-config --ignore-not-found
kubectl create configmap app-config --from-literal=config.txt=$'APP_MODE=prod\n'
kubectl delete pod incident-demo --ignore-not-found
kubectl apply -f lab10-fixed.yaml
```

Terminal log:

```bash
configmap"app-config" deleted
configmap/app-config created
pod"incident-demo" deleted
pod/incident-demo created
```

## Step 12 - Verify final result

```bash
kubectl logs incident-demo
```

Terminal log:

```bash
Starting application...
APP CONFIG:
APP_MODE=prod
```

## Tips

- A pod can be `Running` while the app is still functionally broken.
- Validate mounted files directly with `kubectlexec` when logs are ambiguous.

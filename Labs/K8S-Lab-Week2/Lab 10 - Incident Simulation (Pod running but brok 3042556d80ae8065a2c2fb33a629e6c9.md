# Lab 10 - Incident Simulation (Pod running but broken)

# Lab 10 - Debugging a Broken Pod Using ConfigMap

## Goal

Simulate a real incident where:

- Application expects a config file
- File is missing
- Investigate using logs, describe, exec
- Fix using ConfigMap
- Verify behavior

Cluster used:

- kind (recreated)
- Calico installed
- namespace: week2

---

# Step 1 - Clean Start

Command:

```bash
kubectl delete pod incident-demo --ignore-not-found
```

Output:

```
(nooutput - pod didnot exist)
```

---

# Step 2 - Deploy Broken Application

Apply:

```bash
kubectl apply -f lab10-broken.yaml
```

Output:

```
pod/incident-demo created
```

Watch pod:

```bash
kubectl get pods -w
```

Output:

```
NAME            READY   STATUS              RESTARTS   AGE
client1/1Running018m
incident-demo0/1     ContainerCreating08s
server1/1Running018m
incident-demo1/1Running010s
```

---

# Step 3 - Investigate Logs

Command:

```bash
kubectl logs incident-demo
```

Output:

```
Starting application...cat: can't open '/app/config.txt': No such file or directory
```

Observation:

- Application expects a file at `/app/config.txt`
- File missing

---

# Step 4 - Describe Pod

Command:

```bash
kubectl describe pod incident-demo
```

Relevant Output:

```
Mounts:
  /var/run/secrets/kubernetes.io/serviceaccountfrom kube-api-access-wxn62 (ro)
```

Observation:

- No mount for `/app`
- Config file never injected

---

# Step 5 - Verify Inside Container

Command:

```bash
kubectlexec -it incident-demo -- sh
```

Inside container:

```bash
ls /ls /app
```

Output:

```
ls: /app: No such file or directory
```

Root Cause:

- Config file not present
- Directory not mounted

---

# Step 6 - Create ConfigMap

Command:

```bash
kubectl create configmap app-config \
--from-literal=config.txt="APP_MODE=prod"
```

Output:

```
configmap/app-config created
```

---

# Step 7 - Deploy Fixed Pod

Delete old pod:

```bash
kubectl delete pod incident-demo
```

Output:

```
pod"incident-demo" deleted
```

Apply fixed YAML:

```bash
kubectl apply -f lab10-fixed.yaml
```

Output:

```
pod/incident-demo created
```

---

# Step 8 - Logs Do Not Show Config (Observed Behavior)

Command:

```bash
kubectl logs incident-demo
```

Output:

```
Starting application...
```

Observation:

- Config not printed
- Need further debugging

---

# Step 9 - Validate Mount

Command:

```bash
kubectl describe pod incident-demo | sed -n'/Mounts:/,/Conditions:/p'
```

Output:

```
Mounts:
  /app fromconfig (rw)
  /var/run/secrets/kubernetes.io/serviceaccountfrom kube-api-access-zzbg5 (ro)
```

Mount exists.

---

# Step 10 - Inspect Files Directly

Command:

```bash
kubectlexec -it incident-demo -- sh -c'ls -l /app; echo "----"; cat /app/config.txt || true'
```

Output:

```
total0
lrwxrwxrwx1 root     root17 Feb1119:18config.txt -> ..data/config.txt----
APP_MODE=prod
```

Conclusion:

- ConfigMap mounted correctly
- Formatting issue suspected

---

# Step 11 - Fix ConfigMap Formatting

Command:

```bash
kubectl delete configmap app-config --ignore-not-found
kubectl create configmap app-config --from-literal=config.txt=$'APP_MODE=prod\n'
```

Output:

```
configmap"app-config" deleted
configmap/app-config created
```

Redeploy pod:

```bash
kubectl delete pod incident-demo --ignore-not-found
kubectl apply -f lab10-fixed.yaml
```

Output:

```
pod"incident-demo" deleted
pod/incident-demo created
```

---

# Step 12 - Verify Final Result

Command:

```bash
kubectl logs incident-demo
```

Output:

```
Starting application...
APP CONFIG:
APP_MODE=prod
```

Success.

---

# Final Root Cause

Broken state:

- Application expected file
- File not mounted
- ConfigMap missing

Intermediate issue:

- Formatting prevented expected log behavior

Final fix:

- ConfigMap mounted correctly
- Newline added
- Pod redeployed

---

# Key Commands Learned

Debugging flow:

```bash
kubectl logs
kubectl describe pod
kubectlexec
kubectl get configmap
kubectl delete pod
kubectl apply
```

This exact workflow is what real Kubernetes incident response looks like.

---

# Interview Phrase

Good concise phrasing:

"I debugged a Kubernetes incident where an application failed due to a missing ConfigMap mount. I verified using logs, describe, and exec, then mounted the ConfigMap and redeployed the pod to restore functionality."

---

# Lab Status

Lab 10 complete.
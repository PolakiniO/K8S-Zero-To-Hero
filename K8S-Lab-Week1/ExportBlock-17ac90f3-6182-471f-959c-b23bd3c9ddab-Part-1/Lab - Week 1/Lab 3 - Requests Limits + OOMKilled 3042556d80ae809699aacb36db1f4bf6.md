# Lab 3 - Requests/Limits + OOMKilled

This lab prefers the use of kuebctl top, which requires a metrics API server, which is not set by default:  

[Lab 3 - Enabling kubectl top for OOMKilled observation](Lab%203%20-%20Requests%20Limits%20+%20OOMKilled/Lab%203%20-%20Enabling%20kubectl%20top%20for%20OOMKilled%20observa%203042556d80ae80fb8c9ef9483f908e87.md)

[Lab - Fixing Metrics Server (kubectl top not working)](Lab%203%20-%20Requests%20Limits%20+%20OOMKilled/Lab%20-%20Fixing%20Metrics%20Server%20(kubectl%20top%20not%20worki%203042556d80ae80eea747cb5a5ae3103c.md)

# Lab 3 - Requests, Limits, and OOMKilled

## Goal

You will:

1. Deploy a pod with a low memory limit
2. Force memory usage to grow
3. Observe OOMKilled
4. Fix by right-sizing resources

---

# Step 1 - Deploy a memory constrained pod

Apply this:

```bash
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: memhog
spec:
  containers:
    - name: memhog
      image: python:3.12-slim
      resources:
        requests:
          memory: "64Mi"
          cpu: "50m"
        limits:
          memory: "128Mi"
          cpu: "200m"
      command: ["python", "-c"]
      args:
        - |
          import time
          a=[]
          print("sleeping 60s so metrics-server can scrape me...")
          time.sleep(60)
          i=0
          while True:
            a.append("x"*1024*1024)
            i+=1
            print(f"allocated {i} MiB")
            time.sleep(0.05)
YAML
```

Terminal Log:

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ touch lab3-memhog.yaml
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab3-memhog.yaml
pod/memhog created
```

Watch it:

```bash
kubectl get pod memhog -w
```

Terminal Log: 

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab3-memhog.yaml
pod/memhog created
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pod memhog -w
NAME     READY   STATUS              RESTARTS   AGE
memhog   0/1     ContainerCreating   0          9s
memhog   1/1     Running             0          24s
memhog   0/1     OOMKilled           0          28s
memhog   1/1     Running             1 (1s ago)   29s
memhog   0/1     OOMKilled           1 (5s ago)   33s
memhog   0/1     CrashLoopBackOff    1 (12s ago)   45s
```

should see:

- Running
- Then Restarting / CrashLoopBackOff

---

# Step 2 - Watch memory growth (now possible)

Open another terminal or run quickly:

```bash
kubectl top pod memhog
```

You will see memory climbing toward ~64Mi.

Then the container will restart.

Terminal Log:

```bash
Terminal Log:

polakinio@Polakinio:~$ while true; do kubectl top pod memhog -n week1; sleep 1; done
Error from server (NotFound): pods "memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
NAME     CPU(cores)   MEMORY(bytes)
memhog   14m          4Mi
NAME     CPU(cores)   MEMORY(bytes)
memhog   14m          4Mi
...
NAME     CPU(cores)   MEMORY(bytes)
memhog   0m           4Mi
NAME     CPU(cores)   MEMORY(bytes)
memhog   0m           4Mi
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
NAME     CPU(cores)   MEMORY(bytes)
memhog   0m           4Mi
NAME     CPU(cores)   MEMORY(bytes)
memhog   0m           4Mi
NAME     CPU(cores)   MEMORY(bytes)
memhog   0m           4Mi
...
NAME     CPU(cores)   MEMORY(bytes)
memhog   0m           4Mi
NAME     CPU(cores)   MEMORY(bytes)
memhog   0m           4Mi
^C
polakinio@Polakinio:~$
```

---

# Step 3 - Confirm OOMKilled

Run:

```bash
kubectl describe pod memhog
```

Look for:

- Last State: Terminated
- Reason: OOMKilled
- Exit Code: 137

That confirms Kubernetes killed it for exceeding the memory limit.

Terminal Log:

```bash
polakinio@Polakinio:~$ kubectl describe pod memhog
Name:             memhog
Namespace:        week1
Priority:         0
Service Account:  default
Node:             lab-control-plane/172.19.0.2
Start Time:       Wed, 11 Feb 2026 16:31:12 +0200
Labels:           <none>
Annotations:      <none>
Status:           Running
IP:               10.244.0.15
IPs:
IP:  10.244.0.15
Containers:
memhog:
Container ID:  containerd://dcb834e3c74a7b8260d3cbd07fbe3a9298cdf26c1eb899fc35fe1b0e7ae39fc1
Image:         python:3.12-slim
Image ID:      [docker.io/library/python@sha256:9e01bf1ae5db7649a236da7be1e94ffbbbdd7a93f867dd0d8d5720d9e1f89fab](http://docker.io/library/python@sha256:9e01bf1ae5db7649a236da7be1e94ffbbbdd7a93f867dd0d8d5720d9e1f89fab)
Port:          <none>
Host Port:     <none>
Command:
python
-c
Args:
import time
a=[]
print("sleeping 60s so metrics-server can scrape me...")
time.sleep(60)
i=0
while True:
a.append("x"*1024*1024)
i+=1
print(f"allocated {i} MiB")
time.sleep(0.05)

```
State:          Waiting
  Reason:       CrashLoopBackOff
Last State:     Terminated
  Reason:       OOMKilled
  Exit Code:    137
  Started:      Wed, 11 Feb 2026 16:39:45 +0200
  Finished:     Wed, 11 Feb 2026 16:40:53 +0200
Ready:          False
Restart Count:  5
Limits:
  cpu:     200m
  memory:  128Mi
Requests:
  cpu:        50m
  memory:     64Mi
Environment:  <none>
Mounts:
  /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-7db4q (ro)
```

Conditions:
Type                        Status
PodReadyToStartContainers   True
Initialized                 True
Ready                       False
ContainersReady             False
PodScheduled                True
Volumes:
kube-api-access-7db4q:
Type:                    Projected (a volume that contains injected data from multiple sources)
TokenExpirationSeconds:  3607
ConfigMapName:           kube-root-ca.crt
ConfigMapOptional:       <nil>
DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 [node.kubernetes.io/not-ready:NoExecute](http://node.kubernetes.io/not-ready:NoExecute) op=Exists for 300s
[node.kubernetes.io/unreachable:NoExecute](http://node.kubernetes.io/unreachable:NoExecute) op=Exists for 300s
Events:
Type     Reason     Age                    From               Message

Normal   Scheduled  10m                    default-scheduler  Successfully assigned week1/memhog to lab-control-plane
Normal   Pulled     4m7s (x5 over 10m)     kubelet            Container image "python:3.12-slim" already present on machine
Normal   Created    4m7s (x5 over 10m)     kubelet            Created container memhog
Normal   Started    4m6s (x5 over 10m)     kubelet            Started container memhog
Warning  BackOff    2m5s (x11 over 7m43s)  kubelet            Back-off restarting failed container memhog in pod memhog_week1(1f808f20-5cf9-46db-99f5-241a3fcfdcce)
polakinio@Polakinio:~$/code
```

---

# Step 4 - Fix it (right-size resources)

Delete pod:

```bash
kubectl delete pod memhog
```

Terminal Log:

```bash
polakinio@Polakinio:~$ kubectl delete pod memhog
pod "memhog" deleted
```

Recreate with higher limit:

```bash
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: memhog
spec:
  containers:
  - name: memhog
    image: python:3.12-slim
    resources:
      requests:
        memory:"64Mi"
        cpu:"50m"
      limits:
        memory:"256Mi"
        cpu:"200m"command: ["python","-c"]
    args:
      - |
        importtime
        a=[]while True:
          a.append("x"*1024*1024)
          time.sleep(0.05)
YAML
```

Now:

```bash
kubectl get pod memhog
kubectl top pod memhog
```

It should stay running much longer.

Terminal Log:

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ touch lab3-memhog-fix.yaml
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab3-memhog-fix.yaml
pod/memhog created
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pod memhog -w
NAME     READY   STATUS    RESTARTS   AGE
memhog   1/1     Running   0          8s
^Cpolakinio@Polakinio:~/Projects/k8s/week1$

polakinio@Polakinio:~$ while true; do kubectl top pod memhog -n week1; sleep 1; done
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
Error from server (NotFound): podmetrics.metrics.k8s.io "week1/memhog" not found
NAME     CPU(cores)   MEMORY(bytes)
memhog   105m         242Mi
NAME     CPU(cores)   MEMORY(bytes)
memhog   105m         242Mi
NAME     CPU(cores)   MEMORY(bytes)
memhog   105m         242Mi
NAME     CPU(cores)   MEMORY(bytes)
memhog   105m         242Mi
NAME     CPU(cores)   MEMORY(bytes)
memhog   105m         242Mi
```

---

# What this lab teaches (the real lesson)

Requests:

- Used for scheduling
- Guarantees minimum resources

Limits:

- Hard cap
- Exceeding memory limit triggers OOMKill

OOMKilled:

- Kernel kills container
- Exit code 137
- Pod restarts

---

# Small real-world insight

In production:

- Too low limit → CrashLoopBackOff
- Too high limit → node memory pressure
- Right-sizing comes from observing real usage with metrics

That is exactly why kubectl top and Prometheus exist.
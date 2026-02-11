# Lab 4 — Liveness + Readiness Probes

## Lab 4 - Liveness + Readiness Probes

### Tasks

1. Add liveness probe with broken path
2. Observe restart loop
3. Fix probe path and timing
4. Add readiness probe to gate traffic

### Validation Commands

```bash
kubectl describe pod probe-demo
kubectl get pod probe-demo -w
```

---

## Step 1 - Broken liveness probe (forces restart loop)

### Commands executed

```bash
touch broken-liveliness-probe.yaml
kubectl apply -f lab4-broken-liveliness-probe.yaml
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
```

### What was observed

- Pod entered Running but restart count increased
- Events showed liveness probe failures (HTTP 404) followed by kubelet killing and restarting the container

### Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ touch broken-liveliness-probe.yaml
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab4-broken-liveliness-probe.yaml
pod/probe-demo created
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pod probe-demo -w
NAME         READY   STATUS    RESTARTS   AGE
probe-demo   1/1     Running   0          9s
^Cpolakinio@Polakinio:~/Projects/k8s/week1$
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl describe pod probe-demo
Name:             probe-demo
Namespace:        week1
Priority:         0
Service Account:  default
Node:             lab-control-plane/172.19.0.2
Start Time:       Wed, 11 Feb 2026 17:06:51 +0200
Labels:           <none>
Annotations:      <none>
Status:           Running
IP:               10.244.0.17
IPs:
  IP:  10.244.0.17
Containers:
  nginx:
    Container ID:   containerd://9f201bb593a6103dbdce40356ac63d4de4f49032fddd3cee4abae44a74f841ab
    Image:          nginx:1.25
    Image ID:       docker.io/library/nginx@sha256:a484819eb60211f5299034ac80f6a681b06f89e65866ce91f356ed7c72af059c
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 11 Feb 2026 17:07:07 +0200
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Wed, 11 Feb 2026 17:06:52 +0200
      Finished:     Wed, 11 Feb 2026 17:07:06 +0200
    Ready:          True
    Restart Count:  1
    Liveness:       http-get http://:80/broken delay=5s timeout=1s period=5s #success=1 #failure=2
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-6fsvl (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-6fsvl:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  20s               default-scheduler  Successfully assigned week1/probe-demo to lab-control-plane
  Warning  Unhealthy  5s (x2 over 10s)  kubelet            Liveness probe failed: HTTP probe failed with statuscode: 404
  Normal   Killing    5s                kubelet            Container nginx failed liveness probe, will be restarted
  Normal   Pulled     4s (x2 over 19s)  kubelet            Container image "nginx:1.25" already present on machine
  Normal   Created    4s (x2 over 19s)  kubelet            Created container nginx
  Normal   Started    4s (x2 over 19s)  kubelet            Started container nginx
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pod probe-demo -w
NAME         READY   STATUS    RESTARTS     AGE
probe-demo   1/1     Running   2 (4s ago)   34s
probe-demo   1/1     Running   3 (2s ago)   47s
^Cpolakinio@Polakinio:~/Projects/k8s/week1$
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl describe pod probe-demo
Name:             probe-demo
Namespace:        week1
Priority:         0
Service Account:  default
Node:             lab-control-plane/172.19.0.2
Start Time:       Wed, 11 Feb 2026 17:06:51 +0200
Labels:           <none>
Annotations:      <none>
Status:           Running
IP:               10.244.0.17
IPs:
  IP:  10.244.0.17
Containers:
  nginx:
    Container ID:   containerd://65afdbfcf2b4a92c546c608440facc27c4b6351bb1c7bcddb4ff1c95e70761f7
    Image:          nginx:1.25
    Image ID:       docker.io/library/nginx@sha256:a484819eb60211f5299034ac80f6a681b06f89e65866ce91f356ed7c72af059c
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 11 Feb 2026 17:07:37 +0200
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Wed, 11 Feb 2026 17:07:22 +0200
      Finished:     Wed, 11 Feb 2026 17:07:36 +0200
    Ready:          True
    Restart Count:  3
    Liveness:       http-get http://:80/broken delay=5s timeout=1s period=5s #success=1 #failure=2
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-6fsvl (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-6fsvl:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  56s                default-scheduler  Successfully assigned week1/probe-demo to lab-control-plane
  Normal   Pulled     11s (x4 over 55s)  kubelet            Container image "nginx:1.25" already present on machine
  Normal   Killing    11s (x3 over 41s)  kubelet            Container nginx failed liveness probe, will be restarted
  Normal   Created    10s (x4 over 55s)  kubelet            Created container nginx
  Normal   Started    10s (x4 over 55s)  kubelet            Started container nginx
  Warning  Unhealthy  1s (x7 over 46s)   kubelet            Liveness probe failed: HTTP probe failed with statuscode: 404
polakinio@Polakinio:~/Projects/k8s/week1$
```

---

## Step 2 - Fix liveness probe + add readiness probe

### Commands executed

```bash
touch lab4-fix-liveliness-probe.yaml
kubectl delete pod demo-probe
kubectl delete pod probe-demo
kubectl apply -f lab4-fix-liveliness-probe.yaml
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
```

### What was observed

- Pod stayed Running with Restart Count: 0
- Liveness and readiness both pointed to /
- No Unhealthy or Killing events

### Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ touch lab4-fix-liveliness-probe.yaml
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl delete pod demo-probe
Error from server (NotFound): pods "demo-probe" not found
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl delete pod probe-demo
pod "probe-demo" deleted
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab4-fix-liveliness-probe.yaml
pod/probe-demo created
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pod probe-demo -w
NAME         READY   STATUS    RESTARTS   AGE
probe-demo   1/1     Running   0          12s
^Cpolakinio@Polakinio:~/Projects/k8s/week1$
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl describe pod probe-demo
Name:             probe-demo
Namespace:        week1
Priority:         0
Service Account:  default
Node:             lab-control-plane/172.19.0.2
Start Time:       Wed, 11 Feb 2026 17:11:11 +0200
Labels:           app=probe-demo
Annotations:      <none>
Status:           Running
IP:               10.244.0.18
IPs:
  IP:  10.244.0.18
Containers:
  nginx:
    Container ID:   containerd://62fe236ea8b806dc3f23a7805f80f919f470ae153159e342fdbc2eecb1afd06c
    Image:          nginx:1.25
    Image ID:       docker.io/library/nginx@sha256:a484819eb60211f5299034ac80f6a681b06f89e65866ce91f356ed7c72af059c
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 11 Feb 2026 17:11:13 +0200
    Ready:          True
    Restart Count:  0
    Liveness:       http-get http://:80/ delay=15s timeout=1s period=10s #success=1 #failure=3
    Readiness:      http-get http://:80/ delay=3s timeout=1s period=5s #success=1 #failure=2
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-55jh7 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-55jh7:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  20s   default-scheduler  Successfully assigned week1/probe-demo to lab-control-plane
  Normal  Pulled     19s   kubelet            Container image "nginx:1.25" already present on machine
  Normal  Created    19s   kubelet            Created container nginx
  Normal  Started    18s   kubelet            Started container nginx
polakinio@Polakinio:~/Projects/k8s/week1$
```

---

## Step 3 - Create Service and validate readiness gating via Endpoints

### Commands executed

```bash
touch lab4-readiness-service.yaml
kubectl apply -f lab4-readiness-service.yaml
kubectl get endpoints probe-svc -w
```

### What was observed

- Endpoints contained the pod IP and port because pod was Ready

### Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ touch lab4-readiness-service.yaml
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab4-readiness-service.yaml
service/probe-svc created
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get endpoints probe-svc -w
NAME        ENDPOINTS        AGE
probe-svc   10.244.0.18:80   80s
^Cpolakinio@Polakinio:~/Projects/k8s/week1$
```

---

## Step 4 - Break readiness only (pod stays Running, endpoints removed)

### Commands executed

```bash
touch lab4-broken-rediness-probe.yaml
kubectl apply -f lab4-broken-readiness-probe.yaml
kubectl delete pod probe-demo
kubectl apply -f lab4-broken-readiness-probe.yaml
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
kubectl get endpoints probe-svc -w
kubectl get pod probe-demo -w
kubectl describe pod probe-demo
kubectl get endpoints probe-svc -w
```

### What was observed

- First apply failed because pod spec updates cannot change probe fields
- After deleting and recreating:
    - Pod stayed Running but READY became 0/1
    - Events showed readiness probe failed with HTTP 404
    - Service endpoints became empty

### Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ touch lab4-broken-rediness-probe.yaml
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab4-broken-readiness-probe.yaml
The Pod "probe-demo" is invalid: spec: Forbidden: pod updates may not change fields other than `spec.containers[*].image`,`spec.initContainers[*].image`,`spec.activeDeadlineSeconds`,`spec.tolerations` (only additions to existing tolerations),`spec.terminationGracePeriodSeconds` (allow it to be set to 1 if it was previously negative)
...
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl delete pod probe-demo
pod "probe-demo" deleted
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab4-broken-readiness-probe.yaml
pod/probe-demo created
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pod probe-demo -w
kubectl describe pod probe-demo
kubectl get endpoints probe-svc -w
NAME         READY   STATUS    RESTARTS   AGE
probe-demo   0/1     Running   0          12s
^CName:             probe-demo
Namespace:        week1
Priority:         0
Service Account:  default
Node:             lab-control-plane/172.19.0.2
Start Time:       Wed, 11 Feb 2026 17:19:51 +0200
Labels:           app=probe-demo
Annotations:      <none>
Status:           Running
IP:               10.244.0.19
IPs:
  IP:  10.244.0.19
Containers:
  nginx:
    Container ID:   containerd://13bdffec21b8b3f848c2aebb115b5f624db8489ae1a96377f701ca6646fab099
    Image:          nginx:1.25
    Image ID:       docker.io/library/nginx@sha256:a484819eb60211f5299034ac80f6a681b06f89e65866ce91f356ed7c72af059c
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 11 Feb 2026 17:19:52 +0200
    Ready:          False
    Restart Count:  0
    Liveness:       http-get http://:80/ delay=15s timeout=1s period=10s #success=1 #failure=3
    Readiness:      http-get http://:80/broken delay=3s timeout=1s period=5s #success=1 #failure=2
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-xqxgk (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  kube-api-access-xqxgk:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  16s               default-scheduler  Successfully assigned week1/probe-demo to lab-control-plane
  Normal   Pulled     15s               kubelet            Container image "nginx:1.25" already present on machine
  Normal   Created    15s               kubelet            Created container nginx
  Normal   Started    15s               kubelet            Started container nginx
  Warning  Unhealthy  1s (x3 over 11s)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 404
NAME        ENDPOINTS   AGE
probe-svc               7m14s
^Cpolakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pod probe-demo -w
NAME         READY   STATUS    RESTARTS   AGE
probe-demo   0/1     Running   0          25s
^Cpolakinio@Polakinio:~/Projects/k8s/week1$ kubectl describe pod probe-demo
Name:             probe-demo
Namespace:        week1
Priority:         0
Service Account:  default
Node:             lab-control-plane/172.19.0.2
Start Time:       Wed, 11 Feb 2026 17:19:51 +0200
Labels:           app=probe-demo
Annotations:      <none>
Status:           Running
IP:               10.244.0.19
IPs:
  IP:  10.244.0.19
Containers:
  nginx:
    Container ID:   containerd://13bdffec21b8b3f848c2aebb115b5f624db8489ae1a96377f701ca6646fab099
    Image:          nginx:1.25
    Image ID:       docker.io/library/nginx@sha256:a484819eb60211f5299034ac80f6a681b06f89e65866ce91f356ed7c72af059c
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 11 Feb 2026 17:19:52 +0200
    Ready:          False
    Restart Count:  0
    Liveness:       http-get http://:80/ delay=15s timeout=1s period=10s #success=1 #failure=3
    Readiness:      http-get http://:80/broken delay=3s timeout=1s period=5s #success=1 #failure=2
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-xqxgk (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  kube-api-access-xqxgk:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  31s               default-scheduler  Successfully assigned week1/probe-demo to lab-control-plane
  Normal   Pulled     30s               kubelet            Container image "nginx:1.25" already present on machine
  Normal   Created    30s               kubelet            Created container nginx
  Normal   Started    30s               kubelet            Started container nginx
  Warning  Unhealthy  1s (x6 over 26s)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 404
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get endpoints probe-svc -w
NAME        ENDPOINTS   AGE
probe-svc               7m32s
^Cpolakinio@Polakinio:~/Projects/k8s/week1$
```

---

## Bonus - actually prove readiness gates traffic

Create a Service and watch endpoints appear only when Ready:

```bash
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: probe-svc
spec:
  selector:
    app: probe-demo
  ports:
  - port: 80
    targetPort: 80
YAML
```

That needs a label on the pod. So use this fixed manifest instead (same probes, adds label):

```bash
kubectl delete pod probe-demo
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: probe-demo
  labels:
    app: probe-demo
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 15
      periodSeconds: 10
      timeoutSeconds: 1
      failureThreshold: 3
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 5
      timeoutSeconds: 1
      failureThreshold: 2
YAML
```

Then:

```bash
kubectl get endpoints probe-svc -w
```

Reflection bullets for Lab 4

- Symptom: restarts, readiness false, or service has no endpoints
- Root cause: bad liveness path or too aggressive timing
- Fix: correct path and tune initialDelaySeconds, periodSeconds, failureThreshold; add readiness probe to gate traffic
- Prevention: standard probe templates per app, include startupProbe for slow starts
# Lab 14 - Cluster Resource Exhaustion (CPU) and Scheduling Failure

## Lab 14 - Cluster Resource Exhaustion (CPU) and Scheduling Failure

### Goal

- Overload CPU and observe scheduling behavior when the cluster cannot place additional pods due to CPU requests, node selectors, and taints
- Confirm what runs, what stays Pending, and why

---

### Lab environment baseline

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl get pods -A
kubectl get nodes
kubectl top nodes
NAMESPACE            NAME                                          READY   STATUS    RESTARTS      AGE
calico-apiserver     calico-apiserver-7f745fcf9d-v4p7j             1/1     Running   0             20h
calico-apiserver     calico-apiserver-7f745fcf9d-wh7kx             1/1     Running   0             118m
calico-system        calico-kube-controllers-54697fbc7f-drlcn      1/1     Running   0             20h
calico-system        calico-node-9vbxv                             1/1     Running   3 (41m ago)   20h
calico-system        calico-node-g6n5c                             1/1     Running   0             20h
calico-system        calico-node-qt4n8                             1/1     Running   2 (63m ago)   20h
calico-system        calico-typha-cc7c5bf-7zx7l                    1/1     Running   3 (41m ago)   20h
calico-system        calico-typha-cc7c5bf-kzdp6                    1/1     Running   0             20h
calico-system        csi-node-driver-ksr8p                         2/2     Running   0             20h
calico-system        csi-node-driver-v99tw                         2/2     Running   0             20h
calico-system        csi-node-driver-xfjgt                         2/2     Running   6 (41m ago)   20h
kube-system          coredns-7db6d8ff4d-gw892                      1/1     Running   0             20h
kube-system          coredns-7db6d8ff4d-zj5tp                      1/1     Running   0             20h
kube-system          etcd-labnp-control-plane                      1/1     Running   0             20h
kube-system          kube-apiserver-labnp-control-plane            1/1     Running   0             20h
kube-system          kube-controller-manager-labnp-control-plane   1/1     Running   3 (60m ago)   20h
kube-system          kube-proxy-82bz5                              1/1     Running   3 (41m ago)   20h
kube-system          kube-proxy-fksrt                              1/1     Running   0             20h
kube-system          kube-proxy-h8zwl                              1/1     Running   0             20h
kube-system          kube-scheduler-labnp-control-plane            1/1     Running   4 (60m ago)   20h
local-path-storage   local-path-provisioner-988d74bc-5hnk7         1/1     Running   0             20h
tigera-operator      tigera-operator-5ddc799ffd-t9b2l              1/1     Running   5 (58m ago)   20h
NAME                  STATUS   ROLES           AGE   VERSION
labnp-control-plane   Ready    control-plane   20h   v1.30.0
labnp-worker          Ready    <none>          20h   v1.30.0
labnp-worker2         Ready    <none>          20h   v1.30.0
error: Metrics API not available
polakinio@Polakinio:~/Projects/k8s/week3$
```

Notes

- Metrics Server is not installed, so `kubectl top` fails (expected in kind unless explicitly deployed)
- Cluster has 3 nodes: control-plane (tainted) + 2 workers

---

### Step 1 - Create dedicated namespace and switch context

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl create ns lab14 --dry-run=client -o yaml | kubectl apply -f -
namespace/lab14 created
polakinio@Polakinio:~/Projects/k8s/week3$
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl config set-context --current --namespace=lab14
Context"kind-labnp" modified.
polakinio@Polakinio:~/Projects/k8s/week3$
```

---

### Step 2 - Deploy cpuhog (initial failure due to args handling)

I created the deployment YAML and applied it.

```bash
polakinio@Polakinio:~/Projects/k8s/week3$cat lab14-cpuhog.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpuhog
  namespace: lab14
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cpuhog
  template:
    metadata:
      labels:
        app: cpuhog
    spec:
      nodeSelector:
        kubernetes.io/hostname: labnp-worker
      containers:
      - name: hog
        image: polinux/stress
        args: ["--cpu","2"]
        resources:
          requests:
            cpu:"500m"
            memory:"64Mi"
          limits:
            cpu:"1000m"
            memory:"128Mi"
polakinio@Polakinio:~/Projects/k8s/week3$
```

Apply and observe:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl apply -f lab14-cpuhog.yaml
deployment.apps/cpuhog created
polakinio@Polakinio:~/Projects/k8s/week3$
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl get pods -o wide -w
NAME                     READY   STATUS              RESTARTS   AGE   IP       NODE           NOMINATED NODE   READINESS GATES
cpuhog-99fdf957b-vk55b   0/1     ContainerCreating   0          12s   <none>   labnp-worker   <none>           <none>
cpuhog-99fdf957b-vk55b   0/1     RunContainerError   0          13s   192.168.83.153   labnp-worker   <none>           <none>
cpuhog-99fdf957b-vk55b   0/1     RunContainerError   1 (0s ago)   16s   192.168.83.153   labnp-worker   <none>           <none>
cpuhog-99fdf957b-vk55b   0/1     CrashLoopBackOff    1 (1s ago)   17s   192.168.83.153   labnp-worker   <none>           <none>
^Cpolakinio@Polakinio:~/Projects/k8s/week3$
```

Root cause from `describe`:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl describe pod cpuhog-99fdf957b-vk55b
...
Last State:     Terminated
  Reason:       StartError
  Message:      failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process:exec:"--cpu": executable file not foundin$PATH: unknown
...
Events:
  Warning  Failed  ...  Error: ...exec:"--cpu": executable file not foundin$PATH: unknown
...
polakinio@Polakinio:~/Projects/k8s/week3$
```

What happened

- `polinux/stress` expects `stress` as the executable
- With only `args: ["--cpu","2"]` and no `command: ["stress"]`, the container runtime tried to execute `-cpu` as the entrypoint, which fails

---

### Step 3 - Fix cpuhog by rolling out corrected spec

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl apply -f lab14-cpuhog.yaml
deployment.apps/cpuhog configured
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl rollout restart deploy/cpuhog
deployment.apps/cpuhog restarted
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl rollout status deploy/cpuhog
deployment"cpuhog" successfully rolled out
polakinio@Polakinio:~/Projects/k8s/week3$
```

Pods after fix:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl get pods -o wide
NAME                      READY   STATUS        RESTARTS   AGE   IP               NODE           NOMINATED NODE   READINESS GATES
cpuhog-7c5958c8f5-p8nr4   1/1     Running       0          15s   192.168.83.155   labnp-worker   <none>           <none>
cpuhog-b69997ffd-njhf9    1/1     Terminating   0          34s   192.168.83.154   labnp-worker   <none>           <none>
polakinio@Polakinio:~/Projects/k8s/week3$
```

Verify the process inside the container:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ POD=$(kubectl get pod -l app=cpuhog -o jsonpath='{.items[0].metadata.name}')
polakinio@Polakinio:~/Projects/k8s/week3$ kubectlexec"$POD" -- sh -lc'ps aux | head -n 5; echo; pidof stress || true'
PID   USER     TIME  COMMAND
    1 root      0:00 stress --cpu 2 --timeout 600
   10 root      0:26 stress --cpu 2 --timeout 600
   11 root      0:26 stress --cpu 2 --timeout 600
   12 root      0:00 sh -lc ps aux |head -n 5;echo; pidof stress ||true

11 10 1
polakinio@Polakinio:~/Projects/k8s/week3$
```

Host-level confirmation on `labnp-worker`:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ dockerexec -it labnp-worker bash -lc'top -b -n1 | head -n 25'
top - 15:51:38 up 1 day,  3:27,  0 user,  load average: 4.30, 3.11, 2.87
Tasks:  71 total,   3 running,  68 sleeping,   0 stopped,   0 zombie
%Cpu(s): 30.8 us, 30.8 sy,  0.0 ni, 35.9id,  0.0 wa,  0.0 hi,  2.6 si,  0.0 st
MiB Mem :   7880.2 total,   4139.1 free,   2257.7 used,   1664.8 buff/cache
MiB Swap:   2048.0 total,   1307.6 free,    740.4 used.   5622.5 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   7441 root      20   0     780    128    128 R  38.9   0.0   0:31.21 stress
   7442 root      20   0     780    128    128 R  38.9   0.0   0:30.87 stress
...
polakinio@Polakinio:~/Projects/k8s/week3$
```

---

### Step 4 - Scale cpuhog to increase CPU pressure

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl scale deploy/cpuhog --replicas=2
deployment.apps/cpuhog scaled
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl get pods -o wide -w
NAME                      READY   STATUS              RESTARTS   AGE     IP               NODE           NOMINATED NODE   READINESS GATES
cpuhog-7c5958c8f5-2ftv4   0/1     ContainerCreating   0          6s      <none>           labnp-worker   <none>           <none>
cpuhog-7c5958c8f5-p8nr4   1/1     Running             0          3m46s   192.168.83.155   labnp-worker   <none>           <none>
cpuhog-7c5958c8f5-2ftv4   1/1     Running             0          8s      192.168.83.156   labnp-worker   <none>           <none>
^Cpolakinio@Polakinio:~/Projects/k8s/week3$
```

Scale to 3:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl scale deploy/cpuhog --replicas=3
deployment.apps/cpuhog scaled
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl get pods -o wide
NAME                      READY   STATUS    RESTARTS   AGE    IP               NODE           NOMINATED NODE   READINESS GATES
cpuhog-7c5958c8f5-2ftv4   1/1     Running   0          28s    192.168.83.156   labnp-worker   <none>           <none>
cpuhog-7c5958c8f5-2pbw5   1/1     Running   0          9s     192.168.83.157   labnp-worker   <none>           <none>
cpuhog-7c5958c8f5-p8nr4   1/1     Running   0          4m8s   192.168.83.155   labnp-worker   <none>           <none>
polakinio@Polakinio:~/Projects/k8s/week3$
```

Host view shows load climbing:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ dockerexec -it labnp-worker bash -lc'uptime; top -b -n1 | head -n 15'
 15:54:55 up 1 day,  3:30,  0 user,  load average: 7.15, 4.31, 3.33
top - 15:54:56 up 1 day,  3:30,  0 user,  load average: 6.82, 4.29, 3.33
Tasks:  81 total,   7 running,  74 sleeping,   0 stopped,   0 zombie
%Cpu(s): 46.2 us, 26.9 sy,  0.0 ni, 26.9id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
...
polakinio@Polakinio:~/Projects/k8s/week3$
```

---

### Step 5 - Deploy cpureq with high CPU requests and scale until it breaks scheduling

I applied a second deployment named `cpureq` (YAML not shown in output, but behavior confirms it requests 1500m CPU per pod and uses the same nodeSelector to `labnp-worker`).

Initial creation:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl apply -f lab14-cpureq.yaml
deployment.apps/cpureq created
polakinio@Polakinio:~/Projects/k8s/week3$
```

`describe` confirms requests and limits:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl describe pod -l app=cpureq | sed -n'1,120p'
...
Args:
  --cpu
  1
  --timeout
  600
Limits:
  cpu:     1500m
  memory:  128Mi
Requests:
  cpu:        1500m
  memory:     64Mi
...
Node-Selectors:  kubernetes.io/hostname=labnp-worker
...
polakinio@Polakinio:~/Projects/k8s/week3$
```

Scale cpureq to 2, then 3 - still schedules:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl scale deploy/cpureq --replicas=2
deployment.apps/cpureq scaled
...
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl scale deploy/cpureq --replicas=3
deployment.apps/cpureq scaled
...
```

Scale cpureq to 5 - one replica becomes Pending:

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl scale deploy/cpureq --replicas=5
deployment.apps/cpureq scaled
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl get pods -o wide
NAME                      READY   STATUS    RESTARTS        AGE     IP               NODE           NOMINATED NODE   READINESS GATES
cpuhog-7c5958c8f5-2ftv4   1/1     Running   0               9m36s   192.168.83.156   labnp-worker   <none>           <none>
cpuhog-7c5958c8f5-2pbw5   1/1     Running   0               9m17s   192.168.83.157   labnp-worker   <none>           <none>
cpuhog-7c5958c8f5-p8nr4   1/1     Running   1 (3m13s ago)   13m     192.168.83.155   labnp-worker   <none>           <none>
cpureq-f9c975c6d-4ckxz    1/1     Running   0               18s     192.168.83.161   labnp-worker   <none>           <none>
cpureq-f9c975c6d-84bk6    0/1     Pending   0               18s     <none>           <none>         <none>           <none>
cpureq-f9c975c6d-bt9vm    1/1     Running   0               8m      192.168.83.158   labnp-worker   <none>           <none>
cpureq-f9c975c6d-dlk6r    1/1     Running   0               3m6s    192.168.83.159   labnp-worker   <none>           <none>
cpureq-f9c975c6d-rbpdl    1/1     Running   0               2m37s   192.168.83.160   labnp-worker   <none>           <none>
polakinio@Polakinio:~/Projects/k8s/week3$
```

---

### Key observation - Why the pod is Pending (real scheduler explanation)

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl describe pod cpureq-f9c975c6d-84bk6
Name:             cpureq-f9c975c6d-84bk6
Namespace:        lab14
...
Node:             <none>
Status:           Pending
...
Node-Selectors:              kubernetes.io/hostname=labnp-worker
...
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  105s  default-scheduler  0/3 nodes are available: 1 Insufficient cpu, 1 node(s) didn't match Pod's node affinity/selector, 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }. preemption: 0/3 nodes are available: 1 No preemption victims foundfor incoming pod, 2 Preemption is not helpfulfor scheduling.
polakinio@Polakinio:~/Projects/k8s/week3$
```

Breakdown of the message

- 1 Insufficient cpu - the only eligible worker (labnp-worker) is out of allocatable CPU for this pod's 1500m request
- 1 node didn't match selector - labnp-worker2 is excluded by `nodeSelector: kubernetes.io/hostname=labnp-worker`
- 1 node had untolerated taint - control-plane is tainted and this workload has no toleration, so it cannot run there
- Preemption not helpful - there are no suitable victims it can evict to free enough CPU for the incoming pod (or preemption policy does not help given constraints)

---

### Capacity proof - labnp-worker is at 93 percent CPU requests

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl describe node labnp-worker | egrep -n"Allocated resources|Requests|Limits|cpu|memory" -n -A25
...
Capacity:
33:  cpu:                8
...
Allocatable:
40:  cpu:                8
...
Non-terminated Pods:          (11in total)
61:  Namespace                   Name                          CPU Requests  CPU Limits   Memory Requests  Memory Limits  Age
...
67:  lab14                       cpuhog-7c5958c8f5-2ftv4       500m (6%)     1 (12%)      64Mi (0%)        128Mi (1%)     11m
68:  lab14                       cpuhog-7c5958c8f5-2pbw5       500m (6%)     1 (12%)      64Mi (0%)        128Mi (1%)     11m
69:  lab14                       cpuhog-7c5958c8f5-p8nr4       500m (6%)     1 (12%)      64Mi (0%)        128Mi (1%)     15m
70:  lab14                       cpureq-f9c975c6d-4ckxz        1500m (18%)   1500m (18%)  64Mi (0%)        128Mi (1%)     2m8s
71:  lab14                       cpureq-f9c975c6d-bt9vm        1500m (18%)   1500m (18%)  64Mi (0%)        128Mi (1%)     9m50s
72:  lab14                       cpureq-f9c975c6d-dlk6r        1500m (18%)   1500m (18%)  64Mi (0%)        128Mi (1%)     4m56s
73:  lab14                       cpureq-f9c975c6d-rbpdl        1500m (18%)   1500m (18%)  64Mi (0%)        128Mi (1%)     4m27s
74:Allocated resources:
75-  (Total limits may be over 100 percent, i.e., overcommitted.)
76:  Resource           Requests     Limits
77-  --------           --------     ------
78:  cpu                7500m (93%)  9 (112%)
79:  memory             448Mi (5%)   896Mi (11%)
...
polakinio@Polakinio:~/Projects/k8s/week3$
```

This matches the scheduling outcome

- With 8 CPUs allocatable, requests on the node are already at 7.5 CPU
- Adding one more `cpureq` pod (1.5 CPU request) would push requests to 9.0 CPU, which cannot fit

---

### Supporting evidence - events timeline (scale, create, fail scheduling)

```bash
polakinio@Polakinio:~/Projects/k8s/week3$ kubectl get events --sort-by=.lastTimestamp |tail -n 50
...
117s        Normal    ScalingReplicaSet   deployment/cpureq              Scaled up replicaset cpureq-f9c975c6d to 5 from 3
116s        Normal    SuccessfulCreate    replicaset/cpureq-f9c975c6d    Created pod: cpureq-f9c975c6d-84bk6
116s        Normal    SuccessfulCreate    replicaset/cpureq-f9c975c6d    Created pod: cpureq-f9c975c6d-4ckxz
...
polakinio@Polakinio:~/Projects/k8s/week3$
```

---

### What I learned

- CPU pressure can be reproduced reliably using requests, not actual usage: the scheduler blocks placement based on requested CPU even if the node is not 100 percent busy
- `nodeSelector` is an easy way to intentionally constrain scheduling and force failure even when other nodes are healthy
- Control-plane taints matter immediately in small clusters: without tolerations, workloads cannot use that capacity
- One simple YAML mistake (missing command/entrypoint) can look like a resource issue at first, but `kubectl describe pod` pinpoints the real cause fast

---

### Recommended cleanup (after saving evidence)

Option A - scale back

```bash
kubectl scale deploy/cpureq --replicas=3
kubectl scale deploy/cpuhog --replicas=1
```

Option B - delete the whole lab namespace

```bash
kubectl delete ns lab14
```
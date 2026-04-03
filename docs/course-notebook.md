# ☸️ Kubernetes Zero to Hero: Expanded Course Notebook

This notebook turns the course into a practical study reference with architecture context, command mapping, and common failure patterns.

## Dual-purpose usage (Course + Lab + Showcase)

- **Course**: use each section as weekly study material and concept refresh.
- **Lab**: pair each concept with a matching exercise under `Labs/` and capture command evidence.
- **Showcase**: summarize what you debugged, what failed, how you proved root cause, and what preventive action you added.

## 1. Why Kubernetes Exists

### Core value proposition
- **Automates operations** for containerized applications.
- **Provides self-healing** by replacing failed containers/pods.
- **Enables scaling** with declarative replica counts and autoscaling integrations.
- **Improves portability** across local, on-prem, and cloud environments.

### Traditional pain points solved
- Single VM/app coupling causing large blast radius.
- Manual recovery when processes crash.
- Inconsistent deployments due to environment drift.
- Slow rollouts and risky updates.

---

## 2. Cluster Architecture Deep Dive

### Control Plane (Controller Node)
- **API Server**: front door for all cluster operations.
- **etcd**: authoritative state store.
- **Scheduler**: places pending pods onto suitable nodes.
- **Controller Manager**: reconciliation loops (Deployment, Node, ReplicaSet, etc.).

### Worker Nodes
- **kubelet**: node agent executing pod lifecycle instructions.
- **Container runtime**: starts/stops containers (containerd, CRI-O, etc.).
- **kube-proxy**: implements service networking data plane behavior.

### End-to-end request flow
1. `kubectl apply -f pod.yaml`
2. API server validates + persists desired state in etcd.
3. Scheduler binds Pod to a worker node.
4. kubelet pulls image and starts containers via runtime.
5. kubelet reports status back to API server.

---

## 3. YAML and Declarative Manifests

### Manifest skeleton
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo-pod
  labels:
    app: demo
spec:
  containers:
    - name: web
      image: nginx:1.27
```

### Validation mindset
- `kind` and `apiVersion` must match supported resource versions.
- indentation defines hierarchy; invalid indentation means invalid manifests.
- labels should be intentionally designed to support querying + service selection.

---

## 4. High-value kubectl Commands

| Goal | Command | Why it matters |
|---|---|---|
| Apply config | `kubectl apply -f <file>` | Declarative source-of-truth workflow |
| Inspect objects | `kubectl get <resource> -o wide` | Fast health/status overview |
| Deep inspect | `kubectl describe <resource> <name>` | Event stream for root cause |
| View logs | `kubectl logs <pod> [-c container]` | App and runtime errors |
| Run shell | `kubectl exec -it <pod> -- sh` | Live debugging |
| View usage | `kubectl top nodes,pods` | Capacity and pressure visibility |

---

## 5. Workload Reliability Concepts

### Namespaces
Provide multi-tenant logical separation for teams, environments, and policies.

### Requests and limits
- **Requests** influence scheduling guarantees.
- **Limits** constrain max usage and prevent noisy neighbors.

### Probes
- **Liveness**: restart unhealthy processes.
- **Readiness**: remove non-ready pods from traffic.
- **Startup probe** (recommended extension): protect slow-start applications from premature liveness failures.

---

## 6. Config, Secrets, and Storage

### Config externalization
- **ConfigMap**: non-sensitive key-value config.
- **Secret**: sensitive config (with external secret manager recommended for production).

### Persistence model
1. **StorageClass** defines provisioning behavior.
2. **PersistentVolume (PV)** provides storage resource.
3. **PersistentVolumeClaim (PVC)** requests/binds storage for workloads.

Key operational check: when pods are pending, always inspect PVC status and storage provisioner events.

---

## 7. Services and Networking

### Why Services exist
Pods are ephemeral and IP addresses change. Services offer stable discovery and traffic routing.

### Service types
- **ClusterIP**: internal-only service exposure.
- **NodePort**: external access via nodeIP:highPort.
- **LoadBalancer**: cloud provider-integrated external endpoint.

### NetworkPolicy basics
Use label selectors and namespace selectors to implement least-privilege east-west traffic control.

---

## 8. Deployments, Rollouts, and Scaling

### Deployment advantages
- Desired replica management.
- Rolling updates with controlled surge/unavailable windows.
- Easy rollback with rollout history.

### Core commands
```bash
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name>
kubectl scale deployment/<name> --replicas=5
```

### Common production pitfalls
- Readiness probe not aligned to application startup profile.
- Too-aggressive resource limits causing OOMKilled or throttling.
- Incorrect service selectors after label changes.

---

## 9. Study Checklist

- [ ] Can explain control plane components from memory.
- [ ] Can debug `ImagePullBackOff` using `describe` + events.
- [ ] Can differentiate liveness vs readiness with real examples.
- [ ] Can create and mount ConfigMap/Secret/PVC manifests.
- [ ] Can expose an app through ClusterIP and NodePort.
- [ ] Can perform and rollback a deployment update confidently.

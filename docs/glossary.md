# Kubernetes Key Terms Glossary

| Term | Definition | Practical role |
|---|---|---|
| Pod | Smallest deployable unit in Kubernetes; wraps one or more containers. | Unit scheduled to nodes. |
| Node | A machine (VM or physical) that runs workloads or control plane components. | Capacity source for workloads. |
| Cluster | Set of nodes managed as one orchestration domain. | Runs distributed applications. |
| API Server | Central REST interface for Kubernetes operations. | Entry point for all control actions. |
| etcd | Distributed key-value store for cluster desired/current state. | System of record for cluster state. |
| Scheduler | Component that assigns pending Pods to nodes. | Optimizes placement based on constraints. |
| kubelet | Node agent managing local pod/container lifecycle. | Executes and reports workload state. |
| kube-proxy | Node-level network component for Service traffic rules. | Enables stable service routing. |
| Manifest | YAML definition of desired object state. | Declarative infrastructure/app config. |
| Namespace | Logical partition for resource grouping and policy boundaries. | Multi-team/environment isolation. |
| Deployment | Higher-level controller for stateless replicated pods. | Rollouts, scaling, rollback safety. |
| ReplicaSet | Maintains target count of identical Pods. | Underlying mechanism for Deployments. |
| Service | Stable virtual endpoint for a set of Pods. | Discovery + load balancing abstraction. |
| ClusterIP | Service type exposed only inside cluster network. | Internal service-to-service traffic. |
| NodePort | Service type exposed on node IPs at static high port. | Basic external exposure for labs/dev. |
| LoadBalancer | Service type with cloud LB integration. | Production-grade external access. |
| Ingress | API for HTTP(S) routing rules into cluster services. | Host/path based traffic management. |
| ConfigMap | Object for non-sensitive configuration data. | Decouples config from images. |
| Secret | Object for sensitive configuration values. | Credentials/token delivery to apps. |
| PV (PersistentVolume) | Provisioned storage resource in cluster. | Durable storage backend abstraction. |
| PVC (PersistentVolumeClaim) | Workload request for persistent storage. | Portable storage consumption model. |
| StorageClass | Dynamic storage provisioning policy. | Standardizes backend and lifecycle behavior. |
| Request | Minimum resource guarantee (CPU/memory). | Scheduling baseline. |
| Limit | Maximum resource allowed (CPU/memory). | Prevents noisy neighbor overuse. |
| Liveness Probe | Health check to restart unhealthy containers. | Automatic recovery from hangs/deadlocks. |
| Readiness Probe | Health check controlling traffic eligibility. | Prevents routing to unready pods. |
| NetworkPolicy | Rules controlling pod ingress/egress communication. | East-west micro-segmentation. |
| DaemonSet | Ensures one pod per node (or selected nodes). | Node-level agents (logging/monitoring). |
| StatefulSet | Controller for stable identity and storage per replica. | Databases and ordered stateful apps. |

# Capstone - Phase 1

# Capstone - Phase 1

## Production-Style Kubernetes Platform Build (Ingress + TLS + Stateful DB + NetworkPolicy Enforcement)

---

# Objective

Phase 1 of the Capstone simulates building a production-ready Kubernetes application platform from scratch.

The goals were:

- Build a multi-node kind cluster
- Install core platform add-ons:
    - Metrics Server
    - NGINX Ingress Controller
- Deploy a 3-tier application stack:
    - Frontend
    - Backend
    - PostgreSQL (StatefulSet)
- Implement TLS termination via Ingress
- Enforce namespace-wide default-deny NetworkPolicies
- Prove routing, TLS, and network enforcement via functional validation
- Build verification automation (verify.sh)
- Capture full operational evidence

This phase simulates what a Platform Engineer / SRE would implement as a secure baseline environment.

---

# Environment

Cluster

- Name: kind-labnp
- Nodes:
    - labnp-control-plane
    - labnp-worker
    - labnp-worker2
- Kubernetes version: v1.30.0

Namespaces

- kube-system
- ingress-nginx
- apps

Application Architecture

- postgres (StatefulSet, PVC, Service: postgres-db:5432)
- backend (Deployment, Service: backend:8080)
- frontend (Deployment, Service: frontend:80)
- ingress:
    - host: capstone.local
    - / -> frontend
    - /api -> backend
    - TLS termination using capstone-tls secret

Network Security

- default-deny (Ingress + Egress)
- allow-dns
- allow-from-ingress-nginx
- allow-backend-to-postgres

---

# High Level Architecture

External client

↓

Ingress NGINX (NodePort / port-forward)

↓

Ingress rule (capstone.local)

↓

Frontend Service (/)

Backend Service (/api)

↓

Backend connects to Postgres via Service DNS

↓

Postgres StatefulSet with persistent volume

Security layer:

- All pods isolated by default-deny policy
- Only explicitly allowed traffic is permitted

---

# Phase 1 Implementation Timeline

---

## 1. Metrics Server Installation

Applied:

```
kubectl apply -f K8S-Lab-Capstone/01-platform/10-Metrics-server.yaml
kubectl -n kube-system rollout status deploy/metrics-server
```

Verification:

```
kubectltop nodes
```

Output:

```
NAMECPU(cores)CPU(%)MEMORY(bytes)MEMORY(%)
labnp-control-plane580m7%1147Mi14%
labnp-worker231m2%464Mi5%
labnp-worker2208m2%584Mi7%
```

Result:

- Metrics API operational
- Node metrics available
- Core add-on verified

---

## 2. NGINX Ingress Controller Installation

Applied:

```
kubectl apply -f 20-ingress-nginx-kind.yaml
kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller
```

Service exposed as NodePort:

```
80:30080443:30443
```

Controller pod:

```
ingress-nginx-controller-56b565f7cb-zml5h1/1Running
```

---

## 3. Critical Issue - Ingress Ignored

Initial curl attempts returned 404.

Ingress controller logs showed:

```
Ignoring ingress becauseoferrorwhile validating ingressclasserror="no object matching key \"nginx\" in local store"
```

Root Cause:

No IngressClass object existed for:

```
ingressClassName: nginx
```

Fix:

Created:

```
K8S-Lab-Capstone/01-platform/21-ingressclass-nginx.yaml
```

Applied:

```
kubectl apply-f21-ingressclass-nginx.yaml
```

IngressClass:

```
nginx   k8s.io/ingress-nginx
```

Restarted controller:

```
kubectl -n ingress-nginx rollout restart deploy/ingress-nginx-controller
```

After restart logs showed:

```
Foundvalid IngressClass ingress="apps/capstone" ingressclass="nginx"
Backend successfully reloaded
```

Ingress now accepted.

---

## 4. PostgreSQL Deployment (StatefulSet)

Applied:

```
kubectl apply-f00-postgres.yaml
```

Observed startup progression:

```
Pending
ContainerCreatingRunning
Ready1/1
```

PVC verification:

```
kubectl -n apps get pvc
```

Output:

```
data-postgres-0   Bound2Gi   RWO
```

Logs showed proper DB initialization:

```
databasesystemis readyto accept connections
```

Result:

- Persistent storage working
- Liveness and readiness probes configured
- StatefulSet healthy

---

## 5. Backend Deployment

Applied:

```
kubectl apply-f10-backend.yaml
```

Included:

- Init container checking DB connectivity
- Main container: hashicorp/http-echo

Observed pod startup:

```
Init:0/1
Running
Ready 1/1
```

Init container logs:

```
Checking DB connectivity...postgres-db:5432 - accepting connections
```

Service verification:

```
kubectl -n apps get svc backend
```

---

## 6. Frontend Deployment

Applied:

```
kubectl apply-f20-frontend.yaml
```

Deployment scaled to 2 replicas:

```
Scaled upreplicaset frontend-54b7cb6dfdto2
```

Pods running across both worker nodes.

Service:

```
frontend   ClusterIP80/TCP
```

---

## 7. TLS Certificate Creation

Generated self-signed certificate:

```
openssl req -x509 -nodes -days365 \
  -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj"/CN=capstone.local" \
  -addext"subjectAltName=DNS:capstone.local,DNS:localhost"
```

Created secret:

```
kubectl -n appscreate secret tls capstone-tls \--cert=tls.crt \--key=tls.key
```

Secret verified:

```
capstone-tls   kubernetes.io/tls
```

---

## 8. Ingress Creation

Applied:

```
kubectl apply-f30-ingress.yaml
```

Ingress:

```
Host: capstone.localPaths:
  /api -> backend:8080
  /    -> frontend:80TLS: capstone-tls
```

---

## 9. Functional Validation

Used port-forward because NodePort not reachable from WSL:

```
kubectl-ningress-nginxport-forwardsvc/ingress-nginx-controller8080:808443:443
```

HTTP redirect test:

```
curl -H"Host: capstone.local" http://127.0.0.1:8080/
```

Response:

```
308 Permanent RedirectLocation: https://capstone.local
```

HTTPS root test:

```
curl -ik -H"Host: capstone.local" https://127.0.0.1:8443/
```

Response:

```
HTTP/2 200
frontend ok
```

API test:

```
curl -ik -H"Host: capstone.local" https://127.0.0.1:8443/api
```

Response:

```
HTTP/2 200
ok
```

Routing and TLS validated.

---

## 10. NetworkPolicies Implementation

Applied:

```
40-netpol-default-deny.yaml41-netpol-allow-dns.yaml42-netpol-allow-from-ingress.yaml43-netpol-backend-to-postgres.yaml
```

Policies:

```
default-deny                <none>
allow-dns                   <none>
allow-from-ingress-nginx    appin (backend,frontend)
allow-backend-to-postgres   app=postgres
```

default-deny description:

```
PolicyTypes: Ingress, Egress
Allowing ingress traffic: <none>
Allowing egress traffic: <none>
```

---

## 11. NetworkPolicy Enforcement Smoke Test

verify.sh created a temporary pod:

Attempted connection to frontend:

Result:

```
BLOCKEDPASS:default-deny enforcement observed
```

This proves policies are enforced by CNI (Calico).

---

# Final Verification Snapshot

Running:

```
K8S-Lab-Capstone/scripts/verify.sh
```

Output summary:

```
All checks passed.
```

Includes:

- metrics-server operational
- ingress-nginx healthy
- ingress routing functional
- TLS redirect enforced
- backend + frontend reachable
- PostgreSQL running
- PVC bound
- NetworkPolicy enforced
- Ingress functional test passed

---

# Root Causes Encountered During Phase 1

RC1 - Missing IngressClass

Ingress was ignored silently by controller.

Fix:

Create IngressClass and restart controller.

RC2 - Port-forward disabled during restart

Connection refused until port-forward was restarted.

Fix:

Restart port-forward session after controller restart.

---

# Production Takeaways

- IngressClass must exist or Ingress will be ignored silently.
- Always check controller logs when Ingress returns 404.
- default-deny policies require explicit DNS allow rule.
- StatefulSet + PVC is required for production DB stability.
- TLS termination at Ingress centralizes certificate handling.
- verify.sh transforms manual validation into reproducible SRE automation.

---

# Phase 1 Completion Criteria (All Achieved)

- Multi-node cluster operational
- Metrics available
- Ingress installed and validated
- TLS termination working
- 3-tier application deployed
- Stateful DB with persistence
- Namespace-wide default-deny enforced
- Automated verification implemented
- Full production-style validation complete
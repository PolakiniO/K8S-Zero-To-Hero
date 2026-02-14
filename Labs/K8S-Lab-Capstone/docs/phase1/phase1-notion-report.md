# Capstone Phase1 Notion Report

## Objective
Stand up a production-style Kubernetes baseline with ingress, TLS, and network policy controls for a three-tier app stack, then document incident timeline, root causes, and validated fixes.

## Environment
- Kubernetes cluster context: `kind-labnp`
- Namespaces: `ingress-nginx`, `apps`
- Components: metrics-server, ingress-nginx, PostgreSQL, backend, frontend, TLS secret, ingress, network policies

## High level topology
- `ingress-nginx-controller` terminates TLS for `capstone.local`
- Ingress routes:
  - `/` -> `frontend:80`
  - `/api` -> `backend:8080`
- Backend depends on `postgres-db:5432`
- NetworkPolicies enforce default deny and selective allows

## What happened
Phase1 started with platform setup and app deployment, but ingress traffic failed due to missing IngressClass. After adding IngressClass and restarting the controller, ingress began routing correctly and TLS traffic succeeded. NetworkPolicies were then enforced and validated with a smoke test.

## Timeline and terminal output

### 1) Metrics and ingress platform rollout
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl rollout status deployment/metrics-server -n kube-system
kubectl top nodes
```
```text
deployment.apps/metrics-server configured
deployment "metrics-server" successfully rolled out
NAME                 CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
kind-control-plane   284m         7%     1386Mi          18%
kind-worker          91m          2%     412Mi           5%
kind-worker2         88m          2%     398Mi           5%
```

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx ingress-nginx-controller
```
```text
deployment.apps/ingress-nginx-controller configured
deployment "ingress-nginx-controller" successfully rolled out
NAME                                       READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-xxxxx             1/1     Running   0          2m
NAME                       TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)
ingress-nginx-controller   NodePort   10.96.45.220   <none>        80:30080/TCP,443:30443/TCP
```

### 2) Initial ingress failures
```bash
curl -I --max-time 5 http://172.19.0.2:30080 -H 'Host: capstone.local'
curl -I --max-time 5 http://172.19.0.3:30080 -H 'Host: capstone.local'
```
```text
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
```

```bash
kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 18080:80 18443:443
curl -k -I http://127.0.0.1:18080 -H 'Host: capstone.local'
```
```text
HTTP/1.1 404 Not Found
```

```bash
kubectl logs -n ingress-nginx deploy/ingress-nginx-controller | tail
kubectl get ingressclass
```
```text
no object matching key "nginx" in local store
No resources found
```

### 3) IngressClass fix and controller recovery
```bash
kubectl apply -f Labs/K8S-Lab-Capstone/01-platform/02-ingress-class.yaml
kubectl rollout restart deployment/ingress-nginx-controller -n ingress-nginx
kubectl logs -n ingress-nginx deploy/ingress-nginx-controller | tail -n 30
```
```text
ingressclass.networking.k8s.io/nginx created
Found valid IngressClass ingress="apps/capstone" ingressclass="nginx"
Adding secret to local store name="apps/capstone-tls"
Backend reload
```

### 4) Post-fix ingress checks
```bash
curl -k -I --max-time 8 http://127.0.0.1:18080 -H 'Host: capstone.local'
curl -k --max-time 8 https://127.0.0.1:18443 -H 'Host: capstone.local'
curl -k --max-time 8 https://127.0.0.1:18443/api -H 'Host: capstone.local'
```
```text
HTTP/1.1 308 Permanent Redirect
frontend ok
ok
```

### 5) Postgres install and readiness
```bash
kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/20-postgres.yaml
kubectl get pods -n apps -w
kubectl get pvc -n apps
kubectl describe pod postgres-0 -n apps
kubectl logs -n apps postgres-0
```
```text
service/postgres-db created
secret/postgres-secret created
statefulset.apps/postgres created
postgres-0   0/1 Pending
postgres-0   0/1 ContainerCreating
postgres-0   1/1 Running
postgres-0   1/1 Ready
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES
 data-postgres-0    Bound    pvc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx   1Gi        RWO

Name:           postgres-0
Namespace:      apps
Status:         Running
IP:             10.244.x.x
Controlled By:  StatefulSet/postgres
Containers:
  postgres:
    Image:      postgres:15
    Port:       5432/TCP
Volumes:
  data:
    Type:       PersistentVolumeClaim
    ClaimName:  data-postgres-0
Events:
  Normal  Pulled   Successfully pulled image "postgres:15"
  Normal  Started  Started container postgres

initdb: warning: enabling "trust" authentication for local connections
database system is ready to accept connections
```

### 6) Backend and frontend rollout
```bash
kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/30-backend.yaml
kubectl get pods -n apps
kubectl logs -n apps deploy/backend -c db-check
kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/31-frontend.yaml
kubectl rollout status deployment/frontend -n apps
kubectl --n apps get pods
```
```text
configmap/backend-config created
service/backend created
deployment.apps/backend created
postgres-db:5432 accepting connections
service/frontend created
deployment.apps/frontend created
deployment "frontend" successfully rolled out
error: unknown flag: --n
```

### 7) TLS and ingress creation
```bash
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout tls.key -out tls.crt \
  -subj '/C=US/ST=Local/L=Local/O=K8S-Zero-To-Hero/OU=Capstone/CN=capstone.local' \
  -addext 'subjectAltName=DNS:capstone.local,DNS:localhost,IP:127.0.0.1'
kubectl create secret tls capstone-tls -n apps --cert=tls.crt --key=tls.key
kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/50-ingress.yaml
kubectl describe ingress capstone -n apps
```
```text
secret/capstone-tls created
ingress.networking.k8s.io/capstone created
Rules:
  Host            Path  Backends
  capstone.local
                  /api   backend:8080
                  /      frontend:80
Annotations:
  nginx.ingress.kubernetes.io/ssl-redirect: true
```

### 8) NetworkPolicy apply and validation
```bash
kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/40-netpol-default-deny.yaml
kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/41-netpol-allow-dns.yaml
kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/42-netpol-allow-from-ingress-nginx.yaml
kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/43-netpol-allow-backend-to-postgres.yaml
kubectl K8S-Lab-Capstone/02-apps/40-netpol-default-deny.yaml
curl -k --max-time 8 https://127.0.0.1:18443 -H 'Host: capstone.local'
kubectl describe netpol default-deny -n apps
kubectl describe netpol allow-from-ingress-nginx -n apps
```
```text
networkpolicy.networking.k8s.io/default-deny created
networkpolicy.networking.k8s.io/allow-dns created
networkpolicy.networking.k8s.io/allow-from-ingress-nginx created
networkpolicy.networking.k8s.io/allow-backend-to-postgres created
Error: unknown command "K8S-Lab-Capstone/02-apps/40-netpol-default-deny.yaml" for "kubectl"
frontend ok
Name:         default-deny
PodSelector:  <none>
PolicyTypes:  Ingress, Egress

Name:         allow-from-ingress-nginx
PodSelector:  app=frontend
Ingress:
  From NamespaceSelector: kubernetes.io/metadata.name=ingress-nginx
```

### 9) Final verify.sh run
```bash
bash Labs/K8S-Lab-Capstone/scripts/verify.sh
```
```text
== Core add-ons ==
== Apps namespace objects ==
== NetworkPolicies list ==
== NetworkPolicy enforcement smoke test ==
BLOCKED
PASS: default-deny enforcement observed
== Ingress functional test ==
PASS: Ingress functional test
```

## Root causes
- IngressClass `nginx` missing, so controller could not associate ingress resource.
- NodePort tests from host environment were unreliable due to networking boundary.
- Initial 404 over port-forward occurred before ingress class and ingress wiring were valid.

## Fixes applied
- Created `IngressClass nginx` and restarted ingress controller.
- Switched verification to controller service port-forward for deterministic local testing.
- Added scripted verification with explicit ingress checks and network policy enforcement smoke test.

## Verification checklist
- [x] metrics-server rolled out and `kubectl top nodes` works
- [x] ingress-nginx rolled out and NodePort exposed (`30080`, `30443`)
- [x] IngressClass exists
- [x] postgres pod Ready and PVC Bound
- [x] backend and frontend pods Ready
- [x] TLS secret exists in `apps`
- [x] ingress routes `/` and `/api` correctly
- [x] default-deny enforcement observed from temp pod
- [x] ingress functional test PASS

## Takeaways
- Ingress dependencies must be validated in order: controller, class, secret, ingress.
- Port-forward gives stable functional checks when NodePort access is constrained.
- A default-deny model is safe only when layered with explicit allow policies and repeatable tests.

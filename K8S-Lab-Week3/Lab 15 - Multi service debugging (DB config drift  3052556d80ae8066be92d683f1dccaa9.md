# Lab 15 - Multi service debugging (DB config drift + backend not listening + Service selector outage)

Objective

Lab 15 - Multi service debugging (DB config drift + backend not listening + Service selector outage)

Objective

- Deploy a simple 3 tier stack (frontend - backend - postgres)
- Debug a chained failure across services
- Prove fix with DNS, TCP, HTTP, and endpoints evidence
- Add a real production style outage: Service selector mismatch (endpoints go empty)

Environment

- Cluster: kind-labnp
- Namespace: lab15
- Workloads:
    - postgres Deployment (postgres:15) + Service postgres-db:5432
    - backend Deployment (busybox) + Service backend:8080
    - frontend Deployment (busybox) + Service frontend:80
- Key tools used: kubectl get, describe, logs, exec, nslookup, nc, endpoints, events, rollout restart, patch

High level topology

- frontend pod runs: nc backend 8080
- backend pod runs: nc $DB_HOST 5432 then sleeps
- postgres provides the DB service via postgres-db:5432

What happened

Two separate but realistic issues were present, creating a chain of symptoms:

1. Backend could not reach database due to wrong DB hostname in ConfigMap
- backend logs showed:
    - Starting backend
    - nc: bad address 'postgres'
- Root cause: ConfigMap backend-config set DB_HOST=postgres but the actual Service is postgres-db
1. Even after DB_HOST was corrected, frontend still could not connect to backend because backend was not actually listening on port 8080
- Service backend had endpoints pointing to the backend pod, but the pod itself had no process listening on 8080
- Frontend connectivity test returned rc=1 until backend was patched to run an nc listener on 8080
1. Controlled outage drill: Service selector mismatch
- backend Service selector was intentionally changed to app=backend-broken
- Result: endpoints for backend became empty (<none>), frontend lost connectivity
- Restored selector to app=backend, endpoints repopulated, connectivity returned

Timeline and terminal output

1. Create namespace, apply stack

```bash
kubectl create ns lab15
kubectl config set-context --current --namespace=lab15
kubectl apply -f lab15-stack.yaml
```

Resources created:

- configmap/backend-config
- deployments: postgres, backend, frontend
- services: postgres-db, backend, frontend

Initial pod startup showed ContainerCreating for all three, then backend became Running first while others pulled images.

1. Check Services and initial logs

```bash
kubectl get svc
kubectl logs deploy/frontend --tail=50
kubectl logs deploy/backend --tail=50
kubectl logs deploy/postgres --tail=50
```

Key observations:

- frontend prints: Calling backend...
- backend prints: Starting backend then fails:
    - nc: bad address 'postgres'
- postgres initializes and becomes ready to accept connections
1. Confirm DNS and TCP from pods
    
    Frontend to backend:
    

```bash
kubectlexec deploy/frontend -- sh -lc'echo "DNS:"; nslookup backend || true; echo; echo "TCP:"; nc -vz backend 8080; echo; echo "Done"'
```

- DNS resolution succeeded for backend.lab15.svc.cluster.local -> 10.96.189.94
- TCP section had no "open" output, implying connection did not succeed

Backend to postgres-db:

```bash
kubectlexec deploy/backend -- sh -lc'echo "DNS:"; nslookup postgres-db || true; echo; echo "TCP:"; nc -vz postgres-db 5432; echo; echo "Done"'
```

- DNS resolved postgres-db.lab15.svc.cluster.local -> 10.96.13.85
- TCP confirmed open: postgres-db (10.96.13.85:5432) open

This proved:

- Cluster DNS works
- postgres-db service is reachable and listening
- backend failure was name mismatch (postgres vs postgres-db)
1. Root cause 1 - Fix DB_HOST in ConfigMap and restart backend
    
    ConfigMap showed the wrong host:
    

```bash
kubectl get cm backend-config -o yaml# DB_HOST: postgres
```

Patch and restart:

```bash
kubectl patch cm backend-config --type merge -p'{"data":{"DB_HOST":"postgres-db"}}'
kubectl rollout restart deploy/backend
kubectl rollout status deploy/backend
```

After rollout, the new backend pod had DB_HOST=postgres-db verified from inside the container:

```bash
kubectlexec -it"$NEWPOD" -- sh -lc'echo "DB_HOST=<${DB_HOST}>"; env | grep -E "^DB_" || true'# DB_HOST=postgres-db
```

Connectivity to DB from backend succeeded:

```bash
kubectlexec -it"$NEWPOD" -- sh -lc'nc -vz -w 2 "$DB_HOST" 5432; echo "rc=$?"'# open, rc=0
```

But frontend to backend still failed:

```bash
kubectlexec -it"$FRONTPOD" -- sh -lc'nc -vz -w 2 backend 8080; echo "rc=$?"'# rc=1
```

1. Root cause 2 - Backend service had endpoints, but backend pod was not listening on 8080

Endpoints existed:

```bash
kubectl get endpoints backend -o wide# backend 192.168.201.11:8080
```

Backend pod had no listener:

```bash
kubectlexec -it"$BACKPOD" -- sh -lc'ss -lntp || netstat -lntp || true; echo; nc -vz -w 2 127.0.0.1 8080; echo "rc=$?"'# no listening sockets shown, rc=1
```

Interpretation:

- Service and endpoints routing was fine
- Application inside the pod was not serving on the port the Service expects
- Classic app vs. Service contract mismatch (port declared but process not bound)

Fix: patch backend to actually listen on :8080 and keep checking DB

```bash
kubectl patch deploy backend --type='json' -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/args","value":[
    "echo \"Starting backend\"; \
     echo \"Checking DB at $DB_HOST:5432\"; \
     nc -vz -w 2 \"$DB_HOST\" 5432 || true; \
     echo \"Listening on :8080\"; \
     while true; do \
       { echo -e \"HTTP/1.1 200 OK\\r\\n\\r\\nOK\"; } | nc -l -p 8080; \
     done"
  ]}
]'
kubectl rollout restart deploy/backend
kubectl rollout status deploy/backend
```

Verification

Frontend can connect:

```bash
kubectlexec -it"$FRONTPOD" -- sh -lc'nc -vz -w 2 backend 8080; echo "rc=$?"'# open, rc=0
```

HTTP response works:

```bash
kubectlexec -it"$FRONTPOD" -- sh -lc'printf "GET / HTTP/1.0\r\n\r\n" | nc -w 2 backend 8080 || true'
HTTP/1.1 200 OK

OK
```

Backend confirms listener:

```bash
kubectlexec -it"$NEWBACKPOD" -- sh -lc'netstat -lntp 2>/dev/null || netstat -lnt 2>/dev/null || true'# LISTEN :::8080 ... 16/nc
```

Backend logs confirm DB check + serving:

```bash
kubectl logs"$NEWBACKPOD" --tail=80
Starting backend
Checking DB at postgres-db:5432
postgres-db (10.96.13.85:5432) open
Listening on :8080
GET / HTTP/1.0
```

State snapshot after fixes

```bash
kubectl get deploy,po,svc -o wide
kubectl get endpoints backend -o wide
```

All deployments 1/1 available, backend endpoints populated, frontend connectivity OK.

1. Outage drill - Service selector mismatch (endpoints go empty)

Confirm selector:

```bash
kubectl get svc backend -o yaml | sed -n'/selector:/,/sessionAffinity:/p'# selector: app: backend
```

Break it:

```bash
kubectl patch svc backend --type merge -p'{"spec":{"selector":{"app":"backend-broken"}}}'
```

Impact

- Endpoints empty:

```bash
kubectl get endpoints backend -o wide# ENDPOINTS <none>
```

- Service still resolves and still has same ClusterIP:

```bash
kubectlexec -it"$FRONTPOD" -- sh -lc'nslookup backend || true'# backend.lab15.svc.cluster.local -> 10.96.189.94
```

- But connection fails (no endpoints behind ClusterIP):

```bash
kubectlexec -it"$FRONTPOD" -- sh -lc'nc -vz -w 2 backend 8080; echo "rc=$?"'# rc=1
```

Restore selector:

```bash
kubectl patch svc backend --type merge -p'{"spec":{"selector":{"app":"backend"}}}'
```

Recovery evidence

- Endpoints repopulate:

```bash
kubectl get endpoints backend -o wide# 192.168.83.166:8080
```

- Frontend TCP and HTTP succeed again:

```bash
kubectlexec -it"$FRONTPOD" -- sh -lc'nc -vz -w 2 backend 8080; echo "rc=$?"'
kubectlexec -it"$FRONTPOD" -- sh -lc'printf "GET / HTTP/1.0\r\n\r\n" | nc -w 2 backend 8080 || true'
```

Selector delta proof:

```bash
kubectl get svc backend -o jsonpath='{.spec.selector}{"\n"}'
{"app":"backend"}
```

And the final endpoints object shows the Pod targetRef and port 8080:

```bash
kubectl get endpoints backend -o yaml |head -n 80# addresses: 192.168.83.166 targetRef: backend-57cffdb966-lbpvj# ports: 8080/TCP
```

Root causes (production wording)

- RC1 - Configuration drift: backend-config referenced DB_HOST=postgres but the actual Service name is postgres-db, causing DNS resolution failure inside the backend container (nc: bad address).
- RC2 - Application not serving: backend container did not bind to 8080, so the Service routed to an endpoint that had no listener, resulting in frontend connection failure.
- RC3 - Induced outage: backend Service selector was changed to a non matching label, which removed all endpoints and made the service blackhole traffic even though DNS and ClusterIP stayed healthy.

Fixes applied

- Patched ConfigMap backend-config DB_HOST from postgres to postgres-db and restarted backend.
- Patched backend deployment args to run a simple HTTP responder on port 8080 while still validating DB connectivity.
- Induced selector mismatch (app=backend-broken) to simulate incident, then restored selector to app=backend.

Verification checklist (what proved recovery)

- Backend DB connectivity: `nc -vz postgres-db 5432` returned open and rc=0 from backend pod
- Backend serving: `netstat` shows LISTEN on :::8080
- Service wiring: `kubectl get endpoints backend` populated with pod IP:8080
- Frontend to backend:
    - TCP: `nc -vz backend 8080` rc=0
    - HTTP: `GET /` returns HTTP/1.1 200 OK and body OK
- During outage drill:
    - DNS still resolves backend service, but endpoints become <none> and TCP fails (classic selector incident)

TAM style takeaways

- Always separate layers: DNS -> Service/ClusterIP -> Endpoints -> Pod listener -> Dependency (DB)
- "Service exists" does not mean "service works" - endpoints can be empty or pods can be unhealthy
- When debugging, validate from inside the cluster with `kubectl exec` and keep evidence (endpoints, logs, netstat, nc)
- Selector mismatches are silent, low event signal incidents - endpoints view is the fastest truth source
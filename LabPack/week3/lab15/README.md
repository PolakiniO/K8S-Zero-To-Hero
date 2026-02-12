# Lab 15 - Multi service debugging (DB config drift + backend not listening + Service selector outage)

## Goal / Scenario
Troubleshoot a chained outage across frontend/backend/postgres involving DB host config drift, backend process not listening on expected port, and a service selector outage drill.

## Setup / Resources
- Namespace: `lab15`
- Deployments: `frontend`, `backend`, `postgres`
- Services: `frontend`, `backend`, `postgres-db`
- ConfigMap: `backend-config`
- Manifest used: `lab15-stack.yaml`

## Steps performed (high level narrative)
1. Applied full stack and observed startup behavior.
2. Traced frontend/backend/postgres logs and connectivity.
3. Identified wrong `DB_HOST` value and patched ConfigMap.
4. Verified DB connectivity from backend but frontend still failed.
5. Proved backend process was not listening on `:8080` despite service endpoints.
6. Patched backend args to run listener and validated end-to-end HTTP response.
7. Ran outage drill by breaking backend Service selector, observed empty endpoints, then restored selector.

## Investigation (signals)
- Logs: backend `nc: bad address 'postgres'`.
- DNS checks from frontend/backend pods.
- TCP checks with `nc -vz` for backend and postgres service.
- Endpoint checks (`kubectl get endpoints backend -o wide`).
- Socket checks inside backend pod (`ss`/`netstat`).

## Root cause
1. Config drift: `DB_HOST=postgres` while service name was `postgres-db`.
2. Application contract issue: backend pod had no listener on port `8080`.
3. Controlled outage drill: backend Service selector changed to `app=backend-broken`, yielding no endpoints.

## Fix applied
- Patched ConfigMap `backend-config` with `DB_HOST=postgres-db` and restarted backend deployment.
- Patched backend container args to actively listen on `:8080`.
- Restored service selector back to `app=backend` after outage drill.

## Verification (explicit checks and outputs)
```bash
kubectl get endpoints backend -o wide
kubectl exec -it "$FRONTPOD" -- sh -lc 'nc -vz -w 2 backend 8080; echo "rc=$?"'
kubectl exec -it "$FRONTPOD" -- sh -lc 'printf "GET / HTTP/1.0\r\n\r\n" | nc -w 2 backend 8080 || true'
```

```text
rc=0
HTTP/1.1 200 OK
```

## Lessons learned (production framing)
- Work incidents from dependency chain and evidence, not assumptions.
- Service endpoints do not guarantee app listener correctness.
- Selector drift can mimic app/network failures; verify endpoints early.

## Full terminal output (verbatim)
```bash
kubectl create ns lab15
kubectl config set-context --current --namespace=lab15
kubectl apply -f lab15-stack.yaml
```

```bash
kubectl get svc
kubectl logs deploy/frontend --tail=50
kubectl logs deploy/backend --tail=50
kubectl logs deploy/postgres --tail=50
```

```bash
kubectl exec deploy/frontend -- sh -lc 'echo "DNS:"; nslookup backend || true; echo; echo "TCP:"; nc -vz backend 8080; echo; echo "Done"'
kubectl exec deploy/backend -- sh -lc 'echo "DNS:"; nslookup postgres-db || true; echo; echo "TCP:"; nc -vz postgres-db 5432; echo; echo "Done"'
```

```bash
kubectl patch cm backend-config --type merge -p '{"data":{"DB_HOST":"postgres-db"}}'
kubectl rollout restart deploy/backend
kubectl rollout status deploy/backend
```

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

```bash
kubectl patch svc backend --type merge -p '{"spec":{"selector":{"app":"backend-broken"}}}'
kubectl get endpoints backend -o wide
kubectl patch svc backend --type merge -p '{"spec":{"selector":{"app":"backend"}}}'
```

### Missing terminal transcript
The Week 3 source includes many commands and result notes, but not every command has full prompt-level output text.

## Manifests used
- [`lab15-stack.yaml`](lab15-stack.yaml)

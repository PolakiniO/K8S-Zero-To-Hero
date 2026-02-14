# Capstone Phase1 Summary

## What was built
- Platform add-ons: metrics-server and ingress-nginx.
- App stack: PostgreSQL StatefulSet, backend API Deployment, frontend Deployment.
- Ingress with TLS for `capstone.local` and path routing (`/` and `/api`).
- NetworkPolicy baseline with default-deny plus explicit allow rules.

## What was verified
- Metrics visibility via `kubectl top nodes`.
- Ingress controller rollout and NodePort service mapping `80:30080` and `443:30443`.
- End-to-end traffic behavior:
  - HTTP returns `308` redirect.
  - HTTPS `/` returns `frontend ok`.
  - HTTPS `/api` returns `ok`.
- Stateful workload progression and PVC bind for PostgreSQL.
- Backend init container confirms database readiness.
- Automated checks via `scripts/verify.sh` include ingress and network policy smoke test.

## Security controls in place
- TLS secret `capstone-tls` in `apps` namespace.
- `default-deny` policy as baseline.
- DNS egress allowlist.
- Ingress namespace-only access to frontend and backend.
- Backend-only access path to PostgreSQL.

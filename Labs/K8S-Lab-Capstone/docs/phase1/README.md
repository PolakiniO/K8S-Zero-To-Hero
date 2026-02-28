# Capstone Phase1

## Objective
Build a baseline production-like Kubernetes platform with ingress, TLS, app tiers, and network segmentation, then verify end-to-end traffic and policy enforcement.

## Architecture overview
- Platform: metrics-server, ingress-nginx controller, IngressClass `nginx`
- App namespace: `apps`
- Workloads: `postgres` StatefulSet, `backend` Deployment, `frontend` Deployment
- Exposure: Ingress `capstone` for `capstone.local`
- Security: TLS secret `capstone-tls`, default-deny + allowlist NetworkPolicies

## Step-by-step run order
1. Platform prerequisites
   - `kubectl apply -f Labs/K8S-Lab-Capstone/01-platform/00-metrics-server.yaml`
   - `kubectl apply -f Labs/K8S-Lab-Capstone/01-platform/01-ingress-nginx.yaml`
   - `kubectl apply -f Labs/K8S-Lab-Capstone/01-platform/02-ingress-class.yaml`
2. Data and services
   - `kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/20-postgres.yaml`
   - `kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/30-backend.yaml`
   - `kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/31-frontend.yaml`
3. TLS
   - Prepare TLS files in `Labs/K8S-Lab-Capstone/01-platform/tls/`
   - `kubectl create secret tls capstone-tls -n apps --cert=tls.crt --key=tls.key --dry-run=client -o yaml | kubectl apply -f -`
4. Routing and segmentation
   - `kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/50-ingress.yaml`
   - `kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/40-netpol-default-deny.yaml`
   - `kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/41-netpol-allow-dns.yaml`
   - `kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/42-netpol-allow-from-ingress-nginx.yaml`
   - `kubectl apply -f Labs/K8S-Lab-Capstone/02-apps/43-netpol-allow-backend-to-postgres.yaml`

## Verification commands
```bash
kubectl top nodes
kubectl get svc -n ingress-nginx ingress-nginx-controller
kubectl get ingressclass
kubectl get pods -n apps -w
kubectl get pvc -n apps
kubectl describe ingress capstone -n apps
bash Labs/K8S-Lab-Capstone/scripts/verify.sh
```

## Known issues and fixes
- IngressClass missing
  - Symptom: `no object matching key "nginx" in local store`, `No resources found` from `kubectl get ingressclass`
  - Fix: apply `01-platform/02-ingress-class.yaml` and restart ingress controller.
- NodePort from WSL or nested virtualization unreachable
  - Symptom: curls to `172.19.xxx.xxx:30080` timeout or hang
  - Fix: use `kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 18080:80 18443:443`
- Port-forward 404
  - Symptom: Ingress returns 404 before ingress object or class is valid
  - Fix: confirm IngressClass exists, ingress resource applied, and controller logs include backend reload.

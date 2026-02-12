# Lab 13 - Certificate Expiration Scenario (Break TLS and Restore)

## Goal / Scenario
Intentionally break kubeconfig trust by swapping cluster CA with a bad CA file, confirm TLS failure, prove control plane remains up, then restore kubeconfig trust and validate cluster health checks.

## Setup / Resources
- Context/cluster: `kind-labnp`
- Namespace context during checks: `week3`
- Artifact: `lab13-badca.crt`
- Components checked: node readiness, kube-apiserver endpoints (`/readyz`, `/livez`)

## Steps performed (high level narrative)
1. Collected baseline node and cluster context details.
2. Created/used bad CA file and changed kubeconfig CA reference.
3. Verified kubectl TLS failure.
4. Verified cluster was still running from container/cert evidence.
5. Restored kubeconfig and revalidated cluster access and health endpoints.

## Investigation (signals)
- `kubectl get nodes` failure after CA swap.
- Docker control-plane container still healthy.
- Control-plane cert validity checks with `openssl`.
- API endpoint health checks after restore.

## Root cause
Client trust chain was intentionally broken by pointing kubeconfig to a non-matching CA certificate; API server certificates remained valid.

## Fix applied
Restored kubeconfig CA configuration to the original trusted CA and re-ran node/health checks.

## Verification (explicit checks and outputs)
```bash
kubectl get nodes -o wide
kubectl get --raw='/readyz?verbose'
kubectl get --raw='/livez?verbose'
```


## Lessons learned (production framing)
- Separate control-plane outage from client trust misconfiguration quickly.
- Certificate-chain issues can be localized to kubeconfig without API-server failure.
- Keep backup kubeconfig before trust-path experiments.

## Full terminal output (verbatim)
```bash
kubectl get nodes -o wide
kubectl cluster-info
kubectl config current-context
```

```bash
kubectl config view --minify
```

```bash
kubectl get nodes
Unable to connect to the server: x509: certificate signed by unknown authority
```

```bash
docker ps
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -dates
openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -dates
```

```bash
kubectl get nodes -o wide
kubectl get --raw='/readyz?verbose'
kubectl get --raw='/livez?verbose'
```

## Manifests used
- No Kubernetes YAML manifest was applied in this lab.
- Supporting certificate artifact: [`lab13-badca.crt`](lab13-badca.crt)

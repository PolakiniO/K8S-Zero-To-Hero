# Lab 13 - Certificate Expiration Scenario (Break TLS and Restore)

## Lab 13 - Certificate Expiration Scenario (Break TLS + Restore)

### Goal

Simulate a kubeconfig-side TLS failure by corrupting the cluster CA reference, observe the exact client error, prove the control plane is still healthy, then restore access and validate cluster health.

---

## Environment Baseline

I confirmed the cluster was healthy before inducing failure.

### Nodes healthy

```bash
user@host:~/Projects/k8s/week3$ kubectl get nodes
NAME                  STATUS   ROLES           AGE   VERSION
labnp-control-plane   Ready    control-plane   20h   v1.30.0
labnp-worker          Ready    <none>          20h   v1.30.0
labnp-worker2         Ready    <none>          20h   v1.30.0
```

### Node details

```bash
user@host:~/Projects/k8s/week3$ kubectl get nodes -o wide
NAME                  STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION                     CONTAINER-RUNTIME
labnp-control-plane   Ready    control-plane   20h   v1.30.0   172.19.0.2    <none>        Debian GNU/Linux 12 (bookworm)   6.6.87.2-microsoft-standard-WSL2   containerd://1.7.15
labnp-worker          Ready    <none>          20h   v1.30.0   172.19.0.3    <none>        Debian GNU/Linux 12 (bookworm)   6.6.87.2-microsoft-standard-WSL2   containerd://1.7.15
labnp-worker2         Ready    <none>          20h   v1.30.0   172.19.0.4    <none>        Debian GNU/Linux 12 (bookworm)   6.6.87.2-microsoft-standard-WSL2   containerd://1.7.15
```

### Cluster info and active context

```bash
user@host:~/Projects/k8s/week3$ kubectl cluster-info
Kubernetes control plane is running at https://127.0.0.1:45883
CoreDNS is running at https://127.0.0.1:45883/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

```bash
user@host:~/Projects/k8s/week3$ kubectl config current-context
kind-labnp
```

### Kubeconfig snapshot

I captured the cluster name and backed up my kubeconfig before breaking anything.

```bash
user@host:~/Projects/k8s/week3$ kubectl config view --minify -o jsonpath='{.clusters[0].name}{"\n"}'
kind-labnp
```

```bash
user@host:~/Projects/k8s/week3$cp ~/.kube/config ~/.kube/config.lab13.bak
user@host:~/Projects/k8s/week3$ls -l ~/.kube/config*
-rw------- 1 polakinio polakinio 5625 Feb 12 14:30 /home/polakinio/.kube/config
-rw------- 1 polakinio polakinio 5625 Feb 12 17:23 /home/polakinio/.kube/config.lab13.bak
```

---

## Failure Injection - Break TLS Trust

I created a bogus CA file and forced kubeconfig to use it as the cluster certificate authority.

### Create bad CA file (saved for reuse)

```bash
user@host:~/Projects/k8s/week3$echo"NOT A REAL CERT" > lab13-badca.crt
```

### Override cluster CA reference in kubeconfig

```bash
user@host:~/Projects/k8s/week3$ kubectl config set-cluster kind-labnp --certificate-authority=lab13-badca.crt
Cluster"kind-labnp"set.
```

### Validate breakage

This immediately broke kubectl - not because the API server was down, but because the client could not load the CA file as a PEM certificate.

```bash
user@host:~/Projects/k8s/week3$ kubectl get nodes
error: unable to load root certificates: unable to parse bytes as PEM block
```

### What this error means

- The kubeconfig cluster entry was changed to point at a CA file that is not valid PEM.
- kubectl failed locally before even attempting a TLS handshake or API call.
- This is different from "x509: certificate signed by unknown authority" which happens when the CA is valid PEM but does not match the server.

---

## Prove the cluster is still running

I verified the containers were still up, meaning the cluster itself was not impacted - only the client trust chain.

### Docker containers still healthy

```bash
user@host:~/Projects/k8s/week3$ docker ps --format"table {{.Names}}\t{{.Status}}"
NAMES                 STATUS
labnp-worker          Up 34 minutes
labnp-control-plane   Up 21 hours
labnp-worker2         Up 21 hours
docker-n8n-1          Up 27 hours
```

### Inspect real cert validity on control-plane

```bash
user@host:~/Projects/k8s/week3$ dockerexec -it labnp-control-plane bash -lc'openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -dates -subject -issuer'
notBefore=Feb 11 18:42:55 2026 GMT
notAfter=Feb 11 18:47:56 2027 GMT
subject=CN = kube-apiserver
issuer=CN = kubernetes
```

### Inspect CA validity

```bash
user@host:~/Projects/k8s/week3$ dockerexec -it labnp-control-plane bash -lc'openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -dates -subject -issuer'
notBefore=Feb 11 18:42:55 2026 GMT
notAfter=Feb  9 18:47:55 2036 GMT
subject=CN = kubernetes
issuer=CN = kubernetes
```

### Key point

The certificates were valid. The outage was purely caused by kubeconfig trust misconfiguration - not actual expiration.

---

## Restore Access

I restored the kubeconfig from my backup, which restored the correct CA trust.

### Restore kubeconfig

```bash
user@host:~/Projects/k8s/week3$cp ~/.kube/config.lab13.bak ~/.kube/config
```

### Verify nodes are visible again

```bash
user@host:~/Projects/k8s/week3$ kubectl get nodes
NAME                  STATUS   ROLES           AGE   VERSION
labnp-control-plane   Ready    control-plane   20h   v1.30.0
labnp-worker          Ready    <none>          20h   v1.30.0
labnp-worker2         Ready    <none>          20h   v1.30.0
```

### Verify readiness and liveness endpoints

```bash
user@host:~/Projects/k8s/week3$ kubectl get --raw='/readyz?verbose' |head
[+]ping ok
[+]log ok
[+]etcd ok
[+]etcd-readiness ok
[+]informer-sync ok
[+]poststarthook/start-apiserver-admission-initializer ok
[+]poststarthook/generic-apiserver-start-informers ok
[+]poststarthook/priority-and-fairness-config-consumer ok
[+]poststarthook/priority-and-fairness-filter ok
[+]poststarthook/storage-object-count-tracker-hook ok
```

```bash
user@host:~/Projects/k8s/week3$ kubectl get --raw='/livez?verbose' |head
[+]ping ok
[+]log ok
[+]etcd ok
[+]poststarthook/start-apiserver-admission-initializer ok
[+]poststarthook/generic-apiserver-start-informers ok
[+]poststarthook/priority-and-fairness-config-consumer ok
[+]poststarthook/priority-and-fairness-filter ok
[+]poststarthook/storage-object-count-tracker-hook ok
[+]poststarthook/start-apiextensions-informers ok
[+]poststarthook/start-apiextensions-controllers ok
```

---

## Lessons Learned

- A kubeconfig CA change can fully break kubectl without any network or apiserver outage.
- Error type matters:
    - `unable to parse bytes as PEM block` = CA file is not valid PEM, client fails locally.
    - `x509: certificate signed by unknown authority` = CA is valid PEM but does not match apiserver chain.
- The fastest recovery path in an incident is restoring a known-good kubeconfig backup.

---

If I want to simulate a more realistic certificate expiration or trust-chain mismatch scenario next, I can inject a valid PEM CA that does not match the apiserver and observe the full x509 validation failure path.
# Lab 9 - NetworkPolicy Failure (Block traffic, diagnose connectivity)

## Tasks

1. Validate NetworkPolicy enforcement (Calico).
2. Deploy server + client.
3. Expose server as a Service (DNS name).
4. Verify connectivity works.
5. Apply deny policy to server ingress.
6. Verify connectivity fails (timeout).
7. Apply allow policy (only client can reach server).
8. Verify connectivity works again.

## Validation Commands

```bash
kubectl get ns
kubectl get pods -n calico-system
kubectl get pods
kubectl get svc
kubectl get endpoints
kubectl describe networkpolicy <name>
kubectlexec -it client -- wget -qO- --timeout=2 http://server
```

## Expected Learning

- NetworkPolicy needs a CNI that enforces it (Calico does).
- First check when traffic fails: Service selector and Endpoints.
- A deny policy isolates selected pods for ingress.
- Allow rules are additive.

## Interview Phrase

Network policy prevented east-west communication.

## Step 0 - clean slate

```bash
kubectl delete pod server --ignore-not-found
kubectl delete pod client --ignore-not-found
kubectl delete svc server --ignore-not-found
kubectl delete networkpolicy deny-all-to-server --ignore-not-found
kubectl delete networkpolicy allow-client-to-server --ignore-not-found
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl delete pod server --ignore-not-found
kubectl delete pod client --ignore-not-found
kubectl delete networkpolicy deny-all --ignore-not-found
kubectl delete networkpolicy allow-client --ignore-not-found
```

## Step 1 - recreate cluster and install Calico (NP enforcement)

```bash
kind delete cluster --name lab
kind create cluster --config kind-calico.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/custom-resources.yaml

kubectl get ns
kubectl get pods -n calico-system -w
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kind delete cluster --name lab
Deleting cluster"lab" ...
Deleted nodes: ["lab-control-plane"]

user@host:~/Projects/k8s/week2$ kind create cluster --config kind-calico.yaml
Creating cluster"labnp" ...
 ✓ Ensuring node image (kindest/node:v1.30.0) 🖼
 ✓ Preparing nodes 📦 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to"kind-labnp"

user@host:~/Projects/k8s/week2$ kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/custom-resources.yaml
namespace/tigera-operator created
...
deployment.apps/tigera-operator created
installation.operator.tigera.io/default created
apiserver.operator.tigera.io/default created

user@host:~/Projects/k8s/week2$ kubectl get pods -n calico-system -w
NAME                         READY   STATUS    RESTARTS   AGE
calico-typha-cc7c5bf-7zx7l   0/1     Pending   0          0s
...
calico-typha-cc7c5bf-7zx7l   1/1     Running   0          22s
...
^C
```

## Step 2 - recreate namespace week2 and set context

```bash
kubectl get ns
kubectl create ns week2
kubectl config set-context --current --namespace=week2
kubectl config view --minify | grep namespace
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl get ns
NAME                 STATUS   AGE
calico-system        Active   3m39s
default              Active   4m40s
kube-node-lease      Active   4m40s
kube-public          Active   4m40s
kube-system          Active   4m40s
local-path-storage   Active   4m34s
tigera-operator      Active   4m1s

user@host:~/Projects/k8s/week2$ kubectl create ns week2
namespace/week2 created

user@host:~/Projects/k8s/week2$ kubectl config set-context --current --namespace=week2
Context"kind-labnp" modified.

user@host:~/Projects/k8s/week2$ kubectl config view --minify | grep namespace
    namespace: week2
```

## Step 3 - deploy server + client

```bash
kubectl apply -f lab9-server.yaml
kubectl apply -f lab9-client.yaml
kubectlwait --for=condition=Ready pod/server --timeout=120s
kubectlwait --for=condition=Ready pod/client --timeout=120s
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl apply -f lab9-server.yaml
pod/server created

user@host:~/Projects/k8s/week2$ kubectl apply -f lab9-client.yaml
pod/client created

user@host:~/Projects/k8s/week2$ kubectlwait --for=condition=Ready pod/server --timeout=120s
kubectlwait --for=condition=Ready pod/client --timeout=120s
pod/server condition met
pod/client condition met
```

## Step 4 - expose server and verify baseline connectivity

```bash
kubectl expose pod server --name server --port 80
kubectl get svc server
kubectl get endpoints server -w
kubectlexec -it client -- wget -qO- http://server |head
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl expose pod server --name server --port 80
service/server exposed

user@host:~/Projects/k8s/week2$ kubectl get endpoints server -w
NAME     ENDPOINTS           AGE
server   192.168.83.131:80   11s
^C

user@host:~/Projects/k8s/week2$ kubectlexec -it client -- wget -qO- http://server |head
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
...
```

## Step 5 - deny all ingress to server

```bash
kubectl apply -f lab9-deny.yaml
kubectl get networkpolicy
kubectl describe networkpolicy deny-all-to-server
kubectlexec -it client -- wget -qO- --timeout=2 http://server
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl apply -f lab9-deny.yaml
networkpolicy.networking.k8s.io/deny-all-to-server created

user@host:~/Projects/k8s/week2$ kubectl describe networkpolicy deny-all-to-server
Name:         deny-all-to-server
Namespace:    week2
Created on:   2026-02-11 20:58:00 +0200 IST
Spec:
  PodSelector:     app=server
  Allowing ingress traffic:
    <none> (Selected pods are isolatedfor ingress connectivity)
  Not affecting egress traffic
  Policy Types: Ingress

user@host:~/Projects/k8s/week2$ kubectlexec -it client -- wget -qO- --timeout=2 http://server
wget: download timed outcommand terminated withexit code 1
```

## Step 6 - allow only client -> server on TCP/80

```bash
kubectl apply -f lab9-allow-client.yaml
kubectl describe networkpolicy allow-client-to-server
kubectlexec -it client -- wget -qO- --timeout=2 http://server |head
```

Terminal log:

```bash
(no explicit terminal log captured in the Notion export for this step)
```

## Tips

- If deny policy does not block traffic, validate whether your CNI enforces NetworkPolicy.
- Use Service + Endpoints checks before moving to NetworkPolicy checks.

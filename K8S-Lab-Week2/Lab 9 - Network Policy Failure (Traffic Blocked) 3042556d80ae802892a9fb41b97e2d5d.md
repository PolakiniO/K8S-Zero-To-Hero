# Lab 9 - Network Policy Failure (Traffic Blocked)

# Lab 9 - NetworkPolicy Failure (Block traffic, diagnose connectivity)

## Tasks

1. Validate NetworkPolicy enforcement (Calico)
2. Deploy server + client
3. Expose server as a Service (DNS name)
4. Verify connectivity works
5. Apply deny policy to server ingress
6. Verify connectivity fails (timeout)
7. Apply allow policy (only client can reach server)
8. Verify connectivity works again

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

## Expected learning

- NetworkPolicy needs a CNI that enforces it (Calico does)
- First check when traffic fails: Service selector and Endpoints
- A deny policy isolates selected pods for ingress
- Allow rules are additive - explicitly allow what you need

## Interview phrase

Network policy prevented east-west communication.

---

## Step 0 - clean slate

Commands:

```bash
kubectl delete pod server --ignore-not-found
kubectl delete pod client --ignore-not-found
kubectl delete svc server --ignore-not-found
kubectl delete networkpolicy deny-all-to-server --ignore-not-found
kubectl delete networkpolicy allow-client-to-server --ignore-not-found
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl delete pod server --ignore-not-found
kubectl delete pod client --ignore-not-found
kubectl delete networkpolicy deny-all --ignore-not-found
kubectl delete networkpolicy allow-client --ignore-not-found
```

Tips:

- If you recreated the cluster, your old namespace and resources are gone anyway, but clean slate keeps the lab repeatable.

---

## Step 1 - recreate cluster and install Calico (so NetworkPolicy is enforced)

Why this step exists:

- You applied a deny policy earlier and traffic still worked. That happens when your cluster networking does not enforce NetworkPolicy.
- So you rebuilt the kind cluster and installed Calico.

Commands:

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
polakinio@Polakinio:~/Projects/k8s/week2$ kind delete cluster --name lab
Deleting cluster"lab" ...
Deleted nodes: ["lab-control-plane"]

polakinio@Polakinio:~/Projects/k8s/week2$ kind create cluster --config kind-calico.yaml
Creating cluster"labnp" ...
 ✓ Ensuring node image (kindest/node:v1.30.0) 🖼
 ✓ Preparing nodes 📦 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to"kind-labnp"

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/custom-resources.yaml
namespace/tigera-operator created
...
deployment.apps/tigera-operator created
installation.operator.tigera.io/default created
apiserver.operator.tigera.io/default created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get pods -n calico-system -w
NAME                         READY   STATUS    RESTARTS   AGE
calico-typha-cc7c5bf-7zx7l   0/1     Pending   0          0s
...
calico-typha-cc7c5bf-7zx7l   1/1     Running   0          22s
...
^C
```

Tips:

- After a new cluster: namespaces like `week2` do not exist until you recreate them.
- Always confirm your current context after kind create: `kubectl config current-context`

---

## Step 2 - recreate namespace week2 and set context

Commands:

```bash
kubectl get ns
kubectl create ns week2
kubectl config set-context --current --namespace=week2
kubectl config view --minify | grep namespace
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get ns
NAME                 STATUS   AGE
calico-system        Active   3m39s
default              Active   4m40s
kube-node-lease      Active   4m40s
kube-public          Active   4m40s
kube-system          Active   4m40s
local-path-storage   Active   4m34s
tigera-operator      Active   4m1s

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl create ns week2
namespace/week2 created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl config set-context --current --namespace=week2
Context"kind-labnp" modified.

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl config view --minify | grep namespace
    namespace: week2
```

Tips:

- You hit `namespaces "week2" not found` exactly because the cluster was new.

---

## Step 3 - deploy server + client

### lab9-server.yaml

```yaml
apiVersion:v1kind:Podmetadata:name:serverlabels:app:serverspec:containers:-name:nginximage:nginx:1.25ports:-containerPort:80
```

### lab9-client.yaml

```yaml
apiVersion:v1kind:Podmetadata:name:clientlabels:app:clientspec:containers:-name:clientimage:busybox:1.36command: ["sh","-c","sleep 3600"]
```

Commands:

```bash
kubectl apply -f lab9-server.yaml
kubectl apply -f lab9-client.yaml
kubectlwait --for=condition=Ready pod/server --timeout=120s
kubectlwait --for=condition=Ready pod/client --timeout=120s
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply -f lab9-server.yaml
pod/server created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply -f lab9-client.yaml
pod/client created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectlwait --for=condition=Ready pod/server --timeout=120s
kubectlwait --for=condition=Ready pod/client --timeout=120s
pod/server condition met
pod/client condition met
```

Tips:

- If you try `kubectl apply file.yaml` without `f`, you get "Unexpected args".

---

## Step 4 - expose server and verify baseline connectivity

Commands:

```bash
kubectl expose pod server --name server --port 80
kubectl get svc server
kubectl get endpoints server -w
kubectlexec -it client -- wget -qO- http://server |head
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl expose pod server --name server --port 80
service/server exposed

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get endpoints server -w
NAME     ENDPOINTS           AGE
server   192.168.83.131:80   11s
^C

polakinio@Polakinio:~/Projects/k8s/week2$ kubectlexec -it client -- wget -qO- http://server |head
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
...
```

Tips:

- You originally got `wget: bad address 'server'` before exposing the pod. That is expected because DNS name `server` comes from the Service.

---

## Step 5 - deny all ingress to server

### lab9-deny.yaml

```yaml
apiVersion:networking.k8s.io/v1kind:NetworkPolicymetadata:name:deny-all-to-servernamespace:week2spec:podSelector:matchLabels:app:serverpolicyTypes:-Ingress
```

Commands:

```bash
kubectl apply -f lab9-deny.yaml
kubectl get networkpolicy
kubectl describe networkpolicy deny-all-to-server
kubectlexec -it client -- wget -qO- --timeout=2 http://server
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply -f lab9-deny.yaml
networkpolicy.networking.k8s.io/deny-all-to-server created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl describe networkpolicy deny-all-to-server
Name:         deny-all-to-server
Namespace:    week2
Created on:   2026-02-11 20:58:00 +0200 IST
Spec:
  PodSelector:     app=server
  Allowing ingress traffic:
    <none> (Selected pods are isolatedfor ingress connectivity)
  Not affecting egress traffic
  Policy Types: Ingress

polakinio@Polakinio:~/Projects/k8s/week2$ kubectlexec -it client -- wget -qO- --timeout=2 http://server
wget: download timed outcommand terminated withexit code 1
```

Tips:

- This timeout is the success condition for the deny test.
- Your earlier case where HTML still returned was the signal that NP was not enforced.

---

## Step 6 - allow only client -> server on TCP/80

### lab9-allow-client.yaml

```yaml
apiVersion:networking.k8s.io/v1kind:NetworkPolicymetadata:name:allow-client-to-servernamespace:week2spec:podSelector:matchLabels:app:serverpolicyTypes:-Ingressingress:-from:-podSelector:matchLabels:app:clientports:-protocol:TCPport:80
```

Commands:

```bash
kubectl apply -f lab9-allow-client.yaml
kubectl describe networkpolicy allow-client-to-server
kubectlexec -it client -- wget -qO- --timeout=2 http://server |head
```

What you should see:

- HTML returns again (connectivity restored)
- Deny policy stays, allow policy opens only what you described

Tips:

- If you want to prove it is restricted, create another pod with label `app=other` and watch it time out.
# Lab 6 - Label Selector Mismatch (Service cannot reach Pod)

## Tasks

1. Deploy a pod with a label.
2. Create a Service with the wrong selector.
3. Observe no endpoints.
4. Fix selector and verify connectivity.

## Validation Commands

```bash
kubectl get svc
kubectl get endpoints
kubectl describe svc <service>
kubectl get pod --show-labels
```

## Expected Learning

- Services route only by label selectors.
- Endpoints object is the first place to look when traffic fails.

## Interview Phrase

Service selector mismatch caused routing failure.

## Step 0 - clean slate + namespace isolation

```bash
kubectl config view --minify | grep namespace

kubectl delete svc probe-svc --ignore-not-found
kubectl delete pod probe-demo --ignore-not-found
kubectl delete endpoints probe-svc --ignore-not-found

kubectl delete pod cfg-demo --ignore-not-found

kubectl delete pod web-demo --ignore-not-found
kubectl delete svc web-demo --ignore-not-found
kubectl delete endpoints web-demo --ignore-not-found

kubectl create ns week2 --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace=week2

kubectl config view --minify
kubectl get svc
kubectl get pod
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl config view --minify | grep namespace

kubectl delete svc probe-svc --ignore-not-found
kubectl delete pod probe-demo --ignore-not-found
kubectl delete endpoints probe-svc --ignore-not-found

kubectl delete pod cfg-demo --ignore-not-found

kubectl delete pod web-demo --ignore-not-found
kubectl delete svc web-demo --ignore-not-found
kubectl delete endpoints web-demo --ignore-not-found
    namespace: week1
pod"cfg-demo" deleted

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl create ns week2 --dry-run=client -o yaml | kebectl apply -f
kebectl:command not found
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl create ns week2 --dry-run=client -o yaml | kebectl apply -f -
kebectl:command not found
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl create ns week2 --dry-run=client -o yaml | kubectl apply -f -
namespace/week2 created
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl config set-context --current --namespace=week2
Context"kind-lab" modified.
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl config view -minify
error: unknown shorthand flag:'m'in -minify
See'kubectl config view --help'for usage.
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl config view --minify
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://127.0.0.1:35041
  name: kind-lab
contexts:
- context:
    cluster: kind-lab
    namespace: week2
    user: kind-lab
  name: kind-lab
current-context: kind-lab
kind: Config
preferences: {}users:
- name: kind-lab
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl config view --minify | grep namespace
    namespace: week2

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl delete pod web-demo --ignore-not-found
kubectl delete svc web-demo --ignore-not-found
```

## Step 1 - Deploy a pod with a label

```bash
kubectl apply -f lab6-pod.yaml
kubectl get pod web-demo --show-labels -w
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$touch lab6-pod.yaml
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply -f lab6-pod.yaml
pod/web-demo created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get pod web-demo --show-labels -w
NAME       READY   STATUS    RESTARTS   AGE   LABELS
web-demo   1/1     Running   0          14s   app=web
^Cpolakinio@Polakinio:~/Projects/k8s/week2$
```

## Step 2 - Create Service with wrong selector

```bash
kubectl apply -f lab6-service-broken.yaml
kubectl get svc
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$touch lab6-service-broken.yaml
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply -f lab6-service-broken.yaml
service/web-demo created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get svc
NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
web-demo   ClusterIP   10.96.192.206   <none>        80/TCP    13s
```

## Step 3 - Observe no endpoints

```bash
kubectl get endpoints web-demo
kubectl describe svc web-demo
kubectl get pod --show-labels
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get endpoints web-deno
Error from server (NotFound): endpoints"web-deno" not found

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get endpoints web-demo
NAME       ENDPOINTS   AGE
web-demo   <none>      26s

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl describe svc web-demo
Name:                     web-demo
Namespace:                week2
Labels:                   <none>
Annotations:              <none>
Selector:                 app=wronglabel
Type:                     ClusterIP
IP:                       10.96.192.206
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:
Events:                   <none>

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get pod --show-labels
NAME       READY   STATUS    RESTARTS   AGE    LABELS
web-demo   1/1     Running   0          118s   app=web
```

## Step 4 - Fix selector and verify endpoints

```bash
kubectl apply -f lab6-service-fix.yaml
kubectl apply -f lab6-pod.yaml
kubectl get endpoints web-demo
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$touch lab6-service-fix.yaml
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl delete pod web-demo
pod"web-demo" deleted

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply -f lab6-service-fix.yaml
service/web-demo configured

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply lab6-pod.yaml
error: Unexpected args: [lab6-pod.yaml]
See'kubectl apply -h'forhelp and examples

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply -f lab6-pod.yaml
pod/web-demo created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get endpoints web-demo
NAME       ENDPOINTS        AGE
web-demo   10.244.0.24:80   2m39s
```

## Tips

- Check Endpoints first whenever a Service exists but traffic fails.
- Match `spec.selector` against `kubectl get pod --show-labels` before debugging deeper.

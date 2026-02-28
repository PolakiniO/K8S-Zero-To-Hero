# Lab 7 - Rolling Update Failure

## Tasks

1. Create a working Deployment (nginx).
2. Update image to a broken tag.
3. Observe rollout failure.
4. Inspect rollout status and failing pod.
5. Roll back to the working version.

## Validation Commands

```bash
kubectl get deploy
kubectl get rs
kubectl get pods
kubectl rollout status deployment/web
kubectl describe pod <pod>
kubectl rollouthistory deployment/web
kubectl rollout undo deployment/web
```

## Expected Learning

- Deployment rollout creates a new ReplicaSet.
- Rollout stalls when new pods cannot become Ready.
- Rollback restores the last good ReplicaSet.

## Interview Phrase

I inspected rollout status and isolated failing replicas.

## Step 0 - clean slate

```bash
kubectl delete deployment web --ignore-not-found
kubectl delete rs -l app=web --ignore-not-found
kubectl delete pod -l app=web --ignore-not-found
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl delete deployment web --ignore-not-found
user@host:~/Projects/k8s/week2$ kubectl delete rs -l app=web --ignore-not-found
No resources found
user@host:~/Projects/k8s/week2$ kubectl delete pod -l app=web --ignore-not-found
pod"web-demo" deleted
```

## Step 1 - Create a working Deployment (baseline)

```bash
kubectl apply -f lab7-deploy-good.yaml
kubectl get pods -w
kubectl delete pod curlpod
kubectl get pods -w
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$touch lab7-deploy-good.yaml
user@host:~/Projects/k8s/week2$ kubectl apply -f lab7-deploy-good.yaml
deployment.apps/web created

user@host:~/Projects/k8s/week2$ kubectl get pods -w
NAME                   READY   STATUS             RESTARTS   AGE
curlpod                0/1     ImagePullBackOff   0          21m
web-686b75b84c-ft259   1/1     Running            0          8s
web-686b75b84c-vc7jl   1/1     Running            0          8s

curlpod                0/1     ErrImagePull       0          21m
^Cuser@host:~/Projects/k8s/week2$

user@host:~/Projects/k8s/week2$ kubectl delete pod curlpod
pod"curlpod" deleted

user@host:~/Projects/k8s/week2$ kubectl get pods -w
NAME                   READY   STATUS    RESTARTS   AGE
web-686b75b84c-ft259   1/1     Running   0          31s
web-686b75b84c-vc7jl   1/1     Running   0          31s
^Cuser@host:~/Projects/k8s/week2$
```

## Step 2 - Break the rollout

```bash
kubectl apply -f lab7-deploy-broken.yaml
kubectl rollout status deployment/web
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$touch lab7-deploy-broken.yaml
user@host:~/Projects/k8s/week2$ kubectl apply -f lab7-deploy-broken.yaml
deployment.apps/web configured

user@host:~/Projects/k8s/week2$ kubectl rollout status deployment/web
Waitingfor deployment"web" rollout to finish: 1 out of 2 new replicas have been updated...
^Cuser@host:~/Projects/k8s/week2$
```

## Step 3 - Observe failure symptoms

```bash
kubectl get pods
kubectl describe pod web-5cc4949757-fp4wh
kubectl get events --sort-by=.metadata.creationTimestamp
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl get pods
NAME                   READY   STATUS             RESTARTS   AGE
web-5cc4949757-fp4wh   0/1     ImagePullBackOff   0          44s
web-686b75b84c-ft259   1/1     Running            0          2m22s
web-686b75b84c-vc7jl   1/1     Running            0          2m22s

user@host:~/Projects/k8s/week2$ kubectl desctibe pod web-5cc4949757-fp4wh
error: unknowncommand"desctibe"for"kubectl"

Did you mean this?
        describe

user@host:~/Projects/k8s/week2$ kubectl describe pod web-5cc4949757-fp4wh
...
    Image:          nginx:1.25-doesnotexist
...
    State:          Waiting
      Reason:       ImagePullBackOff
...
Events:
  Normal   Pulling    ...  Pulling image"nginx:1.25-doesnotexist"
  Warning  Failed     ...  Failed to pull image"nginx:1.25-doesnotexist": ... not found
  Warning  Failed     ...  Error: ErrImagePull
  Normal   BackOff    ...  Back-off pulling image"nginx:1.25-doesnotexist"
  Warning  Failed     ...  Error: ImagePullBackOff

user@host:~/Projects/k8s/week2$ kubectl get events --sort-by=.metadata.creationTimestamp
...
102s        Normal    SuccessfulCreate    replicaset/web-5cc4949757   Created pod: web-5cc4949757-fp4wh
102s        Normal    ScalingReplicaSet   deployment/web              Scaled up replicaset web-5cc4949757 to 1
10s         Normal    Pulling             pod/web-5cc4949757-fp4wh    Pulling image"nginx:1.25-doesnotexist"
21s         Warning   Failed              pod/web-5cc4949757-fp4wh    Error: ImagePullBackOff
9s          Warning   Failed              pod/web-5cc4949757-fp4wh    Failed to pull image"nginx:1.25-doesnotexist": ... not found
9s          Warning   Failed              pod/web-5cc4949757-fp4wh    Error: ErrImagePull
21s         Normal    BackOff             pod/web-5cc4949757-fp4wh    Back-off pulling image"nginx:1.25-doesnotexist"
```

## Step 4 - Check rollout history

```bash
kubectl rollouthistory deployment/web
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl rollouthistory deployment/web
deployment.apps/web
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

## Step 5 - Rollback and validate

```bash
kubectl rollout undo deployment/web
kubectl rollout status deployment/web
kubectl get pods
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl rollout undo deployment/web
deployment.apps/web rolled back

user@host:~/Projects/k8s/week2$ kubectl rollout status deployment/web
deployment"web" successfully rolled out

user@host:~/Projects/k8s/week2$ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
web-686b75b84c-ft259   1/1     Running   0          4m26s
web-686b75b84c-vc7jl   1/1     Running   0          4m26s
```

## Tips

- `kubectl rollout status` is the quickest way to see rollout stall behavior.
- Old ReplicaSet pods staying healthy during bad rollout is expected safe behavior.

# Lab 7 - Rolling Update Failure

## Lab 7 - Rolling Update Failure

### Tasks

1. Create a working Deployment (nginx)
2. Update image to a broken tag
3. Observe rollout failure
4. Inspect rollout status + failing pod
5. Roll back to the working version

### Validation Commands

```bash
kubectl get deploy
kubectl get rs
kubectl get pods
kubectl rollout status deployment/web
kubectl describe pod <pod>
kubectl rollouthistory deployment/web
kubectl rollout undo deployment/web
```

### Expected Learning

- Deployment rollout creates a new ReplicaSet
- Rollout stalls when new pods cannot become Ready
- You can isolate the failing replica quickly via rollout status, pods, describe, events
- Rollback restores the last good ReplicaSet

### Interview Phrase

I inspected rollout status and isolated failing replicas.

---

## Step 0 - Clean slate (week2)

Commands:

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

---

## Step 1 - Create a working Deployment (baseline)

Commands:

```bash
touch lab7-deploy-good.yaml
kubectl apply -f lab7-deploy-good.yaml
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
```

Cleanup of leftover pod (noise removal):

```bash
kubectl delete pod curlpod
kubectl get pods -w
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl delete pod curlpod
pod"curlpod" deleted

user@host:~/Projects/k8s/week2$ kubectl get pods -w
NAME                   READY   STATUS    RESTARTS   AGE
web-686b75b84c-ft259   1/1     Running   0          31s
web-686b75b84c-vc7jl   1/1     Running   0          31s
^Cuser@host:~/Projects/k8s/week2$
```

What you proved:

- Deployment healthy, 2 replicas Running

---

## Step 2 - Break the rollout (bad image tag)

Commands:

```bash
touch lab7-deploy-broken.yaml
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

Key observation:

- Rollout is stuck waiting on updated replicas

---

## Step 3 - Observe failure symptoms (pods, describe, events)

Commands:

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

Root cause (from describe + events):

- New ReplicaSet pod is failing because image tag does not exist: nginx:1.25-doesnotexist
- Deployment rollout is blocked waiting for new replicas to become healthy
- Old replicas remain Running (safe behavior)

---

## Step 4 - Check rollout history

Commands:

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

Note:

- CHANGE-CAUSE is empty because the deployment was not annotated with a change cause (optional improvement later)

---

## Step 5 - Rollback

Commands:

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

What you proved:

- Rollback restored last known good state
- Bad ReplicaSet pods disappeared and only healthy replicas remain

---

## Reflection (based on your run)

Failure symptom:

- Rollout stuck and new pod in ImagePullBackOff

First command used and why:

- kubectl rollout status deployment/web to confirm rollout is blocked during update

Root cause:

- Invalid image tag nginx:1.25-doesnotexist causing ErrImagePull -> ImagePullBackOff

Fix:

- kubectl rollout undo deployment/web to revert to last working revision

Prevention step:

- Use image tag validation in CI (or deploy to staging first)
- Add change-cause annotations for auditability
- Consider imagePullPolicy and registry availability checks for production pipelines
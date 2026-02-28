# Lab 1 - Pod Creation + Image Failure

## Tasks

1. Create a working nginx pod.
2. Break startup by using a non-existent image tag.
3. Diagnose via `describe` + events.
4. Fix image back to valid tag.

## Validation Commands

```bash
kubectl get pod web-app -w
kubectl describe pod web-app -n week1
kubectl get events -n week1 --sort-by=.metadata.creationTimestamp
```

## Step 0 - clean slate

```bash
kubectl delete pod web-app --ignore-not-found -n week1
```

Terminal log:

```bash
TODO: No explicit clean-slate terminal log for this step in the Notion export.
```

## Step 1 - Create working pod

```bash
kubectl run web-app --image=nginx:1.25 --restart=Never
kubectl get pods web-app -w
```

Terminal log:

```bash
user@host:~$ kubectl run web-app --image=nginx:1.25 --restart=Never
pod/web-app created
user@host:~$ kubectl get pods web-app -w
NAME      READY   STATUS              RESTARTS   AGE
web-app   0/1     ContainerCreating   0          6s
web-app   1/1     Running             0          28s
```

## Step 2 - Break image tag and diagnose ImagePullBackOff

```bash
kubectl run web-app --image=nginx:1.25-DoNotExist --restart=Never
kubectl get pod web-app
kubectl describe pod web-app
kubectl get events --sort-by=.metadata.creationTimestamp
```

Terminal log:

```bash
user@host:~$ kubectl run web-app --image=nginx:1.25-DoNotExist --restart=Never
pod/web-app created
user@host:~$ kubectl get pod web-app
NAME      READY   STATUS         RESTARTS   AGE
web-app   0/1     ErrImagePull   0          32s
...
  Warning  Failed     21s (x2 over 37s)  kubelet            Error: ErrImagePull
  Normal   BackOff    9s (x2 over 36s)   kubelet            Back-off pulling image "nginx:1.25-DoNotExist"
  Warning  Failed     9s (x2 over 36s)   kubelet            Error: ImagePullBackOff
user@host:~$ kubectl get events --sort-by=.metadata.creationTimestamp
...
4s          Normal    BackOff     pod/web-app   Back-off pulling image "nginx:1.25-DoNotExist"
4s          Warning   Failed      pod/web-app   Error: ImagePullBackOff
```

## Step 3 - Fix image

```bash
kubectl set image pod/web-app web-app=nginx:1.25 -n week1
kubectl describe pod web-app -n week1
```

Terminal log:

```bash
user@host:~$ kubectl set image pod/web-app web-app=nginx:1.25 -n week1
pod/web-app image updated
user@host:~$ kubectl describe pod web-app -n week1
Status:           Running
...
    Image:          nginx:1.25
...
```

## Reflection

- Failure symptom: Pod reached `ErrImagePull` / `ImagePullBackOff`.
- First command used and why: `kubectl describe pod web-app` to inspect pull events and exact kubelet reason.
- Root cause: Invalid image tag (`nginx:1.25-DoNotExist`).
- Fix: Update pod image back to `nginx:1.25`.
- Prevention step: Validate image/tag before apply and check events immediately on pull failures.

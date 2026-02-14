# Lab 1 - Pod creation + image failure

Create a working pod

```bash
kubectl run web-app --image=nginx:1.25 --restart=Never
kubectl get pod web-app -w
```

Terminal Log : 

```jsx
polakinio@Polakinio:~$ kubectl run web-app --image=nginx:1.25 --restart=Never
pod/web-app created
polakinio@Polakinio:~$ kubectl get pods web-app -w
NAME      READY   STATUS              RESTARTS   AGE
web-app   0/1     ContainerCreating   0          6s
web-app   1/1     Running             0          28s
```

Break it (non-existent tag)

```jsx
kubectl run web-app --image=nginx:1.25-DoNotExist --restart=Never
kubectl get pod web-app
kubectl describe pod web-app
kubectl get events --sort-by=.metadata.creationTimestamp
```

Terminal Log: 

```bash
polakinio@Polakinio:~$ kubectl run web-app --image=nginx:1.25-DoNotExist --restart=Never
pod/web-app created
polakinio@Polakinio:~$ kubectl get pod web-app
NAME      READY   STATUS         RESTARTS   AGE
web-app   0/1     ErrImagePull   0          32s
polakinio@Polakinio:~$ kubectl describe pod web-app
Name:             web-app
Namespace:        week1
Priority:         0
Service Account:  default
Node:             lab-control-plane/172.19.0.2
Start Time:       Wed, 11 Feb 2026 14:40:34 +0200
Labels:           run=web-app
Annotations:      <none>
Status:           Pending
IP:               10.244.0.7
IPs:
  IP:  10.244.0.7
Containers:
  web-app:
    Container ID:
    Image:          nginx:1.25-DoNotExist
    Image ID:
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ErrImagePull
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-zz7pl (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  kube-api-access-zz7pl:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  38s                default-scheduler  Successfully assigned week1/web-app to lab-control-plane
  Normal   Pulling    22s (x2 over 38s)  kubelet            Pulling image "nginx:1.25-DoNotExist"
  Warning  Failed     21s (x2 over 37s)  kubelet            Failed to pull image "nginx:1.25-DoNotExist": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:1.25-DoNotExist": failed to resolve reference "docker.io/library/nginx:1.25-DoNotExist": docker.io/library/nginx:1.25-DoNotExist: not found
  Warning  Failed     21s (x2 over 37s)  kubelet            Error: ErrImagePull
  Normal   BackOff    9s (x2 over 36s)   kubelet            Back-off pulling image "nginx:1.25-DoNotExist"
  Warning  Failed     9s (x2 over 36s)   kubelet            Error: ImagePullBackOff
polakinio@Polakinio:~$ kubectl get events --sort-by=.metadata.creationTimestamp
LAST SEEN   TYPE      REASON      OBJECT        MESSAGE
6m22s       Normal    Scheduled   pod/web-app   Successfully assigned week1/web-app to lab-control-plane
5m39s       Normal    Pulling     pod/web-app   Pulling image "ngingx:1.25"
5m38s       Warning   Failed      pod/web-app   Failed to pull image "ngingx:1.25": failed to pull and unpack image "docker.io/library/ngingx:1.25": failed to resolve reference "docker.io/library/ngingx:1.25": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
5m38s       Warning   Failed      pod/web-app   Error: ErrImagePull
5m52s       Normal    BackOff     pod/web-app   Back-off pulling image "ngingx:1.25"
5m52s       Warning   Failed      pod/web-app   Error: ImagePullBackOff
5m29s       Normal    Scheduled   pod/web-app   Successfully assigned week1/web-app to lab-control-plane
5m28s       Normal    Pulling     pod/web-app   Pulling image "nginx:1.25"
5m2s        Normal    Pulled      pod/web-app   Successfully pulled image "nginx:1.25" in 25.939s (25.939s including waiting). Image size: 71005258 bytes.
5m2s        Normal    Created     pod/web-app   Created container web-app
5m2s        Normal    Started     pod/web-app   Started container web-app
101s        Normal    Killing     pod/web-app   Stopping container web-app
74s         Normal    Scheduled   pod/web-app   Successfully assigned week1/web-app to lab-control-plane
31s         Normal    Pulling     pod/web-app   Pulling image "nginx:1.25-DoNotExist"
30s         Warning   Failed      pod/web-app   Failed to pull image "nginx:1.25-DoNotExist": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:1.25-DoNotExist": failed to resolve reference "docker.io/library/nginx:1.25-DoNotExist": docker.io/library/nginx:1.25-DoNotExist: not found
30s         Warning   Failed      pod/web-app   Error: ErrImagePull
4s          Normal    BackOff     pod/web-app   Back-off pulling image "nginx:1.25-DoNotExist"
4s          Warning   Failed      pod/web-app   Error: ImagePullBackOff  
```

Fix it

```bash
kubectl set image pod/web-app web-app=nginx:1.25 -n week1
kubectl describe pod web-app
```

Terminal Log :

```bash
polakinio@Polakinio:~$ kubectl set image pod/web-app web-app=nginx:1.25 -n week1
pod/web-app image updated
polakinio@Polakinio:~$ kubectl describe pod web-app -n week1
Name:             web-app
Namespace:        week1
Priority:         0
Service Account:  default
Node:             lab-control-plane/172.19.0.2
Start Time:       Wed, 11 Feb 2026 14:40:34 +0200
Labels:           run=web-app
Annotations:      <none>
Status:           Running
IP:               10.244.0.7
IPs:
  IP:  10.244.0.7
Containers:
  web-app:
    Container ID:   containerd://c519f89254b538bf6c24ea4445ff9d1579ec8988c92b5e8d87079cc2d2f9d58e
    Image:          nginx:1.25
    Image ID:       docker.io/library/nginx@sha256:a484819eb60211f5299034ac80f6a681b06f89e65866ce91f356ed7c72af059c
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 11 Feb 2026 14:49:57 +0200
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-zz7pl (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-zz7pl:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                  From               Message
  ----     ------     ----                 ----               -------
  Normal   Scheduled  11m                  default-scheduler  Successfully assigned week1/web-app to lab-control-plane
  Normal   Pulling    9m35s (x4 over 11m)  kubelet            Pulling image "nginx:1.25-DoNotExist"
  Warning  Failed     9m34s (x4 over 11m)  kubelet            Failed to pull image "nginx:1.25-DoNotExist": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:1.25-DoNotExist": failed to resolve reference "docker.io/library/nginx:1.25-DoNotExist": docker.io/library/nginx:1.25-DoNotExist: not found
  Warning  Failed     9m34s (x4 over 11m)  kubelet            Error: ErrImagePull
  Warning  Failed     9m20s (x6 over 11m)  kubelet            Error: ImagePullBackOff
  Normal   BackOff    6m (x20 over 11m)    kubelet            Back-off pulling image "nginx:1.25-DoNotExist"
polakinio@Polakinio:~$ kubectl get events -n week1 --sort-by=.metadata.creationTimestamp | tail -n 20
LAST SEEN   TYPE      REASON      OBJECT        MESSAGE
16m         Normal    Scheduled   pod/web-app   Successfully assigned week1/web-app to lab-control-plane
15m         Normal    Pulling     pod/web-app   Pulling image "ngingx:1.25"
15m         Warning   Failed      pod/web-app   Failed to pull image "ngingx:1.25": failed to pull and unpack image "docker.io/library/ngingx:1.25": failed to resolve reference "docker.io/library/ngingx:1.25": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
15m         Warning   Failed      pod/web-app   Error: ErrImagePull
15m         Normal    BackOff     pod/web-app   Back-off pulling image "ngingx:1.25"
15m         Warning   Failed      pod/web-app   Error: ImagePullBackOff
15m         Normal    Scheduled   pod/web-app   Successfully assigned week1/web-app to lab-control-plane
15m         Normal    Pulling     pod/web-app   Pulling image "nginx:1.25"
15m         Normal    Pulled      pod/web-app   Successfully pulled image "nginx:1.25" in 25.939s (25.939s including waiting). Image size: 71005258 bytes.
15m         Normal    Created     pod/web-app   Created container web-app
15m         Normal    Started     pod/web-app   Started container web-app
11m         Normal    Killing     pod/web-app   Stopping container web-app
11m         Normal    Scheduled   pod/web-app   Successfully assigned week1/web-app to lab-control-plane
9m44s       Normal    Pulling     pod/web-app   Pulling image "nginx:1.25-DoNotExist"
9m43s       Warning   Failed      pod/web-app   Failed to pull image "nginx:1.25-DoNotExist": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:1.25-DoNotExist": failed to resolve reference "docker.io/library/nginx:1.25-DoNotExist": docker.io/library/nginx:1.25-DoNotExist: not found
9m43s       Warning   Failed      pod/web-app   Error: ErrImagePull
6m9s        Normal    BackOff     pod/web-app   Back-off pulling image "nginx:1.25-DoNotExist"
9m29s       Warning   Failed      pod/web-app   Error: ImagePullBackOff
polakinio@Polakinio:~$
```
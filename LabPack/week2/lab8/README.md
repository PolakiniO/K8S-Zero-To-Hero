# Lab 8 - Storage Failure (PVC stuck Pending)

## Tasks

1. Create a PersistentVolumeClaim that cannot bind.
2. Observe PVC stuck Pending.
3. Diagnose why it cannot bind.
4. Fix by creating a matching PersistentVolume (or allowing provisioning).

## Validation Commands

```bash
kubectl get pvc
kubectl describe pvc <name>
kubectl get pv
kubectl get pods
```

## Expected Learning

- Pods wait for PVC binding before starting.
- PVC Pending usually means: no PV available, wrong StorageClass, or provisioner not running.

## Interview Phrase

Pod was blocked by volume provisioning.

## Step 0 - clean slate

```bash
kubectl delete pod pvc-demo --ignore-not-found
kubectl delete pvc demo-pvc --ignore-not-found
kubectl delete pv demo-pv --ignore-not-found
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl delete pod pvc-demo --ignore-not-found
kubectl delete pvc demo-pvc --ignore-not-found
kubectl delete pv demo-pv --ignore-not-found
```

## Step 1 - Create PVC

```bash
kubectl apply -f lab8-pvc.yaml
kubectl get pvc
kubectl describe pvc demo-pvc
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$touch lab8-pvc.yaml
user@host:~/Projects/k8s/week2$ kubectl apply -f lab8-pvc.yaml
persistentvolumeclaim/demo-pvc created

user@host:~/Projects/k8s/week2$ kubectl get pvc
NAME       STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
demo-pvc   Pending                                      standard       <unset>                 7s

user@host:~/Projects/k8s/week2$ kubectl describe pvc demo-pvc
Name:          demo-pvc
Namespace:     week2
StorageClass:  standard
Status:        Pending
Volume:
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:
Access Modes:
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type    Reason                Age               From                         Message
  ----    ------                ----              ----                         -------
  Normal  WaitForFirstConsumer  1s (x4 over 31s)  persistentvolume-controller  waitingfor first consumer to be created before binding
```

## Step 2 - Check PersistentVolumes

```bash
kubectl get pv
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl get pv
No resources found
```

## Step 3 - Create pod using PVC

```bash
kubectl apply -f lab8-pod.yaml
kubectl get pod pvc-demo
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$touch lab8-pod.yaml

user@host:~/Projects/k8s/week2$ kubectl apply -f lab8-pod.yaml
pod/pvc-demo created

user@host:~/Projects/k8s/week2$ kubectl get pod pvc-demo
NAME       READY   STATUS    RESTARTS   AGE
pvc-demo   1/1     Running   0          11s
```

## Step 4 - Create PV (manual path)

```bash
kubectl apply -f lab8-pv.yaml
kubectl get pv
kubectl get pvc
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$touch lab8-pv.yaml

user@host:~/Projects/k8s/week2$ kubectl apply -f lab8-pv.yaml
persistentvolume/demo-pv created

user@host:~/Projects/k8s/week2$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM            STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
demo-pv                                    1Gi        RWO            Retain           Available                                   <unset>                          6s
pvc-f14c6230-9af5-4d0c-b45f-adf4d845449a   1Gi        RWO            Delete           Bound       week2/demo-pvc   standard       <unset>                          114s

user@host:~/Projects/k8s/week2$ kubectl get pvc
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
demo-pvc   Bound    pvc-f14c6230-9af5-4d0c-b45f-adf4d845449a   1Gi        RWO            standard       <unset>                 4m
```

## Step 5 - Verify pod and volume

```bash
kubectl get pods
kubectl describe pvc demo-pvc
kubectl describe pod pvc-demo
```

Terminal log:

```bash
user@host:~/Projects/k8s/week2$ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
pvc-demo               1/1     Running   0          2m14s
web-686b75b84c-ft259   1/1     Running   0          13m
web-686b75b84c-vc7jl   1/1     Running   0          13m

user@host:~/Projects/k8s/week2$ kubectl describe pvc demo-pvc
...
Status:        Bound
Used By:       pvc-demo
...
Events:
  ProvisioningSucceeded  Successfully provisioned volume pvc-f14c6230...

user@host:~/Projects/k8s/week2$ kubectl describe pod pvc-demo
...
Mounts:
  /data from storage (rw)
...
```

## Tips

- Fast flow when pod is Pending: `describe pod` -> `get pvc` -> `describe pvc` -> `get storageclass`.
- `WaitForFirstConsumer` StorageClass behavior can keep PVC Pending until a consumer pod is created.

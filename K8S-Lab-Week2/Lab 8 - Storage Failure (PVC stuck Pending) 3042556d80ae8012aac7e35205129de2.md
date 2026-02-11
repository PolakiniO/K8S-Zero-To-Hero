# Lab 8 - Storage Failure (PVC stuck Pending)

## Lab 8 - Storage Failure (PVC stuck Pending)

### Tasks

1. Create a PersistentVolumeClaim that cannot bind
2. Observe PVC stuck Pending
3. Diagnose why it cannot bind
4. Fix by creating a matching PersistentVolume (or allowing provisioning)

### Validation Commands

```bash
kubectl get pvc
kubectl describe pvc <name>
kubectl get pv
kubectl get pods
```

### Expected Learning

- Pods wait for PVC binding before starting
- PVC Pending usually means:
    - No PV available
    - Wrong StorageClass
    - Provisioner not running

### Interview Phrase

Pod was blocked by volume provisioning.

---

## Step 0 - Clean slate

Commands run:

```bash
kubectl delete pod pvc-demo --ignore-not-found
kubectl delete pvc demo-pvc --ignore-not-found
kubectl delete pv demo-pv --ignore-not-found
```

### Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl delete pod pvc-demo --ignore-not-found
kubectl delete pvc demo-pvc --ignore-not-found
kubectl delete pv demo-pv --ignore-not-found
```

---

## Step 1 - Create PVC

Apply manifest and verify status.

### Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$touch lab8-pvc.yaml
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply -f lab8-pvc.yaml
persistentvolumeclaim/demo-pvc created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get pvc
NAME       STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
demo-pvc   Pending                                      standard       <unset>                 7s

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl describe pvc demo-pvc
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

---

## Step 2 - Check PersistentVolumes

### Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get pv
No resources found
```

Observation:

- No PV available yet
- PVC waiting for consumer

Important real-world note:

Your cluster uses dynamic provisioning (local-path provisioner), so the PVC eventually bound automatically once the pod appeared.

That is actually valuable learning:

Not all Pending PVCs require manual PV creation.

---

## Step 3 - Create Pod using PVC

### Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$touch lab8-pod.yaml

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply -f lab8-pod.yaml
pod/pvc-demo created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get pod pvc-demo
NAME       READY   STATUS    RESTARTS   AGE
pvc-demo   1/1     Running   0          11s
```

---

## Step 4 - Create PV (manual path)

### Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$touch lab8-pv.yaml

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl apply -f lab8-pv.yaml
persistentvolume/demo-pv created

polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM            STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
demo-pv                                    1Gi        RWO            Retain           Available                                   <unset>                          6s
pvc-f14c6230-9af5-4d0c-b45f-adf4d845449a   1Gi        RWO            Delete           Bound       week2/demo-pvc   standard       <unset>                          114s
```

PVC status after provisioning:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get pvc
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
demo-pvc   Bound    pvc-f14c6230-9af5-4d0c-b45f-adf4d845449a   1Gi        RWO            standard       <unset>                 4m
```

---

## Step 5 - Verify Pod and Volume

### Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
pvc-demo               1/1     Running   0          2m14s
web-686b75b84c-ft259   1/1     Running   0          13m
web-686b75b84c-vc7jl   1/1     Running   0          13m
```

PVC details:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl describe pvc demo-pvc
...
Status:        Bound
Used By:       pvc-demo
...
Events:
  ProvisioningSucceeded  Successfully provisioned volume pvc-f14c6230...
```

Pod volume mount:

```bash
polakinio@Polakinio:~/Projects/k8s/week2$ kubectl describe pod pvc-demo
...
Mounts:
  /data from storage (rw)
...
```

---

## Reflection

Failure symptom:

PVC Pending initially, no PV visible

First command used and why:

kubectl get pvc - to confirm claim state

Root cause:

PVC waiting for volume provisioning (WaitForFirstConsumer)

Fix:

Pod scheduled and dynamic provisioner created volume

Prevention step:

Verify StorageClass and provisioner before deploying workloads

---

## Practical Tips (important for real clusters)

Tip 1 - Fast diagnosis flow

When Pod is Pending:

1 kubectl describe pod

2 kubectl get pvc

3 kubectl describe pvc

4 kubectl get storageclass

This sequence saves a lot of time in incidents.

---

Tip 2 - StorageClass behavior matters

Common modes:

- Immediate - PV created instantly
- WaitForFirstConsumer - PV created only after Pod scheduled

Your cluster uses WaitForFirstConsumer, which is why behavior looked different.

---

Tip 3 - Real production incident pattern

Very common scenario in interviews and real life:

- Deployment stuck Pending
- Root cause: storage provisioning or quota

Knowing to check PVC early is a senior-level habit.
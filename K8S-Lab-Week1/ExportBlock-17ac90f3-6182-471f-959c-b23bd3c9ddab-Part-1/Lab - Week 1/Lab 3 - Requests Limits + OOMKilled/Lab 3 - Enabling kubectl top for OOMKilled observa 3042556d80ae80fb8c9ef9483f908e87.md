# Lab 3 - Enabling kubectl top for OOMKilled observation

## Goal

Be able to:

- Observe pod memory usage with `kubectl top`
- Watch memory grow before OOMKilled

---

# Problem

Running:

```
kubectltop pod memhog
```

Result:

```
Metrics APInot availableor
podmetricsnot found
```

Meaning:

- metrics-server was not installed or not functioning
- Kubernetes had no resource metrics to return

---

# Step 1 - Install metrics-server

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

This installs:

- metrics-server deployment
- RBAC roles
- APIService for metrics

But metrics still did not work.

---

# Step 2 - Diagnose metrics-server

Check pod:

```
kubectl get pods -n kube-system |grep metrics
```

Result:

```
0/1Running
```

Check logs:

```
kubectl logs -n kube-system deployment/metrics-server
```

Observed error:

```
tls: failedto verify certificate
cannot validate certificate because it doesn't contain any IP SANs
```

Meaning:

- metrics-server could not scrape kubelet
- TLS validation failed (common in local clusters)

---

# Step 3 - Fix metrics-server configuration

Edit deployment:

```
kubectl -n kube-system edit deployment metrics-server
```

Add argument:

```
--kubelet-insecure-tls
```

This allows scraping kubelet in lab environments.

---

# Step 4 - Restart metrics-server

```
kubectl -n kube-system rolloutrestart deployment metrics-server
kubectl -n kube-system rollout status deployment metrics-server
```

Verify:

```
kubectl get pods -n kube-system |grep metrics
```

Expected:

```
1/1Running
```

---

# Step 5 - Validate metrics API

```
kubectl get apiservice v1beta1.metrics.k8s.io
```

Expected:

```
AVAILABLETrue
```

Test:

```
kubectltop nodes
kubectltop pods -n week1
```

Metrics available.

---

# Step 6 - Allow memhog to be scraped

Problem:

- Pod was OOMKilled too fast
- metrics-server scrapes periodically
- Pod sometimes died before first scrape

Solution:

- Allow pod to run long enough before memory spike (or slightly increase memory limit)
- Add sleep for the initialization of the memory hogging args in the yaml script to allow for the metrics API enough time to query the pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memhog
spec:
  containers:
    - name: memhog
      image: python:3.12-slim
      resources:
        requests:
          memory: "64Mi"
          cpu: "50m"
        limits:
          memory: "128Mi"
          cpu: "200m"
      command: ["python", "-c"]
      args:
        - |
          import time
          a=[]
          print("sleeping 60s so metrics-server can scrape me...")
          time.sleep(60)
          i=0
          while True:
            a.append("x"*1024*1024)
            i+=1
            print(f"allocated {i} MiB")
            time.sleep(0.05)
```

After that:

```
kubectltop pod memhog -n week1
```

Returned metrics successfully.

---

# Key Learnings

kubectl top requires:

1. metrics-server installed
2. metrics-server able to scrape kubelet
3. Pod alive long enough to be scraped

In fast-crashing pods:

- metrics may not appear
- use describe pod to confirm OOMKilled

---

# Practical Troubleshooting Flow

If kubectl top fails:

1. Check API:

```
kubectl get apiservice v1beta1.metrics.k8s.io
```

1. Check metrics-server pod:

```
kubectlget pods-n kube-system
```

1. Check logs:

```
kubectl logs -n kube-system deployment/metrics-server
```

1. Look for:
- TLS errors
- scrape failures
- no metrics to serve
1. Patch deployment and restart
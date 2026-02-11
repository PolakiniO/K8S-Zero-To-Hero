# Lab - Fixing Metrics Server (kubectl top not working)

# Lab - Fixing Metrics Server (kubectl top not working)

## Goal

Enable resource metrics so that:

- kubectl top nodes
- kubectl top pods

work correctly.

---

# Problem Observed

Running:

```
kubectltop nodes
```

Result:

```
error: Metrics APInot available
```

---

# Step 1 - Install metrics-server

Applied the official manifest:

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Resources created:

- ServiceAccount
- ClusterRoles / Bindings
- Deployment
- APIService

But metrics still unavailable.

---

# Step 2 - Investigate metrics-server

Check pod:

```
kubectl get pods -n kube-system |grep metrics
```

Pod was:

```
0/1Running
```

Check logs:

```
kubectl logs -n kube-system deployment/metrics-server
```

Error observed:

```
tls: failedto verify certificate
cannot validate certificate because it doesn't contain any IP SANs
```

Meaning:

- metrics-server could not scrape kubelet
- TLS validation failed

---

# Step 3 - Fix configuration

Edit deployment:

```
kubectl -n kube-system edit deployment metrics-server
```

Added argument:

```
--kubelet-insecure-tls
```

This allows metrics-server to scrape kubelet in lab environments where certificates are not fully configured.

---

# Step 4 - Restart Deployment

```
kubectl -n kube-system rolloutrestart deployment metrics-server
kubectl -n kube-system rollout status deployment metrics-server
```

Verify pod:

```
kubectl get pods -n kube-system |grep metrics
```

Expected:

```
1/1Running
```

---

# Step 5 - Validate APIService

```
kubectl get apiservice v1beta1.metrics.k8s.io
```

Expected:

```
AVAILABLETrue
```

---

# Step 6 - Validate Metrics

```
kubectltop nodes
```

Result:

```
CPU and Memory metrics displayed
```

Metrics-server functioning correctly.

---

# Root Cause

Metrics-server failed to scrape kubelet due to TLS certificate validation failure in local cluster environment.

Adding:

```
--kubelet-insecure-tls
```

allowed scraping.

---

# Quick Troubleshooting Flow (for future)

If kubectl top fails:

1. Check metrics-server pod

```
kubectlget pods-n kube-system
```

1. Check logs

```
kubectl logs -n kube-system deployment/metrics-server
```

1. Look for:
- TLS errors
- cannot scrape node
- no metrics to serve
1. Patch deployment and restart

---

# Interview Insight

kubectl top depends on:

- metrics-server
- API aggregation layer
- kubelet metrics endpoint

Most real clusters do not enable this automatically in local environments.
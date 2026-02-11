# Kubernetes Incident Debugging Playbook

Use this flow for any production-style incident.

## 1) Triage
- What is broken? (symptom)
- Who is impacted? (blast radius)
- When did it start? (timeline)
- What changed recently? (deploy/config/infra)

## 2) Fast Object Health Scan
```bash
kubectl get pods -A
kubectl get deploy,rs,svc,endpoints -A
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

## 3) Pod-focused Investigation
```bash
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns>
kubectl logs <pod> -c <container> -n <ns>
kubectl exec -it <pod> -n <ns> -- sh
```

Look for:
- `ImagePullBackOff`, `CrashLoopBackOff`, `OOMKilled`
- Probe failures
- Missing secret/config references
- Startup dependency failures

## 4) Deployment/Rollout Investigation
```bash
kubectl rollout status deployment/<name> -n <ns>
kubectl rollout history deployment/<name> -n <ns>
kubectl describe deployment <name> -n <ns>
```

Look for:
- bad image tag
- failed new ReplicaSet
- maxUnavailable/maxSurge misconfiguration

## 5) Service/Network Investigation
```bash
kubectl get svc,endpoints -n <ns>
kubectl describe svc <name> -n <ns>
kubectl get networkpolicy -n <ns>
```

Look for:
- no endpoints due to selector mismatch
- blocked ingress/egress via policy
- port/targetPort mismatch

## 6) Storage Investigation
```bash
kubectl get pvc,pv -A
kubectl describe pvc <name> -n <ns>
```

Look for:
- PVC `Pending`
- StorageClass mismatch
- access mode incompatibility

## 7) Mitigate, Validate, Prevent
- Mitigate with smallest safe change.
- Validate with objective checks and user-impact recovery.
- Prevent recurrence with probes, alerts, policy guardrails, and runbooks.

## Incident Template (copy/paste)
```md
### Incident Summary
- Symptom:
- Impact:
- Start time:

### Evidence
- Commands run:
- Key observations:

### Root Cause
-

### Fix Applied
-

### Validation
-

### Prevention
-
```

# Incident Investigation Mini Project

Practice a full incident process with three realistic scenarios:

1. Production outage
2. Latency spike
3. Container crash

For each scenario, record exactly what you checked, which logs/metrics you used, and how root cause was proven.

---

## Scenario A — Production Outage

### Simulated symptom
- Public API returns `502/503`.
- Synthetics and uptime checks fail.

### Investigation flow
```bash
kubectl get deploy,rs,pods,svc,endpoints -n prod
kubectl get events -n prod --sort-by=.metadata.creationTimestamp
kubectl describe svc api -n prod
kubectl rollout history deployment/api -n prod
```

### Logs/Signals to review
- Ingress/controller logs for upstream resolution errors.
- Deployment events around last rollout.
- Service endpoints count.

### Typical root cause examples
- Service selector mismatch after label change.
- Failed rollout left no healthy pods.

### Resolution pattern
- Roll back to last healthy ReplicaSet.
- Fix selector and add pre-deploy validation.

---

## Scenario B — Latency Spike

### Simulated symptom
- p95 latency doubled for 20 minutes.
- Partial timeouts under load.

### Investigation flow
```bash
kubectl top pods -n prod
kubectl describe hpa api-hpa -n prod
kubectl logs deploy/api -n prod --since=20m
kubectl get events -n prod --sort-by=.metadata.creationTimestamp
```

### Logs/Signals to review
- CPU/memory saturation.
- HPA scaling delay or maxed replicas.
- Downstream dependency latency and retry volume.

### Typical root cause examples
- CPU throttling from low limits.
- Connection pool exhaustion.
- Slow downstream database/API.

### Resolution pattern
- Increase capacity immediately.
- Tune limits/HPA thresholds.
- Add latency SLO alert plus queue-depth alert.

---

## Scenario C — Container Crash

### Simulated symptom
- Pod enters `CrashLoopBackOff` right after deployment.

### Investigation flow
```bash
kubectl describe pod <pod> -n prod
kubectl logs <pod> -n prod --previous
kubectl get secret app-secrets -n prod -o yaml
kubectl describe deployment api -n prod
```

### Logs/Signals to review
- Last container termination reason.
- Probe failures vs application exceptions.
- Missing/invalid environment variables.

### Typical root cause examples
- Wrong secret key reference.
- Breaking env var rename in app release.
- Startup probe too strict.

### Resolution pattern
- Restore secret/config compatibility.
- Add release contract checks for required env vars.
- Protect cold start with startup probe.

---

## Deliverable template (fill for each scenario)

```md
## Incident: <name>

### 1) Detection
- Alert / report:
- First seen (UTC):
- Affected users/services:

### 2) What I checked
- Commands:
- Dashboards:
- Logs queried:

### 3) Root cause proof
- Evidence that confirms root cause:
- Evidence that ruled out alternatives:

### 4) Fix
- Immediate mitigation:
- Permanent solution:

### 5) Post-incident actions
- Monitoring:
- Runbook:
- Preventive test/policy:
```

## Evaluation rubric

A strong answer includes:
- clear timeline,
- evidence-based root cause,
- distinction between symptom and cause,
- rollback/mitigation decision rationale,
- prevention plan tied to the specific failure mode.

## Dual-use value (learning + recruiter showcase)

- **For learners**: use the same template across all three incidents to build consistent incident muscle memory.
- **For recruiters**: completed write-ups show your ability to communicate impact, evidence, decisions, and long-term corrective actions.

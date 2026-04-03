# Production Troubleshooting Track

This track is designed to simulate how incidents are investigated in real production environments.

## Track goal

Build a repeatable way to explain:

1. **How the issue was detected** (alert, SLO burn, customer report, logs).
2. **What you checked first** (blast radius, recent changes, failing components).
3. **How you proved root cause** (events, logs, metrics, traces, rollout timeline).
4. **What fix you applied** (short-term mitigation and permanent correction).
5. **How you prevented recurrence** (alerts, tests, policy, runbook updates).

---

## Candidate value and recruiter relevance

This track is intentionally structured to show skills hiring teams want in customer-facing and production roles:

- You can debug under pressure using evidence.
- You separate symptom vs trigger vs root cause.
- You communicate impact and decision trade-offs clearly.
- You close incidents with prevention work, not only a quick patch.

---

## Case path (in order)

### Case 1 — Production Outage: Service returns 5xx

**Detection**
- Alert from API availability monitor.
- Error budget burn rate spike for `http_5xx`.

**What to check**
```bash
kubectl get pods -n prod
kubectl get svc,endpoints -n prod
kubectl get events -n prod --sort-by=.metadata.creationTimestamp
kubectl rollout history deployment/api -n prod
```

**Root-cause pattern to validate**
- Service has no endpoints due to label/selector mismatch.
- Or rollout introduced bad image tag.

**Fix examples**
- Correct `Service.spec.selector` or pod labels.
- Roll back deployment to last stable revision.

**Production narrative sentence**
- "Outage started at 14:07 UTC after rollout revision 19; endpoints dropped to zero because selector no longer matched pods."

---

### Case 2 — Latency Spike: p95/p99 regression

**Detection**
- Latency SLO alert (p95 > target for 10m).
- Increased queue depth and upstream timeout errors.

**What to check**
```bash
kubectl top pods -n prod
kubectl describe hpa api-hpa -n prod
kubectl logs -n prod deploy/api --since=15m
kubectl get pods -n prod -o wide
```

**Root-cause pattern to validate**
- CPU throttling due to low limits.
- HPA scale-up delayed by missing metrics or bad target settings.
- Downstream dependency latency increase.

**Fix examples**
- Adjust requests/limits and HPA thresholds.
- Increase replicas temporarily as mitigation.
- Add circuit breaker/backoff tuning for downstream.

**Production narrative sentence**
- "Latency increase was capacity-related, not packet loss: throttling and queue growth appeared before timeout errors."

---

### Case 3 — Container Crash: CrashLoopBackOff

**Detection**
- Restart count alert and pod readiness drop.
- New deployment reports unhealthy pods.

**What to check**
```bash
kubectl describe pod <pod> -n prod
kubectl logs <pod> -n prod --previous
kubectl get secret -n prod
kubectl describe deployment api -n prod
```

**Root-cause pattern to validate**
- Missing secret/config key after deployment.
- Probe misconfiguration causing repeated restarts.
- App startup mismatch with dependency readiness.

**Fix examples**
- Restore secret key and restart rollout.
- Correct probe path/timeout/initial delay.
- Add startup probe to protect cold starts.

**Production narrative sentence**
- "Crash loop was configuration-induced: binary was healthy, but startup failed because required secret key was absent."

---

## Deliverable structure (use for every lab)

Use this template when documenting each incident:

```md
### Incident
- Symptom:
- Impact:
- Detection source:
- Start/End time (UTC):

### Investigation
- Commands run:
- Logs and metrics reviewed:
- What was ruled out:

### Root Cause
-

### Resolution
- Immediate mitigation:
- Permanent fix:

### Prevention
- Alerting improvements:
- Runbook/update:
- Guardrails/tests:

### Interview-ready summary (4 lines max)
- Situation:
- Action:
- Result:
- Role relevance (TAM/Support/Platform/Security):
```

## Success criteria

- You can explain each case in under 5 minutes.
- Every conclusion is backed by objective evidence (command output/logs/metrics).
- You separate symptom, trigger, and root cause clearly.
- Your summary is understandable to both engineers and non-engineering interviewers.

## Dual-use value (learning + recruiter showcase)

- **For learners**: run each case as a repeatable drill and fill the evidence template every time.
- **For recruiters**: this track demonstrates structured production debugging, clean RCA thinking, communication quality, and prevention-oriented engineering.

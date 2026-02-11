# Kubernetes Interview Readiness Plan (3 Weeks)

## Goal
Build confidence to debug real Kubernetes incidents and explain root causes clearly in interviews.

---

## Week 1 — Core Operations + Failure Handling

### Exercise 1: Pod Creation + Image Pull Failure
- Create `nginx` pod.
- Break image tag to trigger `ImagePullBackOff`.
- Diagnose with:
  - `kubectl describe pod`
  - `kubectl get events`
  - `kubectl logs`
- Interview line: **"I validated events to confirm image pull/auth failure before changing manifests."**

### Exercise 2: Namespace + RBAC Failure
- Create namespace and service account.
- Trigger forbidden API access.
- Fix with proper `Role` + `RoleBinding`.
- Interview line: **"This was authorization scope, not network connectivity."**

### Exercise 3: Resource Exhaustion
- Set low memory limit.
- Trigger `OOMKilled`.
- Adjust requests/limits and re-test.
- Interview line: **"Failure was resource pressure driven, confirmed by termination reason and metrics."**

### Exercise 4: Probe Misconfiguration
- Add invalid liveness endpoint.
- Observe `CrashLoopBackOff`.
- Correct probe path/timing.
- Interview line: **"The restart loop was caused by health check configuration, not app binary failure."**

### Exercise 5: Secret Dependency Failure
- Remove or misname secret reference.
- App fails during startup auth.
- Restore secret and restart.
- Interview line: **"Application logic was healthy; startup failure came from missing credential injection."**

---

## Week 2 — Networking + Deployment Incidents

### Exercise 6: Service Selector Mismatch
- Break label alignment between service and pods.
- Validate empty endpoints.
- Fix selector or pod labels.
- Interview line: **"Service had no healthy backends due to selector mismatch."**

### Exercise 7: Failed Rolling Update
- Deploy broken image version.
- Inspect rollout status/history.
- Roll back safely.
- Interview line: **"I stopped blast radius by rolling back to last healthy ReplicaSet."**

### Exercise 8: PVC Pending / Storage Failure
- Request unsupported storage class.
- Validate PVC events.
- Fix storage class or capacity.
- Interview line: **"Workload scheduling blocked by unresolved volume claim."**

### Exercise 9: NetworkPolicy Block
- Apply restrictive policy.
- Confirm failed connectivity.
- Open minimal necessary paths.
- Interview line: **"Traffic denial was policy-enforced east-west segmentation."**

### Exercise 10: End-to-end Incident Drill
- Simulate app failure with pod still `Running`.
- Use logs + exec + describe to find root cause.
- Document timeline and corrective action.

---

## Week 3 — Advanced Production Thinking

- Simulate node unavailability and observe workload rescheduling.
- Explore certificate expiry/rotation failure modes.
- Trigger resource pressure and observe eviction behavior.
- Diagnose chain failures across two or more services.

### Final Mock Prompt
**"Walk me through debugging a failing Kubernetes deployment."**

Target answer structure:
1. Symptom definition
2. Scope/impact
3. Evidence gathered (events, logs, rollout, metrics)
4. Root cause
5. Mitigation
6. Prevention

---

## Completion Criteria
- Can debug failures without trial-and-error panic.
- Uses precise Kubernetes terminology.
- Separates signal from noise using objective command output.
- Explains operational decisions and trade-offs clearly.

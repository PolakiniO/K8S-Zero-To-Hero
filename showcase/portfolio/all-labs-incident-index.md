# All Labs Incident Index (Portfolio)

This portfolio index consolidates incident scenarios from **all completed labs** and includes a recruiter-friendly incident report for each one.

## Incident report standard used in every entry

Each report uses the same structure so incident handling is easy to compare across scenarios:
- Detection signal + impact
- Investigation timeline (sanitized commands)
- Root cause and trigger
- Mitigation + permanent corrective action
- Verification + prevention improvements

Reference templates:
- [`incident-scenarios/README.md`](../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../deliverable-template.md)

---

## Week 1 — Core failures

### 1) Lab 1: Pod creation + image pull failure (`ImagePullBackOff`)
Source: [`LabPack/week1/lab1/README.md`](../../LabPack/week1/lab1/README.md)

- **Detection + impact**
  - `kubectl get pods` showed the workload stuck in `ImagePullBackOff`.
  - No running container meant the service could not start and downstream exercises were blocked.
- **Investigation timeline**
  - Checked pod status and events (`kubectl describe pod`).
  - Confirmed image pull errors and invalid image reference format.
- **Root cause + trigger**
  - Incorrect container image name/tag in manifest (human configuration error).
- **Fixes**
  - Corrected image reference to a valid public image/tag.
  - Re-applied manifest and verified pull succeeded.
- **Verification + prevention**
  - Pod reached `Running/Ready`.
  - Added pre-apply manifest review checklist for image references.

### 2) Lab 2: Namespace + RBAC authorization failure (`Forbidden`)
Source: [`LabPack/week1/lab2/README.md`](../../LabPack/week1/lab2/README.md)

- **Detection + impact**
  - Operations failed with `Forbidden` while attempting namespace-scoped actions.
  - Team could not deploy or inspect required objects.
- **Investigation timeline**
  - Checked current identity/context.
  - Reviewed Role/RoleBinding and target namespace.
  - Validated permissions using `kubectl auth can-i`.
- **Root cause + trigger**
  - Missing or incorrect RBAC binding for the intended subject in the target namespace.
- **Fixes**
  - Applied corrected RoleBinding and ensured subject/namespace alignment.
- **Verification + prevention**
  - `can-i` checks returned expected `yes` for required verbs/resources.
  - Added RBAC validation step before running namespace tasks.

### 3) Lab 3: Requests/limits mis-sizing (`OOMKilled`)
Source: [`LabPack/week1/lab3/README.md`](../../LabPack/week1/lab3/README.md)

- **Detection + impact**
  - Pod repeatedly restarted with `OOMKilled`.
  - Unstable workload behavior and elevated restart count.
- **Investigation timeline**
  - Reviewed container termination reason in `kubectl describe pod`.
  - Compared container memory limits with observed usage profile.
- **Root cause + trigger**
  - Memory limit was set below realistic process peak demand.
- **Fixes**
  - Increased memory limits/requests to a safe baseline.
  - Re-deployed with corrected resources.
- **Verification + prevention**
  - Restarts stabilized and pod remained healthy under expected load.
  - Added resource sizing baseline guidance per workload type.

### 4) Lab 4: Probe misconfiguration (liveness/readiness failure)
Source: [`LabPack/week1/lab4/README.md`](../../LabPack/week1/lab4/README.md)

- **Detection + impact**
  - Pod cycling due to liveness failures and/or not entering ready state.
  - Service endpoints unavailable or flapping.
- **Investigation timeline**
  - Inspected probe paths/ports and timings in deployment spec.
  - Correlated probe events with container logs.
- **Root cause + trigger**
  - Probe endpoint/port mismatch and overly strict probe timings.
- **Fixes**
  - Corrected probe route/port and tuned thresholds.
- **Verification + prevention**
  - Pod became `Ready` consistently; service endpoints populated.
  - Introduced startup/readiness review checklist for new services.

### 5) Lab 5: ConfigMap/Secret wiring failure
Source: [`LabPack/week1/lab5/README.md`](../../LabPack/week1/lab5/README.md)

- **Detection + impact**
  - Application started with wrong or missing configuration values.
  - Functional behavior deviated from expected runtime config.
- **Investigation timeline**
  - Inspected env mappings and key references.
  - Compared ConfigMap/Secret keys to deployment env declarations.
- **Root cause + trigger**
  - Incorrect key names and mismatched references in env wiring.
- **Fixes**
  - Corrected keys and environment variable references.
- **Verification + prevention**
  - App loaded expected values after rollout.
  - Added config contract check (required keys) before deploy.

---

## Week 2 — Networking, rollout, storage, policy, and incident flow

### 6) Lab 6: Service selector mismatch (no endpoints)
Source: [`LabPack/week2/lab6/README.md`](../../LabPack/week2/lab6/README.md)

- **Detection + impact**
  - Service reachable but had zero endpoints; requests failed.
- **Investigation timeline**
  - Compared service selector labels with pod labels.
  - Verified endpoint object remained empty.
- **Root cause + trigger**
  - Label/selector mismatch after manifest drift.
- **Fixes**
  - Aligned service selectors with pod labels.
- **Verification + prevention**
  - Endpoints populated and traffic succeeded.
  - Added label contract review during manifest updates.

### 7) Lab 7: Rolling update failure + rollback path
Source: [`LabPack/week2/lab7/README.md`](../../LabPack/week2/lab7/README.md)

- **Detection + impact**
  - Deployment rollout stalled with unhealthy new replicas.
  - Partial or full service degradation during update window.
- **Investigation timeline**
  - Checked rollout status, ReplicaSet health, and events.
  - Reviewed rollout history for last known good revision.
- **Root cause + trigger**
  - Bad deployment revision introduced invalid runtime behavior.
- **Fixes**
  - Rolled back to known healthy revision.
  - Reworked change set before retrying rollout.
- **Verification + prevention**
  - Stable replica availability restored.
  - Added rollout guardrails and pre-release validation.

### 8) Lab 8: PVC/PV binding failure (`Pending`)
Source: [`LabPack/week2/lab8/README.md`](../../LabPack/week2/lab8/README.md)

- **Detection + impact**
  - PVC remained `Pending`; pod could not start with required storage.
- **Investigation timeline**
  - Reviewed PVC events, storage class, access mode, and capacity.
  - Checked matching PV properties.
- **Root cause + trigger**
  - Incompatible PVC/PV settings (class/mode/size mismatch).
- **Fixes**
  - Corrected claim or volume specs for compatibility.
- **Verification + prevention**
  - PVC bound successfully and pod started.
  - Added storage manifest compatibility checklist.

### 9) Lab 9: NetworkPolicy deny path + connectivity debugging
Source: [`LabPack/week2/lab9/README.md`](../../LabPack/week2/lab9/README.md)

- **Detection + impact**
  - Inter-pod communication blocked unexpectedly.
- **Investigation timeline**
  - Tested connectivity from allowed/denied clients.
  - Reviewed policy selectors and namespace labels.
- **Root cause + trigger**
  - Default deny behavior without explicit allow for intended path.
- **Fixes**
  - Added least-privilege allow rule for required flow.
- **Verification + prevention**
  - Expected client traffic succeeded; non-allowed paths remained blocked.
  - Documented policy intent with test commands in runbook.

### 10) Lab 10: End-to-end incident simulation (`logs -> describe -> exec -> fix`)
Source: [`LabPack/week2/lab10/README.md`](../../LabPack/week2/lab10/README.md)

- **Detection + impact**
  - Application malfunction required full incident workflow.
- **Investigation timeline**
  - Followed structured path: logs, describe, in-container checks, fix.
  - Captured evidence before applying remediation.
- **Root cause + trigger**
  - Misconfiguration introduced application/runtime failure mode.
- **Fixes**
  - Applied targeted configuration correction.
- **Verification + prevention**
  - Service behavior normalized and error condition cleared.
  - Reinforced repeatable triage order for future incidents.

---

## Week 3 — Production pressure scenarios

### 11) Lab 11: Node outage + availability-first scheduling decision
Source: [`LabPack/week3/lab11/README.md`](../../LabPack/week3/lab11/README.md)

- **Detection + impact**
  - Node outage reduced placement options and threatened availability.
- **Investigation timeline**
  - Inspected node and pod scheduling events.
  - Compared strict spread policy behavior vs degraded-cluster reality.
- **Root cause + trigger**
  - Policy rigidity under failure reduced scheduling flexibility.
- **Fixes**
  - Applied availability-first scheduling adjustment during incident.
  - Restored stricter policy after cluster health normalized.
- **Verification + prevention**
  - Workloads rescheduled and availability restored.
  - Added incident-mode policy toggle strategy.

### 12) Lab 12: Memory pressure, OOM restarts, and evictions
Source: [`LabPack/week3/lab12/README.md`](../../LabPack/week3/lab12/README.md)

- **Detection + impact**
  - Cluster exhibited memory pressure with restarts/evictions.
- **Investigation timeline**
  - Correlated node pressure conditions with pod terminations.
  - Reviewed resource requests/limits and QoS behavior.
- **Root cause + trigger**
  - Aggregate memory demand exceeded safe node capacity.
- **Fixes**
  - Rebalanced resource settings and workload pressure profile.
- **Verification + prevention**
  - Memory pressure signals subsided and eviction frequency dropped.
  - Added memory headroom and saturation alert guidance.

### 13) Lab 13: Certificate trust failure and recovery
Source: [`LabPack/week3/lab13/README.md`](../../LabPack/week3/lab13/README.md)

- **Detection + impact**
  - TLS connections failed because client trust validation broke.
- **Investigation timeline**
  - Verified cert chain/trust material used by workload.
  - Confirmed failure tied to bad CA/cert trust input.
- **Root cause + trigger**
  - Invalid or untrusted certificate authority configuration.
- **Fixes**
  - Replaced trust material with valid CA/certificate data.
- **Verification + prevention**
  - TLS handshake succeeded post-remediation.
  - Added cert validity and trust-chain checks to release path.

### 14) Lab 14: CPU exhaustion and scheduler `Insufficient cpu`
Source: [`LabPack/week3/lab14/README.md`](../../LabPack/week3/lab14/README.md)

- **Detection + impact**
  - Pods pending due to scheduler reporting `Insufficient cpu`.
  - Existing workloads experienced contention and degraded latency.
- **Investigation timeline**
  - Observed CPU consumption and scheduler event stream.
  - Compared requests to allocatable node capacity.
- **Root cause + trigger**
  - CPU request sizing and load profile exceeded cluster budget.
- **Fixes**
  - Tuned CPU requests and reduced pressure from hog workload.
- **Verification + prevention**
  - Pending pods scheduled successfully.
  - Added capacity planning checkpoints for request changes.

### 15) Lab 15: Multi-service chain outage (frontend/backend/postgres)
Source: [`LabPack/week3/lab15/README.md`](../../LabPack/week3/lab15/README.md)

- **Detection + impact**
  - End-user flow failed across service chain dependencies.
- **Investigation timeline**
  - Traced path frontend -> backend -> database.
  - Validated service discovery, env config, and dependency readiness.
- **Root cause + trigger**
  - Downstream dependency/service wiring issue cascaded upstream.
- **Fixes**
  - Restored broken dependency path and corrected configuration.
- **Verification + prevention**
  - Full chain recovered with successful end-to-end response.
  - Added dependency health gates and chain-level smoke checks.

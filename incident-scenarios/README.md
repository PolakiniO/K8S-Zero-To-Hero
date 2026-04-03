# Incident Scenarios Index

This folder centralizes failure scenarios as a **system operations simulation**, not just isolated exercises.

Use this index to navigate incident drills and document the full investigation lifecycle:

1. Problem description
2. Investigation approach
3. Commands executed
4. Command/log evidence captured
5. Root cause proof
6. Resolution and verification

## Core scenarios mapped to existing labs

### 1) Pod fails due to memory limits (`OOMKilled`)
- Source lab: `Labs/K8S-Lab-Week1/yaml-files/lab3-memhog.yaml`
- Fix manifest: `Labs/K8S-Lab-Week1/yaml-files/lab3-memhog-fix.yaml`
- Suggested commands:
  - `kubectl describe pod <pod>`
  - `kubectl top pod <pod>`
  - `kubectl get events --sort-by=.metadata.creationTimestamp`

### 2) `ImagePullBackOff`
- Source flow: `Labs/K8S-Lab-Week1/README.md`
- Suggested commands:
  - `kubectl describe pod <pod>`
  - `kubectl get events --sort-by=.metadata.creationTimestamp`
  - `kubectl get pod <pod> -o yaml | yq '.spec.containers[].image'`

### 3) Service not reachable (selector/endpoints mismatch)
- Source lab: `Labs/K8S-Lab-Week2/lab6-service-broken.yaml`
- Fix manifest: `Labs/K8S-Lab-Week2/lab6-service-fix.yaml`
- Suggested commands:
  - `kubectl get svc,endpoints`
  - `kubectl get pods --show-labels`
  - `kubectl describe svc <service>`

### 4) DNS / egress policy issue
- Source labs:
  - `Labs/K8S-Lab-Week2/lab9-deny.yaml`
  - `Labs/K8S-Lab-Capstone/02-apps/41-netpol-allow-dns.yaml`
- Suggested commands:
  - `kubectl get networkpolicy -A`
  - `kubectl exec -it <pod> -- nslookup kubernetes.default.svc.cluster.local`
  - `kubectl exec -it <pod> -- wget -qO- http://<service>`

### 5) CrashLoop due to config/secret/probe mismatch
- Source flows:
  - `Labs/K8S-Lab-Week1/README.md`
  - `docs/production-troubleshooting-track.md`
- Suggested commands:
  - `kubectl logs <pod> --previous`
  - `kubectl describe pod <pod>`
  - `kubectl get secret,configmap -o yaml`

## Standard scenario write-up template

```md
## Scenario: <name>

### Problem
- What failed?
- What was the user impact?

### Investigation
- Hypotheses:
- Commands executed:
- Command/log evidence (sanitized snippets):
  ```txt
  $ <command>
  <redacted-or-anonymized-output>
  ```
- What was ruled out:

### RCA (Root Cause Analysis)
- Root cause summary:
- Trigger conditions:
- Why detection was delayed (if applicable):
- Corrective actions:

### Public Safety & Anonymization
- Replace company/internal names with generic labels (`org-a`, `svc-api`, `cluster-prod`).
- Mask sensitive values (IPs, account IDs, domains, tokens, emails) before publishing logs.
- Keep only technical evidence needed to prove diagnosis and fix.
- Exclude credentials, kubeconfigs, and internal URLs from command output.

### Resolution
- Immediate mitigation:
- Permanent fix:

### Verification
- Health checks:
- Metrics/logs after fix:

### Prevention
- Alerting/runbook/test/policy updates:
```

## System simulation linkage

To validate incidents in a realistic topology, run them against the capstone stack:
- frontend + backend + database workloads in `Labs/K8S-Lab-Capstone/02-apps/`
- ingress + metrics-server in `Labs/K8S-Lab-Capstone/01-platform/`

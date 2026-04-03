# Learning + Recruiter Showcase Guide

This repository is designed for **two audiences at the same time**:

1. **Learners** who want a practical Kubernetes troubleshooting course.
2. **Recruiters/Hiring Managers** who want clear evidence of production-style hands-on work.

## What is already strong (and should be emphasized)

When presenting this repo in interviews, highlight these points first:

- You built and operated a **hands-on Kubernetes lab**, not just a notes repository.
- You practiced failure scenarios that mirror real incidents (`CrashLoopBackOff`, image pull, networking, rollout, policy, storage).
- You used **objective diagnostics** (`kubectl describe`, `kubectl logs`, events, rollout history) instead of trial-and-error guessing.
- You documented investigations in a repeatable format (symptom → evidence → root cause → fix → prevention).
- You demonstrate **system-level thinking** across workload, network, identity, and platform behavior.

These are exactly the signals recruiters look for in support/platform/security-adjacent roles.

## How learners should use this as a course

Follow this order:

1. `docs/course-notebook.md`
2. `docs/kubectl-cheatsheet.md`
3. `docs/incident-debugging-playbook.md`
4. `docs/production-troubleshooting-track.md`
5. `docs/incident-investigation-mini-project.md`
6. `docs/eks-anonymized-interview-lab.md`

For each case/lab:
- write the symptom in one line,
- collect objective evidence (events/logs/metrics),
- state root cause in one sentence,
- record mitigation + permanent fix,
- add prevention items.

## How recruiters should review this repo quickly

If you have 10 minutes, read:

0. `showcase/recruiter-quick-view.md`
1. `docs/production-troubleshooting-track.md` (incident structure quality)
2. `docs/incident-investigation-mini-project.md` (RCA depth and repeatability)
3. `docs/eks-anonymized-interview-lab.md` (cloud architecture + security reasoning)

## Lab structure that works for both candidates and recruiters

Use this structure for every completed lab so it reads like real production evidence:

1. **Scenario**: what changed and what failed.
2. **Impact**: user/system impact and blast radius.
3. **Evidence**: exact commands and observed output.
4. **Root cause**: precise technical fault.
5. **Recovery**: immediate mitigation + permanent fix.
6. **Validation**: proof service recovered.
7. **Prevention**: alert/runbook/policy/test updates.
8. **Role fit**: one line on why this maps to TAM / Support / Platform / Security expectations.

## Repository positioning (GitHub-first)

Keep emphasis on repository evidence itself:
- working three-tier topology in capstone (`frontend`, `backend`, `database`),
- Kubernetes object coverage (Deployment/Service/ConfigMap/Secret/Ingress),
- incident scenarios with command-level proof,
- observability and cloud extension paths documented in-repo.

## Mapping feedback to existing repository assets

- **Real system shape**: available in `Labs/K8S-Lab-Capstone/02-apps/` with frontend/backend/postgres manifests.
- **Incident scenario process**: standardized in `incident-scenarios/README.md` and week labs.
- **Observability baseline**: `metrics-server` setup in capstone platform plus `kubectl top` verification flow.
- **Cloud path**: anonymized EKS + IAM + load balancer workflow in `docs/eks-anonymized-interview-lab.md`.

## What this demonstrates professionally

- Production incident triage habits.
- Evidence-based root cause analysis (not guesswork).
- Cloud/Kubernetes troubleshooting across app, network, identity, and storage layers.
- Security thinking: misconfiguration chaining and blast radius analysis.
- Communication: clear timeline, impact, decision rationale, and prevention planning.

## Portfolio checklist for each new lab

Use this checklist when adding future labs so they work for both learning and hiring review:

- [ ] Context: what was being built/tested?
- [ ] Detection: how was failure observed?
- [ ] Investigation: exact commands and what each proved.
- [ ] Root cause: what failed and why?
- [ ] Fix: immediate mitigation + permanent solution.
- [ ] Validation: proof that service recovered.
- [ ] Prevention: alert/runbook/policy/test updates.
- [ ] Role relevance: TAM/Support/Platform/Security skill signal stated clearly.
- [ ] Public safety: no sensitive identifiers.

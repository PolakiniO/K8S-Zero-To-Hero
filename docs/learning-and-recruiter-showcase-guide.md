# Learning + Recruiter Showcase Guide

This repository is designed for **two audiences at the same time**:

1. **Learners** who want a practical Kubernetes troubleshooting course.
2. **Recruiters/Hiring Managers** who want clear evidence of production-style hands-on work.

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
- [ ] Public safety: no sensitive identifiers.

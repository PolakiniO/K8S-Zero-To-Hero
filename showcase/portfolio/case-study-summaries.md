# Case Study Summaries (Recruiter-Friendly)

These summaries present completed work in a concise interview-ready format.

## Case Study 1 — Production Outage Triage Pattern

**Scope**
- Kubernetes production-style outage workflow with service and rollout checks.

**What was done**
- Defined triage-first investigation path (`pods`, `svc/endpoints`, events, rollout history).
- Documented common root-cause patterns and validation-first fix strategy.

**Evidence in repo**
- `docs/production-troubleshooting-track.md`
- `docs/incident-debugging-playbook.md`

**Showcase value**
- Demonstrates ability to reduce blast radius quickly and prove recovery with objective signals.

---

## Case Study 2 — Latency and Crash Investigation Discipline

**Scope**
- Structured method for diagnosing p95/p99 latency spikes and CrashLoopBackOff failures.

**What was done**
- Defined investigation commands, evidence expectations, likely causes, mitigation flow, and prevention actions.
- Added standardized RCA template for repeatable incident write-ups.

**Evidence in repo**
- `docs/incident-investigation-mini-project.md`
- `showcase/deliverable-template.md`

**Showcase value**
- Demonstrates consistent root-cause communication from detection through prevention.

---

## Case Study 3 — Anonymized EKS Three-Tier Security Lab

**Scope**
- Cloud lab with EKS app tier, MongoDB EC2 database tier, and S3 backup tier.

**What was done**
- Documented phased build plan and troubleshooting log (issue -> detection -> fix).
- Documented intentional security misconfigurations and realistic cloud attack-path chaining.
- Added explicit anonymization/safety controls for public publication.

**Evidence in repo**
- `docs/eks-anonymized-interview-lab.md`

**Showcase value**
- Demonstrates practical cloud platform implementation + security reasoning in a recruiter-safe format.

# Kubernetes Zero to Hero Repository

A practical, interview-focused Kubernetes learning repository built from the Kubernetes Zero to Hero course notes, expanded into structured documentation, hands-on labs, and production-style incident drills.

## Repository Goals

- Consolidate Kubernetes fundamentals into a Notion-ready and GitHub-friendly knowledge base.
- Provide step-by-step exercises from beginner to production troubleshooting.
- Build confidence for CKA and CKAD prep and TAM, Security, and Platform interview scenarios.
- Encourage repeatable, evidence-driven debugging workflows.

## Learning Paths

### 1) Foundations
1. [Course Notebook](docs/course-notebook.md)
2. [Kubernetes Glossary](docs/glossary.md)
3. [kubectl Command Cheat Sheet](docs/kubectl-cheatsheet.md)

### 2) Hands-on Labs (under `Labs/`)
- [Week 1: Core Operations and Failure Handling](Labs/K8S-Lab-Week1/README.md)
- [Week 2: Networking and Deployment Incidents](Labs/K8S-Lab-Week2/README.md)
- [Week 3: Advanced Production Thinking](Labs/K8S-Lab-Week3/README.md)
- [Capstone Phase1: Platform, Security, and Verification](Labs/K8S-Lab-Capstone/docs/phase1/README.md)

### 3) Interview Readiness
- [Interview Readiness Plan](docs/interview-readiness-plan.md)
- [Incident Debugging Playbook](docs/incident-debugging-playbook.md)

## Suggested Workflow
1. Read one topic from `docs/`.
2. Run the matching lab from `Labs/`.
3. Capture what failed, what command proved it, and what fixed it.
4. Add notes in the corresponding lab markdown files.
5. Re-run the same scenario until explanation is natural.

## Repository Structure

```text
.
├── docs/
├── Labs/
│   ├── K8S-Lab-Week1/
│   ├── K8S-Lab-Week2/
│   ├── K8S-Lab-Week3/
│   └── K8S-Lab-Capstone/
│       ├── 01-platform/
│       ├── 02-apps/
│       ├── docs/phase1/
│       └── scripts/
├── LabPack/
├── exercises/
└── scripts/
```

## Lab Navigation Quick Links
- [Week 1 README](Labs/K8S-Lab-Week1/README.md)
- [Week 2 README](Labs/K8S-Lab-Week2/README.md)
- [Week 3 README](Labs/K8S-Lab-Week3/README.md)
- [Capstone Phase1 README](Labs/K8S-Lab-Capstone/docs/phase1/README.md)

## How to Contribute Your Learning
- Keep examples reproducible.
- Prefer declarative manifests over ad-hoc commands.
- Add commands plus expected outcomes and failure modes.
- If you find an error, open an issue or submit a PR with corrected content.

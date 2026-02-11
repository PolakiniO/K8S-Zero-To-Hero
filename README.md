# Kubernetes Zero to Hero Repository

A practical, interview-focused Kubernetes learning repository built from the **Kubernetes Zero to Hero** course notes, expanded into structured documentation, hands-on labs, and production-style incident drills.

## Repository Goals

- Consolidate Kubernetes fundamentals into a Notion-ready and GitHub-friendly knowledge base.
- Provide step-by-step exercises from beginner to production troubleshooting.
- Build confidence for CKA/CKAD prep and TAM/Security/Platform interview scenarios.
- Encourage repeatable, evidence-driven debugging workflows.

## Learning Paths

### 1) Foundations
Start here if you are new to Kubernetes:

1. [Course Notebook](docs/course-notebook.md)
2. [Kubernetes Glossary](docs/glossary.md)
3. [kubectl Command Cheat Sheet](docs/kubectl-cheatsheet.md)

### 2) Hands-on Labs
Progress through these in order:

- [Week 1: Core Operations + Failure Handling](exercises/week-1/README.md)
- [Week 2: Networking + Deployment Incidents](exercises/week-2/README.md)
- [Week 3: Advanced Production Thinking](exercises/week-3/README.md)

### 3) Interview Readiness
Use these to speak clearly about real incidents:

- [Interview Readiness Plan](docs/interview-readiness-plan.md)
- [Incident Debugging Playbook](docs/incident-debugging-playbook.md)

## Suggested Workflow

1. Read one topic from `docs/`.
2. Run the matching exercise from `exercises/`.
3. Capture what failed, what command proved it, and what fixed it.
4. Add your notes in the exercise markdown files.
5. Re-run the same scenario until explanation becomes natural.

## Repository Structure

```text
.
├── docs/
│   ├── course-notebook.md
│   ├── glossary.md
│   ├── incident-debugging-playbook.md
│   ├── interview-readiness-plan.md
│   └── kubectl-cheatsheet.md
├── exercises/
│   ├── week-1/
│   ├── week-2/
│   └── week-3/
├── manifests/
│   └── templates/
├── K8S-Lab-Week1/
│   └── ExportBlock-.../
├── k8s/
│   └── week1/
└── scripts/
    └── verify-markdown-links.sh
```


## Imported Week 1 Notion Export

If you imported the Week 1 Notion export, use this entry point:

- [`K8S-Lab-Week1/README.md`](K8S-Lab-Week1/README.md)

This keeps the original export for reference while exposing normalized YAML manifests for lab execution.

## How to Contribute Your Learning

- Keep examples reproducible.
- Prefer declarative manifests over ad-hoc commands.
- Add commands + expected outcomes + failure modes.
- If you find an error, open an issue or submit a PR with corrected content.

---

If you are preparing for interviews, treat every failed lab as an incident report and practice saying the root cause in one sentence.

# 🚀 Kubernetes Zero to Hero Repository

A practical, interview-focused **public open source Kubernetes course** built from **Kubernetes Zero to Hero** course notes and expanded into:
- structured documentation,
- hands-on labs,
- and production-style incident drills.

---

## 🎯 Repository Goals

- Consolidate Kubernetes fundamentals into a Notion-ready and GitHub-friendly knowledge base.
- Provide step-by-step exercises from beginner to production troubleshooting.
- Build confidence for **CKA/CKAD prep** and TAM, Security, and Platform interview scenarios.
- Encourage repeatable, evidence-driven debugging workflows.

## ✅ Prerequisites

Before starting, make sure you have:

### Required
- Basic Linux command-line familiarity.
- Basic understanding of containers and Kubernetes concepts (pods, services, deployments).
- A local Kubernetes environment, such as:
  - [minikube](https://minikube.sigs.k8s.io/docs/start/),
  - [kind](https://kind.sigs.k8s.io/), or
  - Docker Desktop Kubernetes.

### CLI Tools
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
- [`helm`](https://helm.sh/docs/intro/install/) *(recommended for extended experiments)*
- [`git`](https://git-scm.com/downloads)

### Helpful (Optional)
- [`k9s`](https://k9scli.io/)
- [`jq`](https://jqlang.github.io/jq/)
- [`yq`](https://mikefarah.gitbook.io/yq/)

---

## 🧭 Learning Paths

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

---

## 🛠️ Suggested Workflow

1. Read one topic from `docs/`.
2. Run the matching lab from `Labs/`.
3. Capture what failed, what command proved it, and what fixed it.
4. Add notes in the corresponding lab markdown files.
5. Re-run the same scenario until explanation is natural.

## 🗂️ Repository Structure

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

## 🔗 Lab Navigation Quick Links

- [Week 1 README](Labs/K8S-Lab-Week1/README.md)
- [Week 2 README](Labs/K8S-Lab-Week2/README.md)
- [Week 3 README](Labs/K8S-Lab-Week3/README.md)
- [Capstone Phase1 README](Labs/K8S-Lab-Capstone/docs/phase1/README.md)

## 🤝 How to Contribute Your Learning

- Keep examples reproducible.
- Prefer declarative manifests over ad-hoc commands.
- Add commands plus expected outcomes and failure modes.
- If you find an error, open an issue or submit a PR with corrected content.

See also:
- [Contributing Guide](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
- [March 20, 2026 Public Course Security Audit](docs/reviews/public-course-security-audit-2026-03-20.md)

## Security hygiene checks

Before publishing changes, run:

```bash
./scripts/security-release-scan.sh
```

This blocks accidental inclusion of `.zip`, Notion export artifacts, `.env` files, key material, dumps/logs, and common high-risk secret patterns in tracked files.


## 🪪 Licensing

This repository is available under the [MIT License](LICENSE).

## 📌 Publication note

The current working tree is clean for publication, but the repository history still needs a one-time cleanup to fully remove legacy Notion export artifacts. Run:

```bash
./scripts/security-history-scan.sh
brew install git-filter-repo  # or: pipx install git-filter-repo
./scripts/rewrite-history-security-clean.sh --yes
```

Then force-push rewritten refs and tags from a coordinated maintainer clone.

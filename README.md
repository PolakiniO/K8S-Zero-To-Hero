# K8S Zero to Hero

[![License](https://img.shields.io/github/license/PolakiniO/K8S-Zero-To-Hero)](LICENSE) [![Platform](https://img.shields.io/badge/platform-Kubernetes-326CE5)](#) [![Focus](https://img.shields.io/badge/focus-Hands--On-success)](#) [![Status](https://img.shields.io/badge/status-public--ready-brightgreen)](#)

```text
    __ ______ _____    _____                       ______            __  __              
   / //_( __ ) ___/   /__  /  ___  _________      /_  __/___        / / / /__  _________ 
  / ,< / __  \__ \______/ /  / _ \/ ___/ __ \______/ / / __ \______/ /_/ / _ \/ ___/ __ \
 / /| / /_/ /__/ /_____/ /__/  __/ /  / /_/ /_____/ / / /_/ /_____/ __  /  __/ /  / /_/ /
/_/ |_|\____/____/     /____/\___/_/   \____/     /_/  \____/     /_/ /_/\___/_/   \____/ 
                                                                                         
```

**Learn Kubernetes by doing the work.**
Labs, notes, debugging drills, and interview-focused practice in one repo.

No fluff. No locked platform. Just docs, manifests, incidents, and repetition.

---

## Why this repo exists

Kubernetes gets easier once you stop treating it like theory.

This repository is built to help you:

- learn core Kubernetes concepts through guided notes,
- practice real troubleshooting instead of memorizing commands,
- prepare for CKA/CKAD-style workflows,
- build stronger platform, TAM, and security interview instincts.

---

## What you get

- Structured course notes in `docs/`
- Progressive hands-on labs in `Labs/`
- Incident-style debugging scenarios
- Cheat sheets and glossary material
- Capstone exercises for platform and security thinking

---

## Quick Start

### 1) Prerequisites

You should already be comfortable with:

- basic Linux shell usage,
- containers and images,
- basic Kubernetes concepts like Pods, Deployments, and Services.

Recommended local environments:

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kind](https://kind.sigs.k8s.io/)
- Docker Desktop Kubernetes

Recommended CLI tools:

- [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
- [`git`](https://git-scm.com/downloads)
- [`helm`](https://helm.sh/docs/intro/install/) *(recommended)*
- [`jq`](https://jqlang.github.io/jq/) *(helpful)*
- [`yq`](https://mikefarah.gitbook.io/yq/) *(helpful)*
- [`k9s`](https://k9scli.io/) *(optional)*

---

### 2) Start here

If you're new to the repo, begin in this order:

1. [Course Notebook](docs/course-notebook.md)
2. [Kubernetes Glossary](docs/glossary.md)
3. [kubectl Cheat Sheet](docs/kubectl-cheatsheet.md)
4. [Week 1 Labs](Labs/K8S-Lab-Week1/README.md)
5. [Week 2 Labs](Labs/K8S-Lab-Week2/README.md)
6. [Week 3 Labs](Labs/K8S-Lab-Week3/README.md)
7. [Capstone Phase 1](Labs/K8S-Lab-Capstone/docs/phase1/README.md)

---

## Recommended workflow

Use the repo like this:

1. Read one topic from `docs/`
2. Run the matching lab from `Labs/`
3. Break something on purpose
4. Prove what failed with commands and output
5. Fix it
6. Repeat until you can explain the failure from memory

That is where the real learning happens.

---

## Repository layout

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

---

## Learning paths

### Foundations

- [Course Notebook](docs/course-notebook.md)
- [Kubernetes Glossary](docs/glossary.md)
- [kubectl Command Cheat Sheet](docs/kubectl-cheatsheet.md)

### Hands-on labs

- [Week 1: Core Operations and Failure Handling](Labs/K8S-Lab-Week1/README.md)
- [Week 2: Networking and Deployment Incidents](Labs/K8S-Lab-Week2/README.md)
- [Week 3: Advanced Production Thinking](Labs/K8S-Lab-Week3/README.md)
- [Capstone Phase 1: Platform, Security, and Verification](Labs/K8S-Lab-Capstone/docs/phase1/README.md)

### Interview readiness

- [Interview Readiness Plan](docs/interview-readiness-plan.md)
- [Incident Debugging Playbook](docs/incident-debugging-playbook.md)

---

## Security checks before publishing

Run these before making changes public:

```bash
bash scripts/security-release-scan.sh
bash scripts/security-history-scan.sh
```

These scans are intended to block accidental publication of:

- `.zip` files,
- Notion export artifacts,
- `.env` files,
- key material,
- local dumps/logs,
- and several high-risk secret patterns.

For the March 20, 2026 publication review, see:

- [Public Course Security Audit](docs/reviews/public-course-security-audit-2026-03-20.md)
- [Security Policy](SECURITY.md)

---

## Contributing

Found a mistake? Want to improve a lab? Want to add a cleaner debugging flow?

Contributions are welcome.

Start here:

- [Contributing Guide](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)

Please keep examples reproducible, prefer declarative manifests, and include failure signals plus the fix.

---

## License

MIT. See [LICENSE](LICENSE).

# Repository Structure Guide

This document is the source of truth for how `K8S-Zero-To-Hero` is organized.

## Top-level folders

- `docs/` — core notes, troubleshooting guides, interview prep, and review docs.
- `Labs/` — canonical lab source material grouped by week and capstone.
- `LabPack/` — runner-friendly weekly lab bundles with per-lab READMEs and assets.
- `showcase/` — recruiter-facing summaries, templates, and portfolio assets.
- `incident-scenarios/` — centralized incident index and scenario write-up template.
- `exercises/` — short weekly practice prompts and lightweight drill guides.
- `manifests/templates/` — reusable Kubernetes manifest templates.
- `scripts/` — repo maintenance, security, and link verification scripts.
- `.github/` — GitHub workflow and repository automation metadata.
- `.githooks/` — local git hook scripts installed via `scripts/install-githooks.sh`.

## Canonical learning flow

Use this path when navigating the repository:

1. Start in `docs/course-notebook.md`.
2. Run labs from `Labs/` in week order.
3. Use `LabPack/` when you want an isolated per-lab packet.
4. Capture outcomes in `showcase/`.
5. Normalize incident write-ups via `incident-scenarios/README.md`.

## Labs organization

```text
Labs/
├── K8S-Lab-Week1/
├── K8S-Lab-Week2/
├── K8S-Lab-Week3/
└── K8S-Lab-Capstone/
    ├── 01-platform/
    ├── 02-apps/
    ├── docs/phase1/
    └── scripts/
```

## LabPack organization

```text
LabPack/
├── week1/
│   ├── lab1/
│   ├── lab2/
│   ├── lab3/
│   ├── lab4/
│   └── lab5/
├── week2/
│   ├── lab6/
│   ├── lab7/
│   ├── lab8/
│   ├── lab9/
│   └── lab10/
└── week3/
    ├── lab11/
    ├── lab12/
    ├── lab13/
    ├── lab14/
    └── lab15/
```

## Maintenance notes

- Treat `Labs/` as the primary content location for course progression.
- Keep `LabPack/` aligned with corresponding labs when manifests are updated.
- Prefer adding net-new reusable YAML examples to `manifests/templates/`.
- Keep scripts idempotent and shellcheck-friendly in `scripts/`.

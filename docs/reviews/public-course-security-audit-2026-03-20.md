# Public Course Security Audit — 2026-03-20

## Scope

This review covered:

- the current working tree,
- the documented course content,
- repository automation and contributor workflow,
- the full reachable git history.

## What passed

### Current tree security hygiene

The current tree passed the repository scanners for:

- forbidden tracked artifact types,
- high-risk secret patterns,
- tracked files that now match `.gitignore`,
- local markdown link integrity.

## What still requires maintainer action

### 1. Git history still contains legacy Notion export material

Historical commits still reference:

- `ExportBlock-*` Notion-export folders,
- a `.zip` archive,
- renamed paths under both `K8S-Lab-Week1/` and `Labs/K8S-Lab-Week1/`.

This is not a current working-tree leak, but it **is** a publication risk because anyone can still retrieve those artifacts from repository history.

### 2. Public-open-source controls were incomplete before this audit

Before this change set, the repository did not include:

- a top-level open source license,
- a public-facing security policy,
- contributor guidance for safe examples and commit hygiene,
- repository-local git hooks for pre-commit enforcement,
- GitHub Actions to enforce the same checks in pull requests.

## Changes applied in this audit

- Added `LICENSE` so the repository can be published as a true open source project.
- Added `SECURITY.md` with public-repo disclosure rules and scanning workflow.
- Added `CONTRIBUTING.md` with content and commit hygiene requirements.
- Added `.githooks/pre-commit` plus `scripts/install-githooks.sh` to enforce local checks.
- Added `.github/workflows/repo-guardrails.yml` to run the same checks in CI.
- Updated the root README to describe the project as a public open source course and link governance docs.

## Maintainer follow-up checklist

1. Install hooks locally with `./scripts/install-githooks.sh`.
2. Run all repository checks before each push.
3. Rewrite history with `./scripts/rewrite-history-security-clean.sh --yes` from a fresh mirror clone.
4. Force-push rewritten refs and tags.
5. Ask collaborators to reclone and invalidate old forks if needed.
6. Enable branch protection and required status checks in GitHub settings.
7. Optionally require signed commits in GitHub repository settings.

## Recommended repository settings after push

- Require pull requests before merging.
- Require the `Repo Guardrails` workflow to pass.
- Restrict force pushes after the one-time history rewrite.
- Require signed commits if your maintainer workflow supports GPG, SSH, or S/MIME signing.

# Security Policy

This repository is intended to be a **public, educational Kubernetes course**. That means the repository must never contain live secrets, private infrastructure data, customer data, or internal export artifacts.

## Supported security posture

The current branch is considered publishable only when all of the following are true:

- `./scripts/security-release-scan.sh` passes.
- `./scripts/check-tracked-ignored-files.sh` passes.
- `./scripts/verify-markdown-links.sh` passes.
- Git history has been reviewed with `./scripts/security-history-scan.sh`.

## Reporting a vulnerability

Please **do not** open a public issue for suspected secrets, credentials, or vulnerable content.

Instead:

1. Privately contact the maintainer.
2. Include the file path, commit SHA, and a short impact summary.
3. Rotate any exposed credential before or immediately after disclosure.

## Repository rules for contributors

- Use only placeholder values in manifests and docs.
- Never commit `.env` files, key material, kubeconfigs, dumps, or logs.
- Do not paste cloud account IDs, private IPs, internal hostnames, or real certificates unless they are already public and intentionally documented.
- Prefer examples such as `EXAMPLE_NOT_A_REAL_SECRET`, `example.local`, and RFC 5737 documentation IPs.

## Commit and history hygiene

This repo already includes repository-local scanners, but they only protect the current tree unless contributors run them consistently.

Before opening a PR:

```bash
./scripts/install-githooks.sh
./scripts/security-release-scan.sh
./scripts/check-tracked-ignored-files.sh
./scripts/verify-markdown-links.sh
```

To review historical risk:

```bash
./scripts/security-history-scan.sh
```

If history still contains export bundles or risky artifacts, use the rewrite helper from a coordinated mirror clone:

```bash
brew install git-filter-repo  # or: pipx install git-filter-repo
./scripts/rewrite-history-security-clean.sh --yes
```

After any history rewrite, force-push branches and tags and ask collaborators to reclone.

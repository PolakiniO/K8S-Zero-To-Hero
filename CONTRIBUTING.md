# Contributing

Thanks for helping improve **Kubernetes Zero to Hero** as a public open source learning repo.

## Contribution goals

We welcome contributions that improve:

- technical accuracy,
- reproducible lab steps,
- learner experience,
- accessibility and formatting,
- security hygiene for a public repo.

## Local checks before every commit

Install the repository-local git hooks once:

```bash
./scripts/install-githooks.sh
```

Then make sure these checks pass before you push:

```bash
./scripts/security-release-scan.sh
./scripts/check-tracked-ignored-files.sh
./scripts/verify-markdown-links.sh
```

## Content rules

- Keep examples educational and safe for a public repo.
- Use fake secrets and documentation-only hostnames/IPs.
- Explain when a manifest is intentionally broken for lab purposes.
- Prefer pinned image tags over implicit `latest` tags.
- Include the commands a learner should run and what result they should expect.

## Commit guidance

- Use clear, descriptive commit messages.
- Keep unrelated changes in separate commits.
- Do not commit generated archives, editor temp files, or exported workspace dumps.
- If a commit touches security-sensitive material, mention the risk and remediation in the PR body.

## Pull requests

A good PR should include:

- what changed,
- why it changed,
- how it was validated,
- any follow-up work still required.

If you change learner-facing content, update adjacent documentation so navigation stays accurate.

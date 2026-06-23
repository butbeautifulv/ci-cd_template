# GitHub OSS Full — Node/TypeScript profile

Profile **`oss-full-node`** for Next.js, React, npm, Vitest stacks without Python-centric validate.

## Adopt

```bash
./scripts/adopt.sh --profile oss-full-node --platform github --target .
```

Activates `ci-profile.yml` → `.github/workflows/ci.yml`.

## Pipeline

| Stage | Workflow | Notes |
|-------|----------|-------|
| validate | `base-validate-node.yml` | typecheck, ESLint, Vitest via `package.json` scripts |
| security | `security-gates-oss.yml` | Flat inline OSS scanners (no nested `jobs/oss/`) |
| build | `oss/build-push.yml` | GHCR |
| sbom / sca / sign | `jobs/sbom-oss.yml`, `oss/sca-image.yml`, `jobs/sign-oss.yml` | main/master only |
| sec-func | `jobs/sec-func-tests.yml` | `tests/security/` **or** Vitest `@security` / `test:security` |
| DAST (manual) | `dast-compose-oss.yml` | Compose + ZAP on localhost |

**Not included by default:** Helm deploy, conftest, Schemathesis, binary fuzz, Ruff linters job (skipped without `pyproject.toml`).

## Day-1 gate policy

Copy warn-first defaults for noisy scanners:

```bash
cp config/security-gate-policy-adopt.yaml config/security-gate-policy.yaml
```

After Semgrep triage, set `sast.mode: block` in `security-gate-policy.yaml`.

## Branch names

Workflow triggers `main` and `master`. Adjust `on.push.branches` if your default branch differs.

## Compose DAST

```bash
# workflow_dispatch with inputs, or set env in repo:
# DAST_COMPOSE_FILE, DAST_TARGET_URL, DAST_COMPOSE_SERVICES
```

See [dast-compose-oss.yml](../../templates/github/workflows/dast-compose-oss.yml).

## GitLab variant

```bash
./scripts/adopt.sh --profile oss-full-node --platform gitlab --target .
```

Uses `templates/gitlab/jobs/oss/validate-node.yml` instead of Ruff/pytest.

## Case study

Real adoption on FSTEC: [fstec-adaptation-case-study.md](../references/supplements/fstec-adaptation-case-study.md).

## Validate

```bash
bash scripts/validate-github-oss.sh
./scripts/adopt.sh --profile oss-full-node --platform github --target /tmp/node-test --dry-run
```

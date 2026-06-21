# Quickstart

## 1. Greenfield (new repo)

```bash
git clone <this-template> myapp && cd myapp
./scripts/adopt.sh --profile shift-left --platform github --target .
git add . && git commit -m "chore: adopt devsecops shift-left profile"
```

Enable branch protection: [platforms/github.md](platforms/github.md).

## 2. GitLab migrate (existing pipeline)

1. Backup `.gitlab-ci.yml`
2. `./scripts/adopt.sh --profile minimal --platform gitlab --target .`
3. Merge your build/deploy jobs into `.gitlab/jobs/_base.yml`
4. One PR per phase: add `secret-scan.yml`, then `sast.yml`, …
5. Checklist: [adoption-checklist.md](adoption-checklist.md)

## 3. GitHub migrate (existing Actions)

1. Copy `templates/github/workflows/jobs/` → `.github/workflows/jobs/`
2. Add reusable call in your `ci.yml`:

```yaml
jobs:
  security-gates:
    uses: ./.github/workflows/security-gates.yml
```

3. Copy `config/security-gate-policy.yaml` + `scripts/gate-check.py`
4. Set repo variable `ENABLE_REAL_LINTERS=true` when ready

## Validate on sample app

```bash
cd examples/sample-app
trivy fs .
checkov -d infra/
hadolint Dockerfile
```

## Cursor agents

Open [AGENTS.md](../AGENTS.md) and track todos in `.cursor/plans/devsecops-execution.plan.md`.

## Profiles

| Need | Profile |
|------|---------|
| CI skeleton only | `minimal` |
| MR security gates | `shift-left` |
| SBOM + image scan | `supply-chain` |
| DAST + preprod | `full` |

```bash
./scripts/adopt.sh --profile supply-chain --platform gitlab --target ~/myapp --dry-run
```

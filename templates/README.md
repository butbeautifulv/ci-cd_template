# Templates — adoption guide

## Quick adopt

```bash
./scripts/adopt.sh --profile shift-left --platform gitlab --target ~/myapp
./scripts/adopt.sh --profile shift-left --platform github --target ~/myapp --dry-run
```

## Progressive profiles (`profiles/`)

| Profile | GitLab | GitHub | Phases |
|---------|--------|--------|--------|
| `minimal` | A2 only | lint/test/build | A2 |
| `shift-left` | + B1–B6 | + security-gates | A2, B* |
| `supply-chain` | + C1–C4 | + sbom/scan/sign | + C* |
| `full` | all jobs | + DAST/preprod | + D*, F* |

Copy profile to entrypoint:

```bash
cp templates/profiles/shift-left.gitlab-ci.yml .gitlab-ci.yml
cp -r templates/gitlab/jobs .gitlab/jobs
# Fix paths: local: '.gitlab/jobs/_base.yml'
```

## GitLab manual copy

1. `templates/gitlab/.gitlab-ci.yml` or a **profile** → `.gitlab-ci.yml`
2. `templates/gitlab/jobs/` → `.gitlab/jobs/`
3. `config/security-gate-policy.yaml` → `config/`
4. `scripts/gate-check.py` → `scripts/`
5. `templates/CODEOWNERS` → `CODEOWNERS`

## GitHub manual copy

1. `templates/github/workflows/` → `.github/workflows/`
2. `templates/profiles/*.github.yml` → reference for `ci.yml`
3. `templates/github/dependabot.yml` → `.github/dependabot.yml`
4. Policy + gate-check script (as above)

## Migrate existing pipeline (30 min)

1. Run `./scripts/adopt.sh --profile minimal` — keep your build/test jobs
2. Merge your stages with `_base.yml` patterns
3. Add B1: include `secret-scan.yml` only → one PR
4. Enable branch protection ([`docs/platforms/`](../docs/platforms/))
5. Each week add next profile tier

## Kubernetes (E-phases)

```bash
kubectl apply -f templates/k8s/admission/
kubectl apply -f templates/k8s/network/
helm upgrade falco falcosecurity/falco -f templates/k8s/runtime/falco-values.yaml
```

## Pre-commit

```bash
cp templates/pre-commit/.pre-commit-config.yaml .pre-commit-config.yaml
pre-commit install
```

## Sub-phase order

[docs/phases/](../docs/phases/) — one PR per phase. See [docs/adoption-checklist.md](../docs/adoption-checklist.md).

## Validate

```bash
bash scripts/validate-yaml.sh
python scripts/gate-check.py --control sast --report /tmp/test.sarif
```

Test scans on [examples/sample-app/](../examples/sample-app/).

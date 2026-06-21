# Quickstart

v1.2: GitLab-first gate hardening; три SDLC-модели — [references/sdlc-mapping.md](references/sdlc-mapping.md).

## 1. Greenfield (new repo)

```bash
git clone <this-template> myapp && cd myapp
./scripts/adopt.sh --profile shift-left --platform gitlab --target .
git add . && git commit -m "chore: adopt devsecops shift-left profile"
```

Enable branch protection: [platforms/gitlab.md](platforms/gitlab.md) or [platforms/github.md](platforms/github.md).

## 2. Profile ladder

| Step | Profile | When |
|------|---------|------|
| 1 | `minimal` | CI skeleton only |
| 2 | `shift-left` | MR security gates (default) |
| 3 | `supply-chain` | SBOM + image scan on main |
| 4 | `full` | DAST, preprod, nightly SAST |

```bash
./scripts/adopt.sh --profile shift-left --platform gitlab --target ~/myapp
./scripts/adopt.sh --profile supply-chain --platform gitlab --target ~/myapp --dry-run
```

## 3. GitLab migrate (existing pipeline)

1. Backup `.gitlab-ci.yml`
2. `./scripts/adopt.sh --profile minimal --platform gitlab --target .`
3. Merge your build/deploy jobs into `.gitlab/jobs/_base.yml`
4. One PR per phase: add `secret-scan.yml`, then `sast.yml`, …
5. Paths rewritten automatically to `.gitlab/jobs/`

## 4. GitHub migrate

```bash
./scripts/adopt.sh --profile shift-left --platform github --target .
```

Or manually: copy workflows + `config/security-gate-policy.yaml` + `scripts/gate-check.py`.

## 5. Post-adopt validation

```bash
bash scripts/validate-yaml.sh
python3 scripts/validate-policy.py
python3 scripts/gate-check.py --control sbom --report examples/sample-app/sbom.cdx.json 2>/dev/null || true
```

## 6. Validate on sample app

```bash
cd examples/sample-app
trivy fs .
checkov -d infra/
hadolint Dockerfile
```

Expected: findings for SAST/SCA/IaC demos — use to verify gates in adopted repo.

## 7. Troubleshooting

| Issue | Fix |
|-------|-----|
| GitLab `include` not found | Re-run `adopt.sh` or set `local: '.gitlab/jobs/...'` |
| B6 always passes | Set `ENABLE_REAL_LINTERS=true` |
| Gate too strict | Tune [config/security-gate-policy.yaml](../config/security-gate-policy.yaml) |

## 8. Plan before code

Threat model: [templates/governance/threat-model-checklist.md](../templates/governance/threat-model-checklist.md)

## Cursor agents

[AGENTS.md](../AGENTS.md) — track `.cursor/plans/devsecops-execution.plan.md`.

Checklist: [adoption-checklist.md](adoption-checklist.md).

# Профиль GitHub Actions

## Workflows

Копировать `templates/github/workflows/` → `.github/workflows/`.

| Workflow | Назначение |
|----------|------------|
| `ci.yml` | Entry: validate, test, build |
| `security-gates.yml` | Reusable: secrets, SAST, SCA, IaC, dockerfile |
| `deploy-preprod.yml` | main → preprod |
| `dast.yml` | manual / label `run-dast` |

## Security actions

| Контроль | Action |
|----------|--------|
| Secrets | `gitleaks/gitleaks-action` |
| SAST | `github/codeql-action` + `returntocorp/semgrep-action` |
| SCA | `actions/dependency-review-action`, `aquasecurity/trivy-action` (fs) |
| IaC | `bridgecrewio/checkov-action` |
| Dockerfile | `hadolint/hadolint-action` |
| Container | `aquasecurity/trivy-action` (image) |

## Branch protection

Settings → Branches → `main`:

- [ ] Require pull request before merging
- [ ] Required approvals: **2**
- [ ] Dismiss stale reviews on new commits
- [ ] Require status checks: `security-gates`, `ci`
- [ ] Require signed commits (рекомендация)
- [ ] Include administrators

## Dependabot

`templates/github/dependabot.yml` → `.github/dependabot.yml`

## Registry

- ghcr.io или internal registry
- OIDC: `aws-actions/configure-aws-credentials` / `azure/login` / custom K8s

```yaml
permissions:
  id-token: write
  contents: read
  security-events: write
```

## SARIF

Upload: `github/codeql-action/upload-sarif` для агрегации в Security tab.

---

## A1 — SCM hardening checklist

Зеркало GitLab checklist для GitHub.

### Branch protection (`main`)

- [ ] Require PR, 2 reviewers
- [ ] Require status checks (CI + security)
- [ ] No force push
- [ ] Linear history (squash merge only)

### CODEOWNERS

- [ ] `CODEOWNERS` в корне (шаблон: `templates/CODEOWNERS`)
- [ ] `@security-team` на `config/security-gate-policy.yaml`, `.github/workflows/`

### Security

- [ ] Dependabot alerts enabled
- [ ] Secret scanning + push protection (GitHub Advanced Security)
- [ ] 2FA org-wide

### Signed commits

- [ ] GPG or SSH commit signing required (branch rule)

### Copy-paste: branch protection via CLI

```bash
# Require PR + status checks
gh api repos/{owner}/{repo}/branches/main/protection -X PUT \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["security-gates / secrets", "CI / lint"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 2,
    "dismiss_stale_reviews": true
  },
  "restrictions": null
}
EOF
```

Аудит: скриншоты в тикете. См. [phases/A1-scm-hardening.md](../phases/A1-scm-hardening.md).

# Профиль GitLab CI

## Pipeline stages

```
validate → test → security → build → deploy → post-deploy
```

Entrypoint: `templates/gitlab/.gitlab-ci.yml` (копировать в корень проекта).

**GitLab CE / без Ultimate:** профиль **`oss-full`** — [gitlab-oss-full.md](gitlab-oss-full.md) (Gitleaks, Semgrep, Trivy, Checkov напрямую).

## Includes (security)

| Job file | GitLab template (альтернатива) |
|----------|--------------------------------|
| `jobs/secret-scan.yml` | `Security/Secret-Detection.gitlab-ci.yml` |
| `jobs/sast.yml` | `Security/SAST.gitlab-ci.yml` |
| `jobs/osa.yml` | `Security/Dependency-Scanning.gitlab-ci.yml` |
| `jobs/sca.yml` | alias → `osa.yml` (legacy include) |
| `jobs/iac-scan.yml` | `Security/IaC-Scanning.gitlab-ci.yml` |
| `jobs/dockerfile-lint.yml` | custom hadolint |
| `jobs/container-scan.yml` | `Security/Container-Scanning.gitlab-ci.yml` — gate `sca:` |

## MR-only rules

```yaml
rules:
  - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

## Registry

- Container Registry + Container Scanning
- **Dependency Proxy** — OSS firewall (`T-ADI-DEP-2-2`)
- `REGISTRY: $CI_REGISTRY_IMAGE`

## OIDC / secrets

- CI/CD variables — masked, protected
- Vault integration для runtime secrets (`T-DEV-SM-2-1`)

## Scan policies

GitLab Ultimate: Scan Result Policies. Иначе — `config/security-gate-policy.yaml` + script gate.

---

## A1 — SCM hardening checklist

`T-DEV-SCM-1-*`, `T-DEV-SRC-1-5`, `T-DEV-SRC-2-6`

### Protected branches

- [ ] `main` protected: no direct push для developers
- [ ] Maintainers only: force push disabled
- [ ] Allowed to merge: Developers + Maintainers с approvals

### Merge request approvals

- [ ] Minimum **2** approvals (`T-DEV-SRC-3-4`)
- [ ] Prevent approval by author
- [ ] Reset approvals on new commits (`T-DEV-SRC-1-2`)
- [ ] Code Owners enabled (`CODEOWNERS`)

### Push rules

- [ ] Reject unsigned commits (рекомендация `T-DEV-SRC-3-3`)
- [ ] Reject commit messages matching `\[(skip ci|ci skip)\]` (`T-DEV-CICD-1-5`)
- [ ] Require linear history

### Repository

- [ ] Default branch: `main`
- [ ] Visibility: private для внутренних проектов (`T-DEV-SCM-1-6`)
- [ ] MFA для всех members (`T-DEV-SCM-3-3`)

### Аудит

Скриншоты настроек + ссылка на тикет в `docs/phases/A1-scm-hardening.md`.

### Copy-paste: GitLab API (protected branch)

```bash
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/protected_branches" \
  --data "name=main&push_access_level=0&merge_access_level=30&allow_force_push=false"
```

См. также [github.md](github.md) для зеркального чеклиста.

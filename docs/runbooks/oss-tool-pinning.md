# OSS Tool Version Pinning

Policy for GitLab **`oss-full`** profile and shared scanner jobs after the **TeamPCP** supply-chain incident (March 2026).

## Rules

### Forbidden in CI

| Pattern | Example | Why |
|---------|---------|-----|
| Rolling Docker tags | `:latest`, `:stable`, `latest-debian` | Tag can point to compromised image |
| Unpinned pip | `pip install checkov` | Resolves to newest PyPI on every run |
| Branch install scripts | Trivy `install.sh@main` | Supply-chain takeover vector (CVE-2026-33634) |
| kubectl `stable.txt` | floating K8s release channel | Same class of rolling resolution |

### Forbidden in production runtime

- **Watchtower** or similar auto-redeploy on rolling scanner/runtime images
- Pulling `aquasec/trivy:latest` (or any security tool) without digest review

### Required

1. Semver or immutable image tag in [`config/oss-tool-versions.yaml`](../../config/oss-tool-versions.yaml)
2. GitLab variables mirror in [`templates/gitlab/jobs/oss/versions.yml`](../../templates/gitlab/jobs/oss/versions.yml)
3. Updates **only via PR** with SecChamp + vendor advisory review
4. Run `bash scripts/validate-oss-pins.sh` in CI or pre-merge

## Manifest

Single source of truth:

```bash
config/oss-tool-versions.yaml
```

Profile `oss-full` includes `versions.yml` first so jobs use `OSS_*` variables.

## Updating a tool

1. Read vendor release notes / CVE advisories
2. Bump version in `config/oss-tool-versions.yaml`
3. Sync matching keys in `templates/gitlab/jobs/oss/versions.yml`
4. Update hardcoded pins in shared jobs if the image is not variable-driven (`sbom.yml`, `dockerfile-lint.yml`, etc.)
5. `bash scripts/validate-oss-pins.sh`
6. PR with SecChamp approval

## Trivy install (pinned tarball)

Do **not** use:

```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
```

Use GitHub release tarball:

```bash
TRIVY_VERSION="${OSS_TRIVY_VERSION:-0.63.0}"
curl -sfL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
  | tar xz -C /usr/local/bin trivy
```

## Incident context

See [supply-chain-teampcp-2026.md](../references/supply-chain-teampcp-2026.md) — compromised Trivy → LiteLLM PyPI → Checkmarx Actions.

## DAF alignment

- `T-ADI-DEP-1-5` — reject latest tags (`osa.reject_latest_tags` in security gate policy)
- `tooling_pins` section in [`config/security-gate-policy.yaml`](../../config/security-gate-policy.yaml)

## Follow-up (not in v1.4.2)

- Image digest pinning (`image@sha256:…`)
- GitHub Actions `aquasecurity/trivy-action` pin audit

# OSS Tool Version Pinning

Policy for **`oss-full`** profile (GitLab + GitHub) after the **TeamPCP** supply-chain incident (March 2026).

Shared profile docs: [platforms/oss-full-shared.md](../platforms/oss-full-shared.md)

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
2. Regenerate mirrors: `python3 scripts/generate-oss-pins.py`
3. Updates **only via PR** with SecChamp + vendor advisory review
4. CI checks: `validate-oss-pins.sh`, `validate-pin-sync.sh`

## Manifest and generated targets

Single source of truth:

```bash
config/oss-tool-versions.yaml
```

Generated (header `# GENERATED — do not edit`):

| File | Platform |
|------|----------|
| `templates/gitlab/jobs/oss/versions.yml` | GitLab `OSS_*` variables |
| `config/github-oss-env.yml` | GitHub env reference |
| `templates/profiles/oss-full.github.yml` | Profile `env:` block |

GitLab jobs also use `${OSS_*:-default}` in `_base.yml`, `sbom.yml`, `dockerfile-lint.yml`.

## Updating a tool

1. Read vendor release notes / CVE advisories
2. Bump version in `config/oss-tool-versions.yaml`
3. `python3 scripts/generate-oss-pins.py`
4. `bash scripts/validate-pin-sync.sh && bash scripts/validate-oss-pins.sh`
5. PR with SecChamp approval

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

See [supply-chain-teampcp-2026.md](../references/supply-chain-teampcp-2026.md).

## DAF alignment

- `T-ADI-DEP-1-5` — reject latest tags (`osa.reject_latest_tags` in security gate policy)
- `tooling_pins` section in [`config/security-gate-policy.yaml`](../../config/security-gate-policy.yaml)

## Follow-up (not in scope)

- Image digest pinning (`image@sha256:…`)
- GitHub Actions `aquasecurity/trivy-action` pin audit for non-oss profiles

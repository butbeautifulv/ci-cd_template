# SBOM monitor (F3) — operational runbook

## Continuous monitoring

1. Upload `sbom.cdx.json` from each main build to Dependency-Track / SBOM manager.
2. Enable alerts on new CVE affecting prod SBOM components.
3. Auto-create ticket when Critical CVE appears (integration via webhook).

## Dependency-Track webhook stub

```bash
# POST SBOM after C1 job (example)
curl -X POST "https://dependency-track.example.com/api/v1/bom" \
  -H "X-Api-Key: ${DTRACK_API_KEY}" \
  -H "Content-Type: multipart/form-data" \
  -F "project=UUID-HERE" \
  -F "bom=@sbom.cdx.json"
```

GitLab CI snippet:

```yaml
sbom-upload:
  stage: post-deploy
  script:
    - curl -X POST "$DTRACK_URL/api/v1/bom" -H "X-Api-Key: $DTRACK_API_KEY" \
        -F "project=$DTRACK_PROJECT_UUID" -F "bom=@sbom.cdx.json"
  needs: [sbom-generate]
  when: manual
```

## SBOM signature verify (F3)

Before prod deploy, verify CycloneDX signature:

```bash
cosign verify-blob --certificate-identity-regexp ... --certificate-oidc-issuer-regexp ... \
  --bundle sbom.cdx.json.bundle sbom.cdx.json
```

## Drift detection

Weekly job compares prod SBOM vs latest main build SBOM; report diff in SecChamp channel.

## Red team cadence

Quarterly tabletop + annual external pentest for critical systems (see D3).

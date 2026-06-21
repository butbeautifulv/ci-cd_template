# F3 — Advanced continuous assurance

## DAF: `T-PROD-DAST-1-2`, `T-ADI-DEP-4-1`, `T-PROD-PENTEST-3-1`

## Файлы: `jobs/nightly-full-sast.yml`, `jobs/sbom-monitor.yml` (doc), `docs/phases/F3-advanced.md`

## Практики

- Nightly full SAST on main
- Passive prod DAST (traffic mirror)
- SBOM signature verify before deploy
- Bug Bounty program outline
- Red Team cadence (annual)
- Security func tests target 20% (`T-PREPROD-SECTEST-3-1`)

## Gate

SBOM drift alert; new CVE in prod SBOM → auto-ticket.

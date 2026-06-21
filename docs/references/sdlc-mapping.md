# Маппинг SDLC-моделей

Три взгляда на DevSecOps в этом репозитории:

| Модель | Документ | Фокус |
|--------|----------|-------|
| **Secure SDLC (8 этапов)** | [secure-sdlc-phases.md](secure-sdlc-phases.md) | Plan → Monitor |
| **DAF / Кирилламида** | [daf-kirillamida.md](daf-kirillamida.md) | Зрелость 0–7, практики T-/P- |
| **Финтех swimlane** | [fintech-swimlane.md](fintech-swimlane.md) | Зоны DEV/QA/UAT/PROD, MR gates |

## Secure SDLC ↔ DAF ↔ Template ↔ Pipeline

| Secure SDLC | DAF (примеры) | Template P0–F3 | Pipeline / SDLC | Coverage |
|-------------|---------------|----------------|-----------------|----------|
| **Plan** | `P-REQ-TM`, `P-REQ-RD`, misuse/abuse | P0, A1, P1 | Tracker, threat model | doc-only (P1) |
| **Code** | `T-CODE-SST`, `T-CODE-SC`, `T-CODE-SECDN` | B1–B6 | MR/PR security gates | implemented |
| **Build** | `T-DEV-BLD`, `T-ADI-ART`, `T-CODE-IMG` | A2, C1–C2 | build + SBOM + scan | implemented |
| **Test** | `T-PREPROD-DAST`, `T-PREPROD-SECTEST`, IAST | D1–D2, F1 | preprod deploy | implemented (D partial gate) |
| **Release** | `T-PREPROD-PENTEST`, `T-ADI-ART-4` | C4, D3 | release checklist | doc-only (D3) |
| **Deploy** | `T-PROD-NETWORK`, `T-PROD-SM` | E1–E2, F2 | CD, WAF/RASP | partial (E1–E2 CI/cluster; PKI gap) |
| **Operate** | `T-PROD-RUN`, `T-PROD-EVENTS` | E3–E4, F2 | Falco, SIEM, RASP | partial (cluster; chaos gap) |
| **Monitor** | `T-ADI-DEP`, continuous SCA | F3 | SBOM monitor, ASTO | doc-only (F3 runbook) |

**Coverage:** `implemented` = job/template wired; `partial` = часть в CI, часть runbook; `doc-only` = процесс/runbook без CI job.

## Практики ↔ template jobs

| Secure SDLC practice | Template job / doc | Coverage |
|---------------------|-------------------|----------|
| SAST | `jobs/sast.*` (B2) | implemented |
| SCA | `jobs/sca.*` (B3), `sbom.*` (C1) | implemented |
| Configuration Drift | `jobs/iac-scan.*` (B4), Kyverno (E1) | partial |
| DAST | `jobs/dast.*` (D1) | implemented |
| IAST | `jobs/iast-preprod.*` (F1) | implemented (manual) |
| Secrets | `jobs/secret-scan.*` (B1) | implemented (warn) |
| Linters | `jobs/linter-security.*` (B6) | implemented (warn) |
| WAF / RASP | [F2-rasp-waf.md](../phases/F2-rasp-waf.md) | doc-only |
| Security Monitoring | E4 SIEM, F3 SBOM monitor | partial |
| Misuse/Abuse cases | [P1-threat-model.md](../phases/P1-threat-model.md) | doc-only |
| Performance / Chaos | — | gap |
| PKI / IDS | runbooks | gap |

## Out of scope (documented only)

- Performance Testing, Chaos Engineering — Operate/Test; см. [F4-resilience.md](../phases/F4-resilience.md)
- PKI, IDS — Deploy/Operate; см. [runbooks/pki-k8s.md](../runbooks/pki-k8s.md)
- Misuse/Abuse cases — Plan; [templates/governance/threat-model-checklist.md](../../templates/governance/threat-model-checklist.md)

## Связанные документы

- [01-sdlc-process.md](../01-sdlc-process.md)
- [05-maturity-roadmap.md](../05-maturity-roadmap.md)
- [03-security-controls.md](../03-security-controls.md)

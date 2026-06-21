---
name: devsecops-fintech-sdlc
description: >-
  Fintech secure SDLC swimlane: DEV/QA/UAT/PROD zones, MR security gate
  components, ASTO, fuzzing, roles. Use when designing process, writing
  01-sdlc-process.md, or aligning pipeline with fintech PDF.
---

# Fintech SDLC swimlane

Source: `docs/references/extracts/fintech-pdf.txt`, supplement [supplements/Типовой_процесс_безопасной_разработки_для_финтеха.md](../../docs/references/supplements/Типовой_процесс_безопасной_разработки_для_финтеха.md)

Repo: `docs/01-sdlc-process.md`, `docs/references/fintech-swimlane.md`.

## Zones

| Zone | Data | Controls |
|------|------|----------|
| DEV | Synthetic | IDE SAST, linters, MR pipeline |
| QA | Synthetic | Unit, fuzzing, sanitizers |
| UAT | Prepared test | DAST, IAST, load tests |
| PROD | Real | WAF, RASP, SBOM monitor |
| Security mgmt | — | Policies, ASTO, IRM/GRC |

Feature branch environments allowed.

## MR Security Gate (parallel)

1. SAST (IDE light + CI full)
2. Linters (style + security)
3. Secret-check
4. Forbidden/extra files (binaries)
5. SCA (post-SBOM on build — «no regression» in CD)

## IDE SAST options (from PDF)

1. Standalone IDE plugin
2. Corporate SAST server policies

## Design

- Threat model / attack surface
- **Taint Analysis Tool** — SecChamp refines surface
- Maps to GOST 5.6–5.7

## QA / UAT testing

| Type | Tools |
|------|-------|
| Fuzzing | AFL++, Jazzer, go-fuzz |
| Concolic | language-specific engines |
| Sanitizers | ASan, Valgrind |
| DAST + coverage | ZAP + coverage metrics |
| PII leak tests | custom |
| Load | k6, JMeter |

## Operations

- **ASTO** — aggregate SAST/DAST/SCA (DefectDojo, Jit)
- **IRM/GRC** — risk & compliance
- OBOM + SBOM continuous monitoring
- RASP, WAF, API Sec — prod only

## Special modes

- **Trunk-based** — default
- **Bugfix** — reduced gate, skip UAT, documented risk
- Risk acceptance with deferred checks allowed
- All task artifacts in tracker

Roles & details: [reference.md](reference.md)

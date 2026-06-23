# FSTEC adaptation case study

Real-world adoption of `ci-cd_template` on [butbeautifulv/fstec](https://github.com/butbeautifulv/fstec) — Next.js 16, TypeScript, npm, Vitest, Docker Compose (no K8s/Helm/OpenAPI).

**Outcome:** 6 push iterations → CI green ([run 27914512996](https://github.com/butbeautifulv/fstec/actions/runs/27914512996)). Policy/gates worked; **GitHub mechanics** required template fixes.

## Stack vs template defaults

| Area | FSTEC | Default `oss-full` |
|------|-------|-------------------|
| Validate | npm typecheck, ESLint, Vitest | Ruff + pytest |
| Deploy | Docker Compose | Helm + K8s |
| DAST | ZAP on `localhost:3000` | preprod URL |
| OpenAPI fuzz | N/A | Schemathesis |
| Branch | `master` | `main` |

Use profile **`oss-full-node`** and **`dast-compose-oss.yml`** for this stack.

## Template bugs found (fixed in template)

| # | Severity | Problem | Fix in template |
|---|----------|---------|-----------------|
| 1 | critical | Reusable workflows under `workflows/jobs/oss/` | Flat inline jobs in `security-gates-oss.yml` |
| 2 | critical | `vars`/`secrets` in composite `gate-and-export` | Pass `defectdojo_url` / `defectdojo_token` as **inputs** |
| 3 | high | Placeholder SARIF missing `version`, `tool`, `locations` | `scripts/normalize-sarif.py` in gate-and-export |
| 4 | high | Docker scans write root-owned SARIF | `sudo chown "$(id -u):$(id -g)"` after scan |
| 5 | medium | Semgrep `-u $(id -u)` → `PermissionError: /.semgrep` | `-e HOME=/tmp` (no `-u`) |
| 6 | medium | Hadolint hand-written SARIF without `locations` | Valid SARIF with `physicalLocation` |
| 7 | low | Validator missed nested workflow paths | `validate-github-oss.sh` depth check |
| 8 | low | `sast.mode: block` noisy on day-1 | `config/security-gate-policy-adopt.yaml` (warn first) |

## CI iteration timeline

| Run | Commit | Result | Root cause |
|-----|--------|--------|------------|
| [27914218951](https://github.com/butbeautifulv/fstec/actions/runs/27914218951) | 771ba71 | fail 0s | Nested reusable workflow paths |
| [27914248484](https://github.com/butbeautifulv/fstec/actions/runs/27914248484) | 25b5653 | fail parse | Composite `vars`/`secrets` |
| [27914303079](https://github.com/butbeautifulv/fstec/actions/runs/27914303079) | 4c37155 | 7/8 fail upload | Invalid SARIF schema |
| [27914371411](https://github.com/butbeautifulv/fstec/actions/runs/27914371411) | 081e096 | 4/8 fail | Root-owned SARIF + sast block |
| [27914433923](https://github.com/butbeautifulv/fstec/actions/runs/27914433923) | 1192d57 | 7/8 pass | Hadolint SARIF without locations |
| [27914512996](https://github.com/butbeautifulv/fstec/actions/runs/27914512996) | 1d62713 | **ALL GREEN** | All fixes applied |

## Adopt commands (zero manual patches)

```bash
./scripts/adopt.sh --profile oss-full-node --platform github --target /path/to/fstec
# Optional day-1 policy:
cp config/security-gate-policy-adopt.yaml config/security-gate-policy.yaml
```

## Out of scope for FSTEC (documented gaps)

Helm deploy, Conftest/K8s admission, Schemathesis (no OpenAPI), binary fuzz, IAST preprod URL — see [oss-full-shared.md](../../platforms/oss-full-shared.md).

## Related docs

- [github-oss-full-node.md](../../platforms/github-oss-full-node.md)
- [adoption-checklist.md](../../adoption-checklist.md)
- [github-oss-full.md](../../platforms/github-oss-full.md)

# Tool catalog (synthesized from PDF + template)

## Linters (MR gate — fintech)

ESLint security, golangci-lint, Ruff/Bandit, shellcheck

## Fuzzing / sanitizers (QA — optional CI)

AFL++, libFuzzer, Jazzer, Honggfuzz, ASan, MSan, Valgrind

## BCA / binary

Ghidra, JADX, radare2 | Binary Ninja, IDA Pro

## Codec / mobile obfuscation

ProGuard, DexGuard — mobile only, out of base template

## Taint analysis

Design-phase tools for SecChamp — not default CI job

## Dockerfile (JCSF Dock)

Hadolint, Checkov, Dockle

## Integration point

All scanners → SARIF → `security-gate-policy.yaml` severities → DefectDojo

## SARIF producers in this repo

- `templates/gitlab/jobs/sast.yml`
- `templates/gitlab/jobs/sca.yml`
- `templates/gitlab/jobs/secret-scan.yml`
- GitHub mirrors in `templates/github/workflows/jobs/`

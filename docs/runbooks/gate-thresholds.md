# Gate thresholds (Security as Code)

Single source of truth: [`config/security-gate-policy.yaml`](../config/security-gate-policy.yaml) (+ adopt twin).

| Control | Mode (strict) | Threshold knobs | Notes |
|---------|---------------|-----------------|-------|
| secrets | block (S1.2) | `max_findings` (0 = severity-only) | adopt stays warn |
| sast / osa / sca / iac | block | `severity_block` | count not duplicated |
| dockerfile | block (S1.3) | paths | — |
| linters | warn | `max_findings` (default 50) | when `ENABLE_REAL_LINTERS` |
| infra | warn → block (S1.4) | `summarize_threshold`, `failed_threshold`, `xccdf_failed_threshold` | count-based OVAL/XCCDF |
| dast / fuzzing | warn | `block_release_debt` | no count in this wave |

Evaluator: [`scripts/gate-check.py`](../scripts/gate-check.py). Soft-fail contract: [ci-soft-fail-contract.md](ci-soft-fail-contract.md).

## Mirror warn → block queue (no flip yet)

After ≥3 green multi-service pilots (`hwa_service`, `data_lake_service`, `user_service`), tighten **one control per PR**:

1. `secrets` (gitleaks) — drop mirror `allow_failure`, adopt → strict for that control  
2. `dockerfile` (hadolint)  
3. Then `sast` / `osa` / `iac` / `sca` as noise allows  

Do **not** edit `security-gate-policy-adopt.yaml` to block in this enrichment wave — document only. Full roadmap: [mirror-security-pipeline-action-log.md](mirror-security-pipeline-action-log.md).

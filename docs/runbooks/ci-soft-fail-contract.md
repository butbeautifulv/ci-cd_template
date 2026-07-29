# CI soft-fail contract

How scanners may fail without lying about the security gate (refs/1.1 soft→hard pedagogy).

| Pattern | OK? | Why |
|---------|-----|-----|
| `scanner … \|\| true` then `gate-check` | yes | Scanner exit ≠ policy decision; report must exist for gate |
| `\|\| echo "Issues detected"` without report | **no** | Pipeline stays green with no artifact (lesson 1.2 anti-pattern) |
| `allow_failure: true` + `mode: block` | **no** | Double soft — pick one lever |
| Manual job `allow_failure: true` + `mode: warn` | yes | Burn-in / exploration |
| Schedule job `allow_failure: false` | yes | Nightly must surface gate exit |
| Block-mode GL jobs (`secrets`/`sast`/`osa`/`sca`/`iac`/`dockerfile`) override `allow_failure: false` | yes | Overrides `.security_job_defaults`; scanner may still use `\|\| true` before gate |
| `source scripts/gate-check.py` | **no** | Use `python3 scripts/gate-check.py` |
| `bash scripts/oscap-*.sh` | yes | Executable gate path |

`.security_job_defaults.allow_failure: true` is for early adoption noise; jobs that must enforce policy override `allow_failure: false` (block controls + oscap schedule rules).

## Mirror (`oss-full-service-mirror`) — hard-fail

Mirror jobs set **`allow_failure: false`** (override `.security_job_defaults`). A failed scanner/build/upload fails the pipeline. Intentional Schemathesis *skip* (no OpenAPI / no `API_BASE_URL` / `BUILD_FALLBACK=1`) logs and exits 0 — that is not a soft-fail of a broken tool.

| Lever | Mirror value |
|-------|--------------|
| Policy | `security-gate-policy-adopt.yaml` may still `mode: warn` for finding thresholds |
| Job | `allow_failure: false` except `cleanup-runner` |

Do **not** reintroduce blanket `allow_failure: true` to hide broken builds.

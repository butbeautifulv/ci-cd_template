# CI pipeline observability

Guide for monitoring DevSecOps gates with Prometheus/Grafana (RED method from grafana-dashboards skill).

## RED for security gates

| Metric | Meaning | Example |
|--------|---------|---------|
| **Rate** | Gate runs per hour | `sum(rate(github_workflow_run_total{workflow=~"security.*"}[1h]))` |
| **Errors** | Failed gate checks | `sum(rate(gate_check_failures_total[5m])) by (control)` |
| **Duration** | Scan job wall time | `histogram_quantile(0.95, rate(workflow_job_duration_seconds_bucket[5m]))` |

## USE for CI runners

| Metric | Meaning |
|--------|---------|
| **Utilization** | Runner CPU/memory % |
| **Saturation** | Queued jobs depth |
| **Errors** | Runner disconnect / OOM |

## Dashboard layout

1. **Top row** — big numbers: MR pass rate, open critical findings, mean gate duration
2. **Middle** — time series per control (secrets, sast, osa, iac, dockerfile, linters)
3. **Bottom** — table of latest SARIF exports / DefectDojo sync status

## cxado stack

Unified observability lives in meta-repo `deploy/observability/`:

```bash
make -C ../.. cxado-up-obs   # from consumer project
```

Grafana: `http://localhost:3000` — provision datasources from `deploy/observability/grafana/`.

## Wiring gate metrics (optional)

Export from `scripts/gate-check.py` exit events via CI wrapper or pushgateway:

```bash
# Example: increment on failure (consumer-side)
python scripts/gate-check.py --control sast --report semgrep.sarif || \
  echo 'gate_check_failures_total{control="sast"} 1' | curl --data-binary @- http://pushgateway:9091/metrics/job/ci
```

## Related

- Phase [E4-siem.md](../phases/E4-siem.md)
- ASPM export: [aspm-export.md](aspm-export.md)

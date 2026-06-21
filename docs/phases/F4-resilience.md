# F4 — Chaos / resilience (Operate)

## Цель

Secure SDLC **Operate**: resilience and chaos testing — **process only**, no default CI job.

## Sources

- DSOMM mapping #82 (chaos monkey) — [DSOMM_mapping.md](../references/extracts/daf/DSOMM_mapping.md)
- [secure-sdlc-phases.md](../references/secure-sdlc-phases.md) — Operate stage

## Recommended approach

1. **Game days** — quarterly fault injection on preprod
2. **Tools** — LitmusChaos, Chaos Mesh, Gremlin (org choice)
3. **Scenarios** — pod kill, AZ loss, dependency timeout, cert expiry
4. **Evidence** — runbook + postmortem ticket; not MR gate

## Acceptance

- [ ] Chaos playbook documented in ops wiki
- [ ] At least one preprod drill per quarter (manual)
- [ ] Findings feed backlog / DAF `P-DEFECT-MNG`

## Rollback

N/A — optional maturity exercise.

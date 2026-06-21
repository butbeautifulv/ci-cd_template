# F2 — WAF / API Sec + RASP (prod)

## DAF: `T-PROD-NETWORK-2-2` | финтех-PDF

## Файлы: `docs/phases/F2-rasp-waf.md` only — **no CI**

## Runbook checklist

### WAF

- [ ] Temporary rules have ticket + expiry date
- [ ] SecChamp + ИБ approve before prod apply
- [ ] Post-review in weekly security sync
- [ ] OWASP CRS / custom rules versioned in Git
- [ ] Rollback procedure tested on preprod

### API gateway

- [ ] OpenAPI policies in version control
- [ ] Test on preprod before prod
- [ ] Rate limiting + auth policies documented
- [ ] Rollback via gateway admin API documented

### RASP

- [ ] Alerting only — **not a pipeline gate**
- [ ] SIEM integration (`E4`) — Falco/WAF/RASP correlation
- [ ] Runbook: triage → dev → patch → verify
- [ ] False positive tuning cadence (monthly)

### Integration points

| Control | Owner | Evidence |
|---------|-------|----------|
| WAF rules | Ops | Change ticket |
| API policies | DevOps | Git repo |
| RASP alerts | SecChamp | SIEM dashboard |
| PKI / certs | Ops | [runbooks/pki-k8s.md](../runbooks/pki-k8s.md) |
| Network IDS | Ops | Edge appliance (out of CI) |

### PKI vs IDS

- **PKI** — certificate lifecycle, rotation; see [runbooks/pki-k8s.md](../runbooks/pki-k8s.md)
- **IDS** — network intrusion detection at edge; **Falco** covers runtime/host (E3), not L3 IDS appliance

## Rollback

Disable WAF rule / RASP policy via change ticket.

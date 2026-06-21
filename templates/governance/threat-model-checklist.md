# Threat model checklist (Plan / Secure SDLC)

DAF: `P-REQ-TM-*`, `P-REQ-TM-4-1` (misuse/abuse cases).

## 1. Scope

| Item | Value |
|------|-------|
| Feature / epic | |
| Owner | |
| SecChamp reviewer | |
| Data classification | public / internal / confidential / restricted |

## 2. Assets and trust boundaries

- [ ] Data flows documented (diagram or link)
- [ ] External integrations listed
- [ ] Secrets and key material identified

## 3. STRIDE (summary)

| Threat | Mitigation in design | Owner |
|--------|-------------------|-------|
| Spoofing | | |
| Tampering | | |
| Repudiation | | |
| Information disclosure | | |
| Denial of service | | |
| Elevation of privilege | | |

## 4. Misuse cases

| ID | Legitimate use | Misuse scenario | Control / test |
|----|--------------|-----------------|----------------|
| MU-1 | | | → D2 sec-func test |
| MU-2 | | | |

## 5. Abuse cases

| ID | Attacker goal | Attack path | Control / test |
|----|---------------|-------------|----------------|
| AB-1 | | | |
| AB-2 | | | |

## 6. Sign-off

- [ ] SecChamp reviewed before implementation MR
- [ ] Linked in tracker ticket / design doc
- [ ] Residual risks accepted or deferred with ticket

См. [docs/phases/P1-threat-model.md](../../docs/phases/P1-threat-model.md), [secure-sdlc-phases.md](../../docs/references/secure-sdlc-phases.md).

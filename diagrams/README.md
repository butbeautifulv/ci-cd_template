# Fabrica — threat modeling diagrams

Reference diagrams and **Plan-phase artifacts** for Secure SDLC (Threat Modeling, DAF `P-REQ-TM`): DFD v3, C4 FastAPI, CI/CD overlay, K8s deployment, STRIDE register, Threat Dragon JSON, security requirements.

Used in DevSecOps courses to connect **architecture** with **security control placement** (Fabrica B1–F3).

## Prerequisites

- Python 3.11+
- **System Graphviz** (`dot` binary):

```bash
sudo apt install graphviz   # Debian/Ubuntu
brew install graphviz       # macOS
```

## Quick start

```bash
cd projects/fabrica/diagrams
pip install -e ".[dev]"

# SVG diagrams only
python main.py

# SVG + all TM artifacts
python main.py --export all -o out/

make -C .. diagrams
```

## Diagrams

| Output | Module | Purpose |
|--------|--------|---------|
| `dfd_diagram.svg` | `diagrams/dfd.py` | DFD v3 — STRIDE labels, LINDDUN on PII, trust boundaries |
| `architecture.svg` | `diagrams/architecture.py` | C4 L3 — OpenAPI, abuse-case annotations |
| `pipeline_security.svg` | `diagrams/pipeline.py` | Shift-left → runtime gates |
| `k8s_deploy.svg` | `diagrams/k8s_deploy.py` | C4 L2 — Ingress, Pod, E-phase controls |

## Exports (`--export`)

| Flag | Output | Description |
|------|--------|-------------|
| `stride-md` | `stride_register.md` | STRIDE threat register with Fabrica control mapping |
| `threat-dragon` | `threat_model.json` | OWASP Threat Dragon 2.x import |
| `requirements` | `security_requirements.yaml` | Threat → security requirement traceability |
| `all` | SVG + all artifacts above | Full workshop bundle |

```bash
python main.py --export stride-md -o out/
python main.py --export threat-dragon -o out/
python main.py --export requirements -o out/
```

Canonical model: [`diagrams/model.py`](diagrams/model.py). Optional DOT override: [`templates/dfd.dot`](templates/dfd.dot).

## Workshop templates

| Template | Purpose |
|----------|---------|
| [`templates/threat-model-session.md`](templates/threat-model-session.md) | Session scope, threat register, review schedule |
| [`templates/misuse-abuse-cases.md`](templates/misuse-abuse-cases.md) | Misuse/abuse scenarios (+ [`sample-app /admin`](../../examples/sample-app/app/main.py)) |
| [`templates/taint-analysis-checklist.md`](templates/taint-analysis-checklist.md) | Entry/sink taint review (Fabrica design gap) |

## Workshop flow (курс)

1. `python main.py` — render DFD + C4
2. `python main.py --export stride-md -o out/` — threat register
3. Fill [`templates/misuse-abuse-cases.md`](templates/misuse-abuse-cases.md)
4. Complete [`templates/taint-analysis-checklist.md`](templates/taint-analysis-checklist.md)
5. `python main.py --export requirements -o out/` — traceability to B/D gates
6. Review `pipeline_security.svg` + `k8s_deploy.svg` — shift-left → runtime

## SDLC / playbook links

- Secure SDLC Plan: [`docs/references/secure-sdlc-phases.md`](../docs/references/secure-sdlc-phases.md)
- Governance `P-REQ-TM`: [`docs/07-governance-and-docs.md`](../docs/07-governance-and-docs.md)
- Control matrix: [`docs/03-security-controls.md`](../docs/03-security-controls.md)
- API fuzz reference: [`examples/openapi/minimal.yaml`](../examples/openapi/minimal.yaml)
- Veil playbook skill: `performing-threat-modeling-with-owasp-threat-dragon`
- Workspace skills: `stride-analysis-patterns`, `security-requirement-extraction`

## Element → Fabrica control mapping

| Diagram element | Threat / concern | Fabrica control | Phase |
|-----------------|------------------|-----------------|-------|
| User credentials (PII) | Spoofing, disclosure | B1, D2 | B, D |
| FastAPI / OAuth2 / JWT | Spoofing, elevation | B2, D2 | B, D |
| Pydantic validation | Tampering, injection | B2, D1 | B, D |
| pydantic-settings / env | Info disclosure | B1, B5 | B |
| httpx outbound | SSRF | B2, D1 | B, D |
| PostgreSQL | SQL injection | B2, D1 | B, D |
| S3 / object storage | Tampering, disclosure | B4, E2 | B, E |
| OpenAPI /docs | Info disclosure | Process, D1 | D |
| Container image | Supply chain CVE | C1, C2, B5 | C, B |
| MR pipeline | Shift-left coverage | B1–B5 | B |
| K8s Pod | Runtime compromise | E1, E3 | E |
| Ingress / WAF | Edge attacks | F2 runbook | F |

## Tests

```bash
pytest
```

Export tests run without `dot`. Render tests skip when Graphviz is not installed.

## Reference

Port of [`.external/threat-modeling-main`](../../.external/threat-modeling-main) (Go) to Python/FastAPI for Fabrica. v3 enrichment from `.agents/skills` and Veil threat-dragon corpus.

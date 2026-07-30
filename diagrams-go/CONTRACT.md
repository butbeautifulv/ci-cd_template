# DFD bundle contract (CI artifact)

Mandatory files under `reports/dfd/<SERVICE_NAME>/`:

| File | Rule |
|------|------|
| `dfd_diagram.svg` | Non-empty; well-formed SVG (`<svg` root) |
| `index.html` | Non-empty; links to SVG + exports |
| `stride_register.md` | Non-empty Markdown table |
| `threat_model.json` | Valid JSON; Threat Dragon 2.x shape (`version`, `summary`, `detail`) |
| `security_requirements.yaml` | Non-empty; top-level `requirements:` |

Acceptance (local / CI):

```sh
SERVICE_NAME=hwa_service ./scripts/dfd-export-ci.sh
test -s reports/dfd/hwa_service/dfd_diagram.svg
test -s reports/dfd/hwa_service/index.html
test -s reports/dfd/hwa_service/stride_register.md
test -s reports/dfd/hwa_service/threat_model.json
test -s reports/dfd/hwa_service/security_requirements.yaml
```

Renderer: Go binary `fabrica-diagrams-go` (no Graphviz, no Python).

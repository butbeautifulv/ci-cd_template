# DFD bundle contract (CI artifact)

Mandatory files under `reports/dfd/<SERVICE_NAME>/`:

| File | Rule |
|------|------|
| `index.html` | Interactive viewer; loads **local** `./viz.js` + `./full.render.js` (no CDN); embeds DOT; calls `viz.renderSVGElement` |
| `viz.js` | Vendored Viz.js 2.1.2 |
| `full.render.js` | Vendored Viz.js full render |
| `dfd_diagram.dot` | Non-empty; contains `digraph` |
| `dfd_diagram.svg` | Non-empty; well-formed SVG (`<svg` root) — static fallback |
| `stride_register.md` | Non-empty Markdown table |
| `threat_model.json` | Valid JSON; Threat Dragon 2.x shape |
| `security_requirements.yaml` | Non-empty; top-level `requirements:` |

Acceptance:

```sh
SERVICE_NAME=hwa_service ./scripts/dfd-export-ci.sh
```

Renderer: Go binary `fabrica-diagrams-go` (no host Graphviz/Python).

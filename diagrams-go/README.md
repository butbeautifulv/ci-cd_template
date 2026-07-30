# fabrica-diagrams-go

Single static binary that renders the Fabrica DFD threat-model bundle **without host Graphviz or Python**.

## Browse

Open **`index.html`** first. It embeds DOT and renders with **offline** `viz.js` / `full.render.js` (zoom, pan, fit, SVG/PNG download). No CDN.

## Outputs

See [CONTRACT.md](CONTRACT.md). Also writes:

- `dfd_diagram.dot` — Graphviz source used by the interactive viewer
- `viz.js`, `full.render.js` — vendored next to `index.html`

## Local

```sh
go test ./...
CGO_ENABLED=0 go build -o bin/fabrica-diagrams-go ./cmd/fabrica-diagrams-go
./bin/fabrica-diagrams-go --output-dir /tmp/dfd-out --export all --only dfd --service-name demo
# open /tmp/dfd-out/index.html in a browser
```

Update golden SVG:

```sh
UPDATE_GOLDEN=1 go test ./internal/render/svg/
```

## CI

[`scripts/dfd-export-ci.sh`](../scripts/dfd-export-ci.sh) runs `diagrams-go/bin/fabrica-diagrams-go`. Rebuild the linux/amd64 binary when Go sources or vendored viz.js change:

```sh
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags='-s -w' \
  -o bin/fabrica-diagrams-go ./cmd/fabrica-diagrams-go
```

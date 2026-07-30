# fabrica-diagrams-go

Single static binary that renders the Fabrica DFD threat-model bundle **without Graphviz or Python**.

## Outputs

See [CONTRACT.md](CONTRACT.md):

- `dfd_diagram.svg`
- `index.html`
- `stride_register.md`
- `threat_model.json`
- `security_requirements.yaml`

## Local

```sh
go test ./...
CGO_ENABLED=0 go build -o bin/fabrica-diagrams-go ./cmd/fabrica-diagrams-go
./bin/fabrica-diagrams-go --output-dir /tmp/dfd-out --export all --only dfd --service-name demo
```

Update golden SVG:

```sh
UPDATE_GOLDEN=1 go test ./internal/render/svg/
```

## CI

[`scripts/dfd-export-ci.sh`](../scripts/dfd-export-ci.sh) runs `diagrams-go/bin/fabrica-diagrams-go` (linux/amd64, `CGO_ENABLED=0`). Rebuild and commit the binary when Go sources change:

```sh
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags='-s -w' \
  -o bin/fabrica-diagrams-go ./cmd/fabrica-diagrams-go
```

`scripts/point-copy-mirror.sh` copies the whole `diagrams-go/` tree into the corp mirror.

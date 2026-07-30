package web

import (
	"bytes"
	"embed"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"text/template"

	"github.com/butbeautifulv/fabrica/diagrams-go/internal/model"
)

//go:embed index.html.tmpl
var tmplFS embed.FS

//go:embed static/*
var staticFS embed.FS

// IndexData is the interactive viewer template payload.
type IndexData struct {
	ServiceName  string
	DOTContent   string
	ElementCount int
	FlowCount    int
	ThreatCount  int
}

// WriteIndexHTML writes the interactive DFD viewer (expects viz.js beside it).
func WriteIndexHTML(path string, data IndexData) error {
	tmpl, err := template.ParseFS(tmplFS, "index.html.tmpl")
	if err != nil {
		return err
	}
	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, data); err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, buf.Bytes(), 0o644)
}

// CopyStatic writes vendored viz.js assets next to index.html.
func CopyStatic(outDir string) error {
	entries, err := fs.ReadDir(staticFS, "static")
	if err != nil {
		return err
	}
	if err := os.MkdirAll(outDir, 0o755); err != nil {
		return err
	}
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		raw, err := staticFS.ReadFile("static/" + name)
		if err != nil {
			return err
		}
		dest := filepath.Join(outDir, name)
		if err := os.WriteFile(dest, raw, 0o644); err != nil {
			return err
		}
	}
	// Sanity: both files must exist for offline render.
	for _, need := range []string{"viz.js", "full.render.js"} {
		if _, err := os.Stat(filepath.Join(outDir, need)); err != nil {
			return fmt.Errorf("missing static asset %s: %w", need, err)
		}
	}
	return nil
}

// NewIndexData builds template data from the canonical model + DOT.
func NewIndexData(serviceName, dot string) IndexData {
	return IndexData{
		ServiceName:  serviceName,
		DOTContent:   dot,
		ElementCount: len(model.FastAPIDFDElements),
		FlowCount:    len(model.FastAPIDFDFlows),
		ThreatCount:  len(model.IterThreats()),
	}
}

package web

import (
	"bytes"
	"embed"
	"html/template"
	"os"
	"path/filepath"
)

//go:embed index.html.tmpl
var tmplFS embed.FS

// WriteIndexHTML writes the DFD bundle navigation page.
func WriteIndexHTML(path, serviceName string) error {
	tmpl, err := template.ParseFS(tmplFS, "index.html.tmpl")
	if err != nil {
		return err
	}
	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, map[string]string{"ServiceName": serviceName}); err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, buf.Bytes(), 0o644)
}

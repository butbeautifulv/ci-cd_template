package export_test

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/butbeautifulv/fabrica/diagrams-go/internal/export"
)

func TestExporters(t *testing.T) {
	dir := t.TempDir()
	md := filepath.Join(dir, "stride_register.md")
	js := filepath.Join(dir, "threat_model.json")
	yaml := filepath.Join(dir, "security_requirements.yaml")

	if err := export.WriteStrideMD(md); err != nil {
		t.Fatal(err)
	}
	if err := export.WriteThreatDragonJSON(js); err != nil {
		t.Fatal(err)
	}
	if err := export.WriteRequirementsYAML(yaml); err != nil {
		t.Fatal(err)
	}

	mdBody, _ := os.ReadFile(md)
	if !strings.Contains(string(mdBody), "| T-S-001 |") {
		t.Fatalf("stride md missing T-S-001:\n%s", mdBody)
	}

	var payload map[string]any
	raw, _ := os.ReadFile(js)
	if err := json.Unmarshal(raw, &payload); err != nil {
		t.Fatal(err)
	}
	if payload["version"] != "2.2.0" {
		t.Fatalf("version=%v", payload["version"])
	}
	summary, _ := payload["summary"].(map[string]any)
	if summary["title"] == nil {
		t.Fatal("missing summary.title")
	}
	detail, _ := payload["detail"].(map[string]any)
	if detail["threatTop"] == nil {
		t.Fatal("missing detail.threatTop")
	}

	yBody, _ := os.ReadFile(yaml)
	if !strings.HasPrefix(string(yBody), "requirements:") {
		t.Fatalf("yaml prefix: %s", yBody[:min(40, len(yBody))])
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

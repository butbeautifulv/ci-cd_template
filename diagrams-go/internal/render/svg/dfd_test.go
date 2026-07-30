package svg_test

import (
	"encoding/xml"
	"os"
	"path/filepath"
	"strings"
	"testing"

	svgrender "github.com/butbeautifulv/fabrica/diagrams-go/internal/render/svg"
)

func TestRenderDFDWellFormed(t *testing.T) {
	out, err := svgrender.RenderDFD()
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "<svg") {
		t.Fatal("missing svg root")
	}
	if !strings.Contains(out, "Application Trust Boundary") {
		t.Fatal("missing trust boundary")
	}
	var doc struct {
		XMLName xml.Name `xml:"svg"`
	}
	if err := xml.Unmarshal([]byte(out), &doc); err != nil {
		t.Fatalf("invalid xml: %v", err)
	}
}

func TestRenderDFDGolden(t *testing.T) {
	got, err := svgrender.RenderDFD()
	if err != nil {
		t.Fatal(err)
	}
	golden := filepath.Join("..", "..", "..", "testdata", "golden", "dfd_diagram.svg")
	if os.Getenv("UPDATE_GOLDEN") == "1" {
		if err := os.MkdirAll(filepath.Dir(golden), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(golden, []byte(got), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	want, err := os.ReadFile(golden)
	if err != nil {
		t.Fatalf("read golden (run UPDATE_GOLDEN=1): %v", err)
	}
	if string(want) != got {
		t.Fatalf("svg differs from golden (%s)", golden)
	}
}

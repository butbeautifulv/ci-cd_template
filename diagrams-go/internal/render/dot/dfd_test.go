package dot_test

import (
	"strings"
	"testing"

	dotrender "github.com/butbeautifulv/fabrica/diagrams-go/internal/render/dot"
)

func TestRenderDFD(t *testing.T) {
	out, err := dotrender.RenderDFD()
	if err != nil {
		t.Fatal(err)
	}
	for _, want := range []string{
		"digraph DFD",
		"cluster_app",
		"cluster_external",
		"auth_process",
		"user -> auth_process",
		"LINDDUN",
		"Application Trust Boundary",
	} {
		if !strings.Contains(out, want) {
			t.Fatalf("DOT missing %q", want)
		}
	}
	if strings.Count(out, "user [") < 1 {
		t.Fatal("missing user node")
	}
}

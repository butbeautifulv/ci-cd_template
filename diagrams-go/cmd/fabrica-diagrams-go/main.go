package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"

	"github.com/butbeautifulv/fabrica/diagrams-go/internal/export"
	"github.com/butbeautifulv/fabrica/diagrams-go/internal/model"
	svgrender "github.com/butbeautifulv/fabrica/diagrams-go/internal/render/svg"
	"github.com/butbeautifulv/fabrica/diagrams-go/internal/web"
)

func main() {
	outputDir := flag.String("output-dir", ".", "Directory for generated files")
	only := flag.String("only", "dfd", "Diagrams to render: dfd|all")
	exportMode := flag.String("export", "all", "Exports: stride-md|threat-dragon|requirements|all")
	serviceName := flag.String("service-name", "service", "Service name for index.html")
	flag.Parse()

	if err := model.Validate(); err != nil {
		fail(err)
	}
	if err := os.MkdirAll(*outputDir, 0o755); err != nil {
		fail(err)
	}

	switch *only {
	case "dfd", "all":
		svg, err := svgrender.RenderDFD()
		if err != nil {
			fail(err)
		}
		path := filepath.Join(*outputDir, "dfd_diagram.svg")
		if err := os.WriteFile(path, []byte(svg), 0o644); err != nil {
			fail(err)
		}
		fmt.Println("wrote", path)
	default:
		fail(fmt.Errorf("unsupported --only %q (mvp supports dfd|all)", *only))
	}

	switch *exportMode {
	case "stride-md":
		must(export.WriteStrideMD(filepath.Join(*outputDir, "stride_register.md")))
	case "threat-dragon":
		must(export.WriteThreatDragonJSON(filepath.Join(*outputDir, "threat_model.json")))
	case "requirements":
		must(export.WriteRequirementsYAML(filepath.Join(*outputDir, "security_requirements.yaml")))
	case "all":
		must(export.WriteStrideMD(filepath.Join(*outputDir, "stride_register.md")))
		must(export.WriteThreatDragonJSON(filepath.Join(*outputDir, "threat_model.json")))
		must(export.WriteRequirementsYAML(filepath.Join(*outputDir, "security_requirements.yaml")))
	default:
		fail(fmt.Errorf("unsupported --export %q", *exportMode))
	}

	indexPath := filepath.Join(*outputDir, "index.html")
	must(web.WriteIndexHTML(indexPath, *serviceName))
	fmt.Println("wrote", indexPath)
}

func must(err error) {
	if err != nil {
		fail(err)
	}
}

func fail(err error) {
	fmt.Fprintf(os.Stderr, "fabrica-diagrams-go: %v\n", err)
	os.Exit(1)
}

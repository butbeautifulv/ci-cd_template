package dot

import (
	"fmt"
	"strings"

	"github.com/butbeautifulv/fabrica/diagrams-go/internal/model"
)

// RenderDFD builds Graphviz DOT for the canonical Fabrica DFD (viz.js / Graphviz).
func RenderDFD() (string, error) {
	if err := model.Validate(); err != nil {
		return "", err
	}

	var user model.Element
	var appNodes, extNodes []model.Element
	for _, e := range model.FastAPIDFDElements {
		switch {
		case e.ID == "user":
			user = e
		case e.Cluster == "app":
			appNodes = append(appNodes, e)
		case e.Cluster == "external" && e.ID != "user":
			extNodes = append(extNodes, e)
		}
	}

	var appBody []string
	for _, e := range appNodes {
		appBody = append(appBody, nodeLine(e))
	}
	var extBody []string
	for _, e := range extNodes {
		extBody = append(extBody, nodeLine(e))
	}

	var sameApp []string
	for _, e := range appNodes {
		if e.ID != "config_store" {
			sameApp = append(sameApp, e.ID)
		}
	}
	var sameExt []string
	for _, e := range extNodes {
		sameExt = append(sameExt, e.ID)
	}

	var flows []string
	for _, f := range model.FastAPIDFDFlows {
		label := f.Label
		if f.Linddun != "" && f.ID == "flow_user_auth" {
			label = f.Label + "\nLINDDUN: " + f.Linddun
		}
		attrs := []string{fmt.Sprintf(`label="%s"`, escapeDOTLabel(label))}
		if f.CrossBoundary && f.BoundaryFrom != "" && f.BoundaryTo != "" {
			attrs = append(attrs, fmt.Sprintf(`ltail="%s"`, f.BoundaryFrom))
			attrs = append(attrs, fmt.Sprintf(`lhead="%s"`, f.BoundaryTo))
		}
		flows = append(flows, fmt.Sprintf("  %s -> %s [%s];", f.Source, f.Target, strings.Join(attrs, ", ")))
	}

	var b strings.Builder
	b.WriteString(`digraph DFD {
  graph [
    rankdir="LR",
    fontname="DejaVu Sans",
    fontnames="svg",
    nodesep="0.55",
    ranksep="0.95",
    splines="polyline",
    concentrate="false",
    compound="true",
    pack="true",
    packmode="node",
    labelloc="t",
    fontsize="14",
    label="Data Flow Diagram (DFD v3)\nTrust boundaries, typed data flows — FastAPI"
  ];
  node [fontname="DejaVu Sans", fontsize="12", margin="0.08,0.06"];
  edge [
    fontname="DejaVu Sans",
    fontsize="11",
    style="solid",
    penwidth="0.9",
    arrowhead="normal",
    arrowsize="0.9"
  ];

  `)
	b.WriteString(nodeLine(user))
	b.WriteString(";\n\n")
	b.WriteString("  subgraph cluster_app {\n")
	b.WriteString("    label=\"Application Trust Boundary\";\n")
	b.WriteString("    style=\"dashed\";\n")
	b.WriteString("    color=\"gray50\";\n")
	b.WriteString("    margin=\"12\";\n\n")
	b.WriteString("    ")
	b.WriteString(strings.Join(appBody, "\n    "))
	b.WriteString("\n\n")
	b.WriteString("    { rank=same; ")
	b.WriteString(strings.Join(sameApp, "; "))
	b.WriteString(" }\n")
	b.WriteString("  }\n\n")
	b.WriteString("  subgraph cluster_external {\n")
	b.WriteString("    label=\"External Services\";\n")
	b.WriteString("    style=\"dashed\";\n")
	b.WriteString("    color=\"gray50\";\n")
	b.WriteString("    margin=\"12\";\n\n")
	b.WriteString("    ")
	b.WriteString(strings.Join(extBody, "\n    "))
	b.WriteString("\n\n")
	b.WriteString("    { rank=same; ")
	b.WriteString(strings.Join(sameExt, "; "))
	b.WriteString(" }\n")
	b.WriteString("  }\n\n")
	b.WriteString(strings.Join(flows, "\n"))
	b.WriteString("\n\n")
	b.WriteString(`  Legend [shape=note, fontsize="11",
    label="Нотация:\n- STRIDE on nodes\n- LINDDUN on PII flow\n- Misuse: weak OAuth, credential stuffing\n- Abuse: token replay, SSRF via outbound API"];
}
`)
	return b.String(), nil
}

func nodeLine(e model.Element) string {
	shape := e.GraphShape
	if shape == "" {
		shape = "ellipse"
	}
	return fmt.Sprintf(`%s [label="%s", shape=%s]`, e.ID, escapeDOTLabel(e.Label()), shape)
}

func escapeDOTLabel(s string) string {
	s = strings.ReplaceAll(s, `\`, `\\`)
	s = strings.ReplaceAll(s, `"`, `\"`)
	s = strings.ReplaceAll(s, "\n", `\n`)
	return s
}

func escapeDOT(s string) string {
	return escapeDOTLabel(s)
}

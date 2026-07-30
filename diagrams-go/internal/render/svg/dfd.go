package svg

import (
	"bytes"
	"fmt"
	"html"
	"strings"

	"github.com/butbeautifulv/fabrica/diagrams-go/internal/model"
)

type box struct {
	ID    string
	X, Y  float64
	W, H  float64
	Shape string
	Label string
}

type point struct{ X, Y float64 }

// RenderDFD builds a deterministic DFD SVG without Graphviz.
func RenderDFD() (string, error) {
	if err := model.Validate(); err != nil {
		return "", err
	}

	const (
		nodeW = 180.0
		nodeH = 64.0
		gapY  = 28.0
		pad   = 24.0
	)

	byID := model.ElementByID()
	boxes := map[string]box{}

	// Column layout: user | app trust boundary | external services
	user := byID["user"]
	boxes["user"] = box{ID: "user", X: 40, Y: 200, W: nodeW, H: nodeH, Shape: user.GraphShape, Label: user.Label()}

	appIDs := []string{"auth_process", "data_processing", "file_handler", "config_store"}
	appX := 300.0
	appInnerY := 70.0
	for i, id := range appIDs {
		e := byID[id]
		boxes[id] = box{
			ID: id, X: appX, Y: appInnerY + float64(i)*(nodeH+gapY),
			W: nodeW, H: nodeH, Shape: e.GraphShape, Label: e.Label(),
		}
	}
	appTop := appInnerY - pad
	appBottom := boxes["config_store"].Y + nodeH + pad
	appLeft := appX - pad
	appRight := appX + nodeW + pad
	appW := appRight - appLeft
	appH := appBottom - appTop

	extIDs := []string{"external_api", "file_storage"}
	extX := 620.0
	extInnerY := 120.0
	for i, id := range extIDs {
		e := byID[id]
		boxes[id] = box{
			ID: id, X: extX, Y: extInnerY + float64(i)*(nodeH+gapY*2),
			W: nodeW, H: nodeH, Shape: e.GraphShape, Label: e.Label(),
		}
	}
	extTop := extInnerY - pad
	extBottom := boxes["file_storage"].Y + nodeH + pad
	extLeft := extX - pad
	extRight := extX + nodeW + pad
	extW := extRight - extLeft
	extH := extBottom - extTop

	legendX := 40.0
	legendY := 420.0
	width := extRight + 40
	height := legendY + 110

	var b bytes.Buffer
	fmt.Fprintf(&b, `<?xml version="1.0" encoding="UTF-8"?>`+"\n")
	fmt.Fprintf(&b, `<svg xmlns="http://www.w3.org/2000/svg" width="%.0f" height="%.0f" viewBox="0 0 %.0f %.0f">`+"\n",
		width, height, width, height)
	b.WriteString(`  <style>
    .title { font-family: DejaVu Sans, Arial, sans-serif; font-size: 14px; font-weight: 600; }
    .label { font-family: DejaVu Sans, Arial, sans-serif; font-size: 11px; }
    .edge { font-family: DejaVu Sans, Arial, sans-serif; font-size: 10px; fill: #333; }
    .boundary { fill: none; stroke: #6b7280; stroke-width: 1.5; stroke-dasharray: 6 4; }
    .boundary-label { font-family: DejaVu Sans, Arial, sans-serif; font-size: 11px; fill: #4b5563; }
    .node-rect { fill: #f8fafc; stroke: #111827; stroke-width: 1.2; }
    .node-ellipse { fill: #eff6ff; stroke: #1d4ed8; stroke-width: 1.2; }
    .node-cyl { fill: #fefce8; stroke: #a16207; stroke-width: 1.2; }
    .arrow { stroke: #111827; stroke-width: 1.1; fill: none; marker-end: url(#arrowhead); }
    .note { fill: #fffbeb; stroke: #d97706; stroke-width: 1; }
  </style>
`)
	b.WriteString(`  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#111827"/>
    </marker>
  </defs>
`)
	fmt.Fprintf(&b, `  <text class="title" x="%.0f" y="28">Data Flow Diagram (DFD v3)</text>`+"\n", width/2-120)
	fmt.Fprintf(&b, `  <text class="boundary-label" x="%.0f" y="46">Trust boundaries, typed data flows — FastAPI</text>`+"\n", width/2-130)

	// Trust boundaries
	fmt.Fprintf(&b, `  <rect class="boundary" x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="8"/>`+"\n",
		appLeft, appTop, appW, appH)
	fmt.Fprintf(&b, `  <text class="boundary-label" x="%.1f" y="%.1f">Application Trust Boundary</text>`+"\n",
		appLeft+8, appTop+14)
	fmt.Fprintf(&b, `  <rect class="boundary" x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="8"/>`+"\n",
		extLeft, extTop, extW, extH)
	fmt.Fprintf(&b, `  <text class="boundary-label" x="%.1f" y="%.1f">External Services</text>`+"\n",
		extLeft+8, extTop+14)

	drawOrder := []string{"user", "auth_process", "data_processing", "file_handler", "config_store", "external_api", "file_storage"}
	for _, id := range drawOrder {
		writeNode(&b, boxes[id])
	}

	for _, flow := range model.FastAPIDFDFlows {
		src := boxes[flow.Source]
		dst := boxes[flow.Target]
		p1 := anchor(src, dst)
		p2 := anchor(dst, src)
		label := flow.Label
		if flow.Linddun != "" && flow.ID == "flow_user_auth" {
			label = flow.Label + "\nLINDDUN: " + flow.Linddun
		}
		fmt.Fprintf(&b, `  <path class="arrow" d="M %.1f %.1f L %.1f %.1f"/>`+"\n", p1.X, p1.Y, p2.X, p2.Y)
		mx := (p1.X + p2.X) / 2
		my := (p1.Y + p2.Y) / 2
		writeMultiline(&b, "edge", mx, my-4, label, "middle")
	}

	// Legend note
	fmt.Fprintf(&b, `  <rect class="note" x="%.1f" y="%.1f" width="360" height="90" rx="4"/>`+"\n", legendX, legendY)
	writeMultiline(&b, "label", legendX+10, legendY+18,
		"Нотация:\n- STRIDE on nodes\n- LINDDUN on PII flow\n- Misuse: weak OAuth, credential stuffing\n- Abuse: token replay, SSRF via outbound API",
		"start")

	b.WriteString("</svg>\n")
	return b.String(), nil
}

func writeNode(b *bytes.Buffer, n box) {
	cx := n.X + n.W/2
	cy := n.Y + n.H/2
	switch n.Shape {
	case "cylinder":
		fmt.Fprintf(b, `  <ellipse class="node-cyl" cx="%.1f" cy="%.1f" rx="%.1f" ry="10"/>`+"\n", cx, n.Y+10, n.W/2-4)
		fmt.Fprintf(b, `  <rect class="node-cyl" x="%.1f" y="%.1f" width="%.1f" height="%.1f"/>`+"\n", n.X+4, n.Y+10, n.W-8, n.H-20)
		fmt.Fprintf(b, `  <ellipse class="node-cyl" cx="%.1f" cy="%.1f" rx="%.1f" ry="10"/>`+"\n", cx, n.Y+n.H-10, n.W/2-4)
	case "ellipse":
		fmt.Fprintf(b, `  <ellipse class="node-ellipse" cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f"/>`+"\n", cx, cy, n.W/2, n.H/2)
	default:
		fmt.Fprintf(b, `  <rect class="node-rect" x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="4"/>`+"\n", n.X, n.Y, n.W, n.H)
	}
	writeMultiline(b, "label", cx, n.Y+18, n.Label, "middle")
}

func writeMultiline(b *bytes.Buffer, class string, x, y float64, text, anchor string) {
	lines := strings.Split(text, "\n")
	for i, line := range lines {
		esc := html.EscapeString(line)
		dy := y + float64(i)*13
		fmt.Fprintf(b, `  <text class="%s" x="%.1f" y="%.1f" text-anchor="%s">%s</text>`+"\n", class, x, dy, anchor, esc)
	}
}

func anchor(from, to box) point {
	fx := from.X + from.W/2
	fy := from.Y + from.H/2
	tx := to.X + to.W/2
	ty := to.Y + to.H/2
	dx := tx - fx
	dy := ty - fy
	if abs(dx) >= abs(dy) {
		if dx >= 0 {
			return point{from.X + from.W, fy}
		}
		return point{from.X, fy}
	}
	if dy >= 0 {
		return point{fx, from.Y + from.H}
	}
	return point{fx, from.Y}
}

func abs(v float64) float64 {
	if v < 0 {
		return -v
	}
	return v
}

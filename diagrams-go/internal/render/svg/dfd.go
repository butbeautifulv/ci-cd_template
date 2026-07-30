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

// RenderDFD builds a readable static SVG fallback (interactive HTML is primary).
func RenderDFD() (string, error) {
	if err := model.Validate(); err != nil {
		return "", err
	}

	const (
		nodeW = 220.0
		nodeH = 78.0
		gapY  = 36.0
		pad   = 28.0
	)

	byID := model.ElementByID()
	boxes := map[string]box{}

	user := byID["user"]
	boxes["user"] = box{ID: "user", X: 48, Y: 220, W: nodeW, H: nodeH, Shape: user.GraphShape, Label: user.Label()}

	appIDs := []string{"auth_process", "data_processing", "file_handler", "config_store"}
	appX := 360.0
	appInnerY := 88.0
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

	extIDs := []string{"external_api", "file_storage"}
	extX := 720.0
	extInnerY := 150.0
	for i, id := range extIDs {
		e := byID[id]
		boxes[id] = box{
			ID: id, X: extX, Y: extInnerY + float64(i)*(nodeH+gapY*2.2),
			W: nodeW, H: nodeH, Shape: e.GraphShape, Label: e.Label(),
		}
	}
	extTop := extInnerY - pad
	extBottom := boxes["file_storage"].Y + nodeH + pad
	extLeft := extX - pad
	extRight := extX + nodeW + pad

	legendX := 48.0
	legendY := 520.0
	width := extRight + 48
	height := legendY + 120

	var b bytes.Buffer
	fmt.Fprintf(&b, `<?xml version="1.0" encoding="UTF-8"?>`+"\n")
	fmt.Fprintf(&b, `<svg xmlns="http://www.w3.org/2000/svg" width="%.0f" height="%.0f" viewBox="0 0 %.0f %.0f">`+"\n",
		width, height, width, height)
	b.WriteString(`  <style>
    .title { font-family: DejaVu Sans, Arial, sans-serif; font-size: 16px; font-weight: 600; fill: #0f172a; }
    .subtitle { font-family: DejaVu Sans, Arial, sans-serif; font-size: 12px; fill: #475569; }
    .label { font-family: DejaVu Sans, Arial, sans-serif; font-size: 12px; fill: #0f172a; }
    .edge { font-family: DejaVu Sans, Arial, sans-serif; font-size: 11px; fill: #1e293b; }
    .edge-bg { fill: #ffffff; fill-opacity: 0.92; stroke: #e2e8f0; stroke-width: 1; }
    .boundary { fill: #f8fafc; stroke: #64748b; stroke-width: 1.8; stroke-dasharray: 7 5; }
    .boundary-label { font-family: DejaVu Sans, Arial, sans-serif; font-size: 12px; fill: #334155; font-weight: 600; }
    .node-rect { fill: #E3F2FD; stroke: #1565C0; stroke-width: 1.4; }
    .node-ellipse { fill: #E8F5E8; stroke: #2E7D32; stroke-width: 1.4; }
    .node-cyl { fill: #EFEBE9; stroke: #5D4037; stroke-width: 1.4; }
    .arrow { stroke: #334155; stroke-width: 1.35; fill: none; marker-end: url(#arrowhead); }
    .note { fill: #fffbeb; stroke: #d97706; stroke-width: 1; }
  </style>
`)
	b.WriteString(`  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#334155"/>
    </marker>
  </defs>
`)
	fmt.Fprintf(&b, `  <text class="title" x="%.0f" y="32">Data Flow Diagram (DFD v3)</text>`+"\n", width/2-140)
	fmt.Fprintf(&b, `  <text class="subtitle" x="%.0f" y="52">Trust boundaries, typed data flows — FastAPI · open index.html for interactive view</text>`+"\n", width/2-220)

	fmt.Fprintf(&b, `  <rect class="boundary" x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="10"/>`+"\n",
		appLeft, appTop, appRight-appLeft, appBottom-appTop)
	fmt.Fprintf(&b, `  <text class="boundary-label" x="%.1f" y="%.1f">Application Trust Boundary</text>`+"\n",
		appLeft+10, appTop+18)
	fmt.Fprintf(&b, `  <rect class="boundary" x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="10"/>`+"\n",
		extLeft, extTop, extRight-extLeft, extBottom-extTop)
	fmt.Fprintf(&b, `  <text class="boundary-label" x="%.1f" y="%.1f">External Services</text>`+"\n",
		extLeft+10, extTop+18)

	drawOrder := []string{"user", "auth_process", "data_processing", "file_handler", "config_store", "external_api", "file_storage"}
	for _, id := range drawOrder {
		writeNode(&b, boxes[id])
	}

	// Stagger edge label offsets to reduce collisions.
	labelNudge := map[string]float64{
		"flow_user_auth":   -18,
		"flow_config_auth": 22,
		"flow_auth_data":   -12,
		"flow_data_file":   14,
		"flow_file_s3":     -16,
		"flow_data_api_out": 18,
		"flow_api_data_in": -20,
	}

	for _, flow := range model.FastAPIDFDFlows {
		src := boxes[flow.Source]
		dst := boxes[flow.Target]
		p1 := anchor(src, dst)
		p2 := anchor(dst, src)
		// Slight elbow for readability when mostly horizontal.
		midX := (p1.X + p2.X) / 2
		midY := (p1.Y+p2.Y)/2 + labelNudge[flow.ID]
		fmt.Fprintf(&b, `  <path class="arrow" d="M %.1f %.1f Q %.1f %.1f %.1f %.1f"/>`+"\n",
			p1.X, p1.Y, midX, midY, p2.X, p2.Y)
		label := flow.Label
		if flow.Linddun != "" && flow.ID == "flow_user_auth" {
			label = flow.Label + "\nLINDDUN: " + flow.Linddun
		}
		writeEdgeLabel(&b, midX, midY-6, label)
	}

	fmt.Fprintf(&b, `  <rect class="note" x="%.1f" y="%.1f" width="420" height="100" rx="6"/>`+"\n", legendX, legendY)
	writeMultiline(&b, "label", legendX+12, legendY+22,
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
		fmt.Fprintf(b, `  <ellipse class="node-cyl" cx="%.1f" cy="%.1f" rx="%.1f" ry="11"/>`+"\n", cx, n.Y+11, n.W/2-6)
		fmt.Fprintf(b, `  <rect class="node-cyl" x="%.1f" y="%.1f" width="%.1f" height="%.1f"/>`+"\n", n.X+6, n.Y+11, n.W-12, n.H-22)
		fmt.Fprintf(b, `  <ellipse class="node-cyl" cx="%.1f" cy="%.1f" rx="%.1f" ry="11"/>`+"\n", cx, n.Y+n.H-11, n.W/2-6)
	case "ellipse":
		fmt.Fprintf(b, `  <ellipse class="node-ellipse" cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f"/>`+"\n", cx, cy, n.W/2, n.H/2)
	default:
		fmt.Fprintf(b, `  <rect class="node-rect" x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="6"/>`+"\n", n.X, n.Y, n.W, n.H)
	}
	writeMultiline(b, "label", cx, n.Y+24, n.Label, "middle")
}

func writeEdgeLabel(b *bytes.Buffer, x, y float64, text string) {
	lines := strings.Split(text, "\n")
	maxLen := 0
	for _, line := range lines {
		if len(line) > maxLen {
			maxLen = len(line)
		}
	}
	w := float64(maxLen)*6.2 + 16
	h := float64(len(lines))*14 + 10
	fmt.Fprintf(b, `  <rect class="edge-bg" x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="4"/>`+"\n",
		x-w/2, y-12, w, h)
	writeMultiline(b, "edge", x, y, text, "middle")
}

func writeMultiline(b *bytes.Buffer, class string, x, y float64, text, anchor string) {
	lines := strings.Split(text, "\n")
	for i, line := range lines {
		esc := html.EscapeString(line)
		dy := y + float64(i)*14
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

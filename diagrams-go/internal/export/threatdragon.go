package export

import (
	"crypto/sha1"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/butbeautifulv/fabrica/diagrams-go/internal/model"
)

var typeMap = map[model.ElementType]string{
	model.Process:        "tm.Process",
	model.DataStore:      "tm.Store",
	model.DataFlow:       "tm.Flow",
	model.ExternalEntity: "tm.Actor",
	model.TrustBoundary:  "tm.Boundary",
}

// deterministicUUID derives a stable UUID v5-like string from element id.
func deterministicUUID(id string) string {
	sum := sha1.Sum([]byte("fabrica-dfd:" + id))
	// Set UUID version/variant bits for a v5-like value.
	sum[6] = (sum[6] & 0x0f) | 0x50
	sum[8] = (sum[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", sum[0:4], sum[4:6], sum[6:8], sum[8:10], sum[10:16])
}

// WriteThreatDragonJSON writes Threat Dragon 2.x JSON.
func WriteThreatDragonJSON(path string) error {
	type threat struct {
		ID          string `json:"id"`
		Title       string `json:"title"`
		Type        string `json:"type"`
		Status      string `json:"status"`
		Severity    string `json:"severity"`
		Description string `json:"description"`
		Mitigation  string `json:"mitigation"`
		ModelType   string `json:"modelType"`
	}
	type cell struct {
		Type           string         `json:"type"`
		ID             string         `json:"id"`
		Name           string         `json:"name"`
		Description    string         `json:"description"`
		Position       map[string]int `json:"position"`
		Size           map[string]int `json:"size"`
		Threats        []threat       `json:"threats"`
		HasOpenThreats bool           `json:"hasOpenThreats"`
	}

	xPositions := map[string]int{"app": 200, "external": 500}
	cells := make([]cell, 0, len(model.FastAPIDFDElements))
	threatCounter := 0
	y := 80
	for _, element := range model.FastAPIDFDElements {
		c := cell{
			Type:        typeMap[element.ElementType],
			ID:          deterministicUUID(element.ID),
			Name:        element.Name,
			Description: element.Description,
			Position:    map[string]int{"x": xPositions[element.Cluster], "y": y},
			Size:        map[string]int{"width": 120, "height": 60},
			Threats:     []threat{},
		}
		if c.Position["x"] == 0 {
			c.Position["x"] = 200
		}
		y += 90
		for _, category := range model.StrideByElement[element.ElementType] {
			threatCounter++
			mits := model.StrideMitigations[category]
			if len(mits) == 0 {
				mits = []string{"Review required"}
			}
			c.Threats = append(c.Threats, threat{
				ID:          fmt.Sprintf("%d", threatCounter),
				Title:       category + " - " + element.Name,
				Type:        category,
				Status:      "Open",
				Severity:    "Medium",
				Description: fmt.Sprintf("Potential %s threat against %s", strings.ToLower(category), element.Name),
				Mitigation:  strings.Join(mits, "; "),
				ModelType:   "STRIDE",
			})
			c.HasOpenThreats = true
		}
		cells = append(cells, c)
	}

	payload := map[string]any{
		"version": "2.2.0",
		"summary": map[string]any{
			"title":       model.ThreatModelTitle,
			"owner":       "Security Team",
			"description": model.ThreatModelDescription,
			"id":          0,
		},
		"detail": map[string]any{
			"contributors": []any{},
			"diagrams": []map[string]any{
				{
					"id":          0,
					"title":       "FastAPI DFD",
					"diagramType": "STRIDE",
					"placeholder": "New STRIDE diagram",
					"thumbnail":   "",
					"version":     "2.2.0",
					"cells":       cells,
				},
			},
			"diagramTop": 0,
			"reviewer":   "",
			"threatTop":  threatCounter,
		},
	}
	raw, err := json.MarshalIndent(payload, "", "  ")
	if err != nil {
		return err
	}
	return writeFile(path, string(raw)+"\n")
}

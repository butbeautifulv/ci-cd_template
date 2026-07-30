package model

import "fmt"

func errf(format string, args ...any) error {
	return fmt.Errorf(format, args...)
}

// STRIDE categories by element type (from Python stride_constants).
var StrideByElement = map[ElementType][]string{
	Process: {
		"Spoofing", "Tampering", "Repudiation",
		"Information Disclosure", "Denial of Service", "Elevation of Privilege",
	},
	DataStore: {
		"Tampering", "Information Disclosure", "Denial of Service",
	},
	DataFlow: {
		"Tampering", "Information Disclosure", "Denial of Service",
	},
	ExternalEntity: {
		"Spoofing", "Repudiation",
	},
}

// StrideMitigations maps STRIDE category to mitigation bullets.
var StrideMitigations = map[string][]string{
	"Spoofing": {
		"Implement strong authentication (MFA)",
		"Use mutual TLS for service-to-service",
	},
	"Tampering": {
		"Use integrity checks (HMAC, digital signatures)",
		"Implement input validation",
	},
	"Repudiation": {
		"Enable comprehensive audit logging",
		"Use tamper-evident log storage",
	},
	"Information Disclosure": {
		"Encrypt data at rest and in transit",
		"Implement least-privilege access",
	},
	"Denial of Service": {
		"Implement rate limiting",
		"Use auto-scaling and circuit breakers",
	},
	"Elevation of Privilege": {
		"Enforce RBAC and least privilege",
		"Validate authorization on every request",
	},
}

// StrideAbbrev maps category to letter.
var StrideAbbrev = map[string]string{
	"Spoofing":               "S",
	"Tampering":              "T",
	"Repudiation":            "R",
	"Information Disclosure": "I",
	"Denial of Service":      "D",
	"Elevation of Privilege": "E",
}

// DefaultRiskLevel is the workshop stub risk.
const DefaultRiskLevel = "Medium"

// ThreatRow is one STRIDE register line.
type ThreatRow struct {
	ID             string
	Element        string
	Stride         string
	Description    string
	Risk           string
	Mitigation     string
	FabricaControl string
	Status         string
}

// IterThreats builds the STRIDE register rows (stable order).
func IterThreats() []ThreatRow {
	rows := make([]ThreatRow, 0, 32)
	counter := 0
	for _, element := range FastAPIDFDElements {
		for _, category := range StrideByElement[element.ElementType] {
			counter++
			abbrev := StrideAbbrev[category]
			if abbrev == "" {
				abbrev = string(category[0])
			}
			mits := StrideMitigations[category]
			if len(mits) == 0 {
				mits = []string{"Review required"}
			}
			ctrl := joinComma(element.FabricaControls)
			if ctrl == "" {
				ctrl = "—"
			}
			rows = append(rows, ThreatRow{
				ID:             fmt.Sprintf("T-%s-%03d", abbrev, counter),
				Element:        element.Name,
				Stride:         category,
				Description:    fmt.Sprintf("Potential %s against %s", lowerFirst(category), element.Name),
				Risk:           DefaultRiskLevel,
				Mitigation:     joinSemi(mits),
				FabricaControl: ctrl,
				Status:         "Open",
			})
		}
	}
	return rows
}

func joinComma(parts []string) string {
	if len(parts) == 0 {
		return ""
	}
	out := parts[0]
	for i := 1; i < len(parts); i++ {
		out += ", " + parts[i]
	}
	return out
}

func joinSemi(parts []string) string {
	if len(parts) == 0 {
		return ""
	}
	out := parts[0]
	for i := 1; i < len(parts); i++ {
		out += "; " + parts[i]
	}
	return out
}

func lowerFirst(s string) string {
	if s == "" {
		return s
	}
	b := []byte(s)
	if b[0] >= 'A' && b[0] <= 'Z' {
		b[0] += 'a' - 'A'
	}
	return string(b)
}

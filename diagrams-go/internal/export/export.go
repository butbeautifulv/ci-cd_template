package export

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/butbeautifulv/fabrica/diagrams-go/internal/model"
)

// WriteStrideMD writes stride_register.md.
func WriteStrideMD(path string) error {
	rows := model.IterThreats()
	var b strings.Builder
	b.WriteString("# STRIDE Threat Register — " + model.ThreatModelTitle + "\n\n")
	b.WriteString("| ID | Element | STRIDE | Description | Risk | Mitigation | Fabrica | Status |\n")
	b.WriteString("|----|---------|--------|-------------|------|------------|---------|--------|\n")
	for _, row := range rows {
		fmt.Fprintf(&b, "| %s | %s | %s | %s | %s | %s | %s | %s |\n",
			row.ID, row.Element, row.Stride, row.Description, row.Risk, row.Mitigation, row.FabricaControl, row.Status)
	}
	b.WriteString("\n_Risk stub: Impact × Likelihood (1–4); default Medium for workshop._\n")
	return writeFile(path, b.String())
}

// WriteRequirementsYAML writes security_requirements.yaml (no yaml dependency).
func WriteRequirementsYAML(path string) error {
	domainByStride := map[string]string{
		"Spoofing":               "authentication",
		"Tampering":              "input_validation",
		"Repudiation":            "audit_logging",
		"Information Disclosure": "data_protection",
		"Denial of Service":      "availability",
		"Elevation of Privilege": "authorization",
	}
	requirementText := map[string]string{
		"Spoofing":               "Validate identity tokens and reject missing or expired credentials",
		"Tampering":              "Validate and sanitize all inputs; use parameterized queries",
		"Repudiation":            "Log security-relevant actions with tamper-evident storage",
		"Information Disclosure": "Encrypt sensitive data; enforce least-privilege access",
		"Denial of Service":      "Apply rate limiting and resource quotas on public endpoints",
		"Elevation of Privilege": "Enforce authorization on every protected route and resource",
	}
	testability := map[string]string{
		"authentication":   "sec-func-tests: expired token → 401",
		"input_validation": "SAST/DAST: injection payloads blocked",
		"audit_logging":    "Verify audit events for auth and admin actions",
		"data_protection":  "B1 secret-scan; no secrets in logs or /docs",
		"availability":     "Load test within SLO; rate limit returns 429",
		"authorization":    "sec-func-tests: forbidden role → 403",
	}

	var b strings.Builder
	b.WriteString("requirements:\n")
	for idx, threat := range model.IterThreats() {
		domain := domainByStride[threat.Stride]
		if domain == "" {
			domain = "general"
		}
		req := requirementText[threat.Stride]
		if req == "" {
			req = "Review and document security control"
		}
		test := testability[domain]
		if test == "" {
			test = "Manual design review"
		}
		controls := "—"
		if threat.FabricaControl != "" && threat.FabricaControl != "—" {
			controls = threat.FabricaControl
		}
		fmt.Fprintf(&b, "  - id: SR-%03d\n", idx+1)
		fmt.Fprintf(&b, "    threat_ref: %s\n", threat.ID)
		fmt.Fprintf(&b, "    domain: %s\n", domain)
		fmt.Fprintf(&b, "    requirement: %q\n", req)
		fmt.Fprintf(&b, "    fabrica_control: [%s]\n", controls)
		fmt.Fprintf(&b, "    testability: %q\n", test)
	}
	return writeFile(path, b.String())
}

func writeFile(path, content string) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, []byte(content), 0o644)
}

package model

// ElementType matches Python diagrams.model.ElementType.
type ElementType string

const (
	ExternalEntity ElementType = "external_entity"
	Process        ElementType = "process"
	DataStore      ElementType = "data_store"
	DataFlow       ElementType = "data_flow"
	TrustBoundary  ElementType = "trust_boundary"
)

// DataClass matches Python diagrams.model.DataClass.
type DataClass string

const (
	PII    DataClass = "PII"
	Secret DataClass = "secret"
	Public DataClass = "public"
	Token  DataClass = "token"
)

// Element is a DFD node.
type Element struct {
	ID             string
	Name           string
	ElementType    ElementType
	StrideShort    string
	Description    string
	FabricaControls []string
	GraphLabel     string
	GraphShape     string
	Cluster        string
}

// Label returns the display label with STRIDE annotation.
func (e Element) Label() string {
	base := e.GraphLabel
	if base == "" {
		base = e.Name
	}
	return base + "\nSTRIDE: " + e.StrideShort
}

// Flow is a typed data flow between elements.
type Flow struct {
	ID              string
	Source          string
	Target          string
	Label           string
	DataClass       DataClass
	FabricaControls []string
	Linddun         string
	CrossBoundary   bool
	BoundaryFrom    string
	BoundaryTo      string
}

const (
	ThreatModelTitle       = "Fabrica FastAPI Application"
	ThreatModelDescription = "Reference threat model for DevSecOps course — FastAPI, OAuth2/JWT, PostgreSQL, S3"
)

// FastAPIDFDElements is the canonical node set.
var FastAPIDFDElements = []Element{
	{
		ID: "user", Name: "Пользователь", ElementType: ExternalEntity,
		StrideShort: "S, R", Description: "External user interacting with the API",
		FabricaControls: []string{"B1", "D2"}, GraphLabel: "Пользователь",
		GraphShape: "rectangle", Cluster: "external",
	},
	{
		ID: "auth_process", Name: "FastAPI / OAuth2 / JWT", ElementType: Process,
		StrideShort: "S, T, R, I, D, E", Description: "Authentication and token issuance",
		FabricaControls: []string{"B2", "D2"}, GraphLabel: "FastAPI / OAuth2 / JWT\n(аутентификация)",
		GraphShape: "ellipse", Cluster: "app",
	},
	{
		ID: "data_processing", Name: "Pydantic validation + business logic", ElementType: Process,
		StrideShort: "S, T, R, I, D, E", Description: "Input validation and business rules",
		FabricaControls: []string{"B2", "D1", "D2"}, GraphLabel: "Pydantic validation\n+ business logic",
		GraphShape: "ellipse", Cluster: "app",
	},
	{
		ID: "file_handler", Name: "Работа с файлами", ElementType: Process,
		StrideShort: "S, T, R, I, D, E", Description: "File upload and object storage handling",
		FabricaControls: []string{"B2", "B4"}, GraphLabel: "Работа с файлами",
		GraphShape: "ellipse", Cluster: "app",
	},
	{
		ID: "config_store", Name: "Конфигурация", ElementType: DataStore,
		StrideShort: "T, I, D", Description: "pydantic-settings and environment configuration",
		FabricaControls: []string{"B1", "B5"}, GraphLabel: "Конфигурация\n(pydantic-settings)",
		GraphShape: "cylinder", Cluster: "app",
	},
	{
		ID: "external_api", Name: "Внешнее API", ElementType: ExternalEntity,
		StrideShort: "S, R", Description: "Third-party REST API",
		FabricaControls: []string{"B2", "D1"}, GraphLabel: "Внешнее API",
		GraphShape: "rectangle", Cluster: "external",
	},
	{
		ID: "file_storage", Name: "Файловое хранилище", ElementType: DataStore,
		StrideShort: "T, I, D", Description: "S3 object storage with SSE",
		FabricaControls: []string{"B4", "E2"}, GraphLabel: "Файловое хранилище\n(S3 SSE)",
		GraphShape: "cylinder", Cluster: "external",
	},
}

// FastAPIDFDFlows is the canonical edge set.
var FastAPIDFDFlows = []Flow{
	{
		ID: "flow_user_auth", Source: "user", Target: "auth_process",
		Label: "учетные данные (PII)", DataClass: PII,
		FabricaControls: []string{"B1", "D2"}, Linddun: "L, D (Linkability, Disclosure)",
	},
	{
		ID: "flow_config_auth", Source: "config_store", Target: "auth_process",
		Label: "настройки аутентификации (read-only)", DataClass: Secret,
		FabricaControls: []string{"B1"},
	},
	{
		ID: "flow_auth_data", Source: "auth_process", Target: "data_processing",
		Label: "токен (JWT/OAuth2)", DataClass: Token,
		FabricaControls: []string{"B2", "D2"},
	},
	{
		ID: "flow_data_file", Source: "data_processing", Target: "file_handler",
		Label: "данные для записи (JSON)", DataClass: Public,
		FabricaControls: []string{"B2"},
	},
	{
		ID: "flow_file_s3", Source: "file_handler", Target: "file_storage",
		Label: "S3 API / HTTPS/TLS 1.3", DataClass: Public,
		FabricaControls: []string{"B4", "E2"}, CrossBoundary: true,
		BoundaryFrom: "cluster_app", BoundaryTo: "cluster_external",
	},
	{
		ID: "flow_data_api_out", Source: "data_processing", Target: "external_api",
		Label: "API запросы; HTTPS/TLS 1.3 (JSON)", DataClass: Public,
		FabricaControls: []string{"B2", "D1"}, CrossBoundary: true,
		BoundaryFrom: "cluster_app", BoundaryTo: "cluster_external",
	},
	{
		ID: "flow_api_data_in", Source: "external_api", Target: "data_processing",
		Label: "API ответы; HTTPS/TLS 1.3 (JSON)", DataClass: Public,
		FabricaControls: []string{"B2", "D1"}, CrossBoundary: true,
		BoundaryFrom: "cluster_external", BoundaryTo: "cluster_app",
	},
}

// ElementByID indexes elements by id.
func ElementByID() map[string]Element {
	out := make(map[string]Element, len(FastAPIDFDElements))
	for _, e := range FastAPIDFDElements {
		out[e.ID] = e
	}
	return out
}

// Validate checks unique ids and flow endpoints.
func Validate() error {
	seen := make(map[string]struct{}, len(FastAPIDFDElements))
	for _, e := range FastAPIDFDElements {
		if e.ID == "" {
			return errf("empty element id")
		}
		if _, ok := seen[e.ID]; ok {
			return errf("duplicate element id %q", e.ID)
		}
		seen[e.ID] = struct{}{}
	}
	for _, f := range FastAPIDFDFlows {
		if f.ID == "" {
			return errf("empty flow id")
		}
		if _, ok := seen[f.Source]; !ok {
			return errf("flow %q: unknown source %q", f.ID, f.Source)
		}
		if _, ok := seen[f.Target]; !ok {
			return errf("flow %q: unknown target %q", f.ID, f.Target)
		}
	}
	return nil
}

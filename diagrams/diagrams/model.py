"""Canonical FastAPI DFD model — single source of truth for SVG and exports."""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum


class ElementType(str, Enum):
    EXTERNAL_ENTITY = "external_entity"
    PROCESS = "process"
    DATA_STORE = "data_store"
    DATA_FLOW = "data_flow"
    TRUST_BOUNDARY = "trust_boundary"


class DataClass(str, Enum):
    PII = "PII"
    SECRET = "secret"
    PUBLIC = "public"
    TOKEN = "token"


@dataclass(frozen=True)
class DfdElement:
    id: str
    name: str
    element_type: ElementType
    stride_short: str
    description: str
    fabrica_controls: tuple[str, ...] = ()
    graph_label: str = ""
    graph_shape: str = "ellipse"
    cluster: str = "app"

    @property
    def label(self) -> str:
        base = self.graph_label or self.name
        return f"{base}\\nSTRIDE: {self.stride_short}"


@dataclass(frozen=True)
class DfdFlow:
    id: str
    source: str
    target: str
    label: str
    data_class: DataClass
    fabrica_controls: tuple[str, ...] = ()
    linddun: str | None = None
    cross_boundary: bool = False
    boundary_from: str | None = None
    boundary_to: str | None = None


THREAT_MODEL_TITLE = "Fabrica FastAPI Application"
THREAT_MODEL_DESCRIPTION = (
    "Reference threat model for DevSecOps course — FastAPI, OAuth2/JWT, PostgreSQL, S3"
)

FASTAPI_DFD_ELEMENTS: tuple[DfdElement, ...] = (
    DfdElement(
        id="user",
        name="Пользователь",
        element_type=ElementType.EXTERNAL_ENTITY,
        stride_short="S, R",
        description="External user interacting with the API",
        fabrica_controls=("B1", "D2"),
        graph_label="Пользователь",
        graph_shape="rectangle",
        cluster="external",
    ),
    DfdElement(
        id="auth_process",
        name="FastAPI / OAuth2 / JWT",
        element_type=ElementType.PROCESS,
        stride_short="S, T, R, I, D, E",
        description="Authentication and token issuance",
        fabrica_controls=("B2", "D2"),
        graph_label="FastAPI / OAuth2 / JWT\\n(аутентификация)",
    ),
    DfdElement(
        id="data_processing",
        name="Pydantic validation + business logic",
        element_type=ElementType.PROCESS,
        stride_short="S, T, R, I, D, E",
        description="Input validation and business rules",
        fabrica_controls=("B2", "D1", "D2"),
        graph_label="Pydantic validation\\n+ business logic",
    ),
    DfdElement(
        id="file_handler",
        name="Работа с файлами",
        element_type=ElementType.PROCESS,
        stride_short="S, T, R, I, D, E",
        description="File upload and object storage handling",
        fabrica_controls=("B2", "B4"),
        graph_label="Работа с файлами",
    ),
    DfdElement(
        id="config_store",
        name="Конфигурация",
        element_type=ElementType.DATA_STORE,
        stride_short="T, I, D",
        description="pydantic-settings and environment configuration",
        fabrica_controls=("B1", "B5"),
        graph_label="Конфигурация\\n(pydantic-settings)",
        graph_shape="cylinder",
    ),
    DfdElement(
        id="external_api",
        name="Внешнее API",
        element_type=ElementType.EXTERNAL_ENTITY,
        stride_short="S, R",
        description="Third-party REST API",
        fabrica_controls=("B2", "D1"),
        graph_label="Внешнее API",
        graph_shape="rectangle",
        cluster="external",
    ),
    DfdElement(
        id="file_storage",
        name="Файловое хранилище",
        element_type=ElementType.DATA_STORE,
        stride_short="T, I, D",
        description="S3 object storage with SSE",
        fabrica_controls=("B4", "E2"),
        graph_label="Файловое хранилище\\n(S3 SSE)",
        graph_shape="cylinder",
        cluster="external",
    ),
)

FASTAPI_DFD_FLOWS: tuple[DfdFlow, ...] = (
    DfdFlow(
        id="flow_user_auth",
        source="user",
        target="auth_process",
        label="учетные данные (PII)",
        data_class=DataClass.PII,
        fabrica_controls=("B1", "D2"),
        linddun="L, D (Linkability, Disclosure)",
    ),
    DfdFlow(
        id="flow_config_auth",
        source="config_store",
        target="auth_process",
        label="настройки аутентификации (read-only)",
        data_class=DataClass.SECRET,
        fabrica_controls=("B1",),
    ),
    DfdFlow(
        id="flow_auth_data",
        source="auth_process",
        target="data_processing",
        label="токен (JWT/OAuth2)",
        data_class=DataClass.TOKEN,
        fabrica_controls=("B2", "D2"),
    ),
    DfdFlow(
        id="flow_data_file",
        source="data_processing",
        target="file_handler",
        label="данные для записи (JSON)",
        data_class=DataClass.PUBLIC,
        fabrica_controls=("B2",),
    ),
    DfdFlow(
        id="flow_file_s3",
        source="file_handler",
        target="file_storage",
        label="S3 API / HTTPS/TLS 1.3",
        data_class=DataClass.PUBLIC,
        fabrica_controls=("B4", "E2"),
        cross_boundary=True,
        boundary_from="cluster_app",
        boundary_to="cluster_external",
    ),
    DfdFlow(
        id="flow_data_api_out",
        source="data_processing",
        target="external_api",
        label="API запросы; HTTPS/TLS 1.3 (JSON)",
        data_class=DataClass.PUBLIC,
        fabrica_controls=("B2", "D1"),
        cross_boundary=True,
        boundary_from="cluster_app",
        boundary_to="cluster_external",
    ),
    DfdFlow(
        id="flow_api_data_in",
        source="external_api",
        target="data_processing",
        label="API ответы; HTTPS/TLS 1.3 (JSON)",
        data_class=DataClass.PUBLIC,
        fabrica_controls=("B2", "D1"),
        cross_boundary=True,
        boundary_from="cluster_external",
        boundary_to="cluster_app",
    ),
)

ELEMENT_BY_ID: dict[str, DfdElement] = {element.id: element for element in FASTAPI_DFD_ELEMENTS}

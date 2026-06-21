# Kubernetes runtime security

Синтез JCSF и DAF runtime-практик для целевого деплоя в K8s.

## Домены JCSF (полная карта)

| Домен | Код | Содержание | Шаблон |
|-------|-----|------------|--------|
| General | **gen** | Сегментация, L3/L4 FW, backup | `k8s/network/` |
| Nodes | **nodes** | Hardening OS, golden image | IaC / image pipeline |
| Orchestration | **orchr** | API server, admission, audit | `k8s/admission/` |
| Manifests | **man** | K8s manifests, Helm, RBAC YAML | `k8s/admission/`, IaC scan |
| Images | **img** | Image CVE, signing, registry | `jobs/container-scan.*`, C4 |
| Runtime containers | **cont** | Runtime policies, Falco, seccomp | `k8s/runtime/` |
| Docker (build) | **Dock** | Dockerfile, build host | `jobs/dockerfile-lint.*`, B5 |

Уровни JCSF: L0 Uninitiated → L4 Experts.

## CIS и нормативные маппинги (JCSF xlsx)

| Лист `JCSF v7_public.xlsx` | Применение |
|----------------------------|------------|
| `CIS Docker` | B5 Dockerfile, build workers |
| `CIS Kubernetes` | E1 admission, E2 network |
| `CIS Linux (Debian/RHEL)` | Hardening worker nodes |
| `Приказ 118` | ФСТЭК — для госсектора / регуляторики |

См. [references/framework-mappings.md](references/framework-mappings.md).

## DAF runtime (prod)

| Практика | Описание |
|----------|----------|
| `T-PROD-RUN-1-1` | Kyverno / OPA / PSA — стандартные политики |
| `T-PROD-RUN-2-1` | Кастомные cluster-wide runtime policies |
| `T-PROD-NETWORK-2-1` | Global network policies |
| `T-PROD-EVENTS-3-1` | Логи в SIEM, корреляция |
| `T-CODE-IMG-2-2` | Периодическое сканирование registry |

## Trusted registry (C3)

См. [templates/k8s/cluster/image-pull-policy.md](../templates/k8s/cluster/image-pull-policy.md).

- Pull только из internal registry / dependency proxy
- `imagePullSecrets`, digest pin где возможно
- Env `REGISTRY` в CI (`templates/gitlab/jobs/_base.yml`)

## Периодическое сканирование registry

**Документировано (C2):** cron/registry scanner вне app pipeline — ежедневный Trivy/Grype по всем тегам в internal registry. Настройка на стороне registry (Harbor, GitLab Registry, ghcr).

## Preprod vs prod

| Среда | Контроли |
|-------|----------|
| Preprod | DAST, IAST, sec tests, `T-PREPROD-VULN`, `T-PREPROD-MANSEC` |
| Prod | Admission (**orchr**), network (**gen**), Falco (**cont**), WAF, RASP, passive DAST |

## Связанные подфазы

- [phases/E1-admission.md](phases/E1-admission.md)
- [phases/E2-network.md](phases/E2-network.md)
- [phases/E3-cwpp.md](phases/E3-cwpp.md)
- [phases/C3-registry.md](phases/C3-registry.md)

## JCSF практики L1–L2 (ориентир)

- **Orch-1-1** — authn/authz kube-apiserver
- **Orch-2-13** — Policy engine / admission controller
- **Img-1-1** — регламент сканирования образов
- **Nodes-2-3** — сканирование OS на уязвимости
- **Cont-1-*** — runtime detection (Falco)
- **Dock-1-*** — безопасная сборка образов

Полный список: `JCSF v7_public.xlsx` в `.external/`.

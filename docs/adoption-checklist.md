# Чеклист адаптации DevSecOps

Пошаговое внедрение шаблона в существующий репозиторий.

## 1. Подготовка

- [ ] Оценка зрелости: [`05-maturity-roadmap.md`](05-maturity-roadmap.md)
- [ ] Выбор профиля: `minimal` | `shift-left` | `supply-chain` | `full`
- [ ] Назначен SecChamp на команду

## 2. Копирование (автоматически)

```bash
./scripts/adopt.sh --profile shift-left --platform gitlab --target /path/to/repo
# или
./scripts/adopt.sh --profile shift-left --platform github --target /path/to/repo
```

## 3. SCM (A1)

- [ ] Branch protection — [`platforms/gitlab.md`](platforms/gitlab.md) / [`platforms/github.md`](platforms/github.md)
- [ ] CODEOWNERS для security paths
- [ ] MR/PR required checks

## 4. CI настройка (A2+)

- [ ] Исправить пути `include:` / `uses:` после копирования
- [ ] `REGISTRY` / `ghcr.io` credentials
- [ ] `ENABLE_REAL_LINTERS=true` при готовности
- [ ] Pre-commit: `templates/pre-commit/.pre-commit-config.yaml`

## 5. По фазам

| Фаза | Проверка |
|------|----------|
| B1 | Secret scan artifact, gate-check |
| B2 | SAST SARIF в MR |
| B3 | SCA block critical |
| B4 | IaC на `infra/`, `k8s/` |
| B5 | Dockerfile hadolint |
| B6 | Security linters |
| C1 | `sbom.cdx.json` на main |
| C2 | Container scan SARIF |
| C3 | Internal registry only |
| C4 | cosign manual |
| D1 | DAST на preprod |
| D2 | pytest `@security` |
| D3 | Release gate checklist |
| E1–E4 | K8s policies apply |
| F1–F3 | IAST manual, WAF runbook |

## 6. Валидация на sample-app

```bash
cd examples/sample-app
# локальные сканы — см. examples/sample-app/README.md
```

## 7. ASTO

- [ ] SARIF → DefectDojo / трекер
- [ ] SLA на findings

## 8. Документы организации

- [ ] [`07-governance-and-docs.md`](07-governance-and-docs.md) — регламенты DSO

См. [`quickstart.md`](quickstart.md).

# Release gate checklist

Используйте перед выпуском в PROD (подфаза D3). `T-PREPROD-PENTEST-*`, `T-ADI-ART-4-*`.

## Идентификация релиза

- [ ] Версия / tag: _______________
- [ ] Commit SHA: _______________
- [ ] Задача в трекере: _______________

## CI/CD артефакты

- [ ] Pipeline main зелёный
- [ ] SBOM `sbom.cdx.json` приложен к релизу
- [ ] Container scan: нет открытых Critical
- [ ] Образ подписан cosign (если C4)

## Security scans

- [ ] SAST: нет открытых Critical/High (или принят риск в тикете)
- [ ] SCA: нет Critical в прямых зависимостях
- [ ] Secrets: чисто
- [ ] DAST preprod выполнен (D1) — отчёт приложен

## Pentest (критичные системы)

- [ ] Pentest report актуален (< 12 мес)
- [ ] Открытые findings: triage завершён

## SecChamp / ИБ

- [ ] SecChamp approve в MR release
- [ ] Исключения (waivers) задокументированы с сроком

## K8s / runtime (E-фазы)

- [ ] Admission policies применены
- [ ] NetworkPolicy на namespace
- [ ] WAF/API rules обновлены (F2 runbook)

## Подписи

| Роль | ФИО | Дата |
|------|-----|------|
| SecChamp | | |
| DevOps | | |
| Аналитик ИБ (критичные) | | |

## GitHub environment protection (D3)

Configure **Settings → Environments → production**:

```yaml
# .github/workflows/release.yml (example)
jobs:
  release:
    environment:
      name: production
      url: https://app.example.com
    steps:
      - run: echo "Deploy after checklist sign-off"
```

Required reviewers: SecChamp + DevOps (minimum 1).

```bash
gh api repos/{owner}/{repo}/environments/production \
  -f reviewers[][type]=User -f reviewers[][id]=SECCHAMP_USER_ID
```

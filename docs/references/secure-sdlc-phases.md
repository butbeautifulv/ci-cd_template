# Secure SDLC — 8 этапов

Безопасная модель разработки ПО (Secure SDLC) интегрирует практики безопасности на всех этапах жизненного цикла разработки и эксплуатации приложения в рамках подхода DevSecOps.

См. маппинг на DAF и template: [sdlc-mapping.md](sdlc-mapping.md).

## Этапы Secure SDLC

### 01. Plan (Планирование)

Цель: выявление и анализ потенциальных угроз до начала разработки.

Практики:

- Threat Modeling (моделирование угроз)
- Misuse Cases (сценарии неправильного использования)
- Abuse Cases (сценарии злоупотребления)

Template: P0, A1, design docs (`P-REQ-TM-*`).

---

### 02. Code (Разработка)

Цель: обеспечение безопасности исходного кода на этапе написания.

Практики:

- SAST (Static Application Security Testing)
- SCA (Software Composition Analysis)
- Проверка Configuration Drift (отклонений конфигурации)

Template: B1–B6 (MR security gates).

---

### 03. Build (Сборка)

Цель: контроль безопасности зависимостей и среды сборки.

Практики:

- SCA (Software Composition Analysis)
- Контроль Configuration Drift
- Consistency in Environment (согласованность окружений)

Template: A2, C1–C2 (SBOM, image scan).

---

### 04. Test (Тестирование)

Цель: выявление уязвимостей до релиза.

Практики:

- IAST (Interactive Application Security Testing)
- SAST
- DAST (Dynamic Application Security Testing)
- Performance Testing
- Infrastructure (Cloud) Testing

Template: D1–D2; IaC re-check (`B4`).

---

### 05. Release (Релиз)

Цель: безопасная подготовка приложения к выпуску.

Практики:

- Контроль Configuration Drift
- Consistency in Environment
- SCA

Template: D3 pentest gate, C4 signing.

---

### 06. Deploy (Развертывание)

Цель: безопасный вывод приложения в эксплуатацию.

Практики:

- RASP (Runtime Application Self-Protection)
- PKI (Public Key Infrastructure)
- Secrets Management
- WAF (Web Application Firewall)
- IDS (Intrusion Detection System)
- Compliance Testing

Template: E1–E2, F2 runbooks (out-of-CI).

---

### 07. Operate (Эксплуатация)

Цель: обеспечение безопасности работающей системы.

Практики:

- RASP
- PKI
- Secrets Management
- WAF
- IDS
- Resilience Testing
- Chaos Engineering / Chaos Testing

Template: E3–E4 (Falco, SIEM); F2.

---

### 08. Monitor (Мониторинг)

Цель: непрерывный контроль безопасности и производительности.

Практики:

- Security Monitoring
- Application Monitoring
- Performance Testing

Template: F3 SBOM monitor, continuous SCA.

---

## DevSecOps

Secure SDLC реализуется через подход **DevSecOps**:

```text
Plan → Code → Build → Test → Release → Deploy → Operate → Monitor
```

## Gaps (не в базовом CI template)

| Практика | Рекомендация |
|----------|--------------|
| Misuse/Abuse cases | Threat model checklist (Plan) |
| Configuration Drift | IaC scan + admission (Code/Build/Release) |
| Performance / Chaos | QA/Operate — process, optional jobs |
| PKI / IDS | Deploy/Operate — infra runbooks |

Источник: перенесено из legacy `phases.md` (Jet/alternate SDLC view).

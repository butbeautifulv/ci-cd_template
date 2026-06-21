# Secure SDLC (Secure Software Development Life Cycle)

Безопасная модель разработки ПО (Secure SDLC) интегрирует практики безопасности на всех этапах жизненного цикла разработки и эксплуатации приложения в рамках подхода DevSecOps.

## Этапы Secure SDLC

### 01. Plan (Планирование)

Цель: выявление и анализ потенциальных угроз до начала разработки.

Практики:
- Threat Modeling (моделирование угроз)
- Misuse Cases (сценарии неправильного использования)
- Abuse Cases (сценарии злоупотребления)

---

### 02. Code (Разработка)

Цель: обеспечение безопасности исходного кода на этапе написания.

Практики:
- SAST (Static Application Security Testing)
- SCA (Software Composition Analysis)
- Проверка Configuration Drift (отклонений конфигурации)

---

### 03. Build (Сборка)

Цель: контроль безопасности зависимостей и среды сборки.

Практики:
- SCA (Software Composition Analysis)
- Контроль Configuration Drift
- Consistency in Environment (согласованность окружений)

---

### 04. Test (Тестирование)

Цель: выявление уязвимостей до релиза.

Практики:
- IAST (Interactive Application Security Testing)
- SAST
- DAST (Dynamic Application Security Testing)
- Performance Testing
- Infrastructure (Cloud) Testing

---

### 05. Release (Релиз)

Цель: безопасная подготовка приложения к выпуску.

Практики:
- Контроль Configuration Drift
- Consistency in Environment
- SCA

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

---

### 08. Monitor (Мониторинг)

Цель: непрерывный контроль безопасности и производительности.

Практики:
- Security Monitoring
- Application Monitoring
- Performance Testing

---

## DevSecOps

Secure SDLC реализуется через подход **DevSecOps**, при котором безопасность встроена в каждый этап жизненного цикла:

```text
Plan → Code → Build → Test → Release → Deploy → Operate → Monitor
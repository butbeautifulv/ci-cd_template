# Terraform test in CI

Patterns from HashiCorp `terraform test` for Fabrica consumers with IaC (phase B4).

## Strategy

| When | What | Credentials |
|------|------|-------------|
| Every PR | `terraform fmt -check`, `validate`, `test -filter=unit_test` (plan mode) | None |
| Main / nightly | `test -filter=integration_test` (apply mode) | Cloud secrets |

Name tests `*_unit_test.tftest.hcl` and `*_integration_test.tftest.hcl` for `-filter` separation.

## GitHub Actions (snippet)

```yaml
jobs:
  terraform-unit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0
      - working-directory: infra
        run: |
          terraform fmt -check -recursive
          terraform init -backend=false
          terraform validate
          terraform test -filter=unit_test -verbose
```

## GitLab CI (snippet)

```yaml
terraform-unit-tests:
  image: hashicorp/terraform:1.9
  stage: security
  script:
    - cd infra
    - terraform fmt -check -recursive
    - terraform init -backend=false
    - terraform validate
    - terraform test -filter=unit_test -verbose
```

## Example in Fabrica

- Weak demo: [examples/sample-app/infra/main.tf](../../../examples/sample-app/infra/main.tf)
- Secure contrast: [examples/sample-app/infra/secure/main.tf](../../../examples/sample-app/infra/secure/main.tf)
- Unit test: [examples/sample-app/infra/tests/demo_sg_unit_test.tftest.hcl](../../../examples/sample-app/infra/tests/demo_sg_unit_test.tftest.hcl)

Checkov still runs in B4 `iac-scan` job; Terraform test complements plan-time assertions.

## Related

- [B4-iac.md](../../phases/B4-iac.md)
- [terraform-style-guide SECURITY](https://developer.hashicorp.com/terraform/language/style) — least privilege, no hardcoded secrets

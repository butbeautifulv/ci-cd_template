# Fabrica Semgrep rules (corp offline)

CI must **never** use `p/ci` / semgrep.dev (corp MITM / no egress).

## Layout

| Path | Role |
|------|------|
| `vendor/` | Vendored from [semgrep/semgrep-rules](https://github.com/semgrep/semgrep-rules) (`python/`, `insecure-transport/`, `dockerfile/`) |
| `VENDOR_SHA.txt` | Upstream git SHA of the vendor snapshot |
| `weak-crypto.yaml` | Optional local overlay (Fabrica-specific) |

Default CI config: `SEMGREP_RULES=config/semgrep/vendor`.

## Refresh vendor

```bash
git clone --depth 1 https://github.com/semgrep/semgrep-rules.git /tmp/semgrep-rules
rm -rf config/semgrep/vendor
mkdir -p config/semgrep/vendor
cp -a /tmp/semgrep-rules/python config/semgrep/vendor/
cp -a /tmp/semgrep-rules/problem-based-packs/insecure-transport config/semgrep/vendor/
cp -a /tmp/semgrep-rules/dockerfile config/semgrep/vendor/
git -C /tmp/semgrep-rules rev-parse HEAD > config/semgrep/VENDOR_SHA.txt
```

Commit the tree — runners have no GitHub access.

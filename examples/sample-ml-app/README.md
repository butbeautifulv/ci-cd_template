# Sample ML / AI app — scanner demo

Intentionally weak artifacts for AI1 and ML1–ML3 validation.

## Contents

| Path | Triggers |
|------|----------|
| `data/train.csv` | ML1 **block** (PII email + SSN-like) |
| `.cursor/skills/demo-bad/SKILL.md` | AI1 **warn** (suspicious patterns) |
| `mcp/server.json` | MCP scan **warn** |
| `models/model.pkl` | Pickle scan **warn** |

## Local validation

From repo root:

```bash
cd examples/sample-ml-app

python3 ../../scripts/ai-ml-scan.py ml_data --report /tmp/ml-data.sarif
python3 ../../scripts/gate-check.py --control ml_data --report /tmp/ml-data.sarif
# expect exit 1 (PII block)

python3 ../../scripts/ai-ml-scan.py skill_scan --root . --report /tmp/skill.sarif
python3 ../../scripts/gate-check.py --control skill_scan --report /tmp/skill.sarif
# expect exit 0 (warn only)

python3 ../../scripts/ai-ml-scan.py aibom --report /tmp/aibom.json
python3 ../../scripts/ai-ml-scan.py ml_bom --report /tmp/ml-bom.json
```

## Adopt

```bash
./scripts/adopt.sh --profile ai-ml --platform gitlab --target /path/to/this-copy
```

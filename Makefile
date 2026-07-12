.PHONY: validate validate-quick validate-helm adopt-dry-run diagrams

PROFILE ?= shift-left
PLATFORM ?= github
TARGET ?= /tmp/fabrica-adopt-test

validate:
	bash scripts/validate-yaml.sh
	bash scripts/validate-pin-sync.sh
	bash scripts/validate-github-workflows.sh
	bash scripts/validate-github-oss.sh
	bash scripts/validate-gitlab-oss.sh
	python3 scripts/validate-policy.py
	bash scripts/validate-oss-pins.sh
	bash scripts/validate-registry-config.sh

validate-quick:
	bash scripts/validate-yaml.sh
	bash scripts/validate-github-workflows.sh
	python3 scripts/validate-policy.py

validate-helm:
	bash scripts/validate-helm-chart.sh

adopt-dry-run:
	bash scripts/adopt.sh --profile $(PROFILE) --platform $(PLATFORM) --target $(TARGET) --dry-run

diagrams:
	cd diagrams && (test -x .venv/bin/python || python3 -m venv .venv) && \
		.venv/bin/pip install -q -e . && \
		.venv/bin/python main.py

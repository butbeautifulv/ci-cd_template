.PHONY: validate validate-quick validate-helm adopt-dry-run diagrams \
	mirror-fleet-dry mirror-fleet mirror-aspm-html mirror-inventory-stub

PROFILE ?= shift-left
PLATFORM ?= github
TARGET ?= /tmp/fabrica-adopt-test
WAVE3 := hwa_service data_lake_service user_service
PRODUCTS ?= $(WAVE3)
CONCURRENCY ?= 1
TIER ?=

validate:
	bash scripts/validate-yaml.sh
	bash scripts/validate-pin-sync.sh
	bash scripts/validate-github-workflows.sh
	bash scripts/validate-github-oss.sh
	bash scripts/validate-gitlab-oss.sh
	bash scripts/validate-mirror-corp.sh
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

mirror-fleet-dry:
	python3 scripts/mirror-fleet-trigger.py --dry-run --enabled-only $(if $(TIER),--tier $(TIER),)

mirror-fleet:
	python3 scripts/mirror-fleet-trigger.py --wave3 --concurrency $(CONCURRENCY)

mirror-inventory-stub:
	python3 scripts/mirror-inventory-services.py --yaml-stub

# Batch HTML after Wave-3 pipelines (requires DEFECTDOJO_*). Soft-continue per product.
mirror-aspm-html:
	@mkdir -p reports
	@fail=0; for p in $(PRODUCTS); do \
	  echo "[aspm-html] $$p"; \
	  python3 scripts/dojo-render-aspm-report.py --product $$p --out reports/aspm-report-$$p.html \
	    || { echo "[aspm-html] WARN failed $$p"; fail=1; }; \
	done; \
	if [ $$fail -ne 0 ]; then echo "[aspm-html] some products failed"; exit 1; fi; \
	echo "[aspm-html] done → reports/aspm-report-*.html"

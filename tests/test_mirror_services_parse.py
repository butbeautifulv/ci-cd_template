#!/usr/bin/env python3
"""Unit tests for scripts/lib/mirror_services.py."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

from lib.mirror_services import filter_services, load_services  # noqa: E402

FIXTURE = ROOT / "testdata" / "mirror-services-fixture.yaml"


class TestMirrorServicesParse(unittest.TestCase):
    def test_load_counts(self):
        svcs = load_services(FIXTURE)
        self.assertEqual(len(svcs), 3)
        names = {s["name"] for s in svcs}
        self.assertEqual(names, {"alpha_pilot", "beta_core", "gamma_candidate"})

    def test_enabled_false_excluded(self):
        svcs = load_services(FIXTURE)
        filtered = filter_services(svcs, enabled_only=True)
        self.assertEqual({s["name"] for s in filtered}, {"alpha_pilot", "beta_core"})

    def test_tier_filter(self):
        svcs = load_services(FIXTURE)
        pilots = filter_services(svcs, tier="pilot", enabled_only=False)
        self.assertEqual([s["name"] for s in pilots], ["alpha_pilot"])
        cores = filter_services(svcs, tier="core", enabled_only=True)
        self.assertEqual([s["name"] for s in cores], ["beta_core"])

    def test_tier_all_skips_disabled_when_enabled_only(self):
        svcs = load_services(FIXTURE)
        all_en = filter_services(svcs, tier="all", enabled_only=True)
        self.assertEqual({s["name"] for s in all_en}, {"alpha_pilot", "beta_core"})

    def test_names_allowlist(self):
        svcs = load_services(FIXTURE)
        got = filter_services(svcs, names=["beta_core"], enabled_only=True)
        self.assertEqual([s["name"] for s in got], ["beta_core"])

    def test_missing_key_defaults(self):
        # write minimal temp via inline string path — use fixture beta which has keys;
        # simulate defaults with a tiny inline file
        import tempfile

        raw = """services:
  legacy_svc:
    project_id: "9"
    repo_url: "https://example.invalid/x.git"
    source_ref_fallback: "1.0.0"
"""
        with tempfile.NamedTemporaryFile("w", suffix=".yaml", delete=False) as f:
            f.write(raw)
            path = f.name
        try:
            svcs = load_services(path)
            self.assertEqual(len(svcs), 1)
            self.assertTrue(svcs[0]["enabled"])
            self.assertEqual(svcs[0]["tier"], "core")
        finally:
            Path(path).unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main()

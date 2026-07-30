#!/usr/bin/env python3
"""Offline skip-path tests for scripts/aspm-export-ci.sh (no DefectDojo)."""
from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "aspm-export-ci.sh"


def run_ci(env: dict[str, str], cwd: Path | None = None) -> subprocess.CompletedProcess:
    base = os.environ.copy()
    # Isolate from real Dojo / CI noise
    for k in list(base):
        if k.startswith("DEFECTDOJO_") or k in ("CI_COMMIT_TAG", "SERVICE_NAME"):
            base.pop(k, None)
    base.update(env)
    base["DEFECTDOJO_FAIL_ON_ERROR"] = "false"
    return subprocess.run(
        ["sh", str(SCRIPT)],
        cwd=str(cwd or ROOT),
        env=base,
        capture_output=True,
        text=True,
        check=False,
    )


class TestAspmExportCiSkip(unittest.TestCase):
    def test_missing_control_skips(self):
        r = run_ci({"ASPM_REPORT": "nope.json"})
        self.assertEqual(r.returncode, 0)
        self.assertIn("ASPM_CONTROL unset", r.stdout + r.stderr)

    def test_missing_report_var_skips(self):
        r = run_ci({"ASPM_CONTROL": "sast"})
        self.assertEqual(r.returncode, 0)
        self.assertIn("ASPM_REPORT unset", r.stdout + r.stderr)

    def test_missing_file_skips(self):
        r = run_ci({"ASPM_CONTROL": "sast", "ASPM_REPORT": "does-not-exist.sarif"})
        self.assertEqual(r.returncode, 0)
        self.assertIn("not found", r.stdout + r.stderr)

    def test_empty_file_skips(self):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "empty.sarif"
            p.write_text("", encoding="utf-8")
            # Script looks for scripts/aspm-export.py relative to cwd=ROOT
            # but report path can be absolute
            r = run_ci(
                {"ASPM_CONTROL": "sast", "ASPM_REPORT": str(p)},
                cwd=ROOT,
            )
            self.assertEqual(r.returncode, 0)
            self.assertIn("is empty", r.stdout + r.stderr)

    def test_empty_json_list_skips(self):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "empty-list.json"
            p.write_text("[]", encoding="utf-8")
            r = run_ci(
                {
                    "ASPM_CONTROL": "sast",
                    "ASPM_REPORT": str(p),
                    "ASPM_SKIP_EMPTY": "true",
                },
                cwd=ROOT,
            )
            self.assertEqual(r.returncode, 0)
            self.assertIn("empty list", r.stdout + r.stderr)

    def test_script_declares_curl_fallback(self):
        text = SCRIPT.read_text(encoding="utf-8")
        self.assertIn("curl-fallback", text)
        self.assertIn("run_aspm_curl", text)
        self.assertIn("reimport-scan", text)

    def test_curl_path_skips_without_dojo_url(self):
        """No python3 in PATH → curl path; missing DEFECTDOJO_URL → skip 0."""
        with tempfile.TemporaryDirectory() as td:
            td_path = Path(td)
            report = td_path / "findings.sarif"
            report.write_text(
                '{"version":"2.1.0","runs":[{"results":[{"ruleId":"x"}]}]}',
                encoding="utf-8",
            )
            bin_dir = td_path / "bin"
            bin_dir.mkdir()
            for name in ("sh", "awk", "curl", "cut", "printf", "head", "cat", "chmod"):
                src = Path("/usr/bin") / name
                if not src.exists():
                    src = Path("/bin") / name
                if src.exists():
                    (bin_dir / name).symlink_to(src)
            env = os.environ.copy()
            for k in list(env):
                if k.startswith("DEFECTDOJO_") or k in ("CI_COMMIT_TAG", "SERVICE_NAME"):
                    env.pop(k, None)
            env["PATH"] = str(bin_dir)
            env["ASPM_CONTROL"] = "secrets"
            env["ASPM_REPORT"] = str(report)
            env["ASPM_CONFIG"] = str(ROOT / "config" / "aspm-export.yaml")
            env["DEFECTDOJO_FAIL_ON_ERROR"] = "true"
            # no DEFECTDOJO_URL
            r = subprocess.run(
                ["sh", str(SCRIPT)],
                cwd=str(ROOT),
                env=env,
                capture_output=True,
                text=True,
                check=False,
            )
            out = r.stdout + r.stderr
            self.assertEqual(r.returncode, 0, out)
            self.assertIn("DEFECTDOJO_URL not set", out)


if __name__ == "__main__":
    unittest.main()

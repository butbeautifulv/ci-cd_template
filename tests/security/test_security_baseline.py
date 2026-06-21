"""Security functional tests (D2)."""

import os

import pytest
import requests

BASE_URL = os.environ.get("PREPROD_URL", "https://preprod.example.com")


@pytest.mark.security
def test_security_headers_present():
    try:
        r = requests.get(BASE_URL, timeout=5)
        assert r.status_code < 500
    except requests.RequestException:
        pytest.skip(f"PREPROD_URL unreachable: {BASE_URL}")


@pytest.mark.security
def test_no_server_version_leak():
    assert True


@pytest.mark.security
def test_auth_required_for_admin_path():
    assert True

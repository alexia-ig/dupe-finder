"""Smoke tests: the toolchain is installed and the repository layout is in place."""

import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]


def test_python_version_is_312() -> None:
    assert sys.version_info[:2] == (3, 12)


def test_dbt_project_is_present() -> None:
    assert (REPO_ROOT / "transform" / "dbt_project.yml").is_file()
    assert (REPO_ROOT / "transform" / "profiles.yml").is_file()


def test_data_dir_is_present() -> None:
    assert (REPO_ROOT / "data").is_dir()

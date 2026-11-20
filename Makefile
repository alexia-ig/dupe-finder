# Dupe Finder — developer commands. Run `make help` for the list.
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

# dbt target: dev (default) | ci | prod. Override with `make check DBT_TARGET=ci`.
DBT_TARGET ?= dev
export DBT_TARGET

# Some Windows antivirus products that inspect HTTPS (e.g. Avast Web Shield) set
# SSLKEYLOGFILE to a pseudo-file such as \\.\aswMonFltProxy\<id>. When Python's OpenSSL
# tries to write TLS session keys there, the process crashes with
# "OPENSSL_Uplink ... no OPENSSL_Applink" (seen with dbt). This variable is a debugging
# aid only (TLS key logging for Wireshark-like tools); nothing in this project needs it,
# so it is removed from the environment of every command run by make.
# No effect in CI, where the variable is not set. See README "Dépannage".
unexport SSLKEYLOGFILE

DBT := cd transform && uv run dbt
DBT_FLAGS := --profiles-dir .

.PHONY: help setup lint format test dbt-deps dbt-debug check clean

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

setup: ## Install Python deps (locked), git hooks and dbt packages
	uv sync --locked
	uv run pre-commit install
	$(MAKE) dbt-deps

lint: ## Lint Python (ruff, mypy) and SQL (sqlfluff), no file modified
	uv run ruff check .
	uv run ruff format --check .
	uv run mypy
	uv run sqlfluff lint transform

format: ## Auto-fix Python formatting and lint issues
	uv run ruff check --fix .
	uv run ruff format .

test: ## Run pytest
	uv run pytest

dbt-deps: ## Install dbt packages (versions locked in package-lock.yml)
	$(DBT) deps $(DBT_FLAGS)

dbt-debug: ## Check dbt config and DuckDB connection for DBT_TARGET
	$(DBT) debug $(DBT_FLAGS)

check: lint test dbt-debug ## Everything that must pass before saying "done"

clean: ## Remove caches and dbt build artefacts (keeps data/)
	rm -rf .ruff_cache .mypy_cache .pytest_cache transform/target transform/logs

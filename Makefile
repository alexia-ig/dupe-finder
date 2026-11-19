# Dupe Finder — developer commands. Run `make help` for the list.
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

# dbt target: dev (default) | ci | prod. Override with `make check DBT_TARGET=ci`.
DBT_TARGET ?= dev
export DBT_TARGET

# Some antivirus HTTPS proxies set SSLKEYLOGFILE to a pseudo-file that makes OpenSSL
# crash inside Python ("no OPENSSL_Applink"). dbt never needs TLS key logging.
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

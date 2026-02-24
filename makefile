SHELL := /bin/bash

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install the stuff
	@uv sync
	@uv run --env-file=.env pre-commit install
	@uv run --env-file=.env pre-commit autoupdate

.PHONY: skjold
skjold: ## Sync config for Windows
	@uv run --env-file=.env skjold -v audit @uv.lock

.PHONY: flake8
flake8: ## Flake8
	@uv run --env-file=.env flake8

test: skjold flake8 ## Make test

run: ## Run cron
	@uv run --env-file=.env python start.py

.PHONY: update
update: ## Update requirements
	@uv lock --upgrade
	@uv run --env-file=.env --env-file=.env pre-commit autoupdate

.PHONY: test
test: ## Run tests
	@uv run --env-file=.env --env-file=.env python manage.py test --verbosity=0 --parallel --failfast

.PHONY: run
run: ## Run the Django server
	@uv run --env-file=.env --env-file=.env python manage.py runserver


deploy: ## make the deploy code
	@uv export --no-hashes --format requirements-txt > requirements.txt


precommit: ## Run pre-commit hooks
	@git add . & uv run --env-file=.env --env-file=.env pre-commit run --all-files

patch: ## Increment patch
	@uv version --bump patch

minor: ## Increment minor
	@uv version --bump minor

major: ## Increment major
	@uv version --bump major

alpha: ## Increment alpha
	@uv version --bump alpha

beta: ## Increment beta
	@uv version --bump beta

stable: ## Increment stable
	@uv version --bump stable

dev: ## Increment dev
	@uv version --bump dev

.PHONY: changelog ## update CHANGELOG.md and amend it on the commit
changelog:
	@uv run git-cliff --config pyproject.toml --output CHANGELOG.md
	@git add CHANGELOG.md
	@git commit --amend --no-edit

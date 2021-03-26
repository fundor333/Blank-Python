include .env

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install the stuff
	pipenv install --pre
	pipenv run pre-commit install
	pipenv run pre-commit autoupdate

.PHONY: skjold
skjold: ## Sync config for Windows
	pipenv run skjold -v audit Pipenv.lock

.PHONY: flake8
flake8: ## Flake8
	pipenv run flake8

test: skjold flake8 ## Make test

run: ## Run cron
	pipenv run python start.py

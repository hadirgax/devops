PROJECT_NAME ?= default-project-name
VENV_NAME ?= venv
VENV_BIN_PATH ?= $$(conda info --base)/envs/$(VENV_NAME)/bin
VENV_PYTHON_VERSION ?= $$(grep -E '^\s*requires-python\s*=' pyproject.toml | sed -E 's/.*([0-9]+\.[0-9]+).*/\1/')

export ENVIRONMENT ?= local
export PYTHONPATH := .:./app
export PORT ?= 8711
export APP_URL ?= http://localhost:$(PORT)
.PHONY: all

tv:
	@echo $(PROJECT_NAME)

# ===== Environment =====

env-create:
	conda create -n $(VENV_NAME) -c conda-forge -y --no-default-packages

env-install:
	$(CONDA_EXE) install -n $(VENV_NAME) -c conda-forge -y python=$(VENV_PYTHON_VERSION)
	$(VENV_BIN_PATH)/pip install uv
	$(VENV_BIN_PATH)/uv pip install -r requirements-dev.txt
	$(VENV_BIN_PATH)/pre-commit install --hook-type pre-commit
	@echo "#\n# To activate this environment, use:\n#\n#\t$$ conda activate $(VENV_NAME)"
	@echo "#\n# To deactivate an active environment, use:\n#\n#\t$$ conda deactivate\n"

env-remove:
	conda remove -n $(VENV_NAME) --all -y

env-update:env-remove env-create env-install


#===== Run =====

run:
	./scripts/run.sh


# ===== Test =====

pytest:
	rm -f .reports/coverage*
	coverage run -m pytest -x -vv -W ignore::DeprecationWarning --failed-first
	coverage combine
	coverage html
	coverage report

smoke-test:
	./tests/smoke-test.sh $(APP_URL)

# ===== Format =====

format:
	set -x
	ruff check . --fix --config pyproject.toml
	ruff format . --config pyproject.toml

lint:
	set -e
	set -x
	mypy --config-file pyproject.toml .
	ruff check . --config pyproject.toml
	ruff format . --check --config pyproject.toml

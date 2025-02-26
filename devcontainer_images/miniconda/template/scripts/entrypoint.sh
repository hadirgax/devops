#!/bin/bash

git config --global --add safe.directory /workspace

# Check if the Conda Environment exists
if conda info --envs | grep -q "${VENV_NAME}"; then
    echo ">>> Conda Environment '${VENV_NAME}' already exists."
else
    echo "Conda Environment '${VENV_NAME}' does not exist."
    echo ">>> Creating a new Conda environment..."
    make env-create
fi

# Check if Conda Environment has all the required dependencies
echo ">>> Checking dependencies..."
CONDA_LIST_FILE=$(mktemp)
conda list -n ${VENV_NAME} | awk 'NR>3 {print $1}' > ${CONDA_LIST_FILE}
REQUIREMENTS_DEV_TXT=$(cat requirements-dev.txt | awk 'NR == 1, /dependencies/ { next } { print }')
REQUIREMENTS_TXT=$(cat requirements.txt | awk 'NR == 1, /dependencies/ { next } { print }')
DEPENDENCIES_LIST=$(echo "${REQUIREMENTS_DEV_TXT} ${REQUIREMENTS_TXT}" | awk '{$1=$1;print}' | awk -F'[=<>:]' '{print $1}')
for search_term in ${DEPENDENCIES_LIST}; do
  grep -q ^${search_term}$ ${CONDA_LIST_FILE}
  [ $? -ne 0 ] && echo ">>> Missing conda/pip dependencies: [${search_term}]" && \
  make env-install && break
done

echo ">>> Conda Environment is ready."

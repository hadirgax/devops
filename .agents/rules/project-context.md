# Project Context

## Project Identity
- **Name**: DevOps
- **Type**: DevOps / Configuration Repository
- **Purpose**: Configuration of development environments and docker images to run devcontainers.
- **Domain**: Developer tooling, environment setup, VSCode server, Devcontainers

## Technology Stack
- **Languages**: Bash, PowerShell, Makefile
- **Frameworks/Tools**: Docker, Devcontainers, miniconda, python, zsh, code-server (vscode)

## Configuration
- `code_server/docker-compose.yml`: code-server container configuration.
- `.devcontainer/devcontainer.json`: Devcontainer configuration using custom image.
- `setup_devenv/windows/setup-wsl2.sh`: Shell setup script for WSL2 environment.

## Development Workflow
- Uses VSCode with devcontainers for standardized environments.
- Copilot, GitHub Actions, Python, Jupyter extensions configured.

## Architecture Patterns
- Setup scripts for environment bootstrapping.
- Makefile for pulling/running code-server locally.

## External Integrations
- GitHub (Oh My Zsh, plugins)
- Docker Hub (codercom/code-server)
- Package Managers (apt, conda, npm, wget/curl for binaries)

## Runtime Dependency Graph
- `Browser → code-server :8487 (native) / :8443 (docker)`

## Local Dev Runbook
1. Initialize WSL2 Environment: Run `setup_devenv/windows/setup-wsl2.sh main`
2. Start code-server native: `make get-code-server` then `make start-code-server` in `code_server` directory.
3. Start code-server container: `docker compose up` in `code_server`.

## Environment Variable Dependency Chain
- `DOCKER_USER` → Used by `code_server/docker-compose.yml`; sets environment for code-server container.
- `HOME_CODE_SERVER_DIR` → Used by `code_server/Makefile`; defaults to `~/.code-server`.

## Domain Glossary
- **code-server**: A VSCode instance running on a remote server accessible through a web browser.

## Data Model Overview
- N/A (No databases or core data structures found)

## Project Structure
```text
.
./.gitignore
./.agents
./.agents/rules
./.agents/skills
./vscode_pack
./vscode_pack/README.md
./README.md
./code_server
./code_server/docker-compose.yml
./code_server/Makefile
./code_server/README.md
./setup_devenv
./setup_devenv/README.md
./setup_devenv/linux_ubuntu
./setup_devenv/windows
./setup_devenv/doublecmd
./.devcontainer
./.devcontainer/devcontainer.json
./skills-lock.json
./LICENSE
./.github
./devcontainer_images
./devcontainer_images/python
./devcontainer_images/miniconda
```

<!-- Last Updated: 2026-05-17 -->
<!-- Updated By: Antigravity -->

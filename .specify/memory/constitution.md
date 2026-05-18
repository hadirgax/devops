<!--
Sync Impact Report:
- Version Change: 0.1.0 -> 0.2.0
- Modified Principles:
  - I. Spec-Driven & AI-Native Configuration (added AI-native focus, Makefiles reference)
  - III. Declarative Dependency Management (added Nix, Docker, Terraform, Ansible)
  - IV. Radical Simplicity & Convention (added single-developer context)
  - VI. Modular Architecture & Fail-Fast Execution (added AI generation focus, Makefiles)
  - Governance (added single developer AI review context)
- Templates requiring updates (✅ updated / ⚠ pending):
  - .specify/templates/plan-template.md (⚠ pending)
  - .specify/templates/spec-template.md (⚠ pending)
  - .specify/templates/tasks-template.md (⚠ pending)
-->

# Devops Constitution

## Core Principles

### I. Spec-Driven & AI-Native Configuration

All configuration scripts MUST be generated strictly based on definitions within a `spec.md` file. Prioritize declarative configurations (e.g., Terraform, Ansible, Nix) over imperative scripting (e.g., Bash, Makefiles) whenever possible. As an AI-native project maintained by a single developer, code must be highly LLM-friendly: always use descriptive variable names, avoid clever but obscure one-liners, and include inline comments explaining the *intent* (the "why") behind complex configurations, not just the action.

### II. Strict Idempotency

All configuration scripts MUST be perfectly idempotent. Executing the setup scripts once, twice, or one hundred times must reliably result in the exact same target environment state without causing errors, duplicating configurations, or breaking existing workflows. Always verify if a package, file, container, or configuration already exists before attempting to create or install it. Assuming a "clean slate" or writing imperative logic that fails on subsequent runs is strictly forbidden. This ensures predictable, resilient, and repeatable environment setups.

### III. Declarative Dependency Management

System dependencies, binaries, and libraries MUST be managed exclusively through standardized package managers and unified manifest files (e.g., Nix flakes, Dockerfiles, Terraform states, Ansible playbooks). Writing custom shell scripts to curl and compile binaries is not permitted unless a standardized package absolutely does not exist. This maintains a clean separation between "what needs to be installed" and "how the environment is orchestrated."

### IV. Radical Simplicity & Convention

Follow existing file structures, naming conventions, and script patterns exactly. Do not introduce overly complex orchestration frameworks, new architectural layers, or abstraction magic unless absolutely necessary. This project is designed to eliminate developer friction; ease of maintenance through script readability, familiarity, and predictability is paramount, especially for a solo maintainer leveraging AI.

### V. Zero-to-Hero DevEx (Frictionless Onboarding)

The end-user experience is paramount and must require zero manual configuration. The system MUST provide a single entry point (e.g., `./bootstrap.sh` or `make setup`) that yields a fully functioning, development-ready environment. Prompts for manual input, post-install "next steps" in a README, or requiring the developer to manually tweak configuration files after execution are not permitted.

### VI. Modular Architecture & Fail-Fast Execution

Scripts MUST be heavily modularized into single-responsibility files (e.g., `01-install-deps.sh`, `02-setup-docker.sh`) to facilitate AI-assisted generation, refactoring, and testing. Imperative scripts (like Bash and Makefiles) MUST employ strict error handling (e.g., `set -euo pipefail`). Systems must fail gracefully, halt execution immediately upon encountering an error, and output highly descriptive, actionable error messages pointing exactly to the point of failure.

### VII. Zero-Trust Secrets Management

Hardcoding credentials, API keys, database passwords, or any sensitive tokens into scripts or repositories is strictly forbidden. All secrets MUST be injected at runtime. Always utilize `.env.template` files for local development, enforce the use of environment variables, and structure the architecture to easily integrate with secure secret managers (e.g., Doppler, AWS Secrets Manager, HashiCorp Vault) when necessary.

## Development Workflow

- **Specification First**: Every new environment feature, environment dependency, toolset, infrastructure change, or configuration tweak must be defined in a `spec.md` before implementation begins.
- **Plan Review**: Implementation plans must be reviewed against these principles, explicitly validating how the proposed changes guarantee idempotency, secrets management and avoid host-machine pollution before generating code.
- **Declarative-First Design**: New environment requirements must default to declarative tool definitions (Ansible/Terraform/Docker/Nix) before resorting to raw Bash or Makefiles scripting.

## Governance

- Constitution supersedes all other practices.
- As a single-developer project, amendments require documentation and corresponding updates to affected templates (e.g. Plan, Spec, Tasks templates).
- All AI-generated code must be reviewed against these architectural rules before commit.
- Versioning policy: MAJOR for new principles or removals, MINOR for principle expansions, PATCH for clarifications.

**Version**: 0.2.0 | **Ratified**: 2026-05-17 | **Last Amended**: 2026-05-17

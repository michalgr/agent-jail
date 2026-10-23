# AGENTS.md

Instructions and guidelines for AI agents working in this repository.

## Repository Overview & Architecture

* **Purpose:** This repository defines `agent-jail`, an isolated containerized environment (Docker/Podman) used to run autonomous, unrestricted coding agents safely.
* **Config Source:** Local container configurations and custom Nix packages reside under `config/`, while shared configurations (`tmux-config`, `agents-config`) are pulled via Nix Flake inputs.
* **Declarative System:** Nix Flakes (`flake.nix`) and Home Manager (`home.nix`) configure packages and symlink files inside the container.
* **Containerization:** `Dockerfile` builds the Ubuntu/Nix runtime environment.

## Guidelines for Changes

* **Edit Sources, Not Generated Links:** Always modify configuration files inside `config/` or definitions in `home.nix` rather than target symlink locations directly.
* **Flake Consistency:** When adding packages or changing tool definitions, update `home.nix` (and `flake.nix` if adding new inputs).
* **Isolation Scope:** Remember this environment is designed specifically as an isolated container sandbox. Tool permissions and autonomous rules are tuned for jail isolation.

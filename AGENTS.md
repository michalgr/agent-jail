# AGENTS.md

Instructions and guidelines for AI agents working in this repository.

## Repository Overview & Architecture

* **Dotfiles Source:** All user tool configurations reside under `config/`.
* **Declarative System:** Nix Flakes (`flake.nix`) and Home Manager (`home.nix`) configure packages and symlink files to `~/.config/` and `~/.gemini/`.
* **Containerization:** `Dockerfile` provides the reproducible build environment.

## Guidelines for Changes

* **Edit Sources, Not Generated Links:** Always modify configuration files inside `config/` or definitions in `home.nix` rather than target symlink locations directly.
* **Flake Consistency:** When adding packages or changing tool definitions, update `home.nix` (and `flake.nix` if adding new inputs).

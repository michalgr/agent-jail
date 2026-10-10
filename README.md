# agent-jail

An isolated containerized development environment for running autonomous, unrestricted AI coding agents safely.

Packaged as a Docker/Podman container and declaratively configured using Nix Flakes and Home Manager.

## Features

- **Isolated Sandbox:** Safe playground for autonomous agents operating with unrestricted execution permissions.
- **Reproducible Toolchain:** Packages and dotfiles managed declaratively via Nix Flakes and Home Manager (`home.nix`).
- **Pre-configured Tooling:** Helix, Tmux (with agent lifecycle status hooks), Starship, Lazygit, Git + Delta, Go, Rust, Python/Ruff, and agent integrations.

## Container Setup

### Build

```bash
# Docker
docker build -t agent-jail .

# Podman
podman build -t agent-jail .
```

### Run

Run the jail container with your project mounted into the workspace:

```bash
# Docker
docker run -it --rm -v $(pwd):/home/michalgr/workspace agent-jail

# Podman
podman run -it --rm -v $(pwd):/home/michalgr/workspace agent-jail
```

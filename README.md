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

## Podman Machine Setup (macOS)

For running agent jails on macOS, Podman requires a Linux VM.

### 1. Initialize & Start

Initialize with resource allocations tailored to your workload and start immediately:

```bash
podman machine init \
  --cpus <cores> \
  --memory <mib> \
  --disk-size <gib> \
  --now
```

Example (e.g., 12 CPUs, 48 GB RAM, 250 GB disk):

```bash
podman machine init \
  --cpus 12 \
  --memory 49152 \
  --disk-size 250 \
  --now
```

* **What `--now` does:** Without `--now`, `podman machine init` only configures and creates the VM on disk in a stopped state, requiring a manual `podman machine start`. `--now` boots the VM immediately once initialized.

### 2. VM Lifecycle Cheat Sheet

| Action | Command |
| :--- | :--- |
| **Check status** | `podman machine list` |
| **Start VM** | `podman machine start` |
| **Stop VM** | `podman machine stop` |
| **Inspect resources** | `podman machine inspect` |
| **SSH into VM** | `podman machine ssh` |
| **Adjust resources** | `podman machine stop && podman machine set --cpus <cores> --memory <mib> && podman machine start` |

### 3. Reclaiming Host Disk Space

The VM disk is created as a sparse image (starts at ~1.5 GB and expands dynamically up to the configured limit). Shutting down the VM does not automatically compact the file on macOS.

* **Clean up without destroying the VM:**
  ```bash
  # Prune containers, images, and volumes
  podman system prune -a --volumes -f

  # Trim deleted blocks back to host filesystem
  podman machine ssh sudo fstrim -av
  ```

* **Full Clean-Slate Reset (Reclaims 100% of disk):**
  ```bash
  podman machine rm -f podman-machine-default
  podman machine init --cpus <cores> --memory <mib> --disk-size <gib> --now
  ```



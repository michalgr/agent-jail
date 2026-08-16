# michalgr / env

Personal development environment for **michalgr**, packaged as a container and configured declaratively using Nix Flakes and Home Manager.

## Container Setup

### Build

```bash
docker build -t michalgr-env .
```

### Run

```bash
docker run -it --rm -v $(pwd):/home/michalgr/workspace michalgr-env
```

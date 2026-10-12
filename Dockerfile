FROM ubuntu:noble

# 1. System Dependencies (Base Layer)
RUN apt update && apt install -y \
    adduser \
    build-essential \
    curl \
    git \
    sudo \
    xz-utils \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# 2. User Setup (UID 1001 avoids conflict with default 'ubuntu' user)
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN useradd -rm -d /home/michalgr -s /bin/zsh -u 1001 michalgr && \
    adduser michalgr sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER michalgr
ENV USER=michalgr
WORKDIR /home/michalgr/

# 3. Nix Installation (Single-user mode)
# This layer is independent of config files
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
ENV PATH="/home/michalgr/.nix-profile/bin:/home/michalgr/.local/bin:/home/michalgr/.local/state/nix/profiles/profile/bin:$PATH"

# 4. Nix Config (Pre-copy to enable Flakes)
COPY --chown=michalgr:michalgr config/nix/nix.conf /home/michalgr/.config/nix/nix.conf

# 5. Home Manager Setup (Heavy Caching Layer)
COPY --chown=michalgr:michalgr flake.nix flake.lock home.nix /home/michalgr/.dotfiles/
COPY --chown=michalgr:michalgr config/ /home/michalgr/.dotfiles/config/

RUN cd /home/michalgr/.dotfiles/ \
    && git init \
    && git add -A \
    && nix --extra-experimental-features "nix-command flakes" \
    run github:nix-community/home-manager -- switch --flake .#michalgr \
    && nix-collect-garbage -d \
    && rm -rf $HOME/.cache/nix \
    && rm -rf $HOME/.cache/pip $HOME/.cache/uv

# 6. Final Source Sync and Cleanup
COPY --chown=michalgr:michalgr . /home/michalgr/.dotfiles/
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/bin/zsh", "-l"]

{ pkgs, lib, tmux-control-panel, ... }:
let
  jules-cli = pkgs.callPackage ./config/pkgs/jules.nix { };
in
{

  home.username = "michalgr";
  home.homeDirectory = "/home/michalgr";
  home.stateVersion = "23.11";

  nixpkgs.config.allowUnfree = true;

  # 1. Packages (Migrated from config/nixpkgs/config.nix)
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    bat
    bottom
    coreutils
    eza
    fd
    findutils
    gawk
    git
    gnused
    gnugrep
    go
    go-tools
    gopls
    delve
    lazygit
    less
    opencode
    pyrefly
    ripgrep
    rizin
    rizinPlugins.rz-ghidra
    ruff
    rustup
    tree
    tmux
    unzip
    uv
    wget
    zip
    tmux-control-panel.packages.${pkgs.system}.default
    jules-cli
  ];

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
  ];

  # 2. Shell Configuration (Migrated from config/zsh/.zshrc)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$rust$python$character";
      directory = {
        style = "bold cyan";
      };
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Michal Gregorczyk";
    userEmail = "michalgr@live.com";
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
        syntax-theme = "Monokai Extended";
      };
    };
  };

  programs.gh = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "rust" "fzf" ];
    };
    shellAliases = {
      lg = "lazygit";
      cat = "bat";
      ls = "eza --icons --git";
      top = "btm";
      tmux = "tmux -u";
    };
    initExtra = ''
      # Tool-specific initializations
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    '';
  };

  programs.antigravity-cli = {
    enable = true;
    settings = {
      toolPermission = "always-proceed";
      colorScheme = "dark";
    };
    context = {
      AGENTS = ./config/agents/AGENTS.md;
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "monokai_pro_machine";
      editor = {
        true-color = true;
        cursorline = true;
        bufferline = "always";
        color-modes = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
        };
        indent-guides = {
          render = true;
          character = "┊";
        };
      };
    };
    languages = {
      language = [
        {
          name = "rust";
          auto-format = true;
          formatter = { command = "rustfmt"; };
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [ "pyrefly" "ruff" ];
          formatter = { command = "ruff"; args = [ "format" "-" ]; };
        }
        {
          name = "go";
          auto-format = true;
        }
      ];
      language-server = {
        rust-analyzer = {
          config.check = {
            command = "clippy";
          };
        };
        pyrefly = {
          command = "pyrefly";
          args = [ "lsp" ];
        };
        ruff = {
          command = "ruff";
          args = [ "server" ];
        };
      };
    };
  };


  # 3. Manage Config Files (Symlink to existing files in repo)
  xdg.configFile."agents/AGENTS.md".source = ./config/agents/AGENTS.md;
  xdg.configFile."tmux/tmux.conf".source = ./config/tmux/tmux.conf;
  xdg.configFile."tmux/hx-git.sh".source = ./config/tmux/hx-git.sh;
  xdg.configFile."tmux/tmux-status-hook.sh".source = ./config/tmux/tmux-status-hook.sh;
  xdg.configFile."nix/nix.conf".source = ./config/nix/nix.conf;

  home.file.".gemini/config/hooks.json".source = ./config/gemini/hooks.json;
  home.file.".gemini/config/skills/jules".source = ./config/gemini/skills/jules;
}

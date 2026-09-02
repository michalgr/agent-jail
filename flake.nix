{
  description = "Michal's Dev Environment Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-control-panel = {
      url = "github:michalgr/tmux-control-panel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, tmux-control-panel, llm-agents, ... }:
    let
      system = "aarch64-linux"; # Matches arm64 Docker on M1/M2/M3 Macs
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."michalgr" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit tmux-control-panel llm-agents; };
      };
    };
}

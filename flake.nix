{
  description = "Michal's Dev Environment Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-config = {
      url = "github:michalgr/tmux-config";
      flake = false;
    };
    agents-config = {
      url = "github:michalgr/agents-config";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, tmux-config, agents-config, ... }:
    let
      system = "aarch64-linux"; # Matches arm64 Docker on M1/M2/M3 Macs
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        jules-cli = pkgs.callPackage ./config/pkgs/jules.nix { };
        antigravity-cli = pkgs.callPackage ./config/pkgs/antigravity.nix { };
      };

      homeConfigurations."michalgr" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit tmux-config agents-config; };
      };
    };
}

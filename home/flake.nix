{
  description = "Linulas Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # Pinned older nixpkgs for claude-desktop, which still references
    # nodePackages.asar (removed from nixpkgs on 2026-03-03).
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs-2505";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
          permittedInsecurePackages = [
            "nexusmods-app-unfree-0.21.1"
          ];
        };
      };
      env = import ./local/env.nix; # NOTE: Untracked file, must be added manually
    in
    {
      homeConfigurations = {
        "${env.nixUser}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };

          modules = [ ./default.nix ];
        };
        "${env.nixWorkUser}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };

          modules = [ ./work.nix ];
        };
      };
    };
}

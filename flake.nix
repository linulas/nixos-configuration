{
  description = "Linulas NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Pinned older nixpkgs for claude-desktop, which still references
    # nodePackages.asar (removed from nixpkgs on 2026-03-03).
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs-2505";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
          allowUnfreePredicate = (pkg: true);
          pulseaudio = true;
          permittedInsecurePackages = [
            "nexusmods-app-unfree-0.21.1"
          ];
        };
      };

      pkgsUnstable = import nixpkgs-unstable {
        inherit system;

        config = {
          allowUnfree = true;
          allowUnfreePredicate = (pkg: true);
          pulseaudio = true;
        };
      };
    in
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs pkgsUnstable; };

          modules = [
            ./configuration.nix
            # Set the main pkgs instance using the one defined in the 'let' block
            { nixpkgs.pkgs = pkgs; }
            ({ modulesPath, ... }: {
              imports = [ (modulesPath + "/misc/nixpkgs/read-only.nix") ];
            })
          ];
        };
      };
    };
}

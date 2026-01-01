{
  description = "Linulas NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
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

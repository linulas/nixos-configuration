{
  description = "Linulas NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
          allowUnfreePredicate = (pkg: true);
        };
      };
    in
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs system pkgs; };

          modules = [
            ./configuration.nix
          ];
        };
      };
    };
}

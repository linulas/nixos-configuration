{
  description = "Linulas Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/0b491b460f52e87e23eb17bbf59c6ae64b7664c1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
        };
      };
      env = import ./local/env.nix; # NOTE: Untracked file, must be added manually
    in
    {
      homeConfigurations."${env.nixUser}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [ ./default.nix ];
      };
    };
}

{
  description = "Linulas Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager";
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

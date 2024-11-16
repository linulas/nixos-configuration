{ pkgs, ... }:
let
  env = import ./local/env.nix; # NOTE: Untracked file, must be added manually
in
{
  home = {
    stateVersion = "23.11";
    username = env.nixUser;
    homeDirectory = "/home/${env.nixUser}";

    packages = with pkgs; [
      brave
      csharp-ls
      caprine-bin
      delve
      discord
      dotnet-sdk_8
      feh
      go
      gopls
      htop
      iftop
      lazygit
      lua-language-server
      lutris
      marksman
      multiviewer-for-f1
      neofetch
      netcoredbg
      nixpkgs-fmt
      nodejs_20
      obsidian
      prettierd
      rustup
      spotify
      stylua
      synergy
      telegram-desktop
      tutanota-desktop
      xarchiver
      nodePackages.svelte-language-server
      nodePackages.typescript-language-server
      vscode-langservers-extracted
    ];

    file = {
      ".config/kitty/kitty.conf".source = ./config/kitty.conf;
      ".config/i3/config".source = ./config/i3.conf;
      ".config/i3status/config".source = ./config/i3_status.conf;
      ".config/picom/picom.conf".source = ./config/picom.conf;
    };
  };

  programs = {
    git = {
      enable = true;
      extraConfig = {
        credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

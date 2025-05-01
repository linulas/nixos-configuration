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
      postman
      reaper
      rustup
      spotify
      stylua
      surge-XT
      synergy
      telegram-desktop
      tutanota-desktop
      vital
      xarchiver
      nodePackages.svelte-language-server
      nodePackages.typescript-language-server
      vscode-langservers-extracted
    ];

    file = {
      ".config/kitty/kitty.conf".source = ./config/kitty.conf;
      ".config/waybar/config.jsonc".source = ./config/waybar/waybar.jsonc;
      ".config/waybar/style.css".source = ./config/waybar/waybar_style.css;
      ".config/waybar/launch_menu.sh".source = ./config/waybar/launch_menu.sh;
      ".config/hypr/hyprland.conf".source = ./config/hyprland.conf;
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

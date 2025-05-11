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
      geonkick
      go
      gopls
      hydrogen
      lazygit
      lua-language-server
      lutris
      marksman
      multiviewer-for-f1
      neofetch
      netcoredbg
      nexusmods-app-unfree
      nixpkgs-fmt
      nodejs_20
      nvitop
      obsidian
      odin2
      prettierd
      protontricks
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
      nodePackages.svelte-language-server
      nodePackages.typescript-language-server
      vscode-langservers-extracted
      zynaddsubfx
    ];

    file = {
      ".config/kitty/kitty.conf".source = ./config/kitty.conf;
      ".config/waybar/config.jsonc".source = ./config/waybar/waybar.jsonc;
      ".config/waybar/style.css".source = ./config/waybar/waybar_style.css;
      ".config/waybar/launch_menu.sh".source = ./config/waybar/launch_menu.sh;
      ".config/hypr/hyprland.conf".source = ./config/hyprland.conf;
      ".local/share/applications/nvim.desktop".source = ./config/nvim.desktop;
    };
  };

  programs = {
    btop = {
      enable = true;
    };
    git = {
      enable = true;
      userName = env.nixUser;
      userEmail = env.nixUserEmail;
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

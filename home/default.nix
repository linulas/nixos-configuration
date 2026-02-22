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
      bacon
      brave
      bruno
      cargo
      clippy
      csharp-ls
      delve
      discord
      dotnet-sdk_8
      drum-machine
      feh
      fzf
      geonkick
      go
      gopls
      grim
      hydrogen
      hyprpaper
      jdk25
      lazygit
      lua-language-server
      lutris
      marksman
      multiviewer-for-f1
      neofetch
      netcoredbg
      nexusmods-app-unfree
      nixpkgs-fmt
      nodejs_24
      obsidian
      odin2
      playerctl
      prettierd
      protontricks
      reaper
      rust-analyzer
      rustfmt
      rustc
      slurp
      spotify
      stylua
      surge-XT
      synergy
      steamtinkerlaunch
      telegram-desktop
      tutanota-desktop
      vial
      vital
      vlc
      wget
      nodePackages.svelte-language-server
      nodePackages.typescript-language-server
      vscode-langservers-extracted
      zynaddsubfx
    ];

    file = {
      ".config/kitty/kitty.conf".source = ./config/kitty/kitty.conf;
      ".config/kitty/tab_bar.py".source = ./config/kitty/tab_bar.py;
      ".config/waybar/config.jsonc".source = ./config/waybar/waybar.jsonc;
      ".config/waybar/style.css".source = ./config/waybar/waybar_style.css;
      ".config/waybar/launch_menu.sh".source = ./config/waybar/launch_menu.sh;
      ".config/waybar/display_spotify_song.sh".source = ./config/waybar/display_spotify_song.sh;
      ".config/hypr/hyprland.conf".source = ./config/hyprland/hyprland.conf;
      ".config/hypr/hyprpaper.conf".source = ./config/hyprland/hyprpaper.conf;
      ".config/hypr/apps.conf".source = ./config/hyprland/hyprapps_default.conf;
      ".config/hypr/run_or_focus_application.sh".source = ./config/hyprland/run_or_focus_application.sh;
      ".config/hypr/1.png".source = ./config/hyprland/wallpaper/1.png;
      ".config/hypr/2.png".source = ./config/hyprland/wallpaper/2.png;
      ".config/REAPER/ColorThemes/Beatwing_v2_5.ReaperThemeZip".source = ./config/reaper/Beatwing_v2_5.ReaperThemeZip;
      ".local/share/applications/nvim.desktop".source = ./config/nvim.desktop;
    };
  };

  programs = {
    btop = {
      enable = true;
    };

    firefox = {
      enable = true;
      profiles.default = {
        isDefault = true;
        settings = {
          "browser.sessionstore.resume_from_crash" = true;
          "browser.sessionstore.interval" = 15000;
          "browser.startup.page" = 3;
        };
      };
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = env.nixUser;
          email = env.nixUserEmail;
        };
        init.defaultBranch = "main";
        credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

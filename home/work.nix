{ pkgs, ... }:
let
  env = import ./local/env.nix; # NOTE: Untracked file, must be added manually
in
{
  home = {
    stateVersion = "23.11";
    username = env.nixWorkUser;
    homeDirectory = "/home/${env.nixWorkUser}";

    packages = with pkgs; [
      bacon
      brave
      cargo
      clippy
      bruno
      csharp-ls
      delve
      dotnet-sdk_8
      grim
      go
      gopls
      lazygit
      lua-language-server
      marksman
      neofetch
      netcoredbg
      nixpkgs-fmt
      nodejs_22
      obsidian
      prettierd
      postman
      redis
      redisinsight
      rust-analyzer
      rustfmt
      slack
      spotify
      stylua
      slurp
      teams-for-linux
      tutanota-desktop
      nodePackages.svelte-language-server
      nodePackages.typescript-language-server
      vscode-langservers-extracted
    ];

    file = {
      ".config/kitty/kitty.conf".source = ./config/kitty/kitty.conf;
      ".config/kitty/tab_bar.py".source = ./config/kitty/tab_bar.py;
      ".config/waybar/config.jsonc".source = ./config/waybar/waybar.jsonc;
      ".config/waybar/display_spotify_song.sh".source = ./config/waybar/display_spotify_song.sh;
      ".config/waybar/style.css".source = ./config/waybar/waybar_style.css;
      ".config/waybar/launch_menu.sh".source = ./config/waybar/launch_menu.sh;
      ".config/hypr/hyprland.conf".source = ./config/hyprland/hyprland.conf;
      ".config/hypr/apps.conf".source = ./config/hyprland/hyprapps_work.conf;
      ".config/hypr/run_or_focus_application.sh".source = ./config/hyprland/run_or_focus_application.sh;
      ".local/share/applications/nvim.desktop".source = ./config/nvim.desktop;
    };
  };

  programs = {
    btop = {
      enable = true;
    };
    git = {
      enable = true;
      extraConfig = {
        url."git@ssh.dev.azure.com:v3/sida-development/sida.se/dotnet-common".insteadOf = "https://dev.azure.com/sida-development/sida.se/_git/dotnet-common";
      };
      settings = {
        user = {
          name = env.nixUser;
          email = env.nixWorkUserEmail;
        };
        credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
      };
    };
    obs-studio = {
      enable = true;

      # optional Nvidia hardware acceleration
      package = (
        pkgs.obs-studio.override {
          cudaSupport = true;
        }
      );

      plugins = with pkgs.obs-studio-plugins; [
        droidcam-obs
      ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}


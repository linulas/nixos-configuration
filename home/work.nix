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
      brave
      bruno
      csharp-ls
      delve
      dotnet-sdk_8
      go
      gopls
      lazygit
      lua-language-server
      marksman
      neofetch
      netcoredbg
      nixpkgs-fmt
      nodejs_20
      nvitop
      obsidian
      prettierd
      postman
      rustup
      slack
      spotify
      stylua
      teams-for-linux
      tutanota-desktop
      nodePackages.svelte-language-server
      nodePackages.typescript-language-server
      vscode-langservers-extracted
    ];

    file = {
      ".config/kitty/kitty.conf".source = ./config/kitty.conf;
      ".config/waybar/config.jsonc".source = ./config/waybar/waybar.jsonc;
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
      userName = env.nixUser;
      userEmail = env.nixWorkUserEmail;
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


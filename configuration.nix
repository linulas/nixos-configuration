{ inputs, pkgs, pkgsUnstable, ... }:

let
  env = import ./home/local/env.nix; # NOTE: Untracked file, must be added manually
in
{
  imports =
    [
      ./hardware-configuration.nix # NOTE: Untracked file, must be added manually
      ./home/local/secrets # NOTE: Untracked module, must be added manually
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest; # Must have for networking to work with newer AMD motherboards

  home-manager = {
    extraSpecialArgs = { inherit inputs pkgs; };
    users = {
      "${env.nixUser}" = import ./home/default.nix;
    };
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = env.tcpPorts;
      allowedUDPPorts = env.udpPorts;
      extraCommands = ''
        iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
        iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
      '';
    };
    extraHosts = env.hosts;
    hostName = env.hostName;
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "sv_SE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "en_US.utf8"; # required by dmenu don't change this
  };

  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "soft";
      item = "rtprio";
      value = "95";
    }
    {
      domain = "@audio";
      type = "hard";
      item = "rtprio";
      value = "99";
    }
    {
      domain = "@audio";
      type = "soft";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@audio";
      type = "hard";
      item = "memlock";
      value = "unlimited";
    }
  ];

  powerManagement.cpuFreqGovernor = "performance";

  services = {
    xserver = {
      enable = true;
      xkb = {
        variant = "";
        layout = "se";
      };
      excludePackages = [ pkgs.xterm ];
      videoDrivers = [ "nvidia" ];
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
  };

  console.keyMap = "sv-latin1";

  users = {
    defaultUserShell = pkgs.zsh;
    users."${env.nixUser}" = {
      isNormalUser = true;
      description = env.nixUser;
      extraGroups = [ "networkmanager" "wheel" "docker" "audio" "video" "storage" "plugdev" ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
      pulseaudio = true;
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    pkgsUnstable._1password-cli
    pkgsUnstable._1password-gui
    bottles
    carla
    dmenu
    docker
    dunst
    fd
    firefox
    gcc
    gnome-keyring
    gparted
    home-manager
    hyprlock
    hyprpolkitagent
    kitty
    jack_capture
    libnotify
    libsecret
    lm_sensors
    mangohud
    pkgsUnstable.neovim
    networkmanagerapplet
    nil
    nitrogen
    pasystray
    protonup
    pulseaudioFull
    pwvucontrol
    qjackctl
    qpwgraph
    ripgrep
    sops
    # rocmPackages.llvm.lldb
    xclip
    ulauncher
    unrar
    unzip
    zsh-powerlevel10k
  ];

  environment.variables =
    let
      makePluginPath = format:
        (pkgs.lib.makeSearchPath format [
          "$HOME/.nix-profile/lib"
          "/run/current-system/sw/lib"
          "/etc/profiles/per-user/$USER/lib"
        ])
        + ":$HOME/.${format}";
    in
    {
      DSSI_PATH = makePluginPath "dssi";
      LADSPA_PATH = makePluginPath "ladspa";
      LV2_PATH = makePluginPath "lv2";
      LXVST_PATH = makePluginPath "lxvst";
      VST_PATH = makePluginPath "vst";
      VST3_PATH = makePluginPath "vst3";
      EDITOR = "nvim";
      VISUAL = "nvim";
      STEAM_EXTRA_COMPAT_TOOLS_PATHS =
        "/home/${env.nixUser}/.steam/root/compatibilitytools.d";
    };

  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.droid-sans-mono
  ];

  programs = {
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    };
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      xwayland.enable = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      shellAliases = {
        update = "sudo nixos-rebuild switch --flake path:${env.rootFlakePath}#default";
        updatehome = "home-manager switch --flake path:${env.rootFlakePath}/home";
        upgrade = "sudo nix flake update ${env.rootFlakePath} && update";
        upgradehome = "nix flake update ${env.rootFlakePath}/home && updatehome";
      };
    };

    # Gaming
    gamemode.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth.enable = true;
    nvidia = {
      open = true;
      modesetting.enable = true;
    };
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

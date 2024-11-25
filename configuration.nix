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

  sound.enable = true;

  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
      enable = true;
      xkb = {
        variant = "";
        layout = "se";
      };
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3status
        ];
      };
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      displayManager = {
        lightdm.enable = true;
      };
    };
    displayManager = {
      defaultSession = "xfce+i3";
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
    };
  };

  console.keyMap = "sv-latin1";

  users = {
    defaultUserShell = pkgs.zsh;
    users."${env.nixUser}" = {
      isNormalUser = true;
      description = env.nixUser;
      extraGroups = [ "networkmanager" "wheel" "docker" ];
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
    pkgsUnstable._1password-cli
    pkgsUnstable._1password-gui
    bottles
    dmenu
    docker
    fd
    firefox
    gcc
    gnome.gnome-keyring
    gparted
    home-manager
    kitty
    libsecret
    lm_sensors
    mangohud
    nerdfonts
    pkgsUnstable.neovim
    networkmanagerapplet
    nil
    nitrogen
    pasystray
    picom
    polkit_gnome
    protonup
    pulseaudioFull
    ripgrep
    rofi
    sops
    rocmPackages.llvm.lldb
    xclip
    unrar
    unzip
    zsh-powerlevel10k
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "/home/${env.nixUser}/.steam/root/compatibilitytools.d";
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  programs = {
    thunar.enable = true;
    dconf.enable = true;
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

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  hardware = {
    bluetooth.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia.modesetting.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

{ inputs, pkgs, pkgsUnstable, config, ... }:

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
    systemd-boot.configurationLimit = 15;
    efi.canTouchEfiVariables = true;
  };

  # Pinned to the default stable kernel: linuxPackages_latest (7.2.x) broke the
  # nvidia 595.71.05 module build (implicit strncpy / missing <string.h>).
  boot.kernelPackages = pkgs.linuxPackages;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.kernelModules = [ "v4l2loopback" ];
  # Blacklist the kernel ntfs3 driver so udisks2 mounts NTFS volumes with the
  # tolerant ntfs-3g (FUSE) helper. ntfs3 refuses dirty volumes left behind by
  # Windows Fast Startup with: volume is dirty and "force" flag is not set.
  boot.blacklistedKernelModules = [ "ntfs3" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';

  home-manager = {
    extraSpecialArgs = { inherit inputs pkgs; };
    backupFileExtension = "backup";
    users = {
      "${env.nixUser}" = import ./home/default.nix;
      "${env.nixWorkUser}" = import ./home/work.nix;
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

  security = {
    pam = {
      loginLimits = [
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

      services.greetd.enable = true;
    };

  };

  powerManagement.cpuFreqGovernor = "performance";

  services = {
    usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
    gvfs.enable = true;
    udisks2.enable = true;
    gnome.gnome-keyring.enable = true;
    blueman.enable = true;
    hardware.openrgb.enable = true;
    logind.settings.Login.HandlePowerKey = "suspend";

    displayManager.gdm = {
      enable = true;
    };

    xserver = {
      enable = true;
      xkb = {
        variant = "";
        layout = "se,us";
      };
      excludePackages = [ pkgs.xterm ];
      videoDrivers = [ "nvidia" ];
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

      # Logitech/Saitek X52 & X52 Pro HOTAS - Joystick tagging
      SUBSYSTEM=="input", ATTRS{idVendor}=="06a3", ATTRS{idProduct}=="0255", MODE="0666", ENV{ID_INPUT_JOYSTICK}="1"
      SUBSYSTEM=="input", ATTRS{idVendor}=="06a3", ATTRS{idProduct}=="075c", MODE="0666", ENV{ID_INPUT_JOYSTICK}="1"
      SUBSYSTEM=="input", ATTRS{idVendor}=="06a3", ATTRS{idProduct}=="0762", MODE="0666", ENV{ID_INPUT_JOYSTICK}="1"

      # Raw HID access for advanced MFD/LED control (e.g., via libx52)
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="06a3", ATTRS{idProduct}=="0255", MODE="0666"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="06a3", ATTRS{idProduct}=="075c", MODE="0666"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="06a3", ATTRS{idProduct}=="0762", MODE="0666"
    '';

    openvpn.servers = {
      switzerland = {
        autoStart = false;
        config = ''
          config ${env.ovpn_switzerland_path}
          auth-user-pass ${config.sops.secrets.ovpn_switzerland_credentials.path}
        '';
      };
    };
  };

  console.keyMap = "sv-latin1";

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      "${env.nixUser}" = {
        isNormalUser = true;
        description = env.nixUser;
        extraGroups = [ "networkmanager" "wheel" "docker" "audio" "video" "storage" "plugdev" ];
      };
      "${env.nixWorkUser}" = {
        isNormalUser = true;
        description = env.nixWorkUser;
        extraGroups = [ "networkmanager" "wheel" "docker" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    pkgsUnstable._1password-cli
    pkgsUnstable._1password-gui
    bottles
    carla
    pkgsUnstable.claude-code
    claude-agent-acp
    dmenu
    docker
    dunst
    fd
    file-roller
    gamemode
    gcc
    gnome-keyring
    gparted
    home-manager
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    hyprlock
    hyprpolkitagent
    kitty
    jack_capture
    libnotify
    libsecret
    lm_sensors
    mangohud
    mesa
    ntfs3g
    nvitop
    pkgsUnstable.neovim
    networkmanagerapplet
    nil
    nitrogen
    pasystray
    protonup-ng
    pwvucontrol
    qjackctl
    qpwgraph
    ripgrep
    sops
    thunar-archive-plugin
    thunar-volman
    tree-sitter
    xclip
    pkgsUnstable.ulauncher
    unrar
    unzip
    vulkan-tools
    wl-clipboard
    wineWow64Packages.wayland
    zsh-powerlevel10k
    libimobiledevice
    ifuse # optional, to mount using 'ifuse'

    # Strip ambient cap_sys_nice (inherited from the Hyprland wrapper) before
    # launching Steam, otherwise Steam's bundled bwrap 0.11+ aborts with:
    #   "Unexpected capabilities but not setuid, old file caps config?"
    (writeShellScriptBin "steam" ''
      exec ${util-linux}/bin/setpriv --ambient-caps -all -- \
        ${config.programs.steam.package}/bin/steam "$@"
    '')
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

  fonts.packages = [ pkgs.nerd-fonts.sauce-code-pro ];

  programs = {

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        glibc
        libcxx
      ];
    };
    thunar = {
      enable = true;
    };

    waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    };
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland;
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
        # Update all inputs except the Claude-related pins (nixpkgs-2505, claude-desktop).
        upgrade = "sudo nix flake update nixpkgs nixpkgs-unstable hyprland sops-nix home-manager zen-browser --flake ${env.rootFlakePath} && update";
        upgrade-unstable = "sudo nix flake update nixpkgs-unstable --flake ${env.rootFlakePath} && update";
        upgradehome = "nix flake update nixpkgs --flake ${env.rootFlakePath}/home && updatehome";
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

    # The Hyprland module wraps the binary with ambient cap_sys_nice so the
    # compositor can give itself realtime priority. Ambient capabilities are
    # inherited by every app launched from Hyprland, and the kernel then
    # denies the (capability-less) xdg-desktop-portal ptrace access to those
    # processes, so the portal rejects every request — file/folder pickers
    # (Obsidian "open folder" etc.) silently do nothing. Drop the capability;
    # Hyprland just falls back to normal scheduling.
    wrappers.Hyprland.capabilities = pkgs.lib.mkForce "";
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
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-tools
        vulkan-headers
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vulkan-loader
      ];
    };
    bluetooth.enable = true;
    nvidia = {
      open = true;
      modesetting.enable = true;
      nvidiaSettings = true;
      powerManagement = {
        enable = true;
      };
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

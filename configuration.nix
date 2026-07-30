# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

let
  bottles-native = (pkgs.bottles.override{removeWarningPopup = true;});
  handwrite = pkgs.callPackage ./fonts/fonts.nix {};
  thorium = inputs.thorium.packages.${pkgs.stdenv.hostPlatform.system}.thorium-avx2;
  trid = pkgs.callPackage ./programs/trid.nix { inherit inputs; };
  whisper-cpp-cuda = (pkgs.whisper-cpp.override{cudaSupport = true;});
  xxd = pkgs.unixtools.xxd;
  proton-cachyos = inputs.nix-proton-cachyos.packages.${pkgs.stdenv.hostPlatform.system}.proton-cachyos;
in

{
  imports =
    [ 
      ./hardware-configuration.nix # Include the results of the hardware scan
      inputs.home-manager.nixosModules.default # Home-Manager
      #inputs.nix-flatpak.nixosModules.nix-flatpak # nix-flatpak
    ];

  boot = {
    # Bootloader
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        extraInstallCommands = ''
          ${pkgs.coreutils}/bin/rm -f /boot/EFI/BOOT/BOOTX64.EFI
        '';
      };
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    # Use custom cachyos kernel
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-x86_64-v3; # Can't use lto version because it is compiled with clang instead of gcc and vmware kernel modules are not compatable with clang
    initrd.kernelModules = [ "amdgpu" ];
    kernelParams = [ "amd_pstate=active" ];
    kernel.sysctl = {
      "kernel.yama.ptrace_scope" = 0;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;

    # Enable OpenGL/Graphics
    graphics.enable = true;
    graphics.enable32Bit = true;

    # Enable bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true; # Shows battery charge on supported adapters
          FastConnectable = true; # Faster connections, higher power consumption
        };
        Policy = {
          AutoEnable = true; # Enable all controllers when found
        };
      };
    };

    nvidia = {
      # Modesetting is required
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail
      powerManagement.enable = true;
      # Fine-grained power management. Turns off GPU when not in use
      powerManagement.finegrained = true;

      # Use the NVidia open source kernel module (not to be confused with the
      # nouveau open source driver). Only available on driver 515.43.04+
      # Support is limited to Turing and newer GPUs (GTX 1650 Ti is Turing)
      open = false;

      # Enable the Nvidia settings menu, accessible via `nvidia-settings`
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # PRIME settings for Hybrid Graphics
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        amdgpuBusId = "PCI:5:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  networking = {
    hostName = "emerald"; # Define your hostname

    # Enable DNS
    nameservers = [ "1.1.1.1#cloudflare-dns.com" "1.0.0.1#cloudflare-dns.com" ];

    # Enable networking
    networkmanager.enable = true;
    networkmanager.dns = "systemd-resolved";
  };

  # Set your time zone
  time.timeZone = "Europe/Minsk";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  # Define a user account
  users.users.vlryz = {
    isNormalUser = true;
    description = "vlryz";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    useDefaultShell = true;
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "vlryz" = import ./home.nix;
    };
  };

  security = {
    sudo.wheelNeedsPassword = false; # Disable prompting for password when using sudo
    rtkit.enable = true; # Required for pipewire
  };

  # Install programs that need additional configurations
  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batwatch
      ];
      settings = {
        theme = "Visual Studio Dark+";
        paging = "never";
      };
    };
    git.enable = true;
    kdeconnect.enable = true;
    neovim.enable = true;
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-backgroundremoval
      ];
    };
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
        proton-cachyos
      ];
      package = pkgs.millennium-steam;
    };
    ydotool.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };

  nixpkgs = {
    # Allow unfree packages
    config.allowUnfree = true;
    overlays = [
      inputs.millennium.overlays.default # Required for millenium
      inputs.nix-cachyos-kernel.overlays.pinned # Required for CachyOS kernel
    ];
  };

  environment = {
    # Not install not needed pacakges
    defaultPackages = [];
    # Install programs that don't need additional configuration (just binaries)
    systemPackages = with pkgs; [
      alsa-utils
      android-tools
      antigravity-cli
      asusctl
      audacity
      bastet
      bc
      #bottles-native
      broot
      btop-cuda
      cbonsai
      cmatrix
      davinci-resolve
      easyeffects
      evtest
      eza
      fastfetch
      ffmpeg-full
      figlet
      floorp-bin
      fortune
      fzf
      gcc
      imagemagick
      kdePackages.kalgebra
      kdePackages.kcalc
      kdotool
      kid3-kde
      kitty
      lolcat
      masterpdfeditor4
      mp3gain
      neo-cowsay
      nudoku
      pince
      piper-tts
      powershell
      python315
      qbittorrent
      rust-stakeholder
      sl
      strawberry
      tealdeer
      thorium
      toilet
      tree
      trid
      unar
      units
      vlc
      vscode
      wget
      whisper-cpp-cuda
      wl-clipboard
      wpsoffice-cn
      xxd
      yt-dlp
    ];

    # Change enviromental variables
    variables = {
      EDITOR = "nvim";
      HISTCONTROL = "erasedups";
      PROMPT_EOL_MARK = "";
      NIX_AUTO_RUN = 1;
      NIX_AUTO_RUN_INTERACTIVE = 1;
      # PROMPT_COMMAND = "echo -ne '\\e[A'"; # Fixes bash spacing between lines, currently ins't needed because zsh is the default shell

      # Make man pages colorful
      LESS_TERMCAP_mb = "[1;36m";   # [0m]] (these comments are needed so nothing
      LESS_TERMCAP_md = "[1;36m";   # [0m]] breaks from having an unclosed bracket
      LESS_TERMCAP_me = "[0m";      # [0m]] and so output doesn't get colorized)
      LESS_TERMCAP_se = "[0m";      # [0m]]
      LESS_TERMCAP_so = "[0;1m";    # [0m]]
      LESS_TERMCAP_ue = "[0m";      # [0m]]
      LESS_TERMCAP_us = "[4;1;32m"; # [0m]]
      LESS_TERMCAP_mr = "[7m";      # [0m]]
      LESS_TERMCAP_mh = "[2m";      # [0m]]
      LESS_TERMCAP_ZN = "[74m";     # [0m]]
      LESS_TERMCAP_ZV = "[75m";     # [0m]]
      LESS_TERMCAP_ZO = "[73m";     # [0m]]
      LESS_TERMCAP_ZW = "[75m";     # [0m]]
      GROFF_NO_SGR = 1;
    };

    shellAliases = {
      # Format: "aliasName" = "command to run";
      cat = "bat";
      cd = "z";
      cdd = "cd /home/vlryz/Downloads";
      cdl = "cd /home/vlryz/Important/Legendary";
      cp = "cp -i";
      cdn = "cd /etc/nixos";
      copy = "wl-copy";
      dt = "date +'%A, %B %d %Y %H:%M:%S.%N'";
      l = "eza --icons --group-directories-first -lah";
      la = "eza --icons --group-directories-first -a";
      ll = "eza --icons --group-directories-first -la";
      ls = "eza --icons --group-directories-first";
      lsa = "eza --icons --group-directories-first -lah";
      mv = "mv -i";
      no = "curl -s https://naas.isalman.dev/no | cut -c 12- | rev | cut -c 3- | rev";
      parrot = "python ~/.parrot.py";
      paste = "wl-paste";
      rebuild = "bash ~/Important/Legendary/rebuild.sh"; # Script that automatically handles configuration backups
      rr = "python ~/.rr.py";
      ffmpeg = "ffmpeg -hide_banner";
    };
    plasma6.excludePackages = with pkgs.kdePackages; [
      qrca
      elisa
      ark
      discover
      khelpcenter
      konsole
      okular
    ];
  };

  # Install custom fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      corefonts
      handwrite
      nerd-fonts.jetbrains-mono
      noto-fonts-cjk-serif
      ubuntu-sans-mono
      vista-fonts
    ];
  };

  # List services that you want to enable:
  services = {
    # Enable the KDE Plasma Desktop Environment
    desktopManager.plasma6.enable = true;

    # Enable the KDE Plasma Login Manager
    displayManager = {
      plasma-login-manager.enable = true;
      autoLogin.user = "vlryz"; # Disable prompting for password on boot
    };

    # Additional DNS settings
    resolved = {
      enable = true;
      settings.Resolve = {
        DNSOverTLS = "true";
        Domains = [ "~." ];
        FallbackDNS = [ "1.1.1.1#cloudflare-dns.com" "1.0.0.1#cloudflare-dns.com" ];
      };
    };

    # Enable sound with pipewire
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable the X11 windowing system
    # You can disable this if you're only using the Wayland session
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      # Load nvidia driver for Xorg and Wayland
      videoDrivers = [ "nvidia" "amdgpu" ];
    };

    # Enable the OpenSSH daemon
    # openssh.enable = true;

    # Enables ability to switch between power profiles (power save, balanced, performance)
    power-profiles-daemon.enable = true;

    # Additional requierements for bluetooth
    blueman.enable = true;

    # Enable Flatpak service
    flatpak = {
      enable = true;
      #packages = [
      #  "io.github.Soundux"
        #"com.usebottles.bottles"
      #];
      #update.onActivation = true; # Auto-update on rebuild
      #uninstallUnmanaged = true;
      #overrides.settings = {
        #global = {
          # Force Wayland by default
        #  Context.sockets = ["wayland" "!x11" "!fallback-x11"];
        #  Environment = {
        #    # Fix un-themed cursor in some Wayland apps
        #    XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
            # Force correct theme for some GTK apps
        #    GTK_THEME = "Adwaita:dark";
        #  };
        #};
        #"io.github.Soundux".Context = {
        #  filesystems = [
        #    "home:ro"
        #  ];
        #};
        #"com.usebottles.bottles".Context = {
        #  filesystems = [
        #    "home"
        #  ];
        #};
      #};
    };
  };

  # Required for Flatpak desktop integration
  xdg.portal.enable = true;

  # Install vmware
  virtualisation.vmware.host.enable = true;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
      connect-timeout = 0;
      experimental-features = [ "nix-command" "flakes" ];
      stalled-download-timeout = 0;
      warn-dirty = false;
    };
  };

  #system.autoUpgrade = {
  #  enable = true;
  #  flake = "/etc/nixos/flake.nix";
  #  flags = [
  #    "--print-build-logs"
  #    "--commit-lock-file"  # Automatically commits updated flake.lock
  #  ];
  #  dates = "02:00";
  #  randomizedDelaySec = "45min";
  #  allowReboot = false;
  #};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

let
  bottles-native = (pkgs.bottles.override{removeWarningPopup = true;});
  cowsay-more-cows = pkgs.cowsay.overrideAttrs (prev: { src = lib.fileset.toSource { root = ./.; fileset = lib.fileset.unions [ ./configs/cowsay/cows ]; }; installPhase = prev.installPhase + "mkdir -p $out/share/cowsay/cows; cp ./cows/*.cow $out/share/cowsay/cows/"; });
  handwrite = pkgs.callPackage ./fonts/fonts.nix {};
  kalgebra = pkgs.kdePackages.kalgebra;
  kcalc = pkgs.kdePackages.kcalc;
  proton-cachyos = inputs.nix-proton-cachyos.packages.${pkgs.stdenv.hostPlatform.system}.proton-cachyos;
  thorium = inputs.thorium.packages.${pkgs.stdenv.hostPlatform.system}.thorium-avx2;
  trid = pkgs.callPackage ./programs/trid.nix { inherit inputs; };
  whisper-cpp-cuda = (pkgs.whisper-cpp.override{cudaSupport = true;});
  xxd = pkgs.unixtools.xxd;
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

      # Latest driver for more performance
      branch = "latest";

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
      extraPackages = [ pkgs.kdePackages.breeze ];
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
      cowsay-more-cows
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
      kalgebra
      kcalc
      kdotool
      kid3-kde
      kitty
      lolcat
      masterpdfeditor4
      mp3gain
      nmap
      nudoku
      pince
      piper-tts
      playerctl
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

      LS_COLORS = "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.7z=01;31:*.ace=01;31:*.alz=01;31:*.apk=01;31:*.arc=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cab=01;31:*.cpio=01;31:*.crate=01;31:*.deb=01;31:*.drpm=01;31:*.dwm=01;31:*.dz=01;31:*.ear=01;31:*.egg=01;31:*.esd=01;31:*.gz=01;31:*.jar=01;31:*.lha=01;31:*.lrz=01;31:*.lz=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.lzo=01;31:*.pyz=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.swm=01;31:*.t7z=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.tzo=01;31:*.tzst=01;31:*.udeb=01;31:*.war=01;31:*.whl=01;31:*.wim=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.zst=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.jxl=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:"; # Shamelessly stolen from oh-my-zsh
    };

    shellAliases = {
      # Format: "aliasName" = "command to run";
      cat = "bat";
      cd = "z";
      cdd = "cd /home/vlryz/Downloads";
      cdl = "cd /home/vlryz/Important/Legendary";
      cdn = "cd /etc/nixos";
      copy = "wl-copy";
      cp = "cp -i";
      dt = "date +'%A, %B %d %Y %H:%M:%S.%N'";
      ffmpeg = "ffmpeg -hide_banner";
      ffprobe = "ffprobe -hide_banner";
      grep = "grep --color=auto";
      l = "eza --icons --group-directories-first --short-nix -lh";
      la = "eza --icons --group-directories-first --short=nix -a";
      ll = "eza --icons --group-directories-first -la";
      ls = "eza --icons --group-directories-first --short-nix";
      mv = "mv -i";
      no = "curl -s https://naas.isalman.dev/no | cut -c 12- | rev | cut -c 3- | rev";
      parrot = "python ~/.parrot.py";
      paste = "wl-paste";
      rebuild = "bash ~/Important/Legendary/rebuild.sh"; # Script that automatically handles configuration backups
      rr = "python ~/.rr.py";
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
      };
    };

    # Enable sound with pipewire
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
      download-attempts = 0;
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = "auto";
      stalled-download-timeout = 0;
      warn-dirty = false;

      # Binary cache for cachyos kernel
      substituters = [ "https://attic.xuyh0120.win/lantian" ];
      trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
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

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
in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      #inputs.nix-flatpak.nixosModules.nix-flatpak
    ];

  # Bootloader.
  boot.loader = { 
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


  # Use latest kernel.
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-x86_64-v3;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [ "amd_pstate=active" ];
  boot.kernel.sysctl = {
    "kernel.yama.ptrace_scope" = 0;
  };
  
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  hardware.enableRedistributableFirmware = true;

  # Enable OpenGL/Graphics
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Enable bluetooth
  # hardware.bluetooth.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # Shows battery charge on supported adapters
        FastConnectable = true; # Faster connections, higher power consumption
      };
      Policy = {
        AutoEnable = true; # Enable all controllers when found
      };
    };
  };
 
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
 
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # nouveau open source driver). Only available on driver 515.43.04+
    # Support is limited to Turing and newer GPUs (GTX 1650 Ti is Turing).
    open = false;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # PRIME settings for Hybrid Graphics
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  
  # Enable DNS
  networking.nameservers = [ "1.1.1.1#cloudflare-dns.com" "1.0.0.1#cloudflare-dns.com" ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  services.resolved = {
    enable = true;
    settings.Resolve.DNSOverTLS = "true";
    settings.Resolve.Domains = [ "~." ];
    settings.Resolve.FallbackDNS = [ "1.1.1.1#cloudflare-dns.com" "1.0.0.1#cloudflare-dns.com" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Minsk";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable the KDE Plasma Login Manager
  services.displayManager = {
    plasma-login-manager.enable = true;
    autoLogin.user = "vlryz"; # Disable prompting for password on boot
  };
  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    qrca
    elisa
    ark
    discover
    khelpcenter
    konsole
    okular
  ];

  # Configure keymap in X11
  #services.xserver.xkb = {
    # Set multiple layouts separated by commas
  #  layout = "us,ru";
    
    # Optional: Match variants with layouts, also comma-separated
    # variant = ",typewriter";
    
    # Set the key combination to switch layouts (e.g., Alt+Shift)
    # options = "grp:ctrl_shift_toggle";
    # options = "grp:ctrl_space_toggle"; # It is broken, breaks a lot of other hotkeys, I have having to use multiple keyboard layouts, currently only systray button works for switching layouts.
  #};
  

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.settings.General.Enable = "Source,Sink,Media,Socket";   

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vlryz = {
    isNormalUser = true;
    description = "vlryz";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  users.users.vlryz.shell = pkgs.zsh;
  users.users.vlryz.useDefaultShell = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "vlryz" = import ./home.nix;
    };
  };
  
  # Disable prompting for password when using sudo
  security.sudo.wheelNeedsPassword = false;
  
  # Install programs
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ 
      proton-ge-bin
    ];
    package = pkgs.millennium-steam;
  };
  programs.ydotool.enable = true;
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
    ];
  };
  programs.zoxide.enable = true;
  programs.zsh.enable = true;
  programs.neovim.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.millennium.overlays.default inputs.nix-cachyos-kernel.overlays.pinned ]; # Required for millenium and CachyOS kernel

  # List packages installed in system profile.
  environment.defaultPackages = [];
  environment.systemPackages = with pkgs; [
    alsa-utils
    android-tools
    antigravity-cli
    asusctl
    audacity
    bastet
    bat
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
    git
    imagemagick
    kdePackages.kalgebra
    kdePackages.kcalc
    kdotool
    kid3-kde
    kitty
    lolcat
    mangohud
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

  # Change enviromental variables
  environment.variables = {
    EDITOR = "nvim";
    HISTCONTROL = "erasedups";
    PROMPT_EOL_MARK = "";
    # environment.variables.PROMPT_COMMAND = "echo -ne '\\e[A'"; # Fixes bash spacing between lines, currently ins't needed because zsh is the default shell

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

  environment.shellAliases = {
    # Format: "aliasName" = "command to run";
    cat = "bat --theme 'Visual Studio Dark+'";
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
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services.power-profiles-daemon.enable = true;

  services.blueman.enable = true;

  # Enable Flatpak service
  services.flatpak = {
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

  # Required for Flatpak desktop integration
  xdg.portal.enable = true;

  # Install vmware
  virtualisation.vmware.host.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings = {
    warn-dirty = false;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
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
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}

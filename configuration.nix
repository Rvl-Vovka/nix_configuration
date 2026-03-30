# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # Import the unstable channel
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in

let
  # Pull the Thorium flake directly
  thorium = (builtins.getFlake "github:Rishabh5321/custom-packages-flake");
  # Choose the AVX2 version for Ryzen 7 4800H
  thorium-pkg = thorium.packages.${pkgs.stdenv.hostPlatform.system}.thorium-avx2;
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [ "amd_pstate=active" ];
  boot.extraModprobeConfig = ''
    # alc256-headset-multi is the most modern version for ALC256 combo jacks.
    options snd-hda-intel model=alc256-headset-multi position_fix=1
  '';

  # Create the hardware patch to "re-wire" the ALC256 pins.
  hardware.firmware = [
    (pkgs.writeTextDir "lib/firmware/hda-jack-retask.fw" ''
      [codec]
      # Corrected Subsystem ID for the Realtek card: 1043:1a0e
      0x10ec0256 0x10431a0e 0

      [pincfg]
      # Node 0x19 (Source): Force to "Mic In" WITHOUT Jack Detect (0x01a19020)
      # This forces the "Headset Microphone" to always be seen as plugged in.
      0x19 0x01a19020
      # Node 0x21 (Output): Restore as Headphones (0x01211010)
      0x21 0x01211010
    '')
  ];

  # Force WirePlumber to use a Microphone-only profile for this card
  services.pipewire.wireplumber.extraConfig."10-mic-only-profile" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "node.name" = "alsa_card.pci-0000_05_00.6";
          }
        ];
        actions = {
          update-props = {
            "device.profile" = "input:analog-stereo";
          };
        };
      }
    ];
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable OpenGL/Graphics
  hardware.graphics.enable = true;

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
  services.xserver.videoDrivers = ["nvidia"];
 
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
    dnsovertls = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1#cloudflare-dns.com" "1.0.0.1#cloudflare-dns.com" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Minsk";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    # Set multiple layouts separated by commas
    layout = "us,ru";
    
    # Optional: Match variants with layouts, also comma-separated
    # variant = ",typewriter";
    
    # Set the key combination to switch layouts (e.g., Alt+Shift)
    # options = "grp:ctrl_shift_toggle";
    options = "grp:ctrl_shift_toggle";
  };
  

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
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };
  
  # Disable prompting for password when using sudo
  security.sudo.wheelNeedsPassword = false;
  
  # Install firefox.
  # programs.firefox.enable = true;
  programs.gamemode.enable = true;
  programs.steam.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    #wget
    floorp-bin
    android-tools
    fastfetch
    yt-dlp
    git
    unstable.powershell
    python315
    #kitty
    micro
    msedit
    unstable.gemini-cli
    zoxide
    obs-studio
    cbonsai
    nudoku
    #htop
    btop
    eza
    bat
    neo-cowsay
    figlet
    toilet
    sl
    lolcat
    fortune
    ffmpeg
    #haruna
    xsel
    pciutils
    asusctl
    #alacritty
    bluez
    thorium-pkg
    strawberry
    mpv
    #protonvpn-gui
    #dnslookup
    lsof
    mesa-demos
    vscode
    alsa-utils
    alsa-tools
    tauon
  ];

  # Change enviromental variables
  environment.variables.EDITOR = "nvim";

  environment.shellAliases = {
    # Format: "aliasName" = "command to run";
    copy = "xsel --input --clipboard";
    paste = "xsel --output --clipboard";
    cdd = "cd /home/vlryz/Downloads";
    cdl = "cd /home/vlryz/Important/Legendary";
    rebuild = "~/rebuild.sh";
    n = "nvidia-offload";
    vim = "nvim";
    no = "curl -s https://naas.isalman.dev/no | cut -c 12- | rev | cut -c 3- | rev";
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
  # Disable prompting for password on boot
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "vlryz";

  services.asusd.enable = true;
  services.asusd.enableUserService = true;

  services.power-profiles-daemon.enable = true;

  services.blueman.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  # Automate audio fix AFTER login (prevents PipeWire/KDE from resetting it).
  systemd.user.services.fix-audio-gain = {
    description = "Force microphone alive and static-free";
    wantedBy = [ "default.target" ];
    script = ''
      # Loop for 10 seconds to fight against KDE/PipeWire auto-muting
      for i in {1..10}; do
        # 1. Force hardware VREF power on Node 0x19 (the 3.5mm mic jack)
        # 0x25 = Enable Input + 100% Bias Power (Strongest power for mics)
        ${pkgs.alsa-tools}/bin/hda-verb /dev/snd/hwC2D0 0x19 SET_PIN_WIDGET_CONTROL 0x25
        
        # 2. Kill Internal and Headset Mic Boosts (0 is safe, 3 is static)
        ${pkgs.alsa-utils}/bin/amixer -D hw:Generic_1 cset name='Internal Mic Boost Volume' 0
        ${pkgs.alsa-utils}/bin/amixer -D hw:Generic_1 cset name='Headset Mic Boost Volume' 0
        
        # 3. Force UNMUTE via PipeWire and ALSA
        ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
        ${pkgs.alsa-utils}/bin/amixer -D hw:Generic_1 cset name='Capture Switch' on
        
        # 4. Set clean volumes
        ${pkgs.alsa-utils}/bin/amixer -D hw:Generic_1 cset name='Capture Volume' 63
        ${pkgs.alsa-utils}/bin/amixer -D hw:Generic_1 cset name='Capture Source' 1
        ${pkgs.alsa-utils}/bin/amixer -D hw:Generic_1 sset 'Auto-Mute Mode' Disabled
        
        sleep 1
      done
    '';
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}

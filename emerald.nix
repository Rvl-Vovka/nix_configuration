# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ 
      ./hardware-emerald.nix # Include the results of the hardware scan
      ./shared.nix
    ];

  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    kernelParams = [ "amd_pstate=active" ];
  };

  hardware = {
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
      # Fine-grained power management. Turns off GPU when not in use
      powerManagement.finegrained = true;

      prime = { # PRIME settings for Hybrid Graphics
        offload.enable = true;
        offload.enableOffloadCmd = true;
        amdgpuBusId = "PCI:5:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "vlryz" = import ./home-emerald.nix;
    };
  };

  networking.hostName = "emerald"; # Define your hostname

  programs = {
    kde-pim.enable = false; # Enabled automatically plasma 6 service
  };

  environment = {
    systemPackages = with pkgs; [
      asusctl
      kdotool
      kid3-kde
    ];
    plasma6.excludePackages = with pkgs.kdePackages; [
      ark
      discover
      elisa
      khelpcenter
      konsole
      kwalletmanager
      okular
    ];

    shellAliases = {
      cdl = "cd /home/vlryz/Important/Legendary";
      confsync = "bash ~/Important/Legendary/confsync.sh"; # Script that enshures that local and cloud configurations are same
      parrot = "python ~/.parrot.py";
      rebuild = "bash ~/Important/Legendary/rebuild.sh"; # Script that automatically handles configuration backups
      rr = "python ~/.rr.py";
    };
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
    # Enable the X11 windowing system
    # You can disable this if you're only using the Wayland session
    xserver.videoDrivers = [ "nvidia" "amdgpu" ]; # Load nvidia driver for Xorg and Wayland
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}

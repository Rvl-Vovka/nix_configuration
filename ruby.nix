# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

let
  skanlite = pkgs.kdePackages.skanlite;
in

{
  imports =
    [ 
      ./hardware-ruby.nix # Include the results of the hardware scan
      ./shared.nix
    ];

  fileSystems = {
    "/home/vlryz/D" = { 
      device = "/dev/disk/by-uuid/18F4D20AF4D1EA50";
      fsType = "ntfs";
    };
    "/home/vlryz/E" = { 
      device = "/dev/disk/by-label/LeoNiD";
      fsType = "ntfs";
    };
    "/home/vlryz/F" = { 
      device = "/dev/disk/by-label/Foto\\x26mp3";
      fsType = "ntfs";
    };
    "/home/vlryz/G" = { 
      device = "/dev/disk/by-label/Video";
      fsType = "ntfs";
    };
  };


  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "vlryz" = import ./home-ruby.nix;
    };
  };

  networking.hostName = "ruby"; # Define your hostname

  programs.niri.enable = true;

  environment = {
    systemPackages = with pkgs; [
      rofi
      kid3-qt
      skanlite
      xwayland-satellite
    ];
    variables = {
      SANE_TIMEOUT=90000000;
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_STYLE_OVERRIDE = "kvantum";
    };
    shellAliases = {
      confsync = "bash ~/Important/scripts/confsync.sh"; # Script that enshures that local and cloud configurations are same
      parrot = "python ~/Important/scripts/parrot.py";
      rebuild = "bash ~/Important/scripts/rebuild.sh"; # Script that automatically handles configuration backups
      rr = "python ~/Important/scripts/rr.py";
    };
  };
  # List services that you want to enable:
  services = {
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    # Enable sddm
    displayManager = {
      sddm.enable = true;
      autoLogin.user = "vlryz"; # Disable prompting for password on boot
    };
    # Enable the X11 windowing system
    # You can disable this if you're only using the Wayland session
    xserver.videoDrivers = [ "nvidia" ]; # Load nvidia driver for Xorg and Wayland
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}

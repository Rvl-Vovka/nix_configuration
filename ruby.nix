# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ 
      ./hardware-ruby.nix # Include the results of the hardware scan
      ./shared.nix
    ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "vlryz" = import ./home-ruby.nix;
    };
  };

  networking.hostName = "ruby"; # Define your hostname

  programs.niri.enable = true;

  # List services that you want to enable:
  services = {
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

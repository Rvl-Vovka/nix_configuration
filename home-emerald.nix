{ config, pkgs, inputs, ... }:

{
  imports = [
    ./home-shared.nix
  ];

  xdg.configFile = {
    "kitty".source = ./configs/kitty-emerald;
  };
}

{ pkgs, inputs, ... }:

{
  imports = [
    ./home-shared.nix
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  qt = {
    enable = true;
    style.name = "kvantum";
    # platformTheme.name = "qtct";
    kvanrum = {
      enable = true;
    };
  };

  xdg.configFile = {
    "kitty".source = ./configs/kitty-ruby;
  };
}

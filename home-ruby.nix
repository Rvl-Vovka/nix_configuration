{ pkgs, lib, inputs, ... }:

let
  qt-colorscheme = "./configs/themes/qt-colorscheme.conf";
in 

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
    platformTheme.name = "qtct";
    qt6ctSettings = {
      Appearance = {
        color_scheme_path = qt-colorscheme;
        custom_palette = true;
        icon_theme = "breeze-dark";
        standard_dialogs = "default";
        style = "Breeze";
      };
      Fonts = {
        fixed = "\"JetBrainsMono Nerd Font Mono,10\"";
        general = "\"Noto Sans,10\"";
      };
    };
  };

  xdg.configFile = {
    "kitty".source = ./configs/kitty-ruby;
  };
}

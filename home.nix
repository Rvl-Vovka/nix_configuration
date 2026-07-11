{ config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "vlryz";
  home.homeDirectory = "/home/vlryz";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.
  home.enableNixpkgsReleaseCheck = false;

  home.shellAliases = {
    # Most aliases are configured in configuration.nix but these ones are overwriten by zsh so need to be there
    l = "eza --icons --group-directories-first -lah";
    ls = "eza --icons --group-directories-first";
    ll = "eza --icons --group-directories-first -la";
    la = "eza --icons --group-directories-first -a";
    lsa = "eza --icons --group-directories-first -lah";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/vlryz/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs = {
    home-manager.enable = true; # Let Home Manager install and manage itself.

      yt-dlp = {
        enable = true;
        extraConfig = ''
          -P home:"/home/vlryz/Downloads/"
          --audio-format "mp3"
          --remux-video "mp3>mp3/mp4"
          --sponsorblock-remove music_offtopic
          --yes-playlist
          -o "%(title)s.%(ext)s"
        '';
      };

      zsh = {
      enable = true;
        oh-my-zsh = {
          enable = true;
          theme = "agnoster";
          extraConfig = ''
            # Disable magic functions to prevent paste interference
            DISABLE_MAGIC_FUNCTIONS=true
          '';
        };
        plugins = [
          {
            name = "zsh-nix-shell";
            src = inputs.plugin-zsh-nix-shell;
            file = "nix-shell.plugin.zsh";
          }
          {
            name = "zsh-autosuggestions";
            src = inputs.plugin-zsh-autosuggestions;
            file = "zsh-autosuggestions.zsh";
          }
          {
            name = "zsh-syntax-highlighting";
            src = inputs.plugin-zsh-syntax-highlighting;
            file = "zsh-syntax-highlighting.zsh";
          }
        ];
        initContent = ''
          # Ensure suggestions are cleared on paste
          # This must be defined for zsh-autosuggestions
          ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)
        '';
      };

      neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins = with pkgs.vimPlugins; [
          {
            plugin = nvim-lspconfig;
            config = builtins.readFile ./configs/nvim/plugin/lsp.lua;
            type = "lua";
          }
          {
            plugin = comment-nvim;
            config = "require(\"Comment\").setup()";
            type = "lua";
          }
          {
            plugin = vscode-nvim;
            config = "colorscheme vscode";
            type = "viml";
          }
          neodev-nvim
          nvim-cmp
          {
            plugin = nvim-cmp;
            config = builtins.readFile ./configs/nvim/plugin/cmp.lua;
            type = "lua";
          }
          {
            plugin = telescope-nvim;
            config = builtins.readFile ./configs/nvim/plugin/telescope.lua;
            type = "lua";
          }
          telescope-fzf-native-nvim
          cmp_luasnip
          cmp-nvim-lsp
          luasnip
          friendly-snippets
          lualine-nvim
          nvim-web-devicons
          vim-nix
          {
            plugin = (nvim-treesitter.withPlugins (p: [
              p.tree-sitter-nix
              p.tree-sitter-vim
              p.tree-sitter-bash
              p.tree-sitter-lua
              p.tree-sitter-python
              p.tree-sitter-json
              p.tree-sitter-c
              p.tree-sitter-kitty
              p.tree-sitter-powershell
              p.tree-sitter-markdown
              p.tree-sitter-markdown_inline
            ]));
            config = builtins.readFile ./configs/nvim/plugin/treesitter.lua;
            type = "lua";
          }
        ];
         initLua = ''
          ${builtins.readFile ./configs/nvim/options.lua}
        '';
      };
    };
  xdg.configFile = {
    "powershell/Microsoft.PowerShell_profile.ps1".source = ./configs/powershell/Microsoft.PowerShell_profile.ps1;
    "kitty".source = ./configs/kitty;
    "fastfetch".source = ./configs/fastfetch;
  };
}

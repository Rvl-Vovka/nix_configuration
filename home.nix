{ config, pkgs, inputs, ... }:

{
  home = {
    username = "vlryz";
    homeDirectory = "/home/vlryz";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "26.05"; # Please read the comment before changing.
    enableNixpkgsReleaseCheck = false;
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
        plugins = [
          {
            name = "zsh-nix-shell";
            src = pkgs.zsh-nix-shell;
            file = "share/zsh/plugins/zsh-nix-shell/nix-shell.plugin.zsh";
          }
          {
            name = "zsh-vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
          {
            name = "zsh-autosuggestions";
            src = pkgs.zsh-autosuggestions;
            file = "share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh";
          }
          {
            name = "zsh-syntax-highlighting";
            src = pkgs.zsh-syntax-highlighting;
            file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
          }
        ];
        history = {
          size = 1000000;
          save = 1000000;
          append = true;
        };
        initContent = ''
          # Ensure suggestions are cleared on paste
          # This must be defined for zsh-autosuggestions
          ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)
 
          # Format prompt similar to agnoster theme (not using real theme because I only care about this small part)
          PROMPT='%K{black}%(?.. %F{red}✘%f)%(!. ⚡.)%(1j. %F{cyan}⚙%f.) %n@%m %F{black}%K{blue} %~ %F{blue}%k%f '
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

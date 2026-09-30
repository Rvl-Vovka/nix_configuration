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
        autocd = true;
        initContent = ''
          # Ensure suggestions are cleared on paste
          # This must be defined for zsh-autosuggestions
          ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

          man() { LESS_TERMCAP_mb="[1;36m" LESS_TERMCAP_md="[1;36m" LESS_TERMCAP_me="[0m" LESS_TERMCAP_se="[0m" LESS_TERMCAP_so="[0;1m" LESS_TERMCAP_ue="[0m" LESS_TERMCAP_us="[4;1;32m" LESS_TERMCAP_mr="[7m" LESS_TERMCAP_mh="[2m" LESS_TERMCAP_ZN="[74m" LESS_TERMCAP_ZV="[75m" LESS_TERMCAP_ZO="[73m" LESS_TERMCAP_ZW="[75m" GROFF_NO_SGR=1 $(which -p man) $@ } # [0m Make man pages colorful

          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}" # colorful completion
          zstyle ':completion:*' menu select # show what is currently selected
          zstyle ':completion:*' metcher-list ''' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*' # makes completion case insensetive, preferring original case
          zmodload zsh/complist
          bindkey "''${terminfo[kcbt]}" reverse-menu-complete
          bindkey -M menuselect "''${terminfo[kcbt]}" reverse-menu-complete

          # History search when pressing up/down arrows
          autoload -U up-line-or-beginning-search
          autoload -U down-line-or-beginning-search
          zle -N up-line-or-beginning-search
          zle -N down-line-or-beginning-search
          bindkey -M emacs "^[[A" up-line-or-beginning-search
          bindkey -M viins "^[[A" up-line-or-beginning-search
          bindkey -M vicmd "^[[A" up-line-or-beginning-search
          bindkey -M emacs "^[[B" down-line-or-beginning-search
          bindkey -M viins "^[[B" down-line-or-beginning-search
          bindkey -M vicmd "^[[B" down-line-or-beginning-search

          autoload -Uz edit-command-line
          zle -N edit-command-line
          bindkey "^e" edit-command-line

          bindkey "^u" undo
          bindkey "^r" redo
          bindkey " " magic-space

          autoload zmv

          alias -g NE='2>/dev/null'
          alias -g ND='>/dev/null'
          alias -g NUL='2>1 >/dev/null'

          # Format prompt similar to agnoster theme (not using real theme because I only care about this small part)
          PROMPT='%K{black}%(?.. %F{red}✘%f)%(!. ⚡.)%(1j. %F{cyan}⚙%f.)%(!.%F{yellow}.) %n@%m %F{black}%K{blue} %~ %F{blue}%k%f '

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

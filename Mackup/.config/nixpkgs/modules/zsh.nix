{ config, lib, ... }:

with lib;

let
  dag = lib.hm.dag;

in {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableCompletion = true;

    history = {
      path = ".local/share/zsh/history";
      # Match oh-my-zsh settings
      extended = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      size = 50000;
      save = 10000;
      share = true;
    };

    localVariables = {
      DISABLE_AUTO_TITLE = "true";
    };

    shellAliases = {
      ag = "ag --hidden --path-to-ignore ~/.config/silver_searcher/ignore";
    };
  };

  #### .zshrc
  #
  # This needs to appear at the very top of the file, and so we can't use `initExtra`
  home.file."${config.programs.zsh.dotDir}/.zshrc".text = mkBefore ''
    # Reset $PATH when we load tmux
    # Avoids rbenv, nodenv etc. entries being added twice
    if ([ -n "$TMUX" ] || [ -n "$INSIDE_EMACS" ]) && [ -x "/usr/libexec/path_helper" ]; then
      eval "$(PATH="" /usr/libexec/path_helper -s)"
    fi

    # Defines `NIX_PATH`, `NIX_PROFILES` and `NIX_SSL_CERT_FILE`
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
  '';

  programs.zsh.initExtra = mkMerge [
    (mkBefore ''
      hash -d iCloud="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
      hash -d dotfiles=~iCloud/dotfiles

      path=("$HOME/.bin" $path)

      maybe_source() {
        [ -f "$1" ] && source "$1"
      }
    '')

    (mkAfter ''
      # Cleanup
      unfunction maybe_source
    '')
  ];
  #### end .zshrc

  programs.zsh.oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";

    plugins = [
      "history-substring-search"
      "osx"
    ];
  };

}

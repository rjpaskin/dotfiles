{ config, lib, modulesPath, pkgs, ... }:

let
  # hmPath = dirOf modulesPath;
  # nixpkgsPath = toString pkgs.path;

in {
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;

    history = {
      path = "${config.xdg.dataHome}/zsh/history";
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

    sessionVariables = {
      # NIX_PATH = "nixpkgs=${nixpkgsPath}:home-manager=${hmPath}";
      NIXPKGS_ALLOW_UNFREE = 1;

      # Disable per-tab history from macOS' `/etc` config files
      SHELL_SESSION_HISTORY = 0;
      SHELL_SESSIONS_DISABLE = 1;
    };

    # These get sorted alphabetically so we can't rely on the order
    dirHashes = {
      # dotfiles = machine.dotfilesDirectory;
      iCloud = "$HOME/Library/Mobile Documents/com~apple~CloudDocs";

      # For ease of searching
      # home-manager = hmPath;
      # nixpkgs = nixpkgsPath;
    };

    # This needs to appear at the very top of the file
    initContent = lib.mkBefore ''
      # Reset $PATH when we load tmux - avoids entries being added twice
      if ([ -n "$TMUX" ] || [ -n "$INSIDE_EMACS" ]) && [ -x "/usr/libexec/path_helper" ]; then
        eval "$(PATH="" /usr/libexec/path_helper -s)"
      fi

      # Run before sourcing Nix profile.d to ensure programs from
      # Nix profile appear first in $PATH
      [ -d /opt/homebrew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };

  programs.zsh.oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";

    plugins = [
      "history-substring-search"
      "macos"
    ];
  };
}

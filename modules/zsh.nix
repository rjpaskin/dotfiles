{ config, lib, modulesPath, pkgs, machine, ... }:

with lib;

let
  dag = lib.hm.dag;

  hmPath = dirOf modulesPath;
  nixpkgsPath = toString pkgs.path;

in {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
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
      NIX_PATH = "nixpkgs=${nixpkgsPath}:home-manager=${hmPath}";
    };

    # These get sorted alphabetically so we can't rely on the order
    dirHashes = {
      dotfiles = machine.dotfilesDirectory;
      iCloud = "$HOME/Library/Mobile Documents/com~apple~CloudDocs";

      # For ease of searching
      home-manager = hmPath;
      nixpkgs = nixpkgsPath;
    };
  };

  #### .zshrc
  #
  # This needs to appear at the very top of the file, and so we can't use `initExtra`
  home.file."${config.programs.zsh.dotDir}/.zshrc".text = mkBefore ''
    # Reset $PATH when we load tmux - avoids entries being added twice
    if ([ -n "$TMUX" ] || [ -n "$INSIDE_EMACS" ]) && [ -x "/usr/libexec/path_helper" ]; then
      eval "$(PATH="" /usr/libexec/path_helper -s)"
    fi

    # Defines `NIX_PATH`, `NIX_PROFILES` and `NIX_SSL_CERT_FILE`
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
  '';
  #### end .zshrc

  programs.zsh.oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";

    plugins = [
      "history-substring-search"
      "osx"
    ];
  };

  home.activation.setShellToZSH = dag.entryAfter ["installPackages"] ''
    set_shell_to_zsh() {
      local shell_path="$HOME/.nix-profile/bin/zsh"

      if ! grep -qxF "$shell_path" /etc/shells; then
        $VERBOSE_ECHO "Adding '$shell_path' to /etc/shells"
        $DRY_RUN_CMD sudo sh -c "echo $shell_path >> /etc/shells"
      fi

      if [ "$SHELL" != "$shell_path" ]; then
        $VERBOSE_ECHO "Changing shell for '$LOGNAME' to '$shell_path'"
        $DRY_RUN_CMD sudo chsh -s "$shell_path" "$LOGNAME"
      fi
    }

    set_shell_to_zsh
  '';
}

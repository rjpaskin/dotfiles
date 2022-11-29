{ config, lib, ... }:

let
  editorConfigINI = attrs: with lib; let
    mkKeyValue = generators.mkKeyValueDefault {} " = ";
    attrsOfAttrs = attrsets.filterAttrs (_: v: isAttrs v) attrs;
    topLevel = attrsets.filterAttrs (_: v: !(isAttrs v)) attrs;
  in ''
    ${generators.toKeyValue { inherit mkKeyValue; } topLevel}
    ${generators.toINI { inherit mkKeyValue; } attrsOfAttrs}
  '';

  inherit (config.lib.symlinks) mkDotfileSymlink;

in {
  programs.bash = {
    enable = true;
    historyFile = "${config.xdg.dataHome}/bash/history";
    # don't put duplicates lines or empty spaces in history
    historyControl = [ "ignorespace" "ignoredups" ];
    shellOptions = [
      "cdspell"      # correct typos in `cd`
      "checkwinsize" # resize out to fit window
      "cmdhist"      # combine multiline commands in history
      "histappend"   # merge session histories
    ];
    sessionVariables = {
      CLICOLOR = "1";
      LSCOLORS = "Gxfxcxdxbxegedabagacad";
      GREP_OPTIONS = "--color=auto";
      IGNOREEOF = "1"; # Ctrl+D must be pressed twice to exit shell

      # Disable per-tab history from macOS' `/etc` config files
      SHELL_SESSION_HISTORY = 0;
    };
    shellAliases = {
      ".." = "cd ..";

      # list files...
      "la"  = "ls -alh";  # list all files, incl. hidden
      "ld"  = "ls -d */"; # list directories within current directory
      "ll"  = "ls -lh";   # ...in long format w/ human-readable filesizes
      "lt"  = "ls -lht";  # ...sorted by time modified
      "lfs" = "ls -lhS";  # ...sorted by size
      "lr"  = "ls -lhR";  # ...recursively
      "l1"  = "ls -1";    # ...forcing 1 entry per line
    };
  };
  xdg.dataFile."bash/.keep".text = ""; # ensure Bash has directory to write to
  home.file.".bash_sessions_disable".text = ""; # disable per-tab history from macOS' `/etc` config files

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    stdlib = ''
      # https://github.com/nix-community/nix-direnv/tree/b54e2f2#storing-direnv-outside-the-project-directory
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs

      direnv_layout_dir() {
        echo "''${direnv_layout_dirs[$PWD]:=$(
          mkdir -p "$XDG_CACHE_HOME/direnv/layouts"
          echo -n "$XDG_CACHE_HOME/direnv/layouts/"
          echo -n "$PWD" | shasum | cut -d ' ' -f 1
        )}"
      }
    '';
  };

  programs.readline = {
    enable = true;
    includeSystemConfig = false; # doesn't exist on macOS
    variables = {
      show-all-if-ambiguous = true;  # avoid double-tabbing when > 1 match
      completion-ignore-case = true; # case-insensitive tab completion
    };
  };

  home.file.".editorconfig".text = editorConfigINI {
    root = true;
    "*" = {
      indent_type = "space";
      indent_size = 2;
      end_of_line = "lf"; # Unix-style newlines
      charset = "utf-8";
      trim_trailing_whitespace = true;
      insert_final_newline = true;
    };
    "Makefile" = { indent_style = "tab"; };
  };

  home.file.".ssh/config".text = ''
    # Required for macOS Sierra 10.12.2 or later
    # See https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
    Host *
     AddKeysToAgent yes
     UseKeychain yes
     IgnoreUnknown UseKeychain
     IdentityFile ${
       if builtins.pathExists "${config.home.homeDirectory}/.ssh/id_ed25519"
       then "~/.ssh/id_ed25519"
       else "~/.ssh/id_rsa"
     }
  '';
}

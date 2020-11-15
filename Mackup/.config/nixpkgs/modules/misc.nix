{ ... }:

{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableNixDirenvIntegration = true;
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
}

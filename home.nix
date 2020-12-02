{ config, lib, ... }:

with lib;

{
  config = {
    # Use `script/switch` instead
    programs.home-manager.enable = false;

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "20.09";

    news.display = "silent";

    # Disable `man` so that we don't get `pkgs.man` and all its accompanying executables,
    # but still add `man` to `extraOutputsToInstall` as the `man` module does
    programs.man.enable = false;
    home.extraOutputsToInstall = [ "man" ];

    # Prevent activation script from installing packages into ~/.nix-profile
    # - we do this ourselves later on
    home.activation = with lib.hm; {
      disableNixEnv = dag.entryBefore ["installPackages"] ''
        nix-env() { echo "==> Disabled - packages installed later"; }
      '';

      reenableNixEnv = dag.entryBefore ["linkGeneration"] ''
        unset -f nix-env
      '';
    };
  };

  imports = [
    ./modules/roles.nix

    ./modules/clojure
    ./modules/docker
    ./modules/git.nix
    ./modules/go.nix
    ./modules/heroku.nix
    ./modules/javascript.nix
    ./modules/misc.nix
    ./modules/neovim
    ./modules/pkgs.nix
    ./modules/react-native.nix
    ./modules/ruby.nix
    ./modules/symlinks.nix
    ./modules/tmux
    ./modules/zsh.nix
  ] ++ optional (builtins.getEnv("NO_HM_HOME_LINKS") != "") ./modules/preserve_home.nix;
}

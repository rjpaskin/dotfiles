{ config, lib, ... }:

with lib;

{
  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

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

    home.username = builtins.getEnv("USER");
    home.homeDirectory = builtins.getEnv("HOME");
  };

  imports = [
    ./modules/roles.nix
    ./modules/host

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
    ./modules/tmux.nix
    ./modules/zsh.nix
  ] ++ optional (builtins.getEnv("NO_HM_HOME_LINKS") != "") ./modules/preserve_home.nix;
}

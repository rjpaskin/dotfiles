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
    home.stateVersion = "19.09";

    news.display = "silent";
  };

  imports = [
    ./modules/roles.nix
    ./modules/host

    ./modules/neovim
  ] ++ optional (builtins.getEnv("NO_HM_HOME_LINKS") != "") ./modules/preserve_home.nix;
}

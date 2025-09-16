{ config, lib, ... }:

{
  config = {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "25.05";

    home.homeDirectory = lib.mkForce "/Users/${config.home.username}";

    # Disable `man` so that we don't get `pkgs.man` and all its accompanying executables,
    # but still add `man` to `extraOutputsToInstall` as the `man` module does
    programs.man.enable = false;
    home.extraOutputsToInstall = [ "man" ];

    # Record the roles that were used
    xdg.configFile."dotfiles/roles.json".text = builtins.toJSON config.roles;
  };

  imports = [
    ./modules/roles.nix

    ./modules/zsh.nix
    ./modules/neovim
    ./modules/git.nix
    ./modules/ruby.nix
    ./modules/docker
    ./modules/iterm.nix
    ./modules/javascript.nix
    ./modules/misc.nix
    ./modules/pkgs.nix
    ./modules/ssh.nix
    ./modules/macos_defaults
  ];
}

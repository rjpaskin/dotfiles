{ config, lib, ... }:

{
  config = {
    home.homeDirectory = lib.mkForce "/Users/${config.home.username}";

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
    ./modules/terminal.nix
    ./modules/javascript.nix
    ./modules/misc.nix
    ./modules/pkgs.nix
    ./modules/ssh.nix
    ./modules/macos_defaults
    ./modules/homebrew.nix
  ];
}

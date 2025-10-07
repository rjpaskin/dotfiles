_:

{
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

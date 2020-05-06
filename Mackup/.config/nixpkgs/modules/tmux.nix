{ config, ... }:

{
  home.symlinks = config.lib.mackup.mackupFiles [
    ".tmux.conf"
    ".tmuxinator"
  ];
}

{ config, ... }:

{
  home.symlinks = config.lib.mackup.mackupFiles [
    ".tmux.conf"
    ".tmuxinator"
  ];

  programs.zsh.initExtra = ''
    maybe_source "/usr/local/share/zsh/site-functions/tmuxinator.zsh"
  '';
}

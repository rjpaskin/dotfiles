{ pkgs, ... }:

{
  home.packages = with pkgs; [
    dockutil
    fzf
    jq
    ncdu
    shellcheck
    silver-searcher
    universal-ctags

    autoterm
  ];
}

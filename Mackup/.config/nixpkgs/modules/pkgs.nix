{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fzf
    jq
    ncdu
    shellcheck
    silver-searcher
    universal-ctags

    autoterm
  ];
}

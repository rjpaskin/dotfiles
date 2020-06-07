{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fzf
    jq
    ncdu
    silver-searcher
    universal-ctags
  ];
}

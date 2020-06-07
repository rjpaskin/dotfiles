{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq
    ncdu
    silver-searcher
    universal-ctags
  ];
}

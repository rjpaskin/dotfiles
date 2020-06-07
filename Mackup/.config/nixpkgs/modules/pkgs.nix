{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq
    silver-searcher
    universal-ctags
  ];
}

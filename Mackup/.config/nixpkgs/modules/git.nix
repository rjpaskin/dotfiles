{ config, pkgs, ... }:

{
  programs.neovim.plugs = with pkgs.vimPlugins; [
    vim-fugitive
    vim-rhubarb
  ];
}

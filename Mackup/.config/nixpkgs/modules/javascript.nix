{ config, pkgs, ... }:

{
  programs.neovim.plugs = with pkgs.vimPlugins; [
    emmet-vim
    vim-javascript
    vim-jsx
    vim-prettier
  ];
}

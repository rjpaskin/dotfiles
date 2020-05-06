{ config, pkgs, ... }:

{
  programs.neovim.plugs = with pkgs.vimPlugins; [
    emmet-vim
    vim-javascript
    vim-jsx
    vim-prettier
  ];

  home.symlinks = config.lib.mackup.mackupFiles [
    ".config/yarn/global/package.json"
    ".config/yarn/global/yarn.lock"
  ];
}

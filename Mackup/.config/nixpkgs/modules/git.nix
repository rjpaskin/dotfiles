{ config, pkgs, ... }:

{
  programs.neovim.plugs = with pkgs.vimPlugins; [
    vim-fugitive
    vim-rhubarb
  ];

  home.symlinks = config.lib.mackup.mackupFiles [
    ".config/git/attributes"
    ".config/git/ignore"
    ".config/git/config"
    ".config/git/config.local"

    "Library/Application Support/SourceTree/sourcetree.license"
  ];
}

{ config, pkgs, ... }:

{
  programs.neovim.plugs = with pkgs.vimPlugins; [
    splitjoin-vim
    vim-bundler
    vim-endwise
    vim-rails
    vim-rspec
    vim-ruby
    vim-ruby-refactoring
    vim-rubyhash
    vim-textobj-rubyblock
    vim-yaml-helper # Pretty much only used for i18n YAML files
  ];
}

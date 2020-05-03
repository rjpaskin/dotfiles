{ config, ... }:

{
  home.symlinks = config.lib.mackup.mackupFiles [
    ".config/zsh/.zshrc"
    ".config/zsh/.zshrc.local"
    ".zshenv"
  ];
}

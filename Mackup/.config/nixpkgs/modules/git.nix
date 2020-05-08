{ config, lib, pkgs, ... }:

with lib;

{
  options.roles = with config.lib.roles; {
    git = mkOptionalRole "Git and tools";
    git-flow = mkOptionalRole "Git flow";
  };

  config = mkIf config.roles.git {
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
  };
}

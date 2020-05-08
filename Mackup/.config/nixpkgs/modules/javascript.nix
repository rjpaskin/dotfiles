{ config, lib, pkgs, ... }:

with lib;

{
  options.roles.javascript = config.lib.roles.mkOptionalRole "Javascript dev";

  config = mkIf config.roles.javascript {
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
  };
}

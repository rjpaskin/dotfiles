{ config, ... }:

{
  options.roles.javascript = config.lib.roles.mkOptionalRole "Javascript dev";

  config.hm = { lib, pkgs, ... }: {
    config = lib.mkIf config.roles.javascript {
      home.packages = with pkgs; [
        yarn
        nodejs
      ];

      programs.neovim.plugins = with pkgs.vimPlugins; [
        emmet-vim
        vim-javascript
        vim-jsx-pretty
        vim-prettier
      ];

      programs.zsh.oh-my-zsh.plugins = [ "node" "npm" "yarn" ];
    };
  };
}

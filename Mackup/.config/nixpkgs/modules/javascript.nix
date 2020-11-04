{ config, lib, pkgs, ... }:

with lib;

{
  options.roles.javascript = config.lib.roles.mkOptionalRole "Javascript dev";

  config = mkIf config.roles.javascript {
    home.packages = with pkgs; [
      yarn
    ];

    programs.neovim.plugs = with pkgs.vimPlugins; [
      emmet-vim
      vim-javascript
      vim-jsx-pretty
      vim-prettier
    ];

    programs.zsh = {
      oh-my-zsh.plugins = ["node" "npm" "yarn"];

      initExtra = ''
        # nodenv setup
        if command -v nodenv >/dev/null; then
          eval "$(nodenv init - --no-rehash)"
        fi
      '';
    };
  };
}

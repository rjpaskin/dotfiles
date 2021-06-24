{ config, pkgs, lib, ... }:

with lib;

{
  options.roles.clojure = config.lib.roles.mkOptionalRole "Clojure dev";

  config = mkIf config.roles.clojure {
    home.packages = with pkgs; [
      clojure
      leiningen
    ];

    programs.neovim.plugins = with pkgs.vimPlugins; [
      # vim-salve
      # vim-fireplace
      conjure
      vim-sexp
      vim-sexp-mappings-for-regular-people
    ];

    programs.zsh.oh-my-zsh.plugins = [ "lein" ];

    home.file.".lein/profiles.clj".source = ./lein/profiles.clj;
  };
}

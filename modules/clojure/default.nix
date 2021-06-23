{ config, pkgs, lib, dotfilesRoot, ... }:

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

    home.file.".lein".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesRoot}/modules/clojure/lein";
  };
}

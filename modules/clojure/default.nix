{ config, lib, ... }:

{
  options.roles.clojure = config.lib.roles.mkOptionalRole "Clojure dev";

  config.hm = lib.mkIf config.roles.clojure ({ pkgs, ... }: {
    home.packages = with pkgs; [
      clojure
      leiningen
    ];

    programs.neovim.plugins = with pkgs.vimPlugins; [
      conjure
      vim-sexp
      vim-sexp-mappings-for-regular-people
    ];

    programs.zsh.oh-my-zsh.plugins = [ "lein" ];

    home.file.".lein/profiles.clj".source = ./lein/profiles.clj;
  });
}

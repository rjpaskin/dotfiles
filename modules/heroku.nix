{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.heroku;

  plugins = import ../pkgs/heroku-plugins {
    inherit pkgs;
    inherit (pkgs) nodejs;
  };

  herokuWithPlugins = pkgs.callPackage ../pkgs/heroku-with-plugins.nix {};

  parity = pkgs.callPackage ../pkgs/parity {
    ruby = config.programs.ruby.defaultPackage;
  };

in {
  options = with config.lib.roles; {
    roles.heroku = mkOptionalRole "Heroku tools";
    roles.parity = mkOptionalRole "Parity";

    programs.heroku.plugins = mkOption {
      type = types.listOf types.package;
      description = "List of plugins to bundle into Heroku package";
    };
  };

  config = mkIf config.roles.heroku {
    home.packages = [
      (herokuWithPlugins cfg.plugins)

      (mkIf config.roles.parity parity)
    ];

    programs.heroku.plugins = with plugins; [
      heroku-accounts
      heroku-repo
    ];

    programs.zsh.oh-my-zsh.plugins = ["heroku"];
  };
}

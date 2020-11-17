{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.heroku;

  plugins = import ../pkgs/heroku-plugins { inherit pkgs; };

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
      (pkgs.heroku.withPlugins cfg.plugins)

      (mkIf config.roles.parity pkgs.parity-gem)
    ];

    programs.heroku.plugins = with plugins; [
      heroku-accounts
      heroku-repo
    ];

    programs.zsh.oh-my-zsh.plugins = ["heroku"];
  };
}

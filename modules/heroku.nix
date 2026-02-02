{ config, lib, pkgs, ... }:

with lib;

{
  options = with config.lib.roles; {
    roles.heroku = mkOptionalRole "Heroku tools";
  };

  config = mkIf config.roles.heroku {
    home.packages = [
      pkgs.heroku
    ];

    programs.zsh.oh-my-zsh.plugins = ["heroku"];
  };
}

{ config, lib, ... }:

with lib;

{
  options.roles.heroku = config.lib.roles.mkOptionalRole "Heroku tools";

  config = mkIf config.roles.heroku {
    programs.zsh.oh-my-zsh.plugins = ["heroku"];
  };
}

{ config, lib, ... }:

with lib;

{
  options.roles.docker = config.lib.roles.mkOptionalRole "Docker tools";

  config = mkIf config.roles.docker {
    programs.zsh = {
      oh-my-zsh.plugins = ["docker" "docker-compose"];

      shellAliases = {
        dup = "docker-compose up";
        bdup = "BYEBUG=1 docker-compose up";
        dkill = "docker-compose kill";
      };
    };
  };
}

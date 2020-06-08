{ config, lib, pkgs, ... }:

with lib;

{
  options.roles.docker = config.lib.roles.mkOptionalRole "Docker tools";

  config = mkIf config.roles.docker {
    home.packages = [ pkgs.hadolint ];

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

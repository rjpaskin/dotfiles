{ config, lib, pkgs, dotfilesRoot, ... }:

with lib;

let
  exec-when-up = let
    path = "${dotfilesRoot}/modules/docker/docker_compose_exec_when_up";
  in pkgs.runCommandLocal (baseNameOf path) {} ''
    mkdir -p $out/bin
    cp ${escapeShellArg path} $out/bin/${baseNameOf path}
  '';

in {
  options.roles.docker = config.lib.roles.mkOptionalRole "Docker tools";

  config = mkIf config.roles.docker {
    home.packages = with pkgs; [
      hadolint
      dive
      exec-when-up
    ];

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

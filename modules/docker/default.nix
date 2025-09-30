{ config, lib, pkgs, ... }:

let
  exec-when-up = let
    name = "docker_compose_exec_when_up";
  in pkgs.runCommandLocal name {} ''
    mkdir -p $out/bin
    ln -s ${./. + "/${name}"} $out/bin/${name}
  '';

in {
  options.roles.docker = config.lib.roles.mkOptionalRole "Docker tools";

  config = lib.mkIf config.roles.docker {
    home.packages = with pkgs; [
      hadolint
      dive
      exec-when-up
    ];

    nix-darwin.homebrew.casks = [ "docker-desktop" ];

    programs.zsh = {
      oh-my-zsh.plugins = [ "docker" "docker-compose" ];

      shellAliases = {
        dup = "docker compose up";
        bdup = "BYEBUG=1 docker compose up";
        dkill = "docker compose kill";
      };
    };
  };
}

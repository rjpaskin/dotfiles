{ config, lib, ... }:

{
  options = {
    roles.docker = config.lib.roles.mkOptionalRole "Docker tools";
    docker.cask = lib.mkOption {
      type = lib.types.enum [ "docker-desktop" "orbstack" ];
      description = "Homebrew cask to install for Docker";
      default = "docker-desktop";
    };
  };

  config = lib.mkIf config.roles.docker {
    hm = { pkgs, ... }:
    let
      exec-when-up = pkgs.stdenv.mkDerivation {
        name = "docker_compose_exec_when_up";
        src = builtins.readFile ./docker_compose_exec_when_up;
        phases = [ "buildPhase" "fixupPhase" ];
        buildInputs = [ pkgs.bashInteractive ];
        dontStrip = true;
        buildPhase = ''
          mkdir -p $out/bin
          echo "$src" > $out/bin/$name

          chmod +x $out/bin/$name
          patchShebangs --build $out/bin
        '';
      };
    in {
      home.packages = with pkgs; [
        hadolint
        dive
      ] ++ [ exec-when-up ];

      programs.zsh = {
        oh-my-zsh.plugins = [ "docker" "docker-compose" ];

        shellAliases = {
          dup = "docker compose up";
          bdup = "BYEBUG=1 docker compose up";
          dkill = "docker compose kill";
        };
      };
    };

    darwin.homebrew.casks = [ config.docker.cask ];
  };
}

{ config, lib, ... }:

with lib;

{
  options.roles.go = config.lib.roles.mkOptionalRole "Golang dev";

  config = mkIf config.roles.go {
    programs.zsh = {
      oh-my-zsh.plugins = ["golang"];
      initExtra = ''
        # Golang setup
        if command -v go >/dev/null; then
          export GOPATH="$HOME/src/golang"
        fi
      '';
    };
  };
}

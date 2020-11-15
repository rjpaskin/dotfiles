{ config, lib, pkgs, ... }:

with lib;

{
  options.roles = with config.lib.roles; {
    flight-plan = mkOptionalRole "FlightPlan tools";
  };

  config = mkMerge [
    # Basics
    {
      home.packages = with pkgs; [
        dockutil
        fzf
        jq
        ncdu
        shellcheck
        universal-ctags
      ];
    }

    (let
      config = "silver_searcher/ignore";
    in {
      home.packages = [ pkgs.silver-searcher ];
      xdg.configFile.${config}.text = ''
        .git/
        vendor/assets/
        public/
      '';
      programs.zsh.shellAliases = {
        ag = "ag --hidden --path-to-ignore ~/.config/${config}";
      };
    })

    # My packages
    { home.packages = [ pkgs.autoterm ]; }

    (mkIf config.roles.flight-plan {
      home.packages = [ pkgs.flight_plan_cli ];
    })
  ];
}

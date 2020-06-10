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
        silver-searcher
        universal-ctags
      ];
    }

    # My packages
    { home.packages = [ pkgs.autoterm ]; }

    (mkIf config.roles.flight-plan {
      home.packages = [ pkgs.flight_plan_cli ];
    })
  ];
}

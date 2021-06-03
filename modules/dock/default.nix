{ config, lib, pkgs, ... }:

with lib;

let
  inherit (config) roles;
  inherit (config.home) homeDirectory;

in {
  imports = [ ./options.nix ];

  config.targets.darwin.dock = {
    apps = [
      "Launchpad"
      "Google Chrome"
      (mkIf roles.git "SourceTree")
      "iTerm"
      "Utilities/Activity Monitor"
      "Pages"
      "Numbers"
      "Keynote"
      (mkIf roles.slack "Slack")
      "System Preferences"
    ];

    others = let
      defaults = { view = "grid"; display = "folder"; };
    in [
      ({ path = "/Applications"; sort = "name"; } // defaults)
      ({ path = "${homeDirectory}/Documents"; sort = "kind"; } // defaults)
      ({ path = "${homeDirectory}/Downloads"; sort = "dateadded"; } // defaults)
    ];
  };
}

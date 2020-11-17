{ lib, ... }:

with lib;

let
  _pkgs = (import ../..).nixpkgs;

  # Can't use `pkgs` here, since this needs to be evaluated before the modules are
  # merged together, due to the output being used in the `modules` argument below
  get-serial-number = _pkgs.runCommandNoCCLocal "get-serial-number" {} ''
    mkdir -p $out
    /usr/bin/osascript -l JavaScript "${./serial_number.scpt.js}" > $out/.serialnumber
  '';

  serial-number = fileContents "${get-serial-number}/.serialnumber";

  path = (../../hosts + "/${serial-number}");

in

  {
    imports = if pathExists path then [ path ]
    else warn ''
      No host config found, falling back to default config
      To add host-specific config, add the file ${toString path}/default.nix
    '' [];

    # Prevent output from being garbage-collected
    config.home.packages = [ get-serial-number ];
  }

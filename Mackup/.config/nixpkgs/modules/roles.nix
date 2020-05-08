{ lib, ... }:

with lib;
with types;

let
  mkRole = default: name: mkOption {
    inherit default;
    description = "Enable `${name}` role";
    type = bool;
  };

in {
  options.roles = {
    description = "Top-level roles config";
    type = attrsOf bool;
  };

  config.lib.roles = {
    mkOptionalRole = mkRole false;
    mkDefaultRole = mkRole true;
  };
}

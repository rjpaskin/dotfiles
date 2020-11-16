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
  config.lib.roles = {
    mkOptionalRole = mkRole false;
    mkDefaultRole = mkRole true;
  };
}

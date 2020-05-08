{ config, lib, ... }:

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

  options.roles.docker = config.lib.roles.mkOptionalRole "Docker tools";
  options.roles.go = config.lib.roles.mkOptionalRole "Golang dev";
  options.roles.heroku = config.lib.roles.mkOptionalRole "Heroku tools";
  options.roles.react-native = config.lib.roles.mkOptionalRole "React Native dev (Android)";
}

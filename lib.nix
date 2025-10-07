{ nixpkgs, nix-darwin, home-manager, ... }:

let
  inherit (nixpkgs.lib)
    evalModules
    mapAttrs'
    nameValuePair
    versionOlder
    versionAtLeast;

  dotfilesModule = { lib, ... }: let
    inherit (lib) mkOption types;

    mkRole = default: name: mkOption {
      inherit default;
      description = "Enable `${name}` role";
      type = types.bool;
    };
  in {
    options = {
      lib = mkOption {
        type = types.attrs;
        description = "Additional functions to use in configuration";
      };

      darwin = mkOption {
        type = types.deferredModule;
        description = "nix-darwin configuration";
        default = {};
      };

      hm = mkOption {
        type = types.deferredModule;
        description = "home-manager configuration";
        default = {};
      };

      user = mkOption {
        type = types.str;
        description = "Primary user of the system";
      };
    };

    config.lib.roles = {
      mkOptionalRole = mkRole false;
      mkDefaultRole = mkRole true;
    };
  };

in rec {
  /*
  Convert a macOS codename or version string into an
  { name = ...; version = ...; } attrset
  - i.e. if you supply a `name`, we determine the matching `version`, and vice versa

  The attrset also has `versionOlderThan` and `versionAtLeast` functions, curried to
  compare a (coerced) version/name to the stored `version`.
  */
  mkMacOS = spec': let
    nameToVersion = {
      mojave = "10.14";
      catalina = "10.15";
      big_sur = "11";
      monterey = "12";
      ventura = "13";
      sonoma = "14";
      sequoia = "15";
    };

    versionToName = mapAttrs' (name: version: nameValuePair version name) nameToVersion;

    parseVersion = spec: nameToVersion.${spec} or
    (if versionToName ? ${spec} then spec
    else throw "Invalid macOS version spec: ${spec}");

    version = parseVersion spec';
  in {
    inherit version;

    name = versionToName version;

    versionOlderThan = other: versionOlder version (parseVersion other);
    versionAtLeast = other: versionAtLeast version (parseVersion other);
  };

  /*
    Wrapper around nix-darwin's `darwinSystem`, which allows nix-darwin and
    home-manager modules to be declared in the same module system.

    Roles can be defined at the top level to turn on/off features.
  */
  mkDarwinSystem = {
    inputs,
    system,
    macosVersion,
    modules ? [],
    ...
  }@args: let
    dotfilesConfig = evalModules {
      modules = [
        dotfilesModule
        (builtins.removeAttrs args [ "inputs" "system" "macosVersion" "modules" ])
        {
          _module.args = {
            inherit inputs system;
            os = (mkMacOS macosVersion) // { isARM = system == "aarch64-darwin"; };
          };
        }
      ] ++ modules;
    };
  in nix-darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      dotfilesConfig.config.darwin
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${dotfilesConfig.config.user}.imports = [ dotfilesConfig.config.hm ];
        };
      }
    ];
  };
}

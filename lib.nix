{ nixpkgs, ... }:

let
  inherit (nixpkgs.lib) mapAttrs' nameValuePair versionOlder versionAtLeast;

in {
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
}

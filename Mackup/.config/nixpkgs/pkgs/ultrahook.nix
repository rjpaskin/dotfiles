{ buildRubyGem, ruby, linkFarm }:

let
  gemName = "ultrahook";

  # ultrahook has a dependency on the `json` gem,
  # but we don't include it since it's present in the
  # Ruby standard library
  src = buildRubyGem rec {
    inherit ruby gemName;
    version = "0.1.3";
    source.sha256 = "1dbwbd5d20jjffq8lwzpwx9wa2larm1n3r527p6kxl9w9rwsvnc1";
  };

  name = "bin/${gemName}";
in
  linkFarm gemName [
    { inherit name; path = "${src}/${name}"; }
  ]

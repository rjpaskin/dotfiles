{ buildRubyGem, ruby, linkFarm }:

let
  gemName = "autoterm";

  src = buildRubyGem rec {
    inherit ruby gemName;
    version = "0.2.0";
    source.sha256 = "0s7ha0k1c0p95i6i24zcw4nv8yv2hssxz658chcrqa6m7ys12691";
  };

  name = "bin/${gemName}";
in
  linkFarm gemName [
    { inherit name; path = "${src}/${name}"; }
  ]

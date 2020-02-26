{ buildRubyGem, ruby }:

buildRubyGem rec {
  inherit ruby;
  gemName = "autoterm";
  version = "0.2.0";
  source.sha256 = "0s7ha0k1c0p95i6i24zcw4nv8yv2hssxz658chcrqa6m7ys12691";
};

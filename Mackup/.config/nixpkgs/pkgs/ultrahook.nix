{ buildRubyGem, ruby }:

# ultrahook has a dependency on the `json` gem,
# but we don't include it since it's present in the
# Ruby standard library
buildRubyGem rec {
  inherit ruby;
  version = "0.1.3";
  gemName = "ultrahook";
  source.sha256 = "1dbwbd5d20jjffq8lwzpwx9wa2larm1n3r527p6kxl9w9rwsvnc1";
};

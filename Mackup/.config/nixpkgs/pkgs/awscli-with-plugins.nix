{
  stdenv, lib,
  buildEnv, makeWrapper, runCommandLocal,
  fetchzip,
  awscli
}:

let
  session-manager-plugin = stdenv.mkDerivation rec {
    pname = "session-manager-plugin";
    version = "1.2.7.0";

    src = fetchzip {
      url = "https://session-manager-downloads.s3.amazonaws.com/plugin/${version}/mac/sessionmanager-bundle.zip";
      sha256 = "1zall82dcpif70dwkhrn4jvjnrcsnq5r6z7bhgxd90kln4k9xz5x";
    };

    phases = [ "unpackPhase" "buildPhase" ];
    buildPhase = ''
      mkdir -p $out/bin
      cp $src/bin/${pname} $out/bin
    '';
  };

  # We don't output a `awscli` file to avoid collisions with
  # the main `awscli` package - we could use `ignoreCollisions`
  # with `buildEnv`, but that would hide other collisions that
  # may break things
  wrappedCLI = runCommandLocal "wrapped-awscli" {
    buildInputs = [ makeWrapper ];
  } ''
    mkdir -p $out/bin

    makeWrapper ${awscli}/bin/aws $out/bin/aws-wrapped \
      --prefix PATH : ${lib.makeBinPath [ session-manager-plugin ]}
  '';

in buildEnv {
  inherit (awscli) meta passthru;

  name = "awscli-with-plugins-${awscli.version}";
  paths = [ awscli wrappedCLI ];

  postBuild = ''
    rm $out/bin/aws
    mv $out/bin/aws-wrapped $out/bin/aws
  '';
}

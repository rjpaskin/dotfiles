{ stdenv, fetchFromGitHub, python27 }:

stdenv.mkDerivation rec {
  name = "dockutil";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "kcrawford";
    repo = name;
    rev = version;
    sha256 = "000y3jqbyk9hwcs27x7v2bifgjjfpmrafc5sfgqxn2lkw2wy9l7j";
  };

  buildInputs = [ python27 ];

  phases = [ "unpackPhase" "installPhase" ];

  # TODO: patch/remove other absolute paths?
  installPhase = ''
    mkdir -p $out/bin
    cp ${src}/scripts/${name} $out/bin/${name}
    patchShebangs $out/bin
  '';
}

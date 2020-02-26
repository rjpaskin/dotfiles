{ stdenv, fetchFromGitHub, python27 }:

stdenv.mkDerivation rec {
  name = "git-when-merged";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "mhagger";
    repo = name;
    rev = "v${version}";
    sha256 = "0sw98gmsnd4iki9fx455jga9m80bxvvfgys8i1r2fc7d5whc2qa6";
  };

  buildInputs = [ python27 ];

  phases = [ "unpackPhase" "installPhase" ];

  # TODO: patch path to Git?
  installPhase = ''
    mkdir -p $out/bin
    cp ${src}/bin/${name} $out/bin/${name}
    patchShebangs $out/bin
  '';
}

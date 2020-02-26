{ writeScriptBin, stdenv, nix }:

writeScriptBin "nix-rebuild" ''
  #!${stdenv.shell}
  if ! command -v nix-env &>/dev/null; then
      echo "warning: nix-env was not found in PATH, add nix to userPackages" >&2
      PATH=${nix}/bin:$PATH
  fi
  exec nix-env -f '<nixpkgs>' -r -iA userPackages "$@"
''

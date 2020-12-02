let
  # Adapted from https://nixos.wiki/wiki/Flakes#Using_flakes_project_from_a_legacy_Nix
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);

  flake-compat = let
    inherit (lock.nodes.flake-compat.locked) rev narHash;
  in builtins.fetchTarball {
    url = "https://api.github.com/repos/edolstra/flake-compat/tarball/${rev}";
    sha256 = narHash;
  };

  flake = import flake-compat {
    src = ./.;
  };

in flake.defaultNix

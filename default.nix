rec {
  nixpkgs = import <nixpkgs> {};
  pkgs = nixpkgs;

  home-manager-path = builtins.toPath <home-manager>;
  home-manager = import home-manager-path {};
}

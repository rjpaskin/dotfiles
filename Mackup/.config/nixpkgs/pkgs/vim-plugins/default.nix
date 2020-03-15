{ lib, fetchFromGitHub, vimUtils, callPackage }:

let
  plugins = callPackage ./generated.nix {
    inherit lib fetchFromGitHub;
    inherit (vimUtils) buildVimPluginFrom2Nix;
  };

in

  lib.recurseIntoAttrs plugins

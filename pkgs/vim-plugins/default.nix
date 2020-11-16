{ lib, fetchFromGitHub, vimUtils, callPackage }:

with vimUtils;

let
  plugins = callPackage ./generated.nix {
    inherit lib fetchFromGitHub buildVimPluginFrom2Nix;

    overrides = self: super: {
      deoplete-nvim = buildVimPluginFrom2Nix rec {
        pname = "deoplete.nvim";
        version = "5.1";
        src = fetchFromGitHub {
          owner = "Shougo";
          repo = pname;
          rev = "refs/tags/${version}";
          sha256 = "1ira7g8f1rzgjp8qzsf7vx265y58665fbh1yp28m9r19j97v2aqp";
        };
      };

      denite-nvim = buildVimPluginFrom2Nix rec {
        pname = "denite.nvim";
        version = "2.1";
        src = fetchFromGitHub {
          owner = "Shougo";
          repo = pname;
          rev = "refs/tags/${version}";
          sha256 = "17fsngxpfy1m0r76c99xphwlcip85s4fyf9zj3vcdvb69hdgva2s";
        };
      };
    };
  };

in

  lib.recurseIntoAttrs plugins

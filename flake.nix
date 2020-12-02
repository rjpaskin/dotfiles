{
  description = "My dotfiles and machine setup";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Use our nixpkgs
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-compat }: let
    system = "x86_64-darwin";
    pkgs = nixpkgs.outputs.legacyPackages.${system};
  in rec {
    nixpkgs = pkgs; # used by `spec/support/deps/default.nix`

    hmConfig = {
      hostConfig, dotfilesRoot, username, homeDirectory
    }: home-manager.lib.homeManagerConfiguration rec {
      inherit system homeDirectory username;

      configuration = { lib, ... }: {
        _file = ./flake.nix;
        imports = [ ./home.nix hostConfig ];
        config._module.args = { inherit dotfilesRoot; };
      };
    };

    defaultPackage.${system} = {
      hostConfig,   # filename of extra config to use, git-ignored
      dotfilesRoot, # used to access files in this repo that are git-ignored
      username, homeDirectory
    }@args: with pkgs; let
      inherit (hmConfig args) activationPackage;

      systemEnv = buildEnv {
        name = "system-env";
        paths = [ nix cacert "${activationPackage}/home-path" ];
      };

    in linkFarm "system-bundle" [
      { name = "env"; path = systemEnv; }
      { name = "activate"; path = "${activationPackage}/activate"; }
    ];
  };
}

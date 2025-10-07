{ system, lib, ... }:

# configuration for Nix and nixpkgs

lib.mkMerge [
  # Nix
  {
    darwin = { config, ... }: {
      # Let Determinate Nix handle Nix configuration
      # See: https://docs.determinate.systems/guides/nix-darwin
      nix.enable = false;

      environment.etc."nix/nix.custom.conf".text = ''
        # Written by nix-darwin
        keep-outputs = true
      '';

      # `NIX_PATH` and `registry.json` have shorthands in nix-darwin, but require
      # `nix.enable` so we have to reimplement them here instead
      environment.variables.NIX_PATH = "nixpkgs=flake:nixpkgs";

      # See https://nix.dev/manual/nix/2.25/command-ref/new-cli/nix3-registry#registry-format
      environment.etc."nix/registry.json".text = builtins.toJSON {
        version = 2;
        flakes = [
          {
            from = {
              type = "indirect";
              id = "nixpkgs";
            };
            to = {
              type = "path";
              path = config.nixpkgs.flake.source;
            };
          }
        ];
      };
    };
  }

  # nixpkgs
  {
    darwin.nixpkgs = {
      hostPlatform = system;

      # Allows 1Password CLI to be used
      config.allowUnfree = true;
    };

    hm = {
      # Disable `man` so that we don't get `pkgs.man` and all its accompanying executables,
      # but still add `man` to `extraOutputsToInstall` as the `man` module does
      programs.man.enable = false;
      home.extraOutputsToInstall = [ "man" ];
    };
  }
]

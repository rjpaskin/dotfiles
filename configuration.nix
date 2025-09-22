{ config, ... }:

{
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # Let Determinate Nix handle Nix configuration
  # See: https://docs.determinate.systems/guides/nix-darwin
  nix.enable = false;

  # Global Homebrew settings
  homebrew = {
    enable = true;
    global.brewfile = true;
  };

  # Allows 1Password CLI to be used
  nixpkgs.config.allowUnfree = true;

  environment.variables.EDITOR = "nvim"; # override default of `nano`

  # These settings have shorthands in nix-darwin, but require `nix.enable`
  # so we have to reimplement them here instead
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
}

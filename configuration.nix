{ ... }:

{
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # Let Determinate Nix handle Nix configuration
  # See: https://docs.determinate.systems/guides/nix-darwin
  nix.enable = false;

  # Allows 1Password CLI to be used
  nixpkgs.config.allowUnfree = true;
}

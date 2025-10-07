{ inputs, ... }:

# Configuration for nix-darwin and home-manager themselves

{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  hm.home.stateVersion = "25.05";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  darwin.system.stateVersion = 6;

  darwin = {
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    home-manager.verbose = true;
  };
}

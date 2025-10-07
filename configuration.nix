{ config, ... }:

{
  # Global Homebrew settings
  homebrew = {
    enable = true;
    global.brewfile = true;
  };

  environment.shells = [
    "/run/current-system/sw/bin/zsh" # backup, just in case we bork user profile
    "/etc/profiles/per-user/${config.system.primaryUser}/bin/zsh"
  ];

  environment.variables = {
    EDITOR = "nvim"; # override default of `nano`
  };
}

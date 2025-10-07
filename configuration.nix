{ config, ... }:

{
  # Global Homebrew settings
  homebrew = {
    enable = true;
    global.brewfile = true;
  };

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true; # Use TouchID for sudo
    reattach = true; # Fix TouchID for sudo not working in tmux
  };

  environment.shells = [
    "/run/current-system/sw/bin/zsh" # backup, just in case we bork user profile
    "/etc/profiles/per-user/${config.system.primaryUser}/bin/zsh"
  ];

  environment.variables = {
    EDITOR = "nvim"; # override default of `nano`
    TERMINFO_DIRS = [ "/Applications/Ghostty.app/Contents/Resources/terminfo" ];
  };
}

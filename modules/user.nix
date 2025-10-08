{ config, lib, ... }:

lib.mkMerge [
  {
    hm.home.homeDirectory = lib.mkForce "/Users/${config.user}";
    darwin.system.primaryUser = config.user;

    darwin.security.pam.services.sudo_local = {
      enable = true;
      touchIdAuth = true; # Use TouchID for sudo
      reattach = true; # Fix TouchID for sudo not working in tmux
    };
  }

  {
    # Record the roles that were used
    hm.xdg.configFile."dotfiles/roles.json".text = builtins.toJSON config.roles;
  }
]

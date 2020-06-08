{ config, pkgs, lib, ... }:

with lib;

{
  options.roles = with config.lib.roles; {
    tmux = mkOptionalRole "Tmux";
    tmate = mkOptionalRole "Tmate";
  };

  config = mkMerge [
    {
      # This is used by autoterm so always needs be present
      home.symlinks = config.lib.mackup.mackupFiles [ ".tmuxinator" ];
    }

    (mkIf config.roles.tmux {
      home.packages = with pkgs; [
        reattach-to-user-namespace
        tmux
        tmuxinator
      ];

      home.symlinks = config.lib.mackup.mackupFiles [ ".tmux.conf" ];

      programs.zsh.initExtra = ''
        maybe_source "/usr/local/share/zsh/site-functions/tmuxinator.zsh"
      '';
    })

    (mkIf config.roles.tmate {
      home.packages = [ pkgs.tmate ];
    })
  ];
}

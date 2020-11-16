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
      home.file.".tmuxinator".source = config.lib.file.mkOutOfStoreSymlink ./tmuxinator;
    }

    (mkIf config.roles.tmux {
      home.packages = with pkgs; [
        reattach-to-user-namespace
        tmux
        tmuxinator
      ];

      home.file.".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink ./tmux.conf;
    })

    (mkIf config.roles.tmate {
      home.packages = [ pkgs.tmate ];
    })
  ];
}

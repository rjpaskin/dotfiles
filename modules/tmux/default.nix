{ config, pkgs, lib, dotfilesRoot, ... }:

with lib;

let
  root = "${dotfilesRoot}/modules/tmux";

in {
  options.roles = with config.lib.roles; {
    tmux = mkOptionalRole "Tmux";
    tmate = mkOptionalRole "Tmate";
  };

  config = mkMerge [
    {
      # This is used by autoterm so always needs be present
      home.file.".tmuxinator".source = config.lib.file.mkOutOfStoreSymlink "${root}/tmuxinator";
    }

    (mkIf config.roles.tmux {
      home.packages = with pkgs; [
        reattach-to-user-namespace
        tmux
        tmuxinator
      ];

      home.file.".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${root}/tmux.conf";
    })

    (mkIf config.roles.tmate {
      home.packages = [ pkgs.tmate ];
    })
  ];
}

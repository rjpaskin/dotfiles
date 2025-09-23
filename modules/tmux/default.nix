{ config, pkgs, lib, ... }:

with lib;

{
  options.roles = with config.lib.roles; {
    tmux = mkOptionalRole "Tmux";
    tmate = mkOptionalRole "Tmate";
  };

  config = mkMerge [
    (mkIf config.roles.tmux {
      home.packages = with pkgs; [
        reattach-to-user-namespace
        tmux
      ];

      home.file.".tmux.conf".source = ./tmux.conf;
    })

    (mkIf config.roles.tmate {
      home.packages = [ pkgs.tmate ];
    })
  ];
}

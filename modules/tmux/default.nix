{ config, ... }:

{
  options.roles = with config.lib.roles; {
    tmux = mkOptionalRole "Tmux";
    tmate = mkOptionalRole "Tmate";
  };

  config.hm = { lib, pkgs, ... }: lib.mkMerge [
    (lib.mkIf config.roles.tmux {
      home.packages = with pkgs; [
        reattach-to-user-namespace
        tmux
      ];

      home.file.".tmux.conf".source = ./tmux.conf;
    })

    (lib.mkIf config.roles.tmate {
      home.packages = [ pkgs.tmate ];
    })
  ];
}

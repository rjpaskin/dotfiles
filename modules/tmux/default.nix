{ config, pkgs, lib, ... }:

with lib;

{
  options.roles = with config.lib.roles; {
    tmux = mkOptionalRole "Tmux";
    tmate = mkOptionalRole "Tmate";
  };

  config = mkMerge [
    {
      # `~/..tmuxinator/*.yml` files are used by autoterm so always need be present
      home.file = {
        ".tmuxinator/default.yml".source = ./tmuxinator/default.yml;
        ".tmuxinator/default_helper.rb".source = ./tmuxinator/default_helper.rb;
      };

      privateLinks."tmuxinator/*.yml" = ".tmuxinator";
    }

    (mkIf config.roles.tmux {
      home.packages = with pkgs; [
        reattach-to-user-namespace
        tmux
        tmuxinator
      ];

      home.file.".tmux.conf".source = ./tmux.conf;
    })

    (mkIf config.roles.tmate {
      home.packages = [ pkgs.tmate ];
    })
  ];
}

{ config, lib, ... }:

{
  options.roles.heroku = config.lib.roles.mkOptionalRole "Heroku tools";

  config.hm = lib.mkIf config.roles.heroku ({ pkgs, ... }: {
    home.packages = [
      pkgs.heroku
    ];

    programs.zsh.oh-my-zsh.plugins = [ "heroku" ];
  });
}

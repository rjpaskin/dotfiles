{ lib, ... }:

with lib;

{
  roles = {
    aws = true;
    clojure = true;
    docker = true;
    eqmac = true;
    git = true;
    git-standup = true;
    harvest = true;
    heroku = true;
    javascript = true;
    ngrok = true;
    postman = true;
    react-native = true;
    rubocop = true;
    ruby = true;
    slack = true;
    sql-clients = true;
    tmux = true;
    whatsapp = true;
    zoom = true;
  };

  programs.zsh.initExtra = mkAfter ''
    [ -n "$IN_AUTOTERM_SPEC" ] && HISTFILE=""
  '';

  # ruby.rubocop.package = pkgs.rubocop_0_59;
}

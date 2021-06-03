{ config, lib, pkgs, ... }:

with lib;

{
  options.roles = with config.lib.roles; {
    flight-plan = mkOptionalRole "FlightPlan tools";
    aws = mkOptionalRole "AWS tools";
  };

  config = mkMerge [
    # Basics
    {
      home.packages = with pkgs; [
        fzf
        jq
        ncdu
        shellcheck
        universal-ctags
      ];
    }

    (let
      config = "silver_searcher/ignore";
    in {
      home.packages = [ pkgs.silver-searcher ];
      xdg.configFile.${config}.text = ''
        .git/
        vendor/assets/
        public/
      '';
      programs.zsh.shellAliases = {
        ag = "ag --hidden --path-to-ignore ~/.config/${config}";
      };
    })

    # My packages
    { home.packages = [ pkgs.autoterm ]; }

    (mkIf config.roles.flight-plan {
      home.packages = [ pkgs.flight_plan_cli ];
    })

    (mkIf config.roles.aws {
      home.packages = [ pkgs.awscli-with-plugins ];
      programs.zsh.initExtra = ''
        source $HOME/.nix-profile/share/zsh/site-functions/aws_zsh_completer.sh
      '';
    })

    (let
      pkg = pkgs.highlight;
    in {
      home.packages = [ pkg ];
      targets.darwin.defaults."org.n8gray.QLColorCode".pathHL = "${pkg}/bin/highlight";
    })
  ];
}

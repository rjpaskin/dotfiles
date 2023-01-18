{ config, lib, pkgs, flakeRepos, ... }:

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
      ];
    }

    {
      home.packages = [ pkgs.universal-ctags ];
      xdg.configFile = {
        "ctags/config.ctags".source = "${flakeRepos.thoughtbot-dotfiles}/ctags.d/config.ctags";

        # See https://github.com/universal-ctags/ctags/issues/261
        "ctags/nix.ctags".text = ''
          --langdef=Nix
          --langmap=Nix:.nix
          --regex-Nix=/([^ \t*]*)[ \t]*=.*:/\1/f/
        '';
      };
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
      home.packages = with pkgs; [ awscli-with-plugins aws-vault ];
      programs.zsh = {
        sessionVariables.AWS_VAULT_KEYCHAIN_NAME = "login";
        initExtra = ''
          source $HOME/.nix-profile/share/zsh/site-functions/aws_zsh_completer.sh
        '';
      };
    })
  ];
}

{ config, lib, pkgs, flakeRepos, ... }:

let
  jq-with-all-outputs = pkgs.jq.overrideAttrs (attrs: {
    meta.outputsToInstall = (attrs.meta.outputsToInstall or []) ++ [ "out" "bin" "man" "dev" "doc" ];
  });

  thoughtbot-dotfiles = pkgs.fetchFromGitHub {
    owner = "thoughtbot";
    repo = "dotfiles";
    rev = "07bff4faab635a461a49b37705a5961f7dbcf123";
    hash = "sha256-coht351cMoD3umPkvdFmsm3Dek1M/5+VkUjebsNjDyc=";
  };

in {
  options.roles = with config.lib.roles; {
    aws = mkOptionalRole "AWS tools";
  };

  config = lib.mkMerge [
    # Basics
    {
      home.packages = with pkgs; [
        _1password-cli
        chezmoi
        fzf
        jq-with-all-outputs
        shellcheck
      ];
    }

    {
      home.packages = [ pkgs.ncdu ];
      xdg.configFile."ncdu/config".text = ''
        --color off
      '';
    }

    {
      home.packages = [ pkgs.universal-ctags ];
      xdg.configFile = {
        "ctags/config.ctags".source = "${thoughtbot-dotfiles}/ctags.d/config.ctags";

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
    {
      home.packages = [
        (pkgs.callPackage ../pkgs/autoterm.nix {
          ruby = config.programs.ruby.defaultPackage;
        })
      ];
    }

    (lib.mkIf config.roles.aws {
      home.packages = with pkgs; [
        awscli2
        ssm-session-manager-plugin
        aws-vault
        git-remote-codecommit
      ];
      programs.zsh = {
        sessionVariables.AWS_VAULT_KEYCHAIN_NAME = "login";
        initContent = ''
          source /etc/profiles/per-user/$USER/share/zsh/site-functions/aws_zsh_completer.sh
        '';
      };

      home.extraProfileCommands = ''
        mv $out/bin/aws_zsh_completer.sh $out/share/zsh/site-functions
      '';
    })
  ];
}

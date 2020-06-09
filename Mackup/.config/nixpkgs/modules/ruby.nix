{ config, lib, pkgs, ... }:

with lib;

{
  options.roles = with config.lib.roles; {
    ruby = mkOptionalRole "Ruby dev";

    mailcatcher = mkOptionalRole "MailCatcher";
    ultrahook = mkOptionalRole "Ultrahook";
  };

  config = mkMerge [
    (mkIf config.roles.ruby {
      programs.neovim.plugs = with pkgs.vimPlugins; [
        splitjoin-vim
        vim-bundler
        vim-endwise
        vim-rails
        vim-rspec
        vim-ruby
        vim-ruby-refactoring
        vim-rubyhash
        vim-textobj-rubyblock
        vim-yaml-helper # Pretty much only used for i18n YAML files
      ];

      programs.zsh = {
        oh-my-zsh.plugins = ["bundler" "gem" "rails"];

        initExtra = ''
          # Don't try to run bundled commands in docker projects
          for bcmd in $bundled_commands; do
            read -d "" _eval <<EOF
              maybe_bundled_$bcmd() {
                setopt localoptions extendedglob

                if ! [ -z (../)#docker-compose.yml(N) ]; then
                  unbundled_$bcmd
                else
                  bundled_$bcmd
                fi
              }
          EOF
            # Line above should be flush with `for`

            eval "$_eval"
            alias "$bcmd"="maybe_bundled_$bcmd"
          done

          unset bcmd _eval

          # rbenv setup
          if command -v rbenv >/dev/null; then
            eval "$(rbenv init - --no-rehash)"
          fi
        '';
      };

      home.symlinks = config.lib.mackup.mackupFiles [
        ".gemrc"
        ".irbrc"
        ".rbenv/default-gems"
      ];
    })

    (mkIf config.roles.mailcatcher {
      home.packages = [ pkgs.mailcatcher ];
    })

    (mkIf config.roles.ultrahook {
      home.packages = [ pkgs.ultrahook ];
    })
  ];
}

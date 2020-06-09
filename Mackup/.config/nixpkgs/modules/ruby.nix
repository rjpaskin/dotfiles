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
        oh-my-zsh.plugins = ["gem" "rails"];

        initExtraBeforeCompInit = ''
          # Load completions for Bundler
          fpath+=(${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/bundler)
        '';

        initExtra = ''
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

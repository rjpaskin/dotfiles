{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ruby;

  gemsFunctionType = mkOptionType {
    name = "gems";
    description = "gems to install";
    check = x: if isFunction x then isList (x pkgs.ruby.packages) else false;
    merge = mergeOneOption;
  };

in {
  options = {
    roles = with config.lib.roles; {
      ruby = mkOptionalRole "Ruby dev";

      mailcatcher = mkOptionalRole "MailCatcher";
      rubocop = mkOptionalRole "RuboCop";
      ultrahook = mkOptionalRole "Ultrahook";
    };

    programs.ruby = {
      defaultPackage = mkOption {
        type = types.package;
        description = "Package to use as `ruby` as default";
        default = pkgs.ruby_2_6;
      };

      defaultGems = mkOption {
        type = gemsFunctionType;
        description = "Gems to install with default ruby";
        default = gems: [ gems.byebug ];
      };
    };

    programs.rubocop = {
      package = mkOption {
        type = types.package;
        description = "RuboCop package to install into profile";
        default = pkgs.rubocop_0_59;
      };
    };
  };

  config = mkMerge [
    (mkIf config.roles.ruby {
      home.packages = [
        (cfg.defaultPackage.withPackages cfg.defaultGems)
      ];

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
      };

      home.file.".gemrc".text = ''
        gem: --no-ri --no-rdoc --no-document
      '';

      # Ensure IRB history directory exists
      xdg.dataFile."irb/.keep".text = "";

      home.file.".irbrc".source = ./ruby/irbrc;
    })

    (mkIf config.roles.rubocop {
      home.packages = [ config.programs.rubocop.package ];
    })

    (mkIf config.roles.mailcatcher {
      home.packages = [ pkgs.mailcatcher ];
    })

    (mkIf config.roles.ultrahook {
      home.packages = [ pkgs.ultrahook ];
    })
  ];
}

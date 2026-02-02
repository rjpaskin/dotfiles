{ config, inputs, system, ... }:

let
  inherit (config) roles;

in {
  options.roles = with config.lib.roles; {
    ruby = mkOptionalRole "Ruby dev";

    mailcatcher = mkOptionalRole "MailCatcher";
    rubocop = mkOptionalRole "RuboCop";
  };

  config.hm = { config, lib, pkgs, ... }: let
    inherit (lib) isFunction isList mergeOneOption mkIf mkMerge mkOption mkOptionType types;

    cfg = config.programs.ruby;

    gemsFunctionType = mkOptionType {
      name = "gems";
      description = "gems to install";
      check = x: if isFunction x then isList (x pkgs.ruby.packages) else false;
      merge = mergeOneOption;
    };

  in {
    options = {
      programs.ruby = {
        defaultPackage = mkOption {
          type = types.package;
          description = "Package to use as `ruby` as default";
          default = pkgs.ruby_3_4;
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
          default = pkgs.rubocop.override { ruby = cfg.defaultPackage; };
        };
      };
    };

    config = mkMerge [
      (mkIf roles.ruby {
        home.packages = [
          (cfg.defaultPackage.withPackages cfg.defaultGems)
        ];

        programs.neovim.plugins = with pkgs.vimPlugins; [
          splitjoin-vim
          vim-endwise
          vim-rails
          vim-ruby
        ] ++ (with inputs.self.packages.${system}; [
          vim-bundler
          vim-rspec
          vim-ruby-refactoring
          vim-rubyhash
          vim-textobj-rubyblock
          vim-yaml-helper # Pretty much only used for i18n YAML files
        ]);

        programs.zsh = {
          oh-my-zsh.plugins = [ "gem" "rails" ];

          initContent = lib.mkMerge [
            (lib.mkOrder 550 ''
                # Load completions for Bundler
                fpath+=(${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/bundler)
            '')

            # Return all keys (`(k)`) starting with (`(R)`) "ruby script/"
            # in the "$aliases" associative array
            (lib.mkAfter ''
              # Remove aliases for ancient versions of Rails
              for alias_name in "''${(@k)aliases[(R)ruby script/*]}"; do
                unalias "$alias_name"
              done
            '')
          ];
        };

        home.file.".gemrc".text = ''
          gem: --no-ri --no-rdoc --no-document
        '';

          # Ensure IRB history directory exists
          xdg.dataFile."irb/.keep".text = "";

          home.file.".irbrc".source = ./ruby/irbrc;
        })

        (mkIf roles.rubocop {
          home.packages = [ config.programs.rubocop.package ];
        })
      ];
    };
  }

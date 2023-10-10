{
  description = "My dotfiles and machine setup";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Use our nixpkgs
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    conjure = { url = "github:Olical/conjure/v4.8.0"; flake = false; };
    splitjoin-vim = { url = "github:AndrewRadev/splitjoin.vim"; flake = false; };
    vim-alias = { url = "github:Konfekt/vim-alias"; flake = false; };
    vim-bundler = { url = "github:tpope/vim-bundler"; flake = false; };
    vim-crystal = { url = "github:vim-crystal/vim-crystal"; flake = false; };
    vim-mkdir = { url = "github:pbrisbin/vim-mkdir"; flake = false; };
    vim-prettier = { url = "github:prettier/vim-prettier"; flake = false; };
    vim-rails = { url = "github:tpope/vim-rails"; flake = false; };
    vim-rspec = { url = "github:thoughtbot/vim-rspec"; flake = false; };
    vim-ruby-refactoring = {
      url = "github:ecomba/vim-ruby-refactoring/main"; flake = false;
    };
    vim-rubyhash = { url = "github:rorymckinley/vim-rubyhash"; flake = false; };
    vim-textobj-rubyblock = {
      url = "github:nelstrom/vim-textobj-rubyblock"; flake = false;
    };
    vim-textobj-variable-segment = {
      url = "github:Julian/vim-textobj-variable-segment"; flake = false;
    };
    vim-yaml-helper = { url = "github:lmeijvogel/vim-yaml-helper"; flake = false; };

    thoughtbot-dotfiles = {
      url = "github:thoughtbot/dotfiles";
      flake = false;
    };
  };

  outputs = {
    self, nixpkgs, home-manager,
    flake-compat, # this needs to be a named argument for it to work
    thoughtbot-dotfiles,
    ...
  }@args: let
    hmConfig = {
      hostConfig, machine, pkgs,
      username, homeDirectory,
    }: home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs;

      modules = [
        ({ lib, pkgs, ... }: {
          _file = ./flake.nix;
          config._module.args = {
            flakeRepos = {
              inherit thoughtbot-dotfiles;
            };

            machine = let
              aliases = {
                mojave = "10.14";
                catalina = "10.15";
                big_sur = "11";
              };
            in machine // rec {
              isARM = pkgs.stdenv.hostPlatform.isAarch;
              sameOrNewerThan = version': let
                version = lib.attrByPath [version'] version' aliases;
              in (builtins.compareVersions machine.macOSversion version) > -1;
              olderThan = version: ! sameOrNewerThan version;
            };
          };
        })
        ./home.nix
        hostConfig
        { home = { inherit username homeDirectory; }; }
      ];
    };

    generateOutput = system: let
      pkgs = import nixpkgs {
        inherit system;
        # Ensure our overlays are used in `script/switch`
        overlays = import ./overlays.nix;
        config.permittedInsecurePackages = [
          "ruby-2.7.8"
          "openssl-1.1.1w"
          "wrapped-ruby-dotfiles-specs" # because they use Ruby 2.7
        ];
      };
    in {
      # used by `overlays.nix`
      vimPlugins = with builtins; foldl' (acc: name:
        if (builtins.match ".*vim.*|conjure" name) != null then
        let plugin = args.${name}; in (acc // {
          ${name} = pkgs.vimUtils.buildVimPlugin {
            pname = name;
            version = substring 0 8 plugin.lastModifiedDate;
            src = plugin;
          };
        })
        else acc) {} (attrNames args);

      nixpkgs = pkgs; # used by `script/update-lockfile`

      dotfiles = {
        # filename of extra config to use
        hostConfig,

        # Info about the current machine. Includes:
        # dotfilesDirectory: used to access git-ignored files in this repo or that can't be in the Nix Store
        machine,

        username, homeDirectory
      }@args: with pkgs; let
        inherit (hmConfig (args // { inherit pkgs; })) activationPackage;

        systemEnv = buildEnv {
          name = "system-env";
          paths = [ nix cacert "${activationPackage}/home-path" ];
        };

      in linkFarm "system-bundle" [
        { name = "env"; path = systemEnv; }
        { name = "activate"; path = "${activationPackage}/activate"; }
      ];

      tests = with pkgs; let
        gems = bundlerEnv {
          ruby = ruby_2_7;
          name = "dotfiles-specs";
          gemdir = ./.;
          postBuild = ''
            rm $out/bin/bundle*
          '';
        };
      in buildEnv {
        name = "dotfiles-specs-with-ruby";
        paths = [ gems gems.wrappedRuby ];
        meta.mainProgram = "rspec";
      };
    };
  in {
    legacyPackages."x86_64-darwin" = generateOutput "x86_64-darwin";
    legacyPackages."aarch64-darwin" = generateOutput "aarch64-darwin";
  };
}

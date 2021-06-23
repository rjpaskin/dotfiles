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
  };

  outputs = { self, nixpkgs, home-manager, flake-compat, ... }@args: let
    system = "x86_64-darwin";
    pkgs = nixpkgs.outputs.legacyPackages.${system};

    vimPlugins = with builtins; foldl' (acc: name:
      if (builtins.match ".*vim.*|conjure" name) != null then
        let plugin = args.${name}; in (acc // {
          ${name} = pkgs.vimUtils.buildVimPluginFrom2Nix {
            pname = name;
            version = substring 0 8 plugin.lastModifiedDate;
            src = plugin;
          };
        })
      else acc) {} (attrNames args);
  in rec {
    inherit vimPlugins; # used by `overlays.nix`
    nixpkgs = pkgs; # used by `spec/support/deps/default.nix`

    hmConfig = {
      hostConfig, dotfilesRoot, username, homeDirectory
    }: home-manager.lib.homeManagerConfiguration rec {
      inherit system homeDirectory username;

      configuration = { lib, ... }: {
        _file = ./flake.nix;
        imports = [ ./home.nix hostConfig ];
        config._module.args = { inherit dotfilesRoot; };
      };
    };

    defaultPackage.${system} = {
      hostConfig,   # filename of extra config to use
      dotfilesRoot, # used to access files in this repo that are git-ignored
      username, homeDirectory
    }@args: with pkgs; let
      inherit (hmConfig args) activationPackage;

      systemEnv = buildEnv {
        name = "system-env";
        paths = [ nix cacert "${activationPackage}/home-path" ];
      };

    in linkFarm "system-bundle" [
      { name = "env"; path = systemEnv; }
      { name = "activate"; path = "${activationPackage}/activate"; }
    ];
  };
}

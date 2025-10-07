{
  description = "My dotfiles and machine setup";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin }@inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-darwin" "aarch64-darwin" ];
    forAllSystemsWithPkgs = fn: forAllSystems (system: fn system nixpkgs.legacyPackages.${system});

    filterDerivations = nixpkgs.lib.filterAttrs (_: value: nixpkgs.lib.isDerivation value);

    dotfilesLib = import ./lib.nix inputs;

    shimModule = toplevel: {
      darwin = { config, ... }: {
        config = {
          inherit (config.home-manager.users.${toplevel.config.user}.nix-darwin) homebrew;
        };
      };

      hm = { lib, ... }: {
        imports = [
          ./modules/roles.nix

          ./modules/docker
          ./modules/javascript.nix
          ./modules/misc.nix
          ./modules/pkgs.nix
          ./modules/ssh.nix
          ./modules/macos_defaults
        ];

        options.nix-darwin.homebrew.casks = lib.mkOption {
          type = lib.types.listOf lib.types.anything;
        };
      };
    };

    mkDarwinSystem = args: let
      defaults = {
        inherit inputs;
        user = "rob";
        system = "aarch64-darwin";
      };
    in dotfilesLib.mkDarwinSystem (defaults // args // {
      modules = [
        shimModule
        ./modules/git.nix
        ./modules/homebrew.nix
        ./modules/init.nix
        ./modules/neovim
        ./modules/nix_and_nixpkgs.nix
        ./modules/ruby.nix
        ./modules/terminal.nix
        ./modules/user.nix
        ./modules/zsh.nix
      ] ++ (args.modules or []);
    });

  in {
    darwinConfigurations."360inmac-51320" = mkDarwinSystem {
      user = "rpaskin";
      macosVersion = "sequoia";

      roles = {
        dash = true;
        git = true;
        ngrok = true;
        ruby = true;
        sql-clients = true;
      };

      hm.roles = {
        aws = true;
        docker = true;
        javascript = true;
      };
    };

    lib = dotfilesLib;

    packages = forAllSystemsWithPkgs (_: pkgs: filterDerivations (pkgs.callPackage ./pkgs/vim-plugins.nix {}));

    apps = forAllSystemsWithPkgs (_: pkgs: {
      tests = let
        inherit (pkgs) bundlerEnv ruby_3_1 buildEnv;

        gems = bundlerEnv {
          ruby = ruby_3_1;
          name = "dotfiles-specs";
          gemdir = ./.;
          postBuild = ''
            rm $out/bin/bundle*
          '';
        };

        testEnv = buildEnv {
          name = "dotfiles-specs-with-ruby";
          paths = [ gems gems.wrappedRuby ];
          meta.mainProgram = "rspec";
        };
      in {
        type = "app";
        program = nixpkgs.lib.getExe testEnv;
        meta.description = "Test suite env for dotfiles";
      };
    });
  };
}

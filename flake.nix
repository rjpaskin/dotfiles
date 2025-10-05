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

    mkDarwinSystem = {
      macOS,
      system ? "aarch64-darwin",
      user ? "rob",
      roles
    }: let
      dotfilesModule = {
        _file = ./flake.nix;
        config._module.args.dotfiles = {
          inputPaths = builtins.mapAttrs (_: input: input.outPath) inputs;
          packages = self.packages.${system};
          os = let
            aliases = {
              mojave = "10.14";
              catalina = "10.15";
              big_sur = "11";
              monterey = "12";
              ventura = "13";
              sonoma = "14";
              sequoia = "15";
            };
            macOSNameToVersion = name: nixpkgs.lib.attrByPath [ name ] name aliases;
            currentVersion = macOSNameToVersion macOS;

            sameOrNewerThan = version: (builtins.compareVersions currentVersion (macOSNameToVersion version)) > -1;
          in {
            inherit sameOrNewerThan;
            isARM = system == "aarch64-darwin";
            olderThan = version: ! sameOrNewerThan version;
          };
        };
      };
    in nix-darwin.lib.darwinSystem {
      inherit system;

      modules = [
        ./configuration.nix
        ./modules/roles.nix
        home-manager.darwinModules.home-manager
        dotfilesModule
        ({ config, options, ... }: {
          _file = ./flake.nix;

          inherit (config.home-manager.users.${user}.nix-darwin) homebrew;

          nixpkgs.hostPlatform = system;

          system = {
            # Set Git commit hash for darwin-version.
            configurationRevision = self.rev or self.dirtyRev or null;
            primaryUser = user;
          };

          # Use home-manager as a submodule of nix-darwin
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            verbose = true;
            users.${user} = { lib, ... }: {
              imports = [ ./home.nix dotfilesModule ];
              config = { inherit roles; };

              options.nix-darwin.homebrew.casks = lib.mkOption {
                type = lib.types.listOf lib.types.anything;
              };
            };
          };
        })
      ];
    };

  in {
    darwinConfigurations."360inmac-51320" = mkDarwinSystem {
      user = "rpaskin";
      macOS = "sequoia";

      roles = {
        aws = true;
        dash = true;
        docker = true;
        git = true;
        javascript = true;
        ngrok = true;
        ruby = true;
        sql-clients = true;
      };
    };

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

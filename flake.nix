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

  outputs = { self, nixpkgs, home-manager, nix-darwin }: let
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-darwin" "aarch64-darwin" ];
  in {
    darwinConfigurations."360inmac-51320" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./configuration.nix
        home-manager.darwinModules.home-manager
        # Specific to this host and file
        {
          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
          nixpkgs.hostPlatform = "aarch64-darwin";

        }
        # Use home-manager as a submodule of nix-darwin
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            verbose = true;
            users.rpaskin = { ... }: {
              imports = [ ./home.nix ];

              config.roles = {
                aws = true;
                docker = true;
                git = true;
                git-standup = true;
                javascript = true;
                ruby = true;
              };
            };
          };
        }
      ];
    };

    apps = forAllSystems (system: {
      tests = let
        inherit (nixpkgs.legacyPackages.${system}) bundlerEnv ruby_3_1 buildEnv;

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
      };
    });
  };
}

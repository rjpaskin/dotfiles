let
  customisations = self: super: {
    # Prevent extra outputs from being GC-ed, since they just get
    # redownloaded the next time nix-rebuild is run
    cacert = super.cacert.overrideAttrs (attrs: {
      meta.outputsToInstall = (attrs.meta.outputsToInstall or []) ++ [ "out" "unbundled" ];
    });

    jq = super.jq.overrideAttrs (attrs: {
      meta.outputsToInstall = (attrs.meta.outputsToInstall or []) ++ [ "out" "bin" "man" "dev" "doc" ];
    });

    # https://nixos.org/nixpkgs/manual/#how-to-override-a-python-package-using-overlays
    python37 = super.python37.override {
      packageOverrides = python-self: python-super: {
        msgpack = python-super.msgpack.overridePythonAttrs (old: rec {
          version = "0.6.2";

          src = old.src.override {
            inherit version;
            sha256 = "0c0q3vx0x137567msgs5dnizghnr059qi5kfqigxbz26jf2jyg7a";
          };
        });
      };
    };
  };

  newPackages = self: super: let
    overrides = {
      ruby = super.ruby_2_6;
    };

    callPackage = super.lib.callPackageWith (super // overrides);

  in {
    autoterm = callPackage ./pkgs/autoterm.nix {};
    awscli-with-plugins = callPackage ./pkgs/awscli-with-plugins.nix {};
    dockutil = callPackage ./pkgs/dockutil.nix {};
    flight_plan_cli = callPackage ./pkgs/flight_plan_cli {};
    git-when-merged = callPackage ./pkgs/git-when-merged.nix {};
    git-with-helpers = callPackage ./pkgs/git-with-helpers {};
    parity-gem = callPackage ./pkgs/parity {}; # already a package called "parity"
    rubocop_0_59 = callPackage ./pkgs/rubocop_0_59 {};
    ultrahook = callPackage ./pkgs/ultrahook.nix {};

    heroku = super.heroku.overrideAttrs(old: {
      passthru.withPlugins = callPackage ./pkgs/heroku-with-plugins.nix {
        inherit (super) heroku;
      };
    });

    vimPlugins = super.vimPlugins // super.callPackage ./pkgs/vim-plugins {};
  };

in [ customisations newPackages ]

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
    python38 = super.python38.override {
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

    vimPlugins = super.vimPlugins // {
      deoplete-nvim = self.vimUtils.buildVimPluginFrom2Nix rec {
        pname = "deoplete.nvim";
        version = "5.1";
        src = self.fetchFromGitHub {
          owner = "Shougo";
          repo = pname;
          rev = "refs/tags/${version}";
          sha256 = "1ira7g8f1rzgjp8qzsf7vx265y58665fbh1yp28m9r19j97v2aqp";
        };
      };

      denite-nvim = self.vimUtils.buildVimPluginFrom2Nix rec {
        pname = "denite.nvim";
        version = "2.1";
        src = self.fetchFromGitHub {
          owner = "Shougo";
          repo = pname;
          rev = "refs/tags/${version}";
          sha256 = "17fsngxpfy1m0r76c99xphwlcip85s4fyf9zj3vcdvb69hdgva2s";
        };
      };
    };
  };

  newPackages = self: super: let
    overrides = {
      ruby = super.ruby_2_7;
    };

    callPackage = super.lib.callPackageWith (super // overrides);

  in {
    autoterm = callPackage ./pkgs/autoterm.nix {};
    awscli-with-plugins = callPackage ./pkgs/awscli-with-plugins.nix {};
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

    vimPlugins = super.vimPlugins // (import ./default.nix).vimPlugins;
  };

in [ customisations newPackages ]

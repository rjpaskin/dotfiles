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

  # https://github.com/nix-community/home-manager/issues/2478
  # https://github.com/LnL7/nix-darwin/pull/379/files
  fixZshNixCompletions = self: super: {
    nix-zsh-completions = super.nix-zsh-completions.overrideAttrs (old: {
      installPhase = old.installPhase + ''
        rm $out/share/zsh/site-functions/_nix
      '';
    });
  };

in [ customisations newPackages fixZshNixCompletions ]

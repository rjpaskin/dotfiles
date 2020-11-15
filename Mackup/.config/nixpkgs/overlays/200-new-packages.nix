self: super:

let
  overrides = {
    ruby = super.ruby_2_6;
  };

  callPackage = super.lib.callPackageWith (super // overrides);

in {
  autoterm = callPackage ../pkgs/autoterm.nix {};
  dockutil = callPackage ../pkgs/dockutil.nix {};
  flight_plan_cli = callPackage ../pkgs/flight_plan_cli {};
  git-when-merged = callPackage ../pkgs/git-when-merged.nix {};
  git-with-helpers = callPackage ../pkgs/git-with-helpers {};
  heroku-with-plugins = callPackage ../pkgs/heroku-with-plugins.nix {};
  nix-rebuild = callPackage ../pkgs/nix-rebuild.nix {};
  parity-gem = callPackage ../pkgs/parity {}; # already a package called "parity"
  rubocop_0_59 = callPackage ../pkgs/rubocop_0_59 {};
  ultrahook = callPackage ../pkgs/ultrahook.nix {};

  heroku = super.heroku.overrideAttrs(old: {
    passthru.withPlugins = callPackage ../pkgs/heroku-with-plugins.nix {
      inherit (super) heroku;
    };
  });

  vimPlugins = super.vimPlugins // super.callPackage ../pkgs/vim-plugins {};
}

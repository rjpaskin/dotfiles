self: super:

let
  ruby = super.ruby_2_6;

in {
  autoterm = super.callPackage ../pkgs/autoterm.nix { inherit ruby; };
  dockutil = super.callPackage ../pkgs/dockutil.nix {};
  flight_plan_cli = super.callPackage ../pkgs/flight_plan_cli { inherit ruby; };
  git-when-merged = super.callPackage ../pkgs/git-when-merged.nix {};
  heroku-with-plugins = super.callPackage ../pkgs/heroku-with-plugins.nix {};
  nix-rebuild = super.callPackage ../pkgs/nix-rebuild.nix {};
  rubocop_0_59 = super.callPackage ../pkgs/rubocop_0_59 { inherit ruby; };
  ultrahook = super.callPackage ../pkgs/ultrahook.nix { inherit ruby; };

  vimPlugins = super.vimPlugins // super.callPackage ../pkgs/vim-plugins {};
}

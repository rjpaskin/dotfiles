self: super:

let
  ruby = super.ruby_2_6;

in {
  autoterm = super.callPackage ../pkgs/autoterm.nix { inherit ruby; };
  dockutil = super.callPackage ../pkgs/dockutil.nix {};
  git-when-merged = super.callPackage ../pkgs/git-when-merged.nix {};
  heroku-with-plugins = super.callPackage ../pkgs/heroku-with-plugins.nix {};
  mackup = super.python38.pkgs.callPackage ../pkgs/mackup.nix {};
  nix-rebuild = super.callPackage ../pkgs/nix-rebuild.nix {};
}

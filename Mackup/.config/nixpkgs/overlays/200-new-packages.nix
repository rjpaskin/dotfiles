self: super:

{
  dockutil = super.callPackage ../pkgs/dockutil.nix {};
  git-when-merged = super.callPackage ../pkgs/git-when-merged.nix {};
  mackup = super.python38.pkgs.callPackage ../pkgs/mackup.nix {};
  nix-rebuild = super.callPackage ../pkgs/nix-rebuild.nix {};
}

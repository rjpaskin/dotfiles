self: super:

{
  dockutil = super.callPackage ../pkgs/dockutil.nix {};
  git-when-merged = super.callPackage ../pkgs/git-when-merged.nix {};
  nix-rebuild = super.callPackage ../pkgs/nix-rebuild.nix {};
}

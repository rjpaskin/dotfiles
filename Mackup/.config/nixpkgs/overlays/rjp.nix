self: super:

{
  userPackages = super.userPackages or {} // {
    # Default packages:
    inherit (self) cacert nix;

    # Packages
    inherit (self) ncdu;

    nix-rebuild = super.callPackage ../pkgs/nix-rebuild.nix {};
  };
}

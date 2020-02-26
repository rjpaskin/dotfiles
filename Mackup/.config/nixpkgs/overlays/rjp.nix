self: super:

{
  userPackages = super.userPackages or {} // {
    #==== Nix stuff ====
    inherit (self)
      cacert      # required to fetch from cache.nixos.org
      nix         # so that we have all the nix-* commands available
      ;

    #==== Packages ====
    inherit (self)
      fzf
      jq
      ncdu
      universal-ctags
      ;

    git-when-merged = super.callPackage ../pkgs/git-when-merged.nix {};
    nix-rebuild = super.callPackage ../pkgs/nix-rebuild.nix {};
  };
}

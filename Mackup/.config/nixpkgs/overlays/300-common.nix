self: super:

{
  userPackages = super.userPackages or {} // {
    #==== Nix stuff ====
    inherit (self)
      cacert      # required to fetch from cache.nixos.org
      nix         # so that we have all the nix-* commands available
      nix-rebuild
      ;

    #==== Packages ====
    inherit (self)
      dockutil
      fzf
      git-when-merged
      jq
      mackup
      ncdu
      universal-ctags
      ;
  };
}

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
      autoterm
      dockutil
      flight_plan_cli
      fzf
      git
      git-when-merged
      hadolint
      jq
      mackup
      ncdu
      nodejs
      oh-my-zsh
      reattach-to-user-namespace
      rlwrap
      ruby
      shellcheck
      silver-searcher
      tmux
      ultrahook
      universal-ctags
      yarn
      zsh

      heroku-with-plugins
      ;
  };
}

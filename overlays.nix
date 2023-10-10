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

in [ customisations ]

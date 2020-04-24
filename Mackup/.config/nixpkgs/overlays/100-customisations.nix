self: super:

{
  # Prevent extra outputs from being GC-ed, since they just get
  # redownloaded the next time nix-rebuild is run
  cacert = super.cacert.overrideAttrs (attrs: {
    meta.outputsToInstall = (attrs.meta.outputsToInstall or []) ++ [ "out" "unbundled" ];
  });

  jq = super.jq.overrideAttrs (attrs: {
    meta.outputsToInstall = (attrs.meta.outputsToInstall or []) ++ [ "out" "bin" "man" "dev" "doc" ];
  });

  # https://nixos.org/nixpkgs/manual/#how-to-override-a-python-package-using-overlays
  python37 = super.python37.override {
    packageOverrides = python-self: python-super: {
      msgpack = python-super.msgpack.overridePythonAttrs (old: rec {
        version = "0.6.2";

        src = old.src.override {
          inherit version;
          sha256 = "0c0q3vx0x137567msgs5dnizghnr059qi5kfqigxbz26jf2jyg7a";
        };
      });
    };
  };
}

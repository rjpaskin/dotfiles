{ config, lib, pkgs, ... }@args:

with lib;
with config.lib.file;

let
  mackupRoot = toString ../../../../Mackup;

  mackupFile = file: {
    ${toString file}.source = mkOutOfStoreSymlink "${mackupRoot}/${toString file}";
  };

  mackupFiles = files: mkMerge (map mackupFile files);

in {
  lib.mackup = { inherit mackupFiles; };

  # Generated with:
  # mackup uninstall --dry-run | \
  #  ag reverting | \
  #  sed -e 's/Reverting //' -e 's/\.\.\.//' -e 's/^/"/' -e 's/ $/"/'
  # TODO: `.config/nix` and `.config/nixpkgs` need to be symlinked separately
  home.file = mackupFiles [
    # Apps
    "Library/Preferences/com.agilebits.onepassword4.plist"
    "Library/Preferences/com.kapeli.dashdoc.plist"
    "Library/Preferences/com.kapeli.dash.plist"
    "Library/Application Support/Dash/library.dash"
    "Library/Preferences/com.bitgapp.eqMac2.plist"
    "Library/Preferences/com.googlecode.iterm2.plist"
    "Library/Preferences/info.marcel-dierkes.KeepingYouAwake.plist"

    # macOS
    "Library/Preferences/com.apple.symbolichotkeys.plist"
    "Library/Preferences/com.apple.Terminal.plist"

    # Atom
    ".atom/config.cson"
    ".atom/init.coffee"
    ".atom/keymap.cson"
    ".atom/snippets.cson"
    ".atom/styles.less"
    "Library/Preferences/com.github.atom.plist"

    # Bash and other tools
    ".bash_profile"
    ".editorconfig"
    ".ssh/config"

    # Emacs
    ".emacs.d"

    # Clojure
    ".lein"
  ];
}

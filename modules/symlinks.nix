{ config, lib, pkgs, dotfilesRoot, ... }@args:

with lib;
with config.lib.file;

let
  dotfile = file: let
    fileStr = toString file;
    prefix = if (strings.hasPrefix "Library" fileStr) then "" else ".";
  in {
    "${prefix}${fileStr}".source = mkOutOfStoreSymlink "${dotfilesRoot}/${fileStr}";
  };

  dotfiles = files: mkMerge (map dotfile files);

in {
  lib.symlinks = { inherit dotfile dotfiles; };

  # These need to be writable so we can't put them in the Nix store
  #
  # List generated with:
  # mackup uninstall --dry-run | \
  #  ag reverting | \
  #  sed -e 's/Reverting //' -e 's/\.\.\.//' -e 's/^/"/' -e 's/ $/"/'
  home.file = dotfiles [
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
    "atom/config.cson"
    "atom/init.coffee"
    "atom/keymap.cson"
    "atom/snippets.cson"
    "atom/styles.less"
    "Library/Preferences/com.github.atom.plist"

    # Emacs
    "emacs.d"
  ];
}

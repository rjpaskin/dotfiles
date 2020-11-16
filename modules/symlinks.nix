{ config, lib, pkgs, ... }@args:

with lib;
with config.lib.file;

let
  dotfilesRoot = toString ./..;

  dotfile = file: let
    fileStr = toString file;
    prefix = if (strings.hasPrefix "Library" fileStr) then "" else ".";
  in {
    "${prefix}${fileStr}".source = mkOutOfStoreSymlink "${dotfilesRoot}/${fileStr}";
  };

  dotfiles = files: mkMerge (map dotfile files);

in {
  lib.symlinks = { inherit dotfile dotfiles; };

  # Generated with:
  # mackup uninstall --dry-run | \
  #  ag reverting | \
  #  sed -e 's/Reverting //' -e 's/\.\.\.//' -e 's/^/"/' -e 's/ $/"/'
  # TODO: `.config/nix` and `.config/nixpkgs` need to be symlinked separately
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

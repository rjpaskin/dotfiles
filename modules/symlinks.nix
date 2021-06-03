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
  home.file = dotfiles [
    # macOS
    "Library/Preferences/com.apple.symbolichotkeys.plist"
    "Library/Preferences/com.apple.Terminal.plist"
  ];
}

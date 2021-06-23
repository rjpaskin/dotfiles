{ config, lib, pkgs, dotfilesRoot, ... }@args:

with lib;
with config.lib.file;

{
  lib.symlinks = rec {
    dotfile = file: let
      fileStr = toString file;
      prefix = if (hasPrefix "Library" fileStr) then "" else ".";
    in {
      "${prefix}${fileStr}".source = mkOutOfStoreSymlink "${dotfilesRoot}/${fileStr}";
    };

    dotfiles = files: mkMerge (map dotfile files);
  };
}

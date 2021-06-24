{ config, lib, pkgs, dotfilesRoot, ... }@args:

with lib;
with config.lib.file;

{
  # This differs from `mkOutOfStoreSymlink` in that the list of files
  # to be linked is produced when the activation script is run, rather
  # than when it is generated
  options.privateLinks = mkOption {
    type = with types; attrsOf str;
  };

  config = {
    lib.symlinks = rec {
      dotfile = file: let
        fileStr = toString file;
        prefix = if (hasPrefix "Library" fileStr) then "" else ".";
      in {
        "${prefix}${fileStr}".source = mkOutOfStoreSymlink "${dotfilesRoot}/${fileStr}";
      };

      dotfiles = files: mkMerge (map dotfile files);
    };

    home.activation.linkPrivateFiles = lib.hm.dag.entryAfter ["linkGeneration"] ''
      linkPrivateFiles() {
        local target
        target="$HOME/$1"
        shift 1

        for file in "$@"; do
          filename="$(basename "$file")"
          targetFile="$target/$filename"

          if [ -f "$targetFile" ] || [ -L "$targetFile" ]; then
            $VERBOSE_ECHO "File $targetFile exists, skipping"
          else
            $DRY_RUN_CMD ln -ns $VERBOSE_ARG "$file" "$targetFile"
          fi
        done
      }

      ${
        concatStrings (mapAttrsToList (pattern: target: ''
          linkPrivateFiles '${target}' '${dotfilesRoot}'/${pattern}
        '') config.privateLinks)
      }
    '';
  };
}

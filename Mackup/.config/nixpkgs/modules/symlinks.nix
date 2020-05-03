{ config, lib, pkgs, ... }@args:

with lib;

let
  original = import <home-manager/modules/files.nix> args;

  cfg = config.home;

  homeDirectory = cfg.homeDirectory;

  fileType = (import <home-manager/modules/lib/file-type.nix> {
    inherit homeDirectory lib pkgs;
  }).fileType;

  # arguments: source, relative target (from $HOME), executable?, recursive?
  genSymlink = _: { source, target, ... }: ''
    insertFile "${toString source}" \
      "${toString target}" \
      "inherit"
  '';

  mackupRoot = toString ../../../../Mackup;

  mackupFile = file: {
    ${toString file}.source = "${mackupRoot}/${toString file}";
  };

  mackupFiles = files: mkMerge (map mackupFile files);

in

  attrsets.recursiveUpdate original {
    disabledModules = [ <home-manager/modules/files.nix> ];

    options.home.symlinks = with types; mkOption {
      description = "Items to symlink into $HOME without first importing into the Nix store";
      type = fileType "<envar>HOME</envar>" homeDirectory;
    };

    config.home-files = original.config.home-files.overrideAttrs (old: {
      buildCommand = ''
        ${old.buildCommand}

        # Added by RJP
        ${concatStrings (mapAttrsToList genSymlink config.home.symlinks)}
      '';
    });

    config.lib.mackup = { inherit mackupFiles; };

    # Generated with:
    # mackup uninstall --dry-run | \
    #  ag reverting | \
    #  sed -e 's/Reverting //' -e 's/\.\.\.//' -e 's/^/"/' -e 's/ $/"/'
    # TODO: `.config/nix` and `.config/nixpkgs` need to be symlinked separately
    config.home.symlinks = mackupFiles [
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
      ".config/silver_searcher/ignore"
      ".inputrc"
      ".editorconfig"
      ".ssh/config"

      # Emacs
      ".emacs.d"

      # Clojure
      ".lein"
    ];
  }

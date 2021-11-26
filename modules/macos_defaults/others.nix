{ config, lib, ... }:

with lib;

let
  cfg = config.targets.darwin;

in {
  options.targets.darwin = with types; {
    plists = mkOption {
      description = "Edits to plists to be made via PlistBuddy";
      type = attrsOf attrs;
    };

    powerSettings = mkOption {
      type = submodule {
        options = {
          displaysleep = mkOption {
            description = "Time in minutes before display goes to sleep";
            type = int;
          };
        };
      };
    };
  };

  config = {
    targets.darwin = {
      plists = {
        "Library/Preferences/com.apple.finder.plist" = {
          ":DesktopViewSettings:IconViewSettings:arrangeBy" = "grid";
          ":FK_StandardViewSettings:IconViewSettings:arrangeBy" = "kind";
          ":StandardViewSettings:IconViewSettings:arrangeBy" = "grid";

          ":DesktopViewSettings:IconViewSettings:showItemInfo" = false;
          ":StandardViewSettings:IconViewSettings:showItemInfo" = true;
        };

        # Disable Ctrl+(Left,Right) shortcuts
        # - kSHKMoveLeftASpace  = 79 (Ctrl + Arrow Left)
        # - kSHKMoveRightASpace = 81 (Ctrl + Arrow Right)
        # See https://stackoverflow.com/questions/866056/how-do-i-programmatically-get-the-shortcut-keys-reserved-by-mac-os-x
        "Library/Preferences/com.apple.symbolichotkeys.plist" = {
          "AppleSymbolicHotKeys:79:enabled" = false;
          "AppleSymbolicHotKeys:81:enabled" = false;
        };
      };

      powerSettings = {
        displaysleep = 15;
      };
    };

    home.activation = {
      plistBuddy = let
        toValue = obj: if isBool obj then boolToString obj else obj;
        toCmd = file: path: value: ''
          $DRY_RUN_CMD /usr/libexec/PlistBuddy -c "Set ${path} ${toValue value}" $HOME/${file}
        '';
        toCmds = file: settings: concatStrings (mapAttrsToList (toCmd file) settings);
      in hm.dag.entryAfter ["setDarwinDefaults"] ''
        ${concatStrings (mapAttrsToList toCmds cfg.plists)}
        /usr/bin/killall Finder
      '';

      showHiddenFolders = hm.dag.entryAfter ["installPackages"] ''
        $DRY_RUN_CMD chflags nohidden $HOME/Library
        $DRY_RUN_CMD xattr -d com.apple.FinderInfo $HOME/Library 2>/dev/null || true

        if [ "$(/usr/bin/stat -f '%Xf' /Volumes)" != "0" ]; then
          $VERBOSE_ECHO "Unhiding /Volumes"
          $DRY_RUN_CMD sudo chflags nohidden /Volumes
        fi
      '';

      enableFirewall = let
        domain = "/Library/Preferences/com.apple.alf";
      in hm.dag.entryAfter ["installPackages"] ''
        if [ "$(defaults read ${domain} globalstate 2>/dev/null)" != "1" ]; then
          $VERBOSE_ECHO "Enabling firewall"
          $DRY_RUN_CMD sudo defaults write ${domain} globalstate -int 1
          $DRY_RUN_CMD sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist 2>/dev/null
        fi
      '';

      powerSettings = let
        toCmd = name: value: let
          strValue = toString value;
        in ''
          if [ "$(pmset -g | awk '($1 == "${name}"){ print $2 }')" != "${strValue}" ]; then
            $VERBOSE_ECHO "Setting ${name} to ${strValue}"
            $DRY_RUN_CMD sudo pmset -a ${name} ${strValue}
          fi
        '';
      in hm.dag.entryAfter ["installPackages"] ''
        ${concatStrings (mapAttrsToList toCmd cfg.powerSettings)}
      '';
    };
  };
}

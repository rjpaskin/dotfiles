{ config, lib, pkgs, machine, ... }:

with lib;
with types;

let
  mkNullableEnum = values: mkOption {
    type = nullOr (enum values);
    default = null;
  };

  itemType = submodule {
    options = {
      path = mkOption {
        type = str;
      };
      tileType = mkOption {
        type = enum [ "file" "directory" ];
        default = "directory";
      };
      view = mkNullableEnum [ "grid" ];
      display = mkNullableEnum [ "folder" ];
      sort = mkNullableEnum [ "name" "kind" "dateadded" ];
    };
  };

  viewEnum = { auto = 0; fan = 1; grid = 2; list = 3; };
  sortEnum = { name = 1; dateadded = 2; datemodified = 3; datecreated = 4; kind = 5; };
  displayEnum = { stack = 0; folder = 1; };

  toItem = {
    path,
    tileType,
    view ? null,
    display ? null,
    sort ? null
  }: {
    tile-data = {
      file-data = {
        _CFURLStringType = 0;
        _CFURLString = path;
      };
      file-label = replaceStrings [".app"] [""] (baseNameOf path);
      file-type = if hasSuffix ".app" path then 32 else 2;
    } // (optionalAttrs (view != null) {
      showas = viewEnum.${view};
    }) // (optionalAttrs (display != null) {
      displayas = displayEnum.${display};
    }) // (optionalAttrs (sort != null) {
      arrangement = sortEnum.${sort};
    }) // (optionalAttrs (tileType == "directory") {
      directory = 1;
    });
    tile-type = "${tileType}-tile";
  };

  cfg = config.targets.darwin.dock;

  plistFile = let
    setGUID = type: index: ''
      /usr/libexec/PlistBuddy \
        -c "Add :persistent-${type}:${toString index}:GUID string $(/usr/bin/uuidgen)" \
        $out
    '';
  in pkgs.writeTextFile {
    name = "Dock.plist";
    text = generators.toPlist {} {
      persistent-apps = map toItem cfg.apps;
      persistent-others = map toItem cfg.others;
    };
    checkPhase = ''
      ${concatStrings (imap0 (index: _: setGUID "apps" index) cfg.apps)}
      ${concatStrings (imap0 (index: _: setGUID "others" index) cfg.others)}
    '';
  };

  systemApps = [
    "Launchpad"
    "Utilities/Activity Monitor"
    "System Preferences"
  ];

  appPath = name: if machine.sameOrNewerThan "big_sur" && builtins.elem name systemApps
  then "/System/Applications/${name}.app" # location for system apps on Big Sur
  else "/Applications/${name}.app"; # this may not exist yet if `brew bundle` hasn't yet been run

in {
  options.targets.darwin.dock = mkOption {
    type = submodule {
      options = {
        apps = mkOption {
          description = "Applications to put in the Dock";
          type = listOf (coercedTo str (name: {
            path = appPath name;
            tileType = "file";
          }) itemType);
        };

        others = mkOption {
          description = "Other items to add to the Dock";
          type = listOf itemType;
        };
      };
    };
  };

  config.home.activation.dock = hm.dag.entryAfter ["setDarwinDefaults"] ''
    $DRY_RUN_CMD /usr/bin/defaults import com.apple.dock ${plistFile}
    $DRY_RUN_CMD /usr/bin/killall Dock
  '';
}

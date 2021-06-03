{ config, lib, pkgs, ... }:

with lib;

let
  androidPaths = map (dir: "$ANDROID_HOME/${dir}") [
    "emulator" "tools" "tools/bin" "platform-tools"
  ];

in {
  options.roles.react-native = config.lib.roles.mkOptionalRole "React Native dev (Android)";

  config = mkIf config.roles.react-native {
    home.packages = with pkgs; [
      nodePackages.react-native-cli
      watchman
    ];

    targets.darwin.homebrew.casks = [ "android-studio" ];

    programs.zsh = {
      sessionVariables = {
        ANDROID_HOME = "$HOME/Library/Android/sdk";
      };

      initExtra = ''
        path+=(${concatStringsSep " " androidPaths})
      '';
    };
  };
}

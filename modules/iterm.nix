{ config, ... }:

let
  domain = "com.googlecode.iterm2";

  toColour = parts: {
    "Blue Component" = builtins.elemAt parts 2;
    "Green Component" = builtins.elemAt parts 1;
    "Red Component" = builtins.elemAt parts 0;
  };

  white = toColour [1 1 1];
  black = toColour [0 0 0];

in {
  targets.darwin = {
    homebrew.casks = [ "iterm2" ];

    defaults.${domain} = {
      AlternateMouseScroll = true;
      Columns = 150;
      "Custom Directory" = "Recycle";
      EnableAPIServer = true; # enable Python API
      "Normal Font" = "Monaco 13";
      OpenArrangementAtStartup = false;
      PreserveWindowSizeWhenTabBarVisibilityChanges = true;
      SUEnableAutomaticChecks = true;
      "Scrollback Lines" = 0; # unlimited
      ShowNewOutputIndicator = false;
      SoundForEsc = false;
      StretchTabsToFillBar = false;
      TabStyleWithAutomaticOption = 4;
      "Unlimited Scrollback" = true;
      VisualIndicatorForEsc = false;

      "Background Color" = white;
      "Bold Color" = black;
      "Cursor Color" = black;
      "Foreground Color" = black;
    };

    plists."Library/Preferences/${domain}.plist".":New Bookmarks:0:Allow Title Setting" = false;
  };
}

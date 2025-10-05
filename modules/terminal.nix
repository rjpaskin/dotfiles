{ lib, ... }:

let
  toColour = parts: {
    "Blue Component" = builtins.elemAt parts 2;
    "Green Component" = builtins.elemAt parts 1;
    "Red Component" = builtins.elemAt parts 0;
  };

  white = toColour [1 1 1];
  black = toColour [0 0 0];

  profileUUID = "A00868BC-8749-41C1-8B9E-B92BDA34E275";

in lib.mkMerge [
  {
    # https://iterm2.com/documentation-dynamic-profiles.html
    home.file."Library/Application Support/iTerm2/DynamicProfiles/rjp.json".text = builtins.toJSON {
      Profiles = [
        {
          Name = "RJP";
          Guid = profileUUID;

          "Allow Title Setting" = false;
          "Brighten Bold Text" = false;
          "Columns" = 150;
          "Custom Directory" = "Recycle";
          "Scrollback Lines" = 0; # unlimited
          "Unlimited Scrollback" = true;
          "Normal Font" = "Monaco 13";

          "Background Color" = white;
          "Foreground Color" = black;
          "Bold Color" = black;
          "Cursor Color" = black;
        }
      ];
    };

    nix-darwin.homebrew.casks = [ "iterm2" ];

    targets.darwin.defaults."com.googlecode.iterm2" = {
      AlternateMouseScroll = true;
      "Default Bookmark Guid" = profileUUID;
      EnableAPIServer = true; # enable Python API
      OpenArrangementAtStartup = false;
      PreserveWindowSizeWhenTabBarVisibilityChanges = true;
      SUEnableAutomaticChecks = true;
      ShowNewOutputIndicator = false;
      SoundForEsc = false;
      StretchTabsToFillBar = false;
      TabStyleWithAutomaticOption = 4;
      ToolbeltTools = [ "Jobs" ];
      VisualIndicatorForEsc = false;
    };
  }

  {
    nix-darwin.homebrew.casks = [ "ghostty" ];
    programs.ghostty = {
      enable = true;
      package = null; # sourced from Homebrew instead
      settings = {
        theme = "iTerm2 Light Background";
        # Make light yellow (11) same as dark yellow (3) to make it readable
        palette = [ "11=#c7c400" ];
        font-family = "Monaco";
        font-size = 13;
        unfocused-split-fill = "333333";
        focus-follows-mouse = true;
        shell-integration-features = "no-cursor";
        cursor-style-blink = false;
        macos-titlebar-proxy-icon = "hidden";
        window-padding-x = 4;
        window-padding-y = 4;
        window-new-tab-position = "end";
      };
    };
  }
]

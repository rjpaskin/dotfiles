{ config, lib, pkgs, ... }:

with lib;

let
  inherit (config) roles;

in {
  imports = [ ./options.nix ];

  options.roles = with config.lib.roles; {
    cyberduck = mkOptionalRole "Cyberduck";
    dropbox = mkOptionalRole "Dropbox";
    eqmac = mkOptionalRole "eqMac";
    gimp = mkOptionalRole "GIMP";
    harvest = mkOptionalRole "Harvest taskbar app";
    inkscape = mkOptionalRole "Inkscape";
    ngrok = mkOptionalRole "ngrok";
    postman = mkOptionalRole "Postman";
    slack = mkOptionalRole "Slack";
    sql-clients = mkOptionalRole "SQL clients (Sequel Pro, TablePlus)";
    virtualbox = mkOptionalRole "Virtual Box with extensions";
    whatsapp = mkOptionalRole "WhatsApp";
    zoom = mkOptionalRole "Zoom app";
  };

  config.targets.darwin.homebrew = {
    casks = mkMerge [
      [
        # Browsers
        "google-chrome"
        "firefox"

        # Programming tools
        {
          name = "dash";
          defaults."com.kapeli.dashdoc" = {
            syncFolderPath = "~/Library/Mobile Documents/com~apple~CloudDocs";
            shouldSyncBookmarks = true;
            shouldSyncDocsets = true;
            shouldSyncGeneral = true;
            shouldSyncView = true;
          };
        }
        { name = "emacs"; files = ["emacs.d"]; }
        {
          name = "iterm2";
          defaults."com.googlecode.iterm2" = let
            toColour = parts: {
              "Blue Component" = builtins.elemAt parts 2;
              "Green Component" = builtins.elemAt parts 1;
              "Red Component" = builtins.elemAt parts 0;
            };
            white = toColour [1 1 1];
            black = toColour [0 0 0];
          in {
            AlternateMouseScroll = true;
            Columns = 150;
            "Custom Directory" = "Recycle";
            "Scrollback Lines" = 0; # unlimited
            "Unlimited Scrollback" = true;
            "Normal Font" = "Monaco 13";
            OpenArrangementAtStartup = false;
            ShowNewOutputIndicator = false;
            SUEnableAutomaticChecks = true;
            StretchTabsToFillBar = false;
            TabStyleWithAutomaticOption = 4;
            SoundForEsc = false;
            VisualIndicatorForEsc = false;
            PreserveWindowSizeWhenTabBarVisibilityChanges = true;
            "Background Color" = white;
            "Foreground Color" = black;
            "Bold Color" = black;
            "Cursor Color" = black;
          };
        }
        "kdiff3"
        "xquartz"

        # Quicklook plugins
        {
          name = "qlcolorcode"; # syntax highlighting
          defaults."org.n8gray.QLColorCode".pathHL = "${pkgs.highlight}/bin/highlight";
        }
        "qlcommonmark" # markdown files
        "qlstephen" # files without extensions
        "quicklook-json"
        "quicklook-csv"

        # Others
        "1password"
        "keepingyouawake"
        "betterzip"
        "imageoptim"
        "mollyguard"
        "superduper"
        "vlc"
      ]

      (mkIf roles.cyberduck ["cyberduck"])
      (mkIf roles.dropbox ["dropbox"])
      (mkIf roles.eqmac ["eqmac"])
      (mkIf roles.gimp ["gimp"])
      (mkIf roles.inkscape ["inkscape"])
      (mkIf roles.ngrok ["ngrok"])
      (mkIf roles.postman ["postman"])
      (mkIf roles.slack ["slack"])
      (mkIf roles.sql-clients ["sequel-pro" "tableplus"])
      (mkIf roles.virtualbox ["virtualbox" "virtualbox-extension-pack"])
      (mkIf roles.whatsapp ["whatsapp"])
      (mkIf roles.zoom ["zoom"])
    ];

    masApps = mkMerge [
      {
        Keynote = 409183694;
        Numbers = 409203825;
        Pages = 409201541;
        "HP Smart" = 1474276998;
      }

      (mkIf roles.harvest { Harvest = 506189836; })
    ];
  };
}

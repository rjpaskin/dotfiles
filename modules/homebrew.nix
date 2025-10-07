{ config, lib, os, ... }:

let
  inherit (config) roles;
  inherit (lib) mkIf mkMerge;

in {
  options.roles = with config.lib.roles; {
    cyberduck = mkOptionalRole "Cyberduck";
    dash = mkOptionalRole "Dash";
    dropbox = mkOptionalRole "Dropbox";
    eqmac = mkOptionalRole "eqMac";
    gimp = mkOptionalRole "GIMP";
    harvest = mkOptionalRole "Harvest taskbar app";
    inkscape = mkOptionalRole "Inkscape";
    ngrok = mkOptionalRole "ngrok";
    postman = mkOptionalRole "Postman";
    slack = mkOptionalRole "Slack";
    sql-clients = mkOptionalRole "SQL clients (TablePlus)";
    virtualbox = mkOptionalRole "Virtual Box with extensions";
    whatsapp = mkOptionalRole "WhatsApp";
    vlc = mkOptionalRole "VLC";
    zoom = mkOptionalRole "Zoom app";
  };

  config = mkMerge [
    # Global Homebrew settings
    {
      darwin.homebrew = {
        enable = true;
        global.brewfile = true;
      };
    }

    {
      darwin.homebrew.casks = mkMerge [
        [
          "1password"
          "betterzip"
          "firefox"
          "google-chrome"
          "imageoptim"
          "kdiff3"
          "keepingyouawake"
          "superduper"
          "vlc"
        ]

        (mkIf roles.dropbox [ "dropbox" ])
        (mkIf roles.ngrok [ "ngrok" ])
        (mkIf roles.postman [ "postman" ])
        (mkIf roles.slack [ "slack" ])
        (mkIf roles.sql-clients [ "tableplus" ])
        (mkIf roles.whatsapp [ "whatsapp" ])
        (mkIf roles.zoom [ "zoom" ])
      ];
    }

    (mkIf roles.virtualbox {
      darwin.homebrew.casks = mkIf (!os.isARM) [ "virtualbox" "virtualbox-extension-pack" ];
      darwin.assertions = [
        {
          assertion = os.isARM;
          message = "VirtualBox is not supported on ARM machines";
        }
      ];
    })

    (mkIf roles.dash {
      darwin.homebrew.casks = [ "dash" ];
      hm.targets.darwin.defaults."com.kapeli.dashdoc" = {
        syncFolderPath = "~/Library/Mobile Documents/com~apple~CloudDocs";
        shouldSyncBookmarks = true;
        shouldSyncDocsets = true;
        shouldSyncGeneral = true;
        shouldSyncView = true;
      };
    })

    {
      darwin.homebrew.casks = [ "xquartz" ];
      hm.targets.darwin.defaults."org.xquartz.X11".nolisten_tcp = false; # allow network connections
    }

    # Quicklook plugins
    (mkIf (os.versionOlderThan "catalina") {
      darwin.homebrew.casks = [ "qlcolorcode" ]; # syntax highlighting
      hm = { pkgs, ... }: {
        targets.darwin.defaults."org.n8gray.QLColorCode".pathHL = lib.getExe pkgs.highlight;
      };
    })
    (mkIf (os.versionAtLeast "catalina") {
      darwin.homebrew.casks = [
        { name = "syntax-highlight"; args.no_quarantine = true; }
      ];
    })

    {
      darwin.homebrew.casks = [
        # markdown files
        (mkIf (os.versionOlderThan "catalina") {
          name = "qlcommonmark"; args.no_quarantine = true;
        })
        (mkIf (os.versionAtLeast "catalina") {
          name = "qlmarkdown"; args.no_quarantine = true;
        })

        { name = "qlstephen"; args.no_quarantine = true; } # files without extensions
        { name = "quicklook-json"; args.no_quarantine = true; }
        { name = "quicklook-csv"; args.no_quarantine = true; }
      ];
    }

    # TODO
    # masApps = mkMerge [
    #   {
    #     Keynote = 409183694;
    #     Numbers = 409203825;
    #     Pages = 409201541;
    #     "HP Smart" = 1474276998;
    #   }
    # ];
  ];
}

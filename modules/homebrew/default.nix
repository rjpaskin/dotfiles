{ config, lib, pkgs, dotfiles, ... }:

let
  inherit (config) roles;
  inherit (lib) mkIf mkMerge;
  inherit (dotfiles) os;

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
    {
      nix-darwin.homebrew.casks = mkMerge [
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

        (mkIf roles.cyberduck [ "cyberduck" ])
        (mkIf roles.dropbox [ "dropbox" ])
        (mkIf roles.eqmac [ "eqmac" ])
        (mkIf roles.gimp [ "gimp" ])
        (mkIf roles.inkscape [ "inkscape" ])
        (mkIf roles.ngrok [ "ngrok" ])
        (mkIf roles.postman [ "postman" ])
        (mkIf roles.slack [ "slack" ])
        (mkIf roles.sql-clients [ "tableplus" ])
        (mkIf roles.whatsapp [ "whatsapp" ])
        (mkIf roles.zoom [ "zoom" ])
      ];
    }

    (mkIf roles.virtualbox {
      nix-darwin.homebrew.casks = mkIf (!os.isARM) [ "virtualbox" "virtualbox-extension-pack" ];
      assertions = [
        {
          assertion = os.isARM;
          message = "VirtualBox is not supported on ARM machines";
        }
      ];
    })

    (mkIf roles.dash {
      nix-darwin.homebrew.casks = [ "dash" ];
      targets.darwin.defaults."com.kapeli.dashdoc" = {
        syncFolderPath = "~/Library/Mobile Documents/com~apple~CloudDocs";
        shouldSyncBookmarks = true;
        shouldSyncDocsets = true;
        shouldSyncGeneral = true;
        shouldSyncView = true;
      };
    })

    {
      nix-darwin.homebrew.casks = [ "xquartz" ];
      targets.darwin.defaults."org.xquartz.X11".nolisten_tcp = false; # allow network connections
    }

    # Quicklook plugins
    (mkIf (os.olderThan "catalina") {
      nix-darwin.homebrew.casks = [ "qlcolorcode" ]; # syntax highlighting
      targets.darwin.defaults."org.n8gray.QLColorCode".pathHL = lib.getExe pkgs.highlight;
    })
    (mkIf (os.sameOrNewerThan "catalina") {
      nix-darwin.homebrew.casks = [
        { name = "syntax-highlight"; args.no_quarantine = true; }
      ];
    })

    {
      nix-darwin.homebrew.casks = [
        # markdown files
        (mkIf (os.olderThan "catalina") {
          name = "qlcommonmark"; args.no_quarantine = true;
        })
        (mkIf (os.sameOrNewerThan "catalina") {
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

    #   (mkIf roles.harvest { Harvest = 506189836; })
    # ];
  ];
}

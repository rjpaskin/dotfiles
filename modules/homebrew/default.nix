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
        "google-chrome"
        "firefox"

        {
          name = "dash";
          prefs = ["com.kapeli.dash" "com.kapeli.dashdoc"];
          files = ["Library/Application Support/Dash/library.dash"];
        }
        { name = "emacs"; files = ["emacs.d"]; }
        { name = "iterm2"; prefs = ["com.googlecode.iterm2"]; }
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

        { name = "1password"; prefs = ["com.agilebits.onepassword4"]; }
        { name = "keepingyouawake"; prefs = ["info.marcel-dierkes.KeepingYouAwake"]; }
        "betterzip"
        "imageoptim"
        "mollyguard"
        "superduper"
        "vlc"
      ]

      (mkIf roles.cyberduck ["cyberduck"])
      (mkIf roles.dropbox ["dropbox"])
      (mkIf roles.eqmac [{ name = "eqmac"; prefs = ["com.bitgapp.eqMac2"]; }])
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

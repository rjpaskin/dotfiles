{ config, lib, pkgs, machine, ... }:

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
            EnableAPIServer = true; # enable Python API
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
          plists."Library/Preferences/com.googlecode.iterm2.plist".":New Bookmarks:0:Allow Title Setting" = false;
        }
        "kdiff3"
        {
          name = "xquartz";
          defaults."org.xquartz.X11".nolisten_tcp = false; # allow network connections
        }

        # Quicklook plugins
        (mkIf (machine.olderThan "catalina") {
          name = "qlcolorcode"; # syntax highlighting
          defaults."org.n8gray.QLColorCode".pathHL = "${pkgs.highlight}/bin/highlight";
        })
        (mkIf (machine.sameOrNewerThan "catalina") {
          name = "syntax-highlight"; removeQuarantine = true;
        })

        # markdown files
        (mkIf (machine.olderThan "catalina") {
          name = "qlcommonmark"; removeQuarantine = true;
        })
        (mkIf (machine.sameOrNewerThan "catalina") {
          name = "sbarex-qlmarkdown"; removeQuarantine = true;
        })

        { name = "qlstephen"; removeQuarantine = true; } # files without extensions
        { name = "quicklook-json"; removeQuarantine = true; }
        { name = "quicklook-csv"; removeQuarantine = true; }

        # Others
        "1password"
        "keepingyouawake"
        "betterzip"
        "imageoptim"
        "superduper"
        "vlc"

        {
          name = "mollyguard";
          # Mollyguard was deleted in Homebrew/homebrew-cask#78586
          # - this is the commit before that PR was merged
          rev = "e53923dac85c3e3219ddf6ff33a977f3ca75ebce";
          # Update deprecated `appcast` method - generated with:
          # `git -C $(brew --repository homebrew/cask) diff --unified=2`
          postCheckout = let
            patch = pkgs.writeText "brew-cask-mollyguard.patch" ''
              diff --git a/Casks/mollyguard.rb b/Casks/mollyguard.rb
              --- a/Casks/mollyguard.rb
              +++ b/Casks/mollyguard.rb
              @@ -5,5 +5,8 @@ cask 'mollyguard' do
                 # dl.dropboxusercontent.com/s/j9kx9ufk74wtpm9 was verified as official when first introduced to the cask
                 url 'https://dl.dropboxusercontent.com/s/j9kx9ufk74wtpm9/MollyGuard.zip?dl=1'
              -  appcast 'https://dl.dropboxusercontent.com/s/sno9l4q8ncogz27/MGUpdate.xml'
              +  livecheck do
              +    url 'https://dl.dropboxusercontent.com/s/sno9l4q8ncogz27/MGUpdate.xml'
              +    strategy :sparkle
              +  end
                 name 'MollyGuard'
                 homepage 'http://mollyguard.infinitemonkeytheory.com/'
            '';
          in ''
            echo "Applying patch ${patch}"
            ${pkgs.git}/bin/git apply ${patch}
          '';
          removeQuarantine = true;
          defaults."com.imt.MollyGuard" = {
            defaultBehavior = false; # lock keyboard AND mouse
            displayAlert = true;
            statusIconSet = 1; # circular icons
          };
        }
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

{ lib, machine, ... }:

with lib;

{
  imports = [ ./others.nix ];

  config = {
    targets.darwin.defaults = mkMerge [
      {
        "com.apple.universalaccess" = {
          closeViewZoomFollowsFocus = true;
          reduceTransparency = true;
        };
        NSGlobalDomain = {
          "com.apple.springing.delay" = 0;
          "com.apple.springing.enabled" = true;
          "com.apple.swipescrolldirection" = false;
          AppleFontSmoothing = 1;
          AppleKeyboardUIMode = 3;
          AppleLanguages = ["en-GB"];
          AppleLocale = "en_GB@currency=GBP";
          AppleMeasurementUnits = "Centimeters";
          AppleMetricUnits = true;
          ApplePressAndHoldEnabled = false;
          AppleShowAllExtensions = true;
          AppleShowScrollBars = "WhenScrolling";
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
          NSDisableAutomaticTermination = true;
          NSDocumentSaveNewDocumentsToCloud = false;
          NSNavPanelExpandedStateForSaveMode = true;
          NSNavPanelExpandedStateForSaveMode2 = true;
          NSTableViewDefaultSizeMode = 2;
          NSTextShowsControlCharacters = true;
          NSUseAnimatedFocusRing = false;
          NSWindowResizeTime = 0.001;
          PMPrintingExpandedStateForPrint = true;
          PMPrintingExpandedStateForPrint2 = true;
          WebKitDeveloperExtras = true;
        };
        "com.apple.print.PrintingPrefs" = {
          "Quit When Finished" = true;
        };
        "com.apple.systempreferences" = {
          NSQuitAlwaysKeepsWindows = false;
        };
        "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
          TrackpadCornerSecondaryClick = 2;
          TrackpadRightClick = true;
        };
        "com.apple.BluetoothAudioAgent" = {
          "Apple Bitpool Min (editable)" = 40;
        };
        "com.apple.screensaver" = {
          askForPassword = 1;
          askForPasswordDelay = 0;
        };
        "com.apple.screencapture" = {
          disable-shadow = true;
          location = "$HOME/Desktop";
          type = "png";
        };
        "com.apple.finder" = {
          DisableAllAnimations = true;
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          FXInfoPanesExpanded = {
            General = true;
            OpenWith = true;
            Privileges = true;
          };
          NewWindowTarget = "PfHm";
          OpenWindowForNewRemovableDisk = true;
          QuitMenuItem = true;
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowPathbar = false;
          ShowRemovableMediaOnDesktop = true;
          ShowStatusBar = false;
          _FXShowPosixPathInTitle = true;
          _FXSortFoldersFirst = false;
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.frameworks.diskimages" = {
          auto-open-ro-root = true;
          auto-open-rw-root = true;
        };
        "com.apple.NetworkBrowser" = {
          BrowseAllInterfaces = true;
        };
        "com.apple.dock" = {
          autohide = true;
          dashboard-in-overlay = true;
          enable-spring-load-actions-on-all-items = true;
          expose-animation-duration = 0.1;
          expose-group-by-app = false;
          mru-spaces = false;
          show-process-indicators = true;
          show-recents = false;
          showhidden = true;
          wvous-bl-corner = 5;
          wvous-bl-modifier = 0;
          wvous-br-corner = 2;
          wvous-br-modifier = 0;
          wvous-tr-corner = 4;
          wvous-tr-modifier = 0;
        };
        "com.apple.dashboard" = {
          devmode = true;
          mcx-disabled = true;
        };
        "com.apple.Safari" = {
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled" = true;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = false;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = false;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled" = false;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;
          AutoFillCreditCardData = false;
          AutoFillFromAddressBook = false;
          AutoFillMiscellaneousForms = false;
          AutoFillPasswords = false;
          AutoOpenSafeDownloads = false;
          DebugSnapshotsUpdatePolicy = 2;
          FindOnPageMatchesWordStartsOnly = false;
          HomePage = "about:blank";
          IncludeDevelopMenu = true;
          IncludeInternalDebugMenu = true;
          InstallExtensionUpdatesAutomatically = true;
          ProxiesInBookmarksBar = [];
          ShowFavoritesBar = false;
          ShowFullURLInSmartSearchField = true;
          ShowSidebarInTopSites = false;
          SuppressSearchSuggestions = true;
          UniversalSearchEnabled = false;
          WarnAboutFraudulentWebsites = true;
          WebAutomaticSpellingCorrectionEnabled = false;
          WebContinuousSpellCheckingEnabled = true;
          WebKitJavaEnabled = false;
          WebKitJavaScriptCanOpenWindowsAutomatically = false;
          WebKitPluginsEnabled = false;
          WebKitTabToLinksPreferenceKey = true;
        };
        # "com.apple.spotlight" = {
        #   orderedItems = [
        #     "{\"enabled\" = 1;\"name\" = \"APPLICATIONS\";}"
        #     "{\"enabled\" = 1;\"name\" = \"SYSTEM_PREFS\";}"
        #     "{\"enabled\" = 1;\"name\" = \"DIRECTORIES\";}"
        #     "{\"enabled\" = 1;\"name\" = \"PDF\";}"
        #     "{\"enabled\" = 1;\"name\" = \"FONTS\";}"
        #     "{\"enabled\" = 1;\"name\" = \"DOCUMENTS\";}"
        #     "{\"enabled\" = 0;\"name\" = \"MESSAGES\";}"
        #     "{\"enabled\" = 0;\"name\" = \"CONTACT\";}"
        #     "{\"enabled\" = 0;\"name\" = \"EVENT_TODO\";}"
        #     "{\"enabled\" = 1;\"name\" = \"IMAGES\";}"
        #     "{\"enabled\" = 0;\"name\" = \"BOOKMARKS\";}"
        #     "{\"enabled\" = 0;\"name\" = \"MUSIC\";}"
        #     "{\"enabled\" = 0;\"name\" = \"MOVIES\";}"
        #     "{\"enabled\" = 1;\"name\" = \"PRESENTATIONS\";}"
        #     "{\"enabled\" = 1;\"name\" = \"SPREADSHEETS\";}"
        #     "{\"enabled\" = 0;\"name\" = \"SOURCE\";}"
        #     "{\"enabled\" = 1;\"name\" = \"MENU_DEFINITION\";}"
        #     "{\"enabled\" = 1;\"name\" = \"MENU_OTHER\";}"
        #     "{\"enabled\" = 1;\"name\" = \"MENU_CONVERSION\";}"
        #     "{\"enabled\" = 1;\"name\" = \"MENU_EXPRESSION\";}"
        #   ];
        # };
        "com.apple.Terminal" = {
          SecureKeyboardEntry = true;
          ShowLineMarks = 0;
          StringEncodings = ["4"];
        };
        "com.apple.TimeMachine" = {
          DoNotOfferNewDisksForBackup = true;
        };
        "com.apple.ActivityMonitor" = {
          OpenMainWindow = true;
          ShowCategory = 0;
          SortColumn = "CPUUsage";
          SortDirection = 0;
        };
        "com.apple.addressbook" = {
          ABShowDebugMenu = true;
        };
        "com.apple.iCal" = {
          IncludeDebugMenu = true;
        };
        "com.apple.TextEdit" = {
          PlainTextEncoding = 4;
          PlainTextEncodingForWrite = 4;
          RichText = 0;
        };
        "com.apple.DiskUtility" = {
          DUDebugMenuEnabled = true;
          advanced-image-options = true;
        };
        "com.apple.QuickTimePlayerX" = {
          MGPlayMovieOnOpen = true;
        };
        "com.apple.appstore" = {
          ShowDebugMenu = true;
          WebKitDeveloperExtras = true;
        };
        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          AutomaticDownload = 1;
          ConfigDataInstall = 1;
          CriticalUpdateInstall = 1;
          ScheduleFrequency = 1;
        };
        "com.apple.commerce" = {
          AutoUpdate = true;
          AutoUpdateRestartRequired = true;
        };
        "com.google.Chrome" = {
          AppleEnableSwipeNavigateWithScrolls = false;
          DisablePrintPreview = true;
          PMPrintingExpandedStateForPrint2 = true;
        };
      }

      (mkIf (machine.olderThan "big_sur") {
        "com.apple.menuextra.battery" = {
          ShowPercent = "YES";
        };
      })
    ];

    targets.darwin.currentHostDefaults = mkMerge [
      {
        NSGlobalDomain = {
          "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
          "com.apple.trackpad.enableSecondaryClick" = true;
          "com.apple.trackpad.twoFingerFromRightEdgeSwipeGesture" = false;
          "com.apple.trackpad.twoFingerDoubleTapGesture" = false;
        };
        "com.apple.ImageCapture" = {
          disableHotPlug = true;
        };
      }
      (mkIf (machine.sameOrNewerThan "big_sur") {
        "com.apple.controlcenter" = {
          BatteryShowPercentage = true;
        };
      })
    ];

    home.activation.keyboardMappings = let
      # See below for key codes:
      # - https://developer.apple.com/library/archive/technotes/tn2450/_index.html#//apple_ref/doc/uid/DTS40017618-CH1-KEY_TABLE_USAGES
      # - https://hidutil-generator.netlify.app
      capsLock = 30064771129; # 0x700000000 | 0x39
      # System Preferences uses Right Ctrl for "Control", so copy that
      rightCtrl = 30064771300; # 0x700000000 | 0xE4

      toKeyboardMapping = { from, to }: "<dict>
        <key>HIDKeyboardModifierMappingSrc</key>
        <integer>${toString from}</integer>
        <key>HIDKeyboardModifierMappingDst</key>
        <integer>${toString to}</integer>
      </dict>";

      keyboardMappings = [
        { from = capsLock; to = rightCtrl; }
      ];

    in hm.dag.entryAfter ["setDarwinDefaults"] ''
      # Get "<vendorID>-<productID>" tuples for all keyboards currently connected
      keyboards="$(
        /usr/bin/hidutil list --matching keyboard \
          | awk '/^Devices:/ { seenDevices = 1 } /^0x/ && seenDevices { printf "%d-%d\n", $1, $2 }'
      )"

      for keyboard in $keyboards; do
        $DRY_RUN_CMD /usr/bin/defaults -currentHost write \
          "NSGlobalDomain" \
          "com.apple.keyboard.modifiermapping.$keyboard-0" \
          -array '${concatMapStrings toKeyboardMapping keyboardMappings}'
      done
    '';
  };
}

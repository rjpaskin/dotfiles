#!/bin/sh

choose_terminal() {
  if [ -e "/Applications/iTerm.app" ]; then
    echo "iTerm"
  else
    echo "Utilities/Terminal"
  fi
}

# Uncomment for debugging
# dockutil() { echo "dockutil $@" }

set -e

dockutil --remove all --no-restart
sleep 2 # give the dock time to process the above

for app in "Launchpad" \
  "Google Chrome" \
  "Atom" \
  "SourceTree" \
  "$(choose_terminal)" \
  "Utilities/Activity Monitor" \
  "Pages" \
  "Numbers" \
  "Keynote" \
  "Slack" \
  "System Preferences"; do
    app_path="/Applications/$app.app"

    if [ -e "$app_path" ]; then
      dockutil --add "$app_path" --no-restart
    fi
done

dockutil --add '/Applications' --view grid --display folder --sort name --no-restart
# shellcheck disable=SC2088
dockutil --add '~/Documents'   --view grid --display folder --sort kind --no-restart
# shellcheck disable=SC2088
dockutil --add '~/Downloads'   --view grid --display folder --sort dateadded

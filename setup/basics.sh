#!/bin/sh

set -e

if xcode-select --version | grep --silent "version"; then
  xcode-select --install
fi

if ! softwareupdate --list | grep --silent "No new software available"; then
  softwareupdate --install --all
fi

if ! fdesetup status | grep --silent -E "FileVault is (On|Off, but will be enabled after the next restart)."; then
  sudo fdesetup enable -user "$USER" | tee "$HOME/Desktop/file_vault_recovery_key.txt"
fi

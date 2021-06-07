#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodePackages.node2nix
# shellcheck shell=bash
set -euo pipefail

readonly BASEDIR="$(dirname "$(readlink -f "$0")")"

{
  cd "$BASEDIR"
  node2nix -i plugins.json -o node-packages.nix -c default.nix
}

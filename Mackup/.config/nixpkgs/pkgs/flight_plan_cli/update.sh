#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bundler bundix

set -euo pipefail

readonly BASEDIR="$(dirname "$(readlink -f "$0")")"

{
  cd "$BASEDIR"
  rm -rf Gemfile.lock gemset.nix
  bundix --magic
  rm -rf .bundle vendor
}

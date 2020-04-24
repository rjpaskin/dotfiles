#!/bin/bash
"$HOME/.nix-defexpr/channels/nixpkgs/pkgs/misc/vim-plugins/update.py" \
  --input-names "$HOME/.config/nixpkgs/pkgs/vim-plugins/names.txt" \
  --out "$HOME/.config/nixpkgs/pkgs/vim-plugins/generated.nix"

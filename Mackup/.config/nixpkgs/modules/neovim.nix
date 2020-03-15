{ config, pkgs, lib, ... }:

with lib;
with types;

let
  colourType = submodule {
    options = {
      background = mkOption {
        type = str;
        default = "";
      };
      foreground = mkOption {
        type = str;
        default = "";
      };
      modifier = mkOption {
        type = (enum [ "" "bold" ]);
        default = "";
      };
    };
  };

  myPlugins = pkgs.callPackage ../pkgs/vim-plugins {};

  generateOneColours = colours: let
    genLine = name: attrs: ''
      call one#highlight('${name}', '${attrs.foreground}', '${attrs.background}', '${attrs.modifier}')
    '';
  in strings.concatStrings (attrsets.mapAttrsToList genLine colours);

  cfg = config.programs.neovim;

in {
  options.programs.neovim = {
    plugs = mkOption {
      description = "List of Neovim packages to add via vim-plug";
      type = listOf package;
    };

    colours = mkOption {
      description = "Changes to `one` colour scheme";
      type = attrsOf colourType;
    };
  };

  config = {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      # FIXME:
      # - https://github.com/NixOS/nixpkgs/issues/81206
      # - https://github.com/NixOS/nixpkgs/pull/80528
      package = (import (builtins.fetchTarball {
        name = "nixpkgs-neovim-0.4.2";
        url = https://github.com/nixos/nixpkgs-channels/archive/44465d3480ad6f87024874842f2acb1185a350b1.tar.gz;
        sha256 = "0vrhmjbvh41mhbjqmv2lc0166y9h69ikxvs392b2b732288iz7xl";
      }) {}).pkgs.neovim-unwrapped;

      configure = {
        plug.plugins = cfg.plugs;

        customRC = ''
          colorscheme one
          set background=light
          ${generateOneColours cfg.colours}
        '';
      };

      colours = let
        white = "ffffff";
      in {
        Normal.background = white;
        ColorColumn.background = white;
        DiffAdded.background = "f5faf5";
        DiffRemoved.background = "fcedec";
        DiffLine.background = "eff4fe";
        DiffNewFile = { background = white; modifier = "bold"; };
        DiffFile = { background = white; modifier = "bold"; };
      };

      # Default packages to always use
      plugs = with pkgs.vimPlugins; [
        vim-sensible
        vim-commentary
        vim-surround
        vim-repeat
        vim-unimpaired
        vim-abolish
        vim-dispatch
        vim-eunuch
        myPlugins.vim-alias
        myPlugins.vim-mkdir
        vim-slash
        editorconfig-vim

        vim-textobj-user
        vim-textobj-variable-segment

        myPlugins.deoplete-nvim
        ale
        vim-nix

        # UI
        vim-one
        vim-airline

        # Project navigation
        myPlugins.denite-nvim
        neomru-vim
        nerdtree
        vim-nerdtree-tabs

        # Javascript
        vim-javascript
        myPlugins.vim-jsx
        emmet-vim
        myPlugins.vim-prettier

        # Ruby
        myPlugins.vim-textobj-rubyblock
        vim-ruby
        vim-endwise
        myPlugins.vim-ruby-refactoring
        myPlugins.splitjoin-vim
        myPlugins.vim-rubyhash

        # Rails
        myPlugins.vim-bundler
        myPlugins.vim-rails
        myPlugins.vim-rspec
        myPlugins.vim-yaml-helper # Pretty much only used for i18n YAML files

        # Git
        vim-fugitive
        vim-rhubarb

        # Tmux
        vim-tmux-navigator
      ];
    };
  };
}

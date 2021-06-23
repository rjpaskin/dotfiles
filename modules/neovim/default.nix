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

  generateOneColours = colours: let
    genLine = name: attrs: ''
      call one#highlight('${name}', '${attrs.foreground}', '${attrs.background}', '${attrs.modifier}')
    '';
  in strings.concatStrings (attrsets.mapAttrsToList genLine colours);

  cfg = config.programs.neovim;

in {
  options.programs.neovim.colours = mkOption {
    description = "Changes to `one` colour scheme";
    type = attrsOf colourType;
  };

  config = {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      extraConfig = ''
        " -------------------------------------------------
        "  Colour scheme
        " -------------------------------------------------
        colorscheme one
        set background=light
        ${generateOneColours cfg.colours}
        ${readFile ./init.vim}
      '';

      colours = let
        white = "ffffff";
      in {
        # https://stackoverflow.com/questions/1467438/find-out-to-which-highlight-group-a-particular-keyword-symbol-belongs-in-vim
        Normal.background = white;
        ColorColumn.background = white;

        # Replace grey background with lighter version of foreground (http://www.0to255.com)
        DiffAdded.background = "f5faf5";
        DiffRemoved.background = "fcedec";
        DiffLine.background = "eff4fe";

        DiffNewFile = { background = white; modifier = "bold"; };
        DiffFile = { background = white; modifier = "bold"; };
      };

      # Default packages to always use
      plugins = with pkgs.vimPlugins; mkBefore [
        vim-sensible
        vim-commentary
        vim-surround
        vim-repeat
        vim-unimpaired
        vim-abolish
        vim-dispatch
        vim-eunuch
        vim-alias
        vim-mkdir
        vim-slash
        editorconfig-vim

        # although this is a Tmux plugin, it works without Tmux and defines useful Ctrl+h/j/k/l window-switching keymaps
        vim-tmux-navigator

        vim-textobj-user
        vim-textobj-variable-segment

        deoplete-nvim
        ale

        # UI
        vim-one # colour scheme
        vim-airline

        # Project navigation
        { plugin = denite-nvim; optional = true; } # optional so we can `packadd` it to avoid autoloading issues
        neomru-vim
        nerdtree
        vim-nerdtree-tabs

        # Languages - move to modules?
        swift-vim
        vim-crystal
        vim-nix
      ];
    };

    xdg.configFile."nvim/after/plugin/alias.vim".text = ''
      :Alias ag grep
    '';
  };
}

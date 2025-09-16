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

  generateConfigFromAttrs = fn: attrs: concatStrings (mapAttrsToList fn attrs);

  generateOneColours = generateConfigFromAttrs (name: attrs: ''
    call one#highlight('${name}', '${attrs.foreground}', '${attrs.background}', '${attrs.modifier}')
  '');

  generateFiletypeAutocmds = generateConfigFromAttrs (glob: viml: ''
    au BufNewFile,BufRead ${glob} ${viml}
  '');

  cfg = config.programs.neovim;

in {
  options.programs.neovim = {
    colours = mkOption {
      description = "Changes to `one` colour scheme";
      type = attrsOf colourType;
    };

    filetypes = mkOption {
      description = "Filetypes mappings";
      type = attrsOf str;
    };
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

      # Redo files
      # If shebang present, use builtin filetype detection, otherwise assume `sh`
      filetypes."*.do" = ''
        if getline(1) =~ '^#!' | runtime! scripts.vim | else | setlocal filetype=sh | endif
      '';

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
        # flakePlugins.vim-mkdir
        vim-slash
        editorconfig-vim

        # although this is a Tmux plugin, it works without Tmux and defines useful Ctrl+h/j/k/l window-switching keymaps
        vim-tmux-navigator

        vim-textobj-user
        vim-textobj-variable-segment

        ale

        # UI
        vim-one # colour scheme
        vim-airline

        # Project navigation
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
            require"telescope".setup({
              pickers = {
                find_files = {
                  find_command = { "ag", "--hidden", "--path-to-ignore", vim.fs.normalize"~/.config/silver_searcher/ignore", "-l" }
                }
              }
            })

            local builtin = require"telescope.builtin"

            function telescope_mapping(key_suffix, arg, options)
              if type(arg) == "string" then
                fn = function() return builtin.find_files{ cwd = arg } end
                options = { desc = "Telescope in " .. arg }
              else
                fn = arg
              end

              return vim.keymap.set("n", "<leader>u" .. key_suffix, fn, options or {})
            end

            for key_suffix, arg in pairs{
              u = builtin.find_files,
              b = builtin.buffers,
              r = builtin.registers,
              o = builtin.current_buffer_tags,
              m = "app/models",
              c = "app/controllers",
              v = "app/views",
              h = "app/helpers",
              w = "app/workers",
              s = "spec",
              f = "spec/support/factories"
            } do telescope_mapping(key_suffix, arg) end

            telescope_mapping("p", function()
              return builtin.find_files{ cwd = vim.fn.expand("%:p:h") }
            end, { desc = "Telescope in directory of current buffer" })
          '';
        }

        {
          plugin = blink-cmp;
          type = "lua";
          config = ''
            require"blink-cmp".setup({
              keymap = {
                preset = "enter",
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" }
              }
            })
          '';
        }

        # Languages - move to modules?
        swift-vim
        vim-crystal
        vim-nix
      ];
    };

    xdg.configFile."nvim/after/plugin/alias.vim".text = ''
      :Alias ag grep
    '';

    xdg.configFile."nvim/after/plugin/vim-eunuch.vim".text = ''
      augroup RJP
        " Don't make Redo files executable, even if they have a shebang
        autocmd BufWritePre *.do unlet! b:chmod_post
      augroup END
    '';

    xdg.configFile."nvim/filetype.vim".text = ''
      if exists("did_load_filetypes")
        finish
      endif

      augroup filetypedetect
        ${generateFiletypeAutocmds cfg.filetypes}
      augroup END
    '';
  };
}

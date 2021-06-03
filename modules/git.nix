{ config, lib, pkgs, ... }:

with lib;

let
  extraConfig = {
    core = {
      quotepath = false;
      autocrlf = "input";
      editor = "nvim";
    };
    color = {
      ui = true;
      diff = "auto";
      status = "auto";
      branch = "auto";
    };
    rebase = {
      autoStash = true; # stach changes before rebase
      autoSquash = true; # always use `--autosquash`
    };
    rerere = {
      enabled = true; # record resolutions of merge conflicts
      autoupdate = true; # state rerere-resolved conflicts automatically
    };
    diff.colorMoved = "zebra";
  };

  ignores = [
    "*~"
    "\\#*\\#"
    ".DS_Store"
    "*.sw[nop]" # Vim swap files
    ".bundle"
    ".byebug_history"
    "db/*.sqlite3"
    "log/*.log"
    "rerun.txt"
    "tags" # ctags
    "!tags/"
    "tmp/**/*"
    "!tmp/cache/.keep"
    "*.pyc"
  ];

  aliases = let
    tab = "%09";
  in {
    branches = builtins.replaceStrings [ "\n" ] [ "" ] ''
      for-each-ref
        --sort=-committerdate
        --format="%(color:yellow)%(authordate:relative)${tab}%(color:blue)%(authorname)${tab}%(color:red)%(color:bold)%(refname:short)"
        refs/remotes
    '';
    local-branches = "branch -l --format=\"%(refname:short)\"";
    up = "!echo 'Fetching from remotes...' && git fetch --all --quiet && git ffwd";
  };

in {
  options.roles = with config.lib.roles; {
    git = mkOptionalRole "Git and tools";
    git-flow = mkOptionalRole "Git flow";
    git-standup = mkOptionalRole "git-standup";
  };

  config = mkIf config.roles.git (mkMerge [
    {
      programs.git = {
        inherit aliases extraConfig ignores;
        enable = true;
        package = pkgs.git-with-helpers;
      };

      home.packages = with pkgs; [
        gitAndTools.hub
        gitAndTools.git-filter-repo
        git-when-merged
      ];

      programs.neovim.plugs = with pkgs.vimPlugins; [
        vim-fugitive
        vim-rhubarb
      ];

      programs.zsh.oh-my-zsh.plugins = ["git"];

      home.file = config.lib.symlinks.dotfile
        "Library/Application Support/SourceTree/sourcetree.license";

      targets.darwin.homebrew.casks = ["sourcetree"];
    }

    {
      programs.git = let
        id = "railsschema";
      in {
        extraConfig.merge.${id} = {
          name = "newer Rails schema version";
          driver = "merge-rails-schema %O %A %B %L";
        };
        attributes = [ "db/schema.rb merge=${id}" ];
      };
    }

    (mkIf config.roles.git-flow {
      home.packages = [ pkgs.gitAndTools.gitflow ];

      programs.zsh = {
        oh-my-zsh.plugins = ["git-flow"];
        shellAliases.gf = "git-flow"; # restore now-removed shortcut
      };
    })

    (mkIf config.roles.git-standup {
      home.packages = [ pkgs.gitAndTools.git-standup ];
    })
  ]);
}

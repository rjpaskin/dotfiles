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
    gitGrep = flags: ''
      !f() { git branch -l${flags} --format="%(refname:short)" | xargs git grep "$@"; }; f "$@"
    '';
    tab = "%09";
  in {
    branches = ''
      for-each-ref \
        --sort=-committerdate \
        --format="%(color:yellow)%(authordate:relative)${tab}%(color:blue)%(authorname)${tab}%(color:red)%(color:bold)%(refname:short)" \
        refs/remotes
    '';
    local-branches = "!git branch -vv | cut -c 3- | awk '$3 !~/\\[/ { print $1 }'";
    oldest-ancestor = ''
      !zsh -c 'diff --old-line-format="" --new-line-format="" \
        <(git rev-list --first-parent "''${1:-master}") \
        <(git rev-list --first-parent "''${2:-HEAD}") | head -1' -"
    '';
    grep-branch = gitGrep("a");
    grep-branch-remote = gitGrep("r");
    grep-branch-locale = gitGrep("");
    checkout-at = ''
      !f() { rev=$(git rev-list -1 --before="$1" ''${2:-master}) && git checkout "$rev"; }; f
    '';
    rename-branch = ''
      !f() { git branch -m $1 $2; git push origin :$1; git push --set-upstream origin $2; }; f
    '';
    up = ''
      !echo 'Fetching from remotes...' && git fetch --all --quiet && git ffwd
    '';
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
        git-when-merged
      ];

      programs.neovim.plugs = with pkgs.vimPlugins; [
        vim-fugitive
        vim-rhubarb
      ];

      programs.zsh.oh-my-zsh.plugins = ["git"];

      home.file = config.lib.mackup.mackupFiles [
        "Library/Application Support/SourceTree/sourcetree.license"
      ];
    }

    {
      programs.git = let
        id = "railsschema";
      in {
        extraConfig.merge.${id} = {
          name = "newer Rails schema version";
          # TODO: interpolate path to `merge-rails-schema`
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

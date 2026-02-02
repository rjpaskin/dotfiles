{ config, lib, ... }:

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
      autoStash = true; # stash changes before rebase
      autoSquash = true; # always use `--autosquash`
    };
    rerere = {
      enabled = true; # record resolutions of merge conflicts
      autoupdate = true; # state rerere-resolved conflicts automatically
    };
    diff.colorMoved = "zebra";
    init.defaultBranch = "main";
    commit.verbose = true; # show changes in commit message editor
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

  config = lib.mkIf config.roles.git (lib.mkMerge [
    {
      hm = { config, pkgs, ... }: {
        programs.git = let
          domain = "gmail.com";
          variant = "git";
          username = "rjpaskin";
        in {
          inherit aliases ignores;
          extraConfig = lib.mkMerge [
            extraConfig
            { core.excludesFile = "${config.xdg.configHome}/git/ignore"; }
          ];
          enable = true;
          package = pkgs.callPackage ../pkgs/git-with-helpers {
            ruby = config.programs.ruby.defaultPackage;
          };
          userEmail = "${username}+${variant}@${domain}";
          userName = "Rob Paskin";
        };

        home.packages = with pkgs; [
          git-filter-repo
          git-standup
          git-when-merged
        ];

        programs.neovim.plugins = with pkgs.vimPlugins; [
          vim-fugitive
          vim-rhubarb
        ];

        programs.zsh.oh-my-zsh.plugins = [ "git" ];
      };
    }

    {
      hm.programs.git = let
        id = "railsschema";
      in {
        extraConfig.merge.${id} = {
          name = "newer Rails schema version";
          driver = "merge-rails-schema %O %A %B %L";
        };
        attributes = [ "db/*schema*.rb merge=${id}" ];
      };
    }

    {
      hm.programs.gh = {
        enable = true;
        gitCredentialHelper.enable = false; # use SSH
        settings = {
          git_protocol = "ssh";
          editor = "nvim";
        };
      };
    }

    {
      darwin.homebrew.casks = [ "sourcetree" ];
      hm.targets.darwin.defaults."com.torusknot.SourceTreeNotMAS" = {
        agreedToUpdateConfig = false; # don't touch Git global config
        bookmarksClosedOnStartup = true;
        checkRemoteStatus = false; # don't run `git fetch` in background
        commitColumnGuideWidth = 80;
        diffFontName = "Monaco";
        diffFontSize = 12.0; # needs to be float to get <real>
        diffSkipFilePatterns = ""; # show diffs for all files
        fileStatusFilterMode = 1; # show only: "pending"
        fileStatusStagingViewMode = 1; # "split view staging"
        fileStatusViewMode2 = 0; # "flat list, single column"
        useFixedWithCommitFont = true;
      };
    }

    (lib.mkIf config.roles.git-flow {
      hm = { pkgs, ... }: {
        home.packages = [ pkgs.gitflow ];

        programs.zsh = {
          oh-my-zsh.plugins = [ "git-flow" ];
          shellAliases.gf = "git-flow"; # restore now-removed shortcut
        };
      };
    })
  ]);
}

{ config, lib, pkgs, ... }:

with lib;

{
  options.roles = with config.lib.roles; {
    git = mkOptionalRole "Git and tools";
    git-flow = mkOptionalRole "Git flow";
    git-standup = mkOptionalRole "git-standup";
  };

  config = mkIf config.roles.git (mkMerge [
    {
      home.packages = with pkgs; [
        # TODO: git
        gitAndTools.hub
        git-when-merged
      ];

      programs.neovim.plugs = with pkgs.vimPlugins; [
        vim-fugitive
        vim-rhubarb
      ];

      programs.zsh.oh-my-zsh.plugins = ["git"];

      home.symlinks = config.lib.mackup.mackupFiles [
        ".config/git/attributes"
        ".config/git/ignore"
        ".config/git/config"
        ".config/git/config.local"

        "Library/Application Support/SourceTree/sourcetree.license"
      ];
    }

    (mkIf config.roles.git-flow {
      home.packages = with pkgs; [
        gitAndTools.gitflow
      ];

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

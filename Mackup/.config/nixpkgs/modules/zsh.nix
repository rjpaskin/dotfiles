{ config, lib, ... }:

let
  dag = lib.hm.dag;

in {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableCompletion = true;

    history = {
      path = ".local/share/zsh/history";
      # Match oh-my-zsh settings
      extended = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      size = 50000;
      save = 10000;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";

      plugins = [
        "history-substring-search"
        "osx"
      ];
    };
  };
}

{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    # Use `script/switch` instead
    programs.home-manager.enable = false;

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "23.11";

    news.display = "silent";

    # Disable `man` so that we don't get `pkgs.man` and all its accompanying executables,
    # but still add `man` to `extraOutputsToInstall` as the `man` module does
    programs.man.enable = false;
    home.extraOutputsToInstall = [ "man" ];

    # Prevent activation script from installing packages into ~/.nix-profile
    # - we do this ourselves later on
    home.activation = with lib.hm; {
      disableNixEnv = dag.entryBefore ["installPackages"] ''
        nix-env() { echo "==> Disabled - packages installed later"; }
      '';

      reenableNixEnv = dag.entryBefore ["linkGeneration"] ''
        unset -f nix-env
      '';
    };

    home.extraBuilderCommands = ''
      mkdir -p $out/rjp

      # Link the flake source that build this generation
      ln -s '${./.}' $out/rjp/source

      # Record the roles that were used to build this generation
      echo '${builtins.toJSON config.roles}' > $out/rjp/roles.json
    '';

    home.extraActivationPath = [ pkgs.gawk ];

    xdg.configFile."nix/nix.conf".source = ./nix.conf;
  };

  imports = [
    ./modules/roles.nix

    ./modules/clojure
    ./modules/dock
    ./modules/docker
    ./modules/git.nix
    ./modules/heroku.nix
    ./modules/homebrew
    ./modules/javascript.nix
    ./modules/macos_defaults
    ./modules/misc.nix
    ./modules/neovim
    ./modules/pkgs.nix
    ./modules/ruby.nix
    ./modules/symlinks.nix
    ./modules/tmux
    ./modules/zsh.nix
  ];
}

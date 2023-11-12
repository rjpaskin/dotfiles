{ config, lib, ... }:

{
  config = {
    home.file = lib.mkMerge [
      {
        ".ssh/config".text = ''
          # Required for macOS Sierra 10.12.2 or later
          # See https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
          Host *
           AddKeysToAgent yes
           UseKeychain yes
           IgnoreUnknown UseKeychain
           IdentityFile ${
             if builtins.pathExists "${config.home.homeDirectory}/.ssh/id_ed25519"
             then "~/.ssh/id_ed25519"
             else "~/.ssh/id_rsa"
           }

          Include config.private
        '';
      }

      (config.lib.symlinks.privateFile "ssh/config.private")
    ];
  };
}

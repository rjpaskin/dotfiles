{
  hm = { config, lib, ... }: {
    options.sshKeyType = with lib; mkOption {
      type = types.enum [ "rsa" "ed25519" ];
      default = "ed25519";
      description = "Type of SSH key to use";
    };

    config = {
      home.file.".ssh/config".text = ''
        # Required for macOS Sierra 10.12.2 or later
        # See https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
        Host *
         AddKeysToAgent yes
         UseKeychain yes
         IgnoreUnknown UseKeychain
         IdentityFile ~/.ssh/id_${config.sshKeyType}
      '';
    };
  };

  # SSH doesn't log an error if these key files don't exist
  # *when* the config is 'global' (i.e. in `/etc`) but *does* log
  # if these lines are in `~/.ssh/config`
  # (See: https://serverfault.com/a/582989)
  darwin.config.programs.ssh.extraConfig = ''
    Host *
     # Use host-specific key if it exists
     IdentityFile ~/.ssh/%h/id_ed25519
     IdentityFile ~/.ssh/%h/id_rsa
  '';
}

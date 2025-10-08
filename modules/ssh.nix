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
}

{
  users = {
    users = {
      root = {
        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuGpnauohlQMdECiETb8ss2pxssLSmj7b/fDkxaut5P Michael@MagicBook"
            ];
          };
        };
      };
    };
  };
  system = {
    activationScripts = {
      copy-ssh-keys = ''
        mkdir -p /root/.ssh
        cp ${../secrets/id_ed25519} /root/.ssh/id_ed25519
        chmod 600 /root/.ssh/id_ed25519
      '';
    };
  };
}

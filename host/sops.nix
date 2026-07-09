{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      "user-password" = {
        neededForUsers = true;
      };
    };
    age = {
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
    };
  };
}

{
  pkgs,
  config,
  ...
}:
{
  users = {
    users = {
      Michael = {
        isNormalUser = true;
        shell = pkgs.zsh;
        hashedPasswordFile = config.sops.secrets."user-password".path;
        extraGroups = [
          "docker"
          "dockerd"
          "input"
          "networkmanager"
          "wheel"
          "ydotool"
        ];
      };
      root = {
        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHquLtA5jws3bQt1eSvwYvXvi0nKBQYKMoewxkYoN87m Michael@MagicBook"
            ];
          };
        };
      };
    };
  };
}

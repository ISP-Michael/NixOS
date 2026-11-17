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
        hashedPasswordFile =
          if config.sops.secrets ? "user-password" then
            config.sops.secrets."user-password".path
          else
            null;
        extraGroups = [
          "docker"
          "dockerd"
          "gamemode"
          "input"
          "networkmanager"
          "wheel"
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

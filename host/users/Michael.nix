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
        shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets."user-password".path;
        extraGroups = [
          "docker"
          "dockerd"
          "input"
          "networkmanager"
          "wheel"
        ];
      };
    };
  };
}

{
  pkgs,
  ...
}:
{
  users = {
    users = {
      Michael = {
        isNormalUser = true;
        password = "michael";
        shell = pkgs.fish;
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

{ pkgs, ... }:
let
  extraGroups = [
    "docker"
    "dockerd"
    "input"
    "networkmanager"
    "wheel"
  ];
in
{
  users = {
    users = {
      Michael = {
        isNormalUser = true;
        password     = "michael";
        shell        = pkgs.fish;
        extraGroups  = extraGroups;
      };
    };
  };
}

{ pkgs, ... }:
{
  users = {
    users.Michael = {
      isNormalUser = true;
      password = "michael";
      extraGroups = [
        "wheel"
        "input"
        "docker"
        "dockerd"
        "networkmanager"
      ];
      shell = pkgs.fish;
    };
    groups.libvirtd.members = [ "Michael" ];
  };
}

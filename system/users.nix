{ pkgs, ... }:
{
  users = {
    users.Michael = {
      isNormalUser = true;
      password = "michael";
      extraGroups = [
        "wheel"
        "input"
        "networkmanager"
        "docker"
        "dockerd"
      ];
      shell = pkgs.fish;
    };
    groups.libvirtd.members = [ "Michael" ];
  };
}

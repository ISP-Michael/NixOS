{
  services = {
    navidrome = {
      enable = false;
      settings = {
        MusicFolder = "/var/lib/music";
        DataFolder = "/var/lib/navidrome";
        Port = 4533;
        SubsonicSidebar = true;
      };
    };
    lidarr.enable = true;
    prowlarr.enable = true;
  };
}

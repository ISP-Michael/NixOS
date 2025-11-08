{
  pkgs,
  nur,
  ...
}:
{
  programs = {
    firefox = {
      enable  = true;
      profiles = {
        profile = {
          id = 0;
          name = "Michael";
          extensions = {
            force = true;
            packages = with nur.legacyPackages."x86_64-linux".repos.rycee.firefox-addons; [
              vimium
              translate-web-pages
            ];
          };
        };
      };
    };
  };
}

{
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
          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
            "browser.uidensity" = 0;
            "svg.context-properties.content.enabled" = true;
          };
        };
      };
    };
  };
}

{
  identity,
  nur,
  pkgs,
  ...
}:
{
  programs = {
    firefox = {
      enable  = true;
      configPath = ".mozilla/firefox";
      profiles = {
        profile = {
          id = 0;
          name = identity.user;
          path = "r0k4lu1c.default";
          isDefault = true;
          extensions = {
            force = true;
            packages = with nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee.firefox-addons; [
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

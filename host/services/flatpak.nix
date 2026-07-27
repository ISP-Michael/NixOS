{
  services = {
    flatpak = {
      enable = true;
      update.onActivation = true;
      packages = [
        # "flathub:app.zen_browser.zen"
      ];
    };
  };
}

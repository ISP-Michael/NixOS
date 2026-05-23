{
  services = {
    flatpak = {
      enable = true;
      update.onActivation = true;
      packages = [
        "ru.yandex.Browser"
      ];
    };
  };
}

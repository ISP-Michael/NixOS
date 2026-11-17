{
  # Noctalia красит Chromium через policy-файл. Каталог создаётся
  # tmpfiles, потому что /etc/chromium/policies/managed — не Nix-опция.
  systemd.tmpfiles.settings."10-noctalia-chromium" = {
    "/etc/chromium/policies/managed".d = {
      mode = "0755";
    };
    "/etc/chromium/policies/managed/noctalia-color.json".f = {
      user = "Michael";
      group = "users";
      mode = "0644";
      argument = "{}";
    };
  };
}

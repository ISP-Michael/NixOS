{
  pkgs,
  lib,
  ...
}:
# ─────────────────────────────────────────────────────────────
# Единый шаблон для /opt-установок VPN-клиентов.
# Официальные бинарники ставятся в /opt/<App> вручную (как AmneziaVPN):
#   - GUI бинарь запускается через writeShellScriptBin-обёртку с nix-ld
#   - TUN/привилегии решаются через setcap на бинаре-ядра в /opt
#   - desktop-файл для меню
# Throne 1.3.0-beta.2 -> /opt/Throne (ThroneCore с cap_net_admin для TUN).
# ─────────────────────────────────────────────────────────────
let
  optBinPath = "/opt/Throne";
in
{
  # Клиент Throne 1.3.0-beta.2 (перестали собирать из nixpkgs-исходников 1.2.2).
  # -appdata обязателен: без него GUI молча выходит (как в nixpkgs-сборке).
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "throne"
      "exec env NIX_LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib ${optBinPath}/Throne -appdata \"$@\"")
    (pkgs.writeShellScriptBin "Throne"
      "exec env NIX_LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib ${optBinPath}/Throne -appdata \"$@\"")
    (pkgs.makeDesktopItem {
      name = "throne";
      desktopName = "Throne";
      exec = "Throne";
      icon = "/opt/Throne/Throne.png";
      comment = "Qt based cross-platform GUI proxy configuration manager";
      terminal = false;
      categories = [ "Network" ];
    })
  ];

  # Polkit: разрешить ThroneCore (с cap_net_admin) настраивать DNS
  # через systemd-resolved без пароля. Тот же трюк, что в nixpkgs-модуле.
  security.polkit.extraConfig = lib.mkAfter ''
    polkit.addRule(function(action, subject) {
      const allowedActionIds = [
        "org.freedesktop.resolve1.revert",
        "org.freedesktop.resolve1.set-domains",
        "org.freedesktop.resolve1.set-default-route",
        "org.freedesktop.resolve1.set-dns-servers"
      ];

      if (allowedActionIds.indexOf(action.id) !== -1) {
        try {
          var parentPid = polkit.spawn(["${lib.getExe' pkgs.procps "ps"}", "-o", "ppid=", subject.pid]).trim();
          var parentCap = polkit.spawn(["${lib.getExe' pkgs.libcap "getpcaps"}", parentPid]).trim();
          if (parentCap.includes("cap_net_admin") && parentCap.includes("cap_net_raw")) {
            return polkit.Result.YES;
          } else {
            return polkit.Result.NOT_HANDLED;
          }
        } catch (e) {
          return polkit.Result.NOT_HANDLED;
        }
      }
    })
  '';
}
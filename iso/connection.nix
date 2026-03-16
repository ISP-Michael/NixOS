{
  pkgs,
  ...
}:
{
  systemd = {
    services = {
      nm-config = {
        description = "Auto-connect to Wi-Fi";
        after = [
          "network.target"
          "NetworkManager.service"
        ];
        wantedBy = [
          "multi-user.target"
        ];
        serviceConfig = {
          Type = "oneshot";
        };
        script = ''
          sleep 5
          ${pkgs.networkmanager}/bin/nmcli \
          device wifi connect \
          "MTS_GPON_f63278"  password "Jh47g927" || true
        '';
      };
    };
  };
}

{
  networking = {
    firewall = {
      enable = true;

      # LocalSend: TCP/UDP 53317 (передача и обнаружение).
      # rquickshare: статический TCP 53318 + mDNS на UDP 5353.
      allowedTCPPorts = [
        53317
        53318
      ];
      allowedUDPPorts = [
        5353
        53317
      ];

      # Порт для консоли libvirt/SPICE. Явно оставлен: правило было
      # в старом networking.nix, хотя слушателя сейчас может не быть.
      interfaces = {
        virbr0 = {
          allowedTCPPorts = [
            37963
          ];
        };
      };
    };
  };
}

{
  imports = [
    # ./amnezia-escape.nix
    ./amnezia-vpn-service.nix
    ./flatpak.nix
    ./fprintd.nix
    ./fstrim.nix
    ./happ-opt.nix
    ./keyd.nix
    ./logind.nix
    ./mihomo.nix
    ./pipewire.nix
    ./proxy.nix
    ./qbittorrent.nix
    ./resolved.nix
    ./services.nix
    ./warp.nix
    # ./zapret2.nix  # выключен 14.11.2026: при поднятом AmneziaWG не нужен; /opt/zapret2 остался
  ];
}

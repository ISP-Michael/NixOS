{
  pkgs,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      nftables
    ];
  };
  services = {
    zapret = {
      enable = true;
      udpSupport = true;
      udpPorts = [
        "443"
        "50000:50099"
      ];
      params = [
        "--filter-tcp=80"
        "--dpi-desync=fake,fakedsplit"
        "--dpi-desync-autottl=2"
        "--dpi-desync-fooling=md5sig"
        "--new"
        "--filter-tcp=443"
        "--dpi-desync=fake,multidisorder"
        "--dpi-desync-split-pos=1,midsld"
        "--dpi-desync-repeats=11"
        "--dpi-desync-fooling=md5sig"
        "--new"
        "--filter-udp=443,50000-50099"
        "--dpi-desync=fake"
        "--dpi-desync-repeats=11"
      ];
      whitelist = [
        "youtube.com"
        "googlevideo.com"
        "youtu.be"
        "ytimg.com"
        "ggpht.com"
        "discord.com"
        "discordapp.com"
        "discordapp.net"
        "discord.gg"
        "discord-attachments-uploads-prd.storage.googleapis.com"
      ];
    };
  };
}


{
  services = {
    zapret = {
      enable = true;
      httpSupport = true;
      whitelist = [
        "youtube.com"
        "www.youtube.com"
        "youtu.be"
        "googlevideo.com"
        "ytimg.com"
        "ggpht.com"
        "youtubei.googleapis.com"
      ];
      params = [
        "--filter-tcp=443"
        "--dpi-desync=fake,multidisorder"
        "--dpi-desync-split-pos=midsld"
        "--dpi-desync-fooling=badseq"
        "--dpi-desync-fake-tls=0x00000000"
        "--dpi-desync-repeats=2"
        "--new"
        "--filter-udp=443"
        "--dpi-desync=fake"
        "--dpi-desync-repeats=3"
        "--dpi-desync-fooling=badsum"
      ];
    };
  };
  boot = {
    kernel = {
      sysctl = {
        "net.ipv4.ip_forward" = 1;
      };
    };
  };
}

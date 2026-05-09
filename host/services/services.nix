{
  lib,
  ...
}:
let
  enabledDefaults = lib.genAttrs [
    "blueman"
    "libinput"
    "udisks2"
  ]
  (name: {
      enable = true;
    }
  );
in
{
  services = enabledDefaults // {
    postgresql = {
      enable = true;
    };

    zapret = {
      enable = true;
      params = [
        "--filter-tcp=80 --dpi-desync=methodeol"
        "--filter-tcp=443 --dpi-desync=fake,multisplit --dpi-desync-ttl=3 --orig-ttl=1 --orig-mod-start=s1 --orig-mod-cutoff=d1 --dpi-desync-split-pos=1,midsld --dpi-desync-fake-tls=0x1603 --dpi-desync-fake-tls=!+2 --dpi-desync-fake-tls-mod=rnd,dupsid,rndsni --dpi-desync-fake-tcp-mod=seq"
      ];
    };
  };
}

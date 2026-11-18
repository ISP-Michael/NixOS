{
  config,
  ...
}:
{
  networking = {
    hostName = config.host.hostName;
    enableIPv6 = true;
    # DNS задаётся в network/resolved.nix; второй список здесь только
    # сбивал бы с толку.
    networkmanager = {
      enable = true;
      wifi = {
        scanRandMacAddress = false;
      };
    };
  };
}

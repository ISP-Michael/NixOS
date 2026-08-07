{ config, lib, ... }:

{
  systemd.services.emias-monitor = {
    description = "EMIAS slot monitor for Borisova (Telegram notifications)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      User = "Michael";
      Group = "users";
      WorkingDirectory = "/home/Michael/emias-monitor";
      ExecStart = "/home/Michael/emias-monitor/run.sh --loop";
      Restart = "always";
      RestartSec = 60;
      StandardOutput = "append:/home/Michael/emias-monitor/monitor.log";
      StandardError = "inherit";
    };
  };
}

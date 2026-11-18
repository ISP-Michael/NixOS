{
  lib,
  ...
}:
{
  options.host = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "Michael";
      description = "Основной пользователь системы.";
    };

    home = lib.mkOption {
      type = lib.types.str;
      default = "/home/Michael";
      description = "Домашний каталог основного пользователя.";
    };

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos";
      description = "Путь к этому репозиторию на машине.";
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "MagicBook";
      description = "Имя машины в сети.";
    };

    diskDevice = lib.mkOption {
      type = lib.types.str;
      default = "/dev/nvme0n1";
      description = "Диск, на который ставится система (disko).";
    };

    gitName = lib.mkOption {
      type = lib.types.str;
      default = "Michael";
      description = "Имя для git.";
    };

    gitEmail = lib.mkOption {
      type = lib.types.str;
      default = "mtr.mikhail090905@gmail.com";
      description = "Email для git.";
    };
  };
}

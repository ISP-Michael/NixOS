{
  config,
  lib,
  ...
}:
{
  # Установочный профиль MagicBook: не расшифровываем sops при
  # nixos-install и задаём временный пароль. Это не отдельная система,
  # а те же host-модули с двумя переопределениями.
  #
  # После первого входа задай пароль/добавь sops-ключ и пересобери
  # #MagicBook. Для nix build/rebuild build профиль не нужен.
  sops = {
    secrets = lib.mkForce { };
  };

  users = {
    users = {
      ${config.host.user} = {
        hashedPasswordFile = lib.mkForce null;
        initialPassword = lib.mkForce "nixos";
      };
    };
  };
}

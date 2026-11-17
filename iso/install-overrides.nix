{
  lib,
  ...
}:
{
  # Установочный профиль: не расшифровываем sops при nixos-install.
  # После первого входа задай пароль/пересобери #MagicBook с ключом.
  sops = {
    secrets = lib.mkForce { };
  };

  users = {
    users = {
      Michael = {
        hashedPasswordFile = lib.mkForce null;
        initialPassword = lib.mkForce "nixos";
      };
    };
  };
}

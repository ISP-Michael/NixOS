{
  ...
}:
{
  # Throne переехал на официальную установку из GitHub-релиза в /opt/Throne
  # (актуальная версия — topics/throne.md) — см. ./opt-vpn.nix.
  # Nixpkgs-сборка 1.2.2 из исходников отключена, чтобы не было конфликта
  # setuid-wrappers ThroneCore и старой версии в PATH.
  programs = {
    throne = {
      enable = false;
    };
  };
}
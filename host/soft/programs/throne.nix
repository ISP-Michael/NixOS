{
  ...
}:
{
  # Throne переехал на официальную установку из GitHub-релиза в /opt/Throne
  # (1.3.0-beta.2) — см. ./opt-vpn.nix (единый шаблон /opt VPN-клиентов).
  # Nixpkgs-сборка 1.2.2 из исходников отключена, чтобы не было конфликта
  # setuid-wrappers ThroneCore и старой версии в PATH.
  programs = {
    throne = {
      enable = false;
    };
  };
}
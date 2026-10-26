{
  imports = [
    ./boot.nix
    ./console.nix
    ./disko.nix
    ./documentation.nix
    ./hardware-configuration.nix
    ./home-manager.nix
    ./networking.nix
    ./overlays.nix
    ./scripts
    ./services
    ./settings
    ./soft
    ./sops.nix
    ./ssh.nix
    ./system
    ./systemd.nix
    ./time.nix
    ./users
  ];
  environment = {
    sessionVariables = {
      # Файловые диалоги GTK-приложений (Zen и прочие) — через XDG-портал,
      # чтобы выглядели как у Dolphin (KDE-бэкенд выбран в hyprland.nix),
      # а не как нативный GTK-пикер.
      GTK_USE_PORTAL = "1";
    };
  };
  environment.etc."zshenv.local".text = ''
    export ZDOTDIR="$HOME/.config/zsh"
  '';
  services.journald.settings.Journal.SystemMaxUse = "1G";
}

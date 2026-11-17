{
  environment = {
    sessionVariables = {
      # Файловые диалоги GTK-приложений (Zen и прочие) — через XDG-портал,
      # чтобы выглядели как у Dolphin (KDE-бэкенд выбран в desktop/hyprland.nix),
      # а не как нативный GTK-пикер.
      GTK_USE_PORTAL = "1";
    };
    etc."zshenv.local".text = ''
      export ZDOTDIR="$HOME/.config/zsh"
    '';
  };
}

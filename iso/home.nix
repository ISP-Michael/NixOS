{
  inputs,
  lib,
  nur,
  self,
  ...
}:
let
  # Копия репозитория, которую activation-скрипт кладёт в /etc/nixos.
  repo = "/etc/nixos";
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit
        inputs
        nur
        self
        ;
    };
    users.Michael =
      { config, pkgs, ... }:
      let
        link = path: config.lib.file.mkOutOfStoreSymlink path;
      in
      {
        imports = [
          "${self}/user/base.nix"
          "${self}/user/programs/firefox.nix"
          "${self}/user/programs/git.nix"
          "${self}/user/programs/noctalia"
          "${self}/user/theme"
        ];

        home = {
          sessionVariables = {
            BROWSER = lib.mkForce "firefox";
            EDITOR = "nvim";
            TERMINAL = "kitty";
          };
          file = {
            "Data/Pictures/Wallpapers/default.png".source = "${pkgs.hyprland}/share/hypr/wall1.png";
            "Pictures/screenshots/.keep".text = "";
            ".config/fastfetch".source = link "${repo}/user/dotfiles/.config/fastfetch";
            ".config/hypr".source = link "${repo}/iso/config/hypr";
            ".config/kitty".source = link "${repo}/user/dotfiles/.config/kitty";
            ".config/nvim".source = link "${repo}/user/dotfiles/.config/nvim";
            ".config/tmux".source = link "${repo}/user/dotfiles/.config/tmux";
            ".config/yazi".source = link "${repo}/user/dotfiles/.config/yazi";
            ".config/zsh".source = link "${repo}/user/dotfiles/.config/zsh";
          };
        };

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
            "image/gif" = [ "imv.desktop" ];
            "image/jpeg" = [ "imv.desktop" ];
            "image/png" = [ "imv.desktop" ];
            "image/webp" = [ "imv.desktop" ];
            "inode/directory" = [ "thunar.desktop" ];
            "text/html" = [ "firefox.desktop" ];
            "text/plain" = [ "nvim.desktop" ];
            "video/mp4" = [ "mpv.desktop" ];
            "video/webm" = [ "mpv.desktop" ];
            "video/x-matroska" = [ "mpv.desktop" ];
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
            "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
          };
        };
      };
  };
}

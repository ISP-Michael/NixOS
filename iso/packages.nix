{
  pkgs,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      firefox
      git
      kitty
      neovim
      telegram-desktop
    ];
  };
}

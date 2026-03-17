{
  pkgs,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      firefox
      kitty
      git
      neovim
      telegram-desktop
    ];
  };
}

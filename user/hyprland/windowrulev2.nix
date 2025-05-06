{
  wayland.windowManager.hyprland = {
    windowrulev2 = [
      "suppressevent maximize, class:.*" 
      "float,        class:kitty"
      "float,        class:thunar"
      "float,        class:firefox"
      "float,        title:Telegram"
      "float,        title:Choose Files"
      "float,        class:Chromium-browser"
      "size 80% 90%, class:thunar"
      "size 92% 92%, class:firefox"
      "size 92% 92%, title:Telegram"
      "size 70% 80%, title:Choose Files"
      "size 92% 92%, class:Chromium-browser"
      "move  2%  3%, class:kitty"
      "move  6%  5%, class:thunar"
      "move  6%  5%, class:firefox"
      "move  6%  5%, title:Telegram"
      "move 20% 15%, title:Choose Files"
      "move  6%  5%, class:Chromium-browser"
    ];
  };
}

{ pkgs, winapps-pkgs, zen-browser-pkgs, ayugram-desktop-pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget

    # TTY
    kitty
    alacritty
    powershell
    ghostty

    # Hyrpland
    polkit
    dconf
    hyprpaper
    hyprlock
    hyprshot
    hyprutils
    hyprcursor
    hyprlang

    # Development
    neovim
    zed-editor-fhs
    tmux
    vscode-fhs

    # Shells
    nushell
    zsh
    starship

    # Utils (TUI)
    et
    htop
    btop
    powertop
    tree
    bat
    amdgpu_top
    ripgrep
    fd
    dust
    gdu
    dua
    entr
    ansifilter
    bc
    imagemagick
    zip
    unzip
    fzf
    clipse
    wl-clipboard
    neofetch
    fastfetch
    pavucontrol
    cron
    memtester
    file
    disko
    tesseract
    ventoy-full
    pass
    moreutils
    wl-clipboard
    nix-init
    nh
    nixdoc
    nixfmt-rfc-style
    pre-commit
    pamixer
    eww
    playerctl
    incron

    # Languages
    go
    goimports-reviser
    php
    cargo
    typescript
    lua
    dotnetCorePackages.dotnet_9.sdk
    nodejs_23
    nodePackages_latest.live-server
    nodePackages_latest.browser-sync
    nodePackages_latest.prettier
    cl
    zig
    sass
    jdk

    # GUI utils
    wofi
    rofi-wayland
    brightnessctl
    bluez
    acpi
    nwg-look
    gtk4

    # Python
    python313Full
    (python312.withPackages(ps: [
      ps.numpy
      ps.requests
      ps.pandas
    ]))
    uv

    # 3D
    godot_4
    blender

    # C/C++
    gcc
    clang
    clang-tools
    glibc
    glibcLocales
    cmake
    gnumake
    binutils

    # Libs & Dependencies
    openssl
    zlib
    bzip3
    libffi
    pkg-config
    justbuild

    # LSP, Linters, Formatters
    pyright
    basedpyright
    gopls
    gosimports
    hyprls
    nixd
    yaml-language-server
    rust-analyzer
    csharp-ls
    lua-language-server
    vim-language-server
    bash-language-server
    dockerfile-language-server-nodejs
    docker-compose-language-service
    oxlint
    biome
    superhtml
    emmet-ls
    sqls
    fish-lsp

    # Images & Videos
    imv
    mpv
    obs-studio

    # FM (File managers)
    lf
    xplr
    ranger
    kdePackages.dolphin
    nautilus

    # Themes
    nordzy-cursor-theme
    redis
    sqlite
    mongodb-ce
    sqlitebrowser

    # Containers
    docker-compose

    # Proxy & VPN
    nekoray
    sing-geoip
    sing-geosite
    sing-box
    xray
    spoofdpi
    v2ray

    # Winapps
    winapps-pkgs.winapps
    winapps-pkgs.winapps-launcher

    telegram-desktop
    ayugram-desktop-pkgs.ayugram-desktop
    obsidian
    libreoffice-qt6-fresh
    waydroid
    pywal
    zen-browser-pkgs.generic
  ];
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  profileData = import ./profile-data.nix;

  # OpenCode 2.3.0: официальный релиз, а не сломанный nixpkgs-пакет.
  opencodePackage = import ../apps/opencode/package.nix { inherit pkgs; };

  # Chromium нужен только Playwright MCP OpenCode. В системный PATH
  # кладём обёртку без desktop-файла, чтобы в меню остался только Firefox.
  chromiumForPlaywright = pkgs.writeShellScriptBin "chromium" ''
    exec ${pkgs.chromium}/bin/chromium "$@"
  '';

  # Базовый набор: то, без чего live-система не ощущается системой.
  common = with pkgs; [
    # Рабочий стол и Wayland
    hyprland
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    kitty
    rofi
    fuzzel
    thunar
    thunar-volman
    tumbler
    file-roller
    imv
    mpv
    zathura
    poppler-utils
    wl-clipboard
    cliphist
    grim
    slurp
    hyprpicker
    hyprpolkitagent
    wtype
    brightnessctl
    pamixer
    playerctl
    pavucontrol
    networkmanagerapplet
    blueman

    # Браузер и базовые сетевые вещи
    firefox
    wget
    curl
    dig
    traceroute
    socat
    tcpdump

    # Шрифты и тема
    dejavu_fonts
    liberation_ttf
    nerd-fonts.fira-code
    noto-fonts
    nordzy-cursor-theme
    nordzy-icon-theme

    # Терминал и повседневные CLI
    git
    neovim
    helix
    yazi
    ripgrep
    fd
    fzf
    jq
    yq
    bat
    eza
    zoxide
    starship
    fastfetch
    htop
    btop
    tmux
    zsh
    mdcat
    p7zip
    zip
    unzip
    unrar
    file
    tree
    less
    which
    killall
    usbutils
    pciutils
    dmidecode
    lshw
    smartmontools
    nvme-cli
    exfatprogs
    ntfsprogs-plus

    # Работа с конфигом и установка
    nix-output-monitor
    nix-tree
    nix-index
    nvd
    nix-diff
    nix-init
    nixd
    alejandra
    statix
    sops
    ssh-to-age
    disko
  ];

  # Офис и мессенджер. Браузер — только Firefox (в common).
  work = with pkgs; [
    libreoffice
    telegram-desktop
    keepassxc
    copyq
    pandoc
    gh
  ];

  # Runtime для OpenCode/OpenClaw и ручных приложений: без этого
  # install.sh/docs/transfer.md на live-системе работают наполовину.
  agent = with pkgs; [
    chromiumForPlaywright
    nodejs_latest
    python3
    restic
    sqlite
    opencodePackage
  ];

  # Базовые вещи для дисков, VPN-клиентов и переноса ключей.
  portable = with pkgs; [
    age
    btrfs-progs
    cryptsetup
    dosfstools
    e2fsprogs
    gnupg
    gptfdisk
    iptables
    iproute2
    lm_sensors
    lsb-release
    lvm2
    mdadm
    net-tools
    nftables
    openvpn
    parted
    procps
    rsync
    sshfs-fuse
    wireguard-tools
    xfsprogs
  ];

  # Тяжёлые графические приложения.
  media = with pkgs; [
    gimp
    obs-studio
    vlc
    ffmpeg
    imagemagick
    kdePackages.dolphin
    kdePackages.kdialog
    kdePackages.okular
    kdePackages.ark
    kdePackages.kio-extras
    kdePackages.kio-admin
  ];

  # Разработка и «всё остальное».
  full = with pkgs; [
    gcc
    gnumake
    pkg-config
    go
    rustc
    cargo
    jdk
    dotnet-sdk_10
    php
    lua
    zig
    thunderbird
    qbittorrent
    obsidian
    bitwarden-desktop
  ];

  # Lite + выборочно work/full. Это не «всё», а рабочая середина:
  # офис, Telegram, пароли, агенты и runtime для ручных приложений.
  # Хочешь ближе к Lite — убери libreoffice/telegram из списка ниже.
  custom = with pkgs; [
    keepassxc
    libreoffice
    pandoc
    telegram-desktop
  ];

  profiles = {
    lite = {
      packages = common ++ portable;
      description = "рабочий стол, Firefox, файлы, медиа, CLI, portable runtime";
    };
    work = {
      packages = common ++ portable ++ work ++ agent;
      description = "lite + LibreOffice, Telegram, KeePassXC, CopyQ, OpenCode, AmneziaVPN + Happ, агентский runtime";
    };
    media = {
      packages = common ++ portable ++ work ++ media ++ agent;
      description = "work + GIMP, OBS, VLC, KDE-приложения";
    };
    full = {
      packages = common ++ portable ++ work ++ media ++ full ++ agent;
      description = "media + языки/тулчейны, Obsidian, Bitwarden, Thunderbird";
    };
    custom = {
      packages = common ++ portable ++ custom ++ agent;
      description = "lite + LibreOffice, Telegram, KeePassXC, Pandoc, OpenCode, AmneziaVPN + Happ, агентский runtime";
    };
  };
in
{
  options.iso = {
    profile = lib.mkOption {
      type = lib.types.enum (builtins.attrNames profiles);
      default = "work";
      description = ''
        Набор пакетов на ISO:
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: value: "- ${name} — ${value.description};") profiles
        )}
      '';
    };

    agent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = profileData.${config.iso.profile}.agent;
        description = "Runtime для OpenCode/OpenClaw: Node, Python, Chromium, restic, sqlite, npm, SearXNG.";
      };
    };
  };

  config = {
    environment.systemPackages = profiles.${config.iso.profile}.packages;
  };
}

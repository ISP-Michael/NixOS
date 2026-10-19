{
  pkgs,
  inputs,
  system,
  ...
}:
let
  noctalia-shell = pkgs.noctalia;
  zen = inputs.zen-browser.packages.${system}.default;
  openclaw = inputs.nix-openclaw.packages.${system}.openclaw;
  freesmlauncher = inputs.freesmlauncher.packages.${system}.freesmlauncher;
  # Telegram: файловый диалог через портал (KDE), а не встроенный Qt из-за сессионного qt5ct
  telegram-portal = pkgs.runCommand "telegram-desktop-portal" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin $out/share
    makeWrapper ${pkgs.telegram-desktop}/bin/Telegram $out/bin/Telegram \
      --set QT_QPA_PLATFORMTHEME xdgdesktopportal
    for d in applications icons metainfo; do
      ln -s ${pkgs.telegram-desktop}/share/$d $out/share/$d
    done
    mkdir -p $out/share/dbus-1/services
    sed "s|${pkgs.telegram-desktop}/bin/Telegram|$out/bin/Telegram|" \
      ${pkgs.telegram-desktop}/share/dbus-1/services/org.telegram.desktop.service \
      > $out/share/dbus-1/services/org.telegram.desktop.service
  '';
  neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.default;
  # Ночной Neovide: стабильный 0.16.2 не разбирает api-info от nvim-nightly
  # (новое поле `optional`, фикс только в main — PR #3530), поэтому берём
  # бинарник из rolling-релиза `nightly` (asset от 2026-10-16, коммит 19c705370fda).
  # При обновлении апстрима хеш и version брать так:
  #   nix store prefetch-file --json --hash-type sha256 <URL ниже>
  neovide-nightly = pkgs.stdenvNoCC.mkDerivation {
    pname = "neovide";
    version = "nightly-g19c7053";

    src = pkgs.fetchurl {
      url = "https://github.com/neovide/neovide/releases/download/nightly/neovide-linux-x86_64.tar.gz";
      hash = "sha256-FQhFmrYxGChq1MXU50KviSoMr5D/MlBEQ630A2FEu4U=";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib pkgs.fontconfig ];

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      install -Dm755 neovide $out/bin/neovide
    '';

    postFixup = ''
      wrapProgram $out/bin/neovide \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
          pkgs.libglvnd
          pkgs.libxkbcommon
          pkgs.libx11
          pkgs.libxcursor
          pkgs.libxext
          pkgs.libxrandr
          pkgs.libxi
          pkgs.wayland
        ]}
    '';

    meta.mainProgram = "neovide";
  };
  python13Env = pkgs.python313.withPackages (
    ps:
      with ps; [
        aiogram
        cython
        debugpy
        django
        fastapi
        fastapi-cli
        grip
        matplotlib
        (lib.hiPrio nox)
        nuitka
        numpy
        pandas
        pillow
        psutil
        requests
        rich
      ]
  );
in
{
  home = {
    packages = (
      with pkgs; [
        acpi
        alacritty
        alejandra
        amberol
        amdgpu_top
        ani-cli
        ansifilter
        atuin
        bash-language-server
        bitwarden-desktop
        black
        blender
        blesh
        bluetui
        boxes
        brightnessctl
        browser-sync
        btop
        bzip3
        cargo
        chromium
        cl
        (lib.hiPrio clang)
        clang-tools
        cmake
        copyq
        csharp-ls
        dbeaver-bin
        delve
        deno
        devenv
        distant
        docker-compose-language-service
        dotnetCorePackages.sdk_9_0-bin
        dpkg
        dua
        dust
        emmet-language-server
        emmet-ls
        entr
        eslint
        et
        eww
        eza
        fastfetch
        fd
        feishin
        ffmpeg
        file
        foliate
        freesmlauncher
        fuzzel
        fzf
        gcc
        gdu
        gh
        ghostty
        git-crypt
        gimp
        glab
        glow
        gnumake
        go
        gogcli
        goimports-reviser
        google-cloud-sdk
        gopls
        gosimports
        grim
        gst_all_1.gst-libav
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-ugly
        gst_all_1.gstreamer
        gtk4
        himalaya
        htmlhint
        htop
        hyprcursor
        hypridle
        hyprlang
        hyprls
        hyprpicker
        hyprpolkitagent
        hyprutils
        imagemagick
        imv
        inkscape-with-extensions
        isort
        jdk
        jq
        kdePackages.dolphin
        kdePackages.kdialog
        kdePackages.kio-admin
        kdePackages.kio-extras
        kdePackages.okular
        keepass
        khal
        kitty
        kooha
        (lib.hiPrio kubernetes)
        kdePackages.kwallet
        kdePackages.signon-kwallet-extension
        kdePackages.ksshaskpass
        kdePackages.kwalletmanager
        kdePackages.kwallet-pam
        lazydocker
        lazygit
        lf
        libnotify
        libreoffice
        libva-utils
        lsd
        lshw
        lua
        lua-language-server
        luajitPackages.tree-sitter-cli
        lynx
        mailspring
        manix
        mc
        mdcat
        minikube
        moreutils
        mpv
        mpvpaper
        neovide-nightly
        neovim-nightly
        networkmanagerapplet
        nix-bash-completions
        nix-diff
        nix-index
        nix-init
        nix-output-monitor
        nix-tree
        nixd
        nixdoc
        nnn
        noctalia-shell
        nodejs_latest
        nurl
        nushell
        nvd
        obs-cli
        obs-cmd
        obs-studio
        obsidian
        openclaw
        oxlint
        p7zip
        pamixer
        pandoc
        pass
        pavucontrol
        perl
        php
        playerctl
        powershell
        pre-commit
        prettier
        pv
        python13Env
        pywal
        qt5.qtgraphicaleffects
        qrencode
        (lib.hiPrio rar)
        ripdrag
        ripgrep
        rofi
        roslyn-ls
        ruff
        rust-analyzer
        sass
        sbc
        silver-searcher-ng
        sing-box
        sing-geoip
        sing-geosite
        slurp
        sops
        speedtest-cli
        spice-gtk
        sqlite
        sqlitebrowser
        sqls
        sshfs-fuse
        statix
        starship
        steam-run
        subversion
        superhtml
        tauon
        tea
        telegram-portal
        tesseract
        tg
        thunar
        tig
        tmux
        tor-browser
        tree
        ty
        typescript
        udiskie
        ueberzugpp
        unciv
        universal-ctags
        unrar
        unzip
        uutils-coreutils
        uutils-diffutils
        uutils-findutils
        uv
        v2rayn
        vdirsyncer
        video-downloader
        vim-language-server
        virt-viewer
        vlc
        vtracer
        w3m
        wev
        wget
        wifi-qr
        wl-clipboard
        wofi
        wtype
        xplr
        xray
        yaml-language-server
        yt-dlp
        ytdownloader
        zathura
        zbar
        zen
        zig
        zip
        zoxide
      ]
    );
  };
}

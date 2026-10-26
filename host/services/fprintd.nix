{
  pkgs,
  ...
}:

let
  # Открытый драйвер Goodix GF511 (USB 27c6:5110) — единственный рабочий
  # вариант для этого сенсора: апстрим его не поддерживает, TOD-драйвер
  # (libfprint-2-tod1-goodix) знает только семейство 53xc.
  # Форк buxel/libfprint, ветка goodixtls-upstream-mr (rev 8c36740).
  # Сборка по инструкции проекта: добавляется gnutls (TLS-PSK с сенсором).
  libfprint-goodixtls = pkgs.libfprint.overrideAttrs (prev: {
    pname = "libfprint-goodixtls";

    src = pkgs.fetchFromGitHub {
      owner = "buxel";
      repo = "libfprint";
      rev = "8c3674092ed29bfc6bf0fcf73b24fd821393508c";
      hash = "sha256-Rygz4tjdQnd0qhxm0NTiHip7gp5qPhFEPXN93oJY7kU=";
    };

    # Два патча из PR сообщества к форку:
    # 1) стоп бесконечного цикла чтения при потере USB-устройства
    #    (после сна драйвер раньше крутил 100% CPU и залипал);
    # 2) корректная отмена команды и вызов callback при ошибке
    #    TLS-рукопожатия (иначе verify навсегда остаётся «в процессе»).
    # Плюс локальное понижение порога ключевых точек 25→20: на этом сенсоре
    # сканы часто дают 20–24 точки и раньше отбраковывались до сравнения.
    patches = (prev.patches or [ ]) ++ [
      ./libfprint-goodixtls-patches/pr1-adapted.diff
      ./libfprint-goodixtls-patches/pr3.diff
      ./libfprint-goodixtls-patches/keypoints-20.diff
    ];

    postPatch = ''
      for f in \
        tests/unittest_inspector.py \
        tests/virtual-image.py \
        tests/umockdev-test.py \
        tests/test-generated-hwdb.sh; do
        [ -e "$f" ] || continue
        patchShebangs "$f"
      done
    '';

    buildInputs = prev.buildInputs ++ [ pkgs.gnutls ];

    mesonFlags = prev.mesonFlags ++ [
      "-Dc_args=-Wno-error=incompatible-pointer-types"
      # Introspection не нужен (fprintd — C-приложение), а его тестовые
      # скрипты падают на конфигурации meson в песочнице
      "-Dintrospection=false"
    ];

    doInstallCheck = false;
  });

  fprintd-goodixtls = pkgs.fprintd.override { libfprint = libfprint-goodixtls; };
in
{
  services = {
    fprintd = {
      enable = true;
      package = fprintd-goodixtls;
    };
  };

  # Диагностика: fp_dbg/fp_info в libfprint — это g_debug. Без G_MESSAGES_DEBUG
  # в журнал не попадают ни причина отказа, ни счёт матчера (sigfm score N/7).
  # Временно, для настройки точности; потом можно убрать.
  systemd.services.fprintd.environment = {
    G_MESSAGES_DEBUG = "all";
  };

  # Сенсор после resume перечисляется заново (USB 27c6:5110), а fprintd
  # остаётся с битым хэндлом и «busy». По udev-add перезапускаем его сразу
  # (SIGKILL + start), не дожидаясь 90-секундного stop-sigterm.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="5110", TAG+="systemd", ENV{SYSTEMD_WANTS}+="fprintd-usb-reset.service"
  '';

  systemd.services.fprintd-usb-reset = {
    description = "Reset fprintd after fingerprint sensor re-enumeration";
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.systemd}/bin/systemctl kill -s SIGKILL fprintd.service || true
      ${pkgs.systemd}/bin/systemctl reset-failed fprintd.service || true
      ${pkgs.systemd}/bin/systemctl start fprintd.service || true
    '';
  };

  # --- PAM: палец и пароль ---
  # Локскрин Noctalia общается с сенсором сам, по D-Bus через fprintd, а пароль
  # проверяет через PAM-сервис "login". Если оставить fprintd и в этой цепочке,
  # после ввода пароля модуль сначала до 30 секунд ждёт палец и только потом
  # проверяет пароль — со стороны выглядит, будто пароль не работает.
  # Убираем pam_fprintd из login: палец на локскрине по-прежнему разблокирует
  # (этим занимается сама Noctalia), а пароль проверяется сразу.
  security.pam.services.login.fprintAuth = false;

  # В остальных интерактивных сервисах палец остаётся, но с коротким ожиданием:
  # нет пальца 8 секунд — сразу появляется приглашение ввести пароль
  # (по умолчанию это 30 секунд, и ввод пароля «висел»).
  security.pam.services = {
    sudo.rules.auth.fprintd.args = [ "timeout=8" ];
    "polkit-1".rules.auth.fprintd.args = [ "timeout=8" ];
    su.rules.auth.fprintd.args = [ "timeout=8" ];
    "su-l".rules.auth.fprintd.args = [ "timeout=8" ];
    passwd.rules.auth.fprintd.args = [ "timeout=8" ];
    chsh.rules.auth.fprintd.args = [ "timeout=8" ];
    chfn.rules.auth.fprintd.args = [ "timeout=8" ];
  };
}

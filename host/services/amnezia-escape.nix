{
  pkgs,
  ...
}:
{
  # Таблица маршрутов, которую ждёт AmneziaVPN (amnvpnrt) и qbt (qbt).
  environment.etc."iproute2/rt_tables".text = ''
    255 local
    254 main
    253 default
    0 unspec
    10011 qbt
    10012 amnvpnrt
  '';

  # Escape AmneziaVPN, v4 (loop-сервис).
  # Проблема: демон не может вывести пакеты к серверу в обход туннеля
  # (cgroup net_cls нет -> его MARK-правило мертво; stale-кэш gateway ->
  # exclusion-маршруты пропускаются). Пакеты к 185.103.103.40 идут в
  # 0.0.0.0/1 туннеля и зацикливаются.
  #
  # v2 (только /32 в main) и v3 (таймер OnUnitActiveSec/OnCalendar) НЕ
  # сработали: таймеры systemd 261 после первого запуска не перепланируются
  # (NextElapseUSecMonotonic=infinity, Trigger: n/a) — сервис выполнялся
  # один раз и больше никогда. Плюс приложение ставит `from all lookup
  # <своя_таблица>` с приоритетом 1, перекрывающую main.
  #
  # v4: вечный цикл каждые 5с (Type=simple, Restart=always):
  #  - для каждого escape-IP: /32 в main + правило `to <IP>/32 lookup main
  #    pref 0` (приоритет 0 выше приложенькиного pref 1 — работает при
  #    ЛЮБОМ поведении приложения);
  #  - при исчезновении amn0 всё снимается;
  #  - в журнал пишется одна строка на смену состояния.
  systemd.services.amn-escape = {
    description = "AmneziaVPN escape watcher (loop, every 5s)";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5";
      ExecStart = "${pkgs.writeShellScript "amn-escape-loop" ''
        set -u
        IP=${pkgs.iproute2}/bin/ip
        AWK=${pkgs.gawk}/bin/awk
        GREP=${pkgs.gnugrep}/bin/grep
        SLEEP=${pkgs.coreutils}/bin/sleep
        # IP для обхода туннеля: сервер VPN + exclusion-список приложения (рос. сервисы)
        ESCAPE_IPS="185.103.103.40 94.100.180.215 109.207.1.98 82.202.189.136 109.207.2.205 109.207.8.163 178.248.237.106 109.207.9.147 90.156.232.4 109.207.1.118 155.212.204.74 217.107.111.67 213.59.254.47 109.207.9.154 109.207.8.126 155.212.204.78 109.207.2.53"
        state=""
        while true; do
          if $IP link show amn0 >/dev/null 2>&1; then
            # Дёшево: escape уже стоит? (1-2 grep'а вместо 68 ip-вызовов каждый тик)
            if ! $IP rule show | $GREP -q "to 185.103.103.40" || ! $IP route show | $GREP -q "^185.103.103.40 "; then
              GW=$($IP route show default | $AWK '/^default/ {print $3; exit}')
              DEV=$($IP route show default | $AWK '/^default/ {print $5; exit}')
              if [ -n "$GW" ]; then
                for i in $ESCAPE_IPS; do
                  $IP route replace "$i/32" via "$GW" dev "$DEV" 2>/dev/null || true
                  $IP rule add to "$i/32" lookup main pref 0 2>/dev/null || true
                done
                if [ "$state" != "applied" ]; then
                  echo "escape applied: gw=$GW dev=$DEV"
                  state="applied"
                fi
              fi
            fi
          else
            if [ "$state" != "removed" ]; then
              for i in $ESCAPE_IPS; do
                $IP route del "$i/32" 2>/dev/null || true
                $IP rule del to "$i/32" lookup main pref 0 2>/dev/null || true
              done
              echo "escape removed (no amn0)"
              state="removed"
            fi
          fi
          $SLEEP 5
        done
      ''}";
    };
  };
}

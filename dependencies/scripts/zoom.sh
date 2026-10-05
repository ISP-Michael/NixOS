#!/usr/bin/env sh
# zoom.sh up | down | reset — масштаб курсора в Hyprland.
#
# Две находки, из-за которых бинды SUPER + equal / SUPER + minus не работали:
#   1) `hyprctl keyword <опция> <значение>` в этой сборке Hyprland 0.56
#      отвечает "unknown request" на ЛЮБУЮ опцию. Менять опции через keyword
#      нельзя вообще. Рабочий путь — `hyprctl eval 'hl.config({...})'`.
#   2) repeating = true на бинде означал 4 процесса на КАЖДЫЙ автоповтор.
#      Теперь нажатие = 2 процесса, без jq.
set -eu

STEP=0.5
MIN=1.0
MAX=4.0

case "${1:-}" in
    up|plus|+)    op=up   ;;
    down|minus|-) op=down ;;
    reset)        op=rst  ;;
    *)            echo "usage: zoom.sh up|down|reset" >&2; exit 2 ;;
esac

cur=$(hyprctl getoption cursor:zoom_factor | awk '/^float:/ { print $2 }')
[ -n "${cur:-}" ] || cur=1.0

next=$(awk -v v="$cur" -v op="$op" -v s="$STEP" -v lo="$MIN" -v hi="$MAX" '
    BEGIN {
        if      (op == "up")   v += s
        else if (op == "down") v -= s
        else                  v  = 1.0
        if (v < lo) v = lo
        if (v > hi) v = hi
        printf "%.2f", v
    }
')

hyprctl eval "hl.config({ cursor = { zoom_factor = $next } })" >/dev/null
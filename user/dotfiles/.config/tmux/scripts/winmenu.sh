#!/usr/bin/env bash
# winmenu.sh — переключатель окон tmux: окошко на весь экран, кроме строки статуса.
# Запускается из tmux.conf через run-shell: сам считает размер и открывает себя в display-popup.
# Список плоский, снизу вверх. Цифры 1-9,0 — прыжок, / — фильтр, Enter — выбрать.
# x — убить окно, X — убить сессию, r/R — переименовать окно/сессию, Esc/q — выход.

set -uo pipefail

# ---------- локаль ----------
# окружение tmux-сервера может не иметь UTF-8 — тогда кириллица не читается
case ${LC_ALL:-${LC_CTYPE:-${LANG:-}}} in
    *UTF-8*|*UTF8*|*utf8*|*utf-8*) ;;
    *) export LC_ALL=C.UTF-8 ;;
esac

# ---------- режим запуска: посчитать размер окошка и открыть себя в popup ----------
# Из tmux.conf приходят: сокет, имя клиента, ширина и высота клиента.
if [[ ${WINMENU_INNER:-} != 1 ]]; then
    sock=${1:-} client=${2:-} cw=${3:-} ch=${4:-}
    self=$(realpath "${BASH_SOURCE[0]}")
    T=(); [[ -n $sock ]] && T=(-S "$sock")
    if [[ -z $client || ! $cw =~ ^[0-9]+$ || ! $ch =~ ^[0-9]+$ ]]; then
        read -r _cl _cw _ch < <(tmux "${T[@]}" list-clients -F '#{client_name} #{client_width} #{client_height}' 2>/dev/null | head -1)
        [[ -z $client ]] && client=${_cl:-}
        [[ ! $cw =~ ^[0-9]+$ ]] && cw=${_cw:-160}
        [[ ! $ch =~ ^[0-9]+$ ]] && ch=${_ch:-40}
    fi
    # окошко на весь экран, кроме строки статуса — как нативный fzf
    st="" pos=""
    { read -r st; read -r pos; } < <(tmux "${T[@]}" show -g status \; show -g status-position 2>/dev/null)
    case ${st##* } in
        off) srows=0 ;;
        *[!0-9]*) srows=1 ;;
        *) srows=${st##* } ;;
    esac
    [[ ${pos##* } == top ]] && srows=0
    H=$(( ch - srows ))
    (( H < 3 )) && H=3
    (( H > ch )) && H=$ch
    W=$cw
    # -y у display-popup — это нижняя кромка окошка: ставим её на строку над статусбаром
    y=$(( ch - srows ))
    (( y < 1 )) && y=1
    (( y > ch )) && y=$ch
    C=(); [[ -n $client ]] && C=(-c "$client")
    exec tmux "${T[@]}" display-popup -E -B "${C[@]}" -w "$W" -h "$H" -x 0 -y "$y" \
        "WINMENU_INNER=1 exec '$self' '$sock' '$client' '$cw' '$ch'"
fi

cleanup() { printf '\e[0m\e[?25h' 2>/dev/null || true; }
trap cleanup EXIT

# ---------- цвета (catppuccin mocha) ----------
esc=$'\e'
c_reset=$'\e[0m'
c_text=$'\e[38;2;205;214;244m'
c_dim=$'\e[38;2;108;112;134m'
c_sess=$'\e[38;2;147;153;178m'
c_acc=$'\e[38;2;203;166;247m'
c_warn=$'\e[38;2;249;226;175m'
c_sel=$'\e[48;2;49;50;68m'

# ---------- список окон ----------
# внутри popup первый аргумент — тот же сокет, что передал запускатель
T=()
[[ -n ${1:-} ]] && T=(-S "$1")
client=${2:-}
S=(); I=(); W=(); n=0; cur_pos=0; cur=""

load_windows() {
    S=(); I=(); W=(); n=0; cur_pos=0; cur=""
    # текущее окно спрашиваем явно у клиента: его сессия + активное окно этой сессии.
    # (display-message «от себя» внутри popup возвращает текущее окно не той сессии)
    if [[ -n $client ]]; then
        cur=$(tmux "${T[@]}" display-message -p -c "$client" '#{session_name}:#{window_index}' 2>/dev/null || true)
    fi
    [[ -z $cur ]] && cur=$(tmux "${T[@]}" display-message -p '#{session_name}:#{window_index}' 2>/dev/null || true)
    while IFS=$'\t' read -r sess widx wname; do
        n=$((n + 1))
        S+=("$sess"); I+=("$widx"); W+=("$wname")
        [[ "$sess:$widx" == "$cur" ]] && cur_pos=$n
    done < <(tmux "${T[@]}" list-windows -a -F $'#{session_name}\t#{window_index}\t#{window_name}' 2>/dev/null)
}

load_windows

# ---------- размеры и ширины столбцов ----------
sz=$(stty size 2>/dev/null || true)
L=${sz%% *}; C=${sz##* }
[[ $L =~ ^[0-9]+$ ]] || L=24
[[ $C =~ ^[0-9]+$ ]] || C=80
(( L < 2 )) && L=24
# порог ниже минимальной ширины окошка (wN + wS + 4 + 8 = 14), иначе узкие popup раздувались до 80
(( C < 12 )) && C=80

wN=${#n}
wS=0
for s in "${S[@]}"; do
    (( ${#s} > wS )) && wS=${#s}
done
(( wS > 24 )) && wS=24
wW=0
for s in "${W[@]}"; do
    (( ${#s} > wW )) && wW=${#s}
done
cap=$(( C - 2 - wN - 3 - wS - 3 ))
# сначала минимум, потом обрезка: иначе минимум перебьёт cap и строка вылезет за ширину
(( cap < 1 )) && cap=1
(( wW < 4 )) && wW=4
(( wW > cap )) && wW=$cap

# ---------- состояние ----------
mode=normal
query=""
sel=$(( cur_pos > 0 ? cur_pos - 1 : 0 ))
vis=()
confirm_action=""
confirm_idx=0
confirm_count=0
edit_ctx=""
edit_idx=0
edit_buf=""

build_vis() {
    vis=()
    local -a words=()
    local i w ok hay
    if [[ -n $query ]]; then
        read -ra words <<< "${query,,}"
    fi
    for (( i = 0; i < n; i++ )); do
        if (( ${#words[@]} )); then
            hay="${S[i],,} ${W[i],,}"
            ok=1
            for w in "${words[@]}"; do
                [[ $hay == *"$w"* ]] || { ok=0; break; }
            done
            (( ok )) || continue
        fi
        vis+=("$i")
    done
    if (( ${#vis[@]} == 0 )); then
        sel=0
    elif (( sel >= ${#vis[@]} )); then
        sel=$(( ${#vis[@]} - 1 ))
    elif (( sel < 0 )); then
        sel=0
    fi
}

session_window_count() {
    local sess=$1 i count=0
    for (( i = 0; i < n; i++ )); do
        [[ ${S[i]} == "$sess" ]] && count=$((count + 1))
    done
    printf '%s' "$count"
}

row() {
    local i=$1 s=$2 num sess name out="" p1 p2
    printf -v num '%-*d' "$wN" "$(( i + 1 ))"
    sess=${S[i]}
    (( ${#sess} > wS )) && sess="${sess:0:wS - 1}…"
    p1=""
    while (( ${#sess} + ${#p1} < wS )); do
        p1+=" "
    done
    name=${W[i]}
    (( ${#name} > wW )) && name="${name:0:wW - 1}…"
    p2=""
    while (( ${#name} + ${#p2} < wW )); do
        p2+=" "
    done
    if (( s )); then out+="$c_acc> "; else out+="  "; fi
    out+="$c_acc$num$c_dim │ "
    # выделение — фоном только по словам (сессия, окно), без добивки до ширины столбца
    if (( s )); then
        out+="$c_sel$c_sess$sess$c_reset$p1$c_dim │ $c_sel$c_text$name$c_reset$p2"
    else
        out+="$c_sess$sess$p1$c_dim │ $c_text$name$p2"
    fi
    printf '%s' "$out"
}

truncate_line() {
    local text=$1
    if (( ${#text} > C - 1 )); then
        text="${text:0:C - 2}…"
    fi
    printf '%s' "$text"
}

render() {
    local out k r s idx start rows d fill box hint msg disp cut
    out="$esc[0m$esc[?25l$esc[H$esc[J"
    rows=$(( L - 2 ))
    d=${#vis[@]}
    (( d > rows )) && d=$rows
    start=0
    (( sel >= rows )) && start=$(( sel - rows + 1 ))
    # нумерация снизу вверх: пункт 1 — в нижней строке списка, выше — второй и т.д.
    for (( k = start; k < start + d; k++ )); do
        r=$(( L - 2 - (k - start) ))
        if (( k == sel )); then s=1; else s=0; fi
        idx=${vis[k]}
        out+="$esc[$r;1H"
        out+="$(row "$idx" "$s")"
        out+="$esc[K"
    done
    # строка-разделитель: сплошная линия во всю ширину, как в fzf
    box=$'\u2500'
    printf -v fill '%*s' "$C" ''
    fill=${fill// /$box}
    out+="$esc[$(( L - 1 ));1H$c_dim$fill$c_reset$esc[K"
    case $mode in
        confirm)
            if [[ $confirm_action == session ]]; then
                msg="kill session ${S[confirm_idx]} ($confirm_count windows)? [y/N]"
            else
                msg="kill window ${S[confirm_idx]}:${I[confirm_idx]} (${W[confirm_idx]})? [y/N]"
            fi
            msg=$(truncate_line "$msg")
            out+="$esc[$L;1H${c_warn}${msg}${c_reset}$esc[K"
            ;;
        rename)
            msg="rename ${edit_ctx}: ${edit_buf}"
            disp=$(truncate_line "$msg")
            out+="$esc[$L;1H${c_acc}${disp}${c_reset}$esc[K$esc[?25h"
            out+="$esc[$L;$(( 1 + ${#disp} ))H"
            ;;
        search)
            disp=$query
            # длинный запрос не должен переноситься: показываем хвост
            if (( ${#disp} > C - 3 )); then
                cut=$(( ${#disp} - C + 3 ))
                disp=${disp:cut}
            fi
            out+="$esc[$L;1H"
            out+="${c_acc}/${c_reset}${c_text}${disp}${c_reset}"
            out+="$esc[K$esc[?25h"
            out+="$esc[$L;$(( 2 + ${#disp} ))H"
            ;;
        *)
            hint=$(truncate_line "x kill win · X kill sess · r/R rename · / filter · esc exit")
            out+="$esc[$L;1H${c_dim}${hint}${c_reset}$esc[K"
            ;;
    esac
    printf '%s' "$out"
}

# список пронумерован снизу вверх, поэтому «вверх» — к бо́льшим номерам
move_up()   { (( sel < ${#vis[@]} - 1 )) && sel=$(( sel + 1 )); return 0; }
move_down() { (( sel > 0 )) && sel=$(( sel - 1 )); return 0; }

go() { local -a A=(); [[ -n ${client:-} ]] && A=(-c "$client"); tmux "${T[@]}" switch-client "${A[@]}" -t "${S[$1]}:${I[$1]}"; exit 0; }

jump() {
    local p=$1
    (( p >= 1 && p <= ${#vis[@]} )) || return 0
    go "${vis[p - 1]}"
}

accept() {
    (( ${#vis[@]} )) || return 0
    go "${vis[sel]}"
}

start_confirm() {
    (( ${#vis[@]} )) || return 0
    confirm_action=$1
    confirm_idx=${vis[sel]}
    confirm_count=$(session_window_count "${S[confirm_idx]}")
    mode=confirm
}

kill_selected() {
    local idx=$confirm_idx sess widx count is_cur=0 last_window=0
    (( idx >= 0 && idx < n )) || { mode=normal; return 0; }
    sess=${S[idx]}
    widx=${I[idx]}
    count=$confirm_count
    [[ $sess == "${cur%%:*}" ]] && is_cur=1
    if [[ $confirm_action == session ]]; then
        tmux "${T[@]}" kill-session -t "$sess" 2>/dev/null || true
    else
        tmux "${T[@]}" kill-window -t "$sess:$widx" 2>/dev/null || true
        (( count == 1 )) && last_window=1
    fi
    if (( is_cur )); then
        if [[ $confirm_action == session ]] || (( last_window )); then
            exit 0
        fi
    fi
    load_windows
    mode=normal
    build_vis
}

start_rename() {
    (( ${#vis[@]} )) || return 0
    edit_ctx=$1
    edit_idx=${vis[sel]}
    if [[ $edit_ctx == window ]]; then
        edit_buf=${W[edit_idx]}
    else
        edit_buf=${S[edit_idx]}
    fi
    mode=rename
}

apply_rename() {
    local idx=$edit_idx name=$edit_buf
    if [[ -z $name ]]; then
        mode=normal
        return 0
    fi
    if [[ $edit_ctx == window ]]; then
        tmux "${T[@]}" rename-window -t "${S[idx]}:${I[idx]}" "$name" 2>/dev/null || true
    else
        tmux "${T[@]}" rename-session -t "${S[idx]}" "$name" 2>/dev/null || true
    fi
    load_windows
    mode=normal
    build_vis
}

# ---------- основной цикл ----------
while :; do
    build_vis
    render
    IFS= read -rsn1 -d '' key || exit 0
    case $mode in
        confirm)
            case $key in
                y|Y) kill_selected ;;
                n|N|$'\e'|$'\r'|$'\n') mode=normal ;;
            esac
            continue
            ;;
        rename)
            case $key in
                $'\r'|$'\n') apply_rename ;;
                $'\e') mode=normal ;;
                $'\x7f'|$'\x08') [[ -n $edit_buf ]] && edit_buf=${edit_buf%?} ;;
                $'\x15') edit_buf="" ;;
                *) [[ $key =~ [[:print:]] ]] && edit_buf+=$key ;;
            esac
            continue
            ;;
    esac
    case $key in
        $'\e')
            if IFS= read -rsn1 -d '' -t 0.1 k2 && { [[ $k2 == '[' ]] || [[ $k2 == 'O' ]]; } && IFS= read -rsn1 -d '' -t 0.1 k3; then
                case $k3 in
                    A) move_up ;;
                    B) move_down ;;
                esac
            else
                if [[ $mode == search ]]; then
                    mode=normal
                    query=""
                    sel=$(( cur_pos > 0 ? cur_pos - 1 : 0 ))
                else
                    exit 0
                fi
            fi
            ;;
        $'\r'|$'\n')
            accept
            ;;
        $'\x03')
            exit 0
            ;;
        $'\x7f'|$'\x08')
            if [[ $mode == search && -n $query ]]; then
                query=${query%?}
                sel=0
            fi
            ;;
        *)
            if [[ $mode == search ]]; then
                if [[ $key =~ [[:print:]] ]]; then
                    query+=$key
                    sel=0
                fi
            else
                case $key in
                    [1-9]) jump "$key" ;;
                    0)     jump 10 ;;
                    /)     mode=search; query="" ;;
                    x)     start_confirm window ;;
                    X)     start_confirm session ;;
                    r)     start_rename window ;;
                    R)     start_rename session ;;
                    j)     move_down ;;
                    k)     move_up ;;
                    q)     exit 0 ;;
                esac
            fi
            ;;
    esac
done

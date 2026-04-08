NOW=$(date +"%Y-%m-%d_%H:%M:%S")
PASS="97I66bYCJvIXfwdD"
WS="obsws://localhost:4455/$PASS"
DIR="$HOME/Images/screenshots"
NAME="obs_$NOW.png"
FILE="$DIR/$NAME"

if obs-cmd -w "$WS" save-screenshot "Scene" "png" "$FILE"; then
    wl-copy < "$FILE"
    notify-send "OBS Screenshot" "Сохранено: $NAME\nСкопировано в буфер" -i camera-photo -t 2000
else
    notify-send "OBS Error" "Ошибка при создании скриншота" -u critical
fi



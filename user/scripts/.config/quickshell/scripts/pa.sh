text=$(pamixer --get-volume-human)
if [[ "$text" == "muted" ]]; then
    echo 
else
    echo ${text%?}
fi

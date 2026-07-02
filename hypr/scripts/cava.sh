#!/usr/bin/env bash
set -u

SHM_FILE="/dev/shm/hyprlock_cava_live"
PID_FILE="/dev/shm/hyprlock_cava.pid"
BARS_COUNT=16

if [ ! -f "$PID_FILE" ] || ! kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    CONFIG_FILE="/tmp/hyprlock_cava_config"
    
    cat > "$CONFIG_FILE" <<EOF
[general]
bars = ${BARS_COUNT}
framerate = 90
autosens = 1

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 10
EOF
    (
        bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
        silent_line=""
        for ((i=0; i<BARS_COUNT; i++)); do silent_line+="${bars[0]}"; done
        echo "$silent_line" > "$SHM_FILE"
        cava -p "$CONFIG_FILE" | while read -r line; do
            if ! pidof hyprlock >/dev/null; then
                rm -f "$PID_FILE" "$SHM_FILE"
                exit 0
            fi
            if [[ "$line" =~ [0-7] ]]; then
                IFS=';' read -ra nums <<< "$line"
                out=""
                is_silent=true
                
                for n in "${nums[@]}"; do
                    if (( n < 0 || n > 7 )); then n=0; fi
                    if (( n > 0 )); then is_silent=false; fi
                    out+="${bars[n]}"
                done
                if [ "$is_silent" = true ]; then
                    echo "$silent_line" > "$SHM_FILE"
                else
                    echo "$out" > "$SHM_FILE"
                fi
            else
                echo "$silent_line" > "$SHM_FILE"
            fi
        done
    ) &
    echo $! > "$PID_FILE"
    sleep 0.01
fi
cat "$SHM_FILE" 2>/dev/null || echo ""

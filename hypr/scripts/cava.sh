#!/usr/bin/env bash
set -u
SHM_FILE="/dev/shm/hyprlock_cava_live"
PID_FILE="/dev/shm/hyprlock_cava.pid"
if [ ! -f "$PID_FILE" ] || ! kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    CONFIG_FILE="/tmp/hyprlock_cava_config"
    
    cat > "$CONFIG_FILE" <<EOF
[general]
bars = 16
framerate = 60
autosens = 1

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF
    (
        bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
        cava -p "$CONFIG_FILE" | while read -r line; do
            if ! pidof hyprlock >/dev/null; then
                rm -f "$PID_FILE" "$SHM_FILE"
                exit 0
            fi
            
            if [[ "$line" =~ [1-7] ]]; then
                IFS=';' read -ra nums <<< "$line"
                out=""
                for n in "${nums[@]}"; do
                    if (( n < 0 || n > 7 )); then n=0; fi
                    out+="${bars[n]}"
                done
                echo "$out" > "$SHM_FILE"
            else
                echo "" > "$SHM_FILE"
            fi
        done
    ) &
    echo $! > "$PID_FILE"
    sleep 0.02
fi
cat "$SHM_FILE" 2>/dev/null || echo ""

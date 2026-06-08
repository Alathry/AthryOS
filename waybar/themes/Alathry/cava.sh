#!/usr/bin/env bash
set -u

config_file="/tmp/waybar_cava_config"
cat > "$config_file" <<EOF
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
trap 'pkill -P $$ 2>/dev/null || true' EXIT
bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
empty_bar="▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁"

convert_to_bars() {
    local line="$1"
    local IFS=';'
    local -a nums
    read -ra nums <<< "$line"
    local out=""
    for n in "${nums[@]}"; do
        if (( n < 0 || n > 7 )); then n=0; fi
        out+="${bars[n]}"
    done
    printf '%s\n' "$out"
}
cava -p "$config_file" | while :; do
    if read -t 0.3 -r line; then
        convert_to_bars "$line"
    else
        exit_status=$?
        if (( exit_status > 128 )); then
            printf '%s\n' "$empty_bar"
        else
            break
        fi
    fi
done

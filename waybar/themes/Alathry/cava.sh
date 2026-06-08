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

# قتل Cava بأمان عند إغلاق Waybar
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

# قراءة المخرجات مع مؤقت زمني (0.3 ثانية)
cava -p "$config_file" | while :; do
    if read -t 0.3 -r line; then
        # هناك صوت وcava يرسل بيانات
        convert_to_bars "$line"
    else
        exit_status=$?
        if (( exit_status > 128 )); then
            # انتهت المهلة (Timeout) بسبب سكون كرت الصوت، اطبع الشريط الثابت فوراً
            printf '%s\n' "$empty_bar"
        else
            # Cava توقف عن العمل بالكامل
            break
        fi
    fi
done

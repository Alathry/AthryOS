#!/usr/bin/env bash

WAYBAR_DIR="$HOME/.config/waybar"
THEMES_DIR="$WAYBAR_DIR/themes"
if [[ ! -d "$THEMES_DIR" ]]; then
    echo "خطأ: مجلد الثيمات غير موجود!"
    exit 1
fi
THEMES=$(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n")
ROFI_THEME="$HOME/.config/rofi/type-2/style-15.rasi"
CHOICE=$(echo "$THEMES" | rofi -dmenu -p "Select Theme:" -theme "$ROFI_THEME")
if [[ -z "$CHOICE" ]]; then
    exit 0
fi
TARGET_DIR="$THEMES_DIR/$CHOICE"
ln -sf "$TARGET_DIR/config.jsonc" "$WAYBAR_DIR/config.jsonc"
ln -sf "$TARGET_DIR/style.css" "$WAYBAR_DIR/style.css"
for script in "$TARGET_DIR"/*.sh; do
    if [[ -f "$script" ]]; then
        chmod +x "$script"
        bash "$script" &
    fi
done
if pgrep -x waybar > /dev/null; then
    killall -SIGUSR2 waybar
else
    waybar &
fi

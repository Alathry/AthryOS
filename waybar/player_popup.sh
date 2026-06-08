#!/bin/bash

# 1. التحقق من وجود مشغل نشط
if ! playerctl status > /dev/null 2>&1; then
    exit 0
fi

# 2. جلب غلاف الألبوم والبيانات
album_art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)
cover_path="/tmp/waybar_cover.png"

if [[ "$album_art_url" == file://* ]]; then
    cp "${album_art_url#file://}" "$cover_path"
elif [[ "$album_art_url" == http* ]]; then
    curl -s "$album_art_url" --output "$cover_path"
else
    cover_path="/usr/share/icons/hicolor/scalable/apps/multimedia-audio-player.svg"
fi

title=$(playerctl metadata title 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null)

# 3. إطلاق نافذة Yad عادية متوافقة مع Wayland باسم مخصص (title) لكي يلتقطها Hyprland
yad --title="WaybarMusicPopup" \
    --form --image="$cover_path" --image-on-top \
    --text="<b>${title:-Unknown Title}</b>\n<i>${artist:-Unknown Artist}</i>" --align=center \
    --field="     ⏪ 5s     ":fbtn "playerctl position 5-" \
    --field="     ⏸️ / ▶️     ":fbtn "playerctl play-pause" \
    --field="     5s ⏩     ":fbtn "playerctl position 5+" \
    --no-buttons --close-on-unfocus \
    --width=300 --height=250 \
    --fontname="JetBrainsMono Nerd Font Bold 10"

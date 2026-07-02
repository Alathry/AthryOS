#!/bin/bash
dir="$HOME/.config/rofi/"
theme='config.rasi'
options="󰤆 Poweroff\n󰜉 Reboot\n󰌾 Lock\n󰤄 Suspend\n󰑐 Reload Config\n󰗽 Logout"
chosen=$(echo -e "$options" | rofi -dmenu -i -p "System" \
    -theme ${dir}/${theme})
case "$chosen" in
    *Poweroff) 
        systemctl poweroff ;;
    *Reboot) 
        systemctl reboot ;;
    *Lock) 
        hyprlock ;;
    *Suspend) 
        hyprlock & 
        sleep 0.5 
        systemctl suspend ;;
    *Reload*)
        hyprctl reload
        killall waybar swaync awww-daemon
        waybar &
        swaync &
	awww-daemon
        notify-send "AthryOS" "Reload Completed..." ;;
    *Logout)
        hyprctl dispatch exit ;;
    *) 
        exit 1 ;;
esac

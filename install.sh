#!/bin/bash

touch Install.log

echo "Are you using NetworkManager or IWD? (Type NM or IWD):"
read -r NET_CHOICE

PACKAGES="bluetuith matugen cava waybar hypridle hyprland xorg-xwayland swaync swayosd nodejs wget pyright gopls curl gnome-polkit rofi wofi cmatrix gtk3 gtk4 starship adw-gtk-theme nano fonts-jetbrains-mono ttf-jetbrains-mono fonts-noto-color-emoji ttf-nerd-fonts-symbols neovim nvim lua go rust git wiremix awww uwsm fish kitty polkit-gnome brightnessctl"

if [ "$NET_CHOICE" = "IWD" ] || [ "$NET_CHOICE" = "iwd" ]; then
    PACKAGES="$PACKAGES impala"
fi

if grep -q "Arch" /etc/os-release; then
    sudo pacman -Sy
    PM="sudo pacman -S --noconfirm"
elif grep -q -E "Debian|Ubuntu" /etc/os-release; then
    sudo apt-get update
    PM="sudo apt-get install -y"
else
    echo "Unsupported OS"
    exit 1
fi

for pkg in $PACKAGES; do
    if ! $PM "$pkg" 2>/dev/null; then
        echo "You'r Distro Doesn't Support This Package Out-Of-Box :" | tee -a Install.log
        echo "- * $pkg" | tee -a Install.log
    else
        echo "Successfully installed: $pkg" | tee -a Install.log
    fi
done

mkdir -p "$HOME/.config"

for item in *; do
    if [ -d "$item" ]; then
        if [ "$item" = "Pictures" ] || [ "$item" = "Downloads" ] || [ "$item" = "Documents" ]; then
            continue
        fi
        
        if [ -d "$HOME/.config/$item" ]; then
            echo -e "\n======================================================="
            echo -e "|                                                     |"
            echo -e "| This Config It's already here , take Backup ? (y/n) |"
            echo -e "|                                                     |"
            echo -e "=======================================================\n"
            read -r BACKUP_CHOICE
            
            if [ "$BACKUP_CHOICE" = "y" ] || [ "$BACKUP_CHOICE" = "Y" ]; then
                mv "$HOME/.config/$item" "$HOME/.config/${item}.bak"
            fi
        fi
        cp -r "$item" "$HOME/.config/"
    fi
done

mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Pictures/Wallpapers"

sudo systemctl enable --now swayosd-libinput-backend.service
ln -sf ~/.cache/colors/cava.ini ~/.config/cava/config

echo ""
echo "Made By Alathry - Vist Now !! :"
echo "https://youtube.com/@Ala7thr"
echo "https://x.com/Ala7thry"
echo "https://github.com/Alathry"
echo "https://www.reddit.com/user/Ala7thry/"

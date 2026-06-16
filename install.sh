#!/bin/bash

if ! command -v dialog &>/dev/null; then
    sudo pacman -S --noconfirm dialog
fi

touch Install.log
exec 3>&1

NET_CHOICE=$(dialog --clear --title " Network Configuration " \
    --menu "Choose your Network Manager:" 10 40 2 \
    "NM" "NetworkManager" \
    "IWD" "iwd (Wireless Daemon)" \
    2>&1 1>&3)

PACKAGES="bluetuith matugen cava waybar hypridle hyprland xorg-xwayland swaync swayosd nodejs wget  ethtool wireless_tools speedtest-cli lshw  pyright gopls curl gnome-polkit rofi wofi cmatrix gtk3 gtk4 starship adw-gtk-theme nano fonts-jetbrains-mono ttf-jetbrains-mono fonts-noto-color-emoji ttf-nerd-fonts-symbols neovim nvim lua go rust git wiremix awww uwsm fish kitty polkit-gnome brightnessctl"

if [ "$NET_CHOICE" = "IWD" ]; then
    PACKAGES="$PACKAGES impala"
fi

if grep -q "Arch" /etc/os-release; then
    sudo pacman -S
    PM="sudo pacman -S --noconfirm"
    IS_ARCH=true
elif grep -q -E "Debian|Ubuntu" /etc/os-release; then
    sudo apt-get update
    PM="sudo apt-get install -y"
    IS_ARCH=false
else
    dialog --title " Error " --msgbox "Unsupported OS" 6 30
    exit 1
fi

COUNT=$(echo $PACKAGES | wc -w)
CURRENT=0
(
for pkg in $PACKAGES; do
    CURRENT=$((CURRENT + 1))
    PCT=$((CURRENT * 100 / COUNT))
    echo "XXX"
    echo "$PCT"
    echo "Installing package: $pkg"
    echo "XXX"
    if ! $PM "$pkg" 2>/dev/null; then
        echo "You'r Distro Doesn't Support This Package Out-Of-Box : - * $pkg" >> Install.log
    else
        echo "Successfully installed: $pkg" >> Install.log
    fi
done
) | dialog --title " Package Installation " --gauge "Starting installation..." 10 50 0

mkdir -p "$HOME/.config"

for item in *; do
    if [ -d "$item" ]; then
        if [ "$item" = "Pictures" ] || [ "$item" = "Downloads" ] || [ "$item" = "Documents" ]; then
            continue
        fi
        
        if [ -d "$HOME/.config/$item" ]; then
            dialog --title " Backup Configuration " \
                --yesno "The config for '$item' already exists. Do you want to take a backup?" 7 50
            if [ $? -eq 0 ]; then
                mv "$HOME/.config/$item" "$HOME/.config/${item}.bak"
            fi
        fi
        cp -r "$item" "$HOME/.config/"
    fi
done

mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Pictures/Wallpapers"

sudo systemctl enable --now swayosd-libinput-backend.service 2>/dev/null
ln -sf ~/.cache/colors/cava.ini ~/.config/cava/config 2>/dev/null

dialog --title " AthryFetch Setup " --yesno "Do you want AthryFetch?" 6 35
if [ $? -eq 0 ]; then
    FETCH_CHOICE=$(dialog --clear --title " AthryFetch Version " \
        --menu "Choose installation method:" 10 45 2 \
        "bin" "Install Pre-compiled Binary" \
        "src" "Compile from Source Code" \
        2>&1 1>&3)

    CURRENT_SHELL=$(basename "$SHELL")
    case "$CURRENT_SHELL" in
        bash) SHELL_RC="$HOME/.bashrc" ;;
        zsh)  SHELL_RC="$HOME/.zshrc" ;;
        fish) SHELL_RC="$HOME/.config/fish/config.fish" ;;
        *)    SHELL_RC="$HOME/.profile" ;;
    esac

    if [ "$FETCH_CHOICE" = "bin" ]; then
        mkdir -p "$HOME/.local/share/bin"
        cp AthryFetch "$HOME/.local/share/bin/" 2>/dev/null
        chmod +x "$HOME/.local/share/bin/AthryFetch"
        
        if [ "$CURRENT_SHELL" = "fish" ]; then
            if ! grep -q "AthryFetch" "$SHELL_RC" 2>/dev/null; then
                echo -e "\nfunction fish_greeting\n    ~/.local/share/bin/AthryFetch\nend" >> "$SHELL_RC"
            fi
        else
            if ! grep -q "AthryFetch" "$SHELL_RC" 2>/dev/null; then
                echo -e "\nexport PATH=\"\$HOME/.local/share/bin:\$PATH\"\nAthryFetch" >> "$SHELL_RC"
            fi
        fi
    elif [ "$FETCH_CHOICE" = "src" ]; then
        if command -v g++ &>/dev/null; then
            g++ -O3 Fetch.cpp -o AthryFetch 2>/dev/null
            sudo mv AthryFetch /usr/local/bin/AthryFetch 2>/dev/null
            
            if [ "$CURRENT_SHELL" = "fish" ]; then
                if ! grep -q "AthryFetch" "$SHELL_RC" 2>/dev/null; then
                    echo -e "\nfunction fish_greeting\n    AthryFetch\nend" >> "$SHELL_RC"
                fi
            else
                if ! grep -q "AthryFetch" "$SHELL_RC" 2>/dev/null; then
                    echo -e "\nAthryFetch" >> "$SHELL_RC"
                fi
            fi
        fi
    fi
    
    if [ "$CURRENT_SHELL" = "fish" ]; then
        fish -c "source $SHELL_RC" 2>/dev/null
    else
        source "$SHELL_RC" 2>/dev/null
    fi
fi

if [ "$IS_ARCH" = true ]; then
    dialog --title " Hardware Optimization " --yesno "Do you want to Optimize Your Hardware?" 6 45
    if [ $? -eq 0 ]; then
        dialog --title " Network Optimization " --yesno "Want Network Optimize?" 6 30
        NET_OPT=$?
        
        dialog --title " Systemd Optimization " --yesno "Want to Optimize Systemd Speed?" 6 35
        SYS_OPT=$?
        
        if [ $NET_OPT -eq 0 ] || [ $SYS_OPT -eq 0 ]; then
            dialog --title " Confirmation " --yesno "Are You Sure?" 6 25
            if [ $? -eq 0 ]; then
                if [ $NET_OPT -eq 0 ] && [ -f "1.sh" ]; then
                    clear
                    echo "Running Network Optimization..."
                    sudo sh  1.sh
                fi
                
                if [ $SYS_OPT -eq 0 ] && [ -f "2.sh" ]; then
                    clear
                    echo "Running Systemd Optimization..."
                    sudo sh 2.sh
                fi
                
                dialog --title " Optimization Complete " --yesno "Successfully Installed The Optimize!!\n\nWant to Reboot?" 8 45
                if [ $? -eq 0 ]; then
                    clear
                    sudo reboot
                fi
            fi
        fi
    fi
fi

clear
echo "======================================================="
echo "               Made By Alathry - Visit Now !!          "
echo "======================================================="
echo "  YouTube : https://youtube.com/@Ala7thr"
echo "  X       : https://x.com/Ala7thry"
echo "  GitHub  : https://github.com/Alathry"
echo "  Reddit  : https://www.reddit.com/user/Ala7thry/"
echo "======================================================="
ln -sf ~/.cache/colors/cava.ini ~/.config/cava/config
chmod +x ~/.config/waybar/scripts/*.sh
chmod +x ~/.config/waybar/themes/Alathry/cava.sh
chmod +x ~/.config/hypr/scripts/wal.sh
chmod +x ~/.config/gtk-4.0/
chmod +x ~/.config/script/*.sh

cd /usr/share/applications
sudo rm -rf rofi.desktop xgps.desktop xgpsspeed.desktop lstopo.desktop 

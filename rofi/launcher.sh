dir="$HOME/.config/rofi/"
theme='config.rasi'
killall -9 rofi || rofi \
    -show drun \
    -theme ${dir}/${theme}

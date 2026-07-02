#!/usr/bin/env bash

set -euo pipefail

# ── Paths ────────────────────────────────────────────────────
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
CACHE_DIR="$HOME/.cache"
COLOR_DIR="$CACHE_DIR/colors"
CACHE_FILE="$CACHE_DIR/current_wallpaper"
CACHE_IMAGE="$CACHE_DIR/current_wallpaper.png"
ROFI_THEME="${ROFI_THEME:-$HOME/.config/rofi/config.rasi}"

mkdir -p "$COLOR_DIR"

# ── Guards ───────────────────────────────────────────────────
[[ -d "$WALLPAPER_DIR" ]] || {
    notify-send -u critical "wal.sh" "Wallpaper dir not found: $WALLPAPER_DIR"; exit 1
}
command -v matugen &>/dev/null || {
    notify-send -u critical "wal.sh" "matugen not found — cargo install matugen"; exit 1
}
pick_wallpaper() {
    shopt -s nullglob nocaseglob
    local files=("$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp})
    shopt -u nullglob nocaseglob

    (( ${#files[@]} == 0 )) && {
        notify-send -u critical "wal.sh" "No images in $WALLPAPER_DIR"; exit 1
    }

    local list=""
    for f in "${files[@]}"; do
        [[ -f "$f" ]] || continue
        local name="${f##*/}"; name="${name%.*}"
        list+="${name}\0icon\x1f${f}\n"
    done

    printf "%b" "$list" | rofi \
        -dmenu \
        -i \
        -show-icons \
        -p "󰸉 Wallpaper" \
        -theme "$ROFI_THEME" \
        2>/dev/null
}
set_wallpaper() {
    local wp="$1"
    if command -v awww &>/dev/null; then
        # Ensure daemon is running
        if ! awww query &>/dev/null 2>&1; then
            awww-daemon &>/dev/null & disown
            sleep 0.5
        fi
        awww img "$wp" \
            --transition-type grow \
            --transition-pos center \
            --transition-duration 1 \
            --transition-fps 60

    elif pgrep -x hyprpaper &>/dev/null && command -v hyprctl &>/dev/null; then
        hyprctl hyprpaper unload all &>/dev/null
        hyprctl hyprpaper preload "$wp" &>/dev/null
        hyprctl hyprpaper wallpaper ",$wp" &>/dev/null

    elif command -v feh &>/dev/null; then
        feh --bg-fill "$wp"

    elif command -v nitrogen &>/dev/null; then
        nitrogen --set-zoom-fill --save "$wp"

    else
        notify-send -u critical "wal.sh" "No wallpaper setter found"; return 1
    fi
}
extract_colors() {
    local wp="$1"
    local lockfile="/tmp/wal-colors.lock"
    exec 9>"$lockfile"
    flock -n 9 || { echo "Already running, skipping color extraction"; return 0; }
    rm -f "${COLOR_DIR}/colors.css" \
          "${COLOR_DIR}/colors.conf" \
          "${COLOR_DIR}/colors2.conf" \
          "${COLOR_DIR}/colors.rasi"

    # matugen native run (writes colors.css to its own output dir)
    matugen image "$wp"   --source-color-index 0 2>/dev/null || true

    # If native run didn't produce colors.css → JSON fallback
    if [[ ! -f "${COLOR_DIR}/colors.css" ]]; then
        generate_from_json "$wp" || {
            notify-send -u critical "wal.sh" "Color extraction failed"
            flock -u 9; return 1
        }
    fi

    flock -u 9
}

generate_from_json() {
    local wp="$1"
    command -v jq &>/dev/null || { echo "ERROR: jq required"; return 1; }
    local json
    json=$(matugen image "$wp" --json hex 2>/dev/null) || return 1
    local s="dark"
    local -A C
    while IFS='=' read -r key val; do
        C[$key]="$val"
    done < <(echo "$json" | jq -r "
        .colors.${s} |
        to_entries[] |
        \"\(.key)=\(.value)\"
    " 2>/dev/null)
    _v() { echo "${C[$1]:-$2}"; }
    local background;             background=$(_v background             "#0e1513")
    local on_background;          on_background=$(_v on_background       "#dee4e1")
    local surface;                surface=$(_v surface                   "#0e1513")
    local on_surface;             on_surface=$(_v on_surface             "#dee4e1")
    local surface_variant;        surface_variant=$(_v surface_variant   "#3f4946")
    local on_surface_variant;     on_surface_variant=$(_v on_surface_variant "#bec9c5")
    local outline;                outline=$(_v outline                   "#89938f")
    local outline_variant;        outline_variant=$(_v outline_variant   "#3f4946")
    local primary;                primary=$(_v primary                   "#83d5c5")
    local on_primary;             on_primary=$(_v on_primary             "#003730")
    local primary_container;      primary_container=$(_v primary_container "#005046")
    local on_primary_container;   on_primary_container=$(_v on_primary_container "#9ff2e0")
    local secondary;              secondary=$(_v secondary               "#b1ccc5")
    local on_secondary;           on_secondary=$(_v on_secondary         "#1c3530")
    local secondary_container;    secondary_container=$(_v secondary_container "#334b46")
    local on_secondary_container; on_secondary_container=$(_v on_secondary_container "#cde8e1")
    local tertiary;               tertiary=$(_v tertiary                 "#abcae5")
    local on_tertiary;            on_tertiary=$(_v on_tertiary           "#133348")
    local tertiary_container;     tertiary_container=$(_v tertiary_container "#2c4a60")
    local on_tertiary_container;  on_tertiary_container=$(_v on_tertiary_container "#cae6ff")
    local error;                  error=$(_v error                       "#ffb4ab")
    local on_error;               on_error=$(_v on_error                 "#690005")
    local error_container;        error_container=$(_v error_container   "#93000a")
    local on_error_container;     on_error_container=$(_v on_error_container "#ffdad6")
    local inverse_surface;        inverse_surface=$(_v inverse_surface   "#dee4e1")
    local inverse_on_surface;     inverse_on_surface=$(_v inverse_on_surface "#2b3230")
    local inverse_primary;        inverse_primary=$(_v inverse_primary   "#016b5d")
    local surface_dim;            surface_dim=$(_v surface_dim           "#0e1513")
    local surface_bright;         surface_bright=$(_v surface_bright     "#343b39")
    local surface_container_lowest; surface_container_lowest=$(_v surface_container_lowest "#090f0e")
    local surface_container_low;  surface_container_low=$(_v surface_container_low "#171d1b")
    local surface_container;      surface_container=$(_v surface_container "#1b211f")
    local surface_container_high; surface_container_high=$(_v surface_container_high "#252b29")
    local surface_container_highest; surface_container_highest=$(_v surface_container_highest "#303634")
    local surface_tint;           surface_tint=$(_v surface_tint         "#83d5c5")
    local primary_fixed;          primary_fixed=$(_v primary_fixed       "#9ff2e0")
    local primary_fixed_dim;      primary_fixed_dim=$(_v primary_fixed_dim "#83d5c5")
    local on_primary_fixed;       on_primary_fixed=$(_v on_primary_fixed "#00201b")
    local on_primary_fixed_variant; on_primary_fixed_variant=$(_v on_primary_fixed_variant "#005046")
    local secondary_fixed;        secondary_fixed=$(_v secondary_fixed   "#cde8e1")
    local secondary_fixed_dim;    secondary_fixed_dim=$(_v secondary_fixed_dim "#b1ccc5")
    local on_secondary_fixed;     on_secondary_fixed=$(_v on_secondary_fixed "#06201b")
    local on_secondary_fixed_variant; on_secondary_fixed_variant=$(_v on_secondary_fixed_variant "#334b46")
    local tertiary_fixed;         tertiary_fixed=$(_v tertiary_fixed     "#cae6ff")
    local tertiary_fixed_dim;     tertiary_fixed_dim=$(_v tertiary_fixed_dim "#abcae5")
    local on_tertiary_fixed;      on_tertiary_fixed=$(_v on_tertiary_fixed "#001e2f")
    local on_tertiary_fixed_variant; on_tertiary_fixed_variant=$(_v on_tertiary_fixed_variant "#2c4a60")
    local scrim;                  scrim=$(_v scrim                       "#000000")
    local shadow;                 shadow=$(_v shadow                     "#000000")
    local source_color;           source_color=$(_v source_color         "#08110f")
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    local f="${COLOR_DIR}/colors.css"
    cat > "${f}.tmp" << EOF
/* Material You — Generated ${ts} */
@define-color background ${background};
@define-color error ${error};
@define-color error_container ${error_container};
@define-color inverse_on_surface ${inverse_on_surface};
@define-color inverse_primary ${inverse_primary};
@define-color inverse_surface ${inverse_surface};
@define-color on_background ${on_background};
@define-color on_error ${on_error};
@define-color on_error_container ${on_error_container};
@define-color on_primary ${on_primary};
@define-color on_primary_container ${on_primary_container};
@define-color on_primary_fixed ${on_primary_fixed};
@define-color on_primary_fixed_variant ${on_primary_fixed_variant};
@define-color on_secondary ${on_secondary};
@define-color on_secondary_container ${on_secondary_container};
@define-color on_secondary_fixed ${on_secondary_fixed};
@define-color on_secondary_fixed_variant ${on_secondary_fixed_variant};
@define-color on_surface ${on_surface};
@define-color on_surface_variant ${on_surface_variant};
@define-color on_tertiary ${on_tertiary};
@define-color on_tertiary_container ${on_tertiary_container};
@define-color on_tertiary_fixed ${on_tertiary_fixed};
@define-color on_tertiary_fixed_variant ${on_tertiary_fixed_variant};
@define-color outline ${outline};
@define-color outline_variant ${outline_variant};
@define-color primary ${primary};
@define-color primary_container ${primary_container};
@define-color primary_fixed ${primary_fixed};
@define-color primary_fixed_dim ${primary_fixed_dim};
@define-color scrim ${scrim};
@define-color secondary ${secondary};
@define-color secondary_container ${secondary_container};
@define-color secondary_fixed ${secondary_fixed};
@define-color secondary_fixed_dim ${secondary_fixed_dim};
@define-color shadow ${shadow};
@define-color source_color ${source_color};
@define-color surface ${surface};
@define-color surface_bright ${surface_bright};
@define-color surface_container ${surface_container};
@define-color surface_container_high ${surface_container_high};
@define-color surface_container_highest ${surface_container_highest};
@define-color surface_container_low ${surface_container_low};
@define-color surface_container_lowest ${surface_container_lowest};
@define-color surface_dim ${surface_dim};
@define-color surface_tint ${surface_tint};
@define-color surface_variant ${surface_variant};
@define-color tertiary ${tertiary};
@define-color tertiary_container ${tertiary_container};
@define-color tertiary_fixed ${tertiary_fixed};
@define-color tertiary_fixed_dim ${tertiary_fixed_dim};
EOF
    mv "${f}.tmp" "$f"

    # colors.conf — Kitty
    f="${COLOR_DIR}/colors.conf"
    cat > "${f}.tmp" << EOF
# Kitty — Material You — ${ts}
foreground              ${on_surface}
background              ${background}
background_opacity      0.95
selection_foreground    ${on_primary}
selection_background    ${primary}
cursor                  ${primary}
cursor_text_color       ${on_primary}
url_color               ${tertiary}
color0                  ${surface_container_lowest}
color1                  ${error}
color2                  ${primary}
color3                  ${tertiary}
color4                  ${primary_fixed_dim}
color5                  ${secondary}
color6                  ${tertiary_fixed_dim}
color7                  ${on_surface}
color8                  ${outline}
color9                  ${error_container}
color10                 ${primary_container}
color11                 ${tertiary_container}
color12                 ${primary_fixed}
color13                 ${secondary_fixed}
color14                 ${tertiary_fixed}
color15                 ${surface_bright}
active_tab_foreground   ${on_primary}
active_tab_background   ${primary}
inactive_tab_foreground ${on_surface_variant}
inactive_tab_background ${surface_container}
EOF
    mv "${f}.tmp" "$f"
    f="${COLOR_DIR}/colors2.conf"
    cat > "${f}.tmp" << EOF
# Hyprland — Material You — ${ts}
\$background              = rgb(${background//#/})
\$surface                 = rgb(${surface//#/})
\$surfaceContainer        = rgb(${surface_container//#/})
\$surfaceContainerHigh    = rgb(${surface_container_high//#/})
\$surfaceContainerHighest = rgb(${surface_container_highest//#/})
\$surfaceContainerLow     = rgb(${surface_container_low//#/})
\$surfaceContainerLowest  = rgb(${surface_container_lowest//#/})
\$surfaceBright           = rgb(${surface_bright//#/})
\$surfaceVariant          = rgb(${surface_variant//#/})
\$onSurface               = rgb(${on_surface//#/})
\$onSurfaceVariant        = rgb(${on_surface_variant//#/})
\$primary                 = rgb(${primary//#/})
\$onPrimary               = rgb(${on_primary//#/})
\$primaryContainer        = rgb(${primary_container//#/})
\$onPrimaryContainer      = rgb(${on_primary_container//#/})
\$secondary               = rgb(${secondary//#/})
\$onSecondary             = rgb(${on_secondary//#/})
\$secondaryContainer      = rgb(${secondary_container//#/})
\$onSecondaryContainer    = rgb(${on_secondary_container//#/})
\$tertiary                = rgb(${tertiary//#/})
\$onTertiary              = rgb(${on_tertiary//#/})
\$tertiaryContainer       = rgb(${tertiary_container//#/})
\$onTertiaryContainer     = rgb(${on_tertiary_container//#/})
\$error                   = rgb(${error//#/})
\$onError                 = rgb(${on_error//#/})
\$errorContainer          = rgb(${error_container//#/})
\$onErrorContainer        = rgb(${on_error_container//#/})
\$outline                 = rgb(${outline//#/})
\$outlineVariant          = rgb(${outline_variant//#/})
\$inverseSurface          = rgb(${inverse_surface//#/})
\$inverseOnSurface        = rgb(${inverse_on_surface//#/})
\$inversePrimary          = rgb(${inverse_primary//#/})
\$shadow                  = rgba(${shadow//#/}cc)
\$activeBorder            = rgb(${primary//#/})
\$inactiveBorder          = rgb(${outline_variant//#/})
\$groupActiveBorder       = rgb(${tertiary//#/})
\$groupInactiveBorder     = rgb(${surface_variant//#/})
EOF
    mv "${f}.tmp" "$f"
    f="${COLOR_DIR}/colors.rasi"
    cat > "${f}.tmp" << EOF
/* Rofi — Material You — ${ts} */
* {
    background:                  ${background};
    surface:                     ${surface};
    surface-container:           ${surface_container};
    surface-container-high:      ${surface_container_high};
    surface-container-highest:   ${surface_container_highest};
    surface-container-low:       ${surface_container_low};
    surface-container-lowest:    ${surface_container_lowest};
    surface-bright:              ${surface_bright};
    surface-variant:             ${surface_variant};
    foreground:                  ${on_surface};
    on-surface:                  ${on_surface};
    on-surface-variant:          ${on_surface_variant};
    primary:                     ${primary};
    on-primary:                  ${on_primary};
    primary-container:           ${primary_container};
    on-primary-container:        ${on_primary_container};
    secondary:                   ${secondary};
    on-secondary:                ${on_secondary};
    secondary-container:         ${secondary_container};
    on-secondary-container:      ${on_secondary_container};
    tertiary:                    ${tertiary};
    on-tertiary:                 ${on_tertiary};
    tertiary-container:          ${tertiary_container};
    on-tertiary-container:       ${on_tertiary_container};
    error:                       ${error};
    on-error:                    ${on_error};
    error-container:             ${error_container};
    on-error-container:          ${on_error_container};
    outline:                     ${outline};
    outline-variant:             ${outline_variant};
    inverse-surface:             ${inverse_surface};
    inverse-on-surface:          ${inverse_on_surface};
    inverse-primary:             ${inverse_primary};
    selected-background:         ${primary_container};
    selected-foreground:         ${on_primary_container};
    active-background:           ${tertiary_container};
    active-foreground:           ${on_tertiary_container};
    urgent-background:           ${error_container};
    urgent-foreground:           ${on_error_container};
    shadow:                      ${shadow};
    scrim:                       ${scrim};
}
EOF
    mv "${f}.tmp" "$f"

    echo "  Colors written: css / conf / hypr / rasi"
}
reload_services() {
    # ── Kitty: hot-reload without killing terminal ────────────
    if pgrep -x kitty &>/dev/null; then
        kill -USR1 "$(pgrep -x kitty | tr '\n' ' ')" 2>/dev/null || true
    fi
    if command -v hyprctl &>/dev/null; then
        hyprctl reload &>/dev/null || true
    fi
    if command -v waybar &>/dev/null; then
        pkill -x waybar 2>/dev/null || true
        # Wait until it's fully dead (max 1s)
        local i=0
        while pgrep -x waybar &>/dev/null && (( i++ < 10 )); do sleep 0.1; done
        waybar &>/dev/null & disown
    fi
    if command -v swaync-client &>/dev/null; then
        swaync-client -rs &>/dev/null || true
    fi
    command -v pywalfox &>/dev/null && pywalfox update &>/dev/null & disown 2>/dev/null || true
    local hook="$HOME/.config/hypr/scripts/reload-waybar.sh"
    [[ -x "$hook" ]] && bash "$hook" & disown 2>/dev/null || true
}
main() {
    local t0; t0=$(date +%s%N)
    local selected
    selected=$(pick_wallpaper) || exit 0
    [[ -z "$selected" ]] && exit 0
    local wallpaper=""
    shopt -s nocaseglob
    for ext in png jpg jpeg webp; do
        local c="${WALLPAPER_DIR}/${selected}.${ext}"
        [[ -f "$c" ]] && { wallpaper="$c"; break; }
    done
    shopt -u nocaseglob

    [[ -z "$wallpaper" ]] && {
        notify-send -u critical "wal.sh" "File not found: $selected"; exit 1
    }

    echo "▶ Wallpaper: $wallpaper"
    {
        echo "$wallpaper" > "$CACHE_FILE"
        if command -v magick &>/dev/null; then
            magick "$wallpaper" -resize 800x800 -quality 90 "$CACHE_IMAGE" 2>/dev/null \
                || cp "$wallpaper" "$CACHE_IMAGE"
        else
            cp "$wallpaper" "$CACHE_IMAGE"
        fi
    } &
    local pid_cache=$!
    set_wallpaper "$wallpaper" &
    local pid_wall=$!
    extract_colors "$wallpaper"
    reload_services
    wait "$pid_cache" "$pid_wall" 2>/dev/null || true
    local elapsed=$(( ( $(date +%s%N) - t0 ) / 1000000 ))
    notify-send \
        -i "$CACHE_IMAGE" \
        "Wallpaper Applied" \
        "${selected}\nColors extracted in ${elapsed}ms" \
        -t 3000

    echo "✓ Done: ${elapsed}ms"
}

main "$@"



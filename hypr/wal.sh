#!/usr/bin/env bash

set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
CACHE_DIR="${HOME}/.cache"
COLOR_DIR="${CACHE_DIR}/colors"
CACHE_FILE="${CACHE_DIR}/current_wallpaper"
CACHE_IMAGE="${CACHE_DIR}/current_wallpaper.png"
mkdir -p "$COLOR_DIR"
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify-send -u critical "Wallpaper Selector" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi
if ! command -v matugen &>/dev/null; then
    notify-send -u critical "Wallpaper Selector" "matugen not found. Install it: cargo install matugen"
    exit 1
fi
extract_colors() {
    local wallpaper="$1"
    echo "  Running matugen on: $(basename "$wallpaper")"
    matugen image "$wallpaper" 2>/dev/null
    if [[ ! -f "${COLOR_DIR}/colors.css" ]]; then
        echo "  WARNING: matugen did not generate colors.css"
        echo "  Generating fallback from matugen output..."
        generate_colors_from_matugen "$wallpaper"
    fi
    echo "  Matugen colors extracted successfully"
}
generate_colors_from_matugen() {
    local wallpaper="$1"

    # Get matugen JSON output
    local json_output
    json_output=$(matugen image "$wallpaper" --json hex 2>/dev/null) || {
        echo "  ERROR: matugen failed to process image"
        return 1
    }
    if ! command -v jq &>/dev/null; then
        echo "  ERROR: jq not found, needed for JSON parsing"
        return 1
    fi

    local scheme="dark"

    local background on_background surface on_surface
    local surface_variant on_surface_variant outline outline_variant
    local primary on_primary primary_container on_primary_container
    local secondary on_secondary secondary_container on_secondary_container
    local tertiary on_tertiary tertiary_container on_tertiary_container
    local error on_error error_container on_error_container
    local inverse_surface inverse_on_surface inverse_primary
    local surface_dim surface_bright
    local surface_container_lowest surface_container_low surface_container
    local surface_container_high surface_container_highest
    local primary_fixed primary_fixed_dim on_primary_fixed on_primary_fixed_variant
    local secondary_fixed secondary_fixed_dim on_secondary_fixed on_secondary_fixed_variant
    local tertiary_fixed tertiary_fixed_dim on_tertiary_fixed on_tertiary_fixed_variant
    local scrim shadow source_color surface_tint

    background=$(echo "$json_output" | jq -r ".colors.${scheme}.background // \"#0e1513\"")
    on_background=$(echo "$json_output" | jq -r ".colors.${scheme}.on_background // \"#dee4e1\"")
    surface=$(echo "$json_output" | jq -r ".colors.${scheme}.surface // \"#0e1513\"")
    on_surface=$(echo "$json_output" | jq -r ".colors.${scheme}.on_surface // \"#dee4e1\"")
    surface_variant=$(echo "$json_output" | jq -r ".colors.${scheme}.surface_variant // \"#3f4946\"")
    on_surface_variant=$(echo "$json_output" | jq -r ".colors.${scheme}.on_surface_variant // \"#bec9c5\"")
    outline=$(echo "$json_output" | jq -r ".colors.${scheme}.outline // \"#89938f\"")
    outline_variant=$(echo "$json_output" | jq -r ".colors.${scheme}.outline_variant // \"#3f4946\"")

    primary=$(echo "$json_output" | jq -r ".colors.${scheme}.primary // \"#83d5c5\"")
    on_primary=$(echo "$json_output" | jq -r ".colors.${scheme}.on_primary // \"#003730\"")
    primary_container=$(echo "$json_output" | jq -r ".colors.${scheme}.primary_container // \"#005046\"")
    on_primary_container=$(echo "$json_output" | jq -r ".colors.${scheme}.on_primary_container // \"#9ff2e0\"")

    secondary=$(echo "$json_output" | jq -r ".colors.${scheme}.secondary // \"#b1ccc5\"")
    on_secondary=$(echo "$json_output" | jq -r ".colors.${scheme}.on_secondary // \"#1c3530\"")
    secondary_container=$(echo "$json_output" | jq -r ".colors.${scheme}.secondary_container // \"#334b46\"")
    on_secondary_container=$(echo "$json_output" | jq -r ".colors.${scheme}.on_secondary_container // \"#cde8e1\"")

    tertiary=$(echo "$json_output" | jq -r ".colors.${scheme}.tertiary // \"#abcae5\"")
    on_tertiary=$(echo "$json_output" | jq -r ".colors.${scheme}.on_tertiary // \"#133348\"")
    tertiary_container=$(echo "$json_output" | jq -r ".colors.${scheme}.tertiary_container // \"#2c4a60\"")
    on_tertiary_container=$(echo "$json_output" | jq -r ".colors.${scheme}.on_tertiary_container // \"#cae6ff\"")

    error=$(echo "$json_output" | jq -r ".colors.${scheme}.error // \"#ffb4ab\"")
    on_error=$(echo "$json_output" | jq -r ".colors.${scheme}.on_error // \"#690005\"")
    error_container=$(echo "$json_output" | jq -r ".colors.${scheme}.error_container // \"#93000a\"")
    on_error_container=$(echo "$json_output" | jq -r ".colors.${scheme}.on_error_container // \"#ffdad6\"")

    inverse_surface=$(echo "$json_output" | jq -r ".colors.${scheme}.inverse_surface // \"#dee4e1\"")
    inverse_on_surface=$(echo "$json_output" | jq -r ".colors.${scheme}.inverse_on_surface // \"#2b3230\"")
    inverse_primary=$(echo "$json_output" | jq -r ".colors.${scheme}.inverse_primary // \"#016b5d\"")

    surface_dim=$(echo "$json_output" | jq -r ".colors.${scheme}.surface_dim // \"#0e1513\"")
    surface_bright=$(echo "$json_output" | jq -r ".colors.${scheme}.surface_bright // \"#343b39\"")
    surface_container_lowest=$(echo "$json_output" | jq -r ".colors.${scheme}.surface_container_lowest // \"#090f0e\"")
    surface_container_low=$(echo "$json_output" | jq -r ".colors.${scheme}.surface_container_low // \"#171d1b\"")
    surface_container=$(echo "$json_output" | jq -r ".colors.${scheme}.surface_container // \"#1b211f\"")
    surface_container_high=$(echo "$json_output" | jq -r ".colors.${scheme}.surface_container_high // \"#252b29\"")
    surface_container_highest=$(echo "$json_output" | jq -r ".colors.${scheme}.surface_container_highest // \"#303634\"")
    surface_tint=$(echo "$json_output" | jq -r ".colors.${scheme}.surface_tint // \"#83d5c5\"")

    primary_fixed=$(echo "$json_output" | jq -r ".colors.${scheme}.primary_fixed // \"#9ff2e0\"")
    primary_fixed_dim=$(echo "$json_output" | jq -r ".colors.${scheme}.primary_fixed_dim // \"#83d5c5\"")
    on_primary_fixed=$(echo "$json_output" | jq -r ".colors.${scheme}.on_primary_fixed // \"#00201b\"")
    on_primary_fixed_variant=$(echo "$json_output" | jq -r ".colors.${scheme}.on_primary_fixed_variant // \"#005046\"")

    secondary_fixed=$(echo "$json_output" | jq -r ".colors.${scheme}.secondary_fixed // \"#cde8e1\"")
    secondary_fixed_dim=$(echo "$json_output" | jq -r ".colors.${scheme}.secondary_fixed_dim // \"#b1ccc5\"")
    on_secondary_fixed=$(echo "$json_output" | jq -r ".colors.${scheme}.on_secondary_fixed // \"#06201b\"")
    on_secondary_fixed_variant=$(echo "$json_output" | jq -r ".colors.${scheme}.on_secondary_fixed_variant // \"#334b46\"")

    tertiary_fixed=$(echo "$json_output" | jq -r ".colors.${scheme}.tertiary_fixed // \"#cae6ff\"")
    tertiary_fixed_dim=$(echo "$json_output" | jq -r ".colors.${scheme}.tertiary_fixed_dim // \"#abcae5\"")
    on_tertiary_fixed=$(echo "$json_output" | jq -r ".colors.${scheme}.on_tertiary_fixed // \"#001e2f\"")
    on_tertiary_fixed_variant=$(echo "$json_output" | jq -r ".colors.${scheme}.on_tertiary_fixed_variant // \"#2c4a60\"")

    scrim=$(echo "$json_output" | jq -r ".colors.${scheme}.scrim // \"#000000\"")
    shadow=$(echo "$json_output" | jq -r ".colors.${scheme}.shadow // \"#000000\"")
    source_color=$(echo "$json_output" | jq -r ".colors.${scheme}.source_color // \"#08110f\"")

    cat > "${COLOR_DIR}/colors.css" << WAYBAR
/*
 * Css Colors
 * Generated with Matugen
 * $(date '+%Y-%m-%d %H:%M:%S')
 */

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
WAYBAR

    cat > "${COLOR_DIR}/colors.conf" << KITTY
# Kitty Color Configuration
# Material You - Generated with Matugen
# $(date '+%Y-%m-%d %H:%M:%S')

# Special
foreground              ${on_surface}
background              ${background}
background_opacity      0.95
selection_foreground     ${on_primary}
selection_background     ${primary}
cursor                  ${primary}
cursor_text_color       ${on_primary}
url_color               ${tertiary}

# Normal Colors (mapped from Material You)
color0                  ${surface_container_lowest}
color1                  ${error}
color2                  ${primary}
color3                  ${tertiary}
color4                  ${primary_fixed_dim}
color5                  ${secondary}
color6                  ${tertiary_fixed_dim}
color7                  ${on_surface}

# Bright Colors
color8                  ${outline}
color9                  ${error_container}
color10                 ${primary_container}
color11                 ${tertiary_container}
color12                 ${primary_fixed}
color13                 ${secondary_fixed}
color14                 ${tertiary_fixed}
color15                 ${surface_bright}

# Tab Bar
active_tab_foreground   ${on_primary}
active_tab_background   ${primary}
inactive_tab_foreground ${on_surface_variant}
inactive_tab_background ${surface_container}
KITTY

    # ─────────────────────────────────────────
    # Generate: colors2.conf (Hyprland - Material You)
    # ─────────────────────────────────────────
    # Strip '#' for Hyprland rgb() format
    local h_bg="${background//#/}"
    local h_surface="${surface//#/}"
    local h_surface_container="${surface_container//#/}"
    local h_on_surface="${on_surface//#/}"
    local h_primary="${primary//#/}"
    local h_on_primary="${on_primary//#/}"
    local h_primary_container="${primary_container//#/}"
    local h_secondary="${secondary//#/}"
    local h_tertiary="${tertiary//#/}"
    local h_error="${error//#/}"
    local h_outline="${outline//#/}"
    local h_outline_variant="${outline_variant//#/}"
    local h_surface_variant="${surface_variant//#/}"
    local h_surface_bright="${surface_bright//#/}"
    local h_surface_container_high="${surface_container_high//#/}"
    local h_surface_container_highest="${surface_container_highest//#/}"
    local h_surface_container_low="${surface_container_low//#/}"
    local h_surface_container_lowest="${surface_container_lowest//#/}"
    local h_inverse_surface="${inverse_surface//#/}"
    local h_inverse_primary="${inverse_primary//#/}"
    local h_shadow="${shadow//#/}"

    cat > "${COLOR_DIR}/colors2.conf" << HYPR
# $(date '+%Y-%m-%d %H:%M:%S')

# Core surfaces
\$background              = rgb(${h_bg})
\$surface                 = rgb(${h_surface})
\$surfaceContainer        = rgb(${h_surface_container})
\$surfaceContainerHigh    = rgb(${h_surface_container_high})
\$surfaceContainerHighest = rgb(${h_surface_container_highest})
\$surfaceContainerLow     = rgb(${h_surface_container_low})
\$surfaceContainerLowest  = rgb(${h_surface_container_lowest})
\$surfaceBright           = rgb(${h_surface_bright})
\$surfaceVariant          = rgb(${h_surface_variant})

# On-surfaces
\$onSurface               = rgb(${h_on_surface})
\$onSurfaceVariant        = rgb(${on_surface_variant//#/})

# Primary
\$primary                 = rgb(${h_primary})
\$onPrimary               = rgb(${h_on_primary})
\$primaryContainer        = rgb(${h_primary_container})
\$onPrimaryContainer      = rgb(${on_primary_container//#/})

# Secondary
\$secondary               = rgb(${h_secondary})
\$onSecondary             = rgb(${on_secondary//#/})
\$secondaryContainer      = rgb(${secondary_container//#/})
\$onSecondaryContainer    = rgb(${on_secondary_container//#/})

# Tertiary
\$tertiary                = rgb(${h_tertiary})
\$onTertiary              = rgb(${on_tertiary//#/})
\$tertiaryContainer       = rgb(${tertiary_container//#/})
\$onTertiaryContainer     = rgb(${on_tertiary_container//#/})

# Error
\$error                   = rgb(${h_error})
\$onError                 = rgb(${on_error//#/})
\$errorContainer          = rgb(${error_container//#/})
\$onErrorContainer        = rgb(${on_error_container//#/})

# Outline
\$outline                 = rgb(${h_outline})
\$outlineVariant          = rgb(${h_outline_variant})

# Inverse
\$inverseSurface          = rgb(${h_inverse_surface})
\$inverseOnSurface        = rgb(${inverse_on_surface//#/})
\$inversePrimary          = rgb(${h_inverse_primary})

# Shadow
\$shadow                  = rgba(${h_shadow}cc)

# ── Hyprland-specific aliases ──
\$activeBorder            = rgb(${h_primary})
\$inactiveBorder          = rgb(${h_outline_variant})
\$groupActiveBorder       = rgb(${h_tertiary})
\$groupInactiveBorder     = rgb(${h_surface_variant})
HYPR

    cat > "${COLOR_DIR}/colors.rasi" << ROFI
/**
 * $(date '+%Y-%m-%d %H:%M:%S')
 */

* {
    /* Core surfaces */
    background:                  ${background};
    surface:                     ${surface};
    surface-container:           ${surface_container};
    surface-container-high:      ${surface_container_high};
    surface-container-highest:   ${surface_container_highest};
    surface-container-low:       ${surface_container_low};
    surface-container-lowest:    ${surface_container_lowest};
    surface-bright:              ${surface_bright};
    surface-variant:             ${surface_variant};

    /* On-surfaces */
    foreground:                  ${on_surface};
    on-surface:                  ${on_surface};
    on-surface-variant:          ${on_surface_variant};

    /* Primary */
    primary:                     ${primary};
    on-primary:                  ${on_primary};
    primary-container:           ${primary_container};
    on-primary-container:        ${on_primary_container};

    /* Secondary */
    secondary:                   ${secondary};
    on-secondary:                ${on_secondary};
    secondary-container:         ${secondary_container};
    on-secondary-container:      ${on_secondary_container};

    /* Tertiary */
    tertiary:                    ${tertiary};
    on-tertiary:                 ${on_tertiary};
    tertiary-container:          ${tertiary_container};
    on-tertiary-container:       ${on_tertiary_container};

    /* Error */
    error:                       ${error};
    on-error:                    ${on_error};
    error-container:             ${error_container};
    on-error-container:          ${on_error_container};

    /* Outline */
    outline:                     ${outline};
    outline-variant:             ${outline_variant};

    /* Inverse */
    inverse-surface:             ${inverse_surface};
    inverse-on-surface:          ${inverse_on_surface};
    inverse-primary:             ${inverse_primary};

    /* Semantic aliases for rofi themes */
    selected-background:         ${primary_container};
    selected-foreground:         ${on_primary_container};
    active-background:           ${tertiary_container};
    active-foreground:           ${on_tertiary_container};
    urgent-background:           ${error_container};
    urgent-foreground:           ${on_error_container};

    /* Shadow */
    shadow:                      ${shadow};
    scrim:                       ${scrim};
}
ROFI

    echo "  Generated: colors.css, colors.conf, colors2.conf, colors.rasi"
}

reload_services() {
    echo "  Reloading services..."

    pkill -x waybar 2>/dev/null || true
    pkill -x rofi 2>/dev/null || true

    if pgrep -x kitty &>/dev/null; then
        pkill -USR1 kitty 2>/dev/null || true
    fi

    if command -v hyprctl &>/dev/null; then
        hyprctl reload &>/dev/null &
    fi

    sleep 0.15

    if command -v waybar &>/dev/null; then
        waybar &>/dev/null &
        disown
    fi

    echo "  Services reloaded"
}

set_wallpaper() {
    local wp="$1"
    if command -v swww &>/dev/null; then
        # Ensure swww daemon is running
        swww query &>/dev/null 2>&1 || {
            swww-daemon &>/dev/null &
            disown
            sleep 0.3
        }
        swww img "$wp" \
            --transition-type grow \
            --transition-pos center \
            --transition-duration 1 \
            --transition-fps 60 &
    elif command -v swaybg &>/dev/null; then
        pkill swaybg 2>/dev/null || true
        swaybg -i "$wp" -m fill &>/dev/null &
        disown
    elif command -v hyprctl &>/dev/null && pgrep -x hyprpaper &>/dev/null; then
        hyprctl hyprpaper unload all &>/dev/null
        hyprctl hyprpaper preload "$wp" &>/dev/null
        hyprctl hyprpaper wallpaper ",$wp" &>/dev/null
    elif command -v feh &>/dev/null; then
        feh --bg-fill "$wp"
    elif command -v nitrogen &>/dev/null; then
        nitrogen --set-zoom-fill --save "$wp"
    elif command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.background picture-uri "file://$wp"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$wp"
    else
        notify-send -u critical "Error" "No wallpaper setter found"
        return 1
    fi
}

generate_list() {
    shopt -s nullglob nocaseglob
    local files=("$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp})
    for file in "${files[@]}"; do
        [[ -f "$file" ]] || continue
        local name="${file##*/}"
        name="${name%.*}"
        printf '%s\0icon\x1f%s\n' "$name" "$file"
    done
}

ROFI_THEME='

@import "~/.cache/colors/rofi.rasi"

/* ─────────────────────────────────────────── */
/* Material You Semantic Aliases               */
/* ─────────────────────────────────────────── */
* {
    /* Surface roles */
    bg:             @surface;
    bg-alt:         @surface-container;
    bg-elevated:    @surface-container-high;

    /* Content roles */
    fg:             @on-surface;
    fg-dim:         @on-surface-variant;

    /* Interactive roles */
    bg-selected:    @primary;
    fg-selected:    @on-primary;
    accent:         @primary;

    /* Border roles */
    border-subtle:  @outline-variant;
    border-strong:  @outline;

    /* State roles */
    bg-active:      @primary-container;
    fg-active:      @on-primary-container;
    bg-urgent:      @error-container;
    fg-urgent:      @on-error-container;
}

/* ─────────────────────────────────────────── */
/* Configuration                               */
/* ─────────────────────────────────────────── */
configuration {
    modi:                       "drun,run,window";
    show-icons:                 true;
    display-drun:               "Apps";
    display-run:                "Run";
    display-filebrowser:        "Files";
    display-window:             "Windows";
    drun-display-format:        "{name}";
    window-format:              "{c} · {t}";
    font:                       "Google Sans Display 12";
    icon-theme:                 "Papirus-Dark";
    hover-select:               true;
    me-select-entry:            "";
    me-accept-entry:            "MousePrimary";
    cursor:                     "default";
    steal-focus:                true;
    case-sensitive:             false;
    sort:                       true;
    sorting-method:             "fzf";
    matching:                   "fuzzy";
    click-to-exit:              true;
    drun-match-fields:          "name,generic,exec,categories,keywords";
}

/* ─────────────────────────────────────────── */
/* Global Reset                                */
/* ─────────────────────────────────────────── */
* {
    background-color:           transparent;
    margin:                     0;
    padding:                    0;
}

/* ─────────────────────────────────────────── */
/* Window                                      */
/* ─────────────────────────────────────────── */
window {
    transparency:               "real";
    location:                   center;
    anchor:                     center;
    fullscreen:                 false;
    width:                      820px;
    x-offset:                   0;
    y-offset:                   0;
    enabled:                    true;
    border-radius:              24px;
    border:                     2px solid;
    border-color:               @border-subtle;
    cursor:                     "default";
    background-color:           @bg;
}

/* ─────────────────────────────────────────── */
/* Main Box                                    */
/* ─────────────────────────────────────────── */
mainbox {
    enabled:                    true;
    spacing:                    24px;
    padding:                    28px 32px;
    orientation:                vertical;
    children:                   [ "inputbar", "listview", "message" ];
    background-color:           transparent;
}

/* ─────────────────────────────────────────── */
/* Input Bar                                   */
/* ─────────────────────────────────────────── */
inputbar {
    enabled:                    true;
    spacing:                    12px;
    padding:                    14px 18px;
    border:                     1px solid;
    border-color:               @border-subtle;
    border-radius:              16px;
    background-color:           @bg-alt;
    text-color:                 @fg;
    children:                   [ "textbox-prompt", "entry" ];
}

textbox-prompt {
    enabled:                    true;
    expand:                     false;
    str:                        "󰍉";
    font:                       "Symbols Nerd Font 16";
    background-color:           transparent;
    text-color:                 @fg-dim;
    vertical-align:             0.5;
    horizontal-align:           0.5;
}

prompt {
    enabled:                    true;
    background-color:           transparent;
    text-color:                 @fg;
}

entry {
    enabled:                    true;
    background-color:           transparent;
    text-color:                 @fg;
    cursor:                     text;
    placeholder:                "Type to search…";
    placeholder-color:          @fg-dim;
    vertical-align:             0.5;
}

/* ─────────────────────────────────────────── */
/* List View                                   */
/* ─────────────────────────────────────────── */
listview {
    enabled:                    true;
    columns:                    2;
    lines:                      2;
    cycle:                      true;
    dynamic:                    true;
    scrollbar:                  false;
    layout:                     vertical;
    reverse:                    false;
    fixed-height:               true;
    fixed-columns:              false;
    spacing:                    20px;
    background-color:           transparent;
    text-color:                 @fg;
    cursor:                     "default";
}

/* ─────────────────────────────────────────── */
/* Elements                                    */
/* ─────────────────────────────────────────── */
element {
    enabled:                    true;
    orientation:                vertical;
    spacing:                    12px;
    padding:                    24px 14px 20px 14px;
    border-radius:              18px;
    cursor:                     pointer;
    background-color:           transparent;
    text-color:                 @fg;
    border:                     2px solid;
    border-color:               transparent;
}

element normal.normal {
    background-color:           transparent;
    text-color:                 @fg;
}

element normal.urgent {
    background-color:           transparent;
    text-color:                 @fg-urgent;
}

element normal.active {
    background-color:           @bg-active;
    text-color:                 @fg-active;
    border-color:               @border-subtle;
}

element selected.normal {
    background-color:           @bg-selected;
    text-color:                 @fg-selected;
    border-color:               @accent;
}

element selected.urgent {
    background-color:           @bg-urgent;
    text-color:                 @fg-urgent;
    border-color:               @error;
}

element selected.active {
    background-color:           @bg-selected;
    text-color:                 @fg-selected;
    border-color:               @accent;
}

element alternate.normal {
    background-color:           transparent;
    text-color:                 @fg;
}

element alternate.urgent {
    background-color:           transparent;
    text-color:                 @fg-urgent;
}

element alternate.active {
    background-color:           @bg-active;
    text-color:                 @fg-active;
    border-color:               @border-subtle;
}

element-icon {
    background-color:           transparent;
    text-color:                 inherit;
    size:                       56px;
    cursor:                     inherit;
    horizontal-align:           0.5;
}

element-text {
    background-color:           transparent;
    text-color:                 inherit;
    highlight:                  inherit;
    cursor:                     inherit;
    vertical-align:             0.5;
    horizontal-align:           0.5;
    font:                       "Google Sans Display 10";
}

/* ─────────────────────────────────────────── */
/* Message / Error                             */
/* ─────────────────────────────────────────── */
message {
    enabled:                    true;
    padding:                    0;
    background-color:           transparent;
}

textbox {
    padding:                    14px 18px;
    border-radius:              14px;
    background-color:           @bg-alt;
    text-color:                 @fg-dim;
    vertical-align:             0.5;
    horizontal-align:           0.5;
}

error-message {
    padding:                    18px;
    border-radius:              16px;
    background-color:           @bg-urgent;
    text-color:                 @fg-urgent;
    border:                     2px solid;
    border-color:               @error;
}

'
main() {
    local start_time
    start_time=$(date +%s%N)

    # Show Rofi selector
    local selected
    selected=$(generate_list | rofi -dmenu \
        -i \
        -show-icons \
        -p "󰸉 " \
        -mesg "  Select a wallpaper to apply" \
        -scroll-method 0 \
        -theme-str "$ROFI_THEME" \
        2>/dev/null) || exit 0

    [[ -z "$selected" ]] && exit 0

    # Find the actual file
    local wallpaper=""
    shopt -s nocaseglob
    for ext in png jpg jpeg webp; do
        local candidate="${WALLPAPER_DIR}/${selected}.${ext}"
        if [[ -f "$candidate" ]]; then
            wallpaper="$candidate"
            break
        fi
    done
    shopt -u nocaseglob

    if [[ -z "$wallpaper" || ! -f "$wallpaper" ]]; then
        notify-send -u critical "Error" "Wallpaper file not found: ${selected}"
        exit 1
    fi

    echo "Selected: $wallpaper"

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

    # Wait for cache to finish
    wait "$pid_cache" 2>/dev/null

    reload_services

    wait "$pid_wall" 2>/dev/null

    local end_time
    end_time=$(date +%s%N)
    local elapsed=$(( (end_time - start_time) / 1000000 ))

    notify-send -i "$CACHE_IMAGE" \
        "Wallpaper Applied" \
        "${selected}\nMaterial You colors extracted in ${elapsed}ms" \
        -t 3000

    echo "Total time: ${elapsed}ms"
}
pywalfox update

main "$@"

hl.monitor({
    output   = "eDP-1",
    mode     = "1366x768@60",
    position = "0x0",
    scale    = "1",
})

local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "./.config/rofi/type-2/launcher.sh"
local screenshot  = "hyprshot -m region --raw | satty --filename - --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H%M%S').png"

hl.on("hyprland.start", function () 
    hl.exec_cmd("waybar &")
    hl.exec_cmd("swaync &")
    hl.exec_cmd("hyprctl setcursor 24 macos")
    hl.exec_cmd("awww-daemon &")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)

hl.env("LIBVA_DRIVER_NAME", "i915")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_SCALING_FACTOR","1")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "intel-drm")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 9,
        border_size = 3,
        col = {
            active_border   = { colors = {"rgba(99999999)", "rgba(99999999)", "rgba(99999999)"}, angle = 45 },
            inactive_border = "rgba(12121212)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding       = 0,
        rounding_power = 0,
        active_opacity   = 0.95,
        inactive_opacity = 0.95,
        shadow = {
            enabled      = false,
            range        = 1,
            render_power = 2,
            color        = 0x44000000,
            
        },

        blur = {
        enabled = true,
        size = 4,
        passes = 4,
        vibrancy = 0.95,       
        brightness = 1.4,        
        contrast = 1.3,        
        new_optimizations = true, 
        ignore_opacity = true,
        xray = false,
	},
    },
    animations = {
        enabled = true,
    },
})

hl.curve("md3_standard",   { type = "bezier", points = { {0.2, 0.0}, {0, 1.0} } })
hl.curve("md3_decel",      { type = "bezier", points = { {0.05, 0.7}, {0.1, 1.0} } })
hl.curve("md3_accel",      { type = "bezier", points = { {0.3, 0.0}, {0.8, 0.15} } })
hl.curve("md3_overshoot",  { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.1} } })

hl.animation({ leaf = "global",        enabled = true,  speed = 4,    bezier = "md3_standard" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 5,    bezier = "md3_overshoot" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 5,    bezier = "md3_decel",      style = "popin 80%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 4,    bezier = "md3_accel",      style = "popin 80%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 3,    bezier = "md3_decel" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 3,    bezier = "md3_accel" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 6,    bezier = "md3_decel",      style = "slide" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    misc = {
        force_default_wallpaper = 0,
	vrr = 1,
	disable_hyprland_logo   = true,
    },
})

hl.config({
    input = {
        kb_layout  = "us,ara",
        kb_variant = "",
        kb_model   = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
        disable_while_typing = true,            
        natural_scroll = true,
        },
    },
})

local mainMod = "SUPER"
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("killall waybar swaync; waybar & swaync"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshot))
hl.bind(mainMod .. " + O", hl.dsp.window.float())
hl.bind(mainMod .. " + SHIFT + O", function()
    hl.dispatch(hl.dsp.window.float()) 
    hl.dispatch(hl.dsp.window.pin())
end)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen("0"))
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen("1"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("sh ~/.config/waybar/scripts/waybar_switch.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/wal.sh"))
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), "Volume up")
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), "Volume down")
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), "Mute")
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), "Mute microphone")
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness -5"), "Brightness down (XF86)")
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness +5"), "Brightness up (XF86)")
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end


hl.window_rule({
    name  = "satty",
    match = { class = "com.gabm.satty" },
    float = true,
    center = true,
    size   = { 850, 550 },
})
hl.window_rule({
    name   = "wiremix",
    match  = { class = "wiremix" },
    float  = true,
    size   = { 900, 600 }, 
    center = true,
})
hl.window_rule({
    name   = "impala",
    match  = { class = "impala" },
    float  = true,
    size   = { 850, 550 }, 
    center = true,
})

hl.window_rule({
    name   = "bluetuith",
    match  = { class = "bluetuith" },
    float  = true,
    size   = { 850, 550 }, 
    center = true,
})
hl.layer_rule({
    name = "rofi-popup",
    match = { namespace = "rofi" },
    animation = "slide bottom",
    dim_around = true
})

hl.layer_rule({
    name = "notification-animations",
    match = { namespace = "swaync-control-center" },
    animation = "slide top"
})

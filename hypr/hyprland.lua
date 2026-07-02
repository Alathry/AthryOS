hl.monitor({
    output   = "eDP-1",
    mode     = "1366x768@60.00300",
    position = "0x0",
    scale    = "1",
})

local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "./.config/rofi/launcher.sh"
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
hl.env("VK_DRIVER_FILES", "/usr/share/vulkan/icd.d/intel_hasvk_icd.json")
hl.env("MESA_LOADER_DRIVER_OVERRIDE", "iris")
hl.env("LIBVA_DRIVER_NAME", "i965")
hl.env("ANV_ENABLE_PIPELINE_CACHE", "1")
hl.env("TACO_SHADERS_OPTIMIZE", "1")
hl.env("INTEL_SHADER_COMPILER_ENABLE_FTZ", "1") 
hl.env("MESA_VK_ANTI_LAG", "1")
hl.env("MESA_VK_WSI_PRESENT_MODE", "immediate")
hl.env("ALLOW_ASYNC_BUFFER_SHARING", "1")
hl.env("MESA_DEBUG", "silent")
hl.env("vblank_mode", "0") 
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_SCALE", "1")
hl.env("QT_SCALING_FACTOR", "1")
hl.config({
    general = {
	gaps_in  = 4,
        gaps_out = 9,
        border_size = 0,
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding       = 4,
        rounding_power = 4,
        active_opacity   = 1.00,
        inactive_opacity = 1.00,

        blur = {
        enabled = false,
        new_optimizations = true,
	},
    },
    animations = {
        enabled = true,
    },
})
hl.curve("m3_standard", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })
hl.curve("m3_decel",    { type = "bezier", points = { {0.05, 0.7}, {0.1, 1.0} } })
hl.curve("m3_accel",    { type = "bezier", points = { {0.3,  0.0}, {0.8, 0.15} } })
hl.curve("m3_linear",   { type = "bezier", points = { {0.0,  0.0}, {1.0, 1.0} } })
hl.curve("m3_spring",   { type = "bezier", points = { {0.34, 1.56}, {0.64, 1.0} } })
hl.curve("m3_bounce",   { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("m3_menu",     { type = "bezier", points = { {0.1,  1.0}, {0.0, 1.0} } })
hl.animation({ leaf = "global", enabled = true, speed = 1.0, bezier = "m3_standard" })
hl.animation({ leaf = "windows",    enabled = true, speed = 1.0, bezier = "m3_standard" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.5, bezier = "m3_decel", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.0, bezier = "m3_accel", style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.0, bezier = "m3_standard", style = "slide" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 3.0, bezier = "m3_standard" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 3.0, bezier = "m3_accel" })
hl.animation({ leaf = "border",     enabled = true, speed = 2.0, bezier = "m3_standard" })
hl.animation({ leaf = "layers",     enabled = true, speed = 1.0, bezier = "m3_standard" })
hl.animation({ leaf = "layersIn",   enabled = true, speed = 3.5, bezier = "m3_decel", style = "slide" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 3.0, bezier = "m3_accel", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5.0, bezier = "m3_bounce", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 4.5, bezier = "m3_decel", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 4.0, bezier = "m3_accel", style = "slidevert" })
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    misc = {
        force_default_wallpaper = 0,
	vrr = true,
	vrr = 1,
	disable_hyprland_logo   = true,
	disable_splash_rendering = true,
    },
})

hl.config({
    input = {
        kb_layout   = "us,ara",
        kb_variant  = "",
        kb_model    = "",
        kb_options  = "grp:alt_shift_toggle",
        kb_rules    = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            disable_while_typing = true,            
            natural_scroll = true,
        },
    },
    
    cursor = {
        no_hardware_cursors = true
    }, 
})
local mainMod = "SUPER"
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("killall waybar swaync; waybar & swaync"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("omniglyph"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("sh .config/rofi/poweroff.sh"))
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
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("localsend"))
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
hl.window_rule({
    name   = "Emoji Manager",
    match  = { class = "dev.anishroy.omniglyph" },
    float  = true,
    size   = { 450, 500 }, 
    move   = { "100%-450", "40" },
    pin    = true,
})
hl.layer_rule({
    name = "rofi-popup",
    match = { namespace = "rofi" },
    animation = "slide bottom"
})
hl.layer_rule({
    name = "notification-animations",
    match = { namespace = "swaync-control-center" },
    animation = "slide top"
})
hl.config({
    xwayland = {
        use_nearest_neighbor = true,
        force_zero_scaling = true,
    }
})

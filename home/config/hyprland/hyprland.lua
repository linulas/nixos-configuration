------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/configuring/core/monitors/
-- Matched by description instead of connector name (DP-2/HDMI-A-3/...),
-- since connector names can change between boots/kernel updates.
-- NOTE: single "#" here. The old .conf parser treated "#" as a comment start,
-- so it had to be escaped as "##"; the Lua parser takes the literal string.
local monRight = "desc:Ancor Communications Inc ROG PG279Q #ASO/PRLo3X3d"
local monLeft  = "desc:Ancor Communications Inc VC279 F5LMRS035943"

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.monitor({
    output   = monRight,
    mode     = "2560x1440@165",
    position = "1920x0",
    scale    = 1,
})

hl.monitor({
    output   = monLeft,
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

local browser     = "zen"
local fileManager = "thunar"
local menu        = "ulauncher"
local terminal    = "kitty"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.dispatch(hl.dsp.focus({ workspace = 1 }))
    hl.exec_cmd("hyprpaper")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.device({
    name       = "zmk-project-bt60-keyboard",
    kb_layout  = "us,se",
    -- Per-device kb_layout resets this device's options, so repeat them here
    -- or right Alt stays a plain Alt on the main keyboard.
    kb_options = "grp:ctrl_space_toggle,lv3:ralt_switch",
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint",  style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",        style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint",  style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",        style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear",  style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear",  style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear",  style = "fade" })

-- Odd workspaces on the right monitor, even ones on the left.
for i = 1, 10 do
    local onRight = (i % 2 == 1)
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = onRight and monRight or monLeft,
        default   = (i == 1 or i == 2) or nil,
    })
end

-- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/ for more
hl.config({
    dwindle = {
        -- NOTE: 0.56 removed "pseudotile"; pseudotiling is always available
        -- and toggled per-window (mainMod + X, below).
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/configuring/layouts/master-layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us,se",
        kb_variant = "",
        kb_model   = "",
        -- lv3:ralt_switch makes RIGHT Alt emit ISO_Level3_Shift (Mod5), which is a
        -- modifier distinct from left Alt. Hyprland's modmask has no L/R Alt
        -- split, so this is what makes "MOD5 + key" binds reachable.
        kb_options = "grp:ctrl_space_toggle,lv3:ralt_switch",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Workspace swipe is intentionally not enabled. 0.56 removed the
-- "gestures.workspace_swipe" toggle: gestures are now opt-in per gesture via
-- hl.gesture({...}), so declaring none leaves swiping off.

-- Example per-device config
-- See https://wiki.hypr.land/configuring/core/devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod      = "SUPER" -- Sets "Windows" key as main modifier

-- Right Alt. Must be "MOD5", not the old .conf name "Alt_R": Hyprland's modmask
-- has no left/right Alt split, so "Alt_R" silently parses as plain ALT (mask 8)
-- and would steal LEFT Alt, which we deliberately keep free for applications.
-- Right Alt only *emits* Mod5 because of lv3:ralt_switch in kb_options above.
local secondaryMod = "MOD5"

-- X11 keycodes for the letters used by the secondaryMod app binds.
--
-- These must be bound by keycode, not by letter. lv3:ralt_switch makes holding
-- right Alt request level 3 of the pressed key, and the "us" layout only
-- defines two levels (a/A) -- so "MOD5 + A" resolves to no keysym and never
-- fires. Matching the physical keycode sidesteps keysym resolution entirely.
-- Numbering is X11 (evdev + 8), verified empirically: code:38 is A.
local keycodes = {
    Q = 24, W = 25, E = 26, R = 27, T = 28,
    A = 38, S = 39, D = 40, F = 41, G = 42,
    Z = 52, X = 53, C = 54, V = 55, B = 56,
}

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + X",      hl.dsp.window.pseudo())
hl.bind(mainMod .. " + Z",      hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + C",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + W",      hl.dsp.exec_cmd("pkill waybar; waybar"))

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Move windows with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.window.move({ direction = "down" }))

-- Move windows between monitors
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ monitor = "r" }))

-- Switch workspaces with mainMod + [0-9], move windows with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspaces 1-4 also on the home row keys
for i, key in ipairs({ "U", "I", "O", "P" }) do
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})


------------------------
---- PER-HOST APPS  ----
------------------------

-- Host-specific window rules and launcher binds. The shared helpers above are
-- passed along so apps.lua doesn't have to redefine them.
local ok, apps = pcall(require, "apps")
if ok then
    apps({
        browser      = browser,
        fileManager  = fileManager,
        terminal     = terminal,
        secondaryMod = secondaryMod,
        keycodes     = keycodes,
    })
end

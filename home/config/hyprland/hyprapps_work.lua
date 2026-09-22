-- Host-specific window rules and launcher binds (work machine).
-- Loaded from hyprland.lua via require("apps").

return function(opts)
    local browser      = opts.browser
    local fileManager  = opts.fileManager
    local terminal     = opts.terminal
    local secondaryMod = opts.secondaryMod
    local keycodes     = opts.keycodes

    local runOrFocus = "~/.config/hypr/run_or_focus_application.sh"

    hl.on("hyprland.start", function()
        hl.exec_cmd("waybar & hyprpaper")
    end)

    local function toWorkspace(name, class, workspace)
        hl.window_rule({
            name      = name,
            match     = { class = class },
            workspace = tostring(workspace),
        })
    end

    toWorkspace("spotify-ws", "^(.*Spotify.*)$",        2)
    toWorkspace("teams-ws",   "^(.*teams-for-linux.*)$", 4)
    toWorkspace("slack-ws",   "^(.*Slack.*)$",           4)

    -- Bind on the secondary modifier by physical keycode. See the keycodes table
    -- in hyprland.lua for why these cannot be bound by letter.
    local function secondaryBind(key, cmd)
        local code = assert(keycodes[key], "no keycode for " .. key)
        hl.bind(secondaryMod .. " + code:" .. code, hl.dsp.exec_cmd(cmd))
    end

    -- Open a URL in the browser, then focus it.
    local function browseTo(key, url)
        secondaryBind(key, browser .. " " .. url .. " && " .. runOrFocus .. " zen")
    end

    -- Focus an app if running, otherwise launch it.
    local function focusApp(key, ...)
        local args = table.concat({ ... }, " ")
        secondaryBind(key, runOrFocus .. " " .. args)
    end

    browseTo("Q", "https://www.figma.com/design/HyKNX9P1LP4hNrZ5DSvH2g/Openaid---Final-Design?node-id=8319-18203&t=JZipHFPrmyPEsKUL-1&fuid=768056389549170856")
    browseTo("W", "monkeytype.com")
    browseTo("E", "github.com")
    browseTo("R", "tasks.google.com")
    browseTo("T", "search.nixos.org/packages?channel=26.05")
    browseTo("C", "outlook.office.com/mail/")

    focusApp("A", "zen")
    focusApp("S", "Spotify", "spotify")
    focusApp("F", terminal)
    focusApp("G", fileManager)
    focusApp("Z", "teams-for-linux")
    focusApp("X", "Slack", "slack")
    focusApp("V", "obsidian")
    focusApp("B", "bruno")
end

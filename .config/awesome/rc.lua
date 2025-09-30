package.loaded["naughty.dbus"] = {}

pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- -----------------------------------------------------------------------------
-- Error handling (copied from default)

if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end


-- -----------------------------------------------------------------------------
-- Init.

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile
}


-- Setup monitors (copied from default).
awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, s, awful.layout.layouts[1])
end)

-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Default modkey (This is the super key).
local modkey = "Mod4"

beautiful.useless_gap = 3
beautiful.gap_single_client = true
local primary_screen = screen.primary
awful.screen.padding(primary_screen, {
    top = 2,
    left = 8,
    right = 8,
    bottom = 44
})

-- -----------------------------------------------------------------------------
-- Keybinds.

local globalkeys = gears.table.join(
-- Apps
    awful.key({ modkey, }, "t", function() awful.spawn("wezterm -e /home/alex/.config/tmux/apps/start_terminal.sh") end),
    awful.key({ modkey, }, "p", function() awful.spawn("rofi-pass") end),
    awful.key({ modkey, }, "d", function() awful.spawn("/home/alex/.config/rofi/apps.sh") end),
    awful.key({ modkey, }, "r", function() awful.spawn("wezterm -e /home/alex/.config/tmux/apps/start_newsboat.sh") end),
    awful.key({ modkey, }, "s", function() awful.spawn("/home/alex/.config/rofi/tmux.sh") end),
    awful.key({ modkey, }, "b", function() awful.spawn("zen") end),
    awful.key({ modkey, "Shift" }, "s", function() awful.spawn("flameshot gui") end),
    awful.key({ modkey, }, "m", function() awful.spawn("/home/alex/.config/polybar/scripts/dunst.sh") end),
    awful.key({ modkey, }, "n", function() awful.spawn("dunstctl close-all") end),

    -- Audio
    awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pamixer -i 5") end),
    awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pamixer -d 5") end),
    awful.key({}, "XF86AudioMute", function() awful.spawn("pamixer -t") end),

    -- Windows.
    awful.key({ modkey, }, "]", function() awful.layout.inc(1) end),
    awful.key({ modkey, }, "j", function() awful.client.focus.byidx(1) end),
    awful.key({ modkey, }, "k", function() awful.client.focus.byidx(-1) end),
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end),

    -- Other.
    awful.key({ modkey, "Control" }, "r", awesome.restart)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end)
    )
end

root.keys(globalkeys)

local clientkeys = gears.table.join(
    awful.key({ modkey }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end),

    awful.key({ modkey }, "q", function(c) c:kill() end),
    awful.key({ modkey }, "space", function(c)
        awful.client.floating.toggle()
        if c.floating then
            c.width = 1200
            c.height = 805
            awful.placement.centered()
        end
    end)
)

-- -----------------------------------------------------------------------------
-- Client stuff.

local clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Rules.
awful.rules.rules = {
    -- All clients.
    {
        rule = {},
        properties = {
            border_width         = beautiful.border_width,
            border_color         = beautiful.border_normal,
            focus                = awful.client.focus.filter,
            raise                = true,
            buttons              = clientbuttons,
            keys                 = clientkeys,
            screen               = awful.screen.preferred,
            placement            = awful.placement.no_overlap + awful.placement.no_offscreen,
            floating             = false,
            maximized_vertical   = false,
            maximized_horizontal = false,
            maximized            = false,
            sticky               = false,
            fullscreen           = false,
            size_hint_honor      = true,
        }
    },

    -- NOTE: Sometimes have to do this for force certain windows to float.
    -- (reload *with window open* required)
    {
        rule = { class = "Chromium-browser" },
        properties = {
            floating = false,
            maximized = false,
            maximized_vertical = false,
            maximized_horizontal = false,
        }
    },

    -- Floating clients.
    {
        rule_any = {
            type = {},
            class = {
                "Gcr-prompter"
            },
            role = {
                "Popup"
            },
        },
        properties = {
            floating = true,
        },
        callback = awful.placement.centered
    },
}

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- New floating windows in the center.
    if c.floating and context == "new" then
        c.placement = awful.placement.centered + awful.placement.no_overlap
    end
end)


client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)


-- -----------------------------------------------------------------------------
-- Third party.
awful.spawn("/home/alex/.scripts/startup.sh")

-- -----------------------------------------------------------------------------

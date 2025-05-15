pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

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

-- Setup monitors (copied from default).
awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
end)
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"


-- -----------------------------------------------------------------------------
-- Layout.

local primary_screen = screen.primary
awful.screen.padding(primary_screen, {
    top = 43,
    left = 8,
    right = 8,
    bottom = 1
})

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile
}


-- -----------------------------------------------------------------------------
-- Keybinds.

local globalkeys = gears.table.join(
-- Apps
    awful.key({ modkey, }, "t", function() awful.spawn("wezterm -e /home/alex/.config/tmux/apps/start_terminal.sh") end),
    awful.key({ modkey, }, "d", function() awful.spawn("/home/alex/.config/rofi/launcher/run.sh") end),
    awful.key({ modkey, }, "r", function() awful.spawn("wezterm -e /home/alex/.config/tmux/apps/start_newsboat.sh") end),
    awful.key({ modkey, }, "f", function() awful.spawn("wezterm -e tmux new-session -n \"files\" yazi") end),
    awful.key({ modkey, }, "b", function() awful.spawn("zen") end),

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
    awful.key({ modkey, "Shift" }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end),

    awful.key({ modkey }, "q", function(c) c:kill() end),
    awful.key({ modkey }, "space", awful.client.floating.toggle)
)

-- -----------------------------------------------------------------------------
-- Client stuff.

clientbuttons = gears.table.join(
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
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            keys = clientkeys,
            floating = false
        }
    },

    -- Floating clients.
    -- {
    --     rule_any = {
    --         instance = {
    --             "DTA",   -- Firefox addon DownThemAll.
    --             "copyq", -- Includes session name in class.
    --             "pinentry",
    --         },
    --         class = {
    --             "Arandr",
    --             "Blueman-manager",
    --             "Gpick",
    --             "Kruler",
    --             "MessageWin",  -- kalarm.
    --             "Sxiv",
    --             "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
    --             "Wpa_gui",
    --             "veromix",
    --             "xtightvncviewer" },
    --
    --         -- Note that the name property shown in xprop might be set slightly after creation of the client
    --         -- and the name shown there might not match defined rules here.
    --         name = {
    --             "Event Tester", -- xev.
    --         },
    --         role = {
    --             "AlarmWindow",   -- Thunderbird's calendar.
    --             "ConfigManager", -- Thunderbird's about:config.
    --             "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
    --         }
    --     },
    --     properties = { floating = true }
    -- }
}

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)


client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)


-- -----------------------------------------------------------------------------
-- Third party.

awful.spawn("/home/alex/.scripts/startup.sh")


-- -----------------------------------------------------------------------------

-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
gears = require("gears")
awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
-- naughty = require("naughty")
-- Declarative object management
ruled = require("ruled")
menubar = require("menubar")
vicious = require("vicious")
-- local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
-- naughty.connect_signal("request::display_error", function(message, startup)
--     naughty.notification {
--         urgency = "critical",
--         title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
--         message = message
--     }
-- end)
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
local theme_path = string.format("%s/.config/awesome/theme/theme.lua", os.getenv("HOME"))
beautiful.init(theme_path)
-- beautiful.gap_single_client = false

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
mod = "Mod4"
modalt = "Mod1"

-- Terminal
terminal = os.getenv("TERMINAL") or "xterm"
-- Editor
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	-- {
	-- 	"hotkeys",
	-- 	function()
	-- 		hotkeys_popup.show_help(nil, awful.screen.focused())
	-- 	end,
	-- },
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}
mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
	},
})

-- mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Tag layout
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts({
		awful.layout.suit.tile,
		-- awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		-- awful.layout.suit.tile.top,
		awful.layout.suit.fair,
		awful.layout.suit.fair.horizontal,
		-- awful.layout.suit.spiral,
		-- awful.layout.suit.spiral.dwindle,
		awful.layout.suit.max,
		awful.layout.suit.max.fullscreen,
		awful.layout.suit.magnifier,
		awful.layout.suit.corner.nw,
		awful.layout.suit.floating,
	})
end)
-- }}}

-- {{{ Wibar

function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

-- Create a textclock widget
textclock = wibox.widget.textclock("%a %Y-%m-%d [%H:%M:%S]", 1)
screen.connect_signal("request::desktop_decoration", function(s)
	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	-- s.mypromptbox = awful.widget.prompt()

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox({
		screen = s,
		buttons = {
			awful.button({}, 1, function()
				awful.layout.inc(1)
			end),
			awful.button({}, 3, function()
				awful.layout.inc(-1)
			end),
			awful.button({}, 4, function()
				awful.layout.inc(-1)
			end),
			awful.button({}, 5, function()
				awful.layout.inc(1)
			end),
		},
	})

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = {
			awful.button({}, 1, function(t)
				t:view_only()
			end),
			awful.button({ mod }, 1, function(t)
				if client.focus then
					client.focus:move_to_tag(t)
				end
			end),
			awful.button({}, 3, awful.tag.viewtoggle),
			awful.button({ mod }, 3, function(t)
				if client.focus then
					client.focus:toggle_tag(t)
				end
			end),
			awful.button({}, 4, function(t)
				awful.tag.viewprev(t.screen)
			end),
			awful.button({}, 5, function(t)
				awful.tag.viewnext(t.screen)
			end),
		},
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = {
			awful.button({}, 1, function(c)
				c:activate({ context = "tasklist", action = "toggle_minimization" })
			end),
			awful.button({}, 3, function()
				awful.menu.client_list({ theme = { width = 250 } })
			end),
			awful.button({}, 4, function()
				awful.client.focus.byidx(-1)
			end),
			awful.button({}, 5, function()
				awful.client.focus.byidx(1)
			end),
		},
	})

	textbox = wibox.widget.textbox
	cpu_monitor = vicious.register(textbox(), vicious.widgets.cpu, "CPU=$1", 1)
	-- cpu_monitor = awful.widget.watch(
	-- 	"sh -c \"sensors | grep Package | cut -d' ' -f5 | cut -b 2-\"",
	-- 	-- 'sh -c "sensors | grep Package | cut -d\' \' -f5 | sed \'s/+\\(.*\\)\\..*/\\1/\'"',
	-- 	5,
	-- 	function(widget, stdout)
	-- 		widget:set_text("CPU=" .. stdout)
	-- 	end
	-- )
	ram_monitor = vicious.register(textbox(), vicious.widgets.mem, "RAM=$2", 1)
	-- ram_monitor = awful.widget.watch(
	-- 	"sh -c \"free -m | awk '/^Mem/ {print $3}'\"",
	-- 	5,
	-- 	function(widget, stdout)
	-- 		widget:set_text("RAM=" .. stdout)
	-- 	end
	-- )

	-- Create the wibox
	s.mywibox = awful.wibar({
		position = "top",
		screen = s,
		-- opacity = 0.95,
		height = 20,
		widget = {
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				-- mylauncher,
				s.mytaglist,
				-- s.mypromptbox,
				textbox("| "),
			},
			s.mytasklist, -- Middle widget
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				wibox.widget.systray(),
				textbox(" | "),
				cpu_monitor,
				textbox(" "),
				ram_monitor,
				textbox(" | "),
				textclock,
				textbox(" "),
				s.mylayoutbox,
			},
		},
	})
end)

-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
	awful.button({}, 4, awful.tag.viewprev),
	awful.button({}, 5, awful.tag.viewnext),
})
-- }}}

-- {{{ Key bindings

local wibox_preferred_visible = true
-- General Awesome keys
awful.keyboard.append_global_keybindings({
	-- 	awful.key({ mod }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	-- 	awful.key({ mod }, "w", function()
	-- 		mymainmenu:show()
	-- 	end, { description = "show main menu", group = "awesome" }),
	awful.key({ mod, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	-- 	awful.key({ mod, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
	-- 	awful.key({ mod }, "x", function()
	-- 		awful.prompt.run({
	-- 			prompt = "Run Lua code: ",
	-- 			textbox = awful.screen.focused().mypromptbox.widget,
	-- 			exe_callback = awful.util.eval,
	-- 			history_path = awful.util.get_cache_dir() .. "/history_eval",
	-- 		})
	-- 	end, { description = "lua execute prompt", group = "awesome" }),
	-- 	awful.key({ mod }, "Return", function()
	-- 		awful.spawn(terminal)
	-- 	end, { description = "open a terminal", group = "launcher" }),
	-- 	awful.key({ mod }, "r", function()
	-- 		awful.screen.focused().mypromptbox:run()
	-- 	end, { description = "run prompt", group = "launcher" }),
	-- 	awful.key({ mod }, "p", function()
	-- 		menubar.show()
	-- 	end, { description = "show the menubar", group = "launcher" }),
	awful.key({ mod }, "b", function()
		wibox_preferred_visible = not wibox_preferred_visible
		for s in screen do
			s.mywibox.visible = wibox_preferred_visible
			if s.mybottomwibox then
				s.mybottomwibox.visible = wibox_preferred_visible
			end
		end
	end, { description = "toggle wibox", group = "awesome" }),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ mod, modalt }, "h", function()
		awful.client.focus.bydirection("left")
	end, { description = "focus next by index", group = "client" }),
	awful.key({ mod, modalt }, "j", function()
		awful.client.focus.bydirection("down")
	end, { description = "focus next by index", group = "client" }),
	awful.key({ mod, modalt }, "k", function()
		awful.client.focus.bydirection("up")
	end, { description = "focus next by index", group = "client" }),
	awful.key({ mod, modalt }, "l", function()
		awful.client.focus.bydirection("right")
	end, { description = "focus next by index", group = "client" }),
	awful.key({ mod }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ mod }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ mod }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),
	awful.key({ mod, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ mod, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ mod, "Control" }, "w", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:activate({ raise = true, context = "key.unminimize" })
		end
	end, { description = "restore minimized", group = "client" }),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ mod, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ mod, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	-- awful.key({ mod }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ mod }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ mod }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	-- awful.key({ mod, "Shift" }, "h", function()
	-- 	awful.tag.incnmaster(1, nil, true)
	-- end, { description = "increase the number of master clients", group = "layout" }),
	-- awful.key({ mod, "Shift" }, "l", function()
	-- 	awful.tag.incnmaster(-1, nil, true)
	-- end, { description = "decrease the number of master clients", group = "layout" }),
	-- awful.key({ mod, "Control" }, "h", function()
	-- 	awful.tag.incncol(1, nil, true)
	-- end, { description = "increase the number of columns", group = "layout" }),
	-- awful.key({ mod, "Control" }, "l", function()
	-- 	awful.tag.incncol(-1, nil, true)
	-- end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ mod }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ mod, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),
})

-- Tags related keybindings
-- awful.keyboard.append_global_keybindings({
-- 	awful.key({ mod }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
-- 	awful.key({ mod }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
-- 	awful.key({ mod }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
-- })

awful.key.keygroups.numrow[10][2] = 10 -- makes "0" on number row return "10", for 10 tags.

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { mod },
		keygroup = awful.key.keygroup.NUMROW,
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	}),
	awful.key({
		modifiers = { mod, "Control" },
		keygroup = "numrow",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end,
	}),
	awful.key({
		modifiers = { mod, "Shift" },
		keygroup = "numrow",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	}),
	awful.key({
		modifiers = { mod, "Control", "Shift" },
		keygroup = "numrow",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end,
	}),
	awful.key({
		modifiers = { mod },
		keygroup = "numpad",
		on_press = function(index)
			local t = awful.screen.focused().selected_tag
			if t then
				t.layout = t.layouts[index] or t.layout
			end
		end,
	}),
})

client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({}, 1, function(c)
			c:activate({ context = "mouse_click" })
		end),
		awful.button({ mod }, 1, function(c)
			c:activate({ context = "mouse_click", action = "mouse_move" })
		end),
		awful.button({ mod }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" })
		end),
	})
end)

client.connect_signal("request::default_keybindings", function()
	awful.keyboard.append_client_keybindings({
		awful.key({ mod }, "f", function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end, { description = "toggle fullscreen", group = "client" }),
		awful.key({ mod }, "q", function(c)
			c:kill()
		end, { description = "close", group = "client" }),
		awful.key(
			{ mod, "Shift" },
			"f",
			awful.client.floating.toggle,
			{ description = "toggle floating", group = "client" }
		),
		awful.key({ mod, "Control" }, "Return", function(c)
			c:swap(awful.client.getmaster())
		end, { description = "move to master", group = "client" }),
		awful.key({ mod }, "o", function(c)
			c:move_to_screen()
		end, { description = "move to screen", group = "client" }),
		awful.key({ mod }, "t", function(c)
			c.ontop = not c.ontop
		end, { description = "toggle keep on top", group = "client" }),
		awful.key({ mod }, "w", function(c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end, { description = "minimize", group = "client" }),
		awful.key({ mod }, "e", function(c)
			c.maximized = not c.maximized
			c:raise()
		end, { description = "(un)maximize", group = "client" }),
		awful.key({ mod, "Control" }, "e", function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end, { description = "(un)maximize vertically", group = "client" }),
		awful.key({ mod, "Shift" }, "e", function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end, { description = "(un)maximize horizontally", group = "client" }),
	})
end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
	-- All clients will match this rule.
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	})

	-- Floating clients.
	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			instance = { "copyq", "pinentry" },
			class = {
				-- "Arandr",
				-- "Blueman-manager",
				"Gpick",
				-- "Kruler",
				"Sxiv",
				"Nsxiv",
				"feh",
				"Nm-connection-editor",
				-- "Tor Browser",
				-- "Wpa_gui",
				-- "veromix",
				-- "xtightvncviewer",
			},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				-- "AlarmWindow", -- Thunderbird's calendar.
				-- "ConfigManager", -- Thunderbird's about:config.
				-- "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	})

	-- Add titlebars to normal clients and dialogs
	ruled.client.append_rule({
		id = "titlebars",
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = nil },
	})

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- ruled.client.append_rule {
	--     rule       = { class = "Firefox"     },
	--     properties = { screen = 1, tag = "2" }
	-- }
end)
-- }}}

-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = {
		awful.button({}, 1, function()
			c:activate({ context = "titlebar", action = "mouse_move" })
		end),
		awful.button({}, 3, function()
			c:activate({ context = "titlebar", action = "mouse_resize" })
		end),
	}

	awful.titlebar(c).widget = {
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				halign = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	}
end)
-- }}}

-- {{{ Notifications

-- ruled.notification.connect_signal("request::rules", function()
-- 	-- All notifications will match this rule.
-- 	ruled.notification.append_rule({
-- 		rule = {},
-- 		properties = {
-- 			screen = awful.screen.preferred,
-- 			implicit_timeout = 5,
-- 		},
-- 	})
-- end)

-- naughty.connect_signal("request::display", function(n)
--     naughty.layout.box { notification = n }
-- end)

-- }}}

-- {{{ Window Behavior

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:activate({ context = "mouse_enter", raise = false })
end)

-- Workaround a bug with applications like feh and sxiv requesting fullscreen,
-- and ending up with a "maximized" view with a visible bar.
client.connect_signal("property::fullscreen", function(c)
	if c.fullscreen then
		gears.timer.delayed_call(function()
			if c.valid then
				c:geometry(c.screen.geometry)
			end
		end)
	end
end)

-- Remove gaps and borders from max/fullscreen layouts and modes :)
beautiful.gap_single_client = true

function gap_filler(t)
	local layout = awful.layout.get()["name"]
	local clients = screen[awful.screen.focused()].clients
	local tiled_clients_lookup = {}
	if t.maximized then
		t.border_width = 0
	else
		for _, v in pairs(screen[awful.screen.focused()].tiled_clients) do
			tiled_clients_lookup[v] = true
		end
		if layout == "max" or layout == "fullscreen" then
			t.useless_gap = 0
			for _, c in ipairs(clients) do
				if tiled_clients_lookup[c] ~= nil then
					c.border_width = 0
				else
					c.border_width = beautiful.border_width
				end
			end
		else
			t.useless_gap = beautiful.useless_gap
			for _, c in ipairs(clients) do
				if c.maximized ~= true then
					c.border_width = beautiful.border_width
				end
			end
		end
	end
end

tag.connect_signal("property::layout", gap_filler)
tag.connect_signal("property::selected", gap_filler)
client.connect_signal("request::manage", gap_filler)
client.connect_signal("property::maximized", gap_filler)
client.connect_signal("property::fullscreen", gap_filler)
client.connect_signal("property::floating", gap_filler)

-- Use normal border color with single clients
client.connect_signal("focus", function(c)
	if #awful.screen.focused().clients == 1 then
		c.border_color = beautiful.border_color_normal
	else
		c.border_color = beautiful.border_color_active
	end
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_color_normal
end)

-- Hide the bar in fullscreen modes (if a client is on screen)
function fullscreen_bar()
	local s = awful.screen.focused()
	local clients = screen[awful.screen.focused()].clients

	function check_fullclient()
		for k,v in ipairs(clients) do
			if screen[s].clients[k].fullscreen == true then
				return true
			end
		end
		return false
	end
	if next(clients) ~= nil then
		if awful.layout.get()["name"] == "fullscreen" or check_fullclient()
		then
			s.mywibox.visible = false
		else
			s.mywibox.visible = wibox_preferred_visible
		end
	else
		s.mywibox.visible = wibox_preferred_visible
	end
end

tag.connect_signal("property::layout", fullscreen_bar)
tag.connect_signal("property::selected", fullscreen_bar)
client.connect_signal("property::fullscreen", fullscreen_bar)
client.connect_signal("request::manage", fullscreen_bar)
client.connect_signal("request::unmanage", fullscreen_bar)

-- }}}

print("NUTS HANG BELOW:")
-- sync clock (within like 10ms)
os.execute("i=1; while true; do [ $i -eq 1 ] && var=$(date +%S) && i=$((i + 1)); [ $(date +%S) -ne $var ] && break; done")
textclock:force_update()

local a = require'wezterm'.action

return {
	-- scroll
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'NONE',
    action = a.ScrollByLine(-1),
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'NONE',
    action = a.ScrollByLine(1),
  },

	-- open hyperlinks
	-- account for this: https://wezfurlong.org/wezterm/config/lua/config/bypass_mouse_reporting_modifiers.html
	{
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = a.OpenLinkAtMouseCursor,
  },
  -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = a.Nop,
  },
}

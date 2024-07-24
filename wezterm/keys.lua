local w = require"wezterm"
local k = {
	-- create new window
	{
		key = 'n',
		mods = 'CTRL|SHIFT',
		action = w.action.SpawnWindow,
	},
	{
		key = 'n',
		mods = 'SUPER',
		action = w.action.SpawnWindow,
	},

	-- hide window
	{
		key = 'm',
		mods = 'SUPER',
		action = w.action.Hide,
	},

	-- change font size
	{
		key = '-',
		mods = 'SUPER',
		action = w.action.DecreaseFontSize,
	},
	{
		key = '=',
		mods = 'SUPER',
		action = w.action.IncreaseFontSize,
	},

	-- toggle full screen
	{
		key = 'Enter',
		mods = 'ALT',
		action = w.action.ToggleFullScreen,
	},

	-- reload configuration
	{
		key = 'R',
		mods = 'CTRL|SHIFT',
		action = w.action.ReloadConfiguration,
	},
	{
		key = 'r',
		mods = 'SUPER',
		action = w.action.ReloadConfiguration,
	},
}

return k

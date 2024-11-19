local a = require"wezterm".action

return {
	-- create new window
	{
		key = 'n',
		mods = 'CTRL|SHIFT',
		action = a.SpawnWindow,
	},
	{
		key = 'n',
		mods = 'SUPER',
		action = a.SpawnWindow,
	},

	-- hide window
	{
		key = 'm',
		mods = 'SUPER',
		action = a.Hide,
	},

	-- change font size
	{
		key = '-',
		mods = 'CTRL',
		action = a.DecreaseFontSize,
	},
	{
		key = '=',
		mods = 'CTRL',
		action = a.IncreaseFontSize,
	},

	-- toggle full screen
	{
		key = 'Enter',
		mods = 'ALT',
		action = a.ToggleFullScreen,
	},

	-- reload configuration
	{
		key = 'R',
		mods = 'CTRL|SHIFT',
		action = a.ReloadConfiguration,
	},
	{
		key = 'r',
		mods = 'SUPER',
		action = a.ReloadConfiguration,
	},

	-- copy
	{
		key = 'c',
		mods = 'CTRL|SHIFT',
		action = a.CopyTo'Clipboard',
	},
	{
		key = 'c',
		mods = 'SUPER',
		action = a.CopyTo'Clipboard',
	},
	{
		key = 'Copy',
		action = a.CopyTo'Clipboard',
	},
	-- paste
	{
		key = 'v',
		mods = 'CTRL|SHIFT',
		action = a.PasteFrom'Clipboard',
	},
	{
		key = 'v',
		mods = 'SUPER',
		action = a.PasteFrom'Clipboard',
	},
	{
		key = 'Paste',
		action = a.PasteFrom'Clipboard',
	},

	-- launcher menu
	{
		key = 'l',
		mods = 'SUPER',
		action = a.ShowLauncher,
	},

	-- quit
	{
		key = 'q',
		mods = 'SUPER',
		action = a.QuitApplication },
}

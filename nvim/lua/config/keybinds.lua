-- This is a global keybinds file. The plugin-specific keybinds live in lua/plugin.lua or ftplugin/
local wk = require"which-key"

-- NO ARROW KEYS, U MFCKER! heheheha!!1!
wk.add{
	mode = { "n", "v" },
	{ '<Up>',    '<Nop>', hidden = true },
	{ '<Down>',  '<Nop>', hidden = true },
	{ '<Left>',  '<Nop>', hidden = true },
	{ '<Right>', '<Nop>', hidden = true },
}

-- some good shortcuts
wk.add{
	mode = { "n", "v" },
	{ "<leader>q", "<cmd>q<cr>", desc = "Quit",
		icon = {icon = '', color = 'red'},
	},
	{ "<leader>w", "<cmd>w<cr>", desc = "Write",
		icon = {icon = '', color = 'green'},
	},
}

wk.add{
	mode = { "n", "v" },
	{ "<leader>M", group = "Managers",
		icon = {icon = '', color = 'cyan'},
	},
	{ "<leader>Ml", "<cmd>Lazy<cr>", desc = "Lazy",
		icon = {icon = '󰒲', color = 'purple'},
	},
}

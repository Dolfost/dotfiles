-- this is a global keybinds file. The plugin-specific keybinds live in lua/plugins/ or ftplugin/
local wk = require"which-key"

-- NO ARROW KEYS, U MFCKER! heheheha!!1!
wk.add{
	mode = { "n", "v" },
	{ '<Up>',    '<Nop>', hidden = true },
	{ '<Down>',  '<Nop>', hidden = true },
	{ '<Left>',  '<Nop>', hidden = true },
	{ '<Right>', '<Nop>', hidden = true },
}

-- managers
wk.add{
	mode = { "n", "v" },
	{ "<leader>M", group = "Managers",
		icon = {icon = '', color = 'cyan'},
	},
	{ "<leader>Ml", "<cmd>Lazy<cr>", desc = "Lazy",
		icon = {icon = '󰒲', color = 'purple'},
	},
}

-- disable default neovim lsp binds
vim.keymap.del('n', 'grn')
vim.keymap.del('n', 'gra')
vim.keymap.del('n', 'grr')
vim.keymap.del('n', 'gri')
vim.keymap.del('n', 'gO')

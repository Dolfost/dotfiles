return {
	'nvim-lualine/lualine.nvim',

	dependencies = {'nvim-tree/nvim-web-devicons'},

	opts = {
		options = {
			icons_enabled = true,
			theme = 'auto',
			component_separators = { left = '', right = ''},
			section_separators = { left = '', right = ''},
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			ignore_focus = {},
			always_divide_middle = true,
			globalstatus = false,
			refresh = {
				statusline = 100,
				tabline = 100,
				winbar = 100,
			}
		},
		sections = {
			lualine_a = {'mode'},
			lualine_b = {'branch', 'diff', 'diagnostics'},
			lualine_c = {'filename'},
			lualine_x = {'encoding', 'fileformat', 'filetype'},
			lualine_y = {'progress'},
			lualine_z = {'location'},
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {'filename'},
			lualine_x = {'location'},
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {
			lualine_a = {
				{
					'tabs',
					mode = 2,
					max_length = vim.o.columns,
					symbols = {
						modified = '󰷥 ',
						alternate_file = ' ',
						directory = 'a',
					},
					path = 0
				}
			}
		},

		winbar = {},
		inactive_winbar = {},
		extensions = {'fugitive', 'fzf', 'man', 'lazy', 'quickfix', 'neo-tree'},
	},
}

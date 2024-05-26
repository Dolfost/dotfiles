return {
	{
		'nvim-telescope/telescope.nvim',

		lazy = false,
		tag = '0.1.5',
		cmd = {
			'Telescope',
		},

		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-ui-select.nvim',
		},

		init = function ()
			local wk = require"which-key"

			wk.register({
				t = {
					name = "Telescope",
					f = {"<cmd>Telescope find_files<cr>", "Find File" },
					g = { "<cmd>Telescope live_grep<cr>", "Live grep" },
					b = { "<cmd>Telescope buffers<cr>",   "Buffres" },
					h = { "<cmd>Telescope help_tags<cr>", "Help tags" },
					s = { "<cmd>Telescope treesitter<cr>", "Treesitter symbols" },
					o = { "<cmd>Telescope oldfiles<cr>", "List recentry opened files" },
					c = { "<cmd>Telescope colorscheme<cr>", "List avaliable colorschemes" },
					m = { "<cmd>Telescope marks<cr>", "List vim marks" },
					r = { "<cmd>Telescope registers<cr>", "List vim registers and their contents" },
					j = { "<cmd>Telescope jumplist<cr>", "List vim jumplist" },
					['/'] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Buffer fuzzy search" },
				},
			}, { prefix = "<leader>" })
		end,

		config = function()
			local telescope = require("telescope")

			local opts = {
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
				defaults = {
					layout_strategy = "vertical",
				},
			}

			telescope.setup(opts)
			telescope.load_extension('ui-select')
		end,
	},
}

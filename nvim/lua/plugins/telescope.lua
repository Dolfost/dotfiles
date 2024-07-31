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
			wk.add{
				{ "<leader>t", group = "Telescope" },
				{ "<leader>tf", "<cmd>Telescope find_files<cr>",
					desc = "Find File",
					icon = {icon = " ", color = 'green'}, },
				{ "<leader>tg",  "<cmd>Telescope live_grep<cr>",
					desc = "Live grep",
					icon = {icon = "", color = 'purple'}, },
				{ "<leader>tb",  "<cmd>Telescope buffers<cr>",
					desc =   "Buffres",
					icon = {icon = "󰈔 ", color = 'purple'},
				{ "<leader>th",  "<cmd>Telescope help_tags<cr>",
					desc = "Help tags",
					icon = {icon = "󰋖", color = 'purple'},
				},
				{ "<leader>ts",  "<cmd>Telescope treesitter<cr>",
					desc = "Treesitter symbols",
					icon = {icon = "󰊕", color = 'purple'},
				},
				{ "<leader>to",  "<cmd>Telescope oldfiles<cr>",
					desc = "List recentry opened files",
					icon = {icon = " ", color = 'purple'},
				},
				{ "<leader>tc",  "<cmd>Telescope colorscheme enable_preview=true<cr>",
					desc = "List avaliable colorschemes",
					icon = {icon = " ", color = 'purple'},
				},
				{ "<leader>tm",  "<cmd>Telescope marks<cr>",
					desc = "List vim marks",
					icon = {icon = "", color = 'purple'}, },
				{ "<leader>tr",  "<cmd>Telescope registers<cr>",
					desc = "List vim registers and their contents",
					icon = {icon = "󰅍", color = 'purple'}, },
				},
				{ "<leader>tj",  "<cmd>Telescope jumplist<cr>",
					desc = "List vim jumplist",
					icon = {icon = "", color = 'green'}, },
				{ "<leader>t/",  "<cmd>Telescope current_buffer_fuzzy_find<cr>",
					desc = "Buffer fuzzy search",
					icon = {icon = " ", color = 'green'}, },
			}
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
					layout_strategy = "horizontal",
					mappings = {
						i = {
							['<C-s>'] = 'file_split',
							['<C-x>'] = false,
						},
					},
				},
			}


			telescope.setup(opts)
			telescope.load_extension('ui-select')
		end,
	},
}

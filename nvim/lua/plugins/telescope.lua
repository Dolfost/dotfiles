return {
	{
		'nvim-telescope/telescope.nvim',

		tag = '0.1.5',
		cmd = 'Telescope',
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find File" } },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>",  { desc = "Live grep" } },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>",    { desc = "Buffres" } },

			{ "<leader>fh", "<cmd>Telescope help_tags<cr>",  { desc = "Help tags" } },
		},
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-ui-select.nvim',
		},

		config = function()
			local telescope = require("telescope")
			-- local wk = require("which-key")

			local opts = {
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown {},
					},
				},
			}

			telescope.setup(opts)
			telescope.load_extension('ui-select')
		end,
	},
}

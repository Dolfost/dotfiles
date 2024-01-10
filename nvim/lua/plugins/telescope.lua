return {
	{
		'nvim-telescope/telescope.nvim',

		tag = '0.1.5',
		cmd = 'Telescope',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-ui-select.nvim',
		},


		config = function()
			local telescope = require("telescope")

			local opts = {
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown{},
					},
				},
			}

			telescope.setup(opts)
			telescope.load_extension('ui-select')
		end,
	},
}

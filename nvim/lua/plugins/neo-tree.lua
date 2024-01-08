return {
	{
		'nvim-neo-tree/neo-tree.nvim',

		branch = "v3.x",
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
			'MunifTanjim/nui.nvim',
			'3rd/image.nvim', -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		cmd = 'Neotree',


		opts = {
			window = {
				mappings = {
					["P"] = {"toggle_preview", config = { use_float = false, use_image_nvim = true}},
				}
			},

			default_component_configs = {
				git_status = {
					symbols = {
						-- Change type
						added     = "+", --  NOTE: you can set any of these to an empty string to not show them
						deleted   = "X",
						modified  = "",
						renamed   = "r",
						-- Status type
						untracked = "?",
						ignored   = "/",
						unstaged  = "u",
						staged    = "",
						conflict  = "",
					},
					align = "right",
				},
			},
		},
	},
}

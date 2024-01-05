require("neo-tree").setup({
	window = {
		mappings = {
			["P"] = {"toggle_preview", config = { use_float = false, use_image_nvim = true}},
		}
	},

	default_component_configs = {
		git_status = {
		  symbols = {
			-- Change type
			added     = "+", -- NOTE: you can set any of these to an empty string to not show them
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
})

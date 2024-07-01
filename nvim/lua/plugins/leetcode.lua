local leet_arg = "leetcode.nvim"

return {
	{
		"kawre/leetcode.nvim",

		lazy = leet_arg ~= vim.fn.argv()[1],
		build = ":TSUpdate html",
		dependencies = {
			{
				"nvim-telescope/telescope.nvim",
				dependencies = { "nvim-lua/plenary.nvim" },
			}, -- required by telescope
			"MunifTanjim/nui.nvim",

			-- optional
			"nvim-treesitter/nvim-treesitter",
			"rcarriga/nvim-notify",
			"nvim-tree/nvim-web-devicons",
			-- "3rd/image.nvim",
		},


		opts = {
			image_support = false,

			arg = leet_arg,
		},
	}
}

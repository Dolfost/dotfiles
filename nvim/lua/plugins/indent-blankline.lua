return {
	"lukas-reineke/indent-blankline.nvim",
	enabled = true,
	main = "ibl",

	opts = {
		debounce = 100,
		indent = {
			char = {"╎", "┆", "┊"},
			-- tab_char = nil,
			smart_indent_cap = true,
      highlight = { "Function", "Label", "Statement", "Exception" },
		},

		whitespace = {
			highlight = { "Whitespace", "NonText" }
		},

		scope = {
			char = {"│"},
			show_start = true,
			show_end = true,
			include = {
				node_type = {
					["*"] = {"*"},
				},
			}
		}
	}
}

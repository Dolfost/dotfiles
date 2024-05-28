--  BUG: 
--  Steps to reproduce:
--  	Install telescope
--  	Install indent-blankline.nvim
--  	Save vim session with :mksession (or obsession.nvim)
--  	Reopen nvim with this session
--  	Open the telescope 'find file'
--  After this you will be greeded with lua errors

return {
	"lukas-reineke/indent-blankline.nvim",
	enabled = true,
	main = "ibl",

	opts = {
		debounce = 200,
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

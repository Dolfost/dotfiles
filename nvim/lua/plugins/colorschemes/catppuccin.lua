return {
	"catppuccin/nvim",

	lazy = false,
	name = 'catppuccin',
	priority = 1000,

	opts = {
		flavour = "mocha", -- latte, frappe, macchiato, mocha
		background = { -- :h background
		light = "latte",
		dark = "mocha",
	},

	transparent_background = false, -- disables setting the background color.
	show_end_of_buffer = true, -- shows the '~' characters after the end of buffers
	term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
	dim_inactive = {
		enabled = false, -- dims the background color of inactive window
		shade = "dark",
		percentage = 0.15, -- percentage of the shade to apply to the inactive window
	},
	no_italic = false, -- Force no italic
	no_bold = false, -- Force no bold
	no_underline = false, -- Force no underline
	styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
	comments = { "italic" }, -- Change the style of comments
	conditionals = { "italic" },
	loops = { "italic" },
	functions = {},
	keywords = {},
	strings = { --[["italic"]] },
	variables = { --[["italic"]] },
	numbers = {},
	booleans = { "italic" },
	properties = {},
	types = { "bold" },
	operators = { "bold" },
},
custom_highlights = {},
integrations = {
	cmp = true,
	gitsigns = false,
	neotree = true,
	treesitter = true,
	notify = false,
	markdown = true,
	native_lsp = {
		enabled = true,
		virtual_text = {
			errors = { "italic" },
			hints = { "italic" },
			warnings = { "italic" },
			information = { "italic" },
		},
		underlines = {
			errors = { "underline" },
			hints = { "underline" },
			warnings = { "underline" },
			information = { "underline" },
		},
		inlay_hints = {
			background = true,
		},
	},
},
},
}

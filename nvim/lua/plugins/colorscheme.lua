return {
	{
		"catppuccin/nvim",

		lazy = true,
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
			loops = {"italic"},
			functions = {},
			keywords = {},
			strings = { --[["italic"]] },
			variables = { --[["italic"]] },
			numbers = {},
			booleans = { "italic" },
			properties = {},
			types = {"bold"},
			operators = {"bold"},
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
},

{
	'morhetz/gruvbox',
	lazy = true,

	config = function()
		vim.g.gruvbox_italic = 1
		vim.g.gruvbox_contrast_dark = "hard"
	end,
},

{
	'NLKNguyen/papercolor-theme',
	lazy = true,
},

{
	"yorik1984/newpaper.nvim",
	lazy = true,

	opts = {
		style = "dark",
		lightness = -0.08,
		saturation = 0.9,
		greyscale = false,
		editor_better_view = true,
		terminal            = "contrast",
		sidebars_contrast   = {},
		contrast_float      = true,
		contrast_telescope  = true,
		operators_bold      = false,
		delimiters_bold     = false,
		brackets_bold       = false,
		delim_rainbow_bold  = false,
		booleans            = "italic",
		keywords            = "bold",
		regex               = "bold",
		regex_bg            = true,
		tags                = "bold",
		tags_brackets_bold  = true,
		tex_major           = "bold",
		tex_operators_bold  = true,
		tex_brackets_bold   = false,
		tex_math_delim_bold = false,
		tex_keywords        = "italic",
		tex_zone            = "italic",
		tex_arg             = "italic",
		error_highlight     = "undercurl",
		italic_strings      = true,
		italic_comments     = true,
		italic_doc_comments = true,
		italic_functions    = false,
		italic_variables    = false,
		borders             = true,
		disable_background  = false,
		lsp_virtual_text_bg = true,
		hide_eob            = false,
		colors              = {},
		colors_advanced     = {},
		custom_highlights   = {},
		lualine_bold        = false,
		lualine_style       = "dark",
		devicons_custom     = {},
	},
},

{
	"rebelot/kanagawa.nvim",
	lazy = true,


	opts = {
		compile = false,             -- enable compiling the colorscheme
		undercurl = true,            -- enable undercurls
		commentStyle = { italic = true },
		functionStyle = {},
		keywordStyle = { italic = true},
		statementStyle = { bold = true },
		typeStyle = {},
		transparent = false,         -- do not set background color
		dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
		terminalColors = true,       -- define vim.g.terminal_color_{0,17}
		colors = {                   -- add/modify theme and palette colors
		palette = {},
		theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
	},
	overrides = function(colors) -- add/modify highlights
		return {}
	end,
	theme = "dragon",              -- Load "wave" theme when 'background' option is not set
	background = {               -- map the value of 'background' option to a theme
	dark = "dragon",           -- try "dragon" !
	light = "dragon"
},
		},
	},

	{
		"marko-cerovac/material.nvim",
		lazy = true,


		config = function() 
			vim.g.material_style = "deep ocean"
		end,

		opts = {
			contrast = {
				terminal = false, -- Enable contrast for the built-in terminal
				sidebars = false, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
				floating_windows = false, -- Enable contrast for floating windows
				cursor_line = false, -- Enable darker background for the cursor line
				non_current_windows = false, -- Enable contrasted background for non-current windows
				filetypes = {}, -- Specify which filetypes get the contrasted (darker) background
			},

			styles = { -- Give comments style such as bold, italic, underline etc.
			comments = { --[[ italic = true ]] },
			strings = { --[[ italic = true ]] },
			keywords = { --[[ underline = true ]] },
			functions = { --[[ bold = true, undercurl = true ]] },
			variables = {},
			operators = {},
			types = {},
		},

		plugins = { -- Uncomment the plugins that you use to highlight them
		"neo-tree",
		"nvim-cmp",
		"telescope",
	},

	disable = {
		colored_cursor = false, -- Disable the colored cursor
		borders = false, -- Disable borders between verticaly split windows
		background = false, -- Prevent the theme from setting the background (NeoVim then uses your terminal background)
		term_colors = false, -- Prevent the theme from setting terminal colors
		eob_lines = false -- Hide the end-of-buffer lines
	},

	high_visibility = {
		lighter = false, -- Enable higher contrast text for lighter style
		darker = false -- Enable higher contrast text for darker style
	},

	lualine_style = "stealth", -- Lualine style ( can be 'stealth' or 'default' )

	async_loading = true, -- Load parts of the theme asyncronously for faster startup (turned on by default)

	custom_colors = nil, -- If you want to override the default colors, set this to a function

	custom_highlights = {}, -- Overwrite highlights with your own
},
	},
}

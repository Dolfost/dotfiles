---@diagnostic disable: missing-fields
return {
	{
		'nvim-treesitter/nvim-treesitter',
		build = ":TSUpdate",
		lazy = true,
		enabled = true,

		config = function()
			local configs = require"nvim-treesitter.configs"
			configs.setup({
				-- A list of parser names, or "all" (the five listed parsers should always be installed)
				ensure_installed = {'c', 'cpp', 'bash', 'python', 'c_sharp', 'git_rebase', 'git_config', 'gitignore',
					'doxygen',
					'vimdoc', 'lua', 'luadoc', 'vim', 'query', 'markdown', 'markdown_inline',
					-- 'latex', 'bibtex'
				},

				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = true,

				-- Automatically install missing parsers when entering buffer
				-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
				auto_install = true,

				-- List of parsers to ignore installing (for "all")
				ignore_install = { "latex", 'bibtex' },

				-- If you need to change the installation directory of the parsers (see -> Advanced Setup)
				-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

				highlight = {
					enable = true,
					disable = { 'markdown', 'markdown_inline', 'latex', 'bibtex' };

					-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
					-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
					-- the name of the parser)
					-- list of language that will be disabled
					-- disable = {'latex', 'gitcommit', 'markdown'},
					-- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files

					-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
					-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
					-- Using this option may slow down your editor, and you may see some duplicate highlights.
					-- Instead of true it can also be a list of languages
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true,
					disable = { "latex", 'bibtex' },
				}
			})
		end
	},

	{
		'nvim-treesitter/nvim-treesitter-textobjects',
		dependencies = {'nvim-treesitter/nvim-treesitter'},

		config = function ()
			---@diagnostic disable-next-line: missing-fields
			require"nvim-treesitter.configs".setup{
				textobjects = {
					select = {
						enable = true,

						-- Automatically jump forward to textobj, similar to targets.vim
						lookahead = true,

						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["af"] = {query = "@function.outer", desc = "function"},
							["if"] = {query = "@function.inner", desc = "function"},
							["ac"] = {query = "@class.outer", desc = "class"},
							["ic"] = { query = "@class.inner", desc = "class" },
							-- You can also use captures from other query groups like `locals.scm`
							["as"] = { query = "@scope", query_group = "locals", desc = "scope" },
						},
						-- You can choose the select mode (default is charwise 'v')
						--
						-- Can also be a function which gets passed a table with the keys
						-- * query_string: eg '@function.inner'
						-- * method: eg 'v' or 'o'
						-- and should return the mode ('v', 'V', or '<c-v>') or a table
						-- mapping query_strings to modes.
						selection_modes = {
							['@parameter.outer'] = 'v', -- charwise
							['@function.outer'] = 'V', -- linewise
							['@class.outer'] = '<c-v>', -- blockwise
						},
						-- If you set this to `true` (default is `false`) then any textobject is
						-- extended to include preceding or succeeding whitespace. Succeeding
						-- whitespace has priority in order to act similarly to eg the built-in
						-- `ap`.
						--
						-- Can also be a function which gets passed a table with the keys
						-- * query_string: eg '@function.inner'
						-- * selection_mode: eg 'v'
						-- and should return true or false
						include_surrounding_whitespace = true,
					},
				},
			}
		end,
	},

	{
		'nvim-treesitter/nvim-treesitter-refactor',

		dependencies = {'nvim-treesitter/nvim-treesitter'},

		config = function ()
			---@diagnostic disable-next-line: missing-fields
			require"nvim-treesitter.configs".setup{
				refactor = {
					highlight_definitions = {
						enable = true,
						-- Set to false if you have an `updatetime` of ~100.
						clear_on_cursor_move = true,
					},
				},
			}
		end,
	},
}

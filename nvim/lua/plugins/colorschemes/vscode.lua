return {
	'Mofiqul/vscode.nvim',

	lazy = true,
	priority = 1000,

	config = function ()
		local vs = require('vscode')
		local c = require"vscode.colors".get_colors()

		local opts = {
			-- Alternatively set style in setup
			-- style = 'light'

			-- Enable transparent background
			transparent = false,

			-- Enable italic comment
			italic_comments = true,

			-- Underline `@markup.link.*` variants
			underline_links = true,

			-- Disable nvim-tree background color
			disable_nvimtree_bg = true,
		}

		vs.setup(opts)
	end
}

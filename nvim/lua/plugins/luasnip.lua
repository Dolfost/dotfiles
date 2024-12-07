return {
	'L3MON4D3/LuaSnip',

	-- follow latest release.
	version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	-- install jsregexp (optional!).
	build = 'make install_jsregexp',
	-- dependencies = { 'rafamadriz/friendly-snippets' },

	config = function()
		local ls = require 'luasnip'
		ls.setup {
			snip_env = {
				bruh = "sus",
			},
		}

		ls.filetype_extend("cpp", {"c"})
		require('luasnip.loaders.from_lua').load{
			paths = {
				'~/.config/nvim/lua/snippets'
			}
		}
	end,
}

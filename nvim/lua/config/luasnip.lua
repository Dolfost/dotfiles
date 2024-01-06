local ls = require'luasnip'

require('luasnip.loaders.from_lua').load({paths = '~/.config/nvim/LuaSnip/'})
require("luasnip.loaders.from_vscode").lazy_load()

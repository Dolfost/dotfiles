return {
	cmd = { 'lua-language-server' },
	root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace"
			},
		},
	},
	filetypes = { 'lua' },
}

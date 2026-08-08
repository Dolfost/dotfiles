return {
	capabilities = {
		offsetEncoding = {},
		textDocument = {
			completion = {
				editsNearCursor = true
			},
			-- Advertise inactiveRegions so clangd stops sending #if 0 blocks as
			-- dimmed `comment` semantic tokens. Neovim ignores the notification,
			-- so the disabled code keeps normal syntax highlighting.
			inactiveRegionsCapabilities = {
				inactiveRegions = true
			}
		}
	},
	cmd = {
		"clangd",
		"--rename-file-limit=0",
		"--header-insertion-decorators",
		"--header-insertion=iwyu",
		"--offset-encoding=utf-32",
		"--query-driver=**/*",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	root_markers = { '.git', '.clangd', 'compile_commands.json' }
}


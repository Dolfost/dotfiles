return {
	capabilities = {
		offsetEncoding = {},
		textDocument = {
			completion = {
				editsNearCursor = true
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


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

return {
	capabilities = capabilities,
	cmd = { "vscode-html-language-server", "--stdio" },
	fileytpes = { "html", "templ" },
	init_option = {
		configurationSection = { "html", "css", "javascript" },
		embeddedLanguages = {
			css = true,
			javascript = true
		},
		provideFormatter = true
	},
	root_markers = { "package.json", ".git" },
	settings = {}
}

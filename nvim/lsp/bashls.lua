return {
	cmd = { "bash-language-server" },
	filetypes = { "bash" },
	capabilities = {
		codeActionProvider = {
			codeActionKinds = { "quickfix" },
			resolveProvider = false,
			workDoneProgress = false
		},
		completionProvider = {
			resolveProvider = true,
			triggerCharacters = { "$", "{" }
		},
		definitionProvider = true,
		documentFormattingProvider = true,
		documentHighlightProvider = true,
		documentSymbolProvider = true,
		hoverProvider = true,
		referencesProvider = true,
		renameProvider = {
			prepareProvider = true
		},
		textDocumentSync = {
			change = 1,
			openClose = true,
			save = {
				includeText = false
			},
			willSave = false,
			willSaveWaitUntil = false
		},
		workspaceSymbolProvider = true
	},
}

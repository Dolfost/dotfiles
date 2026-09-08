return {
	{
		"vim-pandoc/vim-pandoc",
		dependencies = { "vim-pandoc/vim-pandoc-syntax" },
		-- not lazy-loaded: vim-pandoc itself owns filetype detection (.md ->
		-- pandoc), so loading it on ft would be circular
		lazy = false,
	},
	{
		-- \f inserts a numbered footnote, \r returns from it
		"vim-pandoc/vim-markdownfootnotes",
		lazy = false,
		config = function()
			-- its mappings live in ftplugin/markdown/, but vim-pandoc gives .md
			-- buffers ft=pandoc - source them there too
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "pandoc",
				command = "runtime ftplugin/markdown/markdownfootnotes.vim",
			})
		end,
	},
	{
		-- CriticMarkup annotations: {++add++} {--del--} {~~old~>new~~}
		"vim-pandoc/vim-criticmarkup",
		lazy = false,
	},
	{
		'Kicamon/markdown-table-mode.nvim',
			config = function()
				require('markdown-table-mode').setup()
				local augroup = vim.api.nvim_create_augroup('my.pandoc', {})
				vim.api.nvim_create_autocmd('FileType', {
					pattern = { "pandoc", "markdown" },
					group = augroup,
					callback = function(ev)
						local wk = require 'which-key'
						wk.add({
							buffer = ev.buf,
							{ "<localleader>m", group = "Markdown",
							icon = {icon = 'md', color = 'green'},
							mode = 'nx',
						},
						{
							mode = 'n',
							{ "<localleader>mm", "<cmd>Mtm<cr>",
							desc = "Table mode",
							icon = {icon = 't', color = 'green'},
						},
					},
				})
			end
		})
	end
	}
}

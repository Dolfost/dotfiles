return {
	'stevearc/conform.nvim',

	enabled = false,

	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "goimports", "gofmt" },
			cpp = { "astyle" },
			javascript = { { "prettierd", "prettier" } },
			python = { { "isort", "black" } },

			-- Use the "*" filetype to run formatters on all filetypes.
			["*"] = { "codespell" },
			-- Use the "_" filetype to run formatters on filetypes that don't
			-- have other formatters configured.
			["_"] = { "trim_whitespace" },
		},
		-- If this is set, Conform will run the formatter on save.
		format_on_save = {
			-- I recommend these options. See :help conform.format for details.
			lsp_fallback = false,
			timeout_ms = 500,
		},
		-- If this is set, Conform will run the formatter asynchronously after save.
		format_after_save = {
			lsp_fallback = false,
		},
		-- Set the log level. Use `:ConformInfo` to see the location of the log file.
		log_level = vim.log.levels.ERROR,
		-- Conform will notify you when a formatter errors
		notify_on_error = true,

		formatters = {
			astyle = {
				prepend_args = { "--indent=tab" },
			},
		},

	},
}

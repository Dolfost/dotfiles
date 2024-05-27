return {
	'lervag/vimtex',
	lazy = true,
	ft = 'tex',
	enabled = true,


	config = function()
		vim.opt_local.spell = true

		vim.cmd("set suffixesadd+=.tex")

		vim.g.vimtex_view_method = 'skim'
		vim.g.vimtex_view_skim_reading_bar = true
		vim.g.vimtex_view_skim_activate = false
		vim.g.vimtex_view_skim_sync = true

		vim.g.vimtex_imaps_enabled = true

		vim.g.vimtex_complete_enabled = true
		vim.g.vimtex_complete_bib = {
			menu_fmt = '@key [@type] \'@title\' @author_short (@year)',
		}
		vim.g.vimtex_complete_close_braces = true
		vim.g.vimtex_complete_ignore_case = true
		vim.g.vimtex_complete_smart_case = true
		vim.g.vimtex_indent_ignored_env = {}

		vim.g.vimtex_syntax_conceal_disable = true

		vim.g.vimtex_parser_bib_backend = "lua"
		vim.g.vimtex_quickfix_open_on_warning = false
		vim.g.vimtex_doc_handlers = { 'vimtex#doc#handlers#texdoc' }

		vim.keymap.set("n", "<localleader>ll", "<Cmd>update<CR><Cmd>VimtexCompile<CR>", { desc = "Vimtex compile" })
		vim.keymap.set({ "n", "x" }, "<localleader>lL", "<Cmd>update<CR><Cmd>VimtexCompileSelected<CR>",
			{ desc = "Vimtex compile selected" })
		vim.keymap.set("n", "<localleader>li", "<Cmd>VimtexInfo<CR>", { desc = "Vimtex info" })
		vim.keymap.set("n", "<localleader>lI", "<Cmd>VimtexInfo!<CR>", { desc = "Vimtex info full" })
		vim.keymap.set("n", "<localleader>lt", "<Cmd>VimtexTocOpen<CR>", { desc = "Vimtex TOC" })
		vim.keymap.set("n", "<localleader>lT", "<Cmd>VimtexTocToggle<CR>", { desc = "Vimtex toggle TOC" })
		vim.keymap.set("n", "<localleader>lq", "<Cmd>VimtexLog<CR>", { desc = "Vimtex log" })
		vim.keymap.set("n", "<localleader>lv", "<Cmd>VimtexView<CR>", { desc = "Vimtex view" })
		vim.keymap.set("n", "<localleader>lr", "<plug>(Vimtex-reverse-search)", { desc = "Vimtex reverse search" })
		vim.keymap.set("n", "<localleader>lk", "<Cmd>VimtexStop<CR>", { desc = "Vimtex stop" })
		vim.keymap.set("n", "<localleader>lK", "<Cmd>VimtexStopAll<CR>", { desc = "Vimtex stop all" })
		vim.keymap.set("n", "<localleader>le", "<Cmd>VimtexErrors<CR>", { desc = "Vimtex errors" })
		vim.keymap.set("n", "<localleader>lo", "<Cmd>VimtexCompileOutput<CR>", { desc = "Vimtex compille output" })
		vim.keymap.set("n", "<localleader>lg", "<Cmd>VimtexStatus<CR>", { desc = "Vimtex status" })
		vim.keymap.set("n", "<localleader>lG", "<Cmd>VimtexStatus!<CR>", { desc = "Vimtex full status" })
		vim.keymap.set("n", "<localleader>lc", "<Cmd>VimtexClean<CR>", { desc = "Vimtex clean" })
		vim.keymap.set("n", "<localleader>lC", "<Cmd>VimtexClean!<CR>", { desc = "Vimtex full clean" })
		vim.keymap.set("n", "<localleader>lx", "<Cmd>VimtexReload<CR>", { desc = "Vimtex reload" })
		vim.keymap.set("n", "<localleader>lX", "<Cmd>VimtexReloadState<CR>", { desc = "Vimtex reload state" })
		vim.keymap.set("n", "<localleader>lm", "<Cmd>VimtexImapsList<CR>", { desc = "Vimtex input maps list" })
		vim.keymap.set("n", "<localleader>ls", "<Cmd>VimtexToggleMain<CR>", { desc = "Vimtex toggle main" })
		vim.keymap.set("n", "<localleader>la", "<Cmd>VimtexContextMenu<CR>", { desc = "Vimtex context menu" })

		vim.g.vimtex_compiler_method = 'latexmk'
		vim.g.vimtex_compiler_latexmk = {
			build_dir = 'buiddir',
			callback = 1,
			continuous = 0,
			executable = 'latexmk',
			hooks = {},
			options = {
				'-verbose',
				'-file-line-error',
				'-synctex=1',
				'-interaction=nonstopmode',
				'-shell-escape',
			},
		}
	end,
}

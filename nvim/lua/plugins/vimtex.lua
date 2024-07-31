return {
	'lervag/vimtex',
	lazy = true,
	ft = 'tex',
	enabled = true,

	--  TODO: fix skim backward search

	config = function()
		vim.opt_local.spell = true

		vim.cmd("set suffixesadd+=.tex")

		vim.g.vimtex_view_method = 'skim'
		vim.g.vimtex_view_skim_reading_bar = true
		vim.g.vimtex_view_skim_activate = false
		vim.g.vimtex_view_skim_sync = true

		vim.g.vimtex_imaps_enabled = true

		vim.g.vimtex_complete_enabled = true
		vim.g.vimtex_complete_close_braces = true
		vim.g.vimtex_complete_ignore_case = true
		vim.g.vimtex_complete_smart_case = true
		vim.g.vimtex_indent_ignored_envs = {"document"}
		vim.g.vimtex_complete_bib = {
			menu_fmt = '[@type] @author_short (@year), "@title"',
		}

		vim.g.vimtex_fold_enabled = false
		vim.g.vimtex_fold_types = {
			preamble = {enabled = true},
			sections = {enabled = true},
		}

		vim.g.vimtex_echo_verbose_input = false
		vim.g.vimtex_parser_bib_backend = "lua"
		vim.g.vimtex_quickfix_open_on_warning = false

		vim.g.vimtex_syntax_conceal_disable = false
		vim.g.vimtex_syntax_conceal = {
			accents = true,
			ligatures = true,
			cites = true,
			fancy = true,
			spacing = true,
			greek = true,
			math_bounds = true,
			math_delimiters = true,
			math_fracs = true,
			math_super_sub = true,
			math_symbols = true,
			sections = true,
			styles = true,
		}

    vim.g.vimtex_syntax_conceal_cites = {
			type = 'brackets',
			icon = '📖',
			verbose = true,
		}

		vim.g.vimtex_doc_confirm_single = false
		vim.g.vimtex_doc_handlers = { 'vimtex#doc#handlers#texdoc' }

		vim.api.nvim_create_autocmd('BufEnter', {
			pattern = {"*.tex", "*.bib", "*.sty"},
			group = vim.api.nvim_create_augroup('vimtexConfig', {}),
			callback = function(ev)
				local wk = require"which-key"

				wk.add{
					{ "<leader>l", buffer = ev.buf, group = "VimTeX" },
					{ "<leader>ll", "<cmd>update<cr><cmd>VimtexCompile<cr>", desc = "Compile" },
					{ "<leader>ll", "<cmd>update<cr><cmd>VimtexCompileSelected<cr>", desc = "Compile selected", mode = 'v' },
					{ "<leader>ls", "<cmd>update<cr><cmd>VimtexCompileSS<cr>", desc = "Single shot compile" },
					{ "<leader>lL", "<cmd>update<cr><cmd>VimtexCompileSelected<cr>", desc = "Compile selected"},
					{ "<leader>li", "<cmd>VimtexInfo<cr>", desc = "Information" },
					{ "<leader>lI", "<cmd>VimtexInfo!<cr>", desc = "Full information" },
					{ "<leader>lt", "<cmd>VimtexTocOpen<cr>", desc = "Table of Contents" },
					{ "<leader>lT", "<cmd>VimtexTocToggle<cr>", desc = "Toggle table of Contents" },
					{ "<leader>lq", "<cmd>VimtexLog<cr>", desc = "Log" },
					{ "<leader>lv", "<cmd>VimtexView<cr>", desc = "View" },
					{ "<leader>lr", "<plug>(Vimtex-reverse-search)", desc = "Reverse search" },
					{ "<leader>lk", "<Cmd>VimtexStop<cr>", desc = "Stop" },
					{ "<leader>lK", "<Cmd>VimtexStopAll<cr>", desc = "Stop all" },
					{ "<leader>le", "<Cmd>VimtexErrors<cr>", desc = "Errors" },
					{ "<leader>lo", "<Cmd>VimtexCompileOutput<cr>", desc = "Compile output" },
					{ "<leader>lg", "<Cmd>VimtexStatus<cr>", desc = "Status" },
					{ "<leader>lG", "<Cmd>VimtexStatus!<cr>", desc = "Full status" },
					{ "<leader>lc", "<Cmd>VimtexClean<cr>", desc = "Clean" },
					{ "<leader>lh", "<Cmd>VimtexClearCache ALL<cr>", desc = "Clear all cache" },
					{ "<leader>lC", "<Cmd>VimtexClean!<cr>", desc = "Full clean" },
					{ "<leader>lx", "<Cmd>VimtexReload<cr>", desc = "Reload" },
					{ "<leader>lX", "<Cmd>VimtexReloadState<cr>", desc = "Reload state" },
					{ "<leader>lm", "<Cmd>VimtexImapsList<cr>", desc = "Input mappings" },
					{ "<leader>lS", "<Cmd>VimtexToggleMain<cr>", desc = "Toggle main" },
					{ "<leader>la", "<Cmd>VimtexContextMenu<cr>", desc = "Context menu"},
				}
			end,
		})

		vim.g.vimtex_compiler_method = 'latexmk'
		vim.g.vimtex_compiler_latexmk = {
			-- auxdir = 'tex_auxiliary',
			-- out_dir = 'out',
			callback = true,
			continuous = true,
			executable = 'latexmk',
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

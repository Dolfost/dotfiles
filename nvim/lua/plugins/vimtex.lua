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

		vim.g.vimtex_fold_enabled = true
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

		local wk = require"which-key"

		wk.register({
			l = {
				name = "VimTeX",
				l = { "<cmd>update<cr><cmd>VimtexCompile<cr>", "Compile" },
				s = { "<cmd>update<cr><cmd>VimtexCompileSS<cr>", "Single shot compile" },
				L = { "<cmd>update<cr><cmd>VimtexCompileSelected<cr>", "Compile selected"},
				i = { "<cmd>VimtexInfo<cr>", "Information" },
				I = { "<cmd>VimtexInfo!<cr>", "Full information" },
				t = { "<cmd>VimtexTocOpen<cr>", "Table of Contents" },
				T = { "<cmd>VimtexTocToggle<cr>", "Toggle table of Contents" },
				q = { "<cmd>VimtexLog<cr>", "Log" },
				v = { "<cmd>VimtexView<cr>", "View" },
				r = { "<plug>(Vimtex-reverse-search)", "Reverse search" },
				k = { "<Cmd>VimtexStop<cr>", "Stop" },
				K = { "<Cmd>VimtexStopAll<cr>", "Stop all" },
				e = { "<Cmd>VimtexErrors<cr>", "Errors" },
				o = { "<Cmd>VimtexCompileOutput<cr>", "Compile output" },
				g = { "<Cmd>VimtexStatus<cr>", "Status" },
				G = { "<Cmd>VimtexStatus!<cr>", "Full status" },
				c = { "<Cmd>VimtexClean<cr>", "Clean" },
				h = { "<Cmd>VimtexClearCache ALL<cr>", "Clear all cache" },
				C = { "<Cmd>Vimtexllean!<cr>", "Full clean" },
				x = { "<Cmd>VimtexReload<cr>", "Reload" },
				X = { "<Cmd>VimtexReloadState<cr>", "Reload state" },
				m = { "<Cmd>VimtexImapsList<cr>", "Input mappings" },
				S = { "<Cmd>VimtexToggleMain<cr>", "Toggle main" },
				a = { "<Cmd>VimtexContextMenu<cr>", "Context menu"},
			},
		}, { prefix = "<leader>" })

		wk.register({
			l = {
				name = "VimTex",
				l = { "<cmd>update<cr><cmd>VimtexCompileSelected<cr>", "Compile selected"},
			},
		}, { prefix = "<leader>", mode = "v"})


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

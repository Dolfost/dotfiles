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
			icon = '',
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
					{ "<leader>l", buffer = ev.buf, group = "VimTeX",
						icon = {icon = '', color = 'green'},
					},
					{ "<leader>ll", "<cmd>update<cr><cmd>VimtexCompile<cr>",
						desc = "Compile",
						icon = {icon = '', color = 'green'},
					},
					{ "<leader>ls", "<cmd>update<cr><cmd>VimtexCompileSS<cr>",
						desc = "Single shot compile",
						icon = {icon = '', color = 'green'},
					},
					{ "<leader>lL", "<cmd>update<cr><cmd>VimtexCompileSelected<cr>",
						desc = "Compile selected",
						icon = {icon = '', color = 'green'},
					},
					{ "<leader>li", "<cmd>VimtexInfo<cr>",
						desc = "Information",
						icon = {icon = '', color = 'purple'}
					},
					{ "<leader>lI", "<cmd>VimtexInfo!<cr>",
						desc = "Full information",
						icon = {icon = '󰙎', color = 'purple'}
					},
					{ "<leader>lt", "<cmd>VimtexTocOpen<cr>",
						desc = "Table of Contents",
						icon = {icon = '󰠶', color = 'purple'}
					},
					{ "<leader>lT", "<cmd>VimtexTocToggle<cr>",
						desc = "Toggle table of Contents",
						icon = {icon = '󰠶', color = 'purple'},
					},
					{ "<leader>lq", "<cmd>VimtexLog<cr>",
						desc = "Log",
						icon = {icon = '', color = 'purple'},
					},
					{ "<leader>lv", "<cmd>VimtexView<cr>",
						desc = "View",
						icon = {icon = '', color = 'green'},
					},
					{ "<leader>lr", "<plug>(Vimtex-reverse-search)",
						desc = "Reverse search",
						icon = {icon = '', color = 'purple'},
					},
					{ "<leader>lk", "<Cmd>VimtexStop<cr>",
						desc = "Stop",
						icon = {icon = '', color = 'red'},
					},
					{ "<leader>lK", "<Cmd>VimtexStopAll<cr>",
						desc = "Stop all",
						icon = {icon = '󰓛', color = 'red'},
					},
					{ "<leader>le", "<Cmd>VimtexErrors<cr>",
						desc = "Errors",
						icon = {icon = '', color = 'red'},
					},
					{ "<leader>lo", "<Cmd>VimtexCompileOutput<cr>",
						desc = "Compile output",
						icon = {icon = '', color = 'purple'},
					},
					{ "<leader>lg", "<Cmd>VimtexStatus<cr>",
						desc = "Status",
						icon = {icon = '󱖫', color = 'purple'},
					},
					{ "<leader>lG", "<Cmd>VimtexStatus!<cr>",
						desc = "Full status",
						icon = {icon = '󱖫', color = 'purple'},
					},
					{ "<leader>lc", "<Cmd>VimtexClean<cr>",
						desc = "Clean",
						icon = {icon = '󰃢', color = 'orange'},
					},
					{ "<leader>lh", "<Cmd>VimtexClearCache ALL<cr>",
						desc = "Clear all cache",
						icon = {icon = '󰃢', color = 'grey'},
					},
					{ "<leader>lC", "<Cmd>VimtexClean!<cr>",
						desc = "Full clean",
						icon = {icon = '󰃢', color = 'red'},
					},
					{ "<leader>lx", "<Cmd>VimtexReload<cr>",
						desc = "Reload",
						icon = {icon = '󰑓', color = 'green'},
					},
					{ "<leader>lX", "<Cmd>VimtexReloadState<cr>",
						desc = "Reload state",
						icon = {icon = '󰑓', color = 'cyan'},
					},
					{ "<leader>lm", "<Cmd>VimtexImapsList<cr>",
						desc = "Input mappings",
						icon = {icon = '', color = 'purple'},
					},
					{ "<leader>lS", "<Cmd>VimtexToggleMain<cr>",
						desc = "Toggle main",
						icon = {icon = '󱪚', color = 'green'},
					},
					{ "<leader>la", "<Cmd>VimtexContextMenu<cr>",
						desc = "Context menu",
						icon = {icon = '󰮫', color = 'purple'},
					},
				}
				wk.add{
					{ "<leader>l", buffer = ev.buf, group = "VimTeX",
						icon = {icon = '', color = 'green'},
						mode = 'v',
					},
					{ "<leader>lL", "<cmd>update<cr><cmd>VimtexCompileSelected<cr>",
						desc = "Compile selected",
						icon = {icon = '', color = 'green'},
						mode = 'v',
					},
				}
			end,
		})

		vim.g.vimtex_compiler_method = 'latexmk'
		vim.g.vimtex_compiler_latexmk = {
			callback = true,
			continuous = true,
			executable = 'latexmk',
			options = {
				'-r ' .. vim.loop.cwd() .. '/build/src/latexmkrc',
				'-verbose',
				'-file-line-error',
				'-synctex=1',
				'-interaction=nonstopmode',
				'-shell-escape',
			},
		}


	end,
}

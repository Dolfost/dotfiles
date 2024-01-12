--  NOTE: VimTex -> Skim -> nvim link
-- function write_server_name()
	--   local nvim_server_file = win32 and vim.cmd("$TEMP") or '/tmp' .. '/vimtexserver.txt'
	-- --  `rm /tmp/vimtexserver.txt`
	--   vim.f("writefile([v:servername], nvim_server_file)")
	-- end


return {
	'lervag/vimtex',
	lazy = true,
	ft = 'tex',


	config = function()
		vim.opt_local.spell = true
		local wk = require("which-key")

		--  NOTE: VimTex -> Skim -> nvim link
		-- vim.api.nvim_create_augroup('vimtex_common', {clear = true})
		-- vim.api.nvim_create_autocmd({"FileType"}, {
			-- 	pattern = "*.tex",
			-- 	group = "vimtex_common",
			-- 	command = "call write_server_name"})

		vim.cmd("set suffixesadd+=.tex")

		vim.g.vimtex_view_method = 'skim'
		vim.g.vimtex_view_skim_reading_bar = true
		vim.g.vimtex_view_skim_activate = false
		vim.g.vimtex_view_skim_sync = true

		vim.g.vimtex_complete_enabled = true
		vim.g.vimtex_complete_bib = {
			menu_fmt = '@key [@type] \'@title\' @author_short (@year)',
		}
		vim.g.vimtex_complete_close_braces = true
		vim.g.vimtex_complete_ignore_case = true
		vim.g.vimtex_complete_smart_case = true

		vim.g.vimtex_parser_bib_backend = "lua"
		vim.g.vimtex_quickfix_open_on_warning = 0 
		vim.g.vimtex_doc_handlers = {'vimtex#doc#handlers#texdoc'}

		wk.register({
			l = {
				name = "Vimtex",
			},
		})

		vim.keymap.set("n", "<localleader>ll", "<Cmd>update<CR><Cmd>VimtexCompile<CR>", {desc = "Vimtex compile"})
		vim.keymap.set({"n", "x"}, "<localleader>lL", "<Cmd>update<CR><Cmd>VimtexCompileSelected<CR>", {desc = "Vimtex compile selected"})
		vim.keymap.set("n", "<localleader>li", "<Cmd>VimtexInfo<CR>", {desc = "Vimtex info"})
		vim.keymap.set("n", "<localleader>lI", "<Cmd>VimtexInfo!<CR>", {desc = "Vimtex info full"})
		vim.keymap.set("n", "<localleader>lt", "<Cmd>VimtexTocOpen<CR>", {desc = "Vimtex TOC"})
		vim.keymap.set("n", "<localleader>lT", "<Cmd>VimtexTocToggle<CR>", {desc = "Vimtex toggle TOC"})
		vim.keymap.set("n", "<localleader>lq", "<Cmd>VimtexLog<CR>", {desc = "Vimtex log"})
		vim.keymap.set("n", "<localleader>lv", "<Cmd>VimtexView<CR>", {desc = "Vimtex view"})
		vim.keymap.set("n", "<localleader>lr", "<plug>(Vimtex-reverse-search)", {desc = "Vimtex reverse search"})
		vim.keymap.set("n", "<localleader>lk", "<Cmd>VimtexStop<CR>", {desc = "Vimtex stop"})
		vim.keymap.set("n", "<localleader>lK", "<Cmd>VimtexStopAll<CR>", {desc = "Vimtex stop all"})
		vim.keymap.set("n", "<localleader>le", "<Cmd>VimtexErrors<CR>", {desc = "Vimtex errors"})
		vim.keymap.set("n", "<localleader>lo", "<Cmd>VimtexCompileOutput<CR>", {desc = "Vimtex compille output"})
		vim.keymap.set("n", "<localleader>lg", "<Cmd>VimtexStatus<CR>", {desc = "Vimtex status"})
		vim.keymap.set("n", "<localleader>lG", "<Cmd>VimtexStatus!<CR>", {desc = "Vimtex full status"})
		vim.keymap.set("n", "<localleader>lc", "<Cmd>VimtexClean<CR>", {desc = "Vimtex clean"})
		vim.keymap.set("n", "<localleader>lC", "<Cmd>VimtexClean!<CR>", {desc = "Vimtex full clean"})
		vim.keymap.set("n", "<localleader>lx", "<Cmd>VimtexReload<CR>", {desc = "Vimtex reload"})
		vim.keymap.set("n", "<localleader>lX", "<Cmd>VimtexReloadState<CR>", {desc = "Vimtex reload state"})
		vim.keymap.set("n", "<localleader>lm", "<Cmd>VimtexImapsList<CR>", {desc = "Vimtex input maps list"})
		vim.keymap.set("n", "<localleader>ls", "<Cmd>VimtexToggleMain<CR>", {desc = "Vimtex toggle main"})
		vim.keymap.set("n", "<localleader>la", "<Cmd>VimtexContextMenu<CR>", {desc = "Vimtex context menu"})


		-- VimTeX uses latexmk as the default compiler backend. If you use it, which is
		-- strongly recommended, you probably don't need to configure anything. If you
		-- want another compiler backend, you can change it as follows. The list of
		-- supported backends and further explanation is provided in the documentation,
		-- see ":help vimtex-compiler".
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

		vim.g.vimtex_compiler_latexmk_engines = {
			_ = '-pdf',
			pdfdvi = '-pdfdvi',
			pdfps = '-pdfps',
			pdflatex = '-pdf',
			luatex = '-lualatex',
			lualatex = '-lualatex',
			xelatex = '-xelatex',
			['context (pdftex)'] = "-pdf -pdflatex=texexec",
			['context (luatex)'] = "-pdf -pdflatex=context",
			['context (xetex)'] = "-pdf -pdflatex=''texexec --xtx''",
		}
	end,
}

vim.opt_local.spell = true

-- VimTex -> Skim -> nvim link
-- function write_server_name()
--   local nvim_server_file = win32 and vim.cmd("$TEMP") or '/tmp' .. '/vimtexserver.txt'
-- --  `rm /tmp/vimtexserver.txt`
--   vim.f("writefile([v:servername], nvim_server_file)")
-- end

-- vim.api.nvim_create_augroup('vimtex_common', {clear = true})
-- vim.api.nvim_create_autocmd({"FileType"}, {
-- 	pattern = "*.tex",
-- 	group = "vimtex_common",
-- 	command = "call write_server_name"})


vim.cmd("set suffixesadd+=.tex")

vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_view_skim_reading_bar = 1
vim.g.vimtex_view_skim_activate = 0
vim.g.vimtex_view_skim_sync = 1

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

vim.g.vimtex_parser_bib_backend = "bibtex"

vim.g.vimtex_quickfix_open_on_warning = 0 

vim.g.vimtex_doc_handlers = {'vimtex#doc#handlers#texdoc'}
vim.g.vimtex_complete_close_braces = 1

vim.keymapfs.set("n", "<localleader>ll", "<Cmd>update<CR><Cmd>VimtexCompile<CR>")

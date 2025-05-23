vim.cmd.colorscheme('carbonfox')
vim.opt.fillchars = 'eob: '
vim.opt.pumheight = 10

vim.diagnostic.config({
	underline = false,
	update_in_insert = true,
	virtual_text = true,
	virtual_lines = false,
	signs = true,
	float = true
})
vim.opt.updatetime = 200;

vim.opt.signcolumn = 'number'

vim.o.compatible = false

vim.cmd("filetype plugin indent on") -- VimTex requirement

vim.o.encoding = "utf8" -- VimTex requirement
vim.o.syntax = true     -- VimTex requirement

vim.o.termguicolor = true

vim.cmd.set("t_Co=256")
vim.o.wildmenu = true
vim.o.wildmode = "full"
vim.o.history = 200
vim.o.fixendofline = false
vim.o.incsearch = true

vim.o.infercase = true
vim.o.ignorecase = true

vim.o.mouse = 'a'
vim.o.wrap = true
vim.o.number = true
vim.o.cursorline = true
vim.o.showmode = false
vim.o.scrolloff = 8

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.conceallevel = 2

-- Replace grep with ripgrep
vim.o.grepprg = 'rg\\ $*\\ --column\\ --no-heading'
vim.o.grepformat = '%f:%l:%c%m,%l:%c%m'

-- Next map  makes the :edit %:h<Tab>
-- equivalent to       :edit %%<Tab>
-- vim.cmd("cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'")


-- Ukrainian language support
vim.o.keymap = 'ukrainian-jcuken'
vim.o.iminsert = 0
vim.o.imsearch = -1
vim.o.spelllang = 'uk,en_us,ru_ru'

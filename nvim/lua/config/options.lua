vim.o.compatible = false

vim.cmd("filetype plugin indent on") -- VimTex requirement

vim.o.encoding = "utf8" -- VimTex requirement
vim.o.syntax = "ON" -- VimTex requirement

vim.o.termguicolors = true

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
vim.o.mousescroll = "ver:1,hor:2"

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.conceallevel = 2

vim.o.exrc = true

-- Replace grep with ripgrep
vim.o.grepprg = 'rg\\ $*\\ --column\\ --no-heading'
vim.o.grepformat = '%f:%l:%c%m,%l:%c%m'

-- Disable netwr explorer
vim.g.loaded_netrwPlugin = true
vim.g.loaded_netrw = true

-- Ukrainian language support
vim.o.keymap = 'ukrainian-enhanced'
vim.o.iminsert = 0
vim.o.imsearch = -1
vim.o.spelllang = 'uk,en_us,ru_ru'

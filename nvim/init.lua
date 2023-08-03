vim.cmd.set("nocompatible")
vim.cmd("filetype plugin indent on")	-- VimTex, vundle requirement

vim.opt.encoding = "utf8"				-- VimTex requirement
vim.cmd("syntax on")					-- VimTex requirement

vim.cmd.set("t_Co=256")
vim.opt.wildmenu = true
vim.opt.wildmode = "full"
vim.cmd.set("history=200")
vim.cmd.set("nofixendofline")

vim.cmd.set("incsearch")

vim.cmd.set("infercase")
vim.cmd.set("ignorecase")

vim.cmd.set("mouse=a")
vim.cmd.set("wrap")
vim.cmd.set("number")
vim.cmd.set("guicursor=i:block-nCursor")
vim.cmd.set("cursorline")
vim.cmd.set("noshowmode")
vim.cmd.set("scrolloff=8")

vim.cmd.set("tabstop=4")
vim.cmd.set("shiftwidth=4")

-- Replace grep with ripgrep
vim.cmd.set("grepprg=rg\\ $*\\ --column\\ --no-heading")
vim.cmd.set("grepformat=%f:%l:%c%m,%l:%c%m")

-- Next map  makes the :edit %:h<Tab>
-- equivalent to       :edit %%<Tab>
vim.cmd("cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'")

-- Ukrainian language support
vim.cmd.set("keymap=ukrainian-jcuken")
vim.cmd.set("iminsert=0 imsearch=-1")
vim.cmd.set("spelllang=uk,en_us,ru_ru")

-- NO ARROW KEYS, U MFCKER! heheheha!!1!
vim.keymap.set('n', '<Up>', '<Nop>')
vim.keymap.set('n', '<Down>', '<Nop>')
vim.keymap.set('n', '<Left>', '<Nop>')
vim.keymap.set('n', '<Right>', '<Nop>')

-- Regenerate ctags file with F5
vim.cmd("nnoremap <f5> :!ctags -R<CR>")
require('plugins')

vim.cmd.set("background=dark")
vim.cmd.colorscheme("PaperColor")


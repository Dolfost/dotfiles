-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	use 'lervag/vimtex'

	-- use {'ycm-core/YouCompleteMe',
	-- ycm_min_num_of_chars_for_completion = 3,
	-- ycm_max_num_candidates = 12}

	if grepper == nil then
		grepper = {}
	endif
	use 'mhinz/vim-grepper'
	vim.g.grepper.highlight = 1
	vim.g.grepper.quickfix = 1
	vim.g.grepper.open = 1
	vim.g.grepper.switch = 1
	vim.g.grepper.jump = 0
	vim.g.grepper.prompt = 1
	vim.g.grepper.prompt_text = '$c> '
	vim.g.grepper.prompt_quote = 0
	vim.g.grepper.tools = ['rg', 'grep', 'git']

	use {'junegunn/fzf'}
	vim.g.fzf_action = {
		["ctrl-t"] = 'tab split',
		["ctrl-s"] = 'split',
		["ctrl-v"] = 'vsplit'}
	vim.g.fzf_layout = {window = {width = 0.9, height = 0.6, relative = true }}
	vim.g.fzf_colors = {
		fg =      ['fg', 'Normal'],
		bg =      ['bg', 'Normal'],
		hl =      ['fg', 'Comment'],
		['fg+'] = ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
		['bg+'] = ['bg', 'CursorLine', 'CursorColumn'],
		['hl+'] = ['fg', 'Statement'],
		info =    ['fg', 'PreProc'],
		border =  ['fg', 'Ignore'],
		prompt =  ['fg', 'Conditional'],
		pointer = ['fg', 'Exception'],
		marker =  ['fg', 'Keyword'],
		spinner = ['fg', 'Label'],
		header =  ['fg', 'Comment']}
	vim.g.fzf_history_dir = '~/.local/share/fzf-history'

-- Plugin 'nvim-treesitter/nvim-treesitter'

-- Plugin 'dense-analysis/ale'
-- noremap <Leader>l :ALELint<CR> 
-- let g:ale_enabled = 1
-- let g:ale_lint_delay = 3000 " def: 200 ms
-- let g:ale_sign_error = '>>'
-- let g:ale_sign_warning = '->'
-- let g:ale_sign_column_always = 0
-- let g:ale_lint_on_text_changed = 'never' " always, normal, insert, never
-- let g:ale_lint_on_insert_leave = 0
-- let g:ale_lint_on_enter = 0
-- let g:ale_lint_on_save = 1

-- Plugin 'tpope/vim-unimpaired'

-- Plugin 'tpope/vim-commentary'

-- Plugin 'tpope/vim-obsession'

-- Plugin 'godlygeek/tabular'
-- Plugin 'preservim/vim-markdown'

-- Plugin 'iamcco/markdown-preview.nvim'

-- Plugin 'ludovicchabant/vim-gutentags'

-- Plugin 'tpope/vim-surround'

-- Plugin 'SirVer/ultisnips'
-- let g:UltiSnipsExpandTrigger='<Tab>'
-- let g:UltiSnipsJumpForwardTrigger='<c-j>'
-- let g:UltiSnipsJumpBackwardTrigger='<c-k>'
-- let g:UltiSnipsEditSplit="tabdo"
-- let g:UltiSnippetsStorageDirectoryForUltisnipsEdit="/Users/vladyslav/.config/nvim/UltiSnips"

-- Plugin 'tpope/vim-fugitive'

-- Plugin 'tpope/vim-dispatch'

-- Plugin 'morhetz/gruvbox'
-- let g:gruvbox_italic = 1
-- let g:gruvbox_contrast_dark = "hard"
-- Plugin 'NLKNguyen/papercolor-theme'
-- Plugin 'ChrisKempson/Tomorrow-Theme'

-- Plugin 'vim-airline/vim-airline'
-- Plugin 'vim-airline/vim-airline-themes'
-- let g:airline_left_sep=''
-- let g:airline_right_sep=''
-- let g:airline_detect_modified=1
-- let g:airline_detect_paste=1
-- let g:airline_detect_crypt=1
-- let g:airline_detect_spell=1
-- let g:airline_detect_spelllang=1
-- let g:airline_detect_iminsert=1
-- let g:airline_inactive_collapse=1
-- let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
-- if !exists('g:airline_symbols')
-- 	let g:airline_symbols = {}
-- endif
-- let g:airline_left_sep = ''
-- let g:airline_right_sep = ''
-- let g:airline_symbols.colnr = ' col '
-- let g:airline_symbols.crypt = ''
-- let g:airline_symbols.linenr = ' '
-- let g:airline_symbols.maxlinenr = '㏑ '
-- let g:airline_symbols.branch = '⎇ '
-- let g:airline_symbols.paste = 'ρ'
-- let g:airline_symbols.spell = 'Ꞩ'
-- let g:airline_symbols.notexists = '∄'
-- let g:airline_symbols.whitespace = 'Ξ'
-- let g:airline#extensions#whitespace#enabled = 0
-- 	let g:airline#extensions#fzf#enabled = 1
-- 	let g:airline#extensions#gutentags#enabled = 1
-- 	let g:airline#extensions#ale#enabled = 1
-- let airline#extensions#ale#error_symbol = 'E:'
-- let airline#extensions#ale#warning_symbol = 'W:'
-- let airline#extensions#ale#show_line_numbers = 1
-- let airline#extensions#ale#open_lnum_symbol = '(L'
-- let airline#extensions#ale#close_lnum_symbol = ')'
-- 	let g:airline#extensions#tabline#enabled = 1
-- let g:airline#extensions#tabline#show_tabs = 1
-- let g:airline#extensions#tabline#tab_nr_type = 1 " 0:splits, 1:tabn, 2:splits&tabn
-- let g:airline#extensions#tabline#show_tab_nr = 1
-- let g:airline#extensions#tabline#overflow_marker = '…'
-- let g:airline#extensions#tabline#show_tab_count = 1
-- let g:airline#extensions#tabline#show_tab_type = 1
-- let g:airline#extensions#tabline#buffers_label = 'B'
-- let g:airline#extensions#tabline#tabs_label = 'T'
-- let g:airline#extensions#tabline#show_close_button = 0
-- let g:airline#extensions#tabline#close_symbol = '×'
-- let g:airline#extensions#tabline#buffer_nr_format = '%s'
-- let g:airline#extensions#tabline#fnamemod = ':t'
-- let g:airline#extensions#tabline#tab_min_count = 2
-- let g:airline#extensions#tabline#buffer_min_count = 2
-- let g:airline#extensions#tabline#left_sep = ''
-- let g:airline#extensions#tabline#left_alt_sep = ''
-- let g:airline#extensions#tabline#right_sep = ''
-- let g:airline#extensions#tabline#right_alt_sep = ''
-- let g:airline#extensions#tabline#ignore_bufadd_pat = 'defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'
-- 	let g:airline#extensions#obsession#enabled = 1
-- let g:airline#extensions#obsession#indicator_text = 'Ⓢ '

-- call vundle#end()

end)

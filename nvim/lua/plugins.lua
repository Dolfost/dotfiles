-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	use 'lervag/vimtex'

	-- use {'ycm-core/YouCompleteMe',
	-- ycm_min_num_of_chars_for_completion = 3,
	-- ycm_max_num_candidates = 12}

	use 'mhinz/vim-grepper'
	vim.g.grepper = {
		highlight = 1,
		quickfix = 1,
		open = 1,
		switch = 1,
		jump = 0,
		prompt = 1,
		prompt_text = '$c> ',
		prompt_quote = 0,
		tools = {'rg', 'grep', 'git'},
	}

	use 'junegunn/fzf'
	vim.g.fzf_action = {
		["ctrl-t"] = 'tab split',
		["ctrl-s"] = 'split',
		["ctrl-v"] = 'vsplit'}
	vim.g.fzf_layout = {window = {width = 0.9, height = 0.6, relative = true }}
	vim.g.fzf_colors = {
		fg =      {'fg', 'Normal'},
		bg =      {'bg', 'Normal'},
		hl =      {'fg', 'Comment'},
		['fg+'] = {'fg', 'CursorLine', 'CursorColumn', 'Normal'},
		['bg+'] = {'bg', 'CursorLine', 'CursorColumn'},
		['hl+'] = {'fg', 'Statement'},
		info =    {'fg', 'PreProc'},
		border =  {'fg', 'Ignore'},
		prompt =  {'fg', 'Conditional'},
		pointer = {'fg', 'Exception'},
		marker =  {'fg', 'Keyword'},
		spinner = {'fg', 'Label'},
		header =  {'fg', 'Comment'}}
	vim.g.fzf_history_dir = '~/.local/share/fzf-history'

	use 'nvim-treesitter/nvim-treesitter'
	require'config/treesitter'

	use 'dense-analysis/ale'
	vim.keymap.set('n', '<Leader>l', ':ALELint<CR>')
	vim.g.ale_enabled = 1
	vim.g.ale_lint_delay = 3000 -- def: 200 ms
	vim.g.ale_sign_error = '>>'
	vim.g.ale_sign_warning = '->'
	vim.g.ale_sign_column_always = 0
	vim.g.ale_lint_on_text_changed = 'never' -- always, normal, insert, never
	vim.g.ale_lint_on_insert_leave = 0
	vim.g.ale_lint_on_enter = 0
	vim.g.ale_lint_on_save = 1

	use 'tpope/vim-unimpaired'

	use 'tpope/vim-commentary'

	use 'tpope/vim-obsession'

	use 'godlygeek/tabular'
	use 'preservim/vim-markdown'
	use{
		'iamcco/markdown-preview.nvim',
		run = function() vim.fn["mkdp#util#install"]() end,
	}


	use 'ludovicchabant/vim-gutentags'
	
	use 'tpope/vim-surround'
	
	use 'SirVer/ultisnips'

	vim.g.UltiSnipsExpandTrigger = '<Tab>'
	vim.g.UltiSnipsJumpForwardTrigger = '<c-j>'
	vim.g.UltiSnipsJumpBackwardTrigger = '<c-k>'
	vim.g.UltiSnipsEditSplit = "tabdo"
	vim.g.UltiSnippetsStorageDirectoryForUltisnipsEdit = "/Users/vladyslav/.config/nvim/UltiSnips"

	use 'tpope/vim-fugitive'

	use 'tpope/vim-dispatch'

	use 'morhetz/gruvbox'
	vim.g.gruvbox_italic = 1
	vim.g.gruvbox_contrast_dark = "hard"
	use 'NLKNguyen/papercolor-theme'
	use 'ChrisKempson/Tomorrow-Theme'

	use 'vim-airline/vim-airline'
	use 'vim-airline/vim-airline-themes'

	vim.g.airline_detect_modified = 1
	vim.g.airline_detect_paste = 1
	vim.g.airline_detect_crypt = 1
	vim.g.airline_detect_spell = 1
	vim.g.airline_detect_spelllang = 1
	vim.g.airline_detect_iminsert = 1
	vim.g.airline_inactive_collapse = 1
	vim.g['airline#parts#ffenc#skip_expected_string'] = 'utf-8[unix]'
	vim.g.airline_symbols = {
		 colnr = 'col ',
		 crypt = '',
		 linenr = ' ',
		 maxlinenr = '㏑ ',
		 branch = '⎇ ',
		 paste = 'ρ',
		 spell = 'ഗ',
		 notexists = '∄',
		 whitespace = 'Ξ',
	 }
	 vim.g.airline_left_sep = ''
	 vim.g.airline_right_sep = ''
	 vim.g['airline#extensions#whitespace#enabled'] = 0
	 vim.g['airline#extensions#fzf#enabled'] = 1
	 vim.g['airline#extensions#gutentags#enabled'] = 1
	 vim.g['airline#extensions#ale#enabled'] = 1
		 vim.g['airline#extensions#ale#error_symbol'] = 'E:'
		 vim.g['airline#extensions#ale#warning_symbol'] = 'W:'
		 vim.g['airline#extensions#ale#show_line_numbers'] = 1
		 vim.g['airline#extensions#ale#open_lnum_symbol'] = '(L'
		 vim.g['airline#extensions#ale#close_lnum_symbol'] = ')'
	 vim.g['airline#extensions#tabline#enabled'] = 1
		 vim.g['airline#extensions#tabline#show_tabs'] = 1
		 vim.g['airline#extensions#tabline#tab_nr_type'] = 1 -- 0:splits, 1:tabn, 2:splits&tabn
		 vim.g['airline#extensions#tabline#show_tab_nr'] = 1
		 vim.g['airline#extensions#tabline#overflow_marker'] = '…'
		 vim.g['airline#extensions#tabline#show_tab_count'] = 1
		 vim.g['airline#extensions#tabline#show_tab_type'] = 1
		 vim.g['airline#extensions#tabline#buffers_label'] = 'B'
		 vim.g['airline#extensions#tabline#tabs_label'] = 'T'
		 vim.g['airline#extensions#tabline#show_close_button'] = 0
		 vim.g['airline#extensions#tabline#close_symbol'] = '×'
		 vim.g['airline#extensions#tabline#buffer_nr_format'] = "%s"
		 vim.g['airline#extensions#tabline#fnamemod'] = ':t'
		 vim.g['airline#extensions#tabline#tab_min_count'] = 2
		 vim.g['airline#extensions#tabline#buffer_min_count'] = 2
		 vim.g['airline#extensions#tabline#left_sep'] = ''
		 vim.g['airline#extensions#tabline#left_alt_sep'] = ''
		 vim.g['airline#extensions#tabline#right_sep'] = ''
		 vim.g['airline#extensions#tabline#right_alt_sep'] = ''
		 vim.g['airline#extensions#tabline#ignore_bufadd_pat'] = 'defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'
	 vim.g['airline#extensions#obsession#enabled'] = 1
		 vim.g['airline#extensions#obsession#indicator_text'] = "ⓢ "

end)

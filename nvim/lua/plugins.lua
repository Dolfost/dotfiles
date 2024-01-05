-- lazy.nvim bootstrap --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- lazy.nvim bootstrap -- 


require("lazy").setup({
	{'lervag/vimtex',
		ft = 'tex',
		config = function()
				require'config.vimtex'
			end,
	},

	{'mhinz/vim-grepper',
		config = function()
				require'config.vim-grepper'
			end,
	},

	{'junegunn/fzf',
		config = function()
			require'config.fzf'
		end,
	},

	{'nvim-treesitter/nvim-treesitter',
		config = function()
			require'config.treesitter'
		end,
		build = ":TSUpdate"
	},

	{'dense-analysis/ale',
		config = function()
			require'config.ale'
		end,
	},

	{'tpope/vim-unimpaired',
	},

	{'tpope/vim-commentary',
	},

	{'tpope/vim-obsession',
	},

	{'godlygeek/tabular',
	},

	{'preservim/vim-markdown',
		ft = 'markdown',
	},

	{'iamcco/markdown-preview.nvim',
		build = function() vim.fn["mkdp#util#install"]() end,
	},

	{'ludovicchabant/vim-gutentags',
	},
		
	{'tpope/vim-surround',
	},

	{'SirVer/ultisnips',
		config = function()
			require'config.ultisnips'
		end,
	},

	{'tpope/vim-fugitive',
	},

	{'tpope/vim-dispatch',
	},

	{
		'nvim-lualine/lualine.nvim',
		config = function()
			require'config.lualine'
		end,
		dependencies = { 'nvim-tree/nvim-web-devicons' }
	},

	{'morhetz/gruvbox',
		config = function()
			require'config.gruvbox'
		end,
		lazy = true,
	},

	{'NLKNguyen/papercolor-theme',
		lazy = true,
		priority = 1000,
	},
})

	-- use 'vim-airline/vim-airline'
	-- use 'vim-airline/vim-airline-themes'
-- 
	-- vim.g.airline_detect_modified = 1
	-- vim.g.airline_detect_paste = 1
	-- vim.g.airline_detect_crypt = 1
	-- vim.g.airline_detect_spell = 1
	-- vim.g.airline_detect_spelllang = 1
	-- vim.g.airline_detect_iminsert = 1
	-- vim.g.airline_inactive_collapse = 1
	-- vim.g['airline#parts#ffenc#skip_expected_string'] = 'utf-8[unix]'
	-- vim.g.airline_symbols = {
		 -- colnr = 'col ',
		 -- crypt = '',
		 -- linenr = ' ',
		 -- maxlinenr = '㏑ ',
		 -- branch = '⎇ ',
		 -- paste = 'ρ',
		 -- spell = 'ഗ',
		 -- notexists = '∄',
		 -- whitespace = 'Ξ',
	 -- }
	 -- vim.g.airline_left_sep = ''
	 -- vim.g.airline_right_sep = ''
	 -- vim.g['airline#extensions#whitespace#enabled'] = 0
	 -- vim.g['airline#extensions#fzf#enabled'] = 1
	 -- vim.g['airline#extensions#gutentags#enabled'] = 1
	 -- vim.g['airline#extensions#ale#enabled'] = 1
		 -- vim.g['airline#extensions#ale#error_symbol'] = 'E:'
		 -- vim.g['airline#extensions#ale#warning_symbol'] = 'W:'
		 -- vim.g['airline#extensions#ale#show_line_numbers'] = 1
		 -- vim.g['airline#extensions#ale#open_lnum_symbol'] = '(L'
		 -- vim.g['airline#extensions#ale#close_lnum_symbol'] = ')'
	 -- vim.g['airline#extensions#tabline#enabled'] = 1
		 -- vim.g['airline#extensions#tabline#show_tabs'] = 1
		 -- vim.g['airline#extensions#tabline#tab_nr_type'] = 1 -- 0:splits, 1:tabn, 2:splits&tabn
		 -- vim.g['airline#extensions#tabline#show_tab_nr'] = 1
		 -- vim.g['airline#extensions#tabline#overflow_marker'] = '…'
		 -- vim.g['airline#extensions#tabline#show_tab_count'] = 1
		 -- vim.g['airline#extensions#tabline#show_tab_type'] = 1
		 -- vim.g['airline#extensions#tabline#buffers_label'] = 'B'
		 -- vim.g['airline#extensions#tabline#tabs_label'] = 'T'
		 -- vim.g['airline#extensions#tabline#show_close_button'] = 0
		 -- vim.g['airline#extensions#tabline#close_symbol'] = '×'
		 -- vim.g['airline#extensions#tabline#buffer_nr_format'] = "%s"
		 -- vim.g['airline#extensions#tabline#fnamemod'] = ':t'
		 -- vim.g['airline#extensions#tabline#tab_min_count'] = 2
		 -- vim.g['airline#extensions#tabline#buffer_min_count'] = 2
		 -- vim.g['airline#extensions#tabline#left_sep'] = ''
		 -- vim.g['airline#extensions#tabline#left_alt_sep'] = ''
		 -- vim.g['airline#extensions#tabline#right_sep'] = ''
		 -- vim.g['airline#extensions#tabline#right_alt_sep'] = ''
		 -- vim.g['airline#extensions#tabline#ignore_bufadd_pat'] = 'defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'
	 -- vim.g['airline#extensions#obsession#enabled'] = 1
		 -- vim.g['airline#extensions#obsession#indicator_text'] = "ⓢ "
-- end)

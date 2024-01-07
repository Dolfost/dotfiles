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

local plugins = {
	{'lervag/vimtex',
		ft = 'tex',
		config = function()
			require'config.vimtex'
		end,
	},

	{'nvim-treesitter/nvim-treesitter',
		config = function()
			require'config.treesitter'
		end,
		build = ":TSUpdate"
	},

	{'L3MON4D3/LuaSnip',
		-- follow latest release.
		version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = 'make install_jsregexp',
		config = function()
			require'config.luasnip'
		end,
		dependencies = {'saadparwaiz1/cmp_luasnip', 'rafamadriz/friendly-snippets'},
	},

	{'hrsh7th/nvim-cmp',
		dependencies = {'neovim/nvim-lspconfig',
			'hrsh7th/cmp-cmdline',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-nvim-lsp',
			'onsails/lspkind.nvim',
		},
		config = function()
			require'config.lspconfig'
		end,
	},

	{"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function ()
			require("config.todo-comments")
		end
	},

	'tpope/vim-unimpaired',
	'tpope/vim-commentary',
	'tpope/vim-obsession',
	'tpope/vim-surround',
	'tpope/vim-fugitive',
	'tpope/vim-dispatch',

	'godlygeek/tabular',
	'ludovicchabant/vim-gutentags',

	{"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},

	{'preservim/vim-markdown',
		ft = 'markdown',
	},

	{'iamcco/markdown-preview.nvim',
		build = function() vim.fn['mkdp#util#install']() end,
	},

	{'nvim-lualine/lualine.nvim',
		config = function()
			require'config.lualine'
		end,
		dependencies = {'nvim-tree/nvim-web-devicons'}
	},

	{'nvim-neo-tree/neo-tree.nvim',
		branch = "v3.x",
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
			'MunifTanjim/nui.nvim',
			'3rd/image.nvim', -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		config = function()
			require'config.neo-tree'
		end,
	},

	{'nvim-telescope/telescope.nvim', tag = '0.1.5',
		dependencies = {'nvim-lua/plenary.nvim'}
    },

	-- Themes
	{'morhetz/gruvbox',
		-- config = function ()
		-- 	require("config.colorscheme")
		-- end,
		-- priority = 1000,
		lazy = true,
	},
	-- TODO: Do somethind with commenting out the config 
	-- field of theme plugins.

	{'NLKNguyen/papercolor-theme',
		-- config = function ()
		-- 	require("config.colorscheme")
		-- end,
		-- priority = 1000,
		lazy = true,
	},

	{"yorik1984/newpaper.nvim",
		-- priority = 1000,
		-- config = function ()
		-- 	require("config.colorscheme")
		-- end,
		lazy = true,
	},

	{"rebelot/kanagawa.nvim",
		-- priority = 1000,
		-- config = function ()
		-- 	require("config.colorscheme")
		-- end,
		lazy = true,
	},

	{"marko-cerovac/material.nvim",
		-- priority = 1000,
		-- config = function ()
		-- 	require("config.colorscheme")
		-- end,
		lazy = true,
	},

	{"catppuccin/nvim", 
		name = "catppuccin",
		priority = 1000,
		config = function ()
			require("config.colorscheme")
		end,
	},
		
}

local options = {}

require("lazy").setup(plugins, options)

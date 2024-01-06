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

	{'mhinz/vim-grepper',
		config = function()
				require'config.vim-grepper'
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

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		config = function()
			require'config.neo-tree'
		end,
	},

	{
		'nvim-telescope/telescope.nvim', tag = '0.1.5',
		dependencies = {'nvim-lua/plenary.nvim'}
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
}

local opts = {}

require("lazy").setup(plugins, opts)

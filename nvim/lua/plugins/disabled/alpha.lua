return {
	"goolord/alpha-nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},


	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = {
			[[                                                                       ]],
			[[                                                                       ]],
			[[                                                                       ]],
			[[                                                                       ]],
			[[                                                                     ]],
			[[       ████ ██████           █████      ██                     ]],
			[[      ███████████             █████                             ]],
			[[      █████████ ███████████████████ ███   ███████████   ]],
			[[     █████████  ███    █████████████ █████ ██████████████   ]],
			[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
			[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
			[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
			[[                                                                       ]],
			[[                                                                       ]],
			[[                                                                       ]],
		}

		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("<leader>ff", " Fuzzy file search", "<cmd>Telescope find_files<cr>"),
			dashboard.button("P", "  Plugins", "<cmd>Lazy<cr>"),
			dashboard.button("S", "  Language servers", "<cmd>Mason<cr>"),
			dashboard.button("T", "  Loading time", "<cmd>Lazy profile<cr>"),
			dashboard.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
		}

		dashboard.margin = 20

		alpha.setup(dashboard.opts)
	end,
}

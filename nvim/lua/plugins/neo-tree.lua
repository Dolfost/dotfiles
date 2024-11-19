return {
	{
		'nvim-neo-tree/neo-tree.nvim',

		branch = "v3.x",
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
			'MunifTanjim/nui.nvim',
			-- '3rd/image.nvim', -- Optional image support in preview window: See `# Preview Mode` for more information
		},

		cmd = 'Neotree',

		init = function ()
			local wk = require"which-key"

			wk.add{
				{ "<leader>n", group = "Neotree",
					icon = {icon = " ", color = 'purple' }
				},
				{ "<leader>nl", "<cmd>Neotree focus left<cr>",
					desc = "Open on the left",
					icon = {icon = "", color = 'purple' }
				},
				{ "<leader>nr", "<cmd>Neotree focus right<cr>",
					desc = "Open on the right",
					icon = {icon = "", color = 'purple' }
				},
				{ "<leader>nc", "<cmd>Neotree focus current<cr>",
					desc = "Open in this buffer",
					icon = {icon = "", color = 'green' }
				},
				{ "<leader>nf", "<cmd>Neotree focus float<cr>",
					desc = "Open as float",
					icon = {icon = "󰹉", color = 'yellow' }
				},
				{ "<leader>nt", group = "Open Neotree and reveal this file",
					icon = {icon = "", color = 'green' }
				},
				{ "<leader>ntl", "<cmd>Neotree focus left reveal<cr>",
					desc = "Open on the left and find this file",
					icon = {icon = "", color = 'purple' }
				},
				{ "<leader>ntr", "<cmd>Neotree focus right reveal<cr>",
					desc = "Open on the right and find this file",
					icon = {icon = "", color = 'purple' }
				},
				{ "<leader>ntc", "<cmd>Neotree focus current reveal<cr>",
					desc = "Open in this buffer and find this file",
					icon = {icon = "", color = 'green' }
				},
				{ "<leader>ntf", "<cmd>Neotree focus float reveal<cr>",
					desc = "Open as float and find this file",
					icon = {icon = "󰹉 ", color = 'green' }
				},
				{ "<leader>ng", group = "Git status"},
				{ "<leader>ngl", "<cmd>Neotree focus left git_status<cr>",
					desc = "Open on the left",
					icon = {icon = "", color = 'purple' }
				},
				{ "<leader>ngr", "<cmd>Neotree focus right git_status<cr>",
					desc = "Open on the right",
					icon = {icon = "", color = 'purple' }
				},
				{ "<leader>ngc", "<cmd>Neotree focus current git_status<cr>",
					desc = "Open in this buffer",
					icon = {icon = "", color = 'green' }
				},
				{ "<leader>ngf", "<cmd>Neotree focus float git_status<cr>",
					desc = "Open as float",
					icon = {icon = "󰹉 ", color = 'yellow' }
				},
				{ "<leader>nb", group = "Buffers"},
				{ "<leader>nbl", "<cmd>Neotree focus left buffers<cr>",
					desc = "Open on the left",
					icon = {icon = "", color = 'purple' }
				},
				{ "<leader>nbr", "<cmd>Neotree focus right buffers<cr>",
					desc = "Open on the right",
					icon = {icon = "", color = 'purple' }
				},
				{ "<leader>nbc", "<cmd>Neotree focus current buffers<cr>",
					desc = "Open in this buffer",
					icon = {icon = "", color = 'green' }
				},
				{ "<leader>nbf", "<cmd>Neotree focus float buffers<cr>",
					desc = "Open as float",
					icon = {icon = "󰹉 ", color = 'yellow' }
				},
			}
		end,

		opts = {
			window = {
				mappings = {
					["P"] = {"toggle_preview", config = { use_float = true, use_image_nvim = true}},
				}
			},

			sources = {
				'filesystem',
				"buffers",
				"git_status",
			},

      source_selector = {
        winbar = false, -- toggle to show selector on winbar
        statusline = false, -- toggle to show selector on statusline
        show_scrolled_off_parent_node = false,                    -- boolean
        sources = {                                               -- table
          {
            source = "filesystem",                                -- string
            display_name = " 󰉓 Files "                            -- string | nil
          },
          {
            source = "buffers",                                   -- string
            display_name = " 󰈚 Buffers "                          -- string | nil
          },
          {
            source = "git_status",                                -- string
            display_name = " 󰊢 Git "                              -- string | nil
          },
					{
						source = "remote",
					},
        },
        content_layout = "start",                                 -- string
        tabs_layout = "equal",                                    -- string
        truncation_character = "…",                               -- string
        tabs_min_width = nil,                                     -- int | nil
        tabs_max_width = nil,                                     -- int | nil
        padding = 0,                                              -- int | { left: int, right: int }
        separator = { left = "▏", right= "▕" },                   -- string | { left: string, right: string, override: string | nil }
        separator_active = nil,                                   -- string | { left: string, right: string, override: string | nil } | nil
        show_separator_on_edge = false,                           -- boolean
        highlight_tab = "NeoTreeTabInactive",                     -- string
        highlight_tab_active = "NeoTreeTabActive",                -- string
        highlight_background = "NeoTreeTabInactive",              -- string
        highlight_separator = "NeoTreeTabSeparatorInactive",      -- string
        highlight_separator_active = "NeoTreeTabSeparatorActive", -- string
      },

			default_component_configs = {
				git_status = {
					symbols = {
						-- Change type
						added     = "+", --  NOTE: you can set any of these to an empty string to not show them
						deleted   = "X",
						modified  = "",
						renamed   = "r",
						-- Status type
						untracked = "?",
						ignored   = "/",
						unstaged  = "u",
						staged    = "",
						conflict  = "",
					},
					align = "right",
				},
			},
		},
	},
}

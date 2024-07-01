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

			wk.register({
				n = {
					name = "Neotree",
					l = {"<cmd>Neotree focus left<cr>", "Open on the left"},
					r = {"<cmd>Neotree focus right<cr>", "Open on the right"},
					c = {"<cmd>Neotree focus current<cr>", "Open in this buffer"},
					f = {"<cmd>Neotree focus float<cr>", "Open as float"},
					t = {
						name = "Open Neotree and reveal this file",
						l = {"<cmd>Neotree focus left reveal<cr>", "Open on the left and find this file"},
						r = {"<cmd>Neotree focus right reveal<cr>", "Open on the right and find this file"},
						c = {"<cmd>Neotree focus current reveal<cr>", "Open in this buffer and find this file"},
						f = {"<cmd>Neotree focus float reveal<cr>", "Open as float and find this file"},
					},
					g = {
						name = "Git status",
						l = {"<cmd>Neotree focus left git_status<cr>", "Open on the left"},
						r = {"<cmd>Neotree focus right git_status<cr>", "Open on the right"},
						c = {"<cmd>Neotree focus current git_status<cr>", "Open in this buffer"},
						f = {"<cmd>Neotree focus float git_status<cr>", "Open as float"},
					},
					b = {
						name = "Buffers",
						l = {"<cmd>Neotree focus left buffers<cr>", "Open on the left"},
						r = {"<cmd>Neotree focus right buffers<cr>", "Open on the right"},
						c = {"<cmd>Neotree focus current buffers<cr>", "Open in this buffer"},
						f = {"<cmd>Neotree focus float buffers<cr>", "Open as float"},
					},
				},
			}, { prefix = "<leader>" })
		end,

		opts = {
			window = {
				mappings = {
					["P"] = {"toggle_preview", config = { use_float = true, use_image_nvim = true}},
				}
			},

			sources = {
				'filesystem',
				"netman.ui.neo-tree",
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

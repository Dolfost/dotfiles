vim.lsp.config('*', {
	capabilities = {
		textDocument = {
			semanticTokens = {
				multilineTokenSupport = true,
			}
		}
	},
	root_markers = { '.git' },
})


vim.lsp.enable({
	'rust_analyzer',
	'lua_ls',
	'clangd',
	-- 'ccls',
	'pyright',
	'cmake',
	'bashls',
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(ev)
		vim.keymap.del('n', 'K', { buffer = ev.buf })
		local wk = require "which-key"
		wk.add{
			{ "<leader>s", buffer = ev.buf,
				group = "Language server",
				icon = {icon = "", color = "purple"},
			},
			{ "<leader>sd", vim.diagnostic.open_float,
				desc = "Line diagnostics",
				icon = {icon = "󱖫", color = "green"},
			},
			{ "<leader>sg", group = "Go to symbol"},
			{ "<leader>sgD", vim.lsp.buf.declaration,
				desc = "Declaration",
				icon = {icon = "󱦹", color = "purple"},
			},
			{ "<leader>sgd", vim.lsp.buf.definition,
				desc = "Definition",
				icon = {icon = "", color = "purple"},
			},
			{ "<leader>sgi", vim.lsp.buf.implementation, desc = "Implementation"},
			{ "<leader>sgt", vim.lsp.buf.type_definition, desc = "Type definition"},
			{ "<leader>sk", vim.lsp.buf.signature_help,
				desc = "Symbol signature help",
				icon = {icon = '󰘥', color = 'purple'},
			},
			{ "<leader>sa", vim.lsp.buf.code_action,
				desc = "Code actions",
				mode = {"n", "v"},
				icon = {icon = '', color = 'green'},
			},
			{ "<leader>sK", vim.lsp.buf.hover,
				desc = "Information about the symbol",
				icon = {icon = '', color = 'green'},
			},
			{ "<leader>sw", group = "Workspace",
				icon = {icon = '', color = 'purple'},
			},
			{ "<leader>sw", vim.lsp.buf.add_workspace_folder,
				desc = "Add folder to the workspace",
				icon = {icon = '', color = 'green'},
			},
			{ "<leader>sw", vim.lsp.buf.remove_workspace_folder,
				desc = "Remove forlder from the workspace",
				icon = {icon = '', color = 'red'},
			},
			{ "<leader>sr", vim.lsp.buf.rename,
				desc = "Rename symbol",
				icon = {icon = '󰏪', color = 'purple'},
			},
			{ "<leader>sf", function()
				vim.lsp.buf.format{async = true}
			end,
				desc = "Format current buffer",
				icon = {icon = '󰉿', color = 'purple'},
			},
			{ "<leader>sl", group = "List", icon = {icon = '', color = 'purple'}},
			{ "<leader>slr", vim.lsp.buf.references, desc = "Current symbol references"},
			{ "<leader>sls", group = "Symbols", icon = {icon = '󰊕', color = 'purple'}},
			{ "<leader>sls", vim.lsp.buf.document_symbol, desc = "From current document"},
			{ "<leader>slw",vim.lsp.buf.workspace_symbol, desc = "From current workspace"},
			{ "<leader>slf",function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end,
				desc = "Workspace folders",
				icon = {icon = '', color = 'purple'},
			},
			{ "<leader>sc", group = "Calls", icon = {icon = '', color = 'purple'}},
			{ "<leader>sco", vim.lsp.buf.outgoing_calls,
				desc = "Symbol outgoing calls",
				icon = {icon = '', color = 'purple'},
			},
			{ "<leader>sci",vim.lsp.buf.incoming_calls,
				desc = "Symbol incoming calls",
				icon = {icon = '', color = 'purple'},
			},
		}
	end,
})

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
	'html'
})

local grp = vim.api.nvim_create_augroup('my.lsp', {})
local wk = require "which-key"

vim.api.nvim_create_autocmd('LspAttach', {
	group = grp,
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		wk.add{
			{ "<leader>s", buffer = ev.buf,
				group = "Language server",
				icon = {icon = "", color = "purple"},
			},
			{ "<leader>sd", vim.diagnostic.open_float,
				desc = "Line diagnostics",
				icon = { icon = "󱖫", color = "green" },
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
				desc = "Symbol signature",
				icon = {icon = '󰘥', color = 'purple'},
			},
			{ "<leader>sa", vim.lsp.buf.code_action,
				desc = "Code actions",
				mode = {"n", "v"},
				icon = {icon = '', color = 'green'},
			},
			{ "<leader>sK", vim.lsp.buf.hover,
				desc = "Symbol info",
				icon = {icon = '', color = 'green'},
			},
			{ "<leader>sw", group = "Workspace",
				icon = {icon = '', color = 'purple'},
			},
			{ "<leader>swa", vim.lsp.buf.add_workspace_folder,
				desc = "Add directory to the workspace",
				icon = {icon = '', color = 'green'},
			},
			{ "<leader>swr", vim.lsp.buf.remove_workspace_folder,
				desc = "Remove directory from the workspace",
				icon = {icon = '', color = 'red'},
			},
			{ "<leader>sr", vim.lsp.buf.rename,
				desc = "Rename symbol",
				icon = {icon = '󰏪', color = 'purple'},
			},
			{ "<leader>sf", function()
				vim.lsp.buf.format{async = true}
			end,
				desc = "Format buffer",
				icon = {icon = '󰉿', color = 'purple'},
			},
			{ "<leader>sl", group = "List", icon = {icon = '', color = 'purple'}},
			{ "<leader>slr", vim.lsp.buf.references, desc = "Current symbol references"},
			{ "<leader>sld", vim.lsp.buf.document_symbol, desc = "Document symbols"},
			{ "<leader>slw",vim.lsp.buf.workspace_symbol, desc = "Workspace symbols"},
			{ "<leader>slf",function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end,
				desc = "Workspace folders",
				icon = {icon = '', color = 'purple'},
			},
			{ "<leader>sc", group = "Calls", icon = {icon = '', color = 'purple'}},
			{ "<leader>sco", vim.lsp.buf.outgoing_calls,
				desc = "Outgoing",
				icon = {icon = '', color = 'purple'},
			},
			{ "<leader>sci",vim.lsp.buf.incoming_calls,
				desc = "Incoming",
				icon = {icon = '', color = 'purple'},
			},
		}

		-- highlighing of the symbol under cursor (if supported)
		if client and client:supports_method('textDocument/documentHighlight') then
			vim.api.nvim_create_autocmd('CursorHold', {
				group = grp,
				callback = function()
					vim.lsp.buf.document_highlight()
				end,
				buffer = ev.buf
			})
			vim.api.nvim_create_autocmd('CursorHoldI', {
				group = grp,
				callback = function()
					vim.lsp.buf.document_highlight()
				end,
				buffer = ev.buf
			})
			vim.api.nvim_create_autocmd('CursorMoved', {
				group = grp,
				callback = function()
					vim.lsp.buf.clear_references()
				end,
				buffer = ev.buf
			})
		end
	end,
})


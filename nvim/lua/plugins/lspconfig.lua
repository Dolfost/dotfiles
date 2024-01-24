local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return {
	{
		'williamboman/mason-lspconfig.nvim',

		dependencies = {
			{ "williamboman/mason.nvim", config = true, },
		},


		opts = {
			ensure_installed = {
				'lua_ls',
				'clangd',
				'omnisharp',
				'pyright',
				'neocmake',
				'ast_grep',
			},
		},
	},

	{
		'neovim/nvim-lspconfig',


		config = function(_, opts)
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			local lspconfig = require("lspconfig")

			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
					vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
					vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
					vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
					vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
					vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set('n', '<leader>wl', function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, opts)
					vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
					vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
					vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
					vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
					vim.keymap.set('n', '<leader>f', function()
						vim.lsp.buf.format { async = true }
					end, opts)
				end,
			})

			lspconfig.lua_ls.setup {
				capabilities = capabilities,
			}
			lspconfig.clangd.setup {
				capabilities = capabilities,
				cmd = {vim.fn.stdpath("data") .. "/mason/bin/clangd"},
				filetypes = { "c", "cpp", "h", "hpp", "objc", "objcpp", "cuda", "proto" }
			}
			lspconfig.omnisharp.setup {
				capabilities = capabilities,
				cmd = { "dotnet", vim.fn.stdpath "data" .. "/mason/packages/omnisharp/libexec/OmniSharp.dll" },
				enable_import_completion = true,
				organize_imports_on_format = true,
				enable_roslyn_analyzers = true,
				root_dir = vim.loop.cwd, -- current working directory
			}
			lspconfig.pyright.setup {
				capabilities = capabilities,
			}
			lspconfig.neocmake.setup {
				capabilities = capabilities,
			}
		end,
	},

	{
		'L3MON4D3/LuaSnip',

		-- follow latest release.
		version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = 'make install_jsregexp',
		dependencies = { 'rafamadriz/friendly-snippets' },


		config = function()
			local ls = require 'luasnip'
			require('luasnip.loaders.from_lua').load({ paths = '~/.config/nvim/LuaSnip/' })
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	{
		'hrsh7th/nvim-cmp',

		dependencies = {
			'neovim/nvim-lspconfig',
			{ "williamboman/mason.nvim", config = true, },
			'williamboman/mason-lspconfig.nvim',
			'onsails/lspkind.nvim',

			'hrsh7th/cmp-cmdline',
			'FelipeLema/cmp-async-path',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-nvim-lsp',
			'saadparwaiz1/cmp_luasnip',
			'tamago324/cmp-zsh',
			'petertriho/cmp-git',
			{ 'micangl/cmp-vimtex',      ft = 'tex' },
			{ 'hrsh7th/cmp-nvim-lua',    ft = 'lua' },
		},


		config = function()
			local cmp = require 'cmp'
			local ls = require 'luasnip'
			local lspkind = require 'lspkind'

			cmp.setup({
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						require('luasnip').lsp_expand(args.body)
					end,
				},

				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},

				experimental = {
					ghost_text = true
				},

				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

					-- LuaSnip support
					['<Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
							-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
							-- that way you will only jump inside the snippet region
						elseif ls.expand_or_jumpable() then
							ls.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif ls.jumpable(-1) then
							ls.jump(-1)
						else
							fallback()
						end
					end, { 'i', 's' }),
				}),

				formatting = {
					fields = { 'abbr', 'kind', 'menu' },
					format = lspkind.cmp_format({
						mode = 'text_symbol',
						-- menu = {
						-- 	buffer = '[Buf]',
						-- 	nvim_lsp = '[LSP]',
						-- 	luasnip = '[lSnip]',
						-- 	nvim_lua = '[Lua]',
						-- 	latex_symbols = '[tex]',
						-- 	vimtex = '[vimtex]',
						-- },
					}),
				},

				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'async_path' },
					{ name = 'buffer' },
				}),
			})

			cmp.setup.filetype('gitcommit', {
				sources = cmp.config.sources({
					{ name = 'git',        group_index = 1 },
					{ name = 'buffer',     group_index = 2 },
					{ name = 'async_path', group_index = 2 },
				}),
			})

			cmp.setup.filetype("tex", {
				sources = {
					{ name = 'vimtex' },
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'async_path' },
					{ name = 'buffer' },
				},
			})

			cmp.setup.filetype("lua", {
				sources = {
					{ name = 'nvim_lua' },
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'async_path' },
					{ name = 'buffer' },
				},
			})

			cmp.setup.cmdline({ '/', '?' }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'buffer' }
				}
			})

			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					-- { name = 'path' },
					{
						name = 'cmdline',
						group_index = 1,
						option = {
							ignore_cmds = { 'Man', '!' }
						},
					},
					{
						name = 'zsh',
						group_index = 2,
					},
				})
			})
		end,
	}
}

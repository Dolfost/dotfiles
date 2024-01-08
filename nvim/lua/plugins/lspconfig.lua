local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end


return {
	{
		'hrsh7th/nvim-cmp',

		dependencies = {
			'neovim/nvim-lspconfig',
			'hrsh7th/cmp-cmdline',
			'FelipeLema/cmp-async-path',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-nvim-lsp',
			'onsails/lspkind.nvim',
			'tamago324/cmp-zsh',
			{'micangl/cmp-vimtex', ft = 'tex'},
			{'hrsh7th/cmp-nvim-lua', ft = 'lua'},
		},


		config = function()
			local cmp = require'cmp'
			local ls = require'luasnip'
			local lspkind = require'lspkind'

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
					fields = {'abbr', 'kind', 'menu'},
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
				{name = 'nvim_lsp'},
					{name = 'luasnip'},
					{name = 'buffer'},
					{name = 'path'},
				}),
			})

			cmp.setup.filetype('gitcommit', {
				sources = cmp.config.sources({
					{ name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
					}, {
					{ name = 'buffer' },
				})
			})

			cmp.setup.cmdline({ '/', '?' }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
				{ name = 'buffer' }
				}
			})

			cmp.setup.filetype("tex", {
				sources = {
					{name = 'vimtex'},
				{name = 'nvim_lsp'},
					{name = 'luasnip'},
					{name = 'buffer'},
					{name = 'path'},
				},
			})

			cmp.setup.filetype("lua", {
				sources = {
				{name = 'nvim_lsp'},
				{name = 'nvim_lua'},
					{name = 'luasnip'},
					{name = 'buffer'},
					{name = 'path'},
				},
			})

			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					-- { name = 'path' },
					{ name = 'zsh' },
					}, {
						{
							name = 'cmdline',
							option = {
								ignore_cmds = { 'Man', '!' }
							}
						}
				})
			})


			-- Set up lspconfig.
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
			require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
				capabilities = capabilities
			}
		end,
	}
}

return {
	"danymat/neogen",

	-- opts = 
	init = function ()
		local wk = require"which-key"
			wk.add{
				{ "<leader>x", "<cmd>Neogen<cr>",
					desc = "Insert documentation block",
					icon = {icon = " ", color = 'yellow'}, },
		}
	end,

	cmd = {
		'Neogen',
	},

	config = function ()
		local neogen = require("neogen")

		neogen.setup({
			snippet_engine = 'luasnip',
			placeholders_text = {
				["description"] = " TODO: description",
				["tparam"] = " TODO: tparam",
				["parameter"] = " TODO: parameter",
				["return"] = " TODO: return",
				["class"] = " TODO: class",
				["throw"] = " TODO: throw",
				["varargs"] = " TODO: varargs",
				["type"] = " TODO: type",
				["attribute"] = " TODO: attribute",
				["args"] = " TODO: args",
				["kwargs"] = " TODO: kwargs",
			},
			languages = {
			},
		})

	end
}
